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
end entity camera_cl_main;

architecture struct of camera_cl_main is

constant CI_PIXBIT : natural := 8;
constant CI_CL_TAP : natural := 8;

component cl_main is
generic(
G_PIXBIT : natural := 1;
G_CL_TAP : natural := 1;
G_CL_CHCOUNT : natural := 1
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
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cl_main;

component cl_frprm_detector is
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
--DBG
--------------------------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  : out std_logic_vector(15 downto 0);
p_out_linecount : out std_logic_vector(15 downto 0);
p_out_det_rdy   : out std_logic
);
end component cl_frprm_detector;

component cl_bufline is
generic(
G_PIXBIT : natural := 8; --Amount bit per 1 pix
G_CL_TAP : natural := 8; --Amount pixel per 1 clk
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
--DBG
--------------------------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--------------------------------------------------
--Output
--------------------------------------------------
p_out_rd_do : out  std_logic_vector(63 downto 0);
p_in_rden   : in   std_logic;
p_in_rdclk  : in   std_logic;
p_out_empty : out  std_logic;
p_out_sync  : out  std_logic
);
end component cl_bufline;

signal i_link    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_fval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
signal i_lval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
signal i_dval    : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
signal i_rxbyte  : std_logic_vector((CI_CL_TAP * CI_PIXBIT) - 1 downto 0);
signal i_rxclk   : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

signal i_link_total : std_logic;
signal i_pixcount   : std_logic_vector(15 downto 0);
signal i_linecount  : std_logic_vector(15 downto 0);
signal i_frprm_det  : std_logic;


signal i_btn           : std_logic;
signal sr_btn          : std_logic_vector(0 to 2);

component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(33 downto 0)
);
end component ila_dbg_cl;

component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(26 downto 0)
);
end component ila_dbg2_cl;

type TCLDBG_detprm is record
pixcount  : std_logic_vector(15 downto 0);
linecount : std_logic_vector(15 downto 0);
frprm_det : std_logic;
restart   : std_logic;
end record;

type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);
type TCLDBG_CH is record
link : std_logic;
fval : std_logic;
lval : std_logic;
rxbyte : TCL_rxbyte_dbg;
end record;
type TCLDBG_CHs is array (0 to 2) of TCLDBG_CH;

type TCAM_dbg is record
det : TCLDBG_detprm;
cl  : TCLDBG_CHs;
end record;

signal i_dbg : TCAM_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct

m_ibufds_tfg : IBUFDS
port map (I => p_in_tfg_p, IB => p_in_tfg_n, O => p_out_cam_ctrl_tx);

m_obufds_tc : OBUFDS
port map (I => p_in_cam_ctrl_rx, O  => p_out_tc_p, OB => p_out_tc_n);


--m_IDELAYCTRL : IDELAYCTRL
--generic map (
--SIM_DEVICE => "ULTRASCALE"  -- Set the device version (7SERIES, ULTRASCALE)
--)
--port map (
--RDY    => i_idelayctrl_rdy, -- 1-bit output: Ready output
--REFCLK => p_in_refclk     , -- 1-bit input: Reference clock input
--RST    => i_idelayctrl_rst  -- 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
--                            -- REFCLK.
--);

m_cl_if : cl_main
generic map(
G_PIXBIT => CI_PIXBIT,
G_CL_TAP => CI_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p => p_in_cl_clk_p,
p_in_cl_clk_n => p_in_cl_clk_n,
p_in_cl_di_p  => p_in_cl_di_p ,
p_in_cl_di_n  => p_in_cl_di_n ,

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_link   => i_link  ,
p_out_fval   => i_fval  ,
p_out_lval   => i_lval  ,
p_out_dval   => i_dval  ,
p_out_rxbyte => i_rxbyte,
p_out_rxclk  => i_rxclk ,

--------------------------------------------------
--DBG
--------------------------------------------------
--p_out_tst => open,
--p_in_tst  => (others => '0'),

--p_in_refclk => p_in_refclk,
--p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);


i_link_total <= AND_reduce(i_link);


--Detect resolution of video
m_frprm_detector : cl_frprm_detector
port map(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart => i_btn,

--------------------------------------------------
--video
--------------------------------------------------
p_in_link  => i_link_total,
p_in_fval  => i_fval(0),
p_in_lval  => i_lval(0),
p_in_dval  => i_dval(0),
p_in_rxclk => i_rxclk(0),

----------------------------------------------------
----DBG
----------------------------------------------------
--p_out_tst => open,
--p_in_tst  => (others => '0'),

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  => i_pixcount,
p_out_linecount => i_linecount,
p_out_det_rdy   => i_frprm_det
);



--m_cl_bufline : cl_bufline
--generic map(
--G_PIXBIT => CI_PIXBIT,
--G_CL_TAP => CI_CL_TAP,
--G_CL_CHCOUNT => G_CL_CHCOUNT
--)
--port map(
----------------------------------------------------
----Input
----------------------------------------------------
--p_in_link   => i_link_total,
--p_in_fval   => i_fval  ,
--p_in_lval   => i_lval  ,
--p_in_dval   => i_dval  ,
--p_in_rxbyte => i_rxbyte,
--p_in_rxclk  => i_rxclk ,
--
----------------------------------------------------
----Output
----------------------------------------------------
--p_out_rd_do => open,
--p_in_rden   => '0',
--p_in_rdclk  => '0',
--p_out_empty => open,
--p_out_sync  => open,
--
----------------------------------------------------
----DBG
----------------------------------------------------
--p_out_tst => open,
--p_in_tst  => (others => '0')
--);



