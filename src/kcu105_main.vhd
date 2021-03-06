-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : kcu105_main
--
-- Description : top level of project
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.clocks_pkg.all;
use work.pcie_pkg.all;
use work.prj_cfg.all;
use work.prj_def.all;
use work.kcu105_main_unit_pkg.all;
use work.mem_ctrl_pkg.all;
use work.mem_wr_pkg.all;
use work.eth_pkg.all;
use work.ust_cfg.all;
use work.cam_cl_pkg.all;

entity kcu105_main is
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_in_btn          : in    std_logic_vector(1 downto 0);
pin_out_led         : out   std_logic_vector(7 downto 0);

pin_in_cl_tfg_n : in  std_logic;
pin_in_cl_tfg_p : in  std_logic;
pin_out_cl_tc_n : out std_logic;
pin_out_cl_tc_p : out std_logic;

--X,Y,Z : 0,1,2
pin_in_cl_clk_p : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
pin_in_cl_clk_n : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
pin_in_cl_di_p  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);
pin_in_cl_di_n  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);

--RS232(PC)
pin_in_rs232_rx  : in  std_logic;
pin_out_rs232_tx : out std_logic;

--------------------------------------------------
--FMC
--------------------------------------------------
pin_out_led_hpc     : out   std_logic_vector(3 downto 0);
pin_out_led_lpc     : out   std_logic_vector(3 downto 0);

--------------------------------------------------
--ETH
--------------------------------------------------
pin_out_ethphy_txp     : out std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
pin_out_ethphy_txn     : out std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
pin_in_ethphy_rxp      : in  std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
pin_in_ethphy_rxn      : in  std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
pin_in_ethphy_refclk_p : in  std_logic;
pin_in_ethphy_refclk_n : in  std_logic;

pin_in_sfp_los         : in  std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
pin_out_sfp_tx_dis     : out std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);

--------------------------------------------------
--RAM
--------------------------------------------------
pin_out_phymem      : out   TMEMCTRL_pinout;
pin_inout_phymem    : inout TMEMCTRL_pininout;
pin_in_phymem       : in    TMEMCTRL_pinin;

--------------------------------------------------
--PCIE
--------------------------------------------------
pin_in_pcie_phy     : in    TPCIE_pinin;
pin_out_pcie_phy    : out   TPCIE_pinout;

--------------------------------------------------
--Reference clock
--------------------------------------------------
pin_out_refclk_sel  : out   std_logic;
pin_in_refclk       : in    TRefClkPinIN
);
end entity kcu105_main;

architecture struct of kcu105_main is

component debounce is
generic(
G_PUSH_LEVEL : std_logic := '0'; --���. ������� ����� ������ ������
G_DEBVAL : integer := 4
);
port(
p_in_btn  : in    std_logic;
p_out_btn : out   std_logic;

p_in_clk_en : in    std_logic;
p_in_clk    : in    std_logic
);
end component debounce;

signal i_glob_rst          : std_logic;
signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal g_usr_highclk       : std_logic;

signal i_host_rst_n        : std_logic;
signal g_host_clk          : std_logic;
signal i_host_gctrl        : std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);
signal i_host_dev_ctrl     : TDevCtrl;
signal i_host_dev_txd      : std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_dev_rxd      : std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_dev_wr       : std_logic;
signal i_host_dev_rd       : std_logic;
signal i_host_dev_status   : std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto C_HREG_DEV_STATUS_FST_BIT);
signal i_host_dev_irq      : std_logic_vector((C_HIRQ_COUNT - 1) downto C_HIRQ_FST_BIT);
signal i_host_dev_opt_in   : std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto C_HDEV_OPTIN_FST_BIT);
signal i_host_dev_opt_out  : std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto C_HDEV_OPTOUT_FST_BIT);

signal i_host_devadr       : unsigned(C_HREG_DMA_CTRL_ADR_M_BIT
                                                 - C_HREG_DMA_CTRL_ADR_L_BIT downto 0);

Type THostDCtrl is array (0 to C_HDEV_COUNT - 1) of std_logic;
Type THostDWR is array (0 to C_HDEV_COUNT - 1) of std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_wr           : THostDCtrl;
signal i_host_rd           : THostDCtrl;
signal i_host_txd          : THostDWR;
signal i_host_rxd          : THostDWR;
signal i_host_rxbuf_full   : THostDCtrl;
signal i_host_rxbuf_empty  : THostDCtrl;
signal i_host_txbuf_full   : THostDCtrl;
signal i_host_txbuf_empty  : THostDCtrl;
signal i_host_txd_rdy      : THostDCtrl;

signal i_host_tst_in       : std_logic_vector(127 downto 0);
signal i_host_tst_out      : std_logic_vector(127 downto 0);
signal i_host_tst2_out     : std_logic_vector(255 downto 0);
signal i_host_dbg          : TPCIE_dbg;

signal i_tmr_clk           : std_logic;
signal i_tmr_irq           : std_logic_vector(C_TMR_COUNT - 1 downto 0);
signal i_tmr_en            : std_logic_vector(C_TMR_COUNT - 1 downto 0);

signal i_host_mem_ctrl     : TPce2Mem_Ctrl;
signal i_host_mem_status   : TPce2Mem_Status;
signal i_host_mem_tst_out  : std_logic_vector(63 downto 0);
signal i_host_mem_tst_in   : std_logic_vector(31 downto 0);

signal i_mem_ctrl_rst      : std_logic;
signal i_memin_fgwrch      : TMemIN_vch;
signal i_memout_fgwrch     : TMemOUT_vch;
signal i_memin_ch          : TMemINCh;
signal i_memout_ch         : TMemOUTCh;

signal i_arb_mem_rst       : std_logic;
signal i_arb_memin         : TMemIN;
signal i_arb_memout        : TMemOUT;
signal i_arb_mem_tst_out   : std_logic_vector(31 downto 0);

signal i_mem_ctrl_status   : TMEMCTRL_status;
signal i_mem_ctrl_sysout   : TMEMCTRL_sysout;

signal i_fg_rst            : std_logic;
signal i_fgwr_chen         : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_fg_rd_start       : std_logic;
signal i_fg_tst_in         : std_logic_vector(31 downto 0);
signal i_fg_tst_out        : std_logic_vector(255 downto 0);

constant C_PCFG_FG_BUFI_DWIDTH : natural := 128; --C_PCFG_ETH_DWIDTH;
signal i_fg_bufi_do        : std_logic_vector((C_PCFG_FG_BUFI_DWIDTH * C_PCFG_ETH_CH_COUNT_MAX) - 1 downto 0);
signal i_fg_bufi_rd        : std_logic_vector(C_PCFG_ETH_CH_COUNT_MAX - 1 downto 0);
signal i_fg_bufi_empty     : std_logic_vector(C_PCFG_ETH_CH_COUNT_MAX - 1 downto 0);
signal i_fg_bufi_full      : std_logic_vector(C_PCFG_ETH_CH_COUNT_MAX - 1 downto 0);
signal i_fg_bufi_pfull     : std_logic_vector(C_PCFG_ETH_CH_COUNT_MAX - 1 downto 0);

signal i_ethio_rx_axi_tready : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_ethio_rx_axi_tdata  : std_logic_vector((C_PCFG_ETH_DWIDTH * C_PCFG_ETH_CH_COUNT) - 1 downto 0);
signal i_ethio_rx_axi_tkeep  : std_logic_vector(((C_PCFG_ETH_DWIDTH / 8) * C_PCFG_ETH_CH_COUNT) - 1 downto 0);
signal i_ethio_rx_axi_tvalid : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_ethio_rx_axi_tuser  : std_logic_vector((2 * C_PCFG_ETH_CH_COUNT) - 1 downto 0);

signal i_ethio_tx_axi_tdata  : std_logic_vector((C_PCFG_ETH_DWIDTH * C_PCFG_ETH_CH_COUNT) - 1 downto 0);
signal i_ethio_tx_axi_tready : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_ethio_tx_axi_tvalid : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_ethio_tx_axi_done   : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);

signal i_swt_ethio_tx_axi_tdata  : std_logic_vector((C_PCFG_ETH_DWIDTH * C_PCFG_ETH_CH_COUNT) - 1 downto 0);
signal i_swt_ethio_tx_axi_tready : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_swt_ethio_tx_axi_tvalid : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_swt_ethio_tx_axi_done   : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);

signal i_ust_ethio_tx_axi_tdata  : std_logic_vector(C_PCFG_ETH_DWIDTH - 1 downto 0);
signal i_ust_ethio_tx_axi_tready : std_logic;
signal i_ust_ethio_tx_axi_tvalid : std_logic;
signal i_ust_ethio_tx_axi_done   : std_logic;

signal i_ethio_clk           : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_ethio_rst           : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);

signal i_eth_status_rdy      : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
--signal i_eth_status_carier   : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_eth_status_qplllock : std_logic;
signal i_eth_rst             : std_logic;
signal i_eth_dbg             : TEthDBG;
signal i_eth_tst_in          : std_logic_vector(31 downto 0);

signal i_sfp_signal_detect   : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
signal i_sfp_tx_fault        : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);

signal i_test_led          : std_logic_vector(1 downto 0);

signal i_swt_rst           : std_logic;
signal i_swt_tst_out       : std_logic_vector(31 downto 0);

signal i_ust_tst_in        : std_logic_vector(2 downto 0);
signal i_ust_tst_out       : std_logic_vector(3 downto 0);
signal i_ust_frprm_restart_btn : std_logic;
signal i_ust_rst           : std_logic;
signal i_ust_rst_mnl       : std_logic;
signal i_ust_cam0_status   : std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

signal i_1ms               : std_logic;

attribute keep : string;
attribute keep of g_host_clk : signal is "true";
attribute keep of g_usr_highclk : signal is "true";
attribute keep of g_usrclk : signal is "true";
attribute keep of i_ethio_clk : signal is "true";

component dbgcs_ila_hostclk is
port (
clk : in std_logic;
--probe0 : in std_logic_vector(21 downto 0)
--probe0 : in std_logic_vector(38 downto 0)
probe0 : in std_logic_vector(55 downto 0)
--probe0 : in std_logic_vector(136 downto 0)
--probe0 : in std_logic_vector(199 downto 0)
);
end component dbgcs_ila_hostclk;

component dbgcs_ila_usr_highclk is
port (
clk : in std_logic;
probe0 : in std_logic_vector(156 downto 0)
);
end component dbgcs_ila_usr_highclk;

--
--type TDBG2_darray is array (0 to 0) of std_logic_vector(31 downto 0);
--
----type TH2M_dbg is record
----mem_start   : std_logic;
----mem_done    : std_logic;
----mem_wr_fsm  : std_logic_vector(3 downto 0);
--------d2h_buf_di    : std_logic_vector(31 downto 0);
----d2h_buf_wr    : std_logic;
----d2h_buf_empty : std_logic;
----d2h_buf_full  : std_logic;
------h2d_buf_do    : std_logic_vector(31 downto 0);
----h2d_buf_rd    : std_logic;
----h2d_buf_empty : std_logic;
----h2d_buf_full  : std_logic;
----
----htxbuf_wr_cnt : std_logic_vector(15 downto 0);
----htxbuf_rd_cnt : std_logic_vector(15 downto 0);
----
--------DEV -> MEM
----axiw_d      : TDBG2_darray;
------axiw_dvalid : std_logic;
------axiw_dlast  : std_logic;
------axiw_wready : std_logic;
------axiw_aready : std_logic;
----
------DEV <- MEM
----axir_d      : TDBG2_darray;
----axir_dvalid : std_logic;
----axir_dlast  : std_logic;
------axir_aready : std_logic;
----end record;
--
--type TCFG_dbg is record
--dadr    : std_logic_vector(3 downto 0);
--radr    : std_logic_vector(5 downto 0);
--radr_ld : std_logic;
--wr      : std_logic;
--rd      : std_logic;
--txd     : std_logic_vector(15 downto 0);
--rxd     : std_logic_vector(15 downto 0);
--rxbuf_empty : std_logic;
--txbuf_empty : std_logic;
--irq : std_logic;
--end record;
--
type TSWT_dbg is record
--h2eth_txd_rdy : std_logic;
--h2eth_txd : std_logic_vector(31 downto 0);
--h2eth_wr : std_logic;
--h2eth_txbuf_empty : std_logic;
--
--i_h2eth_buf_rst   : std_logic;
--i_eth_txbuf_empty : std_logic;
--ethio_clk         : std_logic;
--ethio_rst         : std_logic;

ethio_rx_axi_tready : std_logic                    ;
ethio_rx_axi_tdata  : std_logic_vector(63 downto 0);
ethio_rx_axi_tkeep  : std_logic_vector(7 downto 0) ;
ethio_rx_axi_tvalid : std_logic                    ;
ethio_rx_axi_tuser  : std_logic_vector(1 downto 0) ;

ethio_tx_axi_tdata  : std_logic_vector(63 downto 0);
ethio_tx_axi_tready : std_logic;
ethio_tx_axi_tvalid : std_logic;
ethio_tx_axi_done   : std_logic;

h2eth_buf_empty     : std_logic;

--fgbuf_fltr_den : std_logic;
--eth2fg_frr : std_logic;

--eth_txbuf_hrdy : std_logic;
--eth_txbuf_wr : std_logic;
--eth_txbuf_empty : std_logic;
--eth_txbuf_empty_tst : std_logic;
--eth_tmr_irq : std_logic;
--eth_tmr_en : std_logic;
--vbufi_empty : std_logic;
--eth_rxbuf_den : std_logic;
--vbufi_fltr_den : std_logic;
end record;

