-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 10:29:01
-- Module Name : pcie_unit_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package pcie_unit_pkg is

component pio_to_ctrl
port (
clk        : in  std_logic;
rst_n      : in  std_logic;

req_compl  : in  std_logic;
compl_done : in  std_logic;

cfg_power_state_change_interrupt : in  std_logic;
cfg_power_state_change_ack       : out std_logic
);
end component pio_to_ctrl;



end package pcie_unit_pkg;

