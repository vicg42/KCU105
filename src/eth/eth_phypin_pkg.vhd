-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 15:19:47
-- Module Name : eth_phypin_pkg
--
-- Description : Назначаем пины интерфейсов
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.prj_cfg.all;

package eth_phypin_pkg is

constant C_GTCH_COUNT_MAX : integer := C_PCFG_ETH_GTCH_COUNT_MAX;

----------------------------
--FIBER:
----------------------------
type TEthPhyFiberPinOUT is record
txp : std_logic_vector(C_GTCH_COUNT_MAX-1 downto 0);
txn : std_logic_vector(C_GTCH_COUNT_MAX-1 downto 0);
end record;
type TEthPhyFiberPinIN is record
rxp  : std_logic_vector(C_GTCH_COUNT_MAX-1 downto 0);
rxn  : std_logic_vector(C_GTCH_COUNT_MAX-1 downto 0);
clk_p: std_logic;
clk_n: std_logic;
end record;

----------------------------
--Total
----------------------------
type TEthPhyPinOUT is record
fiber : TEthPhyFiberPinOUT;
end record;
type TEthPhyPinIN is record
fiber : TEthPhyFiberPinIN;
end record;

end eth_phypin_pkg;


