-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 10.08.2015 11:34:32
-- Module Name : kcu105_main_unit_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.prj_def.all;
use work.clocks_pkg.all;
use work.pcie_pkg.all;
use work.mem_wr_pkg.all;
use work.mem_ctrl_pkg.all;
use work.fg_pkg.all;

package kcu105_main_unit_pkg is

component fpga_test_01 is
generic(
G_BLINK_T05 : integer:=10#125#; -- 1/2 периода мигания светодиода.(время в ms)
G_CLK_T05us : integer:=10#1000# -- кол-во периодов частоты порта p_in_clk
                                -- укладывающиеся в 1/2 периода 1us
);
port
(
p_out_test_led : out   std_logic;
p_out_test_done: out   std_logic;

p_out_1us      : out   std_logic;
p_out_1ms      : out   std_logic;
p_out_1s       : out   std_logic;
-------------------------------
--System
-------------------------------
p_in_clken     : in    std_logic;
p_in_clk       : in    std_logic;
p_in_rst       : in    std_logic
);
end component fpga_test_01;

component clocks
port(
p_out_rst  : out   std_logic;
p_out_gclk : out   std_logic_vector(7 downto 0);

p_in_clkopt: in    std_logic_vector(3 downto 0);
p_in_clk   : in    TRefClkPinIN
);
end component clocks;

component pcie_main is
generic(
G_SIM : string := "OFF";
G_DBGCS : string := "OFF"
);
port(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk       : out   std_logic ;
p_out_gctrl      : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

p_out_dev_ctrl   : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din    : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout    : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr     : out   std_logic;
p_out_dev_rd     : out   std_logic;
p_in_dev_status  : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto C_HREG_DEV_STATUS_FST_BIT);
p_in_dev_irq     : in    std_logic_vector((C_HIRQ_COUNT - 1) downto C_HIRQ_FST_BIT);
p_in_dev_opt     : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto C_HDEV_OPTIN_FST_BIT);
p_out_dev_opt    : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto C_HDEV_OPTOUT_FST_BIT);

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst    : out   std_logic_vector(127 downto 0);
p_in_usr_tst     : in    std_logic_vector(127 downto 0);
p_in_tst         : in    std_logic_vector(31 downto 0);
p_out_tst        : out   std_logic_vector(255 downto 0);
p_out_dbg        : out   TPCIE_dbg;

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy    : in    TPCIE_pinin;
p_out_pcie_phy   : out   TPCIE_pinout;
p_out_pcie_rst_n : out   std_logic
);
end component pcie_main;

component pcie2mem_ctrl
generic(
G_MEM_AWIDTH     : integer := 32;
G_MEM_DWIDTH     : integer := 32;
G_MEM_BANK_M_BIT : integer := 29;
G_MEM_BANK_L_BIT : integer := 28;
G_DBG            : string := "OFF"
);
port(
-------------------------------
--CTRL
-------------------------------
p_in_ctrl         : in    TPce2Mem_Ctrl;
p_out_status      : out   TPce2Mem_Status;

--host -> dev
p_in_htxbuf_di    : in   std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_in_htxbuf_wr    : in   std_logic;
p_out_htxbuf_full : out  std_logic;
p_out_htxbuf_empty: out  std_logic;

--host <- dev
p_out_hrxbuf_do   : out  std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_in_hrxbuf_rd    : in   std_logic;
p_out_hrxbuf_full : out  std_logic;
p_out_hrxbuf_empty: out  std_logic;

p_in_hclk         : in    std_logic;

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem         : out   TMemIN;
p_in_mem          : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst          : in    std_logic_vector(31 downto 0);
p_out_tst         : out   std_logic_vector(63 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk          : in    std_logic;
p_in_rst          : in    std_logic
);
end component pcie2mem_ctrl;


component fg is
generic(
G_VSYN_ACTIVE : std_logic := '1';
G_DBGCS  : string := "OFF";
G_MEM_AWIDTH : integer := 32;
G_MEMWR_DWIDTH : integer := 32;
G_MEMRD_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk      : in   std_logic;

p_in_cfg_adr      : in   std_logic_vector(3 downto 0);
p_in_cfg_adr_ld   : in   std_logic;

p_in_cfg_txdata   : in   std_logic_vector(15 downto 0);
p_in_cfg_wr       : in   std_logic;

p_out_cfg_rxdata  : out  std_logic_vector(15 downto 0);
p_in_cfg_rd       : in   std_logic;

-------------------------------
--HOST
-------------------------------
p_in_hrdchsel     : in    std_logic_vector(2 downto 0);   --Host: Channel number for read
p_in_hrdstart     : in    std_logic;                      --Host: Start read data
p_in_hrddone      : in    std_logic;                      --Host: ACK read done
p_out_hirq        : out   std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);--IRQ
p_out_hdrdy       : out   std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);--Frame ready
p_out_hfrmrk      : out   std_logic_vector(31 downto 0);

