-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 11.02.2015 20:26:48
-- Module Name : clocks
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package clocks_pkg is

type TRefClkPinIN is record
--M300_p : std_logic;
--M300_n : std_logic;
--M125_p : std_logic;
--M125_n : std_logic;
M90    : std_logic;
end record;

end clocks_pkg;

