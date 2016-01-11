-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 22.07.2012 11:10:51
-- Module Name : cam_cl_tb
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.cl_pkg.all;
use work.cam_cl_pkg.all;


entity cam_cl_tb is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTE_COUNT : natural := 16; --Header Byte Count
G_PKT_PIXCHUNK_BYTE_COUNT : natural := 768; --Data Chunk
G_CL_PIXBIT : natural := 8; --Amount bit per 1 pix
G_CL_TAP : natural := 8; --Amount pixel per 1 clk
G_CL_CHCOUNT : natural := 3
);
port(
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
p_out_status   : out  std_logic_vector(C_CAM_STATUS_LASTBIT downto 0)
);
end entity cam_cl_tb;

architecture behavior of cam_cl_tb is

constant CI_BUFPKT_RDCLK_PERIOD : TIME := 6.4 ns; --156.25MHz


component cam_cl_main is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTE_COUNT : natural := 16; --Header Byte Count
G_PKT_PIXCHUNK_BYTE_COUNT : natural := 1024; --Data Chunk
G_CL_PIXBIT : natural := 1; --Amount bit per 1 pix
G_CL_TAP : natural := 8; --Amount pixel per 1 clk
G_CL_CHCOUNT : natural := 1;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--
--------------------------------------------------
p_in_cam_ctrl_rx  : in  std_logic;
p_out_cam_ctrl_tx : out std_logic;
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
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cam_cl_main;

signal p_in_rst           : std_logic;
signal p_in_clk           : std_logic;
signal g_host_clk         : std_logic;

signal i_bufpkt_rd        : std_logic;
signal i_bufpkt_rdclk     : std_logic;
signal i_bufpkt_empty     : std_logic;

signal i_time             : unsigned(31 downto 0);


begin --architecture behavior of cam_cl_tb is


gen_clk1 : process
begin
i_bufpkt_rdclk <= '0';
wait for (CI_BUFPKT_RDCLK_PERIOD / 2);
i_bufpkt_rdclk <= '1';
wait for (CI_BUFPKT_RDCLK_PERIOD / 2);
end process;


p_in_rst <= '1','0' after 1 us;


i_time <= TO_UNSIGNED(16#7DCCBBAA#, i_time'length);

--***********************************************************
--
--***********************************************************
m_cam : cam_cl_main
generic map(
G_VCH_NUM => G_VCH_NUM,
G_PKT_TYPE => G_PKT_TYPE,
G_PKT_HEADER_BYTE_COUNT => G_PKT_HEADER_BYTE_COUNT, --Header Byte Count
G_PKT_PIXCHUNK_BYTE_COUNT => G_PKT_PIXCHUNK_BYTE_COUNT, --Data Chunk
G_CL_PIXBIT => G_CL_PIXBIT, --Amount bit per 1 pix
G_CL_TAP => G_CL_TAP, --Amount pixel per 1 clk
G_CL_CHCOUNT => G_CL_CHCOUNT,
G_SIM => "ON"
)
port map(
--------------------------------------------------
--
--------------------------------------------------
p_in_cam_ctrl_rx  => '1',
p_out_cam_ctrl_tx => open,
p_in_time         => std_logic_vector(i_time),

--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_tfg_n => '0',
p_in_tfg_p => '1',
p_out_tc_n => open,
p_out_tc_p => open,

--X,Y,Z : 0,1,2
p_in_cl_clk_p => p_in_cl_clk_p,
p_in_cl_clk_n => p_in_cl_clk_n,
p_in_cl_di_p  => p_in_cl_di_p ,
p_in_cl_di_n  => p_in_cl_di_n ,

--------------------------------------------------
--VideoPkt Output
--------------------------------------------------
p_out_bufpkt_d     => p_out_bufpkt_d,
p_in_bufpkt_rd     => i_bufpkt_rd   ,
p_in_bufpkt_rdclk  => i_bufpkt_rdclk,
p_out_bufpkt_empty => i_bufpkt_empty,

--------------------------------------------------
--
--------------------------------------------------
p_out_status   => p_out_status,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0'),

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst => p_in_rst
);

i_bufpkt_rd <= (not i_bufpkt_empty);


end architecture behavior;
