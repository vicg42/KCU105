-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_main
--
-- Description :
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
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--RS232(PC)
--------------------------------------------------
p_in_rs232_rx  : in  std_logic;
p_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
p_in_tfg_n : in  std_logic; --Camera -> FG
p_in_tfg_p : in  std_logic;
p_out_tc_n : out std_logic; --Camera <- FG
p_out_tc_p : out std_logic;

--X,Y,Z : 0,1,2
p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_refclk : in std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cl_main;

architecture struct of cl_main is

component cl_core is
generic(
G_PLL_TYPE : string := "MMCM" --"PLL"
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
p_out_sync    : out std_logic;

-----------------------------
--DBG
-----------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_dbg : out  TCL_core_dbg;

-----------------------------
--System
-----------------------------
p_in_refclk : in std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cl_core;

signal i_cl_fval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_lval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

type TCL_rxd is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(27 downto 0);
signal i_cl_rxd        : TCL_rxd;
signal i_cl_rxclk      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_sync       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
type TCL_tstout is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(31 downto 0);
signal i_cl_tstout     : TCL_tstout;

type TCL_rxbyte is array (0 to 2) of std_logic_vector(7 downto 0);
signal i_cl_rxbyte     : TCL_rxbyte;

type TCL_core_dbgs is array (0 to G_CL_CHCOUNT - 1) of TCL_core_dbg;
signal i_cl_core_dbg   : TCL_core_dbgs;


component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(49 downto 0)
);
end component ila_dbg_cl;

component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(34 downto 0)
);
end component ila_dbg2_cl;

type TCL_dbg is record
core : TCL_core_dbg;
lval : std_logic;
fval : std_logic;
end record;

type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);

type TCLmain_dbg is record
clx : TCL_dbg;
rxbyte : TCL_rxbyte_dbg;
end record;

signal i_dbg : TCLmain_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct


m_ibufds_tfg : IBUFDS
port map (I => p_in_tfg_p, IB => p_in_tfg_n, O => p_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I => p_in_rs232_rx, O  => p_out_tc_p, OB => p_out_tc_n);



--#########################################
--CHANNEL X
--#########################################
gen_ch : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
m_ch : cl_core
generic map(
G_PLL_TYPE => "MMCM" --"PLL" --
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
p_out_sync    => i_cl_sync(i),

-----------------------------
--DBG
-----------------------------
p_out_tst => i_cl_tstout(i),
p_in_tst  => p_in_tst,
p_out_dbg => i_cl_core_dbg(i),

p_in_refclk => p_in_refclk,
p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);
end generate gen_ch;


--#################################
--Full Configuration (64bit)
--#################################
--!!!! cl X cahnnel !!!!
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

--cl C(byte)
i_cl_rxbyte(2)(0) <= i_cl_rxd(0)((7 * 1) + 5); --C0
i_cl_rxbyte(2)(1) <= i_cl_rxd(0)((7 * 1) + 6); --C1
i_cl_rxbyte(2)(2) <= i_cl_rxd(0)((7 * 2) + 0); --C2
i_cl_rxbyte(2)(3) <= i_cl_rxd(0)((7 * 2) + 1); --C3
i_cl_rxbyte(2)(4) <= i_cl_rxd(0)((7 * 2) + 2); --C4
i_cl_rxbyte(2)(5) <= i_cl_rxd(0)((7 * 2) + 3); --C5
i_cl_rxbyte(2)(6) <= i_cl_rxd(0)((7 * 3) + 4); --C6
i_cl_rxbyte(2)(7) <= i_cl_rxd(0)((7 * 3) + 5); --C7


--!!!! cl Y cahnnel !!!!
i_cl_fval(1) <= i_cl_rxd(1)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(1) <= i_cl_rxd(1)((7 * 2) + 4); --LVAL(Line value)

--cl D(byte)
i_cl_rxbyte(3)(0) <= i_cl_rxd(1)((7 * 0) + 0); --D0
i_cl_rxbyte(3)(1) <= i_cl_rxd(1)((7 * 0) + 1); --D1
i_cl_rxbyte(3)(2) <= i_cl_rxd(1)((7 * 0) + 2); --D2
i_cl_rxbyte(3)(3) <= i_cl_rxd(1)((7 * 0) + 3); --D3
i_cl_rxbyte(3)(4) <= i_cl_rxd(1)((7 * 0) + 4); --D4
i_cl_rxbyte(3)(5) <= i_cl_rxd(1)((7 * 0) + 5); --D5
i_cl_rxbyte(3)(6) <= i_cl_rxd(1)((7 * 3) + 0); --D6
i_cl_rxbyte(3)(7) <= i_cl_rxd(1)((7 * 3) + 1); --D7

