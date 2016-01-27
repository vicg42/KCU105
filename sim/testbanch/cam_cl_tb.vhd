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
use work.eth_pkg.all;


entity cam_cl_tb is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTECOUNT : natural := 16; --Header Byte Count
G_PKT_PIXCHUNK_BYTECOUNT : natural := 256; --Data Chunk
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

p_out_eth_axi_tdata  : out  std_logic_vector(64 - 1 downto 0);
p_out_eth_axi_tkeep  : out  std_logic_vector((64 / 8) - 1 downto 0);
p_out_eth_axi_tvalid : out  std_logic;
p_out_eth_axi_tlast  : out  std_logic;

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
G_PKT_HEADER_BYTECOUNT : natural := 16; --Header Byte Count
G_PKT_PIXCHUNK_BYTECOUNT : natural := 1024; --Data Chunk
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
p_out_dbg : out  TCAM_dbg;

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cam_cl_main;

component eth_mac_tx is
generic(
G_AXI_DWIDTH : integer := 64;
G_DBG : string := "OFF"
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg : in  TEthCfg;

--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_usr_axi_tdata   : in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_usr_axi_tready : out  std_logic;
p_in_usr_axi_tvalid  : in   std_logic;
p_out_usr_axi_done   : out  std_logic;

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_eth_axi_tready  : in   std_logic;
p_out_eth_axi_tdata  : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_eth_axi_tkeep  : out  std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_out_eth_axi_tvalid : out  std_logic;
p_out_eth_axi_tlast  : out  std_logic;

--------------------------------------
--DBG
--------------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);
--p_out_dbg : out  TEthDBG_MacTx;

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk : in  std_logic;
p_in_rst : in  std_logic
);
end component eth_mac_tx;

component pkt_arb is
generic(
G_AXI_DWIDTH : natural := 64;
G_CHCOUNT : natural := 0
);
port(
--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_txusr_axi_tdata   : in   std_logic_vector((G_AXI_DWIDTH * G_CHCOUNT) - 1 downto 0);
p_out_txusr_axi_tready : out  std_logic_vector(G_CHCOUNT - 1 downto 0);
p_in_txusr_axi_tvalid  : in   std_logic_vector(G_CHCOUNT - 1 downto 0);
p_out_txusr_axi_done   : out  std_logic_vector(G_CHCOUNT - 1 downto 0);

----------------------------
--TO ETH_MAC
----------------------------
p_out_txeth_axi_tdata   : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_txeth_axi_tready   : in   std_logic;
p_out_txeth_axi_tvalid  : out  std_logic;
p_in_txeth_axi_done     : in   std_logic;

------------------------------
----DBG
------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

----------------------------
--SYS
----------------------------
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component pkt_arb;

signal p_in_rst           : std_logic;
signal p_in_clk           : std_logic;
signal g_host_clk         : std_logic;

signal i_bufpkt_do        : std_logic_vector(63 downto 0);
signal i_bufpkt_rd        : std_logic;
signal i_bufpkt_rdclk     : std_logic;
signal i_bufpkt_empty     : std_logic;

signal i_time             : unsigned(31 downto 0);

signal i_eth_cfg          : TEthCfg;
signal i_eth_tx_axi_tready: std_logic;
signal i_eth_tx_axi_tvalid: std_logic;

constant CI_CHCOUNT : natural := 3;
constant CI_AXI_DWIDTH : natural := 64;
signal i_txusr_axi_tdata  : std_logic_vector((CI_AXI_DWIDTH * CI_CHCOUNT) - 1 downto 0);
signal i_txusr_axi_tready : std_logic_vector(CI_CHCOUNT - 1 downto 0);
signal i_txusr_axi_tvalid : std_logic_vector(CI_CHCOUNT - 1 downto 0);
signal i_txusr_axi_done   : std_logic_vector(CI_CHCOUNT - 1 downto 0);

signal i_txeth_arb_axi_tdata  : std_logic_vector(CI_AXI_DWIDTH - 1 downto 0);
signal i_txeth_arb_axi_tready : std_logic;
signal i_txeth_arb_axi_tvalid : std_logic;
signal i_txeth_arb_axi_done   : std_logic;




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
G_PKT_HEADER_BYTECOUNT => G_PKT_HEADER_BYTECOUNT, --Header Byte Count
G_PKT_PIXCHUNK_BYTECOUNT => G_PKT_PIXCHUNK_BYTECOUNT, --Data Chunk
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
p_out_bufpkt_d     => i_txusr_axi_tdata((CI_AXI_DWIDTH * (0 + 1)) - 1 downto (CI_AXI_DWIDTH * 0)),--i_bufpkt_do,
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
p_out_dbg => open,

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst => p_in_rst
);

