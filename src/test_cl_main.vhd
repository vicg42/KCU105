-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : test_cl_main
--
-- Description : top level of project
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.clocks_pkg.all;
use work.reduce_pack.all;

entity test_cl_main is
generic(
G_CL_CHCOUNT : natural := 3
);
port(
--------------------------------------------------
--DBG
--------------------------------------------------
pin_out_led         : out   std_logic_vector(4 downto 0);
pin_in_btn          : in    std_logic_vector(1 downto 0);
pin_out_led_hpc     : out   std_logic_vector(3 downto 0);
pin_out_TP          : out   std_logic_vector(1 downto 0);

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

--pin_in_cl_xclk_p : in  std_logic;
--pin_in_cl_xclk_n : in  std_logic;
--pin_in_cl_x_p    : in  std_logic_vector(3 downto 0);
--pin_in_cl_x_n    : in  std_logic_vector(3 downto 0);
--
--pin_in_cl_yclk_p : in  std_logic;
--pin_in_cl_yclk_n : in  std_logic;
--pin_in_cl_y_p    : in  std_logic_vector(3 downto 0);
--pin_in_cl_y_n    : in  std_logic_vector(3 downto 0);

--pin_in_cl_zclk_p : in  std_logic;
--pin_in_cl_zclk_n : in  std_logic;
--pin_in_cl_z_p    : in  std_logic_vector(3 downto 0);
--pin_in_cl_z_n    : in  std_logic_vector(3 downto 0);

--------------------------------------------------
--Reference clock
--------------------------------------------------
pin_in_refclk       : in    TRefClkPinIN
);
end entity test_cl_main;

architecture struct of test_cl_main is

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

component camera_cl_main is
generic(
--G_PIXBIT : natural := 1
--G_CL_TAP : natural := 1
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--
--------------------------------------------------
p_in_cam_ctrl_rx  : in  std_logic;
p_out_cam_ctrl_tx : out std_logic;

--------------------------------------------------
--CameraLink Interface
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

----------------------------------------------------
----VideoOut
----------------------------------------------------
--p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
--p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
--p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
--p_out_rxbyte : out  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
--p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component camera_cl_main;

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
signal i_cl_tst_out        : std_logic_vector(31 downto 0);
signal i_cl_tst_in         : std_logic_vector(31 downto 0);
signal i_usr_rst           : std_logic;


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


i_usr_rst <= pin_in_btn(0);


m_cam : camera_cl_main
generic map(
--G_PIXBIT : natural := 1
--G_CL_TAP : natural := 1
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--
--------------------------------------------------
p_in_cam_ctrl_rx  => pin_in_rs232_rx ,
p_out_cam_ctrl_tx => pin_out_rs232_tx,

--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_tfg_n => pin_in_cl_tfg_n, --Camera -> FG
p_in_tfg_p => pin_in_cl_tfg_p,
p_out_tc_n => pin_out_cl_tc_n, --Camera <- FG
p_out_tc_p => pin_out_cl_tc_p,

--X,Y,Z : 0,1,2
p_in_cl_clk_p => pin_in_cl_clk_p,
p_in_cl_clk_n => pin_in_cl_clk_n,
p_in_cl_di_p  => pin_in_cl_di_p ,
p_in_cl_di_n  => pin_in_cl_di_n ,

----------------------------------------------------
----VideoOut
----------------------------------------------------
--p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
--p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
--p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
--p_out_rxbyte : out  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
--p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => i_cl_tst_out,
p_in_tst  => i_cl_tst_in,

--p_in_refclk => g_usrclk(1),
--p_in_clk => g_usrclk(0),
p_in_rst => i_usr_rst
);

i_cl_tst_in(0) <= i_btn;


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
pin_out_led(1) <= '0';
pin_out_led(2) <= '0'; --i_det
pin_out_led(3) <= i_usr_rst;
pin_out_led(4) <= '0';


pin_out_led_hpc(0) <= i_cl_tst_out(0);
pin_out_led_hpc(1) <= i_cl_tst_out(1);
pin_out_led_hpc(2) <= i_cl_tst_out(2);
pin_out_led_hpc(3) <= i_cl_tst_out(3);

pin_out_TP(0) <= i_cl_tst_out(1);--PMOD1_4  (CSI)
pin_out_TP(1) <= i_cl_tst_out(2);--PMOD1_6  (SSI)


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


end architecture struct;