--cl E(byte)
i_cl_rxbyte(4)(0) <= i_cl_rxd(1)((7 * 0) + 6); --E0
i_cl_rxbyte(4)(1) <= i_cl_rxd(1)((7 * 1) + 0); --E1
i_cl_rxbyte(4)(2) <= i_cl_rxd(1)((7 * 1) + 1); --E2
i_cl_rxbyte(4)(3) <= i_cl_rxd(1)((7 * 1) + 2); --E3
i_cl_rxbyte(4)(4) <= i_cl_rxd(1)((7 * 1) + 3); --E4
i_cl_rxbyte(4)(5) <= i_cl_rxd(1)((7 * 1) + 4); --E5
i_cl_rxbyte(4)(6) <= i_cl_rxd(1)((7 * 3) + 2); --E6
i_cl_rxbyte(4)(7) <= i_cl_rxd(1)((7 * 3) + 3); --E7

--cl F(byte)
i_cl_rxbyte(5)(0) <= i_cl_rxd(1)((7 * 1) + 5); --F0
i_cl_rxbyte(5)(1) <= i_cl_rxd(1)((7 * 1) + 6); --F1
i_cl_rxbyte(5)(2) <= i_cl_rxd(1)((7 * 2) + 0); --F2
i_cl_rxbyte(5)(3) <= i_cl_rxd(1)((7 * 2) + 1); --F3
i_cl_rxbyte(5)(4) <= i_cl_rxd(1)((7 * 2) + 2); --F4
i_cl_rxbyte(5)(5) <= i_cl_rxd(1)((7 * 2) + 3); --F5
i_cl_rxbyte(5)(6) <= i_cl_rxd(1)((7 * 3) + 4); --F6
i_cl_rxbyte(5)(7) <= i_cl_rxd(1)((7 * 3) + 5); --F7


--!!!! cl Z cahnnel !!!!
i_cl_fval(2) <= i_cl_rxd(2)((7 * 2) + 5); --FVAL(Frame value)
i_cl_lval(2) <= i_cl_rxd(2)((7 * 2) + 4); --LVAL(Line value)

--cl G(byte)
i_cl_rxbyte(6)(0) <= i_cl_rxd(2)((7 * 0) + 0); --G0
i_cl_rxbyte(6)(1) <= i_cl_rxd(2)((7 * 0) + 1); --G1
i_cl_rxbyte(6)(2) <= i_cl_rxd(2)((7 * 0) + 2); --G2
i_cl_rxbyte(6)(3) <= i_cl_rxd(2)((7 * 0) + 3); --G3
i_cl_rxbyte(6)(4) <= i_cl_rxd(2)((7 * 0) + 4); --G4
i_cl_rxbyte(6)(5) <= i_cl_rxd(2)((7 * 0) + 5); --G5
i_cl_rxbyte(6)(6) <= i_cl_rxd(2)((7 * 3) + 0); --G6
i_cl_rxbyte(6)(7) <= i_cl_rxd(2)((7 * 3) + 1); --G7

--cl H(byte)
i_cl_rxbyte(7)(0) <= i_cl_rxd(2)((7 * 0) + 6); --H0
i_cl_rxbyte(7)(1) <= i_cl_rxd(2)((7 * 1) + 0); --H1
i_cl_rxbyte(7)(2) <= i_cl_rxd(2)((7 * 1) + 1); --H2
i_cl_rxbyte(7)(3) <= i_cl_rxd(2)((7 * 1) + 2); --H3
i_cl_rxbyte(7)(4) <= i_cl_rxd(2)((7 * 1) + 3); --H4
i_cl_rxbyte(7)(5) <= i_cl_rxd(2)((7 * 1) + 4); --H5
i_cl_rxbyte(7)(6) <= i_cl_rxd(2)((7 * 3) + 2); --H6
i_cl_rxbyte(7)(7) <= i_cl_rxd(2)((7 * 3) + 3); --H7



