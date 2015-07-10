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
--AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
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
p_in_clk : in  std_logic;
p_in_rst_n  : in  std_logic;

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
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

-- Memory Read data handshake with Completion
-- transmit unit. Transmit unit reponds to
-- req_compl assertion and responds with compl_done
-- assertion when a Completion w/ data is transmitted.
p_out_req_compl    : out std_logic := '0';
p_out_req_compl_wd : out std_logic := '0';
p_out_req_compl_ur : out std_logic := '0';--Unsupported Request
p_in_compl_done    : in  std_logic;

p_out_req_tc       : out std_logic_vector(2 downto 0) ;-- Memory Read TC
p_out_req_attr     : out std_logic_vector(2 downto 0) ;-- Memory Read Attribute
p_out_req_len      : out std_logic_vector(10 downto 0);-- Memory Read Length
p_out_req_rid      : out std_logic_vector(15 downto 0);-- Memory Read Requestor ID { 8'b0 (Bus no),
                                                       --                            3'b0 (Dev no),
                                                       --                            5'b0 (Func no)}
p_out_req_tag      : out std_logic_vector(7 downto 0) ;-- Memory Read Tag
p_out_req_be       : out std_logic_vector(7 downto 0) ;-- Memory Read Byte Enables
p_out_req_addr     : out std_logic_vector(12 downto 0);-- Memory Read Address
p_out_req_at       : out std_logic_vector(1 downto 0) ;-- Address Translation

-- Outputs to the TX Block in case of an UR
-- Required to form the completions
p_out_req_des_qword0      : out std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
p_out_req_des_qword1      : out std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
p_out_req_des_tph_present : out std_logic;                    -- TPH Present in the request
p_out_req_des_tph_type    : out std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
p_out_req_des_tph_st_tag  : out std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

--Output to Indicate that the Request was a Mem lock Read Req
p_out_req_mem_lock : out std_logic;
p_out_req_mem      : out std_logic;

--Memory interface used to save 2 DW data received
--on Memory Write 32 TLP. Data extracted from
--inbound TLP is presented to the Endpoint memory
--unit. Endpoint memory unit reacts to wr_en
--assertion and asserts wr_busy when it is
--processing written information.
p_out_ureg_a   : out std_logic_vector(10 downto 0);
p_out_ureg_di  : out std_logic_vector(31 downto 0);
p_out_ureg_wrbe: out std_logic_vector(3 downto 0);
p_out_ureg_wr  : out std_logic;

p_out_payload_len : out std_logic;
p_in_wr_busy      : in  std_logic
);
end entity pcie_rx;

architecture behavioral of pcie_rx is

type TFsmRx_state is (
S_RX_IDLE   ,
S_RX_PKT_CHK,
S_RX_RX_DATA,
S_RX_WAIT
);
signal i_fsm_rx              : TFsmRx_state;

--signal i_in_pkt_q            : std_logic;
signal i_sop                 : std_logic;

signal i_m_axis_cq_tready    : std_logic := '0';
signal i_m_axis_rc_tready    : std_logic := '1';

signal i_req_tc              : std_logic_vector(2 downto 0) ;
signal i_req_attr            : std_logic_vector(2 downto 0) ;
signal i_req_len             : std_logic_vector(10 downto 0);
signal i_req_rid             : std_logic_vector(15 downto 0);
signal i_req_tag             : std_logic_vector(7 downto 0) ;
signal i_req_be              : std_logic_vector(7 downto 0) ;
signal i_req_addr            : std_logic_vector(12 downto 0);
signal i_req_at              : std_logic_vector(1 downto 0) ;

signal i_desc_hdr_qw0        : std_logic_vector(63 downto 0);
signal i_req_byte_enables    : std_logic_vector(7 downto 0);
signal i_first_be            : std_logic_vector(3 downto 0);
signal i_last_be             : std_logic_vector(3 downto 0);

signal i_req_des_qword0      : std_logic_vector(63 downto 0);
signal i_req_des_qword1      : std_logic_vector(63 downto 0);
signal i_req_des_tph_present : std_logic;
signal i_req_des_tph_type    : std_logic_vector(1 downto 0) ;
signal i_req_des_tph_st_tag  : std_logic_vector(7 downto 0) ;

