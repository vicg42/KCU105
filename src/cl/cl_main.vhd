-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_main
--
-- Description :
--
-- Base Configuration   : Tap2/Pix8
-- Base Configuration   : Tap2/Pix10
-- Medium Configuration : Tap10/Pix10
-- Full Configuration   : Tap8/Pix8
-- Full Configuration   : Tap10/Pix8
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.reduce_pack.all;
use work.cl_pkg.all;

entity cl_main is
generic(
G_DCM_TYPE : TCL_DCM_TYPE_ARRAY := (C_CL_PLL, --type dcm for chanal 3
                                    C_CL_PLL, --type dcm for chanal 2
                                    C_CL_MMCM --type dcm for chanal 1
                                   );
G_DCM_CLKIN_PERIOD : real := 11.764000; --85MHz => clkx7 = ((85/1)*14)/2 = 1190/2 = 595MHz
G_DCM_DIVCLK_DIVIDE : natural := 1;
G_DCM_CLKFBOUT_MULT : natural := 14;
G_DCM_CLKOUT0_DIVIDE : natural := 2;
G_CL_PIXBIT : natural := 8; --Number of bit per 1 pix
G_CL_TAP : natural := 8; --Number of pixel per 1 clk
G_CL_CHCOUNT : natural := 1 --Number of channel: Base/Medium/Full Configuration = 1/2/3
);
port(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_plllock: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_cl_clk_synval : out std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cl_main;

architecture struct of cl_main is

component cl_core is
generic(
G_CLKIN_PERIOD : real := 11.764000; --85MHz
G_DIVCLK_DIVIDE : natural := 1;
G_CLKFBOUT_MULT : natural := 2;
G_CLKOUT0_DIVIDE : natural := 2;
G_DCM_TYPE : natural := 0
);
port(
-----------------------------
--CameraLink (IN)
-----------------------------
p_in_cl_clk_p : in  std_logic;
p_in_cl_clk_n : in  std_logic;
p_in_cl_di_p  : in  std_logic_vector(3 downto 0);
p_in_cl_di_n  : in  std_logic_vector(3 downto 0);

-----------------------------
--RxData
-----------------------------
p_out_rxd     : out std_logic_vector(27 downto 0);
p_out_rxclk   : out std_logic;
p_out_link    : out std_logic;

-----------------------------
--DBG
-----------------------------
p_out_cl_clk_synval : out  std_logic_vector(6 downto 0);
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);
--p_out_dbg : out  TCL_core_dbg;

-----------------------------
--System
-----------------------------
--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_out_plllock : out std_logic;
p_in_rst : in std_logic
);
end component cl_core;

signal i_cl_fval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_lval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

type TCL_rxd is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(27 downto 0);
signal i_cl_rxd        : TCL_rxd;
signal i_cl_rxclk      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_link       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_plllock    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
type TCL_tstout is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(31 downto 0);
signal i_cl_tstout     : TCL_tstout;

type TCL_rxbyte is array (0 to C_CL_TAP_MAX - 1) of std_logic_vector(G_CL_PIXBIT - 1 downto 0);
signal i_cl_rxbyte     : TCL_rxbyte;


--type TCL_core_dbgs is array (0 to G_CL_CHCOUNT - 1) of TCL_core_dbg;
--signal i_cl_core_dbg   : TCL_core_dbgs;
--
--
--component ila_dbg_cl is
--port (
--clk : in std_logic;
--probe0 : in std_logic_vector(49 downto 0)
--);
--end component ila_dbg_cl;
--
--component ila_dbg2_cl is
--port (
--clk : in std_logic;
--probe0 : in std_logic_vector(34 downto 0)
--);
--end component ila_dbg2_cl;
--
--type TCL_dbg is record
--core : TCL_core_dbg;
--lval : std_logic;
--fval : std_logic;
--end record;
--
--type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);
--
--type TCLmain_dbg is record
--clx : TCL_dbg;
--rxbyte : TCL_rxbyte_dbg;
--end record;
--
--signal i_dbg : TCLmain_dbg;
--
--attribute mark_debug : string;
--attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct


