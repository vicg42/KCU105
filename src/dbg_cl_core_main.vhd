-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : dbg_cl_core_main
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
use work.clocks_pkg.all;

entity dbg_cl_core_main is
generic(
G_DCM_TYPE : TCL_DCM_TYPE_ARRAY := (C_CL_MMCM, --type dcm for chanal 3
                                    C_CL_PLL, --type dcm for chanal 2
                                    C_CL_PLL --type dcm for chanal 1
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
pin_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
pin_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
pin_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
pin_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--VideoOut
--------------------------------------------------


--------------------------------------------------
--DBG
--------------------------------------------------
pin_out_led         : out   std_logic_vector(4 downto 0);
pin_in_btn          : in    std_logic_vector(1 downto 0);
pin_out_led_hpc     : out   std_logic_vector(3 downto 0);

pin_in_rs232_rx  : in  std_logic;
pin_out_rs232_tx : out std_logic;

pin_in_cl_tfg_n : in  std_logic;
pin_in_cl_tfg_p : in  std_logic;
pin_out_cl_tc_n : out std_logic;
pin_out_cl_tc_p : out std_logic;

pin_in_refclk       : in    TRefClkPinIN
);
end entity dbg_cl_core_main;

architecture struct of dbg_cl_core_main is

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
p_out_clk_synval : out  std_logic_vector(6 downto 0);
p_out_tst : out  std_logic;
p_in_tst  : in   std_logic;
p_out_dbg : out  TCL_core_dbg;

-----------------------------
--System
-----------------------------
p_in_idlyctrl_rdy : in std_logic;
p_out_idlyctrl_clk : out std_logic;
p_out_idlyctrl_rst : out std_logic;
p_out_plllock : out std_logic;
p_in_rst : in std_logic
);
end component cl_core;

component clocks
port(
p_out_rst  : out   std_logic;
p_out_gclk : out   std_logic_vector(7 downto 0);

p_in_clkopt: in    std_logic_vector(3 downto 0);
p_in_clk   : in    TRefClkPinIN
);
end component clocks;

component debounce is
generic(
G_PUSH_LEVEL : std_logic := '0'; --Лог. уровень когда кнопка нажата
G_DEBVAL : integer := 4
);
port(
p_in_btn  : in    std_logic;
p_out_btn : out   std_logic;

p_in_clk_en : in    std_logic;
p_in_clk    : in    std_logic
);
end component debounce;

component fpga_test_01 is
generic(
G_BLINK_T05 : integer:=10#125#; -- 1/2 периода мигания светодиода.(время в ms)
G_CLK_T05us : integer:=10#1000# -- кол-во периодов частоты порта p_in_clk
                                -- укладывающиеся в 1/2 периода 1us
);
port
(
p_out_test_led : out   std_logic;
p_out_test_done: out   std_logic;

p_out_1us      : out   std_logic;
p_out_1ms      : out   std_logic;
p_out_1s       : out   std_logic;
-------------------------------
--System
-------------------------------
p_in_clken     : in    std_logic;
p_in_clk       : in    std_logic;
p_in_rst       : in    std_logic
);
end component fpga_test_01;

signal i_cl_fval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_lval       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

type TCL_rxd is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(27 downto 0);
signal i_cl_rxd        : TCL_rxd;
signal i_cl_rxclk      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_link       : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_cl_plllock    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal g_cl_clkin_7xdiv4 : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

type TCL_rxbyte is array (0 to C_CL_TAP_MAX - 1) of std_logic_vector(G_CL_PIXBIT - 1 downto 0);
signal i_cl_rxbyte     : TCL_rxbyte;

signal g_idlyctrl_clk  : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_idlyctrl_rst  : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_idlyctrl_rdy  : std_logic;




type TCL_Tst0 is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(0 to 1);
signal sr_fval             : TCL_Tst0;
signal sr_lval             : TCL_Tst0;
signal tst_fval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal tst_lval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

signal i_clk_synval  : std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);

signal i_btn               : std_logic;
signal i_1ms               : std_logic;

signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal i_test_led          : std_logic_vector(0 downto 0);
signal i_usr_rst           : std_logic;
signal i_cl_core_rst       : std_logic;

type TCL_core_dbgs is array (0 to G_CL_CHCOUNT - 1) of TCL_core_dbg;
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
component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(34 downto 0)
);
end component ila_dbg2_cl;

