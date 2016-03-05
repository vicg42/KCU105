-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : test_cl_core_main
--
-- Description : top level of project
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.clocks_pkg.all;
use work.reduce_pack.all;
use work.cam_cl_pkg.all;
use work.cl_pkg.all;

entity test_cl_core_main is
generic(
G_CL_CHCOUNT : natural := 3;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_out_led         : out   std_logic_vector(4 downto 0);
pin_in_btn          : in    std_logic_vector(1 downto 0);
pin_out_led_hpc     : out   std_logic_vector(3 downto 0);
--pin_out_TP          : out   std_logic_vector(1 downto 0);

--------------------------------------------------
--RS232(PC)
--------------------------------------------------
pin_in_rs232_rx  : in  std_logic;
pin_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
pin_in_cl_tfg_n : in  std_logic;
pin_in_cl_tfg_p : in  std_logic;
pin_out_cl_tc_n : out std_logic;
pin_out_cl_tc_p : out std_logic;

--X,Y,Z : 0,1,2
pin_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
pin_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
pin_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
pin_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--Reference clock
--------------------------------------------------
pin_in_refclk       : in    TRefClkPinIN
);
end entity test_cl_core_main;

architecture struct of test_cl_core_main is

constant G_CL_PIXBIT  : natural := 8; --Number of bit per 1 pix
constant G_CL_TAP     : natural := 8; --Number of pixel per 1 clk


component clocks
port(
p_out_rst  : out   std_logic;
p_out_gclk : out   std_logic_vector(7 downto 0);

p_in_clkopt: in    std_logic_vector(3 downto 0);
p_in_clk   : in    TRefClkPinIN
);
end component clocks;

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

component cl_main is
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
p_out_clk_synval : out std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--------------------------------------------------
--System
--------------------------------------------------
p_in_refclk : in std_logic;
p_in_rst : in std_logic
);
end component cl_main;

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


signal i_btn               : std_logic;
signal i_1ms               : std_logic;

signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal i_test_led          : std_logic_vector(0 downto 0);
signal i_usr_rst           : std_logic;

signal i_link_total        : std_logic;

signal i_plllock           : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_link              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_fval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
signal i_lval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
signal i_dval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
signal i_rxbyte            : std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
signal i_rxclk             : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

type TCL_Tst0 is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(0 to 1);
signal sr_fval             : TCL_Tst0;
signal sr_lval             : TCL_Tst0;
signal tst_fval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal tst_fval_edge1      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--signal tst_lval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--signal tst_lval_edge1      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal sr_fval_t           : std_logic_vector(0 to 1);
signal sr_lval_t           : std_logic_vector(0 to 1);
signal tst_fval_t_edge0    : std_logic;
signal tst_fval_t_edge1    : std_logic;
--signal tst_lval_t_edge0    : std_logic;
--signal tst_lval_t_edge1    : std_logic;

signal tst_clk_synval   : std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);

signal i_cam_tst_in        : std_logic_vector(2 downto 0);
signal i_dbg           : TCLDBG_CHs;



component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(35 downto 0)
);
end component ila_dbg2_cl;


attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";


begin --architecture struct


--***********************************************************
--
--***********************************************************
m_clocks : clocks
port map(
p_out_rst  => i_usrclk_rst,
p_out_gclk => g_usrclk,

p_in_clkopt => (others => '0'),
--p_out_clk  => pin_out_refclk,
p_in_clk   => pin_in_refclk
);


--i_usr_rst <= pin_in_btn(0) or i_usrclk_rst;


m_cam_core : cl_main
generic map(
G_DCM_TYPE => (C_CL_PLL, C_CL_PLL, C_CL_MMCM),
G_DCM_CLKIN_PERIOD   => 11.764000, --85MHz => clkx7 = ((85/1)*14)/2 = 1190/2 = 595MHz
G_DCM_DIVCLK_DIVIDE  => 1,
G_DCM_CLKFBOUT_MULT  => 14,
G_DCM_CLKOUT0_DIVIDE => 2,
G_CL_PIXBIT => G_CL_PIXBIT,
G_CL_TAP => G_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p => pin_in_cl_clk_p,
p_in_cl_clk_n => pin_in_cl_clk_n,
p_in_cl_di_p  => pin_in_cl_di_p ,
p_in_cl_di_n  => pin_in_cl_di_n ,

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_plllock => i_plllock,
p_out_link   => i_link  ,
p_out_fval   => i_fval  ,
p_out_lval   => i_lval  ,
p_out_dval   => i_dval  ,
p_out_rxbyte => i_rxbyte,
p_out_rxclk  => i_rxclk ,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_clk_synval => tst_clk_synval,
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--------------------------------------------------
--System
--------------------------------------------------
p_in_refclk => '0',
p_in_rst => pin_in_btn(0) --i_usr_rst
);