type TFGRD_dbg is record
fsm             : std_logic_vector(3 downto 0);
vch_num         : std_logic_vector(2 downto 0);
hrd_start       : std_logic;
fr_act_pixcount : std_logic_vector(15 downto 0);
fr_act_rowcount : std_logic_vector(15 downto 0);
steprd          : std_logic_vector(15 downto 0);
fr_skp_pixcount : std_logic_vector(15 downto 0);
fr_skp_rowcount : std_logic_vector(15 downto 0);
mirror_pix      : std_logic;
mirror_row      : std_logic;
rowcnt : std_logic_vector(15 downto 0);

--axir_adr    : std_logic_vector(30 downto 0);
--axir_d      : std_logic_vector(31 downto 0);
axir_dvalid : std_logic;
--axir_dlast  : std_logic;
--axir_aready : std_logic;
--
bufo_empty  : std_logic;
vbuf_hold   : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
hrd_done    : std_logic;
end record;

type TFGWR_vbufi is array (0 to 1) of std_logic_vector(31 downto 0);

type TFGWR_dbg is record
--fsm : std_logic_vector(3 downto 0);
--vbufi_d0         : std_logic_vector(31 downto 0);
--vbufi_d1         : std_logic_vector(31 downto 0);
--vbufi_d2         : std_logic_vector(31 downto 0);
--vbufi_rd         : std_logic;
--vbufi_empty      : std_logic;
--vbufi_full_lacth : std_logic;
--frrdy         : std_logic;
--fr_rownum : std_logic_vector(12 downto 0);
--mem_start : std_logic;
--mem_done : std_logic;
--chk : std_logic;

axiw_adr    : std_logic_vector(30 downto 0);
axiw_d      : std_logic_vector(31 downto 0);-- <= i_memin_ch(1).axiw.data((32 * 1) - 1 downto 32 * 0);
axiw_dvalid : std_logic;
axiw_dlast  : std_logic;
--axiw_wready : std_logic;
axiw_aready : std_logic;

vbufi_do       : TFGWR_vbufi;
fsm            : std_logic_vector(2 downto 0);--<= i_fg_tst_out(2 downto 0);-- <= std_logic_vector(tst_fgwr_fsm);
fr_rownum      : std_logic_vector(12 downto 0);--<= i_fg_tst_out(13 downto 3);-- <= std_logic_vector(i_fr_rownum(10 downto 0));
mem_start      : std_logic;--<= i_fg_tst_out(14);-- <= i_mem_start;
mem_done       : std_logic;--<= i_fg_tst_out(15);-- <= i_mem_done;
err            : std_logic;--<= i_fg_tst_out(16);-- <= i_err;
vbufi_sel      : std_logic;--<= i_fg_tst_out(17);-- <= i_vbufi_sel;
vbufi_empty_all: std_logic;--<= i_fg_tst_out(18);-- <= i_vbufi_empty;
fr_rdy0        : std_logic;--<= i_fg_tst_out(19);-- <= i_fr_rdy(0);
vbufi_full_det : std_logic_vector(1 downto 0);--<= i_fg_tst_out(20);-- <= tst_vbufi_full_detect;
vbufi_rd    : std_logic_vector(1 downto 0);--<= i_fg_tst_out(21);-- <= tst_vbufi_rd(0);
vbufi_empty : std_logic_vector(1 downto 0);--<= i_fg_tst_out(22);-- <= tst_vbufi_empty(0);
--vbufi_full  : std_logic_vector(1 downto 0);--<= i_fg_tst_out(23);-- <= tst_vbufi_full(0);
fsm1            : std_logic_vector(2 downto 0);--<= i_fg_tst_out(2 downto 0);-- <= std_logic_vector(tst_fgwr_fsm);
fr_rownum1      : std_logic_vector(12 downto 0);--<= i_fg_tst_out(13 downto 3);-- <= std_logic_vector(i_fr_rownum(10 downto 0));
end record;
--
type TFG_dbg is record
fgwr : TFGWR_dbg;
fgrd : TFGRD_dbg;
--hirq : std_logic;
--hdrdy : std_logic;

fgrd_vch          : std_logic_vector(2 downto 0);
fgrd_rddone       : std_logic;
fgwr_frrdy        : std_logic_vector(1 downto 0);
irq               : std_logic_vector(1 downto 0);
vbuf_hold         : std_logic_vector(1 downto 0);
err_vbuf_overflow : std_logic_vector(1 downto 0);
frskip0_count     : std_logic_vector(2 downto 0);
frskip1_count     : std_logic_vector(2 downto 0);

vbufi_full  : std_logic_vector(1 downto 0);
vbufi_pfull : std_logic_vector(1 downto 0);

end record;
--
--type TEth_dbg is record
--tx : TEthDBG_MacTx;
--rx : TEthDBG_MacRx;
--end record;
--
type TMAIN_dbg is record
pcie : TPCIE_dbg;
----h2m  : TH2M_dbg;
--cfg : TCFG_dbg;
swt : TSWT_dbg;
fg : TFG_dbg;
eth : TEthDBG;
vpkt_padding : std_logic;
eth_link : std_logic_vector(C_PCFG_ETH_CH_COUNT - 1 downto 0);
end record;

signal i_dbg    : TMAIN_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";


begin --architecture struct


--***********************************************************
--RESET
--***********************************************************
i_mem_ctrl_rst <= i_host_gctrl(C_HREG_CTRL_RST_MEM_BIT);--or i_host_gctrl(C_HREG_CTRL_RST_ALL_BIT) not i_host_rst_n or
i_arb_mem_rst <= not i_mem_ctrl_status.rdy;
i_eth_rst <= i_host_gctrl(C_HREG_CTRL_RST_ETH_BIT) or i_usrclk_rst;
i_swt_rst <= i_arb_mem_rst or i_host_gctrl(C_HREG_CTRL_RST_ALL_BIT);
i_fg_rst <= i_arb_mem_rst or i_host_gctrl(C_HREG_CTRL_RST_ALL_BIT);

i_host_mem_tst_in(0) <= i_arb_mem_rst;

--***********************************************************
--
--***********************************************************
m_clocks : clocks
port map(
p_out_rst  => i_usrclk_rst,
p_out_gclk => g_usrclk,

p_in_clkopt => (others => '0'),
--p_out_clk  => pin_out_refclk,
p_in_clk   => pin_in_refclk
);

pin_out_refclk_sel <= '0';

i_tmr_clk <= g_usrclk(0);
g_usr_highclk <= i_mem_ctrl_sysout.clk;



--#########################################
--
--#########################################
m_tmr : timers
generic map(
G_TMR_COUNT => C_TMR_COUNT
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_reg => i_host_dev_ctrl.reg.tmr,

-------------------------------
--
-------------------------------
p_in_tmr_clk  => i_tmr_clk,
p_out_tmr_irq => i_tmr_irq,
p_out_tmr_en  => i_tmr_en ,

-------------------------------
--System
-------------------------------
p_in_rst => i_usrclk_rst
);


--#########################################
--Ethernet
--#########################################
m_eth : eth_main
generic map(
G_DBG => C_PCFG_ETH_DBG,
G_ETH_CH_COUNT => C_PCFG_ETH_CH_COUNT,
G_ETH_DWIDTH => C_PCFG_ETH_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_reg => i_host_dev_ctrl.reg.eth,

-------------------------------
--UsrBuf
-------------------------------
--rxbuf <- eth
p_in_rxbuf_axi_tready  => i_ethio_rx_axi_tready,
p_out_rxbuf_axi_tdata  => i_ethio_rx_axi_tdata ,
p_out_rxbuf_axi_tkeep  => i_ethio_rx_axi_tkeep ,
p_out_rxbuf_axi_tvalid => i_ethio_rx_axi_tvalid,
p_out_rxbuf_axi_tuser  => i_ethio_rx_axi_tuser ,

--txbuf -> eth
p_in_txbuf_axi_tdata   => i_ethio_tx_axi_tdata ,
p_out_txbuf_axi_tready => i_ethio_tx_axi_tready,
p_in_txbuf_axi_tvalid  => i_ethio_tx_axi_tvalid,
p_out_txbuf_axi_done   => i_ethio_tx_axi_done  ,

p_out_buf_clk => i_ethio_clk,
p_out_buf_rst => i_ethio_rst,

-------------------------------
--
-------------------------------
p_out_status_rdy      => i_eth_status_rdy,
--p_out_status_carier   => i_eth_status_carier,
p_out_status_qplllock => i_eth_status_qplllock,

p_in_sfp_signal_detect => i_sfp_signal_detect,
p_in_sfp_tx_fault      => (others => '0'),--i_sfp_tx_fault,
p_out_sfp_tx_disable   => pin_out_sfp_tx_dis,

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy_txp     => pin_out_ethphy_txp    ,
p_out_ethphy_txn     => pin_out_ethphy_txn    ,
p_in_ethphy_rxp      => pin_in_ethphy_rxp     ,
p_in_ethphy_rxn      => pin_in_ethphy_rxn     ,
p_in_ethphy_refclk_p => pin_in_ethphy_refclk_p,
p_in_ethphy_refclk_n => pin_in_ethphy_refclk_n,

-------------------------------
--DBG
-------------------------------
p_in_sim_speedup_control => '0',
p_in_tst  => i_eth_tst_in,
p_out_tst => open,
p_out_dbg => i_eth_dbg,

-------------------------------
--System
-------------------------------
p_in_dclk => g_usrclk(0), --DRP clk
p_in_rst => i_eth_rst --i_usrclk_rst
);

gen_sfp_los : for i in 0 to (C_PCFG_ETH_CH_COUNT - 1) generate
begin
i_sfp_signal_detect(i) <= not pin_in_sfp_los(i);
end generate gen_sfp_los;


--ETH_TX(0) <- SWT
i_ethio_tx_axi_tdata((C_PCFG_ETH_DWIDTH * (0 + 1)) - 1 downto (C_PCFG_ETH_DWIDTH * 0)) <= i_swt_ethio_tx_axi_tdata((C_PCFG_ETH_DWIDTH * (0 + 1)) - 1 downto (C_PCFG_ETH_DWIDTH * 0));
i_ethio_tx_axi_tvalid(0) <= i_swt_ethio_tx_axi_tvalid(0);
i_swt_ethio_tx_axi_tready(0) <= i_ethio_tx_axi_tready(0);
i_swt_ethio_tx_axi_done(0) <= i_ethio_tx_axi_done(0);

--ETH_TX(1) <- UST
i_ethio_tx_axi_tdata((C_PCFG_ETH_DWIDTH * (1 + 1)) - 1 downto (C_PCFG_ETH_DWIDTH * 1)) <= i_ust_ethio_tx_axi_tdata;
i_ethio_tx_axi_tvalid(1) <= i_ust_ethio_tx_axi_tvalid;
i_ust_ethio_tx_axi_tready <= i_ethio_tx_axi_tready(1);
i_ust_ethio_tx_axi_done <= i_ethio_tx_axi_done(1);


--#########################################
--UST DBG
--#########################################
m_ust : ust_main
generic map(
G_DBGCS => C_PCFG_UST_DBGCS,
G_SIM => "OFF"
)
port map(
--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_cam0_cl_tfg_n => pin_in_cl_tfg_n,
p_in_cam0_cl_tfg_p => pin_in_cl_tfg_p,
p_out_cam0_cl_tc_n => pin_out_cl_tc_n,
p_out_cam0_cl_tc_p => pin_out_cl_tc_p,

--X,Y,Z : 0,1,2
p_in_cam0_cl_clk_p => pin_in_cl_clk_p,
p_in_cam0_cl_clk_n => pin_in_cl_clk_n,
p_in_cam0_cl_di_p  => pin_in_cl_di_p ,
p_in_cam0_cl_di_n  => pin_in_cl_di_n ,

p_out_cam0_status  => i_ust_cam0_status,

--------------------------------------------------
--To ETH
--------------------------------------------------
--user -> eth
p_out_eth_tx_axi_tdata  => i_ust_ethio_tx_axi_tdata,
p_in_eth_tx_axi_tready  => i_ust_ethio_tx_axi_tready,
p_out_eth_tx_axi_tvalid => i_ust_ethio_tx_axi_tvalid,
p_in_eth_tx_axi_done    => i_ust_ethio_tx_axi_done,
p_in_eth_clk            => i_ethio_clk(1),

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => i_ust_tst_out,
p_in_tst  => i_ust_tst_in,

--------------------------------------------------
--SYSTEM
--------------------------------------------------
p_in_clk => g_usrclk(0),
p_in_rst => i_ust_rst
);

i_ust_rst <= OR_reduce(i_ethio_rst) or i_ust_rst_mnl;