signal i_req_msg_code         : std_logic_vector(7 downto 0);
signal i_req_msg_route        : std_logic_vector(2 downto 0);
signal i_req_snoop_latency    : std_logic_vector(15 downto 0);
signal i_req_no_snoop_latency : std_logic_vector(15 downto 0);
signal i_req_obff_code        : std_logic_vector(3 downto 0);
signal i_req_dst_id           : std_logic_vector(15 downto 0);
signal i_req_vend_id          : std_logic_vector(15 downto 0);
signal i_req_vend_hdr         : std_logic_vector(31 downto 0);
signal i_req_tl_hdr           : std_logic_vector(127 downto 0);

signal i_req_compl           : std_logic := '0';
signal i_req_compl_wd        : std_logic := '0';
signal i_req_compl_ur        : std_logic := '0';

signal i_trn_type            : std_logic_vector(3 downto 0);
--signal i_pload_byte_en       : std_logic_vector((32 / 8) - 1 downto 0);

signal i_req_mem             : std_logic;
signal i_req_mem_lock        : std_logic;

signal i_data_start_loc      : std_logic_vector(2 downto 0);

signal i_reg_a               : std_logic_vector(10 downto 0);
signal i_reg_d               : std_logic_vector(31 downto 0);
signal i_reg_wrbe            : std_logic_vector(3 downto 0);
signal i_reg_wr              : std_logic;


begin --architecture behavioral of pcie_rx

p_out_req_mem_lock <= i_req_mem_lock;
p_out_req_mem      <= i_req_mem;


p_out_ureg_a <= i_reg_a;
p_out_ureg_wr <= i_reg_wr;

p_out_ureg_wrbe <= i_reg_wrbe;
p_out_ureg_di <= i_reg_d;

p_out_payload_len <= '0';

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

p_out_req_compl    <= i_req_compl   ;
p_out_req_compl_wd <= i_req_compl_wd;
p_out_req_compl_ur <= i_req_compl_ur;

p_out_pcie_cq_np_req <= '1';

p_out_m_axis_cq_tready <= i_m_axis_cq_tready;
p_out_m_axis_rc_tready <= i_m_axis_rc_tready;

--gen_pload_byte_en : for i in 0 to i_pload_byte_en'length - 1 generate begin
--i_pload_byte_en(i) <= p_in_m_axis_cq_tuser(8 + (4 * i)) ;
--end generate gen_pload_byte_en;

----Generate a signal that indicates if we are currently receiving a packet.
----This value is one clock cycle delayed from what is actually on the AXIS data bus.
--detect_pkt : process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--  if (p_in_rst_n = '0') then
--    i_in_pkt_q <= '0';
--
--  elsif (p_in_m_axis_cq_tvalid = '1'
--        and i_m_axis_cq_tready = '1'
--     and p_in_m_axis_cq_tlast = '1') then
--
--    i_in_pkt_q <= '0';
--
--  elsif (i_sop = '1' and i_m_axis_cq_tready = '1') then
--    i_in_pkt_q <= '1';
--  end if;
--end if;
--end process detect_pkt;

i_sop <= p_in_m_axis_cq_tuser(40);--not i_in_pkt_q and p_in_m_axis_cq_tvalid; --


