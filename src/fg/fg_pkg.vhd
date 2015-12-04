-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.02.2015 10:24:19
-- Module Name : fg_pkg
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_def.all;

package fg_pkg is

type TFG_FrMirror is record
pix : std_logic;
row : std_logic;
end record;

type TFG_FrXY is record
pixcount : unsigned(15 downto 0);
rowcount : unsigned(15 downto 0);
end record;
Type TFG_FrXYs is array (0 to C_FG_VCH_COUNT - 1) of TFG_FrXY;

type TFG_FrXYPrm is record
skp : TFG_FrXY; --skip zone
act : TFG_FrXY; --active zone
end record;
Type TFG_FrXYPrms is array (0 to C_FG_VCH_COUNT - 1) of TFG_FrXYPrm;

type TFG_VCHPrm is record
fr     : TFG_FrXYPrm;
mirror : TFG_FrMirror;
steprd : unsigned(15 downto 0); --Step read frame (Count Line)
--mem_rbase : unsigned(31 downto 0);
end record;
type TFG_VCHPrms is array (0 to C_FG_VCH_COUNT - 1) of TFG_VCHPrm;

type TFG_Prm is record
memwr_trnlen : std_logic_vector(7 downto 0);
memrd_trnlen : std_logic_vector(7 downto 0);
ch : TFG_VCHPrms;
end record;


Type TFG_FrBufs is array (0 to C_FG_VCH_COUNT - 1)
  of unsigned(C_FG_MEM_VFR_M_BIT - C_FG_MEM_VFR_L_BIT downto 0);

Type TFG_FrMrks is array (0 to C_FG_VCH_COUNT - 1) of std_logic_vector(31 downto 0);


end package fg_pkg;

