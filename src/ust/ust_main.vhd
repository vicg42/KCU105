-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.01.2016 10:23:24
-- Module Name : ust_main
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.cl_pkg.all;
use work.cam_cl_pkg.all;
use work.ust_def.all;
use work.ust_cfg.all;

entity ust_main is
generic(
G_DBGCS : string := "OFF";
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_cam0_cl_tfg_n : in  std_logic; --Camera -> FG
p_in_cam0_cl_tfg_p : in  std_logic;
p_out_cam0_cl_tc_n : out std_logic; --Camera <- FG
p_out_cam0_cl_tc_p : out std_logic;

--X,Y,Z : 0,1,2
p_in_cam0_cl_clk_p : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
p_in_cam0_cl_clk_n : in  std_logic_vector(C_USTCFG_CAM0_CL_CHCOUNT - 1 downto 0);
p_in_cam0_cl_di_p  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);
p_in_cam0_cl_di_n  : in  std_logic_vector((4 * C_USTCFG_CAM0_CL_CHCOUNT) - 1 downto 0);

p_out_cam0_status  : out  std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

--------------------------------------------------
--To ETH
--------------------------------------------------
--user -> eth
p_out_eth_tx_axi_tdata   : out  std_logic_vector(63 downto 0);
p_in_eth_tx_axi_tready   : in   std_logic;
p_out_eth_tx_axi_tvalid  : out  std_logic;
p_in_eth_tx_axi_done     : in   std_logic;
p_in_eth_clk             : in   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(3 downto 0);
p_in_tst  : in   std_logic_vector(2 downto 0);

--------------------------------------------------
--SYSTEM
--------------------------------------------------
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity ust_main;

architecture struct of ust_main is

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
p_in_time : in  std_logic_vector(31 downto 0);

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

signal i_time_init     : std_logic_vector(31 downto 0);
signal i_time          : std_logic_vector(31 downto 0);

signal i_cam0_tst_in       : std_logic_vector(2 downto 0);
signal i_cam0_tst_out      : std_logic_vector(2 downto 0);
signal i_cam0_bufpkt_do    : std_logic_vector(63 downto 0);
signal i_cam0_bufpkt_rd    : std_logic;
signal i_cam0_bufpkt_rdclk : std_logic;
signal i_cam0_bufpkt_empty : std_logic;

signal i_cam_dbg           : TCAM_dbg;

component ila_dbg_cam is
port (
clk : in std_logic;
probe0 : in std_logic_vector(75 downto 0)
);
end component ila_dbg_cam;

attribute mark_debug : string;
attribute mark_debug of i_cam_dbg  : signal is "true";



begin --architecture struct


i_time_init <= (others => '0');

m_sync : sync
generic map(
G_T100us => 12500 --100us/(1/clk_ferq) , clk_ferq=125MHz
)
port map(
--p_in_time_set => '0',
p_in_time_val => i_time_init,
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
p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);


--####################################################
--CAMERA0
--####################################################
m_cam0 : cam_cl_main
generic map(
G_VCH_NUM => C_USTCFG_CAM0_VCH_NUM,
G_PKT_TYPE => C_PKT_TYPE_VIDEO,
G_PKT_HEADER_BYTECOUNT => C_PKT_VIDEO_HDR_BCOUNT,
G_PKT_PIXCHUNK_BYTECOUNT => C_USTCFG_CAM0_PIXCHUNK_BYTECOUNT, --1280(max)
G_CL_PIXBIT  => C_USTCFG_CAM0_CL_PIXBIT, --Number of bit per 1 pix
G_CL_TAP     => C_USTCFG_CAM0_CL_TAP, --Number of pixel per 1 clk
G_CL_CHCOUNT => C_USTCFG_CAM0_CL_CHCOUNT,
G_SIM => "OFF"
)
port map(
--------------------------------------------------
--
--------------------------------------------------
p_in_time => i_time,

--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_tfg_n => p_in_cam0_cl_tfg_n, --Camera -> FG
p_in_tfg_p => p_in_cam0_cl_tfg_p,
p_out_tc_n => p_out_cam0_cl_tc_n, --Camera <- FG
p_out_tc_p => p_out_cam0_cl_tc_p,

--X,Y,Z : 0,1,2
p_in_cl_clk_p => p_in_cam0_cl_clk_p,
p_in_cl_clk_n => p_in_cam0_cl_clk_n,
p_in_cl_di_p  => p_in_cam0_cl_di_p,
p_in_cl_di_n  => p_in_cam0_cl_di_n,

--------------------------------------------------
--VideoPkt Output
--------------------------------------------------
p_out_bufpkt_d     => i_cam0_bufpkt_do,
p_in_bufpkt_rd     => i_cam0_bufpkt_rd,
p_in_bufpkt_rdclk  => i_cam0_bufpkt_rdclk,
p_out_bufpkt_empty => i_cam0_bufpkt_empty,

--------------------------------------------------
--
--------------------------------------------------
p_out_status   => p_out_cam0_status,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => i_cam0_tst_out,
p_in_tst  => i_cam0_tst_in,
p_out_dbg => i_cam_dbg,

--p_in_refclk => g_usrclk(1),
--p_in_clk => g_usrclk(0),
p_in_rst => p_in_rst
);


--####################################################
--CAMERA0 -> ETH
--####################################################
p_out_eth_tx_axi_tdata  <= i_cam0_bufpkt_do;
p_out_eth_tx_axi_tvalid <= (not i_cam0_bufpkt_empty);
i_cam0_bufpkt_rd <= p_in_eth_tx_axi_tready;
i_cam0_bufpkt_rdclk <= p_in_eth_clk;
--p_in_eth_tx_axi_done;




--#########################################
--DBG
--#########################################
i_cam0_tst_in(0) <= p_in_tst(0); --frprm_restart
i_cam0_tst_in(2) <= p_in_tst(2); --cam_ctrl_rx (UART)

p_out_tst(0) <= i_cam0_tst_out(0);--i_fval(0)
p_out_tst(1) <= i_cam0_tst_out(1);--i_lval(0)
p_out_tst(2) <= i_cam0_tst_out(2);--cam_ctrl_tx (UART)
p_out_tst(3) <= i_cam_dbg.cam.frprm_detect;


gen_dbgcs_on : if strcmp(G_DBGCS,"ON") generate
dbg_cam : ila_dbg_cam
port map(
clk                 => i_cam0_bufpkt_rdclk,
probe0(0)           => i_cam_dbg.cam.bufpkt_empty,
probe0(1)           => i_cam_dbg.cam.bufpkt_rd   ,
probe0(65 downto 2) => i_cam_dbg.cam.bufpkt_do   ,
probe0(66)          => i_cam_dbg.cam.vpkt_err    ,
probe0(67)          => i_cam_dbg.cam.fval,
probe0(68)          => i_cam_dbg.cam.lval,
probe0(69)          => i_cam_dbg.cam.fval_edge0,
probe0(70)          => i_cam_dbg.cam.fval_edge1,
probe0(71)          => i_cam_dbg.cam.frprm_detect,
probe0(72)          => i_cam_dbg.cam.vpkt_padding,
probe0(75 downto 73)=> i_cam_dbg.cam.vpkt_fsm
);
end generate gen_dbgcs_on;

end architecture struct;