--#########################################
--DBG
--#########################################
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
pin_out_led(1) <= i_usr_rst;

gen_plllock_on : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
pin_out_led(2 + i) <= i_plllock(i);
pin_out_led_hpc(1 + i) <= i_link(i);
end generate gen_plllock_on;

gen_plllock_off : if (G_CL_CHCOUNT < 3) generate begin
gen : for i in G_CL_CHCOUNT to (3 - 1) generate begin
pin_out_led(2 + i) <= '0';
pin_out_led_hpc(1 + i) <= '0';
end generate gen;
end generate gen_plllock_off;

pin_out_led_hpc(0) <= i_link_total;
--pin_out_led_hpc(1) <= i_link(0);
--pin_out_led_hpc(2) <= i_link(1);
--pin_out_led_hpc(3) <= i_link(2);

--pin_out_TP(0) <= '0';--PMOD1_4  (CSI)
--pin_out_TP(1) <= '0';--PMOD1_6  (SSI)


--i_cam_tst_in(0) <= i_btn;

i_link_total <= AND_reduce(i_link);

--test ctrl camera VITA25K
m_ibufds_tfg : IBUFDS
port map (I => pin_in_cl_tfg_p, IB => pin_in_cl_tfg_n, O => pin_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I => pin_in_rs232_rx, O  => pin_out_cl_tc_p, OB => pin_out_cl_tc_n);


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




i_dbg(0).clk <= i_rxclk(0);
i_dbg(0).link <= i_link(0);
i_dbg(0).fval <= i_fval(0);
i_dbg(0).lval <= i_lval(0);
i_dbg(0).fval_edge0 <= tst_fval_edge0(0);
i_dbg(0).fval_edge1 <= tst_fval_edge1(0);
--i_dbg.cl(0).lval_edge0 <= tst_lval_edge0(0);
--i_dbg.cl(0).lval_edge1 <= tst_lval_edge1(0);
i_dbg(0).rxbyte(0) <= i_rxbyte((8 * (0 + 1)) - 1 downto (8 * 0));
i_dbg(0).rxbyte(1) <= i_rxbyte((8 * (1 + 1)) - 1 downto (8 * 1));
i_dbg(0).rxbyte(2) <= i_rxbyte((8 * (2 + 1)) - 1 downto (8 * 2));
i_dbg(0).clk_synval <= tst_clk_synval((7 * (0 + 1)) - 1 downto (7 * 0));

i_dbg(1).clk <= i_rxclk(1);
i_dbg(1).link <= i_link(1);
i_dbg(1).fval <= i_fval(1);
i_dbg(1).lval <= i_lval(1);
i_dbg(1).fval_edge0 <= tst_fval_edge0(1);
i_dbg(1).fval_edge1 <= tst_fval_edge1(1);
--i_dbg(1).lval_edge0 <= tst_lval_edge0(1);
--i_dbg(1).lval_edge1 <= tst_lval_edge1(1);
i_dbg(1).rxbyte(0) <= i_rxbyte((8 * (3 + 1)) - 1 downto (8 * 3));
i_dbg(1).rxbyte(1) <= i_rxbyte((8 * (4 + 1)) - 1 downto (8 * 4));
i_dbg(1).rxbyte(2) <= i_rxbyte((8 * (5 + 1)) - 1 downto (8 * 5));
i_dbg(1).clk_synval <= tst_clk_synval((7 * (1 + 1)) - 1 downto (7 * 1));

