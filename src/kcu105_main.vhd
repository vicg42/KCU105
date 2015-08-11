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
use work.mem_ctrl_pkg.all;
use work.mem_wr_pkg.all;
use work.cfgdev_pkg.all;
use work.kcu105_main_unit_pkg.all;


entity kcu105_main is
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_in_btn          : in    std_logic_vector(3 downto 0);
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
signal i_host_dev_status                : std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
signal i_host_dev_irq                   : std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
signal i_host_dev_opt_in                : std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
signal i_host_dev_opt_out               : std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

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

constant CI_CFG_DWIDTH                  : integer := 16;--bit
signal i_cfg_rst                        : std_logic;
signal i_cfg_dadr                       : std_logic_vector(C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT downto 0);
signal i_cfg_radr                       : std_logic_vector(CI_CFG_DWIDTH - 1 downto 0);
signal i_cfg_radr_ld                    : std_logic;
signal i_cfg_radr_fifo                  : std_logic;
signal i_cfg_wr                         : std_logic;
signal i_cfg_rd                         : std_logic;
signal i_cfg_txd                        : std_logic_vector(15 downto 0);
signal i_cfg_rxd                        : std_logic_vector(15 downto 0);
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
signal i_mem_ctrl_rst                   : std_logic;
signal i_mem_ctrl_sysout                : TMEMCTRL_sysout;


signal i_test_led          : std_logic_vector(0 downto 0);


begin --architecture struct


--***********************************************************
--RESET
--***********************************************************
i_mem_ctrl_rst <= not i_host_rst_n or i_host_gctrl(C_HREG_CTRL_RST_MEM_BIT);--or i_host_gctrl(C_HREG_CTRL_RST_ALL_BIT)
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
--PCI-Express (HOST)
--***********************************************************
m_host : pcie_main
generic map(
G_DBGCS => C_PCGF_PCIE_DBGCS
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

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy   => pin_in_pcie_phy ,
p_out_pcie_phy  => pin_out_pcie_phy,
p_out_pcie_rst_n => i_host_rst_n
);

i_host_tst_in(31 downto 0) <= (others => '0');
i_host_tst_in(47 downto 32) <= (others => '0');
i_host_tst_in(65 downto 48) <= (others => '0');
i_host_tst_in(127 downto 66) <= (others => '0');


i_host_devadr <= UNSIGNED(i_host_dev_ctrl(C_HREG_DEV_CTRL_ADR_M_BIT downto C_HREG_DEV_CTRL_ADR_L_BIT));

--Status User Devices
i_host_dev_status(C_HREG_DEV_STATUS_CFG_RDY_BIT) <= '1';
--i_host_dev_status(C_HREG_DEV_STATUS_CFG_RXRDY_BIT) <= not i_host_rxbuf_empty(C_HDEV_CFG);
--i_host_dev_status(C_HREG_DEV_STATUS_CFG_TXRDY_BIT) <= i_host_txbuf_empty(C_HDEV_CFG);

i_host_dev_status(C_HREG_DEV_STATUS_MEMCTRL_RDY_BIT) <= OR_reduce(i_mem_ctrl_status.rdy);


--Host Write/Read data of user devices
gen_dev_dbuf : for i in 0 to i_host_wr'length - 1 generate
begin
i_host_wr(i)  <= i_host_dev_wr when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_rd(i)  <= i_host_dev_rd when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
i_host_txd(i) <= i_host_dev_txd;
--i_host_txd_rdy(i) <= i_host_dev_ctrl(C_HREG_DEV_CTRL_DRDY_BIT) when i_host_devadr = TO_UNSIGNED(i, i_host_devadr'length) else '0';
end generate gen_dev_dbuf;

i_host_dev_rxd <= i_host_rxd(C_HDEV_MEM);

--Flags (Host <- User Devices)
i_host_dev_opt_in(C_HDEV_OPTIN_TXFIFO_FULL_BIT) <= i_host_txbuf_full(C_HDEV_MEM)
                                                    when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM, i_host_devadr'length) else '0';

i_host_dev_opt_in(C_HDEV_OPTIN_RXFIFO_EMPTY_BIT) <= i_host_rxbuf_empty(C_HDEV_MEM)
                                                    when i_host_devadr = TO_UNSIGNED(C_HDEV_MEM , i_host_devadr'length) else '0';

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
pin_out_led(7 downto 7) <= (others => '0');


pin_out_led_hpc(0) <= i_test_led(0);
pin_out_led_hpc(1) <= i_test_led(0);
pin_out_led_hpc(2) <= i_test_led(0);
pin_out_led_hpc(3) <= i_test_led(0);

pin_out_led_lpc(0) <= i_test_led(0);
pin_out_led_lpc(1) <= i_test_led(0);
pin_out_led_lpc(2) <= i_test_led(0);
pin_out_led_lpc(3) <= i_test_led(0);


end architecture struct;
