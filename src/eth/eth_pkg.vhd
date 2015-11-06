-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 28.11.2011 15:45:11
-- Module Name : eth_pkg
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package eth_pkg is

type TEthMacAdr is array (0 to 5) of unsigned(7 downto 0);
type TEthMAC is record
dst : TEthMacAdr;
src : TEthMacAdr;
end record;

type TEthCfg is record
usrctrl  : std_logic_vector(15 downto 0);
mac      : TEthMAC;
end record;
type TEthCfgs is array (0 to 0) of TEthCfg;



end eth_pkg;


