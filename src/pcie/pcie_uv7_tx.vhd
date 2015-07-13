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
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic;

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


--PIO RX Engine Interface
p_in_req_compl    : in  std_logic;
p_in_req_compl_wd : in  std_logic;
p_in_req_compl_ur : in  std_logic;
p_in_payload_len  : in  std_logic;
p_out_compl_done  : out std_logic;

p_in_req_tc   : in  std_logic_vector(2 downto 0);
p_in_req_td   : in  std_logic;
p_in_req_ep   : in  std_logic;
p_in_req_attr : in  std_logic_vector(1 downto 0);
p_in_req_len  : in  std_logic_vector(10:0] ,
p_in_req_rid  : in  std_logic_vector(15 downto 0);
p_in_req_tag  : in  std_logic_vector(7 downto 0);
p_in_req_be   : in  std_logic_vector(7 downto 0);
p_in_req_addr : in  std_logic_vector(12 downto 0);
p_in_req_at   : in  std_logic_vector(1 downto 0);

p_in_completer_id : in  std_logic_vector(15 downto 0);

--Inputs to the TX Block in case of an UR
--Required to form the completions
p_in_req_des_qword0      : in  std_logic_vector(63 downto 0);
p_in_req_des_qword1      : in  std_logic_vector(63 downto 0);
p_in_req_des_tph_present : in  std_logic;
p_in_req_des_tph_type    : in  std_logic_vector(1 downto 0);
p_in_req_des_tph_st_tag  : in  std_logic_vector(7 downto 0);

--Indicate that the Request was a Mem lock Read Req
p_in_req_mem_lock : in  std_logic;
p_in_req_mem      : in  std_logic;

--PIO Memory Access Control Interface
p_out_rd_addr  : out std_logic_vector(10 downto 0);
p_out_rd_be    : out std_logic_vector(3 downto 0);
p_out_trn_sent : out std_logic;
p_in_rd_data   : in  std_logic_vector(31 downto 0);
p_in_gen_transaction : in  std_logic

);
end entity pcie_tx;

architecture behavioral of pcie_tx is

type TFsmTx_state is (
S_TX_IDLE   ,
S_TX_PKT_CHK,
S_TX_RX_DATA,
S_TX_WAIT
);
signal i_fsm_tx              : TFsmTx_state;

signal i_lower_addr_tmp     : std_logic_vector(6 downto 0);
signal i_lower_addr         : std_logic_vector(6 downto 0);

signal sr_req_compl         : std_logic_vector(0 to 2);


begin --architecture behavioral of pcie_tx


--Present address and byte enable to memory module
process(p_in_clk)
begin
if (p_in_rst_n = '0') then
  i_rd_addr <= (others => '0');
  i_rd_be   <= (others => '0');
