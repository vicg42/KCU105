-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 22.07.2012 11:10:51
-- Module Name : eth_mac_rx_tb
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_cfg.all;
use work.prj_def.all;
--use work.mem_glob_pkg.all;
--use work.mem_wr_pkg.all;
use work.eth_pkg.all;


entity eth_mac_rx_tb is
generic(
G_USRBUF_DWIDTH : integer := 64;
G_AXI_DWIDTH : integer := 64
);
port(
p_out_rxbuf_di   : out   std_logic_vector(G_USRBUF_DWIDTH - 1 downto 0);
p_out_rxbuf_wr   : out   std_logic;
p_out_rxd_sof    : out   std_logic;
p_out_rxd_eof    : out   std_logic
);
end entity eth_mac_rx_tb;

architecture behavior of eth_mac_rx_tb is

constant CI_VBUFI_WRCLK_PERIOD : TIME := 6.6 ns; --150MHz
constant CI_VBUFI_RDCLK_PERIOD : TIME := 2.5 ns; --400MHz

constant CI_FR_PIXCOUNT : integer := 128;
constant CI_FR_ROWCOUNT : integer := 8;
constant CI_FR_PIXNUM   : integer := 0;
constant CI_FR_ROWNUM   : integer := 0;

constant CI_RAM_DEPTH   : integer := 1024;

component eth_core_axi_fifo is
generic(
FIFO_SIZE : integer := 512;
IS_TX : integer := 0
);
port(
-- FIFO write domain
wr_axis_aresetn : in  std_logic;
wr_axis_aclk    : in  std_logic;
wr_axis_tdata   : in  std_logic_vector(63 downto 0);
wr_axis_tkeep   : in  std_logic_vector(7 downto 0);
wr_axis_tvalid  : in  std_logic;
wr_axis_tlast   : in  std_logic;
wr_axis_tready  : out std_logic;
wr_axis_tuser   : in  std_logic;

-- FIFO read domain
rd_axis_aresetn : in  std_logic;
rd_axis_aclk    : in  std_logic;
rd_axis_tdata   : out std_logic_vector(63 downto 0);
rd_axis_tkeep   : out std_logic_vector(7 downto 0);
rd_axis_tvalid  : out std_logic;
rd_axis_tlast   : out std_logic;
rd_axis_tready  : in  std_logic;

-- FIFO Status Signals
fifo_status     : out std_logic_vector(3 downto 0);
fifo_full       : out std_logic
);
end component eth_core_axi_fifo;

component eth_mac_rx is
generic(
G_USRBUF_DWIDTH : integer := 64;
G_AXI_DWIDTH : integer := 64;
G_DBG : string := "OFF"
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg : in TEthCfg;

--------------------------------------
--USR RXBUF <- ETH
--------------------------------------
p_out_rxbuf_di   : out   std_logic_vector(G_USRBUF_DWIDTH - 1 downto 0);
p_out_rxbuf_wr   : out   std_logic;
p_in_rxbuf_full  : in    std_logic;
p_out_rxbuf_sof  : out   std_logic;
p_out_rxbuf_eof  : out   std_logic;

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_in_axi_tdata   : in    std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_axi_tkeep   : in    std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_in_axi_tvalid  : in    std_logic;
p_in_axi_tlast   : in    std_logic;
p_out_axi_tready : out   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  : in    std_logic_vector(31 downto 0);
p_out_tst : out   std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk  : in    std_logic;
p_in_rst  : in    std_logic
);
end component eth_mac_rx;

signal p_in_rst              : std_logic;
signal p_in_clk              : std_logic;

type TD8_array is array (0 to (G_AXI_DWIDTH / 8) - 1) of unsigned(7 downto 0);

signal i_aresetn             : std_logic;
signal i_rx_axis_fifo_tdata  : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal i_rx_axis_fifo_tkeep  : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal i_rx_axis_fifo_tvalid : std_logic;
signal i_rx_axis_fifo_tlast  : std_logic;
signal i_rx_axis_fifo_tready : std_logic;