p_out_plllock <= i_cl_plllock;
p_out_link <= i_cl_link;
p_out_fval <= i_cl_fval;
p_out_lval <= i_cl_lval;
p_out_dval <= (others => '1');
p_out_rxclk <= i_cl_rxclk;
gen_dout : for i in 0 to (G_CL_TAP - 1) generate begin
p_out_rxbyte((G_CL_PIXBIT * (i + 1)) - 1 downto (G_CL_PIXBIT * i)) <= i_cl_rxbyte(i)(G_CL_PIXBIT - 1 downto 0);
end generate gen_dout;


gen_ch : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
m_core : cl_core
generic map(
G_CLKIN_PERIOD   => G_DCM_CLKIN_PERIOD  ,
G_DIVCLK_DIVIDE  => G_DCM_DIVCLK_DIVIDE ,
G_CLKFBOUT_MULT  => G_DCM_CLKFBOUT_MULT ,
G_CLKOUT0_DIVIDE => G_DCM_CLKOUT0_DIVIDE,
G_DCM_TYPE => G_DCM_TYPE(i)
)
port map(
-----------------------------
--CameraLink (IN)
-----------------------------
p_in_cl_clk_p => p_in_cl_clk_p(i),
p_in_cl_clk_n => p_in_cl_clk_n(i),
p_in_cl_di_p  => p_in_cl_di_p((4 * (i + 1)) - 1 downto 4 * i),
p_in_cl_di_n  => p_in_cl_di_n((4 * (i + 1)) - 1 downto 4 * i),

-----------------------------
--RxData
-----------------------------
p_out_rxd     => i_cl_rxd(i),
p_out_rxclk   => i_cl_rxclk(i),
p_out_link    => i_cl_link(i),

-----------------------------
--DBG
-----------------------------
p_out_cl_clk_synval => p_out_cl_clk_synval((7 * (i + 1)) - 1 downto 7 * i),
--p_out_tst => i_cl_tstout(i),
--p_in_tst  => p_in_tst,
--p_out_dbg => i_cl_core_dbg(i),

--p_in_refclk => p_in_refclk,
--p_in_clk => p_in_clk,
p_out_plllock => i_cl_plllock(i),
p_in_rst => p_in_rst
);
end generate gen_ch;


--#################################
--Full Configuration (64bit = 8Tap/8bit)
--#################################
gen_tap8_8bit : if (G_CL_TAP = 8) and (G_CL_PIXBIT = 8) generate begin
--!!!! cl X cahnnel Full Configuration (64bit = 8Tap/8bit)!!!!
process(i_cl_rxclk(0))
begin
if rising_edge(i_cl_rxclk(0)) then
i_cl_fval(0) <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)

--cl A(byte)
i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --PortA0
i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --PortA1
i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --PortA2
i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --PortA3
i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --PortA4
i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 0) + 5); --PortA5
i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 3) + 0); --PortA6
i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 3) + 1); --PortA7

--cl B(byte)
i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 0) + 6); --PortB0
i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 0); --PortB1
i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 1) + 1); --PortB2
i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 1) + 2); --PortB3
i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 1) + 3); --PortB4
i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 1) + 4); --PortB5
i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 3) + 2); --PortB6
i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 3) + 3); --PortB7

--cl C(byte)
i_cl_rxbyte(2)(0) <= i_cl_rxd(0)((7 * 1) + 5); --PortC0
i_cl_rxbyte(2)(1) <= i_cl_rxd(0)((7 * 1) + 6); --PortC1
i_cl_rxbyte(2)(2) <= i_cl_rxd(0)((7 * 2) + 0); --PortC2
i_cl_rxbyte(2)(3) <= i_cl_rxd(0)((7 * 2) + 1); --PortC3
i_cl_rxbyte(2)(4) <= i_cl_rxd(0)((7 * 2) + 2); --PortC4
i_cl_rxbyte(2)(5) <= i_cl_rxd(0)((7 * 2) + 3); --PortC5
i_cl_rxbyte(2)(6) <= i_cl_rxd(0)((7 * 3) + 4); --PortC6
i_cl_rxbyte(2)(7) <= i_cl_rxd(0)((7 * 3) + 5); --PortC7
end if;
end process;