----#################################
----Full Configuration (80bit = 10Tap/8bit)
----#################################
----!!!! cl X cahnnel !!!!
--i_cl_fval    <= i_cl_rxd(0)((7 * 2) + 5); --FVAL(Frame value)
--i_cl_lval(0) <= i_cl_rxd(0)((7 * 2) + 4); --LVAL(Line value)
--
----cl A(byte)
--i_cl_rxbyte(0)(0) <= i_cl_rxd(0)((7 * 0) + 0); --A0
--i_cl_rxbyte(0)(1) <= i_cl_rxd(0)((7 * 0) + 1); --A1
--i_cl_rxbyte(0)(2) <= i_cl_rxd(0)((7 * 0) + 2); --A2
--i_cl_rxbyte(0)(3) <= i_cl_rxd(0)((7 * 0) + 3); --A3
--i_cl_rxbyte(0)(4) <= i_cl_rxd(0)((7 * 0) + 4); --A4
--i_cl_rxbyte(0)(5) <= i_cl_rxd(0)((7 * 3) + 1); --A5
--i_cl_rxbyte(0)(6) <= i_cl_rxd(0)((7 * 0) + 5); --A6
--i_cl_rxbyte(0)(7) <= i_cl_rxd(0)((7 * 0) + 6); --A7
--
----cl B(byte)
--i_cl_rxbyte(1)(0) <= i_cl_rxd(0)((7 * 1) + 0); --B0
--i_cl_rxbyte(1)(1) <= i_cl_rxd(0)((7 * 1) + 1); --B1
--i_cl_rxbyte(1)(2) <= i_cl_rxd(0)((7 * 3) + 2); --B2
--i_cl_rxbyte(1)(3) <= i_cl_rxd(0)((7 * 3) + 3); --B3
--i_cl_rxbyte(1)(4) <= i_cl_rxd(0)((7 * 1) + 2); --B4
--i_cl_rxbyte(1)(5) <= i_cl_rxd(0)((7 * 1) + 3); --B5
--i_cl_rxbyte(1)(6) <= i_cl_rxd(0)((7 * 1) + 4); --B6
--i_cl_rxbyte(1)(7) <= i_cl_rxd(0)((7 * 1) + 5); --B7
--
----cl C(byte)
--i_cl_rxbyte(2)(0) <= i_cl_rxd(0)((7 * 3) + 4); --C0
--i_cl_rxbyte(2)(1) <= i_cl_rxd(0)((7 * 3) + 5); --C1
--i_cl_rxbyte(2)(2) <= i_cl_rxd(0)((7 * 1) + 6); --C2
--i_cl_rxbyte(2)(3) <= i_cl_rxd(0)((7 * 2) + 0); --C3
--i_cl_rxbyte(2)(4) <= i_cl_rxd(0)((7 * 2) + 1); --C4
--i_cl_rxbyte(2)(5) <= i_cl_rxd(0)((7 * 2) + 2); --C5
--i_cl_rxbyte(2)(6) <= i_cl_rxd(0)((7 * 2) + 3); --C6
--i_cl_rxbyte(2)(7) <= i_cl_rxd(0)((7 * 3) + 6); --C7

