-------------------------------------------------------------------------
--Engineer    : Golovachenko Victor
--
--Create Date : 08.07.2015 13:35:52
--Module Name : pcie_tx.vhd
--
--Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_tx is
generic (
G_AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_CC_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK   : integer := 0;

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; --TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   --TPARITY width
);
port(
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tlast  : out std_logic;
p_out_s_axis_cc_tvalid : out std_logic;
p_out_s_axis_cc_tuser  : out std_logic_vector(32 downto 0);
p_in_s_axis_cc_tready  : in  std_logic;

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_rq_tlast  : out std_logic;
p_out_s_axis_rq_tvalid : out std_logic;
p_out_s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
p_in_s_axis_rq_tready  : in  std_logic;

--TX Message Interface
p_in_cfg_msg_transmit_done  : in  std_logic;
p_out_cfg_msg_transmit      : out std_logic;
p_out_cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

--Cfg Flow Control Information
p_in_cfg_fc_ph   : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_nph  : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_cplh : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_pd   : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_npd  : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_cpld : in  std_logic_vector(11 downto 0);
p_out_cfg_fc_sel : out std_logic_vector(2 downto 0);

--Completion
p_in_req_compl    : in  std_logic;
p_in_req_compl_ur : in  std_logic;
p_out_compl_done  : out std_logic;

p_in_req_type : in  std_logic_vector(3 downto 0);
p_in_req_tc   : in  std_logic_vector(2 downto 0);
p_in_req_td   : in  std_logic;
p_in_req_ep   : in  std_logic;
p_in_req_attr : in  std_logic_vector(1 downto 0);
p_in_req_len  : in  std_logic_vector(10 downto 0);
p_in_req_rid  : in  std_logic_vector(15 downto 0);
p_in_req_tag  : in  std_logic_vector(7 downto 0);
p_in_req_be   : in  std_logic_vector(7 downto 0);
p_in_req_addr : in  std_logic_vector(12 downto 0);
p_in_req_at   : in  std_logic_vector(1 downto 0);

p_in_completer_id : in  std_logic_vector(15 downto 0);

p_in_req_des_qword0      : in  std_logic_vector(63 downto 0);
p_in_req_des_qword1      : in  std_logic_vector(63 downto 0);
p_in_req_des_tph_present : in  std_logic;
p_in_req_des_tph_type    : in  std_logic_vector(1 downto 0);
p_in_req_des_tph_st_tag  : in  std_logic_vector(7 downto 0);

--usr app
p_in_ureg_do   : in  std_logic_vector(31 downto 0);

--DBG
p_out_tst : out std_logic_vector(69 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_tx;

architecture behavioral of pcie_tx is

type TFsmTx_state is (
S_TX_IDLE  ,
S_TX_CPL
);
signal i_fsm_tx              : TFsmTx_state;

signal i_s_axis_cc_tparity: std_logic_vector(31 downto 0) := (others => '0');

signal i_s_axis_cc_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
signal i_s_axis_cc_tkeep  : std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
signal i_s_axis_cc_tlast  : std_logic;
signal i_s_axis_cc_tvalid : std_logic;
signal i_s_axis_cc_tuser  : std_logic_vector(32 downto 0);

signal i_s_axis_rq_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
signal i_s_axis_rq_tkeep  : std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
signal i_s_axis_rq_tlast  : std_logic;
signal i_s_axis_rq_tvalid : std_logic;
signal i_s_axis_rq_tuser  : std_logic_vector(59 downto 0);

signal i_cfg_msg_transmit      : std_logic;
signal i_cfg_msg_transmit_type : std_logic_vector(2 downto 0);
signal i_cfg_msg_transmit_data : std_logic_vector(31 downto 0);

signal i_compl_done       : std_logic;

type TReq is record
pkt  : std_logic_vector(3 downto 0);
tc   : std_logic_vector(2 downto 0);
attr : std_logic_vector(2 downto 0);
len  : std_logic_vector(10 downto 0);
rid  : std_logic_vector(15 downto 0);
tag  : std_logic_vector(7 downto 0);
addr : std_logic_vector(12 downto 0);
at   : std_logic_vector(1 downto 0);
end record;

signal i_req              : TReq;

signal i_req_be           : std_logic_vector(7 downto 0);
--signal i_req_type         : std_logic_vector(3 downto 0);
--signal i_req_tc           : std_logic_vector(2 downto 0);
--signal i_req_attr         : std_logic_vector(2 downto 0);
--signal i_req_len          : std_logic_vector(10 downto 0);
--signal i_req_rid          : std_logic_vector(15 downto 0);
--signal i_req_tag          : std_logic_vector(7 downto 0);
--signal i_req_be           : std_logic_vector(7 downto 0);
--signal i_req_addr         : std_logic_vector(12 downto 0);
--signal i_req_at           : std_logic_vector(1 downto 0);
--
--signal i_req_td           : std_logic;
--signal i_req_ep           : std_logic;

--signal i_lower_addr_tmp     : std_logic_vector(6 downto 0);
signal i_lower_addr       : std_logic_vector(6 downto 0);

signal sr_req_compl       : std_logic_vector(0 to 1);

signal tst_fsm_tx         : unsigned(1 downto 0);



begin --architecture behavioral of pcie_tx

p_out_compl_done <= i_compl_done;

--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  <= i_s_axis_cc_tdata ;
p_out_s_axis_cc_tkeep  <= i_s_axis_cc_tkeep ;
p_out_s_axis_cc_tlast  <= i_s_axis_cc_tlast ;
p_out_s_axis_cc_tvalid <= i_s_axis_cc_tvalid;
p_out_s_axis_cc_tuser  <= i_s_axis_cc_tuser ;

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  <= i_s_axis_rq_tdata ;
p_out_s_axis_rq_tkeep  <= i_s_axis_rq_tkeep ;
p_out_s_axis_rq_tlast  <= i_s_axis_rq_tlast ;
p_out_s_axis_rq_tvalid <= i_s_axis_rq_tvalid;
p_out_s_axis_rq_tuser  <= i_s_axis_rq_tuser ;

--TX Message Interface
p_out_cfg_msg_transmit      <= '0';
p_out_cfg_msg_transmit_type <= (others => '0');
p_out_cfg_msg_transmit_data <= (others => '0');

p_out_cfg_fc_sel <= (others => '0');


i_req.attr <= p_in_req_des_qword1((32 * 1) + 30 downto (32 * 1) + 28);
i_req.tc   <= p_in_req_des_qword1((32 * 1) + 27 downto (32 * 1) + 25);
i_req.tag  <= p_in_req_des_qword1((32 * 1) +  7 downto (32 * 1) +  0);
i_req.rid  <= p_in_req_des_qword1((32 * 0) + 31 downto (32 * 0) + 16);
i_req.pkt  <= p_in_req_des_qword1((32 * 0) + 14 downto (32 * 0) + 11);
i_req.len  <= p_in_req_des_qword1((32 * 0) + 10 downto (32 * 0) +  0);
i_req.addr <= p_in_req_des_qword0((32 * 0) + 12 downto (32 * 0) +  2) & "00";
i_req.at   <= p_in_req_des_qword0((32 * 0) +  1 downto (32 * 0) +  0);


--Calculate lower address based on  byte enable
process (p_in_req_be, i_req.addr)
begin
  case p_in_req_be(3 downto 0) is
    when "0000" =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "00");
    when "0001" | "0011" | "0101" | "0111" | "1001" | "1011" | "1101" | "1111" =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "00");
    when "0010" | "0110" | "1010" | "1110" =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "01");
    when "0100" | "1100" =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "10");
    when "1000" =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "11");
    when others =>
      i_lower_addr <= (i_req.addr(6 downto 2) & "00");
  end case;
