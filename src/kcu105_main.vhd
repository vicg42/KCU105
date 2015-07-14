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

entity kcu105_main is
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_in_btn          : in    std_logic_vector(4 downto 0);
pin_out_led         : out   std_logic_vector(7 downto 0);

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

component pcie_main is
port(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk           : out   std_logic ;
p_out_gctrl          : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

p_out_dev_ctrl       : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din        : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout        : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr         : out   std_logic;
p_out_dev_rd         : out   std_logic;
p_in_dev_status      : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq         : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt         : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt        : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst        : out   std_logic_vector(127 downto 0);
p_in_usr_tst         : in    std_logic_vector(127 downto 0);
p_in_tst             : in    std_logic_vector(31 downto 0);
p_out_tst            : out   std_logic_vector(255 downto 0);

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy        : in    TPCIE_pinin;
p_out_pcie_phy       : out   TPCIE_pinout
);
end component pcie_main;

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

signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal g_usr_highclk       : std_logic;

signal i_test_led          : std_logic_vector(0 downto 0);


begin --architecture struct


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


--***********************************************************
--
--***********************************************************
m_host : pcie_main
port map(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk           => open,
p_out_gctrl          => open,

p_out_dev_ctrl       => open,
p_out_dev_din        => open,
p_in_dev_dout        => (others => '0'),
p_out_dev_wr         => open,
p_out_dev_rd         => open,
p_in_dev_status      => (others => '0'),
p_in_dev_irq         => (others => '0'),
p_in_dev_opt         => (others => '0'),
p_out_dev_opt        => open,

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst        => open,
p_in_usr_tst         => (others => '0'),
p_in_tst             => (others => '0'),
p_out_tst            => open,

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy        => pin_in_pcie_phy ,
p_out_pcie_phy       => pin_out_pcie_phy
);


--#########################################
--DBG
--#########################################
m_led : fpga_test_01
generic map(
G_BLINK_T05 => 10#125#,
G_CLK_T05us => 10#450#
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

gen_tst : for i in 1 to 2 generate begin
process(g_usrclk(i))
begin
if rising_edge(g_usrclk(i)) then
pin_out_led(i) <= pin_in_btn(i);
end if;
end process;
end generate gen_tst;

pin_out_led(pin_out_led'high downto 3) <= pin_in_btn(pin_in_btn'high downto 3);

end architecture struct;
