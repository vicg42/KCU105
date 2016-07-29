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
use work.cam_cl_pkg.all;

entity test_cl_main is
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
G_BLINK_T05 : integer:=10#125#; -- 1/2 периода мигани€ светодиода.(врем€ в ms)
G_CLK_T05us : integer:=10#1000# -- кол-во периодов частоты порта p_in_clk
                                -- укладывающиес€ в 1/2 периода 1us
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

component cam_cl_main is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTECOUNT : natural := 16;
G_PKT_PIXCHUNK_BYTECOUNT : natural := 1024;
G_CL_PIXBIT : natural := 1; --Number of bit per 1 pix
G_CL_TAP : natural := 8; --Number of pixel per 1 clk
G_CL_CHCOUNT : natural := 1;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--
--------------------------------------------------
--p_in_cam_ctrl_rx  : in  std_logic;
--p_out_cam_ctrl_tx : out std_logic;
p_in_time         : in  std_logic_vector(31 downto 0);

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

--------------------------------------------------
--VideoPkt Output
--------------------------------------------------
p_out_bufpkt_d     : out  std_logic_vector(63 downto 0);
p_in_bufpkt_rd     : in   std_logic;
p_in_bufpkt_rdclk  : in   std_logic;
p_out_bufpkt_empty : out  std_logic;

--------------------------------------------------
--
--------------------------------------------------
p_out_status   : out  std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(2 downto 0);
p_in_tst  : in   std_logic_vector(2 downto 0);
p_out_dbg : out  TCAM_dbg;

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cam_cl_main;

component debounce is
generic(
G_PUSH_LEVEL : std_logic := '0'; --Ћог. уровень когда кнопка нажата
G_DEBVAL : integer := 4
);
port(
p_in_btn  : in    std_logic;
p_out_btn : out   std_logic;

p_in_clk_en : in    std_logic;
p_in_clk    : in    std_logic
);
end component debounce;

component sync is
generic(
G_T100us : natural := 64 --100us/(1/clk_ferq) , clk_ferq=125MHz
);
port(
--p_in_time_set  : in  std_logic;
p_in_time_val  : in  std_logic_vector(31 downto 0);
p_out_time     : out std_logic_vector(31 downto 0);

----Input synchrotization
--p_in_sync_src    : in std_logic_vector(2 downto 0); --source of sync
--p_in_sync_pps    : in std_logic; --1 strobe per 1 sec
--p_in_sync_ext_1m : in std_logic;
--p_in_sync_ext_1s : in std_logic;
--p_in_sync_iedge  : in std_logic; --управл€ющие фронты входов внешней синхронизации (0-rissing)
--
----Device synchrotization
--p_in_sync_oedge   : in std_logic; --управл€ющие фронты выходов на внешнюю синхронизацию (0-rissing)
--p_out_dev_sync_1m : out  std_logic;
--p_out_dev_sync_1s : out  std_logic;
--p_out_dev_sync_120Hz: out  std_logic;

-------------------------------
--System
-------------------------------
p_in_clk : in   std_logic;
p_in_rst : in   std_logic
);
end component sync;

signal i_btn               : std_logic;
signal i_1ms               : std_logic;

signal i_usrclk_rst        : std_logic;
signal g_usrclk            : std_logic_vector(7 downto 0);
signal i_test_led          : std_logic_vector(0 downto 0);
signal i_usr_rst           : std_logic;

signal i_cam_status        : std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

signal i_cam_bufpkt_do     : std_logic_vector(63 downto 0);
signal i_cam_bufpkt_rd     : std_logic;
signal i_cam_bufpkt_empty  : std_logic;
signal i_cam_bufpkt_rdclk  : std_logic; --g_usrclk(0),

signal i_cam_tst_out       : std_logic_vector(2 downto 0);
signal i_cam_tst_in        : std_logic_vector(2 downto 0);
signal i_cam_dbg           : TCAM_dbg;

signal i_time              : std_logic_vector(31 downto 0);



component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(33 downto 0)
);
end component ila_dbg_cl;