--!!!! cl Y cahnnel Full Configuration (64bit = 8Tap/8bit)!!!!
process(i_cl_rxclk(1))
begin
if rising_edge(i_cl_rxclk(1)) then
i_cl_fval(1) <= i_cl_rxd(1)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(1) <= i_cl_rxd(1)((7 * 2) + 4); --LVAL(Line value)

--cl D(byte)
i_cl_rxbyte(3)(0) <= i_cl_rxd(1)((7 * 0) + 0); --PortD0
i_cl_rxbyte(3)(1) <= i_cl_rxd(1)((7 * 0) + 1); --PortD1
i_cl_rxbyte(3)(2) <= i_cl_rxd(1)((7 * 0) + 2); --PortD2
i_cl_rxbyte(3)(3) <= i_cl_rxd(1)((7 * 0) + 3); --PortD3
i_cl_rxbyte(3)(4) <= i_cl_rxd(1)((7 * 0) + 4); --PortD4
i_cl_rxbyte(3)(5) <= i_cl_rxd(1)((7 * 0) + 5); --PortD5
i_cl_rxbyte(3)(6) <= i_cl_rxd(1)((7 * 3) + 0); --PortD6
i_cl_rxbyte(3)(7) <= i_cl_rxd(1)((7 * 3) + 1); --PortD7

--cl E(byte)
i_cl_rxbyte(4)(0) <= i_cl_rxd(1)((7 * 0) + 6); --PortE0
i_cl_rxbyte(4)(1) <= i_cl_rxd(1)((7 * 1) + 0); --PortE1
i_cl_rxbyte(4)(2) <= i_cl_rxd(1)((7 * 1) + 1); --PortE2
i_cl_rxbyte(4)(3) <= i_cl_rxd(1)((7 * 1) + 2); --PortE3
i_cl_rxbyte(4)(4) <= i_cl_rxd(1)((7 * 1) + 3); --PortE4
i_cl_rxbyte(4)(5) <= i_cl_rxd(1)((7 * 1) + 4); --PortE5
i_cl_rxbyte(4)(6) <= i_cl_rxd(1)((7 * 3) + 2); --PortE6
i_cl_rxbyte(4)(7) <= i_cl_rxd(1)((7 * 3) + 3); --PortE7

--cl F(byte)
i_cl_rxbyte(5)(0) <= i_cl_rxd(1)((7 * 1) + 5); --PortF0
i_cl_rxbyte(5)(1) <= i_cl_rxd(1)((7 * 1) + 6); --PortF1
i_cl_rxbyte(5)(2) <= i_cl_rxd(1)((7 * 2) + 0); --PortF2
i_cl_rxbyte(5)(3) <= i_cl_rxd(1)((7 * 2) + 1); --PortF3
i_cl_rxbyte(5)(4) <= i_cl_rxd(1)((7 * 2) + 2); --PortF4
i_cl_rxbyte(5)(5) <= i_cl_rxd(1)((7 * 2) + 3); --PortF5
i_cl_rxbyte(5)(6) <= i_cl_rxd(1)((7 * 3) + 4); --PortF6
i_cl_rxbyte(5)(7) <= i_cl_rxd(1)((7 * 3) + 5); --PortF7
end if;
end process;

--!!!! cl Z cahnnel Full Configuration (64bit = 8Tap/8bit)!!!!
process(i_cl_rxclk(2))
begin
if rising_edge(i_cl_rxclk(2)) then
i_cl_fval(2) <= i_cl_rxd(2)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(2) <= i_cl_rxd(2)((7 * 2) + 4); --LVAL(Line value)

