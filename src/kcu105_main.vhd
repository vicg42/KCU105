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
use work.cfgdev_pkg.all;
use work.fg_pkg.all;


entity kcu105_main is
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_in_btn          : in    std_logic_vector(4 downto 0);
pin_out_led         : out   std_logic_vector(7 downto 0);

--------------------------------------------------
--FMC
--------------------------------------------------
pin_out_led_hpc     : out   std_logic_vector(3 downto 0);
pin_out_led_lpc     : out   std_logic_vector(3 downto 0);

--------------------------------------------------
--RAM
--------------------------------------------------
pin_out_phymem      : out   TMEMCTRL_pinouts;
pin_inout_phymem    : inout TMEMCTRL_pininouts;
pin_in_phymem       : in    TMEMCTRL_pinins;

--------------------------------------------------
--PCIE
--------------------------------------------------
pin_in_pcie_phy     : in    TPCIE_pinin;
pin_out_pcie_phy    : out   TPCIE_pinout;

--------------------------------------------------
--Reference clock
--------------------------------------------------
pin_in_refclk       : in    TRefClkPinIN
);
end entity kcu105_main;

architecture struct of kcu105_main is

signal i_glob_rst                       : std_logic;
signal i_usrclk_rst                     : std_logic;
signal g_usrclk                         : std_logic_vector(7 downto 0);
signal g_usr_highclk                    : std_logic;

signal i_host_rst_n                     : std_logic;
signal g_host_clk                       : std_logic;
signal i_host_gctrl                     : std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);
signal i_host_dev_ctrl                  : std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
signal i_host_dev_txd                   : std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_dev_rxd                   : std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_dev_wr                    : std_logic;
signal i_host_dev_rd                    : std_logic;
signal i_host_dev_status                : std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto C_HREG_DEV_STATUS_FST_BIT);
signal i_host_dev_irq                   : std_logic_vector((C_HIRQ_COUNT - 1) downto C_HIRQ_FST_BIT);
signal i_host_dev_opt_in                : std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto C_HDEV_OPTIN_FST_BIT);
signal i_host_dev_opt_out               : std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto C_HDEV_OPTOUT_FST_BIT);

signal i_host_devadr                    : unsigned(C_HREG_DEV_CTRL_ADR_M_BIT
                                                              - C_HREG_DEV_CTRL_ADR_L_BIT downto 0);

Type THostDCtrl is array (0 to C_HDEV_COUNT - 1) of std_logic;
Type THostDWR is array (0 to C_HDEV_COUNT - 1) of std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
signal i_host_wr                        : THostDCtrl;
signal i_host_rd                        : THostDCtrl;
signal i_host_txd                       : THostDWR;
signal i_host_rxd                       : THostDWR;
signal i_host_rxbuf_full                : THostDCtrl;
signal i_host_rxbuf_empty               : THostDCtrl;
signal i_host_txbuf_full                : THostDCtrl;
signal i_host_txbuf_empty               : THostDCtrl;
--signal i_host_txd_rdy                   : THostDCtrl;

signal i_host_tst_in                    : std_logic_vector(127 downto 0);
signal i_host_tst_out                   : std_logic_vector(127 downto 0);
signal i_host_tst2_out                  : std_logic_vector(255 downto 0);
signal i_host_dbg                       : TPCIE_dbg;

