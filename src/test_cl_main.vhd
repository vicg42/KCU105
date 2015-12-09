-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : test_cl_main
--
-- Description : top level of project
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clocks_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity test_cl_main is
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_out_led         : out   std_logic_vector(0 downto 0);

pin_out_led_hpc     : out   std_logic_vector(0 downto 0);

--------------------------------------------------
--RS232(PC)
--------------------------------------------------
pin_in_rs232_rx  : in  std_logic;
pin_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
pin_in_cl_tfg_n : in  std_logic;
pin_in_cl_tfg_p : in  std_logic;
pin_out_cl_tc_n : out std_logic;
pin_out_cl_tc_p : out std_logic;

--------------------------------------------------
--Reference clock
--------------------------------------------------
pin_in_refclk       : in    TRefClkPinIN
);
end entity test_cl_main;

architecture struct of test_cl_main is

component clocks
port(
p_out_rst  : out   std_logic;
p_out_gclk : out   std_logic_vector(7 downto 0);

p_in_clkopt: in    std_logic_vector(3 downto 0);
p_in_clk   : in    TRefClkPinIN
);
end component clocks;

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


signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
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


m_IBUFDS_cl_tfg : IBUFDS
--generic map (
--DQS_BIAS => "FALSE" -- (FALSE, TRUE)
--)
port map (
O  => pin_out_rs232_tx, -- 1-bit output: Buffer output
I  => pin_in_cl_tfg_p , -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
IB => pin_in_cl_tfg_n   -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
);


m_OBUFDS_cl_tc : OBUFDS
port map (
O  => pin_out_cl_tc_p, -- 1-bit output: Diff_p output (connect directly to top-level port)
OB => pin_out_cl_tc_n, -- 1-bit output: Diff_n output (connect directly to top-level port)
I  => pin_in_rs232_rx  -- 1-bit input: Buffer input
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


pin_out_led_hpc(0) <= i_test_led(0);
--pin_out_led_hpc(1) <= '0';
--pin_out_led_hpc(2) <= '0';
--pin_out_led_hpc(3) <= i_test_led(0);




end architecture struct;