else
  if p_in_req_compl_wd = '1' then
    if i_dword_count = (i_dword_count'range => '0') then
      i_rd_addr <= UNSIGNED(p_in_req_addr(12 downto 0);
      i_rd_be   <= p_in_req_be(3 downto 0);
    end if;

  else
    i_rd_addr <= UNSIGNED(p_in_req_addr(12 downto 2)) + 1;
    i_rd_be   <= p_in_req_be(7 downto 4);

  end if;
end if;
end process;

--Calculate lower address based on  byte enable
process (i_rd_be, p_in_req_addr)
begin
  case i_rd_be(3 downto 0) is
    when "0000" =>
      i_lower_addr_tmp <= (p_in_req_addr(4 downto 0) & "00");
    when "0001" | "0011" | "0101" | "0111" | "1001" | "1011" | "1101" | "1111" =>
      i_lower_addr_tmp <= (req_addr_i(4 downto 0) & "00");
    when "0010" | "0110" | "1010" | "1110" =>
      i_lower_addr_tmp <= (p_in_req_addr(4 downto 0) & "01");
    when "0100" | "1100" =>
      i_lower_addr_tmp <= (p_in_req_addr(4 downto 0) & "10");
    when "1000" =>
      i_lower_addr_tmp <= (p_in_req_addr(4 downto 0) & "11");
    when others =>
      i_lower_addr_tmp <= (p_in_req_addr(4 downto 0) & "00");
  end case;
end process;

i_lower_addr <= i_lower_addr_tmp when req_compl_wd_qqq = '1' else (others => '0');


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
if (p_in_rst_n = '0') then
  sr_req_compl <= (others => '0');

else
  sr_req_compl <= p_in_req_compl & sr_req_compl(0 to 1);

  end if;
end if;
end process;




--Tx State Machine
fsm : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_tx <= S_RX_IDLE;

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

    i_compl_done  <= '0';
    i_dword_count <= '0';
    i_trn_sent    <= '0';

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

            i_compl_done  <= '0';
            i_dword_count <= '0';
            i_trn_sent    <= '0';

            if p_in_req_compl = '1' then
              i_fsm_tx <= S_RX_PKT_CHK;
            end if;


        --#######################################################################
        --
        --#######################################################################
        when S_TX_CPL =>
        --Completion Without Payload - Alignment doesnt matter

          if sr_req_compl(2) = '1' then
            i_s_axis_cc_tvalid <= '1';
            i_s_axis_cc_tlast  <= '0';
            i_s_axis_cc_tkeep  <= std_logic_vector(TO_UNSIGNED(3, i_s_axis_cc_tkeep'length));

            i_s_axis_cc_tdata(63 downto 48) <= p_in_req_rid;           --Requester ID - 16 bits
            i_s_axis_cc_tdata(47)           <= '0';                    --Rsvd
            i_s_axis_cc_tdata(46)           <= '0';                    --Posioned completion
            i_s_axis_cc_tdata(45 downto 43) <= C_PCIE_COMPL_STATUS_SC; --Completion Status: SuccessFull completion
            --must 1 for IO rd completion and 0 for IO wr completion.
            --1 while sending a completion for zero-length memory read
            --0 must when send a UR or CA completion
            i_s_axis_cc_tdata(42 downto 32) <= ????;                   --DWord Count 0 - IO Write completions

            i_s_axis_cc_tdata(31 downto 30) <= (others => '0');        --Rsvd
            i_s_axis_cc_tdata(29)           <= '0';                    --Locked Read Completion
            i_s_axis_cc_tdata(28 downto 16) <= std_logic_vector(TO_UNSIGNED(4, 13)); --Byte Count
            i_s_axis_cc_tdata(15 downto 10) <= (others => '0');        --Rsvd
            i_s_axis_cc_tdata(9 downto 8)   <= p_in_req_at;            --Adress Type - 2 bits
            i_s_axis_cc_tdata(7)            <= '0';                    --Rsvd
            i_s_axis_cc_tdata(6 downto 0)   <= lower_addr;             --Starting address of the mem byte - 7 bits


            if G_AXISTEN_IF_CC_PARITY_CHECK = 0 then
              i_s_axis_cc_tuser <= (others => '0');
            else
              i_s_axis_cc_tuser <= i_s_axis_cc_tparity;
            end if;
--            s_axis_cc_tuser   <= #TCQ {1'b0, (G_AXISTEN_IF_CC_PARITY_CHECK ? s_axis_cc_tparity : 32'b0)};

            if p_in_s_axis_cc_tready = '1' begin
              i_fsm_tx <= S_TX_CPL_2;
            end if;

          end if;

        when S_TX_CPL_2 =>

            i_s_axis_cc_tvalid <= '1';
            i_s_axis_cc_tlast  <= '1';
            i_s_axis_cc_tkeep  <= std_logic_vector(TO_UNSIGNED(1, i_s_axis_cc_tkeep'length));


            i_s_axis_cc_tdata(63 downto 32) <= (others => '0'); --

            i_s_axis_cc_tdata(31)           <= '0';           -- Force ECRC
            i_s_axis_cc_tdata(30 downto 28) <= std_logic_vector(RESIZE(UNSIGNED(p_in_req_attr), 3));
            i_s_axis_cc_tdata(27 downto 25) <= p_in_req_tc;   --
            i_s_axis_cc_tdata(24)           <= '0';           --Completer ID to control selection of Client Supplied Bus number
            i_s_axis_cc_tdata(23 downto 16) <= p_in_completer_id(16 downto 8); --Completer Bus number - selected if Compl ID    = 1
            i_s_axis_cc_tdata(15 downto 8)  <= p_in_completer_id(7 downto 0);  --Compl Dev / Func no - sel if Compl ID = 1
            i_s_axis_cc_tdata(7 downto 0)   <= p_in_req_tag;  --Matching Request Tag

            if G_AXISTEN_IF_CC_PARITY_CHECK = 0 then
              i_s_axis_cc_tuser <= (others => '0');
            else
              i_s_axis_cc_tuser <= i_s_axis_cc_tparity;
            end if;
--            s_axis_cc_tuser   <= #TCQ {1'b0, (G_AXISTEN_IF_CC_PARITY_CHECK ? s_axis_cc_tparity : 32'b0)};

            if p_in_s_axis_cc_tready = '1' begin
              i_fsm_tx <= S_TX_IDLE;
            end if;

          end if;

    end case; --case i_fsm_tx is
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm

end architecture behavioral;


