-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 08.07.2015 13:35:52
-- Module Name : pcie_rx.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_rx is
generic (
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_STRADDLE         : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1');

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; -- TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   -- TPARITY width
);
port(
-- Completer Request Interface
p_in_m_axis_cq_tdata      : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tlast      : in  std_logic;
p_in_m_axis_cq_tvalid     : in  std_logic;
p_in_m_axis_cq_tuser      : in  std_logic_vector(84 downto 0);
p_in_m_axis_cq_tkeep      : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_pcie_cq_np_req_count : in  std_logic_vector(5 downto 0);
p_out_m_axis_cq_tready    : out std_logic;
p_out_pcie_cq_np_req      : out std_logic;

-- Requester Completion Interface
p_in_m_axis_rc_tdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tlast    : in  std_logic;
p_in_m_axis_rc_tvalid   : in  std_logic;
p_in_m_axis_rc_tkeep    : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser    : in  std_logic_vector(74 downto 0);
p_out_m_axis_rc_tready  : out std_logic;

--RX Message Interface
--This input is active only when the
--AXISTEN_IF_ENABLE_RX_MSG_INTFC attribute is set.
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

--Completion
p_out_req_compl    : out std_logic;
p_out_req_compl_ur : out std_logic;--Unsupported Request
p_in_compl_done    : in  std_logic;

p_out_req_type     : out std_logic_vector(3 downto 0);
p_out_req_tc       : out std_logic_vector(2 downto 0) ;-- Memory Read TC
p_out_req_attr     : out std_logic_vector(2 downto 0) ;-- Memory Read Attribute
p_out_req_len      : out std_logic_vector(10 downto 0);-- Memory Read Length
p_out_req_rid      : out std_logic_vector(15 downto 0);-- Memory Read Requestor ID {8'b0 (Bus no),3'b0 (Dev no), 5'b0 (Func no)}
p_out_req_tag      : out std_logic_vector(7 downto 0) ;-- Memory Read Tag
p_out_req_be       : out std_logic_vector(7 downto 0) ;-- Memory Read Byte Enables
p_out_req_addr     : out std_logic_vector(12 downto 0);-- Memory Read Address
p_out_req_at       : out std_logic_vector(1 downto 0) ;-- Address Translation

p_out_req_des_qword0      : out std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
p_out_req_des_qword1      : out std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
p_out_req_des_tph_present : out std_logic;                    -- TPH Present in the request
p_out_req_des_tph_type    : out std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
p_out_req_des_tph_st_tag  : out std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

--usr app
p_out_ureg_di  : out std_logic_vector(31 downto 0);
p_out_ureg_wrbe: out std_logic_vector(3 downto 0);
p_out_ureg_wr  : out std_logic;
p_out_ureg_rd  : out std_logic;

--DBG
p_out_tst : out std_logic_vector(31 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_rx;

architecture behavioral of pcie_rx is

type TFsmRx_state is (
S_RX_IDLE,
S_RX_CHK2,
S_RX_CHK3,
S_RX_CHK4,
S_RX_DATA,
S_RX_WAIT,
S_RX_WAIT2
);
signal i_fsm_rx              : TFsmRx_state;

signal i_sop                 : std_logic;

signal i_m_axis_cq_tready    : std_logic := '0';
signal i_m_axis_rc_tready    : std_logic := '1';

signal i_req_pkt             : std_logic_vector(3 downto 0);
signal i_req_tc              : std_logic_vector(2 downto 0) ;
signal i_req_attr            : std_logic_vector(2 downto 0) ;
signal i_req_len             : std_logic_vector(10 downto 0);
signal i_req_rid             : std_logic_vector(15 downto 0);
signal i_req_tag             : std_logic_vector(7 downto 0) ;
signal i_req_be              : std_logic_vector(7 downto 0) ;
signal i_req_addr            : std_logic_vector(12 downto 0);
signal i_req_at              : std_logic_vector(1 downto 0) ;
signal i_trg_func            : std_logic_vector(7 downto 0);
signal i_bar_id              : std_logic_vector(2 downto 0);

signal i_req_des_qword0      : std_logic_vector(63 downto 0);
signal i_req_des_qword1      : std_logic_vector(63 downto 0);
signal i_req_des_tph_present : std_logic;
signal i_req_des_tph_type    : std_logic_vector(1 downto 0) ;
signal i_req_des_tph_st_tag  : std_logic_vector(7 downto 0) ;

signal i_req_compl           : std_logic := '0';
signal i_req_compl_ur        : std_logic := '0';


signal i_reg_d               : std_logic_vector(31 downto 0);
signal i_reg_wrbe            : std_logic_vector(3 downto 0);
signal i_reg_wr              : std_logic;
signal i_reg_rd              : std_logic;

signal tst_err                 : std_logic;
signal tst_fsm_rx            : unsigned(1 downto 0);


begin --architecture behavioral of pcie_rx


p_out_ureg_wr <= i_reg_wr;
p_out_ureg_rd <= i_reg_rd;
p_out_ureg_wrbe <= i_reg_wrbe;
p_out_ureg_di <= i_reg_d;

--p_out_payload_len <= '0';

p_out_req_type <= i_req_pkt;
p_out_req_tc   <= i_req_tc  ;
p_out_req_attr <= i_req_attr;
p_out_req_len  <= i_req_len ;
p_out_req_rid  <= i_req_rid ;
p_out_req_tag  <= i_req_tag ;
p_out_req_be   <= i_req_be  ;
p_out_req_addr <= i_req_addr;
p_out_req_at   <= i_req_at  ;

p_out_req_des_qword0      <= i_req_des_qword0     ;
p_out_req_des_qword1      <= i_req_des_qword1     ;
p_out_req_des_tph_present <= i_req_des_tph_present;
p_out_req_des_tph_type    <= i_req_des_tph_type   ;
p_out_req_des_tph_st_tag  <= i_req_des_tph_st_tag ;

p_out_req_compl    <= i_req_compl;
p_out_req_compl_ur <= i_req_compl_ur;

p_out_pcie_cq_np_req <= '1';

p_out_m_axis_cq_tready <= i_m_axis_cq_tready;-- and i_m_axis_cq_tready2;
p_out_m_axis_rc_tready <= i_m_axis_rc_tready;

--gen_pload_byte_en : for i in 0 to i_pload_byte_en'length - 1 generate begin
--i_pload_byte_en(i) <= p_in_m_axis_cq_tuser(8 + (4 * i)) ;
--end generate gen_pload_byte_en;

i_sop <= p_in_m_axis_cq_tuser(40);--not i_in_pkt_q and p_in_m_axis_cq_tvalid; --


i_m_axis_rc_tready <= '1';

--Rx State Machine
fsm : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_rx <= S_RX_IDLE;

    i_m_axis_cq_tready <= '0';

    i_req_compl    <= '0';
    i_req_compl_ur <= '0';

    i_req_des_qword0 <= (others => '0');
    i_req_des_qword1 <= (others => '0');

    i_req_attr <= (others => '0');
    i_req_tc   <= (others => '0');
    i_bar_id   <= (others => '0');
    i_trg_func <= (others => '0');
    i_req_tag  <= (others => '0');
    i_req_rid  <= (others => '0');
    i_req_pkt  <= (others => '0');
    i_req_len  <= (others => '0');
    i_req_addr <= (others => '0');
    i_req_at   <= (others => '0');

    i_req_be   <= (others => '0');

    i_req_des_tph_present <= '0';
    i_req_des_tph_type    <= (others => '0');
    i_req_des_tph_st_tag  <= (others => '0');

    i_reg_d <= (others => '0');
    i_reg_wrbe <= (others => '0');
    i_reg_wr   <= '0'; tst_err <= '0';
    i_reg_rd   <= '0';

  else

    case i_fsm_rx is
        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RX_IDLE =>

            i_reg_wr <= '0';

            if p_in_m_axis_cq_tvalid = '0' then
              i_m_axis_cq_tready <= '1';

            elsif i_sop = '1' then

              i_req_be   <= p_in_m_axis_cq_tuser(7 downto 4) & p_in_m_axis_cq_tuser(3 downto 0);

              i_req_des_tph_present <= p_in_m_axis_cq_tuser(42);
              i_req_des_tph_type    <= p_in_m_axis_cq_tuser(44 downto 43);
              i_req_des_tph_st_tag  <= p_in_m_axis_cq_tuser(52 downto 45);

              --#######################################
              --cq_tkeep(7 downto 0) = "00011111"
              --#######################################
              if p_in_m_axis_cq_tkeep(7 downto 0) = "00011111" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 1) - 1 downto (32 * 0));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 2) - 1 downto (32 * 1));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 3) - 1 downto (32 * 2));
                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 4) - 1 downto (32 * 3));

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 3) + 30) downto ((32 * 3) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 3) + 27) downto ((32 * 3) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 3) + 18) downto ((32 * 3) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 3) + 15) downto ((32 * 3) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 3) +  7) downto ((32 * 3) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 2) + 31) downto ((32 * 2) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 2) + 10) downto ((32 * 2) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 0) + 12) downto ((32 * 0) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 0) +  1) downto ((32 * 0) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 2) + 10) downto ((32 * 2) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 5) - 1 downto (32 * 4));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 5)) - 1 downto (8 + (4 * 4)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 2) + 14) downto ((32 * 2) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case;--Req Type



              --#######################################
              --cq_tkeep(7 downto 0) = "00111110"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "00111110" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 2) - 1 downto (32 * 1));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 3) - 1 downto (32 * 2));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 4) - 1 downto (32 * 3));
                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 5) - 1 downto (32 * 4));

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 4) + 30) downto ((32 * 4) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 4) + 27) downto ((32 * 4) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 4) + 18) downto ((32 * 4) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 4) + 15) downto ((32 * 4) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 4) +  7) downto ((32 * 4) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 3) + 31) downto ((32 * 3) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 3) + 10) downto ((32 * 3) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 1) + 12) downto ((32 * 1) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 1) +  1) downto ((32 * 1) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 3) + 10) downto ((32 * 3) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 6) - 1 downto (32 * 5));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 6)) - 1 downto (8 + (4 * 5)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 3) + 14) downto ((32 * 3) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type



              --#######################################
              --cq_tkeep(7 downto 0) = "01111100"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "01111100" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 3) - 1 downto (32 * 2));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 4) - 1 downto (32 * 3));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 5) - 1 downto (32 * 4));
                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 6) - 1 downto (32 * 5));

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 5) + 30) downto ((32 * 5) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 5) + 27) downto ((32 * 5) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 5) + 18) downto ((32 * 5) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 5) + 15) downto ((32 * 5) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 5) +  7) downto ((32 * 5) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 4) + 31) downto ((32 * 4) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 4) + 10) downto ((32 * 4) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 2) + 12) downto ((32 * 2) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 2) +  1) downto ((32 * 2) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 4) + 10) downto ((32 * 4) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 7) - 1 downto (32 * 6));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 7)) - 1 downto (8 + (4 * 6)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 4) + 14) downto ((32 * 4) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type



              --#######################################
              --cq_tkeep(7 downto 0) = "11111000"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "11111000" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 4) - 1 downto (32 * 3));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 5) - 1 downto (32 * 4));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 6) - 1 downto (32 * 5));
                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 7) - 1 downto (32 * 6));

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 6) + 30) downto ((32 * 6) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 6) + 27) downto ((32 * 6) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 6) + 18) downto ((32 * 6) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 6) + 15) downto ((32 * 6) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 6) +  7) downto ((32 * 6) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 5) + 31) downto ((32 * 5) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 5) + 10) downto ((32 * 5) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 3) + 12) downto ((32 * 3) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 3) +  1) downto ((32 * 3) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 5) + 10) downto ((32 * 5) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 8) - 1 downto (32 * 7));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 8)) - 1 downto (8 + (4 * 7)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type



              --#######################################
              --cq_tkeep(7 downto 0) = "11110000"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "11110000" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 5) + 14) downto ((32 * 5) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 5) - 1 downto (32 * 4));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 6) - 1 downto (32 * 5));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 7) - 1 downto (32 * 6));
                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 8) - 1 downto (32 * 7));

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 7) + 30) downto ((32 * 7) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 7) + 27) downto ((32 * 7) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 7) + 18) downto ((32 * 7) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 7) + 15) downto ((32 * 7) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 7) +  7) downto ((32 * 7) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 6) + 31) downto ((32 * 6) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 6) + 10) downto ((32 * 6) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 4) + 12) downto ((32 * 4) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 4) +  1) downto ((32 * 4) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 6) + 10) downto ((32 * 6) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_fsm_rx <= S_RX_DATA;

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_fsm_rx <= S_RX_DATA;

                                  elsif (p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 6) + 14) downto ((32 * 6) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';
                                      i_fsm_rx <= S_RX_WAIT;

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                            i_fsm_rx <= S_RX_WAIT;
                          end if;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type



              --#######################################
              --cq_tkeep(7 downto 0) = "11100000"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "11100000" then
                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 7) + 14) downto ((32 * 7) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 6) - 1 downto (32 * 5));
                          i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 7) - 1 downto (32 * 6));
                          i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 8) - 1 downto (32 * 7));