----cl D(byte)
--i_cl_rxbyte(3)(0) <= i_cl_rxd(0)((7 * 2) + 6); --D0
--i_cl_rxbyte(3)(1) <= i_cl_rxd(0)((7 * 3) + 0); --D1
--
--
----!!!! cl Y cahnnel !!!!
--i_cl_lval(1) <= i_cl_rxd(1)((7 * 3) + 0); --LVAL(Line value)
--
--i_cl_rxbyte(3)(2) <= i_cl_rxd(1)((7 * 0) + 0); --D2
--i_cl_rxbyte(3)(3) <= i_cl_rxd(1)((7 * 0) + 1); --D3
--i_cl_rxbyte(3)(4) <= i_cl_rxd(1)((7 * 0) + 2); --D4
--i_cl_rxbyte(3)(5) <= i_cl_rxd(1)((7 * 0) + 3); --D5
--i_cl_rxbyte(3)(6) <= i_cl_rxd(1)((7 * 0) + 4); --D6
--i_cl_rxbyte(3)(7) <= i_cl_rxd(1)((7 * 3) + 1); --D7
--
----cl E(byte)
--i_cl_rxbyte(4)(0) <= i_cl_rxd(0)((7 * 0) + 5); --E0
--i_cl_rxbyte(4)(1) <= i_cl_rxd(0)((7 * 0) + 6); --E1
--i_cl_rxbyte(4)(2) <= i_cl_rxd(1)((7 * 1) + 0); --E2
--i_cl_rxbyte(4)(3) <= i_cl_rxd(1)((7 * 1) + 1); --E3
--i_cl_rxbyte(4)(4) <= i_cl_rxd(1)((7 * 3) + 2); --E4
--i_cl_rxbyte(4)(5) <= i_cl_rxd(1)((7 * 3) + 3); --E5
--i_cl_rxbyte(4)(6) <= i_cl_rxd(1)((7 * 1) + 2); --E6
--i_cl_rxbyte(4)(7) <= i_cl_rxd(1)((7 * 1) + 3); --E7
--
----cl F(byte)
--i_cl_rxbyte(5)(0) <= i_cl_rxd(1)((7 * 1) + 4); --F0
--i_cl_rxbyte(5)(1) <= i_cl_rxd(1)((7 * 1) + 5); --F1
--i_cl_rxbyte(5)(2) <= i_cl_rxd(1)((7 * 3) + 4); --F2
--i_cl_rxbyte(5)(3) <= i_cl_rxd(1)((7 * 3) + 5); --F3
--i_cl_rxbyte(5)(4) <= i_cl_rxd(1)((7 * 1) + 6); --F4
--i_cl_rxbyte(5)(5) <= i_cl_rxd(1)((7 * 2) + 0); --F5
--i_cl_rxbyte(5)(6) <= i_cl_rxd(1)((7 * 2) + 1); --F6
--i_cl_rxbyte(5)(7) <= i_cl_rxd(1)((7 * 2) + 2); --F7
--
----cl G(byte)
--i_cl_rxbyte(6)(0) <= i_cl_rxd(1)((7 * 2) + 3); --G0
--i_cl_rxbyte(6)(1) <= i_cl_rxd(1)((7 * 3) + 6); --G1
--i_cl_rxbyte(6)(2) <= i_cl_rxd(1)((7 * 2) + 4); --G2
--i_cl_rxbyte(6)(3) <= i_cl_rxd(1)((7 * 2) + 5); --G3
--i_cl_rxbyte(6)(4) <= i_cl_rxd(1)((7 * 2) + 6); --G4
--
--
----!!!! cl Y cahnnel !!!!
--i_cl_lval(2) <= i_cl_rxd(2)((7 * 3) + 0); --LVAL(Line value)
--
--i_cl_rxbyte(6)(5) <= i_cl_rxd(2)((7 * 0) + 0); --G5
--i_cl_rxbyte(6)(6) <= i_cl_rxd(2)((7 * 0) + 1); --G6
--i_cl_rxbyte(6)(7) <= i_cl_rxd(2)((7 * 0) + 2); --G7
--
----cl H(byte)
--i_cl_rxbyte(7)(0) <= i_cl_rxd(2)((7 * 0) + 3); --H0
--i_cl_rxbyte(7)(1) <= i_cl_rxd(2)((7 * 0) + 4); --H1
--i_cl_rxbyte(7)(2) <= i_cl_rxd(2)((7 * 3) + 1); --H2
--i_cl_rxbyte(7)(3) <= i_cl_rxd(2)((7 * 0) + 5); --H3
--i_cl_rxbyte(7)(4) <= i_cl_rxd(2)((7 * 0) + 6); --H4
--i_cl_rxbyte(7)(5) <= i_cl_rxd(2)((7 * 1) + 0); --H5
--i_cl_rxbyte(7)(6) <= i_cl_rxd(2)((7 * 1) + 1); --H6
--i_cl_rxbyte(7)(7) <= i_cl_rxd(2)((7 * 3) + 2); --H7
--
----cl I(byte)
--i_cl_rxbyte(8)(0) <= i_cl_rxd(2)((7 * 3) + 3); --I0
--i_cl_rxbyte(8)(1) <= i_cl_rxd(2)((7 * 1) + 2); --I1
--i_cl_rxbyte(8)(2) <= i_cl_rxd(2)((7 * 1) + 3); --I2
--i_cl_rxbyte(8)(3) <= i_cl_rxd(2)((7 * 1) + 4); --I3
--i_cl_rxbyte(8)(4) <= i_cl_rxd(2)((7 * 1) + 5); --I4
--i_cl_rxbyte(8)(5) <= i_cl_rxd(2)((7 * 3) + 4); --I5
--i_cl_rxbyte(8)(6) <= i_cl_rxd(2)((7 * 3) + 5); --I6
--i_cl_rxbyte(8)(7) <= i_cl_rxd(2)((7 * 1) + 6); --I7
--
----cl J(byte)
--i_cl_rxbyte(9)(0) <= i_cl_rxd(2)((7 * 2) + 0); --J0
--i_cl_rxbyte(9)(1) <= i_cl_rxd(2)((7 * 2) + 1); --J1
--i_cl_rxbyte(9)(2) <= i_cl_rxd(2)((7 * 2) + 2); --J2
--i_cl_rxbyte(9)(3) <= i_cl_rxd(2)((7 * 2) + 3); --J3
--i_cl_rxbyte(9)(4) <= i_cl_rxd(2)((7 * 3) + 6); --J4
--i_cl_rxbyte(9)(5) <= i_cl_rxd(2)((7 * 2) + 4); --J5
--i_cl_rxbyte(9)(6) <= i_cl_rxd(2)((7 * 2) + 5); --J6
--i_cl_rxbyte(9)(7) <= i_cl_rxd(2)((7 * 2) + 6); --J7