--cl G(byte)
i_cl_rxbyte(6)(0) <= i_cl_rxd(2)((7 * 0) + 0); --PortG0
i_cl_rxbyte(6)(1) <= i_cl_rxd(2)((7 * 0) + 1); --PortG1
i_cl_rxbyte(6)(2) <= i_cl_rxd(2)((7 * 0) + 2); --PortG2
i_cl_rxbyte(6)(3) <= i_cl_rxd(2)((7 * 0) + 3); --PortG3
i_cl_rxbyte(6)(4) <= i_cl_rxd(2)((7 * 0) + 4); --PortG4
i_cl_rxbyte(6)(5) <= i_cl_rxd(2)((7 * 0) + 5); --PortG5
i_cl_rxbyte(6)(6) <= i_cl_rxd(2)((7 * 3) + 0); --PortG6
i_cl_rxbyte(6)(7) <= i_cl_rxd(2)((7 * 3) + 1); --PortG7

--cl H(byte)
i_cl_rxbyte(7)(0) <= i_cl_rxd(2)((7 * 0) + 6); --PortH0
i_cl_rxbyte(7)(1) <= i_cl_rxd(2)((7 * 1) + 0); --PortH1
i_cl_rxbyte(7)(2) <= i_cl_rxd(2)((7 * 1) + 1); --PortH2
i_cl_rxbyte(7)(3) <= i_cl_rxd(2)((7 * 1) + 2); --PortH3
i_cl_rxbyte(7)(4) <= i_cl_rxd(2)((7 * 1) + 3); --PortH4
i_cl_rxbyte(7)(5) <= i_cl_rxd(2)((7 * 1) + 4); --PortH5
i_cl_rxbyte(7)(6) <= i_cl_rxd(2)((7 * 3) + 2); --PortH6
i_cl_rxbyte(7)(7) <= i_cl_rxd(2)((7 * 3) + 3); --PortH7
end if;
end process;

end generate gen_tap8_8bit;






--#################################
--Full Configuration (80bit = 10Tap/8bit)
--#################################
gen_tap10_8bit : if (G_CL_TAP = 10) and (G_CL_PIXBIT = 8) generate begin
--!!!! cl X cahnnel Full Configuration (80bit = 10Tap/8bit)!!!!
process(i_cl_rxclk(0))
begin
if rising_edge(i_cl_rxclk(0)) then
i_cl_fval(0) <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)

--cl A(byte)
i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --PortA0
i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --PortA1
i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --PortA2
i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --PortA3
i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --PortA4
i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 3) + 1); --PortA5
i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 0) + 5); --PortA6
i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 0) + 6); --PortA7

--cl B(byte)
i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 1) + 0); --PortB0
i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 1); --PortB1
i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 3) + 2); --PortB2
i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 3) + 3); --PortB3
i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 1) + 2); --PortB4
i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 1) + 3); --PortB5
i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 1) + 4); --PortB6
i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 1) + 5); --PortB7

--cl C(byte)
i_cl_rxbyte(2)(0) <= i_cl_rxd(0)((7 * 3) + 4); --PortC0
i_cl_rxbyte(2)(1) <= i_cl_rxd(0)((7 * 3) + 5); --PortC1
i_cl_rxbyte(2)(2) <= i_cl_rxd(0)((7 * 1) + 6); --PortC2
i_cl_rxbyte(2)(3) <= i_cl_rxd(0)((7 * 2) + 0); --PortC3
i_cl_rxbyte(2)(4) <= i_cl_rxd(0)((7 * 2) + 1); --PortC4
i_cl_rxbyte(2)(5) <= i_cl_rxd(0)((7 * 2) + 2); --PortC5
i_cl_rxbyte(2)(6) <= i_cl_rxd(0)((7 * 2) + 3); --PortC6
i_cl_rxbyte(2)(7) <= i_cl_rxd(0)((7 * 3) + 6); --PortC7

--cl D(byte)
i_cl_rxbyte(3)(0) <= i_cl_rxd(0)((7 * 2) + 6); --PortD0
i_cl_rxbyte(3)(1) <= i_cl_rxd(0)((7 * 3) + 0); --PortD1
end if;
end process;

--!!!! cl Y cahnnel Full Configuration (80bit = 10Tap/8bit)!!!!
process(i_cl_rxclk(1))
begin
if rising_edge(i_cl_rxclk(1)) then
i_cl_lval(1) <= i_cl_rxd(1)((7 * 3) + 0); --LVAL(Line value)

