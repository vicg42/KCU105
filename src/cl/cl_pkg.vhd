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

constant C_CL_CHCOUNT_MAX : natural := 3;
constant C_CL_TAP_MAX : natural := 10;

constant C_CL_MMCM : natural := 0;
constant C_CL_PLL  : natural := 1;
type TCL_DCM_TYPE_ARRAY is array(2 downto 0) of natural;

type TCL_RegSync is array (0 to 6) of unsigned(3 downto 0);

type TCL_core_dbg is record
fsm_sync : std_logic_vector(2 downto 0);
usr_sync : std_logic;
usr_2sync : std_logic;
sync : std_logic;
sync_find : std_logic;
sync_find_ok : std_logic;
idelay_inc : std_logic;
idelay_ce : std_logic;
idelay_oval : std_logic_vector((9 * 1) - 1 downto 0);
des_d : std_logic_vector(3 downto 0);
sr_des_d : TCL_RegSync;
gearbox_do_sync_val : std_logic_vector(6 downto 0);
end record;


end package cl_pkg;