--#########################################
--Switch
--#########################################
m_swt : switch_data
generic map(
G_ETH_CH_COUNT => C_PCFG_ETH_CH_COUNT,
G_ETH_DWIDTH   => C_PCFG_ETH_DWIDTH,
G_FGBUFI_DWIDTH => C_PCFG_FG_BUFI_DWIDTH,
G_HOST_DWIDTH  => C_HDEV_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_reg => i_host_dev_ctrl.reg.swt,

-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_eth_htxd_rdy      => i_host_txd_rdy(C_HDEV_ETH),
p_in_eth_htxbuf_di     => i_host_txd(C_HDEV_ETH),
p_in_eth_htxbuf_wr     => i_host_wr(C_HDEV_ETH),
p_out_eth_htxbuf_full  => i_host_txbuf_full(C_HDEV_ETH),
p_out_eth_htxbuf_empty => i_host_txbuf_empty(C_HDEV_ETH),

--host <- dev
p_out_eth_hrxbuf_do    => i_host_rxd(C_HDEV_ETH),
p_in_eth_hrxbuf_rd     => i_host_rd(C_HDEV_ETH),
p_out_eth_hrxbuf_full  => i_host_rxbuf_full(C_HDEV_ETH),
p_out_eth_hrxbuf_empty => i_host_rxbuf_empty(C_HDEV_ETH),

p_out_eth_hirq         => i_host_dev_irq(C_HIRQ_ETH),

p_in_hclk              => g_host_clk,

-------------------------------
--ETH
-------------------------------
p_in_eth_tmr_irq       => i_tmr_irq(C_TMR_ETH),
p_in_eth_tmr_en        => i_tmr_en(C_TMR_ETH) ,

--rxbuf <- eth
p_out_ethio_rx_axi_tready => i_ethio_rx_axi_tready,
p_in_ethio_rx_axi_tdata   => i_ethio_rx_axi_tdata ,
p_in_ethio_rx_axi_tkeep   => i_ethio_rx_axi_tkeep ,
p_in_ethio_rx_axi_tvalid  => i_ethio_rx_axi_tvalid,
p_in_ethio_rx_axi_tuser   => i_ethio_rx_axi_tuser ,

--txbuf -> eth
p_out_ethio_tx_axi_tdata  => i_swt_ethio_tx_axi_tdata , --i_ethio_tx_axi_tdata ,--
p_in_ethio_tx_axi_tready  => i_swt_ethio_tx_axi_tready, --i_ethio_tx_axi_tready,--
p_out_ethio_tx_axi_tvalid => i_swt_ethio_tx_axi_tvalid, --i_ethio_tx_axi_tvalid,--
p_in_ethio_tx_axi_done    => i_swt_ethio_tx_axi_done  , --i_ethio_tx_axi_done  ,--

p_in_ethio_clk            => i_ethio_clk,
p_in_ethio_rst            => i_ethio_rst,

-------------------------------
--FG_BUFI
-------------------------------
p_in_fgbufi_rdclk  => g_usr_highclk  ,
p_out_fgbufi_do    => i_fg_bufi_do   ((C_PCFG_FG_BUFI_DWIDTH * C_PCFG_ETH_CH_COUNT) - 1 downto 0),
p_in_fgbufi_rd     => i_fg_bufi_rd   (C_PCFG_ETH_CH_COUNT - 1 downto 0),
p_out_fgbufi_empty => i_fg_bufi_empty(C_PCFG_ETH_CH_COUNT - 1 downto 0),
p_out_fgbufi_full  => i_fg_bufi_full (C_PCFG_ETH_CH_COUNT - 1 downto 0),
p_out_fgbufi_pfull => i_fg_bufi_pfull(C_PCFG_ETH_CH_COUNT - 1 downto 0),

-------------------------------
--DBG
-------------------------------
p_in_tst  => (others => '0'),
p_out_tst => i_swt_tst_out,

-------------------------------
--System
-------------------------------
p_in_rst  => i_swt_rst
);


--#########################################
--Frame Grabber
--#########################################
i_fg_rd_start <= i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_DMA_START_BIT)
                  when i_host_devadr = TO_UNSIGNED(C_HDEV_FG, i_host_devadr'length) else '0';

m_fg : fg
generic map(
G_DBGCS => "ON",

G_VBUFI_COUNT => C_PCFG_ETH_CH_COUNT,
G_VBUFI_COUNT_MAX => C_PCFG_ETH_CH_COUNT_MAX,
G_VCH_COUNT => C_FG_VCH_COUNT,

G_MEM_VCH_M_BIT   => C_FG_MEM_VCH_M_BIT  ,
G_MEM_VCH_L_BIT   => C_FG_MEM_VCH_L_BIT  ,
G_MEM_VFR_M_BIT   => C_FG_MEM_VFR_M_BIT  ,
G_MEM_VFR_L_BIT   => C_FG_MEM_VFR_L_BIT  ,
G_MEM_VLINE_M_BIT => C_FG_MEM_VLINE_M_BIT,
G_MEM_VLINE_L_BIT => C_FG_MEM_VLINE_L_BIT,

G_MEM_AWIDTH => C_AXI_AWIDTH,
G_MEMWR_DWIDTH => C_PCFG_FG_BUFI_DWIDTH,
G_MEMRD_DWIDTH => C_HDEV_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_reg => i_host_dev_ctrl.reg.fg,

-------------------------------
--HOST
-------------------------------
p_in_hrdchsel     => i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_FG_CH_M_BIT downto C_HREG_DMA_CTRL_FG_CH_L_BIT),
p_in_hrdstart     => i_fg_rd_start,
p_in_hrddone      => i_host_gctrl(C_HREG_CTRL_FG_RDDONE_BIT),
p_out_hirq        => i_host_dev_irq((C_HIRQ_FG_VCH0 + C_FG_VCH_COUNT) - 1 downto C_HIRQ_FG_VCH0),
p_out_hdrdy       => i_host_dev_status((C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT
                                        + C_FG_VCH_COUNT) - 1 downto C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT),

p_out_hfrmrk      => i_host_dev_opt_in(C_HDEV_OPTIN_FG_FRMRK_M_BIT downto C_HDEV_OPTIN_FG_FRMRK_L_BIT),

--HOST <- MEM(VBUF)
p_in_vbufo_rdclk  => g_host_clk,
p_out_vbufo_do    => i_host_rxd(C_HDEV_FG),
p_in_vbufo_rd     => i_host_rd(C_HDEV_FG),
p_out_vbufo_empty => i_host_rxbuf_empty(C_HDEV_FG),

-------------------------------
--VBUFI -> MEM(VBUF)
-------------------------------
p_in_vbufi_do     => i_fg_bufi_do,
p_out_vbufi_rd    => i_fg_bufi_rd,
p_in_vbufi_empty  => i_fg_bufi_empty,
p_in_vbufi_full   => i_fg_bufi_full,
p_in_vbufi_pfull  => i_fg_bufi_pfull,

---------------------------------
--MEM
---------------------------------
--CH WRITE
p_out_memwr       => i_memin_fgwrch , --(2),--DEV -> MEM
p_in_memwr        => i_memout_fgwrch, --(2),--DEV <- MEM
--CH READ                           --
p_out_memrd       => i_memin_ch (0),--(1),--DEV -> MEM
p_in_memrd        => i_memout_ch(0),--(1),--DEV <- MEM

-------------------------------
--DBG
-------------------------------
p_in_tst          => (others => '0'),--i_fg_tst_in,
p_out_tst         => i_fg_tst_out,

-------------------------------
--System
-------------------------------
p_in_clk          => g_usr_highclk,
p_in_rst          => i_fg_rst
);

gen_fgwr_memch : for i in 0 to (C_FG_VCH_COUNT - 1) generate
begin
i_memin_ch(1 + i)  <= i_memin_fgwrch(i) ;
i_memout_fgwrch(i) <= i_memout_ch(1 + i);
end generate gen_fgwr_memch;


--***********************************************************
--PCI-Express (HOST)
--***********************************************************
m_host : pcie_main
generic map(
G_DBGCS => "OFF"
)
port map(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk      => g_host_clk        ,
p_out_gctrl     => i_host_gctrl      ,

p_out_dev_ctrl  => i_host_dev_ctrl   ,
p_out_dev_di    => i_host_dev_txd    ,
p_in_dev_do     => i_host_dev_rxd    ,
p_out_dev_wr    => i_host_dev_wr     ,
p_out_dev_rd    => i_host_dev_rd     ,
p_in_dev_status => i_host_dev_status ,
p_in_dev_irq    => i_host_dev_irq    ,
p_in_dev_opt    => i_host_dev_opt_in ,
p_out_dev_opt   => i_host_dev_opt_out,

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst   => i_host_tst_out,
p_in_usr_tst    => (others => '0'),
p_in_tst        => (others => '0'),
p_out_tst       => i_host_tst2_out,
p_out_dbg       => i_host_dbg     ,

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy   => pin_in_pcie_phy ,
p_out_pcie_phy  => pin_out_pcie_phy,
p_out_pcie_rst_n => open --i_host_rst_n
);

i_host_tst_in(31 downto 0) <= (others => '0');
i_host_tst_in(47 downto 32) <= (others => '0');
i_host_tst_in(65 downto 48) <= (others => '0');
i_host_tst_in(127 downto 66) <= (others => '0');


i_host_devadr <= UNSIGNED(i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_ADR_M_BIT downto C_HREG_DMA_CTRL_ADR_L_BIT));

--Status User Devices
i_host_dev_status(C_HREG_DEV_STATUS_MEMCTRL_RDY_BIT) <= i_mem_ctrl_status.rdy;

i_host_dev_status(C_HREG_DEV_STATUS_ETH_RDY_BIT) <= i_eth_status_qplllock;
i_host_dev_status(C_HREG_DEV_STATUS_ETH_LINK_BIT) <= i_eth_status_rdy(0);
i_host_dev_status(C_HREG_DEV_STATUS_ETH_RXRDY_BIT) <= not i_host_rxbuf_empty(C_HDEV_ETH);
i_host_dev_status(C_HREG_DEV_STATUS_ETH_TXRDY_BIT) <= i_host_txbuf_empty(C_HDEV_ETH);

--Host Write/Read data of user devices
gen_dev_dbuf : for i in 0 to i_host_wr'length - 1 generate
begin
i_host_wr(i)  <= i_host_dev_wr when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_rd(i)  <= i_host_dev_rd when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_txd(i) <= i_host_dev_txd;
i_host_txd_rdy(i) <= i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_DRDY_BIT) when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
end generate gen_dev_dbuf;

i_host_dev_rxd <= i_host_rxd(C_HDEV_ETH) when i_host_devadr = TO_UNSIGNED(C_HDEV_ETH, i_host_devadr'length) else
                  i_host_rxd(C_HDEV_FG);--  when i_host_devadr = TO_UNSIGNED(C_HDEV_FG, i_host_devadr'length) else
--                  i_host_rxd(C_HDEV_MEM);

--Flags (Host <- User Devices)
--i_host_dev_opt_in(C_HDEV_OPTIN_TXFIFO_FULL_BIT) <= i_host_txbuf_full(C_HDEV_MEM) when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else
i_host_dev_opt_in(C_HDEV_OPTIN_TXFIFO_FULL_BIT) <= i_host_txbuf_full(C_HDEV_ETH) when i_host_devadr = TO_UNSIGNED(C_HDEV_ETH, i_host_devadr'length) else
                                                   '0';

--i_host_dev_opt_in(C_HDEV_OPTIN_RXFIFO_EMPTY_BIT) <= i_host_rxbuf_empty(C_HDEV_MEM) when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else
i_host_dev_opt_in(C_HDEV_OPTIN_RXFIFO_EMPTY_BIT) <= i_host_rxbuf_empty(C_HDEV_ETH) when i_host_devadr = TO_UNSIGNED(C_HDEV_ETH, i_host_devadr'length) else
                                                    i_host_rxbuf_empty(C_HDEV_FG)  when i_host_devadr = TO_UNSIGNED(C_HDEV_FG , i_host_devadr'length) else
                                                    '0';

i_host_dev_opt_in(C_HDEV_OPTIN_ETH_HEADER_M_BIT
                    downto C_HDEV_OPTIN_ETH_HEADER_L_BIT) <= i_host_rxd(C_HDEV_ETH)(31 downto 0);

i_host_dev_opt_in(C_HDEV_OPTIN_MEM_DONE_BIT) <= '0';--i_host_mem_status.done;


--***********************************************************
--HOST <-> Memory
--***********************************************************
i_host_mem_ctrl.trnwr_len <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_TRNWR_LEN_M_BIT downto C_HDEV_OPTOUT_MEM_TRNWR_LEN_L_BIT);
i_host_mem_ctrl.trnrd_len <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_TRNRD_LEN_M_BIT downto C_HDEV_OPTOUT_MEM_TRNRD_LEN_L_BIT);
i_host_mem_ctrl.adr       <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_ADR_M_BIT downto C_HDEV_OPTOUT_MEM_ADR_L_BIT);
i_host_mem_ctrl.req_len   <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_RQLEN_M_BIT downto C_HDEV_OPTOUT_MEM_RQLEN_L_BIT);
i_host_mem_ctrl.dir       <= not i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_DMA_DIR_BIT);
i_host_mem_ctrl.start     <= i_host_dev_ctrl.dma(C_HREG_DMA_CTRL_DMA_START_BIT)
                                when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else '0';