i_cl_rxbyte(3)(2) <= i_cl_rxd(1)((7 * 0) + 0); --PortD2
i_cl_rxbyte(3)(3) <= i_cl_rxd(1)((7 * 0) + 1); --PortD3
i_cl_rxbyte(3)(4) <= i_cl_rxd(1)((7 * 0) + 2); --PortD4
i_cl_rxbyte(3)(5) <= i_cl_rxd(1)((7 * 0) + 3); --PortD5
i_cl_rxbyte(3)(6) <= i_cl_rxd(1)((7 * 0) + 4); --PortD6
i_cl_rxbyte(3)(7) <= i_cl_rxd(1)((7 * 3) + 1); --PortD7

--cl E(byte)
i_cl_rxbyte(4)(0) <= i_cl_rxd(1)((7 * 0) + 5); --PortE0
i_cl_rxbyte(4)(1) <= i_cl_rxd(1)((7 * 0) + 6); --PortE1
i_cl_rxbyte(4)(2) <= i_cl_rxd(1)((7 * 1) + 0); --PortE2
i_cl_rxbyte(4)(3) <= i_cl_rxd(1)((7 * 1) + 1); --PortE3
i_cl_rxbyte(4)(4) <= i_cl_rxd(1)((7 * 3) + 2); --PortE4
i_cl_rxbyte(4)(5) <= i_cl_rxd(1)((7 * 3) + 3); --PortE5
i_cl_rxbyte(4)(6) <= i_cl_rxd(1)((7 * 1) + 2); --PortE6
i_cl_rxbyte(4)(7) <= i_cl_rxd(1)((7 * 1) + 3); --PortE7

--cl F(byte)
i_cl_rxbyte(5)(0) <= i_cl_rxd(1)((7 * 1) + 4); --PortF0
i_cl_rxbyte(5)(1) <= i_cl_rxd(1)((7 * 1) + 5); --PortF1
i_cl_rxbyte(5)(2) <= i_cl_rxd(1)((7 * 3) + 4); --PortF2
i_cl_rxbyte(5)(3) <= i_cl_rxd(1)((7 * 3) + 5); --PortF3
i_cl_rxbyte(5)(4) <= i_cl_rxd(1)((7 * 1) + 6); --PortF4
i_cl_rxbyte(5)(5) <= i_cl_rxd(1)((7 * 2) + 0); --PortF5
i_cl_rxbyte(5)(6) <= i_cl_rxd(1)((7 * 2) + 1); --PortF6
i_cl_rxbyte(5)(7) <= i_cl_rxd(1)((7 * 2) + 2); --PortF7

--cl G(byte)
i_cl_rxbyte(6)(0) <= i_cl_rxd(1)((7 * 2) + 3); --PortG0
i_cl_rxbyte(6)(1) <= i_cl_rxd(1)((7 * 3) + 6); --PortG1
i_cl_rxbyte(6)(2) <= i_cl_rxd(1)((7 * 2) + 4); --PortG2
i_cl_rxbyte(6)(3) <= i_cl_rxd(1)((7 * 2) + 5); --PortG3
i_cl_rxbyte(6)(4) <= i_cl_rxd(1)((7 * 2) + 6); --PortG4
end if;
end process;

--!!!! cl Y cahnnel Full Configuration (80bit = 10Tap/8bit)!!!!
process(i_cl_rxclk(2))
begin
if rising_edge(i_cl_rxclk(2)) then
i_cl_lval(2) <= i_cl_rxd(2)((7 * 3) + 0); --LVAL(Line value)

i_cl_rxbyte(6)(5) <= i_cl_rxd(2)((7 * 0) + 0); --PortG5
i_cl_rxbyte(6)(6) <= i_cl_rxd(2)((7 * 0) + 1); --PortG6
i_cl_rxbyte(6)(7) <= i_cl_rxd(2)((7 * 0) + 2); --PortG7