--                          i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 9) - 1 downto (32 * 8));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 7) + 31) downto ((32 * 7) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 7) + 14) downto ((32 * 7) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 7) + 10) downto ((32 * 7) +  0)); --Length data payload (DW)

                          i_req_addr <= p_in_m_axis_cq_tdata(((32 * 5) + 12) downto ((32 * 5) + 2)) & "00";
                          i_req_at   <= p_in_m_axis_cq_tdata(((32 * 5) +  1) downto ((32 * 5) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 7) + 10) downto ((32 * 7) + 0))) = TO_UNSIGNED(16#01#, 11) then

                            i_fsm_rx <= S_RX_CHK2;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                            i_fsm_rx <= S_RX_WAIT;
                          end if;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type




              --#######################################
              --cq_tkeep(7 downto 0) = "11000000"
              --#######################################
              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "11000000" then

                i_m_axis_cq_tready <= '0';

                i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 7) - 1 downto (32 * 6));
                i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 8) - 1 downto (32 * 7));

                i_fsm_rx <= S_RX_CHK3;

              elsif p_in_m_axis_cq_tkeep(7 downto 0) = "10000000" then

                i_m_axis_cq_tready <= '0';

                i_req_des_qword0((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 8) - 1 downto (32 * 7));

                i_fsm_rx <= S_RX_CHK4;


              else
                i_m_axis_cq_tready <= '0';
                tst_err <= '1';
                i_fsm_rx <= S_RX_WAIT2;

              end if;--if p_in_m_axis_cq_tkeep(7 downto 0) = "00011111" then

            end if; --if p_in_m_axis_cq_tvalid = '1' then
        --end S_RX_IDLE :



        --#######################################################################
        --
        --#######################################################################
        when S_RX_CHK2 =>

            if p_in_m_axis_cq_tvalid = '1' then
                i_m_axis_cq_tready <= '0';

                if p_in_m_axis_cq_tkeep(7 downto 0) = "00000011" then

                    i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 1) - 1 downto (32 * 0));

                    i_req_attr <= p_in_m_axis_cq_tdata(((32 * 0) + 30) downto ((32 * 0) + 28));
                    i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 0) + 27) downto ((32 * 0) + 25));
                    i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 0) + 18) downto ((32 * 0) + 16));
                    i_trg_func <= p_in_m_axis_cq_tdata(((32 * 0) + 15) downto ((32 * 0) +  8));
                    i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 0) +  7) downto ((32 * 0) +  0));

                    i_reg_d    <= p_in_m_axis_cq_tdata((32 * 2) - 1 downto (32 * 1));
                    i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 2)) - 1 downto (8 + (4 * 1)));

                    --Compl
                    if (i_req_pkt = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                        i_req_compl <= '0';
                        i_reg_wr <= '1';

                    else
                        i_req_compl <= '1';

                        if (i_req_pkt = C_PCIE3_PKT_TYPE_IO_WR_D) then

                          i_reg_wr <= '1';

                        elsif (i_req_pkt = C_PCIE3_PKT_TYPE_IO_RD_ND)
                           or (i_req_pkt = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                           or (i_req_pkt = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                            i_reg_rd <= '1';

                        end if;
                    end if;

                    i_fsm_rx <= S_RX_WAIT;

                else
                  tst_err <= '1';
                  i_fsm_rx <= S_RX_WAIT2;

                end if;
            end if;
        --end S_RX_CHK2 :


        --#######################################################################
        --
        --#######################################################################
        when S_RX_CHK3 =>

            if p_in_m_axis_cq_tvalid = '1' then
                if p_in_m_axis_cq_tkeep(7 downto 0) = "00000111" then

                    i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 1) - 1 downto (32 * 0));
                    i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 2) - 1 downto (32 * 1));

                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 1) + 30) downto ((32 * 1) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 1) + 27) downto ((32 * 1) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 1) + 18) downto ((32 * 1) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 1) + 15) downto ((32 * 1) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 1) +  7) downto ((32 * 1) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 0) + 31) downto ((32 * 0) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 0) + 10) downto ((32 * 0) +  0)); --Length data payload (DW)

                          i_req_addr <= i_req_des_qword0(((32 * 0) + 12) downto ((32 * 0) + 2)) & "00";
                          i_req_at   <= i_req_des_qword0(((32 * 0) +  1) downto ((32 * 0) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 0) + 10) downto ((32 * 0) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 3) - 1 downto (32 * 2));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 3)) - 1 downto (8 + (4 * 2)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 0) + 14) downto ((32 * 0) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type

                else
                  tst_err <= '1';
                  i_fsm_rx <= S_RX_WAIT2;

                end if;
            end if;
        --end S_RX_CHK3 :



        --#######################################################################
        --
        --#######################################################################
        when S_RX_CHK4 =>

            if p_in_m_axis_cq_tvalid = '1' then
                if p_in_m_axis_cq_tkeep(7 downto 0) = "00001111" then

                    i_req_des_qword0((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 1) - 1 downto (32 * 0));
                    i_req_des_qword1((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_cq_tdata((32 * 2) - 1 downto (32 * 1));
                    i_req_des_qword1((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_cq_tdata((32 * 3) - 1 downto (32 * 2));

                    --Req Type
                    case p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) is
                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                        when C_PCIE3_PKT_TYPE_MEM_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                            | C_PCIE3_PKT_TYPE_MEM_WR_D
                            | C_PCIE3_PKT_TYPE_IO_RD_ND
                            | C_PCIE3_PKT_TYPE_IO_WR_D =>

                          i_m_axis_cq_tready <= '0';

                          i_req_attr <= p_in_m_axis_cq_tdata(((32 * 2) + 30) downto ((32 * 2) + 28));
                          i_req_tc   <= p_in_m_axis_cq_tdata(((32 * 2) + 27) downto ((32 * 2) + 25));
                          i_bar_id   <= p_in_m_axis_cq_tdata(((32 * 2) + 18) downto ((32 * 2) + 16));
                          i_trg_func <= p_in_m_axis_cq_tdata(((32 * 2) + 15) downto ((32 * 2) +  8));
                          i_req_tag  <= p_in_m_axis_cq_tdata(((32 * 2) +  7) downto ((32 * 2) +  0));

                          i_req_rid  <= p_in_m_axis_cq_tdata(((32 * 1) + 31) downto ((32 * 1) + 16));
                          i_req_pkt  <= p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11));
                          i_req_len  <= p_in_m_axis_cq_tdata(((32 * 1) + 10) downto ((32 * 1) +  0)); --Length data payload (DW)

                          i_req_addr <= i_req_des_qword0(((32 * 0) + 12) downto ((32 * 0) + 2)) & "00";
                          i_req_at   <= i_req_des_qword0(((32 * 0) +  1) downto ((32 * 0) + 0));

                          --Check length data payload (DW)
                          if UNSIGNED(p_in_m_axis_cq_tdata(((32 * 1) + 10) downto ((32 * 1) + 0))) = TO_UNSIGNED(16#01#, 11) then

                              i_reg_d    <= p_in_m_axis_cq_tdata((32 * 4) - 1 downto (32 * 3));
                              i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 4)) - 1 downto (8 + (4 * 3)));

                              --Compl
                              if (p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) = C_PCIE3_PKT_TYPE_MEM_WR_D) then

                                  i_req_compl <= '0';
                                  i_reg_wr <= '1';

                              else
                                  i_req_compl <= '1';

                                  if (p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) = C_PCIE3_PKT_TYPE_IO_WR_D) then

                                    i_reg_wr <= '1';

                                  elsif (p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                                     or (p_in_m_axis_cq_tdata(((32 * 1) + 14) downto ((32 * 1) + 11)) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                                      i_reg_rd <= '1';

                                  end if;
                              end if;

                          else
                            i_req_compl    <= '0';
                            i_req_compl_ur <= '1';--Unsupported Request

                            i_bar_id <= (others => '0');
                            i_trg_func <= (others => '0');

                          end if;

                          i_fsm_rx <= S_RX_WAIT;

                        -------------------------------------------------------------------------
                        --
                        -------------------------------------------------------------------------
                         when others =>
                            i_fsm_rx <= S_RX_IDLE;

                    end case; --Req Type

                else
                  tst_err <= '1';
                  i_fsm_rx <= S_RX_WAIT2;

                end if;
            end if;
        --end S_RX_CHK4 :


        --#######################################################################
        --
        --#######################################################################
        when S_RX_DATA =>

            i_req_compl <= '0';

            if p_in_m_axis_cq_tvalid = '1' then

                i_reg_wr <= '1';

                if p_in_m_axis_cq_tkeep(7 downto 0) = "00000001" then

                  i_m_axis_cq_tready <= '1';

                  i_reg_d    <= p_in_m_axis_cq_tdata((32 * 1) - 1 downto (32 * 0));
                  i_reg_wrbe <= p_in_m_axis_cq_tuser((8 + (4 * 1)) - 1 downto (8 + (4 * 0)));

                  i_fsm_rx <= S_RX_IDLE;

                else

                  tst_err <= '1';
                  i_fsm_rx <= S_RX_WAIT2;

                end if;

            end if;
        --end S_RX_DATA :


        --#######################################################################
        --
        --#######################################################################
        when S_RX_WAIT =>

            i_reg_wr <= '0';
            i_reg_rd <= '0';
            i_req_compl <= '0';
            i_req_compl_ur <= '0';

            if p_in_compl_done = '1' or i_req_compl = '0' then

              i_m_axis_cq_tready <= '1';
              i_fsm_rx <= S_RX_IDLE;

            end if;


        when S_RX_WAIT2 =>

            tst_err <= '0';
            i_reg_wr <= '0';
            i_reg_rd <= '0';
            i_req_compl <= '0';
            i_req_compl_ur <= '0';

            i_m_axis_cq_tready <= '1';
            i_fsm_rx <= S_RX_IDLE;

    end case; --case i_fsm_rx is
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm



--#######################################################################
--DBG
--#######################################################################
tst_fsm_rx <= TO_UNSIGNED(16#01#,tst_fsm_rx'length) when i_fsm_rx = S_RX_WAIT       else
              TO_UNSIGNED(16#02#,tst_fsm_rx'length) when i_fsm_rx = S_RX_DATA    else
              TO_UNSIGNED(16#00#,tst_fsm_rx'length); --i_fsm_rx = S_RX_IDLE           else

p_out_tst(1 downto 0) <= std_logic_vector(tst_fsm_rx);
p_out_tst(31 downto 2) <= (others => '0');


end architecture behavioral;