--m_host2mem : pcie2mem_ctrl
--generic map(
--G_MEM_AWIDTH     => C_HREG_MEM_ADR_LAST_BIT,
--G_MEM_DWIDTH     => C_AXIS_DWIDTH(0),
--G_MEM_BANK_M_BIT => C_HREG_MEM_ADR_BANK_M_BIT,
--G_MEM_BANK_L_BIT => C_HREG_MEM_ADR_BANK_L_BIT,
--G_DBG            => "ON"
--)
--port map(
---------------------------------
----CTRL
---------------------------------
--p_in_ctrl         => i_host_mem_ctrl,
--p_out_status      => i_host_mem_status,
--
----host -> dev(mem)
--p_in_htxbuf_di     => i_host_txd(C_HDEV_MEM),
--p_in_htxbuf_wr     => i_host_wr(C_HDEV_MEM),
--p_out_htxbuf_full  => i_host_txbuf_full(C_HDEV_MEM),
--p_out_htxbuf_empty => open,
--
----host <- dev(mem)
--p_out_hrxbuf_do    => i_host_rxd(C_HDEV_MEM),
--p_in_hrxbuf_rd     => i_host_rd(C_HDEV_MEM),
--p_out_hrxbuf_full  => open,
--p_out_hrxbuf_empty => i_host_rxbuf_empty(C_HDEV_MEM),
--
--p_in_hclk          => g_host_clk,
--
---------------------------------
----MEM_CTRL Port
---------------------------------
--p_out_mem         => i_memin_ch(0), --DEV -> MEM
--p_in_mem          => i_memout_ch(0),--DEV <- MEM
--
---------------------------------
----DBG
---------------------------------
--p_in_tst          => i_host_mem_tst_in,
--p_out_tst         => i_host_mem_tst_out,
--
---------------------------------
----System
---------------------------------
--p_in_clk         => g_usr_highclk,
--p_in_rst         => i_arb_mem_rst
--);
--


--***********************************************************
--Memory controller
--***********************************************************
--Arbiter
m_mem_arb : mem_arb
generic map(
G_CH_COUNT   => C_MEM_ARB_CH_COUNT,
G_MEM_AWIDTH => C_AXI_AWIDTH,
G_MEM_DWIDTH => C_AXIM_DWIDTH
)
port map(
-------------------------------
--USR Port
-------------------------------
p_in_memch  => i_memin_ch,
p_out_memch => i_memout_ch,

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem   => i_arb_memin,
p_in_mem    => i_arb_memout,

-------------------------------
--DBG
-------------------------------
p_in_tst    => (others => '0'),
p_out_tst   => i_arb_mem_tst_out,

-------------------------------
--System
-------------------------------
p_in_clk    => g_usr_highclk,
p_in_rst    => i_arb_mem_rst
);


m_mem_ctrl : mem_ctrl
generic map(
G_SIM => "OFF"
)
port map(
------------------------------------
--USER Port
------------------------------------
p_in_mem   => i_arb_memin ,
p_out_mem  => i_arb_memout,

p_out_status    => i_mem_ctrl_status,

------------------------------------
--Memory physical interface
------------------------------------
p_out_phymem    => pin_out_phymem,
p_inout_phymem  => pin_inout_phymem,

------------------------------------
--System
------------------------------------
p_out_sys       => i_mem_ctrl_sysout,
p_in_sys        => pin_in_phymem,
p_in_rst        => i_mem_ctrl_rst
);



--#########################################
--DBG
--#########################################
m_led : fpga_test_01
generic map(
G_BLINK_T05 => 10#250#,
G_CLK_T05us => 10#62#
)
port map (
p_out_test_led  => i_test_led(0),
p_out_test_done => open,

p_out_1us  => open,
p_out_1ms  => i_1ms,
p_out_1s   => open,
-------------------------------
--System
-------------------------------
p_in_clken => '1',
p_in_clk   => g_usrclk(0),
p_in_rst   => i_usrclk_rst
);

pin_out_led(0) <= i_test_led(0) and (not i_host_tst_out(127)); --i_pcie_irq_err;
pin_out_led(1) <= i_host_tst2_out(0) and (not OR_reduce(i_fg_tst_out(43 downto 42))) ;--i_user_lnk_up ; i_fg_tst_out(32) - tst_err_vbuf_overflow
pin_out_led(2) <= i_mem_ctrl_status.rdy and (not (i_fg_tst_out(25) or i_fg_tst_out(50 + 25)) );
pin_out_led(3) <= i_eth_status_qplllock and i_test_led(1);

gen_eth_status : for i in 0 to (C_PCFG_ETH_CH_COUNT - 1) generate
begin
pin_out_led(4 + i) <= i_sfp_signal_detect(i);
pin_out_led(6 + i) <= i_eth_status_rdy(i);
end generate gen_eth_status;

gen_eth_count1 : if (C_PCFG_ETH_CH_COUNT = 1) generate
begin
pin_out_led(5) <= '0';
pin_out_led(7) <= '0';
end generate gen_eth_count1;


--pin_out_led_hpc(0) <= i_swt_tst_out(4);-- <= OR_reduce(h_reg_eth2fg_frr(0))
--pin_out_led_hpc(1) <= i_swt_tst_out(5);-- <= h_reg_ctrl(C_SWT_REG_CTRL_DBG_HOST2FG_BIT);
--pin_out_led_hpc(2) <= i_tmr_irq(0) and i_tmr_en(0);
--pin_out_led_hpc(3) <= i_test_led(1);
pin_out_led_hpc(0) <= i_ust_cam0_status(C_CAM_STATUS_CL_LINKTOTAL_BIT);
pin_out_led_hpc(1) <= i_ust_cam0_status(C_CAM_STATUS_CLX_LINK_BIT);
pin_out_led_hpc(2) <= i_ust_cam0_status(C_CAM_STATUS_CLY_LINK_BIT);
pin_out_led_hpc(3) <= i_ust_cam0_status(C_CAM_STATUS_CLZ_LINK_BIT);

pin_out_led_lpc(0) <= i_swt_tst_out(4);-- <= OR_reduce(h_reg_eth2fg_frr(0))
pin_out_led_lpc(1) <= i_swt_tst_out(5);-- <= h_reg_ctrl(C_SWT_REG_CTRL_DBG_HOST2FG_BIT);
pin_out_led_lpc(2) <= i_tmr_irq(0) and i_tmr_en(0);
pin_out_led_lpc(3) <= i_test_led(1);


m_led2 : fpga_test_01
generic map(
G_BLINK_T05 => 10#250#,
G_CLK_T05us => 10#62#
)
port map (
p_out_test_led  => i_test_led(1),
p_out_test_done => open,

p_out_1us  => open,
p_out_1ms  => open,
p_out_1s   => open,
-------------------------------
--System
-------------------------------
p_in_clken => '1',
p_in_clk   => i_ethio_clk(0),
p_in_rst   => i_ethio_rst(0)
);

i_ust_tst_in(0) <= i_ust_frprm_restart_btn;
i_ust_tst_in(2) <= pin_in_rs232_rx;--p_in_tst(2); --cam_ctrl_rx (UART)

--i_ust_tst_out(0);--i_fval(0)
--i_ust_tst_out(1);--i_lval(0)
pin_out_rs232_tx <= i_ust_tst_out(2);--cam_ctrl_tx (UART)

i_ust_rst_mnl <= pin_in_btn(0); --CPU_RESET

m_btn : debounce
generic map(
G_PUSH_LEVEL => '0', --���. ������� ����� ������ ������
G_DEBVAL => 250
)
port map(
p_in_btn  => pin_in_btn(1), --SW_C (SW7)
p_out_btn => i_ust_frprm_restart_btn,

p_in_clk_en => i_1ms,
p_in_clk    => g_usrclk(0)
);


i_eth_tst_in(0) <= i_host_tst_out(0);


------#############################################
------DBGCS
------#############################################
----gen_dbgcs_on : if strcmp(C_PCFG_MAIN_DBGCS, "ON") generate
----begin
----
--i_dbg.pcie <= i_host_dbg;

i_dbg.fg.fgwr.vbufi_do(0) <= i_fg_bufi_do((32 * 1) - 1 downto (32 * 0));
i_dbg.fg.fgwr.vbufi_do(1) <= i_fg_bufi_do((32 * 2) - 1 downto (32 * 1));
i_dbg.fg.fgwr.fsm       <= i_fg_tst_out( 2 downto 0);-- <= std_logic_vector(tst_fgwr_fsm);
i_dbg.fg.fgwr.fr_rownum <= i_fg_tst_out(15 downto 3);-- <= std_logic_vector(i_fr_rownum(10 downto 0));
i_dbg.fg.fgwr.mem_start <= i_fg_tst_out(16);-- <= i_mem_start;
i_dbg.fg.fgwr.mem_done  <= i_fg_tst_out(17);-- <= i_mem_done;
--i_dbg.fg.fgwr.err <= i_fg_tst_out(18);-- <= i_err;
--i_dbg.fg.fgwr.vbufi_sel <= i_fg_tst_out(19);-- <= i_vbufi_sel;
--i_dbg.fg.fgwr.vbufi_empty_all <= i_fg_tst_out(20);-- <= i_vbufi_empty;
--i_dbg.fg.fgwr.fr_rdy0 <= i_fg_tst_out(21);-- <= i_fr_rdy(0);
--i_dbg.fg.fgwr.vbufi_full_det <= i_fg_tst_out(22);-- <= tst_vbufi_full_detect;
i_dbg.fg.fgwr.vbufi_rd      (0) <= i_fg_tst_out( 0 + 23);-- <= tst_vbufi_rd(0);
i_dbg.fg.fgwr.vbufi_empty   (0) <= i_fg_tst_out( 0 + 24);-- <= tst_vbufi_empty(0);
i_dbg.fg.fgwr.vbufi_full_det(0) <= i_fg_tst_out( 0 + 25);-- <= tst_vbufi_full(0);
i_dbg.fg.fgwr.vbufi_rd      (1) <= i_fg_tst_out(50 + 23);-- <= tst_vbufi_rd(1);
i_dbg.fg.fgwr.vbufi_empty   (1) <= i_fg_tst_out(50 + 24);-- <= tst_vbufi_empty(1);
i_dbg.fg.fgwr.vbufi_full_det(1) <= i_fg_tst_out(50 + 25);-- <= tst_vbufi_full(1);

i_dbg.fg.fgwr.fsm1       <= i_fg_tst_out((50 +  2) downto (50 + 0));-- <= std_logic_vector(tst_fgwr_fsm);
i_dbg.fg.fgwr.fr_rownum1 <= i_fg_tst_out((50 + 15) downto (50 + 3));-- <= std_logic_vector(i_fr_rownum(10 downto 0));

--
i_dbg.fg.fgrd.fsm             <= i_fg_tst_out((128 + 3) downto (128 + 0))  ;--<= std_logic_vector(tst_fsm_fgrd);
i_dbg.fg.fgrd.vch_num         <= i_fg_tst_out((128 + 6) downto (128 + 4))  ;--<= i_vch_num;
i_dbg.fg.fgrd.hrd_start       <= i_fg_tst_out(128 + 7)                     ;--<= p_in_hrd_start;
i_dbg.fg.fgrd.fr_act_pixcount <= i_fg_tst_out((128 + 23) downto (128 + 8 ));--<= i_vch_prm.fr.act.pixcount;
i_dbg.fg.fgrd.fr_act_rowcount <= i_fg_tst_out((128 + 39) downto (128 + 24));--<= i_vch_prm.fr.act.rowcount;
i_dbg.fg.fgrd.steprd          <= i_fg_tst_out((128 + 55) downto (128 + 40));--<= i_vch_prm.steprd;
i_dbg.fg.fgrd.fr_skp_pixcount <= i_fg_tst_out((128 + 71) downto (128 + 56));--<= i_vch_prm.fr.skp.pixcount;
i_dbg.fg.fgrd.fr_skp_rowcount <= i_fg_tst_out((128 + 87) downto (128 + 72));--<= i_vch_prm.fr.skp.rowcount;
i_dbg.fg.fgrd.mirror_pix      <= i_fg_tst_out(128 + 88)          ;--<= i_vch_prm.mirror.pix;
i_dbg.fg.fgrd.mirror_row      <= i_fg_tst_out(128 + 89)          ;--<= i_vch_prm.mirror.row;
i_dbg.fg.fgrd.rowcnt      <= i_fg_tst_out((128 + 105) downto (128 + 90));
i_dbg.fg.fgrd.hrd_done       <= i_fg_tst_out(128 + 106)                     ;--<= p_in_hrd_start;
i_dbg.fg.fgrd.bufo_empty <= i_host_rxbuf_empty(C_HDEV_FG);
i_dbg.fg.fgrd.vbuf_hold <= i_host_dev_status((C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT
                                        + C_FG_VCH_COUNT) - 1 downto C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT);

--i_dbg.fg.fgwr.axiw_adr    <= i_memin_ch(1).axiw.adr(30 downto 0);
--i_dbg.fg.fgwr.axiw_d      <= i_memin_ch(1).axiw.data((32 * 1) - 1 downto 32 * 0);
--i_dbg.fg.fgwr.axiw_dvalid <= i_memin_ch(1).axiw.dvalid;
--i_dbg.fg.fgwr.axiw_dlast  <= i_memin_ch(1).axiw.dlast ;
----i_dbg.fg.fgwr.axiw_wready <= i_memout_ch(1).axiw.wready;
--i_dbg.fg.fgwr.axiw_aready <= i_memout_ch(1).axiw.aready;
--
--i_dbg.fg.fgrd.axir_adr    <= i_memin_ch(0).axiw.adr(30 downto 0);
--i_dbg.fg.fgrd.axir_d      <= i_memout_ch(0).axir.data((32 * 1) - 1 downto 32 * 0);
i_dbg.fg.fgrd.axir_dvalid <= i_memout_ch(0).axir.dvalid;
--i_dbg.fg.fgrd.axir_dlast  <= i_memout_ch(0).axir.dlast ;
--i_dbg.fg.fgrd.axir_aready <= i_memout_ch(0).axir.aready;