component ila_dbg_cl_core is
port (
clk : in std_logic;
probe0 : in std_logic_vector(73 downto 0)
);
end component ila_dbg_cl_core;
--
--type TCL_dbg is record
--core : TCL_core_dbgs;
--lval : std_logic;
--fval : std_logic;
--end record;

type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);

type TCLmain_dbg is record
core : TCL_core_dbgs;
lval : std_logic;
fval : std_logic;
rxbyte : TCL_rxbyte_dbg;
clk_synval: std_logic_vector(6 downto 0);
lval_edge : std_logic;
fval_edge : std_logic;
end record;

signal i_dbg : TCLmain_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct

m_clocks : clocks
port map(
p_out_rst  => i_usrclk_rst,
p_out_gclk => g_usrclk,

p_in_clkopt => (others => '0'),
--p_out_clk  => pin_out_refclk,
p_in_clk   => pin_in_refclk
);

m_btn : debounce
generic map(
G_PUSH_LEVEL => '1', --Лог. уровень когда кнопка нажата
G_DEBVAL => 250
)
port map(
p_in_btn  => pin_in_btn(1),
p_out_btn => i_btn,

p_in_clk_en => i_1ms,
p_in_clk    => g_usrclk(0)
);

m_led : fpga_test_01
generic map(
G_BLINK_T05 => 10#250#,
G_CLK_T05us => 10#62#
)
port map (
p_out_test_led  => i_test_led(0),
p_out_test_done => open,

p_out_1us  => open,
p_out_1ms  => i_1ms,
p_out_1s   => open,
-------------------------------
--System
-------------------------------
p_in_clken => '1',
p_in_clk   => g_usrclk(0),
p_in_rst   => i_usrclk_rst
);

pin_out_led(0) <= i_test_led(0);
pin_out_led(1) <= pin_in_btn(0);

gen_plllock_on : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
pin_out_led(2 + i) <= i_cl_plllock(i);
pin_out_led_hpc(1 + i) <= i_cl_link(i);
end generate gen_plllock_on;

gen_plllock_off : if (G_CL_CHCOUNT < 3) generate begin
gen : for i in G_CL_CHCOUNT to (3 - 1) generate begin
pin_out_led(2 + i) <= '0';
pin_out_led_hpc(1 + i) <= '0';
end generate gen;
end generate gen_plllock_off;

pin_out_led_hpc(0) <= AND_reduce(i_cl_link);
--pin_out_led_hpc(1) <= i_cl_link(0);
--pin_out_led_hpc(2) <= '0';
--pin_out_led_hpc(3) <= '0';


--test ctrl camera VITA25K
m_ibufds_tfg : IBUFDS
port map (I => pin_in_cl_tfg_p, IB => pin_in_cl_tfg_n, O => pin_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I => pin_in_rs232_rx, O  => pin_out_cl_tc_p, OB => pin_out_cl_tc_n);


--i_cl_core_rst <= i_usrclk_rst or pin_in_btn(0);

--m_idlyctrl : IDELAYCTRL
--generic map (
--SIM_DEVICE => "ULTRASCALE"  -- Set the device version (7SERIES, ULTRASCALE)
--)
--port map (
--RDY    => i_idlyctrl_rdy,   -- 1-bit output: Ready output
--REFCLK => g_idlyctrl_clk(0),   -- 1-bit input: Reference clock input
--RST    => i_idlyctrl_rst(0) -- 1-bit input: Active high reset input.
--);
i_idlyctrl_rdy <= '1';


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
p_in_cl_clk_p => pin_in_cl_clk_p(i),
p_in_cl_clk_n => pin_in_cl_clk_n(i),
p_in_cl_di_p  => pin_in_cl_di_p((4 * (i + 1)) - 1 downto 4 * i),
p_in_cl_di_n  => pin_in_cl_di_n((4 * (i + 1)) - 1 downto 4 * i),

-----------------------------
--RxData
-----------------------------
p_out_rxd     => i_cl_rxd(i),
p_out_rxclk   => i_cl_rxclk(i),
p_out_link    => i_cl_link(i),

