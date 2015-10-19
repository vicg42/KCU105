-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.02.2015 10:24:19
-- Module Name : fg_pkg
--
-- Description :
--  VideoPacket:
--              -----------------------------------------------------
--             | 31..28 |27..24|23..20|19...16|15..12|11..8|7..4|3..0|
--             |-----------------------------------------------------|
--             | Reserv | FrNum| VCH  |PktType|   Length(Byte)       |
--             |-----------------------------------------------------|
--             |        Frame LineCount       |   Frame PixCount     |
--             |-----------------------------------------------------|
--             |        Frame LineNum         |   Frame PixNum       |
--             |-----------------------------------------------------|
--             |                     Time Stump                      |
--              -----------------------------------------------------
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_def.all;

package fg_pkg is

type TFG_FrMirror is record
x : std_logic;
y : std_logic;
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
end record;
type TFG_VCHPrms is array (0 to C_FG_VCH_COUNT - 1) of TFG_VCHPrm;

type TFG_Prm is record
mem_wd_trn_len : std_logic_vector(7 downto 0);
mem_rd_trn_len : std_logic_vector(7 downto 0);
ch : TFG_VCHPrms;
end record;

type TFGWR_Prm is record
fr : TFG_FrXY;
end record;
Type TFGWR_Prms is array (0 to C_FG_VCH_COUNT - 1) of TFGWR_Prm;

type TFGRD_Prm is record
--frwr   : TFG_FrXY;
frrd   : TFG_FrXYPrm;
mirror : TFG_FrMirror;
steprd : unsigned(15 downto 0); --Step read frame (Count Line)
end record;
Type TFGRD_Prms is array (0 to C_FG_VCH_COUNT - 1) of TFGRD_Prm;


Type TFG_FrBufs is array (0 to C_FG_VCH_COUNT - 1)
  of unsigned(C_FG_MEM_VFR_M_BIT - C_FG_MEM_VFR_L_BIT downto 0);

Type TFG_FrMrks is array (0 to C_FG_VCH_COUNT - 1) of std_logic_vector(31 downto 0);

type TFG_Video is record
d  : std_logic_vector(63 downto 0);
hs : std_logic;
vs : std_logic;
pixclken : std_logic;
pixclk   : std_logic;
end record;

type TFGWR_VBUFI is record
frprm : TFG_FrXY;
video : TFG_Video;
end record;
type TFGWR_VBUFIs is array (0 to C_FG_VCH_COUNT - 1) of TFGWR_VBUFI;

end package fg_pkg;