--cl H(byte)
i_cl_rxbyte(7)(0) <= i_cl_rxd(2)((7 * 0) + 3); --PortH0
i_cl_rxbyte(7)(1) <= i_cl_rxd(2)((7 * 0) + 4); --PortH1
i_cl_rxbyte(7)(2) <= i_cl_rxd(2)((7 * 3) + 1); --PortH2
i_cl_rxbyte(7)(3) <= i_cl_rxd(2)((7 * 0) + 5); --PortH3
i_cl_rxbyte(7)(4) <= i_cl_rxd(2)((7 * 0) + 6); --PortH4
i_cl_rxbyte(7)(5) <= i_cl_rxd(2)((7 * 1) + 0); --PortH5
i_cl_rxbyte(7)(6) <= i_cl_rxd(2)((7 * 1) + 1); --PortH6
i_cl_rxbyte(7)(7) <= i_cl_rxd(2)((7 * 3) + 2); --PortH7

--cl I(byte)
i_cl_rxbyte(8)(0) <= i_cl_rxd(2)((7 * 3) + 3); --PortI0
i_cl_rxbyte(8)(1) <= i_cl_rxd(2)((7 * 1) + 2); --PortI1
i_cl_rxbyte(8)(2) <= i_cl_rxd(2)((7 * 1) + 3); --PortI2
i_cl_rxbyte(8)(3) <= i_cl_rxd(2)((7 * 1) + 4); --PortI3
i_cl_rxbyte(8)(4) <= i_cl_rxd(2)((7 * 1) + 5); --PortI4
i_cl_rxbyte(8)(5) <= i_cl_rxd(2)((7 * 3) + 4); --PortI5
i_cl_rxbyte(8)(6) <= i_cl_rxd(2)((7 * 3) + 5); --PortI6
i_cl_rxbyte(8)(7) <= i_cl_rxd(2)((7 * 1) + 6); --PortI7

--cl J(byte)
i_cl_rxbyte(9)(0) <= i_cl_rxd(2)((7 * 2) + 0); --PortJ0
i_cl_rxbyte(9)(1) <= i_cl_rxd(2)((7 * 2) + 1); --PortJ1
i_cl_rxbyte(9)(2) <= i_cl_rxd(2)((7 * 2) + 2); --PortJ2
i_cl_rxbyte(9)(3) <= i_cl_rxd(2)((7 * 2) + 3); --PortJ3
i_cl_rxbyte(9)(4) <= i_cl_rxd(2)((7 * 3) + 6); --PortJ4
i_cl_rxbyte(9)(5) <= i_cl_rxd(2)((7 * 2) + 4); --PortJ5
i_cl_rxbyte(9)(6) <= i_cl_rxd(2)((7 * 2) + 5); --PortJ6
i_cl_rxbyte(9)(7) <= i_cl_rxd(2)((7 * 2) + 6); --PortJ7
end if;
end process;
end generate gen_tap10_8bit;




--#################################
--BASE Configuration (16bit = 2Tap/8bit)
--#################################
gen_tap2_8bit : if (G_CL_TAP = 2) and (G_CL_PIXBIT = 8) generate begin
--!!!! cl X cahnnel !!!!
process(i_cl_rxclk(0))
begin
if rising_edge(i_cl_rxclk(0)) then
i_cl_fval(0) <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)

--cl A(byte)
i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --A0
i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --A1
i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --A2
i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --A3
i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --A4
i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 0) + 5); --A5
i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 3) + 0); --A6
i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 3) + 1); --A7

--cl B(byte)
i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 0) + 6); --B0
i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 0); --B1
i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 1) + 1); --B2
i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 1) + 2); --B3
i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 1) + 3); --B4
i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 1) + 4); --B5
i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 3) + 2); --B6
i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 3) + 3); --B7

end if;
end process;
end generate gen_tap2_8bit;




--#################################
--BASE Configuration (20bit = 2Tap/10bit)
--#################################
gen_tap2_10bit : if (G_CL_TAP = 2) and (G_CL_PIXBIT = 10) generate begin
--!!!! cl X cahnnel !!!!
process(i_cl_rxclk(0))
begin
if rising_edge(i_cl_rxclk(0)) then
i_cl_fval(0) <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)

