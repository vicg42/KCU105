-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 15:19:47
-- Module Name : eth_phypin_pkg
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.prj_cfg.all;

package eth_phypin_pkg is

constant C_GTCH_COUNT : integer := C_PCFG_ETH_CH_COUNT;

----------------------------
--FIBER:
----------------------------
type TEthPhyFiberPin_OUT is record
txp : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
txn : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
end record;
type TEthPhyFiberPin_IN is record
rxp  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rxn  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
refclk_p: std_logic;
refclk_n: std_logic;
end record;

----------------------------
--Total
----------------------------
type TEthPhyPin_OUT is record
fiber : TEthPhyFiberPin_OUT;
end record;
type TEthPhyPin_IN is record
fiber : TEthPhyFiberPin_IN;
end record;

end package eth_phypin_pkg;