--Rx State Machine
fsm : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_rx <= S_RX_IDLE;

    i_m_axis_cq_tready <= '0';
    i_m_axis_rc_tready <= '1';

    i_desc_hdr_qw0     <= (others => '0');
    i_first_be         <= (others => '0');
    i_last_be          <= (others => '0');

    i_req_des_qword0      <= (others => '0');
    i_req_des_qword1      <= (others => '0');
    i_req_des_tph_present <= '0';
    i_req_des_tph_type    <= (others => '0');
    i_req_des_tph_st_tag  <= (others => '0');

    i_req_compl    <= '0';
    i_req_compl_wd <= '0';
    i_req_compl_ur <= '0';

    i_req_len  <= (others => '0');
    i_req_tc   <= (others => '0');
    i_req_attr <= (others => '0');
    i_req_rid  <= (others => '0');
    i_req_tag  <= (others => '0');
    i_req_be   <= (others => '0');
    i_req_addr <= (others => '0');
    i_req_at   <= (others => '0');

    i_trn_type <= (others => '0');

    i_req_mem <= '0';
    i_req_mem_lock <= '0';

    i_data_start_loc <= (others => '0');

    i_reg_a <= (others => '0');
    i_reg_d <= (others => '0');
    i_reg_wrbe <= (others => '0');
    i_reg_wr   <= '0';

  else

    case i_fsm_rx is
        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RX_IDLE =>
            i_m_axis_cq_tready <= '1';
            i_m_axis_rc_tready <= '1';

            if i_sop = '1' then
              i_desc_hdr_qw0 <= p_in_m_axis_cq_tdata(63 downto 0);
              i_first_be <= p_in_m_axis_cq_tuser(3 downto 0);
              i_last_be  <= p_in_m_axis_cq_tuser(7 downto 4);

              i_fsm_rx <= S_RX_PKT_CHK;
            end if;

        --#######################################################################
        --Check paket type
        --#######################################################################
        when S_RX_PKT_CHK =>

            if p_in_m_axis_cq_tvalid = '1' then

                --Req Type
                case p_in_m_axis_cq_tdata(14 downto 11) is
                    -------------------------------------------------------------------------
                    --
                    -------------------------------------------------------------------------
                    when C_PCIE3_PKT_TYPE_MEM_RD_ND
                        | C_PCIE3_PKT_TYPE_MEM_LK_RD_ND
                        | C_PCIE3_PKT_TYPE_MEM_WR_D
                        | C_PCIE3_PKT_TYPE_IO_RD_ND
                        | C_PCIE3_PKT_TYPE_IO_WR_D
                        | C_PCIE3_PKT_TYPE_ATOP_FAA
                        | C_PCIE3_PKT_TYPE_ATOP_UCS
                        | C_PCIE3_PKT_TYPE_ATOP_CAS =>

                      i_m_axis_cq_tready <= '0';

                      i_req_des_qword0      <= i_desc_hdr_qw0(63 downto 0);
                      i_req_des_qword1      <= p_in_m_axis_cq_tdata(63 downto 0);
                      i_req_des_tph_present <= p_in_m_axis_cq_tuser(42);
                      i_req_des_tph_type    <= p_in_m_axis_cq_tuser(44 downto 43);
                      i_req_des_tph_st_tag  <= p_in_m_axis_cq_tuser(52 downto 45);

                      i_trn_type <= p_in_m_axis_cq_tdata(14 downto 11);
                      i_req_len  <= p_in_m_axis_cq_tdata(10 downto 0); --Length data payload (DW)

                      --Check length data payload (DW)
                      if UNSIGNED(p_in_m_axis_cq_tdata(10 downto 0)) = TO_UNSIGNED(16#01#, 11) then

                          i_req_tc   <= p_in_m_axis_cq_tdata(59 downto 57);
                          i_req_attr <= p_in_m_axis_cq_tdata(62 downto 60);
                          i_req_rid  <= p_in_m_axis_cq_tdata(31 downto 16);
                          i_req_tag  <= p_in_m_axis_cq_tdata(39 downto 32);
                          i_req_be   <= i_last_be & i_first_be;
                          i_req_addr <= i_desc_hdr_qw0(12 downto 2) & "00";--??????
                          i_req_at   <= i_desc_hdr_qw0(1 downto 0);

                          if (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MEM_RD_ND) then
                            i_req_mem <= '1';
                          else
                            i_req_mem <= '0';
                          end if;

                          if (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then
                            i_req_mem_lock <= '1';
                          else
                            i_req_mem_lock <= '0';
                          end if;

                          if (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MEM_WR_D) then
                            if strcmp(G_AXISTEN_IF_CQ_ALIGNMENT_MODE, "TRUE") then
                              i_data_start_loc <= std_logic_vector(RESIZE(UNSIGNED(i_desc_hdr_qw0(2 downto 2)), i_data_start_loc'length));

                            else
                              i_data_start_loc <= (others => '0');

                            end if;

                          elsif (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_IO_WR_D) then
                            if strcmp(G_AXISTEN_IF_CQ_ALIGNMENT_MODE, "TRUE") then
                              i_data_start_loc <= std_logic_vector(RESIZE(UNSIGNED(i_desc_hdr_qw0(2 downto 2)), i_data_start_loc'length));

                            else
                              i_data_start_loc <= (others => '0');

                            end if;
                          end if;

                          --Compl
                          if (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_IO_WR_D)
                            or (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_ATOP_FAA)
                            or (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_ATOP_UCS)
                            or (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_ATOP_CAS) then

                              i_req_compl    <= '1';
                              i_req_compl_wd <= '0';

                              if (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_IO_WR_D) then
                                i_fsm_rx <= S_RX_RX_DATA;
                              else
                                i_fsm_rx <= S_RX_WAIT;
                              end if;

                          --ComplD
                          elsif (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_IO_RD_ND)
                            or (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                            or (p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND) then

                              i_req_compl    <= '0';
                              i_req_compl_wd <= '1';

                              i_fsm_rx <= S_RX_WAIT;

                          else
                              i_req_compl    <= '0';
                              i_req_compl_wd <= '0';

                              i_fsm_rx <= S_RX_RX_DATA;

                          end if;--Check length data payload (DW)

                      else
                        i_req_compl    <= '0';
                        i_req_compl_wd <= '0';
                        i_req_compl_ur <= '1';--Unsupported Request

                        i_fsm_rx <= S_RX_WAIT;
                      end if;

                    -------------------------------------------------------------------------
                    --
                    -------------------------------------------------------------------------
                    when C_PCIE3_PKT_TYPE_MSG
                        | C_PCIE3_PKT_TYPE_MSG_VD
                        | C_PCIE3_PKT_TYPE_MSG_ATS =>

                        i_m_axis_cq_tready <= '0';

                        i_trn_type <= p_in_m_axis_cq_tdata(14 downto 11);
                        i_req_len  <= p_in_m_axis_cq_tdata(10 downto 0);

                        i_req_tc        <= p_in_m_axis_cq_tdata(59 downto 57);
                        i_req_attr      <= p_in_m_axis_cq_tdata(62 downto 60);
                        i_req_rid       <= p_in_m_axis_cq_tdata(31 downto 16);
                        i_req_tag       <= p_in_m_axis_cq_tdata(39 downto 32);
                        i_req_msg_code  <= p_in_m_axis_cq_tdata(47 downto 40);
                        i_req_msg_route <= p_in_m_axis_cq_tdata(50 downto 48);
                        i_req_be        <= i_last_be & i_first_be;
                        i_req_at        <= i_desc_hdr_qw0(1 downto 0);

                        if p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MSG then
                          i_req_snoop_latency    <= i_desc_hdr_qw0(15 downto 0);
                          i_req_no_snoop_latency <= i_desc_hdr_qw0(31 downto 16);
                          i_req_obff_code        <= i_desc_hdr_qw0(35 downto 32);

                        elsif p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MSG_VD then
                          i_req_dst_id    <= i_desc_hdr_qw0(15 downto 0);
                          i_req_vend_id   <= i_desc_hdr_qw0(31 downto 16);
                          i_req_vend_hdr  <= i_desc_hdr_qw0(63 downto 32);

                        else --if p_in_m_axis_cq_tdata(14 downto 11) = C_PCIE3_PKT_TYPE_MSG_ATS then
                          i_req_tl_hdr(127 downto 64) <= i_desc_hdr_qw0(63 downto 0);

                        end if;

                        i_fsm_rx <= S_RX_IDLE;

                    -------------------------------------------------------------------------
                    --
                    -------------------------------------------------------------------------
                     when others =>
                        i_fsm_rx <= S_RX_PKT_CHK;

                end case; --case p_in_m_axis_cq_tdata(14 downto 11) is
            end if; --if p_in_m_axis_cq_tvalid = '1' then
        --end S_RX_PKT_CHK :


        --#######################################################################
        --
        --#######################################################################
        when S_RX_RX_DATA =>

            if p_in_m_axis_cq_tvalid = '1' then

                i_reg_a <= i_req_addr(12 downto 2);

                case i_data_start_loc is
                  when "000" =>

                      i_m_axis_cq_tready <= '0';

                      i_reg_wr <= '1';
                      i_reg_d <= p_in_m_axis_cq_tdata(31 downto 0);
                      i_reg_wrbe <= p_in_m_axis_cq_tuser(11 downto 8);


                      i_fsm_rx <= S_RX_WAIT;

                  when "001" =>

                      i_m_axis_cq_tready <= '0';

                      i_reg_wr <= '1';
                      i_reg_d <= p_in_m_axis_cq_tdata(63 downto 32);
                      i_reg_wrbe <= p_in_m_axis_cq_tuser(15 downto 12);

                      i_fsm_rx <= S_RX_WAIT;

                  when others =>
                    i_fsm_rx <= S_RX_RX_DATA;

                end case;--case data_start_loc is

            end if; --if p_in_m_axis_cq_tvalid = '1' then


        --#######################################################################
        --
        --#######################################################################
        when S_RX_WAIT =>

            i_req_mem <= '0';
            i_req_mem_lock <= '0';

            i_reg_wr <= '0';
            i_req_compl    <= '0';
            i_req_compl_wd <= '0';

            if (i_trn_type = C_PCIE3_PKT_TYPE_MEM_WR_D) then

              i_m_axis_cq_tready <= '1';
              i_fsm_rx <= S_RX_IDLE;

            elsif p_in_compl_done = '1' then

              i_m_axis_cq_tready <= '1';
              i_fsm_rx <= S_RX_IDLE;

            end if;

    end case; --case i_fsm_rx is
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm

end architecture behavioral;