component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(35 downto 0)
);
end component ila_dbg2_cl;

component ila_dbg_cam is
port (
clk : in std_logic;
probe0 : in std_logic_vector(70 downto 0)
);
end component ila_dbg_cam;

attribute mark_debug : string;
attribute mark_debug of i_cam_dbg  : signal is "true";


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



m_cam : cam_cl_main
generic map(
G_VCH_NUM => 0,
G_PKT_TYPE => 1,
G_PKT_HEADER_BYTECOUNT => 16,
G_PKT_PIXCHUNK_BYTECOUNT => 1024, --1280
G_CL_PIXBIT  => 8, --Number of bit per 1 pix
G_CL_TAP     => 8, --Number of pixel per 1 clk
G_CL_CHCOUNT => G_CL_CHCOUNT,
G_SIM => G_SIM
)
port map(
--------------------------------------------------
--
--------------------------------------------------
--p_in_cam_ctrl_rx  => pin_in_rs232_rx ,
--p_out_cam_ctrl_tx => pin_out_rs232_tx,
p_in_time         => i_time,

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

--------------------------------------------------
--VideoPkt Output
--------------------------------------------------
p_out_bufpkt_d     => i_cam_bufpkt_do,
p_in_bufpkt_rd     => i_cam_bufpkt_rd,
p_in_bufpkt_rdclk  => i_cam_bufpkt_rdclk, --g_usrclk(0),
p_out_bufpkt_empty => i_cam_bufpkt_empty,

--------------------------------------------------
--
--------------------------------------------------
p_out_status   => i_cam_status,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => i_cam_tst_out,
p_in_tst  => i_cam_tst_in,
p_out_dbg => i_cam_dbg,

--p_in_refclk => g_usrclk(1),
--p_in_clk => g_usrclk(0),
p_in_rst => i_usr_rst
);

i_usr_rst <= pin_in_btn(0);


i_cam_bufpkt_rd <= (not i_cam_bufpkt_empty);
i_cam_bufpkt_rdclk <= g_usrclk(0);