--i_dbg.fg.fgwr.fsm <= i_fg_tst_out(3  downto 0);
--i_dbg.fg.fgwr.vbufi_rd <= i_fg_tst_out(4);
--i_dbg.fg.fgwr.vbufi_empty <= i_fg_bufi_empty(0);
--i_dbg.fg.fgwr.chk <= i_fg_tst_out(23);
--i_dbg.fg.fgwr.vbufi_full_lacth <= i_fg_tst_out(5);
--i_dbg.fg.fgwr.fr_rownum <= i_fg_tst_out(20 downto 10);
--i_dbg.fg.fgwr.mem_start <= i_fg_tst_out(21);
--i_dbg.fg.fgwr.mem_done <= i_fg_tst_out(22);
--
--i_dbg.fg.fgwr.frrdy <= i_fg_tst_out(6);-- <= i_fr_rdy(0);
--i_dbg.fg.fgwr.vbufi_d0 <= i_fg_bufi_do((32 * 1) - 1 downto (32 * 0));
--i_dbg.fg.fgwr.vbufi_d1 <= i_fg_bufi_do((32 * 2) - 1 downto (32 * 1));
----i_dbg.fg.fgwr.vbufi_d2 <= i_fg_bufi_do((32 * 3) - 1 downto (32 * 2));
--i_dbg.fg.hirq <= i_fg_tst_out(8);-- <= i_irq_exp(0);
--i_dbg.fg.hdrdy <= i_fg_tst_out(9);-- <= i_vbuf_hold(0);
--
--
----i_dbg.swt.eth_txbuf_wr <= i_host_wr(C_HDEV_ETH);
----i_dbg.swt.eth_txbuf_empty <= i_swt_tst_out(1);-- <= i_eth_txbuf_empty;
----i_dbg.swt.eth_txbuf_empty_tst <= i_swt_tst_out(2);-- <= tst_txbuf_empty;
----i_dbg.swt.eth_txbuf_hrdy <= i_host_txd_rdy(C_HDEV_ETH);
----i_dbg.swt.eth_tmr_irq <= i_tmr_irq(C_TMR_ETH);
----i_dbg.swt.eth_tmr_en  <= i_tmr_en(C_TMR_ETH) ;
----i_dbg.swt.vbufi_empty <= i_swt_tst_out(3);-- <= tst_vbufi_empty;
----i_dbg.swt.eth_rxbuf_den <= i_swt_tst_out(6);-- <= tst_eth_rxbuf_den;
----i_dbg.swt.vbufi_fltr_den <= i_swt_tst_out(7);-- <= i_vbufi_fltr_den;

i_dbg.swt.ethio_rx_axi_tdata  <= i_ethio_rx_axi_tdata ((64 * (1 + 0)) - 1 downto (64 * 0));
i_dbg.swt.ethio_rx_axi_tkeep  <= i_ethio_rx_axi_tkeep ((8 * (1 + 0)) - 1 downto (8 * 0));
i_dbg.swt.ethio_rx_axi_tvalid <= i_ethio_rx_axi_tvalid(0);
i_dbg.swt.ethio_rx_axi_tuser  <= i_ethio_rx_axi_tuser ((2 * (1 + 0)) - 1 downto (2 * 0));

--i_dbg.swt.ethio_tx_axi_tdata  <= i_ethio_tx_axi_tdata ((64 * (1 + 1)) - 1 downto (64 * 1));
--i_dbg.swt.ethio_tx_axi_tready <= i_ethio_tx_axi_tready(1);
--i_dbg.swt.ethio_tx_axi_tvalid <= i_ethio_tx_axi_tvalid(1);
--i_dbg.swt.ethio_tx_axi_done   <= i_ethio_tx_axi_done  (1);
--i_dbg.swt.h2eth_buf_empty     <= i_swt_tst_out(1);-- <= i_eth_txbuf_empty;


i_dbg.fg.fgrd_vch          <= i_fg_tst_out(34 downto 32);--<= i_fgrd_vch;
i_dbg.fg.fgrd_rddone       <= i_fg_tst_out(35)          ;--<= i_fgrd_rddone;
i_dbg.fg.fgwr_frrdy        <= i_fg_tst_out(37 downto 36);--<= i_fgwr_frrdy(1 downto 0);
i_dbg.fg.irq               <= i_fg_tst_out(39 downto 38);--<= i_irq(1 downto 0);
i_dbg.fg.vbuf_hold         <= i_fg_tst_out(41 downto 40);--<= i_vbuf_hold(1 downto 0);
i_dbg.fg.err_vbuf_overflow <= i_fg_tst_out(43 downto 42);--<= tst_err_vbuf_overflow(1 downto 0);
i_dbg.fg.frskip0_count     <= i_fg_tst_out(46 downto 44);--<= i_frskip(0);
i_dbg.fg.frskip1_count     <= i_fg_tst_out(49 downto 47);--<= i_frskip(1);

--i_dbg.fg.vbufi_full        <= i_fg_bufi_full;
--i_dbg.fg.vbufi_pfull       <= i_fg_bufi_pfull;