--cl A(byte)
i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --PortA0
i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --PortA1
i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --PortA2
i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --PortA3
i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --PortA4
i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 0) + 5); --PortA5
i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 3) + 0); --PortA6
i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 3) + 1); --PortA7
i_cl_rxbyte(0)(8) <= i_cl_rxd(0)((7 * 0) + 6); --PortB0
i_cl_rxbyte(0)(9) <= i_cl_rxd(0)((7 * 1) + 0); --PortB1

--cl B(byte)
i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 1) + 5); --PortC0
i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 6); --PortC1
i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 2) + 0); --PortC2
i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 2) + 1); --PortC3
i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 2) + 2); --PortC4
i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 2) + 3); --PortC5
i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 3) + 4); --PortC6
i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 3) + 5); --PortC7
i_cl_rxbyte(1)(8) <= i_cl_rxd(0)((7 * 1) + 3); --PortB4
i_cl_rxbyte(1)(9) <= i_cl_rxd(0)((7 * 1) + 4); --PortB5

end if;
end process;
end generate gen_tap2_10bit;




--#################################
--MEDIUM Configuration (40bit = 4Tap/10bit)
--#################################
gen_tap4_10bit : if (G_CL_TAP = 4) and (G_CL_PIXBIT = 10) generate begin
--!!!! cl X cahnnel !!!!
process(i_cl_rxclk(0))
begin
if rising_edge(i_cl_rxclk(0)) then
i_cl_fval(0) <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)

--cl A(byte)
i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --PortA0
i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --PortA1
i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --PortA2
i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --PortA3
i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --PortA4
i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 0) + 5); --PortA5
i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 3) + 0); --PortA6
i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 3) + 1); --PortA7
i_cl_rxbyte(0)(8) <= i_cl_rxd(0)((7 * 0) + 6); --PortB0
i_cl_rxbyte(0)(9) <= i_cl_rxd(0)((7 * 1) + 0); --PortB1

--cl B(byte)
i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 1) + 5); --PortC0
i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 6); --PortC1
i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 2) + 0); --PortC2
i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 2) + 1); --PortC3
i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 2) + 2); --PortC4
i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 2) + 3); --PortC5
i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 3) + 4); --PortC6
i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 3) + 5); --PortC7
i_cl_rxbyte(1)(8) <= i_cl_rxd(0)((7 * 1) + 3); --PortB4
i_cl_rxbyte(1)(9) <= i_cl_rxd(0)((7 * 1) + 4); --PortB5

end if;
end process;

--!!!! cl Y cahnnel !!!!
process(i_cl_rxclk(1))
begin
if rising_edge(i_cl_rxclk(1)) then
i_cl_fval(1) <= i_cl_rxd(1)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(1) <= i_cl_rxd(1)((7 * 2) + 4); --LVAL(Line value)

--cl C(byte)
i_cl_rxbyte(2)(0) <= i_cl_rxd(1)((7 * 0) + 0); --PortD0
i_cl_rxbyte(2)(1) <= i_cl_rxd(1)((7 * 0) + 1); --PortD1
i_cl_rxbyte(2)(2) <= i_cl_rxd(1)((7 * 0) + 2); --PortD2
i_cl_rxbyte(2)(3) <= i_cl_rxd(1)((7 * 0) + 3); --PortD3
i_cl_rxbyte(2)(4) <= i_cl_rxd(1)((7 * 0) + 4); --PortD4
i_cl_rxbyte(2)(5) <= i_cl_rxd(1)((7 * 0) + 5); --PortD5
i_cl_rxbyte(2)(6) <= i_cl_rxd(1)((7 * 3) + 0); --PortD6
i_cl_rxbyte(2)(7) <= i_cl_rxd(1)((7 * 3) + 1); --PortD7
i_cl_rxbyte(2)(4) <= i_cl_rxd(1)((7 * 2) + 2); --PortF4
i_cl_rxbyte(2)(5) <= i_cl_rxd(1)((7 * 2) + 3); --PortF5

