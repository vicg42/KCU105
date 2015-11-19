-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 17:10:40
-- Module Name : eth_pkg
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


package eth_pkg is

type TEthMacAdr is array (0 to 5) of std_logic_vector(7 downto 0);
type TEthMAC is record
dst : TEthMacAdr;
src : TEthMacAdr;
end record;

type TEthCfg is record
--usrctrl  : std_logic_vector(15 downto 0);
mac      : TEthMAC;
end record;
type TEthCfgs is array (0 to 0) of TEthCfg;


end package eth_pkg;