----i_dbg.swt.ethio_rx_axi_tvalid <= i_swt_tst_out(6);
----i_dbg.swt.ethio_rx_axi_tuser  <= i_swt_tst_out(7) & i_swt_tst_out(8);
----i_swt_tst_out(7);-- <= syn_eth_rxd_sof(0);
----i_swt_tst_out(8);-- <= syn_eth_rxd_eof(0);
--
--i_dbg.swt.h2eth_txd         <= i_host_txd(C_HDEV_ETH)        ;
--i_dbg.swt.h2eth_wr          <= i_host_wr(C_HDEV_ETH)         ;
--i_dbg.swt.h2eth_txbuf_empty <= i_host_txbuf_empty(C_HDEV_ETH);
--i_dbg.swt.h2eth_txd_rdy     <= i_host_txd_rdy(C_HDEV_ETH)    ;
--
--i_dbg.swt.i_h2eth_buf_rst   <= i_swt_tst_out(0);--<= i_h2eth_buf_rst;
--process(i_dbg.swt.ethio_clk)
--begin
--if rising_edge(i_dbg.swt.ethio_clk) then
--i_dbg.swt.i_eth_txbuf_empty <= i_swt_tst_out(1);--<= i_eth_txbuf_empty;
--end if;
--end process;
--i_dbg.swt.ethio_clk <= i_ethio_clk(0);
----i_dbg.swt.ethio_rst <= i_ethio_rst(0);
----i_dbg.swt.eth2fg_frr <= i_swt_tst_out(4);-- <= OR_reduce(h_reg_eth2fg_frr(0));
--i_dbg.swt.fgbuf_fltr_den <= i_swt_tst_out(9);-- <= i_fgbuf_fltr_den(0);
--
i_dbg.eth <= i_eth_dbg;
i_dbg.vpkt_padding <= i_ust_tst_out(3);
i_dbg.eth_link <= i_eth_status_rdy;
--i_dbg.eth.tx <= i_eth_dbg.tx(0);
--i_dbg.eth.rx <= i_eth_dbg.rx(0);
--
--
--i_dbg.cfg.dadr    <= i_cfg_dadr(3 downto 0);
--i_dbg.cfg.radr    <= i_cfg_radr(5 downto 0);
--i_dbg.cfg.radr_ld <= i_cfg_radr_ld;
--i_dbg.cfg.wr      <= i_cfg_wr     ;
--i_dbg.cfg.rd      <= i_cfg_rd     ;
--i_dbg.cfg.txd     <= i_cfg_txd    ;
--i_dbg.cfg.rxd     <= i_cfg_rxd    ;--i_cfg_rxd_dev(C_CFGDEV_SWT);--
--i_dbg.cfg.rxbuf_empty <= i_host_rxbuf_empty(C_HDEV_CFG);
--i_dbg.cfg.txbuf_empty <= i_host_txbuf_empty(C_HDEV_CFG);
--i_dbg.cfg.irq <= i_host_dev_irq(C_HIRQ_CFG);
--
--
--
--
----
------i_dbg.h2m.mem_start     <= i_host_mem_tst_out(0)           ;-- <= i_mem_start;
------i_dbg.h2m.mem_done      <= i_host_mem_tst_out(1)           ;-- <= i_mem_done;
------i_dbg.h2m.mem_wr_fsm    <= i_host_mem_tst_out(5 downto 2)  ;-- <= tst_mem_ctrl_out(5 downto 2);--m_mem_wr/tst_fsm_cs;
--------i_dbg.h2m.d2h_buf_di    <= i_host_mem_tst_out(95 downto 64);-- <= i_rxbuf_din(31 downto 0);--RAM->PCIE
------i_dbg.h2m.d2h_buf_wr    <= i_host_mem_tst_out(10)          ;-- <= i_rxbuf_din_wr ;--RAM->PCIE
------i_dbg.h2m.d2h_buf_empty <= i_host_mem_tst_out(6)           ;-- <= i_rxbuf_empty;  --RAM->PCIE
------i_dbg.h2m.d2h_buf_full  <= i_host_mem_tst_out(7)           ;-- <= i_rxbuf_full;   --RAM->PCIE
----------i_dbg.h2m.h2d_buf_do    <= i_host_mem_tst_out(63 downto 32);-- <= i_txbuf_dout(31 downto 0);--RAM<-PCIE
------i_dbg.h2m.h2d_buf_rd    <= i_host_mem_tst_out(11)          ;-- <= i_txbuf_dout_rd;--RAM<-PCIE
------i_dbg.h2m.h2d_buf_empty <= i_host_mem_tst_out(8)           ;-- <= i_txbuf_empty;  --RAM<-PCIE
------i_dbg.h2m.h2d_buf_full  <= i_host_mem_tst_out(9)           ;-- <= i_txbuf_full;   --RAM<-PCIE
------
----------DEV -> MEM
--------i_dbg.h2m.axiw_d(0)   <= i_memin_ch(0).axiw.data((32 * 1) - 1 downto 32 * 0);
--------i_dbg.h2m.axiw_d(1)   <= i_memin_ch(0).axiw.data((32 * 2) - 1 downto 32 * 1);
--------i_dbg.h2m.axiw_d(2)   <= i_memin_ch(0).axiw.data((32 * 3) - 1 downto 32 * 2);
--------i_dbg.h2m.axiw_d(3)   <= i_memin_ch(0).axiw.data((32 * 4) - 1 downto 32 * 3);
--------i_dbg.h2m.axiw_dvalid <= i_memin_ch(0).axiw.dvalid;
--------i_dbg.h2m.axiw_dlast  <= i_memin_ch(0).axiw.dlast ;
--------i_dbg.h2m.axiw_wready <= i_memout_ch(0).axiw.wready;
--------i_dbg.h2m.axiw_aready <= i_memout_ch(0).axiw.aready;
------
--------DEV <- MEM
------gen_dbg_h2m_axir_d : for i in 0 to 0 generate begin
------i_dbg.h2m.axir_d(i) <= i_memout_ch(0).axir.data((32 * (i + 1)) - 1 downto 32 * i);
------end generate gen_dbg_h2m_axir_d;
------i_dbg.h2m.axir_dvalid <= i_memout_ch(0).axir.dvalid;
------i_dbg.h2m.axir_dlast  <= i_memout_ch(0).axir.dlast ;
--------i_dbg.h2m.axir_aready <= i_memout_ch(0).axir.aready;
------
------i_dbg.h2m.htxbuf_wr_cnt <= i_host_mem_tst_out(47 downto 32);-- <= std_logic_vector(tst_htxbuf_wr_cnt);
------i_dbg.h2m.htxbuf_rd_cnt <= i_host_mem_tst_out(63 downto 48);-- <= std_logic_vector(tst_htxbuf_rd_cnt);
------
------gen_dbg_h2m_axiw_d : for i in 0 to 0 generate begin
------i_dbg.h2m.axiw_d(i)   <= i_memin_ch(0).axiw.data((32 * (i + 1)) - 1 downto 32 * i);
------end generate gen_dbg_h2m_axiw_d;
----
------##########################
------m_dbg_hostclk : dbgcs_ila_hostclk
------port map (
------clk => g_host_clk,
------
--------pc <- fpga
------probe0(0) => i_dbg.pcie.axi_rq_tvalid,
------probe0(1) => i_dbg.pcie.axi_rq_tlast ,
------probe0(2) => i_dbg.pcie.axi_rq_tready,
------
--------pc -> fpga
------probe0(3) => i_dbg.pcie.axi_rc_tvalid,
------probe0(4) => i_dbg.pcie.axi_rc_tlast ,
------probe0(5) => i_dbg.pcie.axi_rc_tready,
------
------probe0(9 downto 6) => i_dbg.pcie.dev_num  ,
------probe0(10)         => i_dbg.pcie.dma_start,
------probe0(11)         => i_dbg.pcie.dma_irq  ,
------
------probe0(12)         => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
------probe0(13)         => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
------probe0(14)         => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
------probe0(15)         => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
------
------probe0(16) => i_dbg.pcie.irq_int ,
------probe0(17) => i_dbg.pcie.irq_pend,
------probe0(18) => i_dbg.pcie.irq_sent,
------probe0(19) => i_dbg.pcie.irq_msi ,
------
------probe0(20) => i_dbg.pcie.test_speed_bit,
------
------probe0(24 downto 21) => i_dbg.pcie.axi_rq_fsm,
------
------probe0(56 downto 25) => i_dbg.pcie.h2d_buf_di(0),
------probe0(88 downto 57) => i_dbg.pcie.d2h_buf_do(0)
------);
----
------m_dbg_hostclk : dbgcs_ila_hostclk
------port map (
------clk => g_host_clk,
------
--------pc <- fpga
------probe0(0) => i_dbg.pcie.axi_rq_tvalid,
------probe0(1) => i_dbg.pcie.axi_rq_tlast ,
------probe0(2) => i_dbg.pcie.axi_rq_tready,
------
--------pc -> fpga
------probe0(3) => i_dbg.pcie.axi_rc_tvalid,
------probe0(4) => i_dbg.pcie.axi_rc_tlast ,
------probe0(5) => i_dbg.pcie.axi_rc_tready,
------
------probe0(9 downto 6) => i_dbg.pcie.dev_num  ,
------probe0(10)         => i_dbg.pcie.dma_start,
------probe0(11)         => i_dbg.pcie.dma_irq  ,
------
------probe0(12)         => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
------probe0(13)         => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
------probe0(14)         => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
------probe0(15)         => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
------
------probe0(16) => i_dbg.pcie.irq_int ,
------probe0(17) => i_dbg.pcie.irq_pend,
------probe0(18) => i_dbg.pcie.irq_sent,
------
------probe0(19) => i_dbg.pcie.irq_msi_en,
--------probe0(20) => i_dbg.pcie.irq_msi_int,
--------probe0(21) => i_dbg.pcie.irq_msi_send,
--------probe0(22) => i_dbg.pcie.irq_msi_fail,
--------probe0(23) => i_dbg.pcie.irq_msi_pending_status,
--------probe0(29 downto 24) => i_dbg.pcie.irq_msi_vf_enable,
--------probe0(35 downto 30) => i_dbg.pcie.irq_msi_mmenable,
------
------probe0(36) => i_dbg.pcie.test_speed_bit
------);
----
----
------m_dbg_hostclk : dbgcs_ila_hostclk
------port map (
------clk => g_host_clk,
------
------probe0(3 downto 0) => i_dbg.pcie.dev_num  ,
------probe0(4) => i_dbg.pcie.dma_start,
------probe0(5) => i_dbg.pcie.dma_irq  ,
------probe0(6) => i_dbg.pcie.test_speed_bit,
------probe0(7) => i_dbg.pcie.irq_int ,
------probe0(8) => i_dbg.pcie.irq_pend,
------probe0(9) => i_dbg.pcie.irq_sent,
------probe0(10) => i_dbg.pcie.irq_msi_en,
------
------
------------pc <- fpga
----------probe0(11) => i_dbg.pcie.axi_rc_tvalid,
----------probe0(12) => i_dbg.pcie.axi_rc_tlast ,
----------probe0(13) => i_dbg.pcie.axi_rc_tready,
----------
----------probe0(14) => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
----------probe0(15) => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
----------
----------probe0(23 downto 16) => i_dbg.pcie.axi_rc_tkeep,
----------
----------probe0(55 downto 24) => i_dbg.pcie.h2d_buf_di(0),
----------probe0(87 downto 56) => i_dbg.pcie.h2d_buf_di(1),
----------probe0(119 downto 88) => i_dbg.pcie.h2d_buf_di(2),
----------probe0(151 downto 120) => i_dbg.pcie.h2d_buf_di(3),
----------probe0(183 downto 152) => i_dbg.pcie.h2d_buf_di(4),
----------probe0(215 downto 184) => i_dbg.pcie.h2d_buf_di(5),
----------probe0(247 downto 216) => i_dbg.pcie.h2d_buf_di(6),
----------probe0(279 downto 248) => i_dbg.pcie.h2d_buf_di(7)
------
--------pc <- fpga
------probe0(11) => i_dbg.pcie.axi_rq_tvalid,
------probe0(12) => i_dbg.pcie.axi_rq_tlast ,
------probe0(13) => i_dbg.pcie.axi_rq_tready,
------
------probe0(14) => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
------probe0(15) => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
------
------probe0(23 downto 16) => i_dbg.pcie.axi_rq_tkeep,
------
------probe0(55 downto 24) => i_dbg.pcie.d2h_buf_do(0),
------probe0(87 downto 56) => i_dbg.pcie.d2h_buf_do(1),
------probe0(119 downto 88) => i_dbg.pcie.d2h_buf_do(2),
------probe0(151 downto 120) => i_dbg.pcie.d2h_buf_do(3),
------probe0(183 downto 152) => i_dbg.pcie.d2h_buf_do(4),
------probe0(215 downto 184) => i_dbg.pcie.d2h_buf_do(5),
------probe0(247 downto 216) => i_dbg.pcie.d2h_buf_do(6),
------probe0(279 downto 248) => i_dbg.pcie.d2h_buf_do(7)
------
--------probe0(20) => i_dbg.pcie.irq_msi_int,
--------probe0(21) => i_dbg.pcie.irq_msi_send,
--------probe0(22) => i_dbg.pcie.irq_msi_fail,
--------probe0(23) => i_dbg.pcie.irq_msi_pending_status,
--------probe0(29 downto 24) => i_dbg.pcie.irq_msi_vf_enable,
--------probe0(35 downto 30) => i_dbg.pcie.irq_msi_mmenable,
------
------
------);
----
------m_dbg_hostclk : dbgcs_ila_hostclk
------port map (
------clk => g_host_clk,
------
------probe0(3 downto 0) => i_dbg.pcie.dev_num  ,
------probe0(4) => i_dbg.pcie.dma_start,
------probe0(5) => i_dbg.pcie.dma_dir,
------probe0(6) => i_dbg.pcie.dma_irq_clr,
------probe0(7) => i_dbg.pcie.irq_int,
------probe0(8) => i_dbg.pcie.irq_pend,
------
------probe0(9) => i_dbg.pcie.axi_rc_tready,
------probe0(10) => i_dbg.pcie.axi_rc_tvalid,
------probe0(11) => i_dbg.pcie.axi_rc_tlast ,
------
------probe0(12) => i_dbg.pcie.axi_rq_tready,
------probe0(13) => i_dbg.pcie.axi_rq_tvalid,
------probe0(14) => i_dbg.pcie.axi_rq_tlast ,
------
------probe0(15) => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
------probe0(16) => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
------
------probe0(17) => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
------probe0(18) => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
------
--------probe0(48 downto 17) => i_dbg.pcie.axi_rc_tdata(0),
--------probe0(80 downto 49) => i_dbg.pcie.axi_rc_tdata(1),
------probe0(50 downto 19) => i_dbg.pcie.d2h_buf_d(0),
--------probe0(81 downto 51) => i_dbg.pcie.d2h_buf_d(1),
------
------probe0(82 downto 51) => i_dbg.pcie.axi_rq_tdata(0),
--------probe0(145 downto 114) => i_dbg.pcie.axi_rq_tdata(1),
------
------probe0(84 downto 83) => i_dbg.pcie.axi_rc_tkeep,
------probe0(86 downto 85) => i_dbg.pcie.axi_rq_tkeep,
------
------probe0(89 downto 87) => i_dbg.pcie.axi_rc_fsm
------
--------probe0(96 downto 81) => i_dbg.h2m.htxbuf_wr_cnt,
------
--------probe0(112 downto 81) => i_dbg.pcie.d2h_buf_do(2),
--------probe0(144 downto 113) => i_dbg.pcie.d2h_buf_do(3)
------);
--
--m_dbg_hostclk : dbgcs_ila_hostclk
--port map (
--clk => g_host_clk,
--
--probe0(3 downto 0) => i_dbg.pcie.dev_num  ,
--probe0(4) => i_dbg.pcie.dma_start,
--probe0(5) => i_dbg.pcie.dma_dir,
--probe0(6) => i_dbg.pcie.dma_irq_clr,
--probe0(7) => i_dbg.pcie.irq_int,
--probe0(8) => i_dbg.pcie.irq_pend,
--
--probe0(9) => i_dbg.pcie.axi_rc_tready,
--probe0(10) => i_dbg.pcie.axi_rc_tvalid,
--probe0(11) => i_dbg.pcie.axi_rc_tlast ,
--
--probe0(12) => i_dbg.pcie.axi_rq_tready,
--probe0(13) => i_dbg.pcie.axi_rq_tvalid,
--probe0(14) => i_dbg.pcie.axi_rq_tlast
--
----probe0(15) => i_dbg.cfg.radr_ld,
----probe0(16) => i_dbg.cfg.wr,
----probe0(17) => i_dbg.cfg.rd,
----probe0(18) => i_dbg.cfg.rxbuf_empty,
----probe0(19) => i_dbg.cfg.txbuf_empty,
----probe0(20) => i_dbg.cfg.irq,
----probe0(24  downto 21) => i_dbg.cfg.dadr,
----probe0(30  downto 25) => i_dbg.cfg.radr,
----probe0(46 downto 31) => i_dbg.cfg.txd,
----probe0(62 downto 47) => i_dbg.cfg.rxd
----
----probe0(63) => i_dbg.swt.h2eth_wr          ,
----probe0(64) => i_dbg.swt.h2eth_txbuf_empty ,
----probe0(65) => i_dbg.swt.h2eth_txd_rdy     ,
----probe0(97 downto 66) => i_dbg.swt.h2eth_txd
--
----probe0(18) => i_dbg.swt.eth_txbuf_wr,
----probe0(19) => i_dbg.swt.eth_txbuf_empty,
----probe0(20) => i_dbg.swt.eth_txbuf_hrdy,
----probe0(21) => i_dbg.swt.eth_txbuf_empty_tst,
----probe0(22) => i_dbg.swt.eth_tmr_irq,
----probe0(23) => i_dbg.swt.eth_tmr_en,
----probe0(24) => i_dbg.swt.vbufi_empty,
----probe0(25) => i_dbg.swt.eth_rxbuf_den,
----probe0(26) => i_dbg.swt.vbufi_fltr_den,
----probe0(27) => i_dbg.fg.hdrdy -- <= i_fg_tst_out(9);-- <= i_vbuf_hold(0);
--
----probe0(15) => i_dbg.pcie.h2d_buf_wr,
----probe0(16) => i_dbg.pcie.d2h_buf_rd,
----probe0(48  downto 17) => i_dbg.pcie.h2d_buf_d(0),
----probe0(80  downto 49) => i_dbg.pcie.h2d_buf_d(1),
----probe0(112 downto 81) => i_dbg.pcie.d2h_buf_d(0),
----probe0(144 downto 113) => i_dbg.pcie.d2h_buf_d(1),
--
----probe0(148  downto 145) => i_dbg.cfg.dadr,
----probe0(154  downto 149) => i_dbg.cfg.radr,
----probe0(155) => i_dbg.cfg.radr_ld,
----probe0(156) => i_dbg.cfg.wr,
----probe0(157) => i_dbg.cfg.rd,
----probe0(158) => i_dbg.cfg.rxbuf_empty,
----probe0(159) => i_dbg.cfg.txbuf_empty,
----probe0(160) => i_dbg.cfg.irq,
----probe0(176 downto 161) => i_dbg.cfg.txd,
----probe0(192 downto 177) => i_dbg.cfg.rxd
--
--
----probe0(193) => i_dbg.pcie.dma_work   ,
----probe0(194) => i_dbg.pcie.dma_worktrn,
----probe0(195) => i_dbg.pcie.dma_timeout,
----
----probe0(202 downto 196) => i_dbg.pcie.irq_stat
--
--);
--
------########### DBG AXI ###############
------m_dbg_highclk : dbgcs_ila_hostclk
------port map (
------clk => g_usr_highclk,
------
------probe0(0)          => i_dbg.h2m.mem_start     ,--<= i_host_mem_tst_out(0)         ;-- <= i_mem_start;
------probe0(1)          => i_dbg.h2m.mem_done      ,--<= i_host_mem_tst_out(1)         ;-- <= i_mem_done;
------probe0(5 downto 2) => i_dbg.h2m.mem_wr_fsm    ,--<= i_host_mem_tst_out(5 downto 2);-- <= tst_mem_ctrl_out(5 downto 2);--m_mem_wr/tst_fsm_cs;
------probe0(6)          => i_dbg.h2m.d2h_buf_wr    ,--<= i_host_mem_tst_out(10)        ;-- <= i_rxbuf_din_wr ;--RAM->PCIE
------probe0(7)          => i_dbg.h2m.d2h_buf_empty ,--<= i_host_mem_tst_out(6)         ;-- <= i_rxbuf_empty;  --RAM->PCIE
------probe0(8)          => i_dbg.h2m.d2h_buf_full  ,--<= i_host_mem_tst_out(7)         ;-- <= i_rxbuf_full;   --RAM->PCIE
------probe0(9)          => i_dbg.h2m.h2d_buf_rd    ,--<= i_host_mem_tst_out(11)        ;-- <= i_txbuf_dout_rd;--RAM<-PCIE
------probe0(10)         => i_dbg.h2m.h2d_buf_empty ,--<= i_host_mem_tst_out(8)         ;-- <= i_txbuf_empty;  --RAM<-PCIE
------probe0(11)         => i_dbg.h2m.h2d_buf_full  ,--<= i_host_mem_tst_out(9)         ;-- <= i_txbuf_full;   --RAM<-PCIE
------
--------DEV -> MEM
------probe0(12) => i_dbg.h2m.axiw_dvalid,
------probe0(13) => i_dbg.h2m.axiw_dlast ,
------probe0(14) => i_dbg.h2m.axiw_wready,
------probe0(15) => i_dbg.h2m.axiw_aready,
------
--------DEV <- MEM
------probe0(16) => i_dbg.h2m.axir_dvalid,
------probe0(17) => i_dbg.h2m.axir_dlast ,
------probe0(18) => i_dbg.h2m.axir_aready,
------
------probe0(50 downto 19)   => i_dbg.h2m.axiw_d(0),--RAM<-PCIE
------probe0(82 downto 51)   => i_dbg.h2m.axiw_d(1),--RAM<-PCIE
------probe0(114 downto 83)  => i_dbg.h2m.axiw_d(2),--RAM<-PCIE
------probe0(146 downto 115) => i_dbg.h2m.axiw_d(3),--RAM<-PCIE
------probe0(178 downto 147) => i_dbg.h2m.axir_d(0),--RAM->PCIE
------probe0(210 downto 179) => i_dbg.h2m.axir_d(1),--RAM->PCIE
------probe0(242 downto 211) => i_dbg.h2m.axir_d(2),--RAM->PCIE
------probe0(274 downto 243) => i_dbg.h2m.axir_d(3) --RAM->PCIE
--------probe0(275) => '0',
--------probe0(276) => '0',
--------probe0(277) => '0',
--------probe0(278) => '0',
--------probe0(279) => '0'
------);
----
----
------m_dbg_highclk : dbgcs_ila_usr_highclk
------port map (
------clk => g_usr_highclk,
------
------probe0(0)          => i_dbg.h2m.mem_start     ,--<= i_host_mem_tst_out(0)         ;-- <= i_mem_start;
------probe0(1)          => i_dbg.h2m.mem_done      ,--<= i_host_mem_tst_out(1)         ;-- <= i_mem_done;
------probe0(5 downto 2) => i_dbg.h2m.mem_wr_fsm    ,--<= i_host_mem_tst_out(5 downto 2);-- <= tst_mem_ctrl_out(5 downto 2);--m_mem_wr/tst_fsm_cs;
------probe0(6)          => i_dbg.h2m.d2h_buf_wr    ,--<= i_host_mem_tst_out(10)        ;-- <= i_rxbuf_din_wr ;--RAM->PCIE
------probe0(7)          => i_dbg.h2m.d2h_buf_empty ,--<= i_host_mem_tst_out(6)         ;-- <= i_rxbuf_empty;  --RAM->PCIE
------probe0(8)          => i_dbg.h2m.d2h_buf_full  ,--<= i_host_mem_tst_out(7)         ;-- <= i_rxbuf_full;   --RAM->PCIE
------probe0(9)          => i_dbg.h2m.h2d_buf_rd    ,--<= i_host_mem_tst_out(10)        ;-- <= i_rxbuf_din_wr ;--RAM->PCIE
------probe0(10)         => i_dbg.h2m.h2d_buf_empty ,--<= i_host_mem_tst_out(6)         ;-- <= i_rxbuf_empty;  --RAM->PCIE--DEV <- MEM
------probe0(11)         => i_dbg.h2m.h2d_buf_full  ,--<= i_host_mem_tst_out(7)         ;-- <= i_rxbuf_full;   --RAM->PCIEprobe0(9) => i_dbg.h2m.axir_dvalid,
------
------probe0(12) => i_dbg.h2m.axir_dlast ,
------
------probe0(44 downto 13)   => i_dbg.h2m.axir_d(0),--RAM->PCIE
--------probe0(76 downto 45)   => i_dbg.h2m.axir_d(1), --RAM->PCIE
--------probe0(106 downto 75)  => i_dbg.h2m.axir_d(2),--RAM->PCIE
--------probe0(138 downto 107) => i_dbg.h2m.axir_d(3) --RAM->PCIE
------
------probe0(76 downto 45)  => i_dbg.h2m.axiw_d(0)
--------probe0(156 downto 125) => i_dbg.h2m.axiw_d(1)
------
--------probe0(92 downto 77) => i_dbg.h2m.htxbuf_rd_cnt,
--------probe0(93) => i_dbg.h2m.axir_dvalid
------);
----
--
--m_dbg_fg : dbgcs_ila_usr_highclk
--port map (
--clk => g_usr_highclk,
--
--probe0(3 downto 0) => i_dbg.fg.fgwr.fsm,
--probe0(4) => i_dbg.fg.fgwr.vbufi_rd,
--probe0(5) => i_dbg.fg.fgwr.vbufi_empty,
--probe0(6) => i_dbg.fg.fgwr.chk,--vbufi_full_lacth,
--probe0(7) => i_dbg.fg.fgwr.frrdy,
--
--probe0(8) => i_dbg.fg.hirq,
--probe0(9) => i_dbg.fg.hdrdy,
--
--probe0(41 downto 10) => i_dbg.fg.fgwr.vbufi_d0,
--probe0(42) => i_dbg.fg.fgwr.mem_start,
--probe0(43) => i_dbg.fg.fgwr.mem_done,
--probe0(54 downto 44) => i_dbg.fg.fgwr.fr_rownum,
--probe0(86 downto 55) => i_dbg.fg.fgwr.vbufi_d1
----probe0(118 downto 87) => i_dbg.fg.fgwr.vbufi_d2
--);
--
--
--m_dbg_highclk : dbgcs_ila_usr_highclk
--port map (
--clk => i_dbg.swt.ethio_clk,
--
--probe0(0) => i_dbg.swt.i_h2eth_buf_rst,
--probe0(1) => i_dbg.swt.i_eth_txbuf_empty,
--
--probe0(2)           => i_dbg.swt.ethio_rx_axi_tvalid,
--probe0(4 downto 3)  => i_dbg.swt.ethio_rx_axi_tuser,
--probe0(68 downto 5) => i_dbg.swt.ethio_rx_axi_tdata,
--probe0(76 downto 69)=> i_dbg.swt.ethio_rx_axi_tkeep,
--
--probe0(79 downto 77)   => i_dbg.eth.rx.fsm,
--probe0(80)           => i_dbg.swt.fgbuf_fltr_den,
--probe0(86 downto 81) => (others => '0')
--
----probe0(80)             => i_dbg.eth.rx.mac_tuser ,
----probe0(81)             => i_dbg.eth.rx.mac_tvalid,
----probe0(82)             => i_dbg.eth.rx.mac_tlast ,
----probe0(146 downto 83)  => i_dbg.eth.rx.mac_tdata ,
----probe0(154 downto 147) => i_dbg.eth.rx.mac_tkeep
--
--
----probe0(157 downto 155) => i_dbg.eth.tx.fsm,
----
----probe0(158)            => i_dbg.eth.tx.mac_tready,
----probe0(159)            => i_dbg.eth.tx.mac_tvalid,
----probe0(160)            => i_dbg.eth.tx.mac_tlast ,
----probe0(224 downto 161) => i_dbg.eth.tx.mac_tdata ,
----probe0(232 downto 225) => i_dbg.eth.tx.mac_tkeep ,
----
----probe0(233)            => i_dbg.eth.tx.fifo_tready,
----probe0(234)            => i_dbg.eth.tx.fifo_tvalid,
----probe0(235)            => i_dbg.eth.tx.fifo_tlast ,
----probe0(299 downto 236) => i_dbg.eth.tx.fifo_tdata ,
----probe0(307 downto 300) => i_dbg.eth.tx.fifo_tkeep
--
--);
--
----end generate gen_dbgcs_on;


