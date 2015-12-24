-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.02.2015 10:24:19
-- Module Name : cl_pkg
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cl_pkg is

type TCLRxByte is array (0 to 2) of std_logic_vector(7 downto 0);
type TCLRegSync is array (0 to 6) of unsigned(3 downto 0);

type TCL_core_dbg is record
det_sync : std_logic;
tst_sync : std_logic;
idelay_inc : std_logic;
idelay_ce : std_logic;
idelay_oval : std_logic_vector(8 downto 0);
sr_reg : TCLRegSync;
sr_serdes_d : std_logic_vector(3 downto 0);
rx_sync_val : std_logic_vector(6 downto 0);
end record;


end package cl_pkg;

