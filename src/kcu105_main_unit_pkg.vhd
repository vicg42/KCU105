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
use work.eth_pkg.all;
use work.ust_cfg.all;
use work.cam_cl_pkg.all;

package kcu105_main_unit_pkg is

component fpga_test_01 is
generic(
G_BLINK_T05 : integer:=10#125#; -- 1/2 ������� ������� ����������.(����� � ms)
G_CLK_T05us : integer:=10#1000# -- ���-�� �������� ������� ����� p_in_clk
                                -- �������������� � 1/2 ������� 1us
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

p_out_dev_ctrl   : out   TDevCtrl;
p_out_dev_di     : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_do      : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
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
G_DBGCS : string := "OFF";

G_VBUFI_COUNT : integer := 1;
G_VBUFI_COUNT_MAX : integer := 1;
G_VCH_COUNT : integer := 1;

G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;
G_MEM_VLINE_L_BIT : integer := 0;

G_MEM_AWIDTH : integer := 32;
G_MEMWR_DWIDTH : integer := 32;
G_MEMRD_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TFgCtrl;

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
p_in_vbufi_do     : in    std_logic_vector((G_MEMWR_DWIDTH * G_VBUFI_COUNT_MAX) - 1 downto 0);
p_out_vbufi_rd    : out   std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_empty  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_full   : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_pfull  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);

---------------------------------
--MEM
---------------------------------
--CH WRITE
p_out_memwr       : out   TMemIN_vch;
p_in_memwr        : in    TMemOUT_vch;
--CH READ
p_out_memrd       : out   TMemIN;
p_in_memrd        : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst          : in    std_logic_vector(31 downto 0);
p_out_tst         : out   std_logic_vector(255 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk          : in    std_logic;
p_in_rst          : in    std_logic
);
end component fg;


component switch_data is
generic(
G_ETH_CH_COUNT : integer := 1;
G_ETH_DWIDTH : integer := 32;
G_FGBUFI_DWIDTH : integer := 32;
G_HOST_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TSwtCtrl;

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

--rxbuf <- eth
p_out_ethio_rx_axi_tready : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tdata   : in   std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tkeep   : in   std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tvalid  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tuser   : in   std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--txbuf -> eth
p_out_ethio_tx_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_tx_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_ethio_tx_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_tx_axi_done    : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

p_in_ethio_clk            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rst            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--FG_BUFI
-------------------------------
p_out_fgbufi_do    : out  std_logic_vector((G_FGBUFI_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_fgbufi_rd     : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_fgbufi_rdclk  : in   std_logic;
p_out_fgbufi_empty : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_full  : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_pfull : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--DBG
-------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst  : in    std_logic
);
end component switch_data;

component timers is
generic(
G_TMR_COUNT : natural := 1
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TTmrCtrl;

-------------------------------
--
-------------------------------
p_in_tmr_clk     : in   std_logic;
p_out_tmr_irq    : out  std_logic_vector(G_TMR_COUNT - 1 downto 0);
p_out_tmr_en     : out  std_logic_vector(G_TMR_COUNT - 1 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst         : in   std_logic
);
end component timers;


component eth_main is
generic(
G_ETH_CH_COUNT : integer := 1;
G_ETH_DWIDTH : integer := 64;
G_DBG  : string := "OFF";
G_SIM  : string := "OFF"
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TEthCtrl;

-------------------------------
--UsrBuf
-------------------------------
--rxbuf <- eth
p_in_rxbuf_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tkeep  : out  std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tuser  : out  std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--txbuf -> eth
p_in_txbuf_axi_tdata   : in   std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_out_txbuf_axi_tready : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_txbuf_axi_tvalid  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_txbuf_axi_done   : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

p_out_buf_clk  : out   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_buf_rst  : out   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--
-------------------------------
p_out_status_rdy      : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
--p_out_status_carier   : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_status_qplllock : out std_logic;

p_in_sfp_signal_detect : in std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_sfp_tx_fault      : in std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_sfp_tx_disable   : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy_txp    : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_ethphy_txn    : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_rxp     : in  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_rxn     : in  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_refclk_p: in  std_logic;
p_in_ethphy_refclk_n: in  std_logic;

-------------------------------
--DBG
-------------------------------
p_in_sim_speedup_control : in  std_logic;
p_in_tst  : in  std_logic_vector(31 downto 0);
p_out_tst : out std_logic_vector(31 downto 0);
p_out_dbg : out TEthDBG;

-------------------------------
--System
-------------------------------
p_in_dclk : in  std_logic; --DRP clk
p_in_rst : in  std_logic
);
end component eth_main;

component ust_main is
generic(
G_DBGCS : string := "OFF";
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_cam0_cl_tfg_n : in  std_logic; --Camera -> FG
p_in_cam0_cl_tfg_p : in  std_logic;
p_out_cam0_cl_tc_n : out std_logic; --Camera <- FG
p_out_cam0_cl_tc_p : out std_logic;

--X,Y,Z : 0,1,2
p_in_cam0_cl_clk_p : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
p_in_cam0_cl_clk_n : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
p_in_cam0_cl_di_p  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);
p_in_cam0_cl_di_n  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);

p_out_cam0_status  : out  std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

--------------------------------------------------
--To ETH
--------------------------------------------------
--user -> eth
p_out_eth_tx_axi_tdata   : out  std_logic_vector(63 downto 0);
p_in_eth_tx_axi_tready   : in   std_logic;
p_out_eth_tx_axi_tvalid  : out  std_logic;
p_in_eth_tx_axi_done     : in   std_logic;
p_in_eth_clk             : in   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(3 downto 0);
p_in_tst  : in   std_logic_vector(2 downto 0);

--------------------------------------------------
--SYSTEM
--------------------------------------------------
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component ust_main;


end package kcu105_main_unit_pkg;