--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_cl_tstout(0)(0);
p_out_tst(1) <= i_cl_fval(0);
p_out_tst(2) <= i_cl_lval(0);


i_dbg.clx.core <= i_cl_core_dbg(0);
i_dbg.clx.lval <= i_cl_lval(0);
i_dbg.clx.fval <= i_cl_fval(0);
i_dbg.rxbyte(0) <= i_cl_rxbyte(0);
i_dbg.rxbyte(1) <= i_cl_rxbyte(1);
i_dbg.rxbyte(2) <= i_cl_rxbyte(2);


dbg_cl : ila_dbg_cl
port map(
clk => i_cl_tstout(0)(1), --g_cl_clkin_7xdiv4
probe0(0) => i_dbg.clx.core.sync,
probe0(4 downto 1) => i_dbg.clx.core.des_d,
probe0(5) => i_dbg.clx.core.idelay_inc,
probe0(6) => i_dbg.clx.core.idelay_ce,
probe0(15 downto 7) => i_dbg.clx.core.idelay_oval,
probe0(19 downto 16) => std_logic_vector(i_dbg.clx.core.sr_des_d(0)),
probe0(23 downto 20) => std_logic_vector(i_dbg.clx.core.sr_des_d(1)),
probe0(27 downto 24) => std_logic_vector(i_dbg.clx.core.sr_des_d(2)),
probe0(31 downto 28) => std_logic_vector(i_dbg.clx.core.sr_des_d(3)),
probe0(35 downto 32) => std_logic_vector(i_dbg.clx.core.sr_des_d(4)),
probe0(39 downto 36) => std_logic_vector(i_dbg.clx.core.sr_des_d(5)),
probe0(43 downto 40) => std_logic_vector(i_dbg.clx.core.sr_des_d(6)),

probe0(44) => i_dbg.clx.core.sync_find_ok,
probe0(45) => i_dbg.clx.core.sync_find,
probe0(46) => i_dbg.clx.core.usr_sync,
probe0(49 downto 47) => i_dbg.clx.core.fsm_sync
);


dbg2_cl : ila_dbg2_cl
port map(
clk => i_cl_rxclk(0),
probe0(0) => i_dbg.clx.core.sync_find_ok,
probe0(7 downto 1) => i_dbg.clx.core.gearbox_do_sync_val,
probe0(8) => i_dbg.clx.lval,
probe0(9) => i_dbg.clx.fval,
probe0(17 downto 10) => i_dbg.rxbyte(0),
probe0(25 downto 18) => i_dbg.rxbyte(1),
probe0(33 downto 26) => i_dbg.rxbyte(2),
probe0(34) => i_dbg.clx.core.usr_2sync
);



end architecture struct;
