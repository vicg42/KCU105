-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 17:10:15
-- Module Name : eth_core_example_design
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.eth_pkg.all;

entity eth_core_example_design is
generic(
G_AXI_DWIDTH : integer := 64;
G_GTCH_COUNT : integer := 1
);
port(
--// Clock inputs
clk_in       : in  std_logic;       --// Freerunning clock source
refclk_p     : in  std_logic;       --// Transceiver reference clock source
refclk_n     : in  std_logic;
coreclk_out  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

--// Example design control inputs
reset                  : in  std_logic;
sim_speedup_control    : in  std_logic;

--// Example design status outputs
frame_error        : out std_logic;
core_ready         : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
qplllock_out       : out std_logic;

--// Serial I/O from/to transceiver
txp : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
txn : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxp : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxn : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0)
);
end entity eth_core_example_design;

architecture behavioral of eth_core_example_design is


component eth_main is
generic(
G_ETH_CH_COUNT : integer := 1;
G_ETH_DWIDTH : integer := 64;
G_DBG  : string := "OFF";
G_SIM  : string := "OFF"
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in  std_logic;

p_in_cfg_adr     : in  std_logic_vector(2 downto 0);
p_in_cfg_adr_ld  : in  std_logic;

p_in_cfg_txdata  : in  std_logic_vector(15 downto 0);
p_in_cfg_wr      : in  std_logic;

p_out_cfg_rxdata : out std_logic_vector(15 downto 0);
p_in_cfg_rd      : in  std_logic;

-------------------------------
--UsrBuf
-------------------------------
--RXBUF <- ETH
p_in_rxbuf_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tkeep  : out  std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tuser  : out  std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--TXBUF -> ETH
p_in_txbuf_axi_tdata   : in   std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_out_txbuf_axi_tready : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_txbuf_axi_tvalid  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_txbuf_axi_done   : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

p_out_buf_clk  : out   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_buf_rst  : out   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--
-------------------------------
p_out_status_rdy      : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_status_carier   : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_status_qplllock : out std_logic;

p_in_sfp_signal_detect : in std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_sfp_tx_fault      : in std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy_txp    : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_ethphy_txn    : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_rxp     : in  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_rxn     : in  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethphy_refclk_p: in  std_logic;
p_in_ethphy_refclk_n: in  std_logic;

-------------------------------
--DBG
-------------------------------
p_in_sim  : in  TEthSIM_IN;
p_in_tst  : in  std_logic_vector(31 downto 0);
p_out_tst : out std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_dclk : in  std_logic; --DRP clk
p_in_rst : in  std_logic
);
end component eth_main;


component fifo_host2eth
port (
din       : in  std_logic_vector(127 downto 0);
wr_en     : in  std_logic;

dout      : out std_logic_vector(127 downto 0);
rd_en     : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk       : in  std_logic;
srst      : in  std_logic
);
end component;


signal i_sfp_signal_detect : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_sfp_tx_fault      : std_logic_vector(G_GTCH_COUNT - 1 downto 0);

signal i_ethio_rx_axi_tready : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_ethio_rx_axi_tdata  : std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0);
signal i_ethio_rx_axi_tkeep  : std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
signal i_ethio_rx_axi_tvalid : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_ethio_rx_axi_tuser  : std_logic_vector((2 * G_GTCH_COUNT) - 1 downto 0);

signal i_ethio_tx_axi_tdata  : std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0);
signal i_ethio_tx_axi_tready : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_ethio_tx_axi_tvalid : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_ethio_tx_axi_done   : std_logic_vector(G_GTCH_COUNT - 1 downto 0);

signal i_ethio_clk           : std_logic_vector(G_GTCH_COUNT - 1 downto 0);
signal i_ethio_rst           : std_logic_vector(G_GTCH_COUNT - 1 downto 0);

signal i_in_sim          : TEthSIM_IN;
signal i_in_tst          : std_logic_vector(31 downto 0);
signal i_out_tst         : std_logic_vector(31 downto 0);

signal i_fifo_di         : unsigned(127 downto 0);
signal i_fifo_do         : std_logic_vector(127 downto 0);
signal i_fifo_wr         : std_logic;
signal i_fifo_rd         : std_logic;
signal i_fifo_empty      : std_logic;
signal i_fifo_full       : std_logic;


