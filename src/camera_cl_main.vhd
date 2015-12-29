-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : camera_cl_main
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

entity camera_cl_main is
generic(
--G_PIXBIT : natural := 1
--G_CL_TAP : natural := 1
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
--VideoOut
--------------------------------------------------
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_refclk : in std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity camera_cl_main;

architecture struct of camera_cl_main is

constant CI_PIXBIT : natural := 8;
constant CI_CL_TAP : natural := 8;

component cl_main is
generic(
G_PIXBIT : natural := 1
G_CL_TAP : natural := 1
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
--VideoOut
--------------------------------------------------
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_refclk : in std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cl_main;

component cl_vprm_det is
port(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart : in std_logic;

--------------------------------------------------
--video
--------------------------------------------------
p_in_link   : in std_logic;
p_in_fval   : in std_logic;
p_in_lval   : in std_logic;
p_in_dval   : in std_logic;
p_in_rxclk  : in std_logic;

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  : out std_logic_vector(15 downto 0);
p_out_linecount : out std_logic_vector(15 downto 0);
p_out_det_rdy   : out std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0)
);
end component cl_vprm_det;

component cl_bufline is
generic(
G_PIXBIT : natural := 8, --Amount bit per 1 pix
G_CL_TAP : natural := 8, --Amount pixel per 1 clk
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--Input
--------------------------------------------------
p_in_link   : in  std_logic;
p_in_fval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_in_lval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_in_dval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_in_rxbyte : in  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
p_in_rxclk  : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--Output
--------------------------------------------------
p_out_rd_do : out  std_logic_vector(63 downto 0);
p_in_rden   : in   std_logic;
p_in_rdclk  : in   std_logic;
p_out_empty : out  std_logic;
p_out_sync  : out  std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);
);
end component cl_bufline;

signal i_link    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_fval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
signal i_lval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
signal i_dval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
signal i_rxbyte  : std_logic_vector((CI_CL_TAP * CI_PIXBIT) - 1 downto 0);
signal i_rxclk   : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);


begin --architecture struct


m_cam : cl_main
generic map(
G_PIXBIT => CI_PIXBIT,
G_CL_TAP => CI_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--RS232(PC)
--------------------------------------------------
p_in_rs232_rx  : in  std_logic;
p_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
p_in_tfg_n => p_in_tfg_n, --Camera -> FG
p_in_tfg_p => p_in_tfg_p,
p_out_tc_n => p_out_tc_n, --Camera <- FG
p_out_tc_p => p_out_tc_p,

--X,Y,Z : 0,1,2
p_in_cl_clk_p => p_in_cl_clk_p,
p_in_cl_clk_n => p_in_cl_clk_n,
p_in_cl_di_p  => p_in_cl_di_p ,
p_in_cl_di_n  => p_in_cl_di_n ,

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_link   => i_link,
p_out_fval   => i_fval  ,
p_out_lval   => i_lval  ,
p_out_dval   => i_dval  ,
p_out_rxbyte => i_rxbyte,
p_out_rxclk  => i_rxclk ,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0'),

p_in_refclk : in std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);


i_link_total <= AND_reduce(i_link);


--Detect resolution of video
m_vprm_det : cl_vprm_det
port map(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart => '0',

--------------------------------------------------
--video
--------------------------------------------------
p_in_link  => i_link_total,
p_in_fval  => i_fval(0),
p_in_lval  => i_lval(0),
p_in_dval  => i_dval(0)
p_in_rxclk => i_rxclk(0),

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  => i_pixcount,
p_out_linecount => i_linecount,
p_out_det_rdy   => i_vprm_det_rdy

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0')
);



m_cl_bufline : cl_bufline
generic map(
G_PIXBIT => CI_PIXBIT,
G_CL_TAP => CI_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--Input
--------------------------------------------------
p_in_link   => i_link_total,
p_in_fval   => i_fval  ,
p_in_lval   => i_lval  ,
p_in_dval   => i_dval  ,
p_in_rxbyte => i_rxbyte,
p_in_rxclk  => i_rxclk ,

--------------------------------------------------
--Output
--------------------------------------------------
p_out_rd_do : out  std_logic_vector(63 downto 0);
p_in_rden   : in   std_logic;
p_in_rdclk  : in   std_logic;
p_out_empty : out  std_logic;
p_out_sync  : out  std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);
);







--#########################################
--DBG
--#########################################
gen_sync_ch : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
p_out_tst(i) <= i_cl_sync(i);
end generate gen_sync_ch;
p_out_tst(3) <= i_cl_fval(0);
p_out_tst(4) <= i_cl_lval(0);


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
probe0(15 downto 7) => i_dbg.clx.core.idelay_oval((9 * 1) - 1 downto (9 * 0)),
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
--probe0(58 downto 50) => i_dbg.clx.core.idelay_oval((9 * 2) - 1 downto (9 * 1))
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
