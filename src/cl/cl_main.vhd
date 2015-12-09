-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_main
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cl_main is
port(
--------------------------------------------------
--RS232(PC)
--------------------------------------------------
p_in_rs232_rx  : in  std_logic;
p_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
p_in_cl_tfg_n : in  std_logic; --Camera -> FG
p_in_cl_tfg_p : in  std_logic;
p_out_cl_tc_n : out std_logic; --Camera <- FG
p_out_cl_tc_p : out std_logic;

p_in_cl_xclk_p : in  std_logic;
p_in_cl_xclk_n : in  std_logic;
p_in_cl_x_p : in  std_logic_vector(3 downto 0);
p_in_cl_x_n : in  std_logic_vector(3 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cl_main;

architecture struct of cl_main is


component cl_xclk is
Port (
clk_in1_p : in std_logic;
clk_in1_n : in std_logic;
clk_out1  : out std_logic;
clk_out2  : out std_logic;
reset     : in std_logic;
locked    : out std_logic
);
end component cl_xclk;

signal g_cl_xclk_7x        : std_logic;
signal i_cl_xclk_7x_lock   : std_logic;
signal i_test_led          : std_logic_vector(0 downto 0);


begin --architecture struct


m_xclk : cl_xclk
port map(
clk_in1_p => p_in_cl_xclk_p,
clk_in1_n => p_in_cl_xclk_n,
clk_out1  => g_cl_xclk,
clk_out2  => g_cl_xclk_7x,
reset     => p_in_rst,
locked    => i_cl_xclk_7x_lock
);





end architecture struct;