signal i_rx_axis_mac_tdata   : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal i_rx_axis_mac_tkeep   : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal i_rx_axis_mac_tvalid  : std_logic;
signal i_rx_axis_mac_tlast   : std_logic;
signal i_rx_axis_mac_tuser   : std_logic;

signal i_rx_mac_tdata : TD8_array;
signal i_rx_mac_tkeep : unsigned((G_AXI_DWIDTH / 8) - 1 downto 0);

signal i_rx_fifo_status : std_logic_vector(3 downto 0);
signal i_rx_fifo_full   : std_logic;

signal i_frmac_length : unsigned(15 downto 0);

signal i_cfg   : TEthCfg;
signal i_simcfg   : TEthCfg;


begin --architecture behavior of eth_mac_rx_tb is


gen_clk0 : process
begin
p_in_clk <= '0';
wait for (CI_VBUFI_RDCLK_PERIOD / 2);
p_in_clk <= '1';
wait for (CI_VBUFI_RDCLK_PERIOD / 2);
end process;


p_in_rst <= '1','0' after 1 us;


m_eth_rx : eth_mac_rx
generic map(
G_USRBUF_DWIDTH => G_USRBUF_DWIDTH,
G_AXI_DWIDTH => G_AXI_DWIDTH,
G_DBG => "OFF"
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => i_cfg,

--------------------------------------
--USR RXBUF <- ETH
--------------------------------------
p_out_rxbuf_di  => p_out_rxbuf_di,
p_out_rxbuf_wr  => p_out_rxbuf_wr,
p_in_rxbuf_full => '0',
p_out_rxbuf_sof => p_out_rxd_sof,
p_out_rxbuf_eof => p_out_rxd_eof,

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_in_axi_tdata   => i_rx_axis_fifo_tdata ,
p_in_axi_tkeep   => i_rx_axis_fifo_tkeep ,
p_in_axi_tvalid  => i_rx_axis_fifo_tvalid,
p_in_axi_tlast   => i_rx_axis_fifo_tlast ,
p_out_axi_tready => i_rx_axis_fifo_tready,

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);


i_aresetn <= not p_in_rst;

m_macbuf : eth_core_axi_fifo
generic map (
FIFO_SIZE => 1024,
IS_TX => 0
)
port map (
-- FIFO write domain
wr_axis_aresetn => i_aresetn,--i_rx_axis_mac_aresetn,--: in  std_logic;
wr_axis_aclk    => p_in_clk,--i_rx_axis_mac_aclk   ,--: in  std_logic;
wr_axis_tdata   => i_rx_axis_mac_tdata  ,--: in  std_logic_vector(63 downto 0);
wr_axis_tkeep   => i_rx_axis_mac_tkeep  ,--: in  std_logic_vector(7 downto 0);
wr_axis_tvalid  => i_rx_axis_mac_tvalid ,--: in  std_logic;
wr_axis_tlast   => i_rx_axis_mac_tlast  ,--: in  std_logic;
wr_axis_tready  => open                 ,--: out std_logic;
wr_axis_tuser   => i_rx_axis_mac_tuser  ,--: in  std_logic;

-- FIFO read domain
rd_axis_aresetn => i_aresetn,--i_rx_axis_fifo_aresetn,--: in  std_logic;
rd_axis_aclk    => p_in_clk,--i_rx_axis_fifo_aclk   ,--: in  std_logic;
rd_axis_tdata   => i_rx_axis_fifo_tdata  ,--: out std_logic_vector(63 downto 0);
rd_axis_tkeep   => i_rx_axis_fifo_tkeep  ,--: out std_logic_vector(7 downto 0);
rd_axis_tvalid  => i_rx_axis_fifo_tvalid ,--: out std_logic;
rd_axis_tlast   => i_rx_axis_fifo_tlast  ,--: out std_logic;
rd_axis_tready  => i_rx_axis_fifo_tready ,--: in  std_logic;

-- FIFO Status Signals
fifo_status     => i_rx_fifo_status,--: out std_logic_vector(3 downto 0);
fifo_full       => i_rx_fifo_full   --: out std_logic;
);