-----------------------------
--DBG
-----------------------------
p_out_clk_synval => i_clk_synval((7 * (i + 1)) - 1 downto 7 * i),
p_out_tst => g_cl_clkin_7xdiv4(i),
p_in_tst  => i_btn,
p_out_dbg => i_dbg.core(i),

-----------------------------
--System
-----------------------------
p_in_idlyctrl_rdy => i_idlyctrl_rdy,
p_out_idlyctrl_clk => g_idlyctrl_clk(i),
p_out_idlyctrl_rst => i_idlyctrl_rst(i),
p_out_plllock => i_cl_plllock(i),
p_in_rst => pin_in_btn(0)
);
end generate gen_ch;



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



--#########################################
--DBG
--#########################################
--p_out_tst <= (others => '0');


i_dbg.lval <= i_cl_lval(0);
i_dbg.fval <= i_cl_fval(0);
i_dbg.rxbyte(0) <= i_cl_rxbyte(0);
i_dbg.rxbyte(1) <= i_cl_rxbyte(1);
i_dbg.rxbyte(2) <= i_cl_rxbyte(2);
i_dbg.clk_synval <= i_clk_synval((7 * (0 + 1)) - 1 downto (7 * 0));

i_dbg.lval_edge <= tst_lval_edge0(0);
i_dbg.fval_edge <= tst_fval_edge0(0);


dbg2_cl : ila_dbg2_cl
port map(
clk => i_cl_rxclk(0),
probe0(0) => i_dbg.lval,
probe0(1) => i_dbg.fval,
probe0(9 downto 2) => i_dbg.rxbyte(0),
probe0(17 downto 10) => i_dbg.rxbyte(1),
probe0(25 downto 18) => i_dbg.rxbyte(2),
probe0(32 downto 26) => i_dbg.clk_synval,
probe0(33) => i_dbg.lval_edge,
probe0(34) => i_dbg.fval_edge
);


gen_tst0 : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
process(i_cl_rxclk(i))
begin
if rising_edge(i_cl_rxclk(i)) then

  sr_fval(i) <= i_cl_fval(i) & sr_fval(i)(0 to 0);
  sr_lval(i) <= i_cl_lval(i) & sr_lval(i)(0 to 0);

  tst_fval_edge0(i) <= sr_fval(i)(0) and (not sr_fval(i)(1));
--  tst_fval_edge1(i) <= (not sr_fval(i)(0)) and sr_fval(i)(1);

  tst_lval_edge0(i) <= sr_lval(i)(0) and (not sr_lval(i)(1));
--  tst_lval_edge1(i) <= (not sr_lval(i)(0)) and sr_lval(i)(1);

end if;
end process;


dbg_cl_core : ila_dbg_cl_core
port map(
clk                  => g_cl_clkin_7xdiv4(i),
probe0(0)            => i_dbg.core(i).sync_find,
probe0(1)            => i_dbg.core(i).gearbox_rst,
probe0(5 downto 2)   => std_logic_vector(i_dbg.core(i).sr_des_d(0)),
probe0(9 downto 6)   => std_logic_vector(i_dbg.core(i).sr_des_d(1)),
probe0(13 downto 10) => std_logic_vector(i_dbg.core(i).sr_des_d(2)),
probe0(17 downto 14) => std_logic_vector(i_dbg.core(i).sr_des_d(3)),
probe0(21 downto 18) => std_logic_vector(i_dbg.core(i).sr_des_d(4)),
probe0(25 downto 22) => std_logic_vector(i_dbg.core(i).sr_des_d(5)),
probe0(29 downto 26) => std_logic_vector(i_dbg.core(i).sr_des_d(6)),
probe0(38 downto 30) => i_dbg.core(i).idelay_oval,
probe0(39)           => i_dbg.core(i).idelay_inc,
probe0(40)           => i_dbg.core(i).idelay_ce,
probe0(41)           => i_dbg.core(i).idelay_vtc,
probe0(42)           => i_dbg.core(i).link,
probe0(46 downto 43) => i_dbg.core(i).fsm_sync,
probe0(53 downto 47) => i_dbg.core(i).sync_val,
probe0(56 downto 54) => i_dbg.core(i).sync_cnt,
probe0(64 downto 57) => i_dbg.core(i).usrcnt,
probe0(73 downto 65) => i_dbg.core(i).measure_cnt
);

end generate gen_tst0;


end architecture struct;