i_dbg(2).clk <= i_rxclk(2);
i_dbg(2).link <= i_link(2);
i_dbg(2).fval <= i_fval(2);
i_dbg(2).lval <= i_lval(2);
i_dbg(2).fval_edge0 <= tst_fval_edge0(2);
i_dbg(2).fval_edge1 <= tst_fval_edge1(2);
--i_dbg(2).lval_edge0 <= tst_lval_edge0(2);
--i_dbg(2).lval_edge1 <= tst_lval_edge1(2);
i_dbg(2).rxbyte(0) <= i_rxbyte((8 * (6 + 1)) - 1 downto (8 * 6));
i_dbg(2).rxbyte(1) <= i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));
i_dbg(2).rxbyte(2) <= (others => '0');--i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));
i_dbg(2).clk_synval <= tst_clk_synval((7 * (2 + 1)) - 1 downto (7 * 2));



gen_ch : for i in 0 to (G_CL_CHCOUNT - 1) generate begin

dbg2_cl : ila_dbg2_cl
port map(
clk                  => i_dbg(i).clk      , --i_rxclk(i), --
probe0(0)            => i_dbg(i).link     ,
probe0(1)            => i_dbg(i).fval     ,
probe0(2)            => i_dbg(i).lval     ,
probe0(10 downto 3)  => i_dbg(i).rxbyte(0),
probe0(18 downto 11) => i_dbg(i).rxbyte(1),
probe0(26 downto 19) => i_dbg(i).rxbyte(2),
probe0(27)           => i_dbg(i).fval_edge0,
probe0(28)           => i_dbg(i).fval_edge1,
probe0(35 downto 29) => i_dbg(i).clk_synval
);

process(i_rxclk(i))
begin
if rising_edge(i_rxclk(i)) then

  sr_fval(i) <= i_fval(i) & sr_fval(i)(0 to 0);
  sr_lval(i) <= i_lval(i) & sr_lval(i)(0 to 0);

  tst_fval_edge0(i) <= sr_fval(i)(0) and (not sr_fval(i)(1));
  tst_fval_edge1(i) <= (not sr_fval(i)(0)) and sr_fval(i)(1);

--  tst_lval_edge0(i) <= sr_lval(i)(0) and (not sr_lval(i)(1));
--  tst_lval_edge1(i) <= (not sr_lval(i)(0)) and sr_lval(i)(1);

end if;
end process;
end generate gen_ch;


end architecture struct;



--dbg2_clx : ila_dbg2_cl
--port map(
--clk                  => i_dbg(0).clk      , --i_rxclk(0), --
--probe0(0)            => i_dbg(0).link     ,
--probe0(1)            => i_dbg(0).fval     ,
--probe0(2)            => i_dbg(0).lval     ,
--probe0(10 downto 3)  => i_dbg(0).rxbyte(0),
--probe0(18 downto 11) => i_dbg(0).rxbyte(1),
--probe0(26 downto 19) => i_dbg(0).rxbyte(2),
--probe0(27)           => i_dbg(0).fval_edge0,
--probe0(28)           => i_dbg(0).fval_edge1,
--probe0(35 downto 29) => i_dbg(0).clk_synval
--);
--
--dbg2_cly : ila_dbg2_cl
--port map(
--clk                  => i_dbg(1).clk      , --i_rxclk(1), --
--probe0(0)            => i_dbg(1).link     ,
--probe0(1)            => i_dbg(1).fval     ,
--probe0(2)            => i_dbg(1).lval     ,
--probe0(10 downto 3)  => i_dbg(1).rxbyte(0),
--probe0(18 downto 11) => i_dbg(1).rxbyte(1),
--probe0(26 downto 19) => i_dbg(1).rxbyte(2),
--probe0(27)           => i_dbg(1).fval_edge0,
--probe0(28)           => i_dbg(1).fval_edge1,
--probe0(35 downto 29) => i_dbg(1).clk_synval
--);
--
--dbg2_clz : ila_dbg2_cl
--port map(
--clk                  => i_dbg(2).clk      , --i_rxclk(2), --
--probe0(0)            => i_dbg(2).link     ,
--probe0(1)            => i_dbg(2).fval     ,
--probe0(2)            => i_dbg(2).lval     ,
--probe0(10 downto 3)  => i_dbg(2).rxbyte(0),
--probe0(18 downto 11) => i_dbg(2).rxbyte(1),
--probe0(26 downto 19) => i_dbg(2).rxbyte(2),
--probe0(27)           => i_dbg(2).fval_edge0,
--probe0(28)           => i_dbg(2).fval_edge1,
--probe0(35 downto 29) => i_dbg(2).clk_synval
--);