begin --architecture behavioral of eth_core_example_design is



frame_error        <= '0';

i_in_sim.speedup_control <= sim_speedup_control;

gen_ch : for i in 0 to (G_GTCH_COUNT - 1) generate
begin
i_sfp_signal_detect(i) <= '1';
i_sfp_tx_fault(i) <= '0';
end generate gen_ch;


coreclk_out <= i_ethio_clk;

i_fifo_di <= RESIZE(UNSIGNED(i_ethio_rx_axi_tdata((G_AXI_DWIDTH * (0 + 1)) - 1 downto (G_AXI_DWIDTH * 0))), i_fifo_di'length);
i_fifo_wr <= i_ethio_rx_axi_tvalid(0);
i_ethio_rx_axi_tready(0) <= not i_fifo_full;

i_ethio_tx_axi_tdata((G_AXI_DWIDTH * (0 + 1)) - 1 downto (G_AXI_DWIDTH * 0)) <= i_fifo_do(G_AXI_DWIDTH - 1 downto 0);
i_fifo_rd <= i_ethio_tx_axi_tready(0);
i_ethio_tx_axi_tvalid(0) <= not i_fifo_empty;


m_fifo_loop : fifo_host2eth
port map(
din       => std_logic_vector(i_fifo_di),
wr_en     => i_fifo_wr,

dout      => i_fifo_do,
rd_en     => i_fifo_rd,

empty     => i_fifo_empty,
full      => open,
prog_full => i_fifo_full,

wr_rst_busy => open,
rd_rst_busy => open,

clk       => i_ethio_clk(0),
srst      => i_ethio_rst(0)
);


m_eth : eth_main
generic map(
G_ETH_CH_COUNT => G_GTCH_COUNT,
G_ETH_DWIDTH => G_AXI_DWIDTH,
G_DBG => "OFF",
G_SIM => "OFF"
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     => clk_in,

p_in_cfg_adr     => (others => '0'),
p_in_cfg_adr_ld  => '0',

p_in_cfg_txdata  => (others => '0'),
p_in_cfg_wr      => '0',

p_out_cfg_rxdata => open,
p_in_cfg_rd      => '0',

-------------------------------
--UsrBuf
-------------------------------
--RXBUF <- ETH
p_in_rxbuf_axi_tready  => i_ethio_rx_axi_tready,
p_out_rxbuf_axi_tdata  => i_ethio_rx_axi_tdata ,
p_out_rxbuf_axi_tkeep  => i_ethio_rx_axi_tkeep ,
p_out_rxbuf_axi_tvalid => i_ethio_rx_axi_tvalid,
p_out_rxbuf_axi_tuser  => i_ethio_rx_axi_tuser ,

--TXBUF -> ETH
p_in_txbuf_axi_tdata   => i_ethio_tx_axi_tdata ,
p_out_txbuf_axi_tready => i_ethio_tx_axi_tready,
p_in_txbuf_axi_tvalid  => i_ethio_tx_axi_tvalid,
p_out_txbuf_axi_done   => i_ethio_tx_axi_done  ,

p_out_buf_clk  => i_ethio_clk,
p_out_buf_rst  => i_ethio_rst,


p_out_status_rdy      => core_ready,
p_out_status_carier   => open,
p_out_status_qplllock => qplllock_out,

p_in_sfp_signal_detect => i_sfp_signal_detect,
p_in_sfp_tx_fault      => i_sfp_tx_fault     ,

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy_txp => txp,
p_out_ethphy_txn => txn,
p_in_ethphy_rxp => rxp,
p_in_ethphy_rxn => rxn,
p_in_ethphy_refclk_p => refclk_p,
p_in_ethphy_refclk_n => refclk_n,

-------------------------------
--DBG
-------------------------------
p_in_sim  => i_in_sim ,
p_in_tst  => i_in_tst ,
p_out_tst => i_out_tst,

-------------------------------
--System
-------------------------------
p_in_dclk => clk_in,
p_in_rst  => reset
);


end architecture behavioral;