--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_link_total;
gen_tp1_link : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
p_out_tst(1 + i) <= i_link(i);
end generate gen_tp1_link;

gen_tp2_link : if (G_CL_CHCOUNT < C_CL_CHCOUNT_MAX) generate begin
gen : for i in G_CL_CHCOUNT to (C_CL_CHCOUNT_MAX - 1) generate begin
p_out_tst(1 + i) <= '0';
end generate gen;
end generate gen_tp2_link;

p_out_tst(4) <= i_fval(0);
p_out_tst(5) <= i_lval(0);


i_dbg.det.pixcount  <= i_pixcount;
i_dbg.det.linecount <= i_linecount;
i_dbg.det.frprm_det <= i_frprm_det;
i_dbg.det.restart <= i_btn;

i_dbg.cl(0).link <= i_link(0);
i_dbg.cl(0).fval <= i_fval(0);
i_dbg.cl(0).lval <= i_lval(0);
i_dbg.cl(0).rxbyte(0) <= i_rxbyte((8 * (0 + 1)) - 1 downto (8 * 0));
i_dbg.cl(0).rxbyte(1) <= i_rxbyte((8 * (1 + 1)) - 1 downto (8 * 1));
i_dbg.cl(0).rxbyte(2) <= i_rxbyte((8 * (2 + 1)) - 1 downto (8 * 2));

i_dbg.cl(1).link <= i_link(1);
i_dbg.cl(1).fval <= i_fval(1);
i_dbg.cl(1).lval <= i_lval(1);
i_dbg.cl(1).rxbyte(0) <= i_rxbyte((8 * (3 + 1)) - 1 downto (8 * 3));
i_dbg.cl(1).rxbyte(1) <= i_rxbyte((8 * (4 + 1)) - 1 downto (8 * 4));
i_dbg.cl(1).rxbyte(2) <= i_rxbyte((8 * (5 + 1)) - 1 downto (8 * 5));

i_dbg.cl(2).link <= i_link(2);
i_dbg.cl(2).fval <= i_fval(2);
i_dbg.cl(2).lval <= i_lval(2);
i_dbg.cl(2).rxbyte(0) <= i_rxbyte((8 * (6 + 1)) - 1 downto (8 * 6));
i_dbg.cl(2).rxbyte(1) <= i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));
i_dbg.cl(2).rxbyte(2) <= i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));


dbg_prm : ila_dbg_cl
port map(
clk       => i_rxclk(0),
probe0(0) => i_dbg.det.frprm_det,
probe0(16 downto 1) => i_dbg.det.pixcount,
probe0(32 downto 17) => i_dbg.det.linecount,
probe0(33) => i_dbg.det.restart

);

dbg2_clx : ila_dbg2_cl
port map(
clk                  => i_rxclk(0),
probe0(0)            => i_dbg.cl(0).link     ,
probe0(1)            => i_dbg.cl(0).fval     ,
probe0(2)            => i_dbg.cl(0).lval     ,
probe0(10 downto 3)  => i_dbg.cl(0).rxbyte(0),
probe0(18 downto 11) => i_dbg.cl(0).rxbyte(1),
probe0(26 downto 19) => i_dbg.cl(0).rxbyte(2)
);

dbg2_cly : ila_dbg2_cl
port map(
clk                  => i_rxclk(1),
probe0(0)            => i_dbg.cl(1).link     ,
probe0(1)            => i_dbg.cl(1).fval     ,
probe0(2)            => i_dbg.cl(1).lval     ,
probe0(10 downto 3)  => i_dbg.cl(1).rxbyte(0),
probe0(18 downto 11) => i_dbg.cl(1).rxbyte(1),
probe0(26 downto 19) => i_dbg.cl(1).rxbyte(2)
);

dbg2_clz : ila_dbg2_cl
port map(
clk                  => i_rxclk(2),
probe0(0)            => i_dbg.cl(2).link     ,
probe0(1)            => i_dbg.cl(2).fval     ,
probe0(2)            => i_dbg.cl(2).lval     ,
probe0(10 downto 3)  => i_dbg.cl(2).rxbyte(0),
probe0(18 downto 11) => i_dbg.cl(2).rxbyte(1),
probe0(26 downto 19) => i_dbg.cl(2).rxbyte(2)
);


process(i_link_total, i_rxclk(0))
begin
if (i_link_total = '0') then
  sr_btn <= (others => '0');
  i_btn <= '0';
elsif rising_edge(i_rxclk(0)) then
  sr_btn <= p_in_tst(0) & sr_btn(0 to 1);
  i_btn <= sr_btn(1) and (not sr_btn(2));
end if;
end process;


end architecture struct;