--i_time <= TO_UNSIGNED(16#7BBBAAAA#, i_time'length);

m_sync : sync
generic map(
G_T100us => 12500 --100us/(1/clk_ferq) , clk_ferq=125MHz
)
port map(
--p_in_time_set => '0',
p_in_time_val => (others => '0'),
p_out_time    => i_time,

----Input synchrotization
--p_in_sync_src    => "000",
--p_in_sync_pps    => '0',
--p_in_sync_ext_1m => '0',
--p_in_sync_ext_1s => '0',
--p_in_sync_iedge  => '0',
--
----Device synchrotization
--p_in_sync_oedge   => '0',
--p_out_dev_sync_1m => open,
--p_out_dev_sync_1s => open,
--p_out_dev_sync_120Hz=> open,

-------------------------------
--System
-------------------------------
p_in_clk => g_usrclk(0),
p_in_rst => i_usrclk_rst
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
pin_out_led(2) <= '0'; --i_det
pin_out_led(3) <= '0';
pin_out_led(4) <= '0';


pin_out_led_hpc(0) <= i_cam_status(C_CAM_STATUS_CL_LINKTOTAL_BIT);
pin_out_led_hpc(1) <= i_cam_status(C_CAM_STATUS_CLX_LINK_BIT);
pin_out_led_hpc(2) <= i_cam_status(C_CAM_STATUS_CLY_LINK_BIT);
pin_out_led_hpc(3) <= i_cam_status(C_CAM_STATUS_CLZ_LINK_BIT);

pin_out_TP(0) <= i_cam_tst_out(0);--PMOD1_4  (CSI)
pin_out_TP(1) <= i_cam_tst_out(1);--PMOD1_6  (SSI)


i_cam_tst_in(0) <= i_btn;
i_cam_tst_in(1) <= '0';
i_cam_tst_in(2) <= pin_in_rs232_rx;--p_in_tst(2); --cam_ctrl_rx (UART)
pin_out_rs232_tx <= i_cam_tst_out(2);--cam_ctrl_tx (UART)


m_btn : debounce
generic map(
G_PUSH_LEVEL => '1', --Ћог. уровень когда кнопка нажата
G_DEBVAL => 250
)
port map(
p_in_btn  => pin_in_btn(1),
p_out_btn => i_btn,

p_in_clk_en => i_1ms,
p_in_clk    => g_usrclk(0)
);





dbg_prm : ila_dbg_cl
port map(
clk       => i_cam_dbg.cl(0).clk,
probe0(0) => i_cam_dbg.det.frprm_det,
probe0(16 downto 1) => i_cam_dbg.det.pixcount,
probe0(32 downto 17) => i_cam_dbg.det.linecount,
probe0(33) => i_cam_dbg.det.restart

);

dbg2_clx : ila_dbg2_cl
port map(
clk                  => i_cam_dbg.cl(0).clk,
probe0(0)            => i_cam_dbg.cl(0).link     ,
probe0(1)            => i_cam_dbg.cl(0).fval     ,
probe0(2)            => i_cam_dbg.cl(0).lval     ,
probe0(10 downto 3)  => i_cam_dbg.cl(0).rxbyte(0),
probe0(18 downto 11) => i_cam_dbg.cl(0).rxbyte(1),
probe0(26 downto 19) => i_cam_dbg.cl(0).rxbyte(2),
probe0(27)           => i_cam_dbg.cl(0).fval_edge0,
probe0(28)           => i_cam_dbg.cl(0).fval_edge1,
probe0(35 downto 29) => i_cam_dbg.cl(0).clk_synval
);

dbg2_cly : ila_dbg2_cl
port map(
clk                  => i_cam_dbg.cl(1).clk,
probe0(0)            => i_cam_dbg.cl(1).link     ,
probe0(1)            => i_cam_dbg.cl(1).fval     ,
probe0(2)            => i_cam_dbg.cl(1).lval     ,
probe0(10 downto 3)  => i_cam_dbg.cl(1).rxbyte(0),
probe0(18 downto 11) => i_cam_dbg.cl(1).rxbyte(1),
probe0(26 downto 19) => i_cam_dbg.cl(1).rxbyte(2),
probe0(27)           => i_cam_dbg.cl(1).fval_edge0,
probe0(28)           => i_cam_dbg.cl(1).fval_edge1,
probe0(35 downto 29) => i_cam_dbg.cl(1).clk_synval
);

dbg2_clz : ila_dbg2_cl
port map(
clk                  => i_cam_dbg.cl(2).clk,
probe0(0)            => i_cam_dbg.cl(2).link     ,
probe0(1)            => i_cam_dbg.cl(2).fval     ,
probe0(2)            => i_cam_dbg.cl(2).lval     ,
probe0(10 downto 3)  => i_cam_dbg.cl(2).rxbyte(0),
probe0(18 downto 11) => i_cam_dbg.cl(2).rxbyte(1),
probe0(26 downto 19) => i_cam_dbg.cl(2).rxbyte(2),
probe0(27)           => i_cam_dbg.cl(2).fval_edge0,
probe0(28)           => i_cam_dbg.cl(2).fval_edge1,
probe0(35 downto 29) => i_cam_dbg.cl(2).clk_synval
);

dbg_cam : ila_dbg_cam
port map(
clk                 => i_cam_bufpkt_rdclk,
probe0(0)           => i_cam_dbg.cam.bufpkt_empty,
probe0(1)           => i_cam_dbg.cam.bufpkt_rd   ,
probe0(65 downto 2) => i_cam_dbg.cam.bufpkt_do   ,
probe0(66)          => i_cam_dbg.cam.vpkt_err    ,
probe0(67)          => i_cam_dbg.cam.fval,
probe0(68)          => i_cam_dbg.cam.lval,
probe0(69)          => i_cam_dbg.cam.fval_edge0,
probe0(70)          => i_cam_dbg.cam.fval_edge1
);

end architecture struct;