--m_dbg_swt : dbgcs_ila_usr_highclk
--port map (
--clk => i_ethio_clk(0),
--
--probe0(0)           => i_dbg.swt.ethio_rx_axi_tvalid,
--probe0(2 downto 1)  => i_dbg.swt.ethio_rx_axi_tuser,
--probe0(66 downto 3) => i_dbg.swt.ethio_rx_axi_tdata,
--probe0(74 downto 67)=> i_dbg.swt.ethio_rx_axi_tkeep,
--
--probe0(138 downto 75)=> i_dbg.swt.ethio_tx_axi_tdata ,
--probe0(139)          => i_dbg.swt.ethio_tx_axi_tready,
--probe0(140)          => i_dbg.swt.ethio_tx_axi_tvalid,
--probe0(141)          => i_dbg.swt.ethio_tx_axi_done  ,
--
--probe0(142)          => i_dbg.swt.h2eth_buf_empty
--);

m_dbg_eth0 : dbgcs_ila_usr_highclk
port map (
clk => i_ethio_clk(0),

probe0(0)              => i_dbg.swt.ethio_rx_axi_tvalid  ,--i_dbg.eth.rx(0).mac_tvalid,--
probe0(1)              => i_dbg.swt.ethio_rx_axi_tuser(0),--i_dbg.eth.rx(0).mac_tuser ,--
probe0(65 downto 2)    => i_dbg.swt.ethio_rx_axi_tdata   ,--i_dbg.eth.rx(0).mac_tdata ,--
probe0(73 downto 66)   => i_dbg.swt.ethio_rx_axi_tkeep   ,--i_dbg.eth.rx(0).mac_tkeep ,--
probe0(74)             => i_dbg.swt.ethio_rx_axi_tuser(1),--i_dbg.eth.rx(0).mac_tlast ,--

probe0(138 downto 75)  => i_dbg.eth.tx(0).mac_tdata ,
probe0(139)            => i_dbg.eth.tx(0).mac_tready,
probe0(140)            => i_dbg.eth.tx(0).mac_tvalid,
probe0(141)            => i_dbg.eth.tx(0).mac_tlast ,
probe0(149 downto 142) => i_dbg.eth.tx(0).mac_tkeep ,

probe0(152 downto 150) => i_dbg.eth.rx(0).fsm,
probe0(155 downto 153) => i_dbg.eth.tx(0).fsm,
probe0(156)            => i_dbg.eth_link(0) --i_dbg.vpkt_padding
);

m_dbg_eth1 : dbgcs_ila_usr_highclk
port map (
clk => i_ethio_clk(1),

probe0(0)              => i_dbg.eth.rx(1).mac_tvalid,
probe0(1)              => i_dbg.eth.rx(1).mac_tuser ,
probe0(65 downto 2)    => i_dbg.eth.rx(1).mac_tdata ,
probe0(73 downto 66)   => i_dbg.eth.rx(1).mac_tkeep ,
probe0(74)             => i_dbg.eth.rx(1).mac_tlast ,

probe0(138 downto 75)  => i_dbg.eth.tx(1).mac_tdata ,
probe0(139)            => i_dbg.eth.tx(1).mac_tready,
probe0(140)            => i_dbg.eth.tx(1).mac_tvalid,
probe0(141)            => i_dbg.eth.tx(1).mac_tlast ,
probe0(149 downto 142) => i_dbg.eth.tx(1).mac_tkeep ,

probe0(152 downto 150) => i_dbg.eth.rx(1).fsm,
probe0(155 downto 153) => i_dbg.eth.tx(1).fsm,
probe0(156)            => i_dbg.eth_link(1) --i_dbg.vpkt_padding
);

--m_dbg_fg : dbgcs_ila_hostclk
--port map (
--clk => g_usr_highclk,
--
--probe0(2 downto 0)   => i_dbg.fg.fgrd_vch         ,
--probe0(3)            => i_dbg.fg.fgrd_rddone      ,
--probe0(5 downto 4)   => i_dbg.fg.fgwr_frrdy       ,
--probe0(7 downto 6)   => i_dbg.fg.irq              ,
--probe0(9 downto 8)   => i_dbg.fg.vbuf_hold        ,
--probe0(11 downto 10) => i_dbg.fg.err_vbuf_overflow,
--probe0(14 downto 12) => i_dbg.fg.frskip0_count    ,
--probe0(17 downto 15) => i_dbg.fg.frskip1_count    ,
--
--probe0(19 downto 18) => i_dbg.fg.vbufi_full       ,
--probe0(21 downto 20) => i_dbg.fg.vbufi_pfull      ,
--
--probe0(24 downto 22) => i_dbg.fg.fgwr.fsm,
--probe0(35 downto 25) => i_dbg.fg.fgwr.fr_rownum,
--probe0(36) => i_dbg.fg.fgwr.vbufi_sel,
--probe0(38 downto 37) => i_dbg.fg.fgwr.vbufi_empty
--
--
----probe0(31 downto 0) => i_dbg.fg.fgwr.vbufi_do(0),
----probe0(63 downto 32) => i_dbg.fg.fgwr.vbufi_do(1),
----probe0(66 downto 64) => i_dbg.fg.fgwr.fsm,
----probe0(77 downto 67) => i_dbg.fg.fgwr.fr_rownum,
----probe0(78) => i_dbg.fg.fgwr.mem_start,
----probe0(79) => i_dbg.fg.fgwr.mem_done,
----probe0(80) => i_dbg.fg.fgwr.err,
----probe0(81) => i_dbg.fg.fgwr.vbufi_sel,
----probe0(82) => i_dbg.fg.fgwr.vbufi_empty_all,
----probe0(83) => i_dbg.fg.fgwr.fr_rdy0,
----probe0(84) => i_dbg.fg.fgwr.vbufi_full_det,
----probe0(85) => i_dbg.fg.fgwr.vbufi_rd(0),
----probe0(86) => i_dbg.fg.fgwr.vbufi_empty(0),
----probe0(87) => i_dbg.fg.fgwr.vbufi_full(0),
----
----probe0(91 downto 88)   => i_dbg.fg.fgrd.fsm            ,
----probe0(94 downto 92)   => i_dbg.fg.fgrd.vch_num        ,
----probe0(95)             => i_dbg.fg.fgrd.hrd_start      ,
----probe0(111 downto 96)  => i_dbg.fg.fgrd.fr_act_pixcount,
----probe0(127 downto 112) => i_dbg.fg.fgrd.fr_act_rowcount,
----probe0(143 downto 128) => i_dbg.fg.fgrd.steprd,
----probe0(159 downto 144) => i_dbg.fg.fgrd.fr_skp_pixcount,
----probe0(175 downto 160) => i_dbg.fg.fgrd.fr_skp_rowcount,
----probe0(176)            => i_dbg.fg.fgrd.mirror_pix     ,
----probe0(177)            => i_dbg.fg.fgrd.mirror_row     ,
----
----probe0(193 downto 178) => i_dbg.fg.fgrd.rowcnt,
----probe0(194) => i_dbg.fg.fgrd.hrd_done,
----probe0(195) => i_dbg.fg.fgrd.bufo_empty,
----probe0(198 downto 196) => i_dbg.fg.fgrd.vbuf_hold,
----probe0(199) => i_dbg.fg.fgrd.axir_dvalid
--);