end process;

--i_lower_addr <= i_lower_addr_tmp when req_compl_wd_qqq = '1' else (others => '0');


--gen_cc_align_off : if strcmp(G_AXISTEN_IF_CC_ALIGNMENT_MODE, "FALSE") generate begin
--i_tkeep <= std_logic_vector(TO_UNSIGNED(16#01#, i_tkeep'length));
--end generate gen_cc_align_off;
--
--gen_cc_align_on : if strcmp(G_AXISTEN_IF_CC_ALIGNMENT_MODE, "TRUE") generate begin
--process (i_lower_addr)
--begin
--  case i_lower_addr(4 downto 2) is
--    when "000" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#01#, i_tkeep'length));
--    when "001" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#03#, i_tkeep'length));
--    when "010" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#07#, i_tkeep'length));
--    when "011" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#0F#, i_tkeep'length));
--    when "100" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#1F#, i_tkeep'length));
--    when "101" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#3F#, i_tkeep'length));
--    when "110" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#7F#, i_tkeep'length));
--    when "111" => i_tkeep <= std_logic_vector(TO_UNSIGNED(16#FF#, i_tkeep'length));
--    when others => null;
--  end case;
--end process;
--end generate gen_cc_align_on;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst_n = '0') then
    sr_req_compl <= (others => '0');
  else
    sr_req_compl <= p_in_req_compl & sr_req_compl(0 to 0);
  end if;
end if;
end process;



--Tx State Machine
fsm : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_tx <= S_TX_IDLE;

    i_s_axis_cc_tdata  <= (others => '0');
    i_s_axis_cc_tkeep  <= (others => '0');
    i_s_axis_cc_tlast  <= '0';
    i_s_axis_cc_tvalid <= '0';
    i_s_axis_cc_tuser  <= (others => '0');

    i_s_axis_rq_tdata  <= (others => '0');
    i_s_axis_rq_tkeep  <= (others => '0');
    i_s_axis_rq_tlast  <= '0';
    i_s_axis_rq_tvalid <= '0';
    i_s_axis_rq_tuser  <= (others => '0');

    i_cfg_msg_transmit      <= '0';
    i_cfg_msg_transmit_type <= (others => '0');
    i_cfg_msg_transmit_data <= (others => '0');

    i_compl_done <= '0';

  else

    case i_fsm_tx is
        --#######################################################################
        --
        --#######################################################################
        when S_TX_IDLE =>
            i_s_axis_cc_tdata  <= (others => '0');
            i_s_axis_cc_tkeep  <= (others => '0');
            i_s_axis_cc_tlast  <= '0';
            i_s_axis_cc_tvalid <= '0';
            i_s_axis_cc_tuser  <= (others => '0');

            i_s_axis_rq_tdata  <= (others => '0');
            i_s_axis_rq_tkeep  <= (others => '0');
            i_s_axis_rq_tlast  <= '0';
            i_s_axis_rq_tvalid <= '0';
            i_s_axis_rq_tuser  <= (others => '0');

            i_cfg_msg_transmit      <= '0';
            i_cfg_msg_transmit_type <= (others => '0');
            i_cfg_msg_transmit_data <= (others => '0');

            i_compl_done <= '0';

            if p_in_req_compl = '1' then
              i_fsm_tx <= S_TX_CPL;
            end if;


        --#######################################################################
        --
        --#######################################################################
        when S_TX_CPL =>

          if sr_req_compl(sr_req_compl'high) = '1' then

            i_s_axis_cc_tvalid <= '1';
            i_s_axis_cc_tlast  <= '1';

            if (i_req.pkt = C_PCIE3_PKT_TYPE_MEM_RD_ND)
                or (i_req.pkt = C_PCIE3_PKT_TYPE_MEM_LK_RD_ND)
                or (i_req.pkt = C_PCIE3_PKT_TYPE_IO_RD_ND) then

              i_s_axis_cc_tdata((32 * 4) - 1 downto (32 * 3)) <= p_in_ureg_do;
              i_s_axis_cc_tkeep <= std_logic_vector(TO_UNSIGNED(16#0F#, i_s_axis_cc_tkeep'length));

            else
              i_s_axis_cc_tdata((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
              i_s_axis_cc_tkeep <= std_logic_vector(TO_UNSIGNED(16#07#, i_s_axis_cc_tkeep'length));

            end if;

            i_s_axis_cc_tdata((32 * 2) + 31)                      <= '0';       -- Force ECRC
            i_s_axis_cc_tdata((32 * 2) + 30 downto (32 * 2) + 28) <= std_logic_vector(RESIZE(UNSIGNED(i_req.attr), 3));
            i_s_axis_cc_tdata((32 * 2) + 27 downto (32 * 2) + 25) <= i_req.tc;  --
            i_s_axis_cc_tdata((32 * 2) + 24)                      <= '0';       --Completer ID to control selection of Client Supplied Bus number
            i_s_axis_cc_tdata((32 * 2) + 23 downto (32 * 2) + 16) <= p_in_completer_id(15 downto 8); --Completer Bus number - selected if Compl ID = 1
            i_s_axis_cc_tdata((32 * 2) + 15 downto (32 * 2) +  8) <= p_in_completer_id(7 downto 0);  --Compl Dev / Func no - sel if Compl ID = 1
            i_s_axis_cc_tdata((32 * 2) +  7 downto (32 * 2) +  0) <= i_req.tag; --Matching Request Tag

            i_s_axis_cc_tdata((32 * 1) + 31 downto (32 * 1) + 16) <= i_req.rid; --Requester ID - 16 bits
            i_s_axis_cc_tdata((32 * 1) + 15)                      <= '0';       --Rsvd
            i_s_axis_cc_tdata((32 * 1) + 14)                      <= '0';       --Posioned completion
            i_s_axis_cc_tdata((32 * 1) + 13 downto (32 * 1) + 11) <= C_PCIE_COMPL_STATUS_SC; --Completion Status: SuccessFull completion

            if (i_req.pkt = C_PCIE3_PKT_TYPE_IO_RD_ND) or
               ((i_req.pkt = C_PCIE3_PKT_TYPE_MEM_RD_ND) and (i_req.len = (i_req.len'range => '0'))) then

              i_s_axis_cc_tdata((32 * 1) + 10 downto (32 * 1) + 0) <= std_logic_vector(TO_UNSIGNED(1, 11)); --DWord Count

            elsif (i_req.pkt = C_PCIE3_PKT_TYPE_IO_WR_D) then
              i_s_axis_cc_tdata((32 * 1) + 10 downto (32 * 1) + 0) <= (others => '0'); --DWord Count

            else
              i_s_axis_cc_tdata((32 * 1) + 10 downto (32 * 1) + 0) <= i_req.len; --DWord Count

            end if;

            i_s_axis_cc_tdata((32 * 0) + 31 downto (32 * 0) + 30) <= (others => '0');        --Rsvd
            i_s_axis_cc_tdata((32 * 0) + 29)                      <= '0';                    --Locked Read Completion
            i_s_axis_cc_tdata((32 * 0) + 28 downto (32 * 0) + 16) <= std_logic_vector(TO_UNSIGNED(4, 13)); --Byte Count
            i_s_axis_cc_tdata((32 * 0) + 15 downto (32 * 0) + 10) <= (others => '0');        --Rsvd
            i_s_axis_cc_tdata((32 * 0) +  9 downto (32 * 0) +  8) <= i_req.at;               --Adress Type - 2 bits
            i_s_axis_cc_tdata((32 * 0) +  7)                      <= '0';                    --Rsvd
            i_s_axis_cc_tdata((32 * 0) +  6 downto (32 * 0) +  0) <= (others => '0');        --Starting address of the mem byte - 7 bits

            if G_AXISTEN_IF_CC_PARITY_CHECK = 0 then
              i_s_axis_cc_tuser <= (others => '0');
            else
              i_s_axis_cc_tuser <= std_logic_vector(RESIZE(UNSIGNED(i_s_axis_cc_tparity), i_s_axis_cc_tuser'length));
            end if;

            if p_in_s_axis_cc_tready = '1' then
              i_compl_done <= '1';
              i_fsm_tx <= S_TX_IDLE;
            end if;

          end if;

    end case; --case i_fsm_tx is
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm


--#######################################################################
--DBG
--#######################################################################

p_out_tst(1 downto 0) <= (others => '0');
p_out_tst(69 downto 68) <= (others => '0');

end architecture behavioral;