--HOST <- MEM(VBUF)
p_in_vbufo_rdclk  : in    std_logic;
p_out_vbufo_do    : out   std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
p_in_vbufo_rd     : in    std_logic;
p_out_vbufo_empty : out   std_logic;

-------------------------------
--VBUFI -> MEM(VBUF)
-------------------------------
p_in_vbufi        : in    TFGWR_VBUFIs;

---------------------------------
--MEM
---------------------------------
--CH WRITE
p_out_memwr       : out   TMemIN;
p_in_memwr        : in    TMemOUT;
--CH READ
p_out_memrd       : out   TMemIN;
p_in_memrd        : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst          : in    std_logic_vector(31 downto 0);
p_out_tst         : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk          : in    std_logic;
p_in_rst          : in    std_logic
);
end component fg;


component switch_data is
generic(
G_ETH_CH_COUNT : integer:=1;
G_ETH_DWIDTH : integer:=32;
G_VBUFI_OWIDTH : integer:=32;
G_HOST_DWIDTH : integer:=32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in   std_logic;

p_in_cfg_adr     : in   std_logic_vector(5 downto 0);
p_in_cfg_adr_ld  : in   std_logic;

p_in_cfg_txdata  : in   std_logic_vector(15 downto 0);
p_in_cfg_wr      : in   std_logic;

p_out_cfg_rxdata : out  std_logic_vector(15 downto 0);
p_in_cfg_rd      : in   std_logic;

-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_eth_htxd_rdy      : in   std_logic;
p_in_eth_htxbuf_di     : in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_htxbuf_wr     : in   std_logic;
p_out_eth_htxbuf_full  : out  std_logic;
p_out_eth_htxbuf_empty : out  std_logic;

--host <- dev
p_out_eth_hrxbuf_do    : out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_hrxbuf_rd     : in   std_logic;
p_out_eth_hrxbuf_full  : out  std_logic;
p_out_eth_hrxbuf_empty : out  std_logic;

p_out_eth_hirq         : out  std_logic;

p_in_hclk              : in   std_logic;

-------------------------------
--ETH
-------------------------------
p_in_eth_tmr_irq       : in   std_logic;
p_in_eth_tmr_en        : in   std_logic;
p_in_eth_clk           : in   std_logic;
----p_in_eth               : in   TEthOUTs;
----p_out_eth              : out  TEthINs;

-------------------------------
--FG_BUFI
-------------------------------
p_in_vbufi_rdclk       : in   std_logic;
p_out_vbufi_do         : out  std_logic_vector(G_VBUFI_OWIDTH - 1 downto 0);
p_in_vbufi_rd          : in   std_logic;
p_out_vbufi_empty      : out  std_logic;
p_out_vbufi_full       : out  std_logic;
p_out_vbufi_pfull      : out  std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst               : in   std_logic_vector(31 downto 0);
p_out_tst              : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst     : in    std_logic
);
end component switch_data;

component timers is
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in   std_logic;

p_in_cfg_adr     : in   std_logic_vector(1 downto 0);
p_in_cfg_adr_ld  : in   std_logic;

p_in_cfg_txdata  : in   std_logic_vector(15 downto 0);
p_in_cfg_wr      : in   std_logic;

p_out_cfg_rxdata : out  std_logic_vector(15 downto 0);
p_in_cfg_rd      : in   std_logic;

-------------------------------
--
-------------------------------
p_in_tmr_clk     : in   std_logic;
p_out_tmr_irq    : out  std_logic_vector(C_TMR_COUNT - 1 downto 0);
p_out_tmr_en     : out  std_logic_vector(C_TMR_COUNT - 1 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst         : in   std_logic
);
end component timers;

end package kcu105_main_unit_pkg;