m_dbg_fg : dbgcs_ila_hostclk
port map (
clk => g_usr_highclk,

probe0(2 downto 0)   => i_dbg.fg.fgrd_vch         ,
probe0(3)            => i_dbg.fg.fgrd_rddone      ,
probe0(5 downto 4)   => i_dbg.fg.fgwr_frrdy       ,
probe0(7 downto 6)   => i_dbg.fg.irq              ,
probe0(9 downto 8)   => i_dbg.fg.vbuf_hold        ,
probe0(11 downto 10) => i_dbg.fg.err_vbuf_overflow,
probe0(14 downto 12) => i_dbg.fg.frskip0_count    ,
probe0(17 downto 15) => i_dbg.fg.frskip1_count    ,

probe0(19 downto 18) => i_dbg.fg.vbufi_full       ,
probe0(21 downto 20) => i_dbg.fg.fgwr.vbufi_full_det,

probe0(24 downto 22) => i_dbg.fg.fgwr.fsm,
probe0(37 downto 25) => i_dbg.fg.fgwr.fr_rownum,
probe0(39 downto 38) => i_dbg.fg.fgwr.vbufi_empty,
probe0(42 downto 40) => i_dbg.fg.fgwr.fsm1,
probe0(55 downto 43) => i_dbg.fg.fgwr.fr_rownum1


--probe0(31 downto 0) => i_dbg.fg.fgwr.vbufi_do(0),
--probe0(63 downto 32) => i_dbg.fg.fgwr.vbufi_do(1),
--probe0(66 downto 64) => i_dbg.fg.fgwr.fsm,
--probe0(77 downto 67) => i_dbg.fg.fgwr.fr_rownum,
--probe0(78) => i_dbg.fg.fgwr.mem_start,
--probe0(79) => i_dbg.fg.fgwr.mem_done,
--probe0(80) => i_dbg.fg.fgwr.err,
--probe0(81) => i_dbg.fg.fgwr.vbufi_sel,
--probe0(82) => i_dbg.fg.fgwr.vbufi_empty_all,
--probe0(83) => i_dbg.fg.fgwr.fr_rdy0,
--probe0(84) => i_dbg.fg.fgwr.vbufi_full_det,
--probe0(85) => i_dbg.fg.fgwr.vbufi_rd(0),
--probe0(86) => i_dbg.fg.fgwr.vbufi_empty(0),
--probe0(87) => i_dbg.fg.fgwr.vbufi_full(0),
--
--probe0(91 downto 88)   => i_dbg.fg.fgrd.fsm            ,
--probe0(94 downto 92)   => i_dbg.fg.fgrd.vch_num        ,
--probe0(95)             => i_dbg.fg.fgrd.hrd_start      ,
--probe0(111 downto 96)  => i_dbg.fg.fgrd.fr_act_pixcount,
--probe0(127 downto 112) => i_dbg.fg.fgrd.fr_act_rowcount,
--probe0(143 downto 128) => i_dbg.fg.fgrd.steprd,
--probe0(159 downto 144) => i_dbg.fg.fgrd.fr_skp_pixcount,
--probe0(175 downto 160) => i_dbg.fg.fgrd.fr_skp_rowcount,
--probe0(176)            => i_dbg.fg.fgrd.mirror_pix     ,
--probe0(177)            => i_dbg.fg.fgrd.mirror_row     ,
--
--probe0(193 downto 178) => i_dbg.fg.fgrd.rowcnt,
--probe0(194) => i_dbg.fg.fgrd.hrd_done,
--probe0(195) => i_dbg.fg.fgrd.bufo_empty,
--probe0(198 downto 196) => i_dbg.fg.fgrd.vbuf_hold,
--probe0(199) => i_dbg.fg.fgrd.axir_dvalid
);

--m_dbg_fg : dbgcs_ila_hostclk
--port map (
--clk => g_usr_highclk,
--
--probe0(31 downto 0) => i_dbg.fg.fgwr.axiw_d,
--probe0(63 downto 32) => i_dbg.fg.fgrd.axir_d,
--probe0(66 downto 64) => i_dbg.fg.fgwr.fsm,
--probe0(79 downto 67) => i_dbg.fg.fgwr.fr_rownum,
--probe0(80) => i_dbg.fg.fgwr.axiw_dvalid, --i_dbg.fg.fgwr.mem_start,
--probe0(81) => i_dbg.fg.fgwr.axiw_dlast , --i_dbg.fg.fgwr.mem_done,
--probe0(82) => i_dbg.fg.fgwr.err,
--probe0(83) => i_dbg.fg.fgwr.vbufi_sel,
--probe0(84) => i_dbg.fg.fgwr.vbufi_empty_all,
--probe0(85) => i_dbg.fg.fgwr.fr_rdy0,
--probe0(86) => i_dbg.fg.fgwr.vbufi_full_det,
--probe0(87) => i_dbg.fg.fgrd.bufo_empty,--i_dbg.fg.fgwr.vbufi_rd(0),
--probe0(88) => i_dbg.fg.fgwr.vbufi_empty(0),
--probe0(89) => i_dbg.fg.fgwr.vbufi_full(0),
--
--probe0(93 downto 90)   => i_dbg.fg.fgrd.fsm            ,
--probe0(96 downto 94)   => i_dbg.fg.fgrd.vch_num        ,
--probe0(97)             => i_dbg.fg.fgrd.hrd_start      ,
--probe0(113 downto 98)  => i_dbg.fg.fgrd.rowcnt, --i_dbg.fg.fgrd.fr_act_pixcount,
--probe0(114) => i_dbg.fg.fgrd.axir_dvalid,
--probe0(115) => i_dbg.fg.fgrd.axir_dlast ,
--
--probe0(146 downto 116) => i_dbg.fg.fgrd.axir_adr,
--probe0(177 downto 147) => i_dbg.fg.fgwr.axiw_adr,
--probe0(178) => i_dbg.fg.fgrd.hrd_done
--);

--m_dbg_fg : dbgcs_ila_hostclk
--port map (
--clk => g_usr_highclk,
--
--probe0(15 downto 0)  => i_dbg.fg.fgrd.fr_act_pixcount,
--probe0(31 downto 16) => i_dbg.fg.fgrd.fr_act_rowcount,
--probe0(47 downto 32) => i_dbg.fg.fgrd.fr_skp_pixcount,
--probe0(63 downto 48) => i_dbg.fg.fgrd.fr_skp_rowcount,
--probe0(66 downto 64) => i_dbg.fg.fgwr.fsm,
--probe0(77 downto 67) => i_dbg.fg.fgwr.fr_rownum,
--probe0(78) => i_dbg.fg.fgrd.axir_dvalid,
--probe0(79) => i_dbg.fg.fgwr.axiw_dvalid,
--probe0(80) => i_dbg.fg.fgwr.err,
--probe0(81) => i_dbg.fg.fgwr.vbufi_sel,
--probe0(82) => i_dbg.fg.fgwr.vbufi_empty_all,
--probe0(83) => i_dbg.fg.fgwr.fr_rdy0,
--probe0(84) => i_dbg.fg.fgwr.vbufi_full_det,
----probe0(85) => i_dbg.fg.fgwr.vbufi_rd(0),
--probe0(85) => i_dbg.fg.fgrd.hrd_done,
--probe0(86) => i_dbg.fg.fgwr.vbufi_empty(0),
--probe0(87) => i_dbg.fg.fgwr.vbufi_full(0),
--
--probe0(91 downto 88)   => i_dbg.fg.fgrd.fsm            ,
--probe0(94 downto 92)   => i_dbg.fg.fgrd.vch_num        ,
--probe0(95)             => i_dbg.fg.fgrd.hrd_start      ,
--probe0(111 downto 96) => i_dbg.fg.fgrd.steprd,
--
--probe0(112)            => i_dbg.fg.fgrd.mirror_pix     ,
--probe0(113)            => i_dbg.fg.fgrd.mirror_row     ,
--
--probe0(114) => i_dbg.fg.fgrd.bufo_empty,
--probe0(130 downto 115) => i_dbg.fg.fgrd.rowcnt,
--probe0(132 downto 131) => i_dbg.fg.fgrd.vbuf_hold,
--probe0(133) => '0'
--
--);


--m_dbg_pci : dbgcs_ila_hostclk
--port map (
--clk => g_host_clk,
--
--probe0(3 downto 0) => i_dbg.pcie.dev_num   ,
--probe0(4)          => i_dbg.pcie.dma_dir   ,
--probe0(12 downto 5)=> i_dbg.pcie.dma_bufnum,
--probe0(13)         => i_dbg.pcie.dma_done  ,
--probe0(14)         => i_dbg.pcie.dma_init  ,
--probe0(15)         => i_dbg.pcie.dma_work  ,
--probe0(16) => i_dbg.pcie.test_speed,
--
----PCIE<-FPGA (DMA_WR/RD)
--probe0(17) => i_dbg.pcie.axi_rq_tready,
--probe0(18) => i_dbg.pcie.axi_rq_tvalid,
--probe0(19) => i_dbg.pcie.axi_rq_tlast ,
--
----PCIE->FPGA (USR_WR/RD)
--probe0(20) => i_dbg.pcie.axi_cq_tready,
--probe0(21) => i_dbg.pcie.axi_cq_tvalid,
--probe0(22) => i_dbg.pcie.axi_cq_tlast ,
--
----PCIE->FPGA (DMA_RD(CPL))
--probe0(23) => i_dbg.pcie.axi_rc_tready,
--probe0(24) => i_dbg.pcie.axi_rc_tvalid,
--probe0(25) => i_dbg.pcie.axi_rc_tlast ,
--
----PCIE<-FPGA (USR_RD(CPL))
--probe0(26) => i_dbg.pcie.axi_cc_tready,
--probe0(27) => i_dbg.pcie.axi_cc_tvalid,
--probe0(28) => i_dbg.pcie.axi_cc_tlast ,
--
--probe0(29) => i_dbg.pcie.req_compl,
--probe0(30) => i_dbg.pcie.compl_done,
--
--probe0(31) => i_dbg.pcie.d2h_buf_rd,
--probe0(32) => i_dbg.pcie.d2h_buf_empty,
--
--probe0(33) => i_dbg.pcie.h2d_buf_wr,
--probe0(34) => i_dbg.pcie.h2d_buf_full,
--
--probe0(35) => i_dbg.pcie.irq_int,
--probe0(36) => i_dbg.pcie.irq_pending,
--probe0(37) => i_dbg.pcie.irq_sent,
----probe0(37) => i_dbg.pcie.axi_rc_err_detect,
----
--probe0(69 downto 38) => i_dbg.pcie.axi_rq_tdata(0),
--probe0(101 downto 70) => i_dbg.pcie.axi_rq_tdata(1),
--probe0(133 downto 102) => i_dbg.pcie.axi_rq_tdata(2),
--
--probe0(136 downto 134) => i_dbg.pcie.irq_set
--
----probe0(137 downto 134) => i_dbg.pcie.axi_cc_tkeep(3 downto 0),
----probe0(141 downto 138) => i_dbg.pcie.axi_rc_tkeep(3 downto 0),
----probe0(145 downto 142) => i_dbg.pcie.axi_rq_tkeep(3 downto 0),
----
----probe0(148 downto 146) => i_dbg.pcie.axi_rc_fsm,
----probe0(174 downto 149) => i_dbg.pcie.dma_mrd_rxdwcount(25 downto 0),
----probe0(180 downto 175) => i_dbg.pcie.axi_rc_err(6 downto 0),
------probe0(180 downto 149) => i_dbg.pcie.dma_mrd_rxdwcount,
------probe0(180 downto 149) => i_dbg.pcie.axi_rc_err,
----
----probe0(212 downto 181) => i_dbg.pcie.axi_rc_tdata(0),
----probe0(244 downto 213) => i_dbg.pcie.axi_rc_tdata(1),
----probe0(276 downto 245) => i_dbg.pcie.axi_rc_tdata(2),
----probe0(277) => i_dbg.pcie.axi_rc_sof(0),
----probe0(278) => i_dbg.pcie.axi_rc_discon
--);



end architecture struct;

