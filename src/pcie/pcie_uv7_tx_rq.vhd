-------------------------------------------------------------------------
--Engineer    : Golovachenko Victor
--
--Create Date : 23.07.2015 11:21:07
--Module Name : pcie_tx_rq.vhd
--
--Description : Requester Request
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_tx_rq is
generic (
G_AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; --TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   --TPARITY width
);
port(
--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_rq_tlast  : out std_logic;
p_out_s_axis_rq_tvalid : out std_logic;
p_out_s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
p_in_s_axis_rq_tready  : in  std_logic;

----TX Message Interface
--p_in_cfg_msg_transmit_done  : in  std_logic;
--p_out_cfg_msg_transmit      : out std_logic;
--p_out_cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
--p_out_cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

----Completion
--p_in_req_compl    : in  std_logic;
--p_in_req_compl_ur : in  std_logic;
--p_out_compl_done  : out std_logic;
--
--p_in_req_prm      : in TPCIE_reqprm;

p_in_completer_id : in  std_logic_vector(15 downto 0);

----usr app
--p_in_ureg_do   : in  std_logic_vector(31 downto 0);

p_in_pcie_prm    : in  TPCIE_cfgprm;

p_in_dma_init    : in  std_logic;
p_in_dma_prm     : in  TPCIE_dmaprm;


--DBG
p_out_tst : out std_logic_vector(279 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_tx_rq;

architecture behavioral of pcie_tx_rq is

type TFsmTxRq_state is (
S_TXRQ_IDLE  ,
S_TXRQ_CPL
);
signal i_fsm_txrq              : TFsmTxRq_state;

--signal i_s_axis_rq_tparity: std_logic_vector(31 downto 0) := (others => '0');

signal i_s_axis_rq_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
signal i_s_axis_rq_tkeep  : std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
signal i_s_axis_rq_tlast  : std_logic;
signal i_s_axis_rq_tvalid : std_logic;
signal i_s_axis_rq_tuser  : std_logic_vector(59 downto 0);

--signal i_cfg_msg_transmit      : std_logic;
--signal i_cfg_msg_transmit_type : std_logic_vector(2 downto 0);
--signal i_cfg_msg_transmit_data : std_logic_vector(31 downto 0);

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

--signal i_lower_addr_tmp     : std_logic_vector(6 downto 0);
signal i_lower_addr       : std_logic_vector(6 downto 0);

signal sr_req_compl       : std_logic_vector(0 to 1);

signal tst_fsm_tx         : std_logic;



begin --architecture behavioral of pcie_tx_rq

p_out_compl_done <= i_compl_done;

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  <= (others => '0');--i_s_axis_rq_tdata ;
p_out_s_axis_rq_tkeep  <= (others => '0');--i_s_axis_rq_tkeep ;
p_out_s_axis_rq_tlast  <= '0';--i_s_axis_rq_tlast ;
p_out_s_axis_rq_tvalid <= '0';--i_s_axis_rq_tvalid;
p_out_s_axis_rq_tuser  <= (others => '0');--i_s_axis_rq_tuser ;

----TX Message Interface
--p_out_cfg_msg_transmit      <= '0';
--p_out_cfg_msg_transmit_type <= (others => '0');
--p_out_cfg_msg_transmit_data <= (others => '0');

p_out_cfg_fc_sel <= (others => '0');

i_req.attr <= p_in_req_prm.desc(3)(30 downto 28);
i_req.tc   <= p_in_req_prm.desc(3)(27 downto 25);
i_req.tag  <= p_in_req_prm.desc(3)( 7 downto  0);
i_req.rid  <= p_in_req_prm.desc(2)(31 downto 16);
i_req.pkt  <= p_in_req_prm.desc(2)(14 downto 11);
i_req.len  <= p_in_req_prm.desc(2)(10 downto  0);
i_req.addr <= p_in_req_prm.desc(0)(12 downto  2) & "00";
i_req.at   <= p_in_req_prm.desc(0)( 1 downto  0);

i_req_be  <= p_in_req_prm.last_be & p_in_req_prm.first_be;

--Calculate lower address based on  byte enable
process (i_req_be, i_req.addr)
begin
  case i_req_be(3 downto 0) is
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

--DMA initialization
init : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then
    i_dma_init <= '0';

  else
    if p_in_dma_init = '1' then
        i_dma_init <= '1';
    else
        if (i_fsm_txrq = S_TX_MWR_QW00) or (i_fsm_txrq = S_TX_MRD_QW00) then
          i_dma_init <= '0';
        end if;
    end if;
  end if;
end if;
end process;--init



--Tx State Machine
fsm : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_txrq <= S_TXRQ_IDLE;

    i_s_axis_rq_tdata  <= (others => '0');
    i_s_axis_rq_tkeep  <= (others => '0');
    i_s_axis_rq_tlast  <= '0';
    i_s_axis_rq_tvalid <= '0';
    i_s_axis_rq_tuser  <= (others => '0');

    i_compl_done <= '0';

  else

    case i_fsm_txrq is
        --#######################################################################
        --
        --#######################################################################
        when S_TXRQ_IDLE =>
            i_s_axis_rq_tdata  <= (others => '0');
            i_s_axis_rq_tkeep  <= (others => '0');
            i_s_axis_rq_tlast  <= '0';
            i_s_axis_rq_tvalid <= '0';
            i_s_axis_rq_tuser  <= (others => '0');

            i_compl_done <= '0';

            if i_dma_init = '1' then
              i_fsm_txrq <= S_TXRQ_CPL;
            end if;

        when S_TXRQ_MWR_0 =>

            if i_dma_init = '1' then

              case p_in_pcie_prm.max_payload is
              when C_PCIE_MAX_PAYLOAD_4096_BYTE => i_mwr_tpl_max_byte <= TO_UNSIGNED(4096, i_mwr_tpl_max_byte'length);
              when C_PCIE_MAX_PAYLOAD_2048_BYTE => i_mwr_tpl_max_byte <= TO_UNSIGNED(2048, i_mwr_tpl_max_byte'length);
              when C_PCIE_MAX_PAYLOAD_1024_BYTE => i_mwr_tpl_max_byte <= TO_UNSIGNED(1024, i_mwr_tpl_max_byte'length);
              when C_PCIE_MAX_PAYLOAD_512_BYTE  => i_mwr_tpl_max_byte <= TO_UNSIGNED(512, i_mwr_tpl_max_byte'length);
              when C_PCIE_MAX_PAYLOAD_256_BYTE  => i_mwr_tpl_max_byte <= TO_UNSIGNED(256, i_mwr_tpl_max_byte'length);
              when C_PCIE_MAX_PAYLOAD_128_BYTE  => i_mwr_tpl_max_byte <= TO_UNSIGNED(128, i_mwr_tpl_max_byte'length);
              when others => null;
              end case;

              i_mem_adr_byte <= UNSIGNED(p_in_dma_prm.addr);
              i_mem_remain_byte <= UNSIGNED(p_in_dma_prm.len);

            else
              i_mem_remain_byte <= UNSIGNED(p_in_dma_prm.len) - i_mem_tx_byte;
            end if;

            i_fsm_txrq <= S_TXRQ_MWR_QW00;

        --#######################################################################
        --MWr , +data (PC<-FPGA) FPGA is PCIe master
        --#######################################################################
        when S_TXRQ_MWR_QW00 =>

          if i_mem_remain_byte > RESIZE(i_mwr_tpl_max_byte, i_mem_remain_byte'length) then
              i_mem_tpl_last <= '0';
              i_mem_tpl_byte <= i_mwr_tpl_max_byte;
              i_mem_tpl_dw <= RESIZE(i_mwr_tpl_max_byte(i_mem_tpl_dw'high downto log2(32 / 8)), i_mem_tpl_dw'length);

              i_mem_tpl_len <= RESIZE(i_mwr_tpl_max_byte(i_mem_tpl_len'high downto log2(G_DATA_WIDTH / 8)), i_mem_tpl_len'length);
          else
              i_mem_tpl_last <= '1';
              i_mem_tpl_byte <= i_mem_remain_byte(i_mem_tpl_byte'range);
              i_mem_tpl_dw <= RESIZE(i_mem_remain_byte(i_mem_tpl_dw'high downto log2(32 / 8)), i_mem_tpl_dw'length)
                              + (TO_UNSIGNED(0, i_mem_tpl_dw'length - (log2(32 / 8)))
                                  & OR_reduce(i_mem_remain_byte(log2(32 / 8) - 1 downto 0)));

              i_mem_tpl_len <= RESIZE(i_mem_remain_byte(i_mem_tpl_len'high downto log2(G_DATA_WIDTH / 8)), i_mem_tpl_len'length)
                              + (TO_UNSIGNED(0, i_mem_tpl_len'length - (log2(G_DATA_WIDTH / 8)))
                                  & OR_reduce(i_mem_remain_byte(log2(G_DATA_WIDTH / 8) - 1 downto 0)));
          end if;

          i_fsm_txrq <= S_TXRQ_MWR_QW01;
        --end S_TXRQ_MWR_QW00 :

        when S_TXRQ_MWR_QW01 =>

          i_mwr_work <= '1';

          i_fsm_txrq <= S_TXRQ_MWR_QW0;

        when S_TXRQ_MWR_QW0 =>

            if i_usr_rxbuf_rd = '1' then
--i_s_axis_rq_tuser  : std_logic_vector(59 downto 0);

--                i_s_axis_rq_tkeep  : std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
--                i_s_axis_rq_tlast  : std_logic;

                i_s_axis_rq_tvalid <= '1';

                i_s_axis_rq_tdata((32 * 2) - 1 downto (32 * 0)) <= std_logic_vector(RESIZE(i_mem_adr_byte(31 downto 2), (32 * 2)) & "00");

                i_s_axis_rq_tdata((32 * 2) + 10 downto (32 * 2) +  0) <= std_logic_vector(i_mem_tpl_dw(10 downto 0)); --DW count
                i_s_axis_rq_tdata((32 * 2) + 14 downto (32 * 2) + 11) <= std_logic_vector(TO_UNSIGNED(C_PCIE3_PKT_TYPE_MEM_WR_D, 4)); --Req Type
                i_s_axis_rq_tdata((32 * 2) + 15) <= '0'; --Poisoned Request
                i_s_axis_rq_tdata((32 * 2) + 31 downto (32 * 2) + 16) <= (others => '0'); --Req ID

                i_s_axis_rq_tdata((32 * 3) +  7 downto (32 * 3) +  0) <= std_logic_vector(i_mem_tpl_tag(7 downto 0)); --Tag
                i_s_axis_rq_tdata((32 * 3) + 23 downto (32 * 3) +  8) <= p_in_completer_id; --Completer ID
                i_s_axis_rq_tdata((32 * 3) + 24) <= '0; --Requester ID Enable
                i_s_axis_rq_tdata((32 * 3) + 27 downto (32 * 3) + 25) <= (others => '0');--Transaction Class (TC)
                i_s_axis_rq_tdata((32 * 3) + 28) <= '0'; --Attr (No Snoop)
                i_s_axis_rq_tdata((32 * 3) + 29) <= '0'; --Attr (Relaxed Ordering)
                i_s_axis_rq_tdata((32 * 3) + 30) <= '0'; --Attr (ID-Based Ordering)
                i_s_axis_rq_tdata((32 * 3) + 31) <= '0'; --Force ECRC

                i_s_axis_rq_tkeep(3 downto 0) <= "1111";

                i_s_axis_rq_tuser(3 downto 0) <= ;--First_be;
                i_s_axis_rq_tuser(7 downto 4) <= ;--Last_be;
                i_s_axis_rq_tuser(10 downto 8) <= ;--Last_be;
                i_s_axis_rq_tuser(11) <= '0';--Discontinue;

                i_s_axis_rq_tuser(12) <= '0';--TPH_present;
                i_s_axis_rq_tuser(14 downto 13) <= (others => '0');--TPH_type;
                i_s_axis_rq_tuser(15) <= '0';--TPH_indirect_tag_en;
                i_s_axis_rq_tuser(23 downto 16) <= (others => '0');--TPH_st_tag;

                i_s_axis_rq_tuser(27 downto 24) <= (others => '0');--seq_num[3:0];

                i_s_axis_rq_tuser(59 downto 28) <= (others => '0');--parity[31:0];



                i_mem_adr_byte <= i_mem_adr_byte + RESIZE(i_mem_tpl_byte, i_mem_adr_byte'length);

--                i_trn_td(63 downto 32) <= std_logic_vector(i_mem_adr_byte(31 downto 2) & "00");
--                if G_USR_DBUS = 128 then
--                i_trn_td(31 downto 0)  <= std_logic_vector(i_usr_rxbuf_do_swap(32*4 - 1 downto 32*3));
--                else --if G_USR_DBUS = 32 then
--                i_trn_td(31 downto 0)  <= std_logic_vector(i_usr_rxbuf_do_swap(32*1 - 1 downto 32*0));
--                end if;
--
--                sr_usr_rxbuf_do_swap(32*3 - 1 downto 32*0) <= i_usr_rxbuf_do_swap(32*3 - 1 downto 32*0);

                --Counter send data (current transaction)
                if i_mem_tpl_cnt = (i_mem_tpl_len - 1) then

                    i_mwr_work <= '0';

                    if i_mem_tpl_dw = TO_UNSIGNED(16#01#, i_mem_tpl_dw'length) then
                      i_mem_tpl_cnt <= (others => '0');

                      if i_mem_tpl_last = '1' then
                        i_mem_tx_byte <= (others => '0');
                        i_mem_tpl_tag <= (others => '0');
                        i_mwr_done <= '1';
                      end if;

                      i_trn_teof_n <= '0';

                      i_fsm_cs <= S_TX_IDLE;

                    else

                      i_mem_tpl_dw_rem <= i_mem_tpl_dw_rem + 1;

                      i_fsm_cs <= S_TX_MWR_QWN2;

                    end if;

                else --if i_mem_tpl_cnt /= (i_mem_tpl_len - 1) then

                    i_mem_tpl_cnt <= i_mem_tpl_cnt + 1;

                    i_mem_tpl_tag <= i_mem_tpl_tag + 1;

                    i_trn_teof_n <= '1';

                    i_fsm_cs <= S_TX_MWR_QWN;

                end if;

            end if;
        --end S_TXRQ_MWR_QW0 :


    end case; --case i_fsm_txrq is
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm


--#######################################################################
--DBG
--#######################################################################
tst_fsm_tx <= '1' when i_fsm_txrq = S_TXRQ_CPL  else '0';

p_out_tst(0) <= tst_fsm_tx;
p_out_tst(3 downto 1) <= (others => '0');
p_out_tst(7 downto 4) <= (others => '0');

p_out_tst(8) <= i_s_axis_rq_tvalid;
p_out_tst(9) <= i_s_axis_rq_tlast;
p_out_tst(10) <= p_in_s_axis_rq_tready;
p_out_tst(266 downto 11)  <= std_logic_vector(RESIZE(UNSIGNED(i_s_axis_rq_tdata), 256));
p_out_tst(274 downto 267) <= std_logic_vector(RESIZE(UNSIGNED(i_s_axis_rq_tkeep), 8));
p_out_tst(279 downto 275) <= (others => '0');

end architecture behavioral;