constant CI_CFG_DWIDTH                  : integer := 16;--bit
signal i_cfg_rst                        : std_logic;
signal i_cfg_dadr                       : std_logic_vector(C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT downto 0);
signal i_cfg_radr                       : std_logic_vector(C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT downto 0);
signal i_cfg_radr_ld                    : std_logic;
signal i_cfg_radr_fifo                  : std_logic;
signal i_cfg_wr                         : std_logic;
signal i_cfg_rd                         : std_logic;
signal i_cfg_txd                        : std_logic_vector(CI_CFG_DWIDTH - 1 downto 0);
signal i_cfg_rxd                        : std_logic_vector(CI_CFG_DWIDTH - 1 downto 0);
Type TCfgRxD is array (0 to C_CFGDEV_COUNT - 1) of std_logic_vector(i_cfg_rxd'range);
signal i_cfg_rxd_dev                    : TCfgRxD;
signal i_cfg_done                       : std_logic;
signal i_cfg_wr_dev                     : std_logic_vector(C_CFGDEV_COUNT - 1 downto 0);
signal i_cfg_rd_dev                     : std_logic_vector(C_CFGDEV_COUNT - 1 downto 0);
signal i_cfg_done_dev                   : std_logic_vector(C_CFGDEV_COUNT - 1 downto 0);
signal i_cfg_tst_out                    : std_logic_vector(31 downto 0);

signal i_tmr_rst                        : std_logic;
signal i_tmr_hirq                       : std_logic_vector(C_TMR_COUNT - 1 downto 0);
signal i_tmr_en                         : std_logic_vector(C_TMR_COUNT - 1 downto 0);

signal i_host_mem_ctrl                  : TPce2Mem_Ctrl;
signal i_host_mem_status                : TPce2Mem_Status;
signal i_host_mem_tst_out               : std_logic_vector(31 downto 0);

signal i_memin_fgwrch                   : TMemINChVD;
signal i_memout_fgwrch                  : TMemOUTChVD;
signal i_memin_ch                       : TMemINCh;
signal i_memout_ch                      : TMemOUTCh;
signal i_memin_bank                     : TMemINBank;
signal i_memout_bank                    : TMemOUTBank;

signal i_arb_mem_rst                    : std_logic;
signal i_arb_memin                      : TMemIN;
signal i_arb_memout                     : TMemOUT;
signal i_arb_mem_tst_out                : std_logic_vector(31 downto 0);

signal i_mem_ctrl_status                : TMEMCTRL_status;
signal i_mem_ctrl_sysout                : TMEMCTRL_sysout;

signal i_fgwr_chen                      : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_fr_rd_start                    : std_logic;
signal i_fg_vbufi                       : TFGWR_VBUFIs;
signal i_fg_tst_in                      : std_logic_vector(31 downto 0);
signal i_fg_tst_out                     : std_logic_vector(31 downto 0);

signal i_test_led          : std_logic_vector(0 downto 0);
signal sr_host_rst_n       : std_logic_vector(0 to 2) := (others => '1');
signal i_det_pcie_rst      : std_logic := '0';

signal i_reg_adr  : unsigned(3 downto 0);
signal i_reg_ctrl : std_logic_vector(15 downto 0);
signal i_reg_tst0 : std_logic_vector(15 downto 0);
signal i_reg_mem  : std_logic_vector(15 downto 0);

component dbgcs_ila_hostclk is
port (
clk : in std_logic;
probe0 : in std_logic_vector(36 downto 0)
);
end component dbgcs_ila_hostclk;

component dbgcs_ila_usr_highclk is
port (
clk : in std_logic;
probe0 : in std_logic_vector(79 downto 0)
);
end component dbgcs_ila_usr_highclk;

type TH2M_dbg is record
mem_start   : std_logic;
mem_done    : std_logic;
mem_wr_fsm  : std_logic_vector(3 downto 0);
--d2h_buf_di    : std_logic_vector(31 downto 0);
d2h_buf_wr    : std_logic;
d2h_buf_empty : std_logic;
d2h_buf_full  : std_logic;
--h2d_buf_do    : std_logic_vector(31 downto 0);
h2d_buf_rd    : std_logic;
h2d_buf_empty : std_logic;
h2d_buf_full  : std_logic;

--DEV -> MEM
axiw_d      : std_logic_vector(31 downto 0);
axiw_dvalid : std_logic;
axiw_dvlast : std_logic;

--DEV <- MEM
axir_d      : std_logic_vector(31 downto 0);
axir_dvalid : std_logic;
axir_dvlast : std_logic;

end record;

type TMAIN_dbg is record
pcie : TPCIE_dbg;
--h2m  : TH2M_dbg;
end record;

signal i_dbg    : TMAIN_dbg;

--attribute mark_debug : string;
--attribute mark_debug of i_dbg  : signal is "true";


begin --architecture struct


--***********************************************************
--RESET
--***********************************************************
i_glob_rst <= i_host_gctrl(C_HREG_CTRL_RST_MEM_BIT);--or i_host_gctrl(C_HREG_CTRL_RST_ALL_BIT) not i_host_rst_n or
i_arb_mem_rst <= not OR_reduce(i_mem_ctrl_status.rdy);


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

g_usr_highclk <= i_mem_ctrl_sysout.clk;


--***********************************************************
--
--***********************************************************
m_cfg : cfgdev_host
generic map(
G_DBG => "OFF",
G_HOST_DWIDTH  => C_HDEV_DWIDTH,
G_CFG_DWIDTH => CI_CFG_DWIDTH
)
port map(
-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_htxbuf_di       => i_host_txd(C_HDEV_CFG),
p_in_htxbuf_wr       => i_host_wr(C_HDEV_CFG),
p_out_htxbuf_full    => i_host_txbuf_full(C_HDEV_CFG),
p_out_htxbuf_empty   => i_host_txbuf_empty(C_HDEV_CFG),

--host <- dev
p_out_hrxbuf_do      => i_host_rxd(C_HDEV_CFG),
p_in_hrxbuf_rd       => i_host_rd(C_HDEV_CFG),
p_out_hrxbuf_full    => open,
p_out_hrxbuf_empty   => i_host_rxbuf_empty(C_HDEV_CFG),

p_out_hirq           => i_host_dev_irq(C_HIRQ_CFG),
p_in_hclk            => g_host_clk,

-------------------------------
--CFG
-------------------------------
p_out_cfg_dadr       => i_cfg_dadr,
p_out_cfg_radr       => i_cfg_radr,
p_out_cfg_radr_ld    => i_cfg_radr_ld,
p_out_cfg_radr_fifo  => i_cfg_radr_fifo,

p_out_cfg_txdata     => i_cfg_txd,
p_out_cfg_wr         => i_cfg_wr,
p_in_cfg_txbuf_full  => '0',
p_in_cfg_txbuf_empty => '0',

p_in_cfg_rxdata      => i_cfg_rxd,
p_out_cfg_rd         => i_cfg_rd,
p_in_cfg_rxbuf_full  => '0',
p_in_cfg_rxbuf_empty => '0',

p_out_cfg_done       => i_cfg_done,
p_in_cfg_clk         => g_host_clk,

-------------------------------
--DBG
-------------------------------
p_in_tst             => (others => '0'),
p_out_tst            => i_cfg_tst_out,

-------------------------------
--System
-------------------------------
p_in_rst             => i_glob_rst
);

i_cfg_rxd <= i_cfg_rxd_dev(C_CFGDEV_SWT);

gen_cfg_dev : for i in 0 to C_CFGDEV_COUNT - 1 generate
i_cfg_wr_dev(i)   <= i_cfg_wr   when UNSIGNED(i_cfg_dadr) = i else '0';
i_cfg_rd_dev(i)   <= i_cfg_rd   when UNSIGNED(i_cfg_dadr) = i else '0';
i_cfg_done_dev(i) <= i_cfg_done when UNSIGNED(i_cfg_dadr) = i else '0';
end generate gen_cfg_dev;


--#########################################
--Switch
--#########################################
m_switch : switch_data
generic map(
--G_ETH_CH_COUNT => ,--: integer:=1;
G_ETH_DWIDTH   => C_HDEV_DWIDTH, --C_AXIS_DWIDTH(2),
G_VBUFI_OWIDTH => C_AXIS_DWIDTH(2),
G_HOST_DWIDTH  => C_HDEV_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk      => g_host_clk,

p_in_cfg_adr      => i_cfg_radr(7 downto 0),
p_in_cfg_adr_ld   => i_cfg_radr_ld,
p_in_cfg_adr_fifo => i_cfg_radr_fifo,

p_in_cfg_txdata   => i_cfg_txd,
p_in_cfg_wd       => i_cfg_wr_dev(C_CFGDEV_SWT),

p_out_cfg_rxdata  => i_cfg_rxd_dev(C_CFGDEV_SWT),
p_in_cfg_rd       => i_cfg_rd_dev(C_CFGDEV_SWT),

p_in_cfg_done     => i_cfg_done_dev(C_CFGDEV_SWT),

---------------------------------
----HOST
---------------------------------
----host -> dev
--p_in_eth_htxbuf_di     => i_host_txd(C_HDEV_ETH),
--p_in_eth_htxbuf_wr     => i_host_wr(C_HDEV_ETH),
--p_out_eth_htxbuf_full  => i_host_txbuf_full(C_HDEV_ETH),
--p_out_eth_htxbuf_empty => i_host_txbuf_empty(C_HDEV_ETH),
--
------host <- dev
----p_out_eth_hrxbuf_do    => i_host_rxd(C_HDEV_ETH),
----p_in_eth_hrxbuf_rd     => i_host_rd(C_HDEV_ETH),
----p_out_eth_hrxbuf_full  => i_host_rxbuf_full(C_HDEV_ETH),
----p_out_eth_hrxbuf_empty => i_host_rxbuf_empty(C_HDEV_ETH),
----
----p_out_eth_hirq         => i_host_dev_irq(C_HIRQ_ETH),
--
--p_in_hclk              => g_host_clk,
--
-----------------------------------
------ETH
-----------------------------------
----p_in_eth_tmr_irq       : in   std_logic;
----p_in_eth_tmr_en        : in   std_logic;
----p_in_eth_clk           : in   std_logic;
----p_in_eth               : in   TEthOUTs;
----p_out_eth              : out  TEthINs;
--
---------------------------------
----FG_BUFI
---------------------------------
--p_in_vbufi_rdclk  => g_usr_highclk,
--p_out_vbufi_do    => i_fg_bufi_do, --: out  std_logic_vector(G_VBUFI_OWIDTH - 1 downto 0);
--p_in_vbufi_rd     => i_fg_bufi_rd,
--p_out_vbufi_empty => i_fg_bufi_empty,
--p_out_vbufi_full  => i_fg_bufi_full,
--p_out_vbufi_pfull => i_fg_bufi_pfull,

-------------------------------
--DBG
-------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,

-------------------------------
--System
-------------------------------
p_in_rst  => i_arb_mem_rst
);


----#########################################
----Frame Grabber
----#########################################
--i_fg_rd_start <= i_host_dev_ctrl(C_HREG_DEV_CTRL_DMA_START_BIT)
--                  when i_host_devadr = TO_UNSIGNED(C_HDEV_FG, i_host_devadr'length) else '0';
--
--m_fg : fg
--generic map(
--G_DBGCS => "OFF",
--G_MEM_AWIDTH => C_AXI_AWIDTH,
--G_MEMWR_DWIDTH => C_AXIS_DWIDTH(2),
--G_MEMRD_DWIDTH => C_HDEV_DWIDTH
--)
--port map(
---------------------------------
----CFG
---------------------------------
--p_in_cfg_clk      => g_host_clk,
--
--p_in_cfg_adr      => i_cfg_radr(3 downto 0),
--p_in_cfg_adr_ld   => i_cfg_radr_ld,
--p_in_cfg_adr_fifo => i_cfg_radr_fifo,
--
--p_in_cfg_txdata   => i_cfg_txd,
--p_in_cfg_wd       => i_cfg_wr_dev(C_CFGDEV_FG),
--
--p_out_cfg_rxdata  => i_cfg_rxd_dev(C_CFGDEV_FG),
--p_in_cfg_rd       => i_cfg_rd_dev(C_CFGDEV_FG),
--
--p_in_cfg_done     => i_cfg_done_dev(C_CFGDEV_FG),
--
---------------------------------
----HOST
---------------------------------
--p_in_hrdchsel     => i_host_dev_ctrl(C_HREG_DEV_CTRL_FG_CH_M_BIT downto C_HREG_DEV_CTRL_FG_CH_L_BIT),
--p_in_hrdstart     => i_fg_rd_start,
--p_in_hrddone      => i_host_gctrl(C_HREG_CTRL_FG_RDDONE_BIT),
--p_out_hirq        => i_host_dev_irq((C_HIRQ_FG_VCH0 + C_FG_VCH_COUNT) - 1 downto C_HIRQ_FG_VCH0),
--p_out_hdrdy       => i_host_dev_status((C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT
--                                        + C_FG_VCH_COUNT) - 1 downto C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT),
--p_out_hfrmrk      => i_host_dev_opt_in(C_HDEV_OPTIN_FG_FRMRK_M_BIT downto C_HDEV_OPTIN_FG_FRMRK_L_BIT),
--
----HOST <- MEM(VBUF)
--p_in_vbufo_rdclk  => g_host_clk,
--p_out_vbufo_do    => i_host_rxd(C_HDEV_FG),
--p_in_vbufo_rd     => i_host_rd(C_HDEV_FG),
--p_out_vbufo_empty => i_host_rxbuf_empty(C_HDEV_FG),
--
---------------------------------
----VBUFI -> MEM(VBUF)
---------------------------------
--p_in_vbufi_do     => i_fg_bufi_do,
--p_out_vbufi_rd    => i_fg_bufi_rd,
--p_in_vbufi_empty  => i_fg_bufi_empty,
--p_in_vbufi_full   => i_fg_bufi_full,
--p_in_vbufi_pfull  => i_fg_bufi_pfull,
--
-----------------------------------
----MEM
-----------------------------------
----CH WRITE
--p_out_memwr       => i_memin_ch(2), --DEV -> MEM
--p_in_memwr        => i_memout_ch(2),--DEV <- MEM
----CH READ
--p_out_memrd       => i_memin_ch(1), --DEV -> MEM
--p_in_memrd        => i_memout_ch(1),--DEV <- MEM
--
---------------------------------
----DBG
---------------------------------
--p_in_tst          => (others => '0'),--i_fg_tst_in,
--p_out_tst         => i_fg_tst_out,
--
---------------------------------
----System
---------------------------------
--p_in_clk          => g_usr_highclk,
--p_in_rst          => i_arb_mem_rst
--);


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
p_out_dev_din   => i_host_dev_txd    ,
p_in_dev_dout   => i_host_dev_rxd    ,
p_out_dev_wr    => i_host_dev_wr     ,
p_out_dev_rd    => i_host_dev_rd     ,
p_in_dev_status => i_host_dev_status ,
p_in_dev_irq    => i_host_dev_irq    ,
p_in_dev_opt    => i_host_dev_opt_in ,
p_out_dev_opt   => i_host_dev_opt_out,

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst   => open           ,
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


i_host_devadr <= UNSIGNED(i_host_dev_ctrl(C_HREG_DEV_CTRL_ADR_M_BIT downto C_HREG_DEV_CTRL_ADR_L_BIT));

--Status User Devices
i_host_dev_status(C_HREG_DEV_STATUS_CFG_RDY_BIT) <= '1';
i_host_dev_status(C_HREG_DEV_STATUS_CFG_RXRDY_BIT) <= not i_host_rxbuf_empty(C_HDEV_CFG);
i_host_dev_status(C_HREG_DEV_STATUS_CFG_TXRDY_BIT) <= i_host_txbuf_empty(C_HDEV_CFG);

i_host_dev_status(C_HREG_DEV_STATUS_MEMCTRL_RDY_BIT) <= OR_reduce(i_mem_ctrl_status.rdy);

i_host_dev_status(C_HREG_DEV_STATUS_ETH_RDY_BIT) <= '1';--i_ethphy_out.rdy;
i_host_dev_status(C_HREG_DEV_STATUS_ETH_LINK_BIT) <= '1';--i_ethphy_out.link;
i_host_dev_status(C_HREG_DEV_STATUS_ETH_RXRDY_BIT) <= '0';--not i_host_rxbuf_empty(C_HDEV_ETH);
i_host_dev_status(C_HREG_DEV_STATUS_ETH_TXRDY_BIT) <= '1';--i_host_txbuf_empty(C_HDEV_ETH);

--Host Write/Read data of user devices
gen_dev_dbuf : for i in 0 to i_host_wr'length - 1 generate
begin
i_host_wr(i)  <= i_host_dev_wr when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_rd(i)  <= i_host_dev_rd when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_txd(i) <= i_host_dev_txd;
--i_host_txd_rdy(i) <= i_host_dev_ctrl(C_HREG_DEV_CTRL_DRDY_BIT) when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
end generate gen_dev_dbuf;

i_host_dev_rxd <= i_host_rxd(C_HDEV_CFG) when i_host_devadr = TO_UNSIGNED(C_HDEV_CFG, i_host_devadr'length) else
                  i_host_rxd(C_HDEV_MEM);
--                  i_host_rxd(C_HDEV_FG)  when i_host_devadr = TO_UNSIGNED(C_HDEV_FG, i_host_devadr'length) else

--Flags (Host <- User Devices)
i_host_dev_opt_in(C_HDEV_OPTIN_TXFIFO_FULL_BIT) <= i_host_txbuf_full(C_HDEV_MEM)
                                                    when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else '0';

i_host_dev_opt_in(C_HDEV_OPTIN_RXFIFO_EMPTY_BIT) <= i_host_rxbuf_empty(C_HDEV_MEM)
                                                    when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM , i_host_devadr'length) else '0';
--                                                    i_host_rxbuf_empty(C_HDEV_FG)
--                                                    when i_host_devadr = TO_UNSIGNED(C_HDEV_FG , i_host_devadr'length) else '0';

i_host_dev_opt_in(C_HDEV_OPTIN_MEM_DONE_BIT) <= i_host_mem_status.done;


--***********************************************************
--HOST <-> Memory
--***********************************************************
i_host_mem_ctrl.trnwr_len <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_TRNWR_LEN_M_BIT downto C_HDEV_OPTOUT_MEM_TRNWR_LEN_L_BIT);
i_host_mem_ctrl.trnrd_len <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_TRNRD_LEN_M_BIT downto C_HDEV_OPTOUT_MEM_TRNRD_LEN_L_BIT);
i_host_mem_ctrl.adr       <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_ADR_M_BIT downto C_HDEV_OPTOUT_MEM_ADR_L_BIT);
i_host_mem_ctrl.req_len   <= i_host_dev_opt_out(C_HDEV_OPTOUT_MEM_RQLEN_M_BIT downto C_HDEV_OPTOUT_MEM_RQLEN_L_BIT);
i_host_mem_ctrl.dir       <= not i_host_dev_ctrl(C_HREG_DEV_CTRL_DMA_DIR_BIT);
i_host_mem_ctrl.start     <= i_host_dev_ctrl(C_HREG_DEV_CTRL_DMA_START_BIT)
                                when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else '0';

m_host2mem : pcie2mem_ctrl
generic map(
G_MEM_AWIDTH     => C_HREG_MEM_ADR_LAST_BIT,
G_MEM_DWIDTH     => C_AXIS_DWIDTH(0),
G_MEM_BANK_M_BIT => C_HREG_MEM_ADR_BANK_M_BIT,
G_MEM_BANK_L_BIT => C_HREG_MEM_ADR_BANK_L_BIT,
G_DBG            => "OFF"
)
port map(
-------------------------------
--CTRL
-------------------------------
p_in_ctrl         => i_host_mem_ctrl,
p_out_status      => i_host_mem_status,

--host -> dev
p_in_htxbuf_di     => i_host_txd(C_HDEV_MEM),
p_in_htxbuf_wr     => i_host_wr(C_HDEV_MEM),
p_out_htxbuf_full  => i_host_txbuf_full(C_HDEV_MEM),
p_out_htxbuf_empty => open,

--host <- dev
p_out_hrxbuf_do    => i_host_rxd(C_HDEV_MEM),
p_in_hrxbuf_rd     => i_host_rd(C_HDEV_MEM),
p_out_hrxbuf_full  => open,
p_out_hrxbuf_empty => i_host_rxbuf_empty(C_HDEV_MEM),

p_in_hclk          => g_host_clk,

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem         => i_memin_ch(0), --DEV -> MEM
p_in_mem          => i_memout_ch(0),--DEV <- MEM

-------------------------------
--DBG
-------------------------------
p_in_tst          => (others => '0'),
p_out_tst         => i_host_mem_tst_out,

-------------------------------
--System
-------------------------------
p_in_clk         => g_usr_highclk,
p_in_rst         => i_arb_mem_rst
);



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

i_memin_bank(0) <= i_arb_memin;
i_arb_memout    <= i_memout_bank(0);

m_mem_ctrl : mem_ctrl
generic map(
G_SIM => "OFF"
)
port map(
------------------------------------
--USER Port
------------------------------------
p_in_mem   => i_memin_bank,
p_out_mem  => i_memout_bank,

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
p_in_rst        => i_glob_rst
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
p_out_1ms  => open,
p_out_1s   => open,
-------------------------------
--System
-------------------------------
p_in_clken => '1',
p_in_clk   => g_usrclk(0),
p_in_rst   => i_usrclk_rst
);

pin_out_led(0) <= i_test_led(0);
pin_out_led(1) <= i_host_tst2_out(0);--i_user_lnk_up
pin_out_led(2) <= OR_reduce(i_mem_ctrl_status.rdy);
pin_out_led(6 downto 3) <= pin_in_btn(3 downto 0);
pin_out_led(7) <= '0';--i_det_pcie_rst;


pin_out_led_hpc(0) <= i_test_led(0);
pin_out_led_hpc(1) <= i_test_led(0);
pin_out_led_hpc(2) <= i_test_led(0);
pin_out_led_hpc(3) <= i_test_led(0);

pin_out_led_lpc(0) <= i_test_led(0);
pin_out_led_lpc(1) <= i_test_led(0);
pin_out_led_lpc(2) <= i_test_led(0);
pin_out_led_lpc(3) <= i_test_led(0);


--process(g_usrclk(0))
--begin
--if rising_edge(g_usrclk(0)) then
--  sr_host_rst_n <= i_host_rst_n & sr_host_rst_n(0 to 1);
--
--  if (pin_in_btn(4) = '1' and i_det_pcie_rst = '1') then
--    i_det_pcie_rst <= '0';
--  elsif (sr_host_rst_n(1) = '1' and sr_host_rst_n(2) = '0') then
--    i_det_pcie_rst <= '1';
--  end if;
--
--end if;
--end process;



----adress
--process(g_host_clk)
--begin
--if rising_edge(g_host_clk) then
--  if i_glob_rst = '1' then
--    i_reg_adr <= (others => '0');
--  else
--    if i_cfg_radr_ld = '1' then
--      i_reg_adr <= UNSIGNED(i_cfg_radr(3 downto 0));
--    else
--      if i_cfg_radr_fifo = '0' and (i_cfg_wr_dev(C_CFGDEV_FG) = '1' or i_cfg_rd_dev(C_CFGDEV_FG) = '1') then
--        i_reg_adr <= i_reg_adr + 1;
--      end if;
--    end if;
--  end if;
--end if;
--end process;
--
----write registers
--process(g_host_clk)
--begin
--if rising_edge(g_host_clk) then
--  if i_glob_rst = '1' then
--    i_reg_ctrl <= (others => '0');
--    i_reg_tst0 <= (others => '0');
--    i_reg_mem <= (others => '0');
--
--  else
--
--    if i_cfg_wr_dev(C_CFGDEV_FG) = '1' then
--      if i_reg_adr = TO_UNSIGNED(C_FG_REG_CTRL, i_reg_adr'length) then
--        i_reg_ctrl <= i_cfg_txd;
--
--      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_MEM_CTRL, i_reg_adr'length) then
--        i_reg_mem <= i_cfg_txd;
--
--      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_TST0, i_reg_adr'length) then
--        i_reg_tst0 <= i_cfg_txd;
--
--      end if;
--    end if;
--
--  end if;
--end if;
--end process;
--
--i_cfg_rxd_dev(C_CFGDEV_FG)
--                  <= i_reg_ctrl when i_reg_adr = TO_UNSIGNED(C_FG_REG_CTRL, i_reg_adr'length) else
--                        i_reg_mem when i_reg_adr = TO_UNSIGNED(C_FG_REG_MEM_CTRL, i_reg_adr'length) else
--                          i_reg_tst0 when i_reg_adr = TO_UNSIGNED(C_FG_REG_TST0, i_reg_adr'length) else
--                            (others => '0');



----#############################################
----DBGCS
----#############################################
--gen_dbgcs_on : if strcmp(C_PCFG_MAIN_DBGCS, "ON") generate
--begin
--
--i_dbg.pcie <= i_host_dbg;
--
----i_dbg.h2m.mem_start   <= i_host_mem_tst_out(0)         ;-- <= i_mem_start;
----i_dbg.h2m.mem_done    <= i_host_mem_tst_out(1)         ;-- <= i_mem_done;
----i_dbg.h2m.mem_wr_fsm  <= i_host_mem_tst_out(5 downto 2);-- <= tst_mem_ctrl_out(5 downto 2);--m_mem_wr/tst_fsm_cs;
------i_dbg.h2m.d2h_buf_di    <= i_host_mem_tst_out(95 downto 64);-- <= i_rxbuf_din(31 downto 0);--RAM->PCIE
----i_dbg.h2m.d2h_buf_wr    <= i_host_mem_tst_out(10)          ;-- <= i_rxbuf_din_wr ;--RAM->PCIE
----i_dbg.h2m.d2h_buf_empty <= i_host_mem_tst_out(6)           ;-- <= i_rxbuf_empty;  --RAM->PCIE
----i_dbg.h2m.d2h_buf_full  <= i_host_mem_tst_out(7)           ;-- <= i_rxbuf_full;   --RAM->PCIE
------i_dbg.h2m.h2d_buf_do    <= i_host_mem_tst_out(63 downto 32);-- <= i_txbuf_dout(31 downto 0);--RAM<-PCIE
----i_dbg.h2m.h2d_buf_rd    <= i_host_mem_tst_out(11)          ;-- <= i_txbuf_dout_rd;--RAM<-PCIE
----i_dbg.h2m.h2d_buf_empty <= i_host_mem_tst_out(8)           ;-- <= i_txbuf_empty;  --RAM<-PCIE
----i_dbg.h2m.h2d_buf_full  <= i_host_mem_tst_out(9)           ;-- <= i_txbuf_full;   --RAM<-PCIE
----
------DEV -> MEM
----i_dbg.h2m.axiw_d      <= i_memin_ch(0).axiw.data(31 downto 0);
----i_dbg.h2m.axiw_dvalid <= i_memin_ch(0).axiw.dvalid;
----i_dbg.h2m.axiw_dvlast <= i_memin_ch(0).axiw.dlast ;
----
------DEV <- MEM
----i_dbg.h2m.axir_d      <= i_reg_tst0 & i_reg_mem;--i_memout_ch(0).axir.data(31 downto 0);
----i_dbg.h2m.axir_dvalid <= i_memout_ch(0).axir.dvalid;
----i_dbg.h2m.axir_dvlast <= i_memout_ch(0).axir.dlast ;
--
--
----##########################
----m_dbg_hostclk : dbgcs_ila_hostclk
----port map (
----clk => g_host_clk,
----
------pc <- fpga
----probe0(0) => i_dbg.pcie.axi_rq_tvalid,
----probe0(1) => i_dbg.pcie.axi_rq_tlast ,
----probe0(2) => i_dbg.pcie.axi_rq_tready,
----
------pc -> fpga
----probe0(3) => i_dbg.pcie.axi_rc_tvalid,
----probe0(4) => i_dbg.pcie.axi_rc_tlast ,
----probe0(5) => i_dbg.pcie.axi_rc_tready,
----
----probe0(9 downto 6) => i_dbg.pcie.dev_num  ,
----probe0(10)         => i_dbg.pcie.dma_start,
----probe0(11)         => i_dbg.pcie.dma_irq  ,
----
----probe0(12)         => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
----probe0(13)         => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
----probe0(14)         => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
----probe0(15)         => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
----
----probe0(16) => i_dbg.pcie.irq_int ,
----probe0(17) => i_dbg.pcie.irq_pend,
----probe0(18) => i_dbg.pcie.irq_sent,
----probe0(19) => i_dbg.pcie.irq_msi ,
----
----probe0(20) => i_dbg.pcie.test_speed_bit,
----
----probe0(24 downto 21) => i_dbg.pcie.axi_rq_fsm,
----
----probe0(56 downto 25) => i_dbg.pcie.h2d_buf_di(0),
----probe0(88 downto 57) => i_dbg.pcie.d2h_buf_do(0)
----);
--
--m_dbg_hostclk : dbgcs_ila_hostclk
--port map (
--clk => g_host_clk,
--
----pc <- fpga
--probe0(0) => i_dbg.pcie.axi_rq_tvalid,
--probe0(1) => i_dbg.pcie.axi_rq_tlast ,
--probe0(2) => i_dbg.pcie.axi_rq_tready,
--
----pc -> fpga
--probe0(3) => i_dbg.pcie.axi_rc_tvalid,
--probe0(4) => i_dbg.pcie.axi_rc_tlast ,
--probe0(5) => i_dbg.pcie.axi_rc_tready,
--
--probe0(9 downto 6) => i_dbg.pcie.dev_num  ,
--probe0(10)         => i_dbg.pcie.dma_start,
--probe0(11)         => i_dbg.pcie.dma_irq  ,
--
--probe0(12)         => i_dbg.pcie.h2d_buf_wr   ,--PCIE -> DEV
--probe0(13)         => i_dbg.pcie.h2d_buf_full ,--PCIE -> DEV
--probe0(14)         => i_dbg.pcie.d2h_buf_rd   ,--PCIE <- DEV
--probe0(15)         => i_dbg.pcie.d2h_buf_empty,--PCIE <- DEV
--
--probe0(16) => i_dbg.pcie.irq_int ,
--probe0(17) => i_dbg.pcie.irq_pend,
--probe0(18) => i_dbg.pcie.irq_sent,
--
--probe0(19) => i_dbg.pcie.irq_msi_en,
--probe0(20) => i_dbg.pcie.irq_msi_int,
--probe0(21) => i_dbg.pcie.irq_msi_send,
--probe0(22) => i_dbg.pcie.irq_msi_fail,
--probe0(23) => i_dbg.pcie.irq_msi_pending_status,
--probe0(29 downto 24) => i_dbg.pcie.irq_msi_vf_enable,
--probe0(35 downto 30) => i_dbg.pcie.irq_msi_mmenable,
--
--probe0(36) => i_dbg.pcie.test_speed_bit
--);
--
--
----m_dbg_usr_highclk : dbgcs_ila_usr_highclk
----port map (
----clk => g_usr_highclk,
----
----probe0(0)          => i_dbg.h2m.mem_start  ,
----probe0(1)          => i_dbg.h2m.mem_done   ,
----probe0(5 downto 2) => i_dbg.h2m.mem_wr_fsm ,
----probe0(6)          => i_dbg.h2m.d2h_buf_empty,--RAM->PCIE
----probe0(7)          => i_dbg.h2m.d2h_buf_full ,--RAM->PCIE
----probe0(8)          => i_dbg.h2m.h2d_buf_empty,--RAM<-PCIE
----probe0(9)          => i_dbg.h2m.h2d_buf_full , --RAM<-PCIE
----probe0(10)           => i_dbg.h2m.d2h_buf_wr,--: std_logic;
----probe0(11)           => i_dbg.h2m.h2d_buf_rd,--: std_logic;
----probe0(43 downto 12) => i_dbg.h2m.axiw_d,--i_dbg.h2m.d2h_buf_di,--: std_logic_vector(31 downto 0);
----probe0(75 downto 44) => i_dbg.h2m.axir_d,--i_dbg.h2m.h2d_buf_do --: std_logic_vector(31 downto 0);
----
----probe0(76)           => i_dbg.h2m.axiw_dvalid,
----probe0(77)           => i_dbg.h2m.axiw_dvlast,
----
----probe0(78)           => i_dbg.h2m.axir_dvalid,
----probe0(79)           => i_dbg.h2m.axir_dvlast
----);
--
--
--
--
--end generate gen_dbgcs_on;

end architecture struct;

