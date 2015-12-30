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

constant C_CAM_STATUS_LASTBIT : natural := C_CAM_STATUS_CL_LINKTOTAL_BIT;

end package cam_cl_pkg;