--i_bufpkt_rd <= (not i_bufpkt_empty);


i_bufpkt_rd <= i_txusr_axi_tready(0);
i_txusr_axi_tvalid(0) <= not i_bufpkt_empty;
i_txusr_axi_tvalid(1) <= '0';
i_txusr_axi_tvalid(2) <= '0';


m_pkt_arb : pkt_arb
generic map(
G_AXI_DWIDTH => CI_AXI_DWIDTH,
G_CHCOUNT => CI_CHCOUNT
)
port map(
--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_txusr_axi_tdata   => i_txusr_axi_tdata ,--: in   std_logic_vector((G_AXI_DWIDTH * G_CHCOUNT) - 1 downto 0);
p_out_txusr_axi_tready => i_txusr_axi_tready,--: out  std_logic_vector(G_CHCOUNT - 1 downto 0);
p_in_txusr_axi_tvalid  => i_txusr_axi_tvalid,--: in   std_logic_vector(G_CHCOUNT - 1 downto 0);
p_out_txusr_axi_done   => open  ,--: out  std_logic_vector(G_CHCOUNT - 1 downto 0);

----------------------------
--TO ETH_MAC
----------------------------
p_out_txeth_axi_tdata  => i_txeth_arb_axi_tdata ,
p_in_txeth_axi_tready  => i_txeth_arb_axi_tready,
p_out_txeth_axi_tvalid => i_txeth_arb_axi_tvalid,
p_in_txeth_axi_done    => i_txeth_arb_axi_done  ,

------------------------------
----DBG
------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

----------------------------
--SYS
----------------------------
p_in_clk => i_bufpkt_rdclk,
p_in_rst => p_in_rst
);



i_eth_cfg.mac.dst(0) <= std_logic_vector(TO_UNSIGNED(16#11#, 8));
i_eth_cfg.mac.dst(1) <= std_logic_vector(TO_UNSIGNED(16#12#, 8));
i_eth_cfg.mac.dst(2) <= std_logic_vector(TO_UNSIGNED(16#13#, 8));
i_eth_cfg.mac.dst(3) <= std_logic_vector(TO_UNSIGNED(16#14#, 8));
i_eth_cfg.mac.dst(4) <= std_logic_vector(TO_UNSIGNED(16#15#, 8));
i_eth_cfg.mac.dst(5) <= std_logic_vector(TO_UNSIGNED(16#16#, 8));

i_eth_cfg.mac.src(0) <= std_logic_vector(TO_UNSIGNED(16#21#, 8));
i_eth_cfg.mac.src(1) <= std_logic_vector(TO_UNSIGNED(16#22#, 8));
i_eth_cfg.mac.src(2) <= std_logic_vector(TO_UNSIGNED(16#23#, 8));
i_eth_cfg.mac.src(3) <= std_logic_vector(TO_UNSIGNED(16#24#, 8));
i_eth_cfg.mac.src(4) <= std_logic_vector(TO_UNSIGNED(16#25#, 8));
i_eth_cfg.mac.src(5) <= std_logic_vector(TO_UNSIGNED(16#26#, 8));




m_eth_tx : eth_mac_tx
generic map(
G_AXI_DWIDTH => 64,
G_DBG => "OFF"
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => i_eth_cfg,

--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_usr_axi_tdata   => i_txeth_arb_axi_tdata,--i_bufpkt_do,
p_out_usr_axi_tready => i_txeth_arb_axi_tready,--i_eth_tx_axi_tready,--: out  std_logic;
p_in_usr_axi_tvalid  => i_txeth_arb_axi_tvalid,--i_eth_tx_axi_tvalid,--: in   std_logic;
p_out_usr_axi_done   => i_txeth_arb_axi_done,--open,

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_eth_axi_tready  => '1',--: in   std_logic;
p_out_eth_axi_tdata  => p_out_eth_axi_tdata ,
p_out_eth_axi_tkeep  => p_out_eth_axi_tkeep ,
p_out_eth_axi_tvalid => p_out_eth_axi_tvalid,
p_out_eth_axi_tlast  => p_out_eth_axi_tlast ,

--------------------------------------
--DBG
--------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,
--p_out_dbg : out  TEthDBG_MacTx;

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_bufpkt_rdclk,
p_in_rst => p_in_rst
);




end architecture behavior;
