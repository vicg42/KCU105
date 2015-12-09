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
--DBG
--------------------------------------------------
pin_out_led         : out   std_logic_vector(0 downto 0);

--------------------------------------------------
--RS232(PC)
--------------------------------------------------
p_in_rs232_rx  : in  std_logic;
p_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
p_in_cl_tfg_n : in  std_logic;
p_in_cl_tfg_p : in  std_logic;
p_out_cl_tc_n : out std_logic;
p_out_cl_tc_p : out std_logic;


);
end entity cl_main;

architecture struct of cl_main is


signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal i_test_led          : std_logic_vector(0 downto 0);


begin --architecture struct







end architecture struct;