--cl D(byte)
i_cl_rxbyte(3)(0) <= i_cl_rxd(1)((7 * 0) + 6); --PortE0
i_cl_rxbyte(3)(1) <= i_cl_rxd(1)((7 * 1) + 0); --PortE1
i_cl_rxbyte(3)(2) <= i_cl_rxd(1)((7 * 1) + 1); --PortE2
i_cl_rxbyte(3)(3) <= i_cl_rxd(1)((7 * 1) + 2); --PortE3
i_cl_rxbyte(3)(4) <= i_cl_rxd(1)((7 * 1) + 3); --PortE4
i_cl_rxbyte(3)(5) <= i_cl_rxd(1)((7 * 1) + 4); --PortE5
i_cl_rxbyte(3)(6) <= i_cl_rxd(1)((7 * 3) + 2); --PortE6
i_cl_rxbyte(3)(7) <= i_cl_rxd(1)((7 * 3) + 3); --PortE7
i_cl_rxbyte(3)(8) <= i_cl_rxd(1)((7 * 1) + 5); --PortF0
i_cl_rxbyte(3)(9) <= i_cl_rxd(1)((7 * 1) + 6); --PortF1

end if;
end process;

end generate gen_tap4_10bit;






--#########################################
--DBG
--#########################################
--p_out_tst <= (others => '0');


--i_dbg.clx.core <= i_cl_core_dbg(0);
--i_dbg.clx.lval <= i_cl_lval(0);
--i_dbg.clx.fval <= i_cl_fval(0);
--i_dbg.rxbyte(0) <= i_cl_rxbyte(0);
--i_dbg.rxbyte(1) <= i_cl_rxbyte(1);
--i_dbg.rxbyte(2) <= i_cl_rxbyte(2);
--
--
--dbg_cl : ila_dbg_cl
--port map(
--clk => i_cl_tstout(0)(1), --g_cl_clkin_7xdiv4
--probe0(0) => i_dbg.clx.core.sync,
--probe0(4 downto 1) => i_dbg.clx.core.des_d,
--probe0(5) => i_dbg.clx.core.idelay_inc,
--probe0(6) => i_dbg.clx.core.idelay_ce,
--probe0(15 downto 7) => i_dbg.clx.core.idelay_oval((9 * 1) - 1 downto (9 * 0)),
--probe0(19 downto 16) => std_logic_vector(i_dbg.clx.core.sr_des_d(0)),
--probe0(23 downto 20) => std_logic_vector(i_dbg.clx.core.sr_des_d(1)),
--probe0(27 downto 24) => std_logic_vector(i_dbg.clx.core.sr_des_d(2)),
--probe0(31 downto 28) => std_logic_vector(i_dbg.clx.core.sr_des_d(3)),
--probe0(35 downto 32) => std_logic_vector(i_dbg.clx.core.sr_des_d(4)),
--probe0(39 downto 36) => std_logic_vector(i_dbg.clx.core.sr_des_d(5)),
--probe0(43 downto 40) => std_logic_vector(i_dbg.clx.core.sr_des_d(6)),
--
--probe0(44) => i_dbg.clx.core.sync_find_ok,
--probe0(45) => i_dbg.clx.core.sync_find,
--probe0(46) => i_dbg.clx.core.usr_sync,
--probe0(49 downto 47) => i_dbg.clx.core.fsm_sync
----probe0(58 downto 50) => i_dbg.clx.core.idelay_oval((9 * 2) - 1 downto (9 * 1))
--);
--
--
--dbg2_cl : ila_dbg2_cl
--port map(
--clk => i_cl_rxclk(0),
--probe0(0) => i_dbg.clx.core.sync_find_ok,
--probe0(7 downto 1) => i_dbg.clx.core.gearbox_do_sync_val,
--probe0(8) => i_dbg.clx.lval,
--probe0(9) => i_dbg.clx.fval,
--probe0(17 downto 10) => i_dbg.rxbyte(0),
--probe0(25 downto 18) => i_dbg.rxbyte(1),
--probe0(33 downto 26) => i_dbg.rxbyte(2),
--probe0(34) => i_dbg.clx.core.usr_2sync
--);



end architecture struct;