i_cfg.mac.dst(0) <= TO_UNSIGNED(16#A0#, i_cfg.mac.dst(0)'length);
i_cfg.mac.dst(1) <= TO_UNSIGNED(16#A1#, i_cfg.mac.dst(1)'length);
i_cfg.mac.dst(2) <= TO_UNSIGNED(16#A2#, i_cfg.mac.dst(2)'length);
i_cfg.mac.dst(3) <= TO_UNSIGNED(16#A3#, i_cfg.mac.dst(3)'length);
i_cfg.mac.dst(4) <= TO_UNSIGNED(16#A4#, i_cfg.mac.dst(4)'length);
i_cfg.mac.dst(5) <= TO_UNSIGNED(16#A5#, i_cfg.mac.dst(5)'length);

i_cfg.mac.src(0) <= TO_UNSIGNED(16#B0#, i_cfg.mac.dst(0)'length);
i_cfg.mac.src(1) <= TO_UNSIGNED(16#B1#, i_cfg.mac.dst(1)'length);
i_cfg.mac.src(2) <= TO_UNSIGNED(16#B2#, i_cfg.mac.dst(2)'length);
i_cfg.mac.src(3) <= TO_UNSIGNED(16#B3#, i_cfg.mac.dst(3)'length);
i_cfg.mac.src(4) <= TO_UNSIGNED(16#B4#, i_cfg.mac.dst(4)'length);
i_cfg.mac.src(5) <= TO_UNSIGNED(16#B5#, i_cfg.mac.dst(5)'length);

i_simcfg.mac.src <= i_cfg.mac.dst;
i_simcfg.mac.dst <= i_cfg.mac.src;


gen_d : for i in 0 to i_rx_mac_tdata'length - 1 generate
i_rx_axis_mac_tdata((i_rx_mac_tdata(0)'length * (i + 1)) - 1 downto (i_rx_mac_tdata'length * i)) <= std_logic_vector(i_rx_mac_tdata(i));
end generate gen_d;

i_rx_axis_mac_tkeep <= std_logic_vector(i_rx_mac_tkeep);

process
begin

for i in 0 to i_rx_mac_tdata'length - 1 loop
i_rx_mac_tdata(i) <= (others => '0');
end loop;
i_rx_mac_tkeep <= (others => '0');

i_rx_axis_mac_tvalid <= '0';
i_rx_axis_mac_tlast  <= '0';
i_rx_axis_mac_tuser  <= '0';

wait for 2 us;


wait until rising_edge(p_in_clk);
i_frmac_length <= TO_UNSIGNED(18, 16);

i_rx_axis_mac_tvalid <= '1';

i_rx_mac_tdata(0) <= i_simcfg.mac.dst(0); i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= i_simcfg.mac.dst(1); i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= i_simcfg.mac.dst(2); i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= i_simcfg.mac.dst(3); i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= i_simcfg.mac.dst(4); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= i_simcfg.mac.dst(5); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= i_simcfg.mac.src(0); i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= i_simcfg.mac.src(1); i_rx_mac_tkeep(7) <= '1';


wait until rising_edge(p_in_clk);

i_rx_axis_mac_tvalid <= '1';

i_rx_mac_tdata(0) <= i_simcfg.mac.src(2);                        i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= i_simcfg.mac.src(3);                        i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= i_simcfg.mac.src(4);                        i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= i_simcfg.mac.src(5);                        i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= i_frmac_length((8 * 2) - 1 downto (8 * 1)); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= i_frmac_length((8 * 1) - 1 downto (8 * 0)); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= TO_UNSIGNED(0, 8);                          i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= TO_UNSIGNED(1, 8);                          i_rx_mac_tkeep(7) <= '1';

wait until rising_edge(p_in_clk);

i_rx_axis_mac_tvalid <= '1';
i_rx_axis_mac_tlast <= '0';
i_rx_axis_mac_tuser <= '0';

i_rx_mac_tdata(0) <= TO_UNSIGNED(2, 8); i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= TO_UNSIGNED(3, 8); i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= TO_UNSIGNED(4, 8); i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= TO_UNSIGNED(5, 8); i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= TO_UNSIGNED(6, 8); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= TO_UNSIGNED(7, 8); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= TO_UNSIGNED(8, 8); i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= TO_UNSIGNED(9, 8); i_rx_mac_tkeep(7) <= '1';

wait until rising_edge(p_in_clk);

i_rx_axis_mac_tvalid <= '1';
i_rx_axis_mac_tlast <= '1';
i_rx_axis_mac_tuser <= '1';

i_rx_mac_tdata(0) <= TO_UNSIGNED(10, 8); i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= TO_UNSIGNED(11, 8); i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= TO_UNSIGNED(12, 8); i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= TO_UNSIGNED(13, 8); i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= TO_UNSIGNED(14, 8); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= TO_UNSIGNED(15, 8); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= TO_UNSIGNED(16, 8); i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= TO_UNSIGNED(17, 8); i_rx_mac_tkeep(7) <= '1';

wait until rising_edge(p_in_clk);
i_rx_axis_mac_tvalid <= '0';
i_rx_axis_mac_tlast <= '0';
i_rx_axis_mac_tuser <= '0';

wait for 0.5 us;


wait until rising_edge(p_in_clk);
i_frmac_length <= TO_UNSIGNED(6, 16);

i_rx_axis_mac_tvalid <= '1';

i_rx_mac_tdata(0) <= i_simcfg.mac.dst(0); i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= i_simcfg.mac.dst(1); i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= i_simcfg.mac.dst(2); i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= i_simcfg.mac.dst(3); i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= i_simcfg.mac.dst(4); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= i_simcfg.mac.dst(5); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= i_simcfg.mac.src(0); i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= i_simcfg.mac.src(1); i_rx_mac_tkeep(7) <= '1';

wait until rising_edge(p_in_clk);

i_rx_axis_mac_tvalid <= '1';

i_rx_mac_tdata(0) <= i_simcfg.mac.src(2);                        i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= i_simcfg.mac.src(3);                        i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= i_simcfg.mac.src(4);                        i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= i_simcfg.mac.src(5);                        i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= i_frmac_length((8 * 2) - 1 downto (8 * 1)); i_rx_mac_tkeep(4) <= '1';
i_rx_mac_tdata(5) <= i_frmac_length((8 * 1) - 1 downto (8 * 0)); i_rx_mac_tkeep(5) <= '1';
i_rx_mac_tdata(6) <= TO_UNSIGNED(0, 8);                          i_rx_mac_tkeep(6) <= '1';
i_rx_mac_tdata(7) <= TO_UNSIGNED(1, 8);                          i_rx_mac_tkeep(7) <= '1';

wait until rising_edge(p_in_clk);

i_rx_axis_mac_tvalid <= '1';
i_rx_axis_mac_tlast <= '1';
i_rx_axis_mac_tuser <= '1';

i_rx_mac_tdata(0) <= TO_UNSIGNED(2, 8); i_rx_mac_tkeep(0) <= '1';
i_rx_mac_tdata(1) <= TO_UNSIGNED(3, 8); i_rx_mac_tkeep(1) <= '1';
i_rx_mac_tdata(2) <= TO_UNSIGNED(4, 8); i_rx_mac_tkeep(2) <= '1';
i_rx_mac_tdata(3) <= TO_UNSIGNED(5, 8); i_rx_mac_tkeep(3) <= '1';
i_rx_mac_tdata(4) <= TO_UNSIGNED(0, 8); i_rx_mac_tkeep(4) <= '0';
i_rx_mac_tdata(5) <= TO_UNSIGNED(0, 8); i_rx_mac_tkeep(5) <= '0';
i_rx_mac_tdata(6) <= TO_UNSIGNED(0, 8); i_rx_mac_tkeep(6) <= '0';
i_rx_mac_tdata(7) <= TO_UNSIGNED(0, 8); i_rx_mac_tkeep(7) <= '0';

wait until rising_edge(p_in_clk);
i_rx_axis_mac_tvalid <= '0';
i_rx_axis_mac_tlast <= '0';
i_rx_axis_mac_tuser <= '0';

wait;
end process;



end architecture behavior;
