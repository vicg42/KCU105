-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.02.2015 10:24:19
-- Module Name : cam_cl_pkg
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cam_cl_pkg is

constant C_CAM_STATUS_CLX_PLLLOCK_BIT  : natural := 0;
constant C_CAM_STATUS_CLY_PLLLOCK_BIT  : natural := 1;
constant C_CAM_STATUS_CLZ_PLLLOCK_BIT  : natural := 2;
constant C_CAM_STATUS_CLX_LINK_BIT     : natural := 3;
constant C_CAM_STATUS_CLY_LINK_BIT     : natural := 4;
constant C_CAM_STATUS_CLZ_LINK_BIT     : natural := 5;
constant C_CAM_STATUS_CL_LINKTOTAL_BIT : natural := 6;
constant C_CAM_STATUS_FRPRM_DETECT_BIT : natural := 7;

constant C_CAM_STATUS_LASTBIT : natural := C_CAM_STATUS_FRPRM_DETECT_BIT;



type TCLDBG_detprm is record
pixcount  : std_logic_vector(15 downto 0);
linecount : std_logic_vector(15 downto 0);
frprm_det : std_logic;
restart   : std_logic;
end record;

type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);
type TCLDBG_CH is record
clk : std_logic;
link : std_logic;
fval : std_logic;
lval : std_logic;
fval_edge0 : std_logic;
fval_edge1 : std_logic;
--lval_edge0 : std_logic;
--lval_edge1 : std_logic;
rxbyte : TCL_rxbyte_dbg;
clk_synval : std_logic_vector(6 downto 0);
end record;
type TCLDBG_CHs is array (0 to 2) of TCLDBG_CH;

type TCLDBG_CAM is record
bufpkt_empty : std_logic;
bufpkt_rd : std_logic;
bufpkt_do : std_logic_vector(63 downto 0);
vpkt_err : std_logic;
fval : std_logic;
lval : std_logic;
fval_edge0 : std_logic;
fval_edge1 : std_logic;
--lval_edge0 : std_logic;
--lval_edge1 : std_logic;
frprm_detect : std_logic;
vpkt_fsm     : std_logic_vector(2 downto 0);
vpkt_padding : std_logic;
end record;

type TCAM_dbg is record
det : TCLDBG_detprm;
cl  : TCLDBG_CHs;
cam : TCLDBG_CAM;
end record;

end package cam_cl_pkg;

