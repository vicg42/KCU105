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
coreclk_out  : out std_logic;

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
--p_out_status_carier   : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
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
p_in_sim_speedup_control : in  std_logic;
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


component switch_data is
generic(
G_ETH_CH_COUNT : integer := 1;
G_ETH_DWIDTH : integer := 32;
G_FGBUFI_DWIDTH : integer := 32;
G_HOST_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in   std_logic;

p_in_cfg_adr     : in   std_logic_vector(5 downto 0);
p_in_cfg_adr_ld  : in   std_logic;

p_in_cfg_txdata  : in   std_logic_vector(15 downto 0);
p_in_cfg_wr      : in   std_logic;

p_out_cfg_rxdata : out  std_logic_vector(15 downto 0);
p_in_cfg_rd      : in   std_logic;

-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_eth_htxd_rdy      : in   std_logic;
p_in_eth_htxbuf_di     : in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_htxbuf_wr     : in   std_logic;
p_out_eth_htxbuf_full  : out  std_logic;
p_out_eth_htxbuf_empty : out  std_logic;

--host <- dev
p_out_eth_hrxbuf_do    : out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_hrxbuf_rd     : in   std_logic;
p_out_eth_hrxbuf_full  : out  std_logic;
p_out_eth_hrxbuf_empty : out  std_logic;

p_out_eth_hirq         : out  std_logic;

p_in_hclk              : in   std_logic;

-------------------------------
--ETH
-------------------------------
p_in_eth_tmr_irq       : in   std_logic;
p_in_eth_tmr_en        : in   std_logic;

--rxbuf <- eth
p_out_ethio_rx_axi_tready : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tdata   : in   std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tkeep   : in   std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tvalid  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tuser   : in   std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--txbuf -> eth
p_out_ethio_tx_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_tx_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_ethio_tx_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_tx_axi_done    : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

p_in_ethio_clk            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rst            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--FG_BUFI
-------------------------------
p_out_fgbufi_do    : out  std_logic_vector((G_FGBUFI_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_fgbufi_rd     : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_fgbufi_rdclk  : in   std_logic;
p_out_fgbufi_empty : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_full  : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_pfull : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--DBG
-------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst  : in    std_logic
);
end component switch_data;


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

signal i_in_tst          : std_logic_vector(31 downto 0);
signal i_out_tst         : std_logic_vector(31 downto 0);

signal i_fifo_di         : unsigned(127 downto 0);
signal i_fifo_do         : std_logic_vector(127 downto 0);
signal i_fifo_wr         : std_logic;
signal i_fifo_rd         : std_logic;
signal i_fifo_empty      : std_logic;
signal i_fifo_full       : std_logic;

constant CI_HCLK_PERIOD : TIME := 2.5 ns; --400MHz
constant CI_HOST_DWIDTH : natural := 128;

signal i_eth_hrxbuf_di_rdy : std_logic;
signal i_eth_hrxbuf_di   : unsigned(CI_HOST_DWIDTH - 1 downto 0);
signal i_eth_hrxbuf_do   : std_logic_vector(CI_HOST_DWIDTH - 1 downto 0);
signal i_eth_htxbuf_wr   : std_logic;
signal i_eth_hrxbuf_empty: std_logic;
signal i_eth_hirq        : std_logic;
signal i_hclk            : std_logic;

signal sr_eth_hirq     : std_logic := '0';
signal sr_eth_hirq_dly : std_logic_vector(0 to 15) := (others => '0');



begin --architecture behavioral of eth_core_example_design is



frame_error        <= '0';

gen_ch : for i in 0 to (G_GTCH_COUNT - 1) generate
begin
i_sfp_signal_detect(i) <= '1';
i_sfp_tx_fault(i) <= '0';
end generate gen_ch;


coreclk_out <= i_ethio_clk(0);

--i_fifo_di <= RESIZE(UNSIGNED(i_ethio_rx_axi_tdata((G_AXI_DWIDTH * (0 + 1)) - 1 downto (G_AXI_DWIDTH * 0))), i_fifo_di'length);
--i_fifo_wr <= i_ethio_rx_axi_tvalid(0);
--i_ethio_rx_axi_tready(0) <= not i_fifo_full;
--
--i_ethio_tx_axi_tdata((G_AXI_DWIDTH * (0 + 1)) - 1 downto (G_AXI_DWIDTH * 0)) <= i_fifo_do(G_AXI_DWIDTH - 1 downto 0);
--i_fifo_rd <= i_ethio_tx_axi_tready(0);
--i_ethio_tx_axi_tvalid(0) <= not i_fifo_empty;
--
--
--m_fifo_loop : fifo_host2eth
--port map(
--din       => std_logic_vector(i_fifo_di),
--wr_en     => i_fifo_wr,
--
--dout      => i_fifo_do,
--rd_en     => i_fifo_rd,
--
--empty     => i_fifo_empty,
--full      => open,
--prog_full => i_fifo_full,
--
--wr_rst_busy => open,
--rd_rst_busy => open,
--
--clk       => i_ethio_clk(0),
--srst      => i_ethio_rst(0)
--);


--i_eth_htxbuf_wr <= not i_eth_hrxbuf_empty;


gen_hclk : process
begin
i_hclk <= '0';
wait for (CI_HCLK_PERIOD / 2);
i_hclk <= '1';
wait for (CI_HCLK_PERIOD / 2);
end process;


process
begin

i_eth_hrxbuf_di <= (others => '0');
i_eth_htxbuf_wr <= '0';
i_eth_hrxbuf_di_rdy <= '0';

wait for 20 us;

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '1';
i_eth_hrxbuf_di(63 downto 0) <=  TO_UNSIGNED(16#0504#, 16) & TO_UNSIGNED(16#0302#, 16) & TO_UNSIGNED(16#0100#, 16) & TO_UNSIGNED(16#004E#, 16);
i_eth_hrxbuf_di(127 downto 64) <=  TO_UNSIGNED(16#0D0C#, 16) & TO_UNSIGNED(16#0B0A#, 16) & TO_UNSIGNED(16#0908#, 16) & TO_UNSIGNED(16#0706#, 16);

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '1';
i_eth_hrxbuf_di(63 downto 0) <=  TO_UNSIGNED(16#1514#, 16) & TO_UNSIGNED(16#1312#, 16) & TO_UNSIGNED(16#1110#, 16) & TO_UNSIGNED(16#0F0E#, 16);
i_eth_hrxbuf_di(127 downto 64) <=  TO_UNSIGNED(16#1D1C#, 16) & TO_UNSIGNED(16#1B1A#, 16) & TO_UNSIGNED(16#1918#, 16) & TO_UNSIGNED(16#1716#, 16);

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '1';
i_eth_hrxbuf_di(63 downto 0) <=  TO_UNSIGNED(16#2524#, 16) & TO_UNSIGNED(16#2322#, 16) & TO_UNSIGNED(16#2120#, 16) & TO_UNSIGNED(16#1F1E#, 16);
i_eth_hrxbuf_di(127 downto 64) <=  TO_UNSIGNED(16#2D2C#, 16) & TO_UNSIGNED(16#2B2A#, 16) & TO_UNSIGNED(16#2928#, 16) & TO_UNSIGNED(16#2726#, 16);

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '1';
i_eth_hrxbuf_di(63 downto 0) <=  TO_UNSIGNED(16#3534#, 16) & TO_UNSIGNED(16#3332#, 16) & TO_UNSIGNED(16#3130#, 16) & TO_UNSIGNED(16#2F2E#, 16);
i_eth_hrxbuf_di(127 downto 64) <=  TO_UNSIGNED(16#3D3C#, 16) & TO_UNSIGNED(16#3B3A#, 16) & TO_UNSIGNED(16#3938#, 16) & TO_UNSIGNED(16#3736#, 16);

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '1';
i_eth_hrxbuf_di(63 downto 0) <=  TO_UNSIGNED(16#0000#, 16) & TO_UNSIGNED(16#0000#, 16) & TO_UNSIGNED(16#0000#, 16) & TO_UNSIGNED(16#3F3E#, 16);
i_eth_hrxbuf_di(127 downto 64) <=  (others => '0');

wait until rising_edge(i_hclk); i_eth_htxbuf_wr <= '0';
i_eth_hrxbuf_di_rdy <= '1';

wait until rising_edge(i_hclk);
i_eth_hrxbuf_di_rdy <= '0';

end process;

m_swt : switch_data
generic map(
G_ETH_CH_COUNT => G_GTCH_COUNT,
G_ETH_DWIDTH => G_AXI_DWIDTH,
G_FGBUFI_DWIDTH => G_AXI_DWIDTH,
G_HOST_DWIDTH => CI_HOST_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     => '0',

p_in_cfg_adr     => (others => '0'),
p_in_cfg_adr_ld  => '0',

p_in_cfg_txdata  => (others => '0'),
p_in_cfg_wr      => '0',

p_out_cfg_rxdata => open,
p_in_cfg_rd      => '0',

-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_eth_htxd_rdy      => i_eth_hrxbuf_di_rdy,--sr_eth_hirq_dly(sr_eth_hirq_dly'high),--: in   std_logic;
p_in_eth_htxbuf_di     => std_logic_vector(i_eth_hrxbuf_di),--i_eth_hrxbuf_do,--: in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_htxbuf_wr     => i_eth_htxbuf_wr,--: in   std_logic;
p_out_eth_htxbuf_full  => open,--: out  std_logic;
p_out_eth_htxbuf_empty => open,--: out  std_logic;

--host <- dev
p_out_eth_hrxbuf_do    => i_eth_hrxbuf_do,--: out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_hrxbuf_rd     => '1', --: in   std_logic;
p_out_eth_hrxbuf_full  => open,--: out  std_logic;
p_out_eth_hrxbuf_empty => i_eth_hrxbuf_empty,--: out  std_logic;

p_out_eth_hirq         => i_eth_hirq,--: out  std_logic;

p_in_hclk              => i_hclk,--: in   std_logic;

-------------------------------
--ETH
-------------------------------
p_in_eth_tmr_irq       => '0',--: in   std_logic;
p_in_eth_tmr_en        => '0',--: in   std_logic;

--rxbuf <- eth
p_out_ethio_rx_axi_tready => i_ethio_rx_axi_tready,
p_in_ethio_rx_axi_tdata   => i_ethio_rx_axi_tdata ,
p_in_ethio_rx_axi_tkeep   => i_ethio_rx_axi_tkeep ,
p_in_ethio_rx_axi_tvalid  => i_ethio_rx_axi_tvalid,
p_in_ethio_rx_axi_tuser   => i_ethio_rx_axi_tuser ,

--txbuf -> eth
p_out_ethio_tx_axi_tdata  => i_ethio_tx_axi_tdata ,
p_in_ethio_tx_axi_tready  => i_ethio_tx_axi_tready,
p_out_ethio_tx_axi_tvalid => i_ethio_tx_axi_tvalid,
p_in_ethio_tx_axi_done    => i_ethio_tx_axi_done  ,

p_in_ethio_clk            => i_ethio_clk,
p_in_ethio_rst            => i_ethio_rst,

-------------------------------
--FG_BUFI
-------------------------------
p_out_fgbufi_do    => open,
p_in_fgbufi_rd     => (others => '0'),
p_in_fgbufi_rdclk  => '0',
p_out_fgbufi_empty => open,
p_out_fgbufi_full  => open,
p_out_fgbufi_pfull => open,

-------------------------------
--DBG
-------------------------------
p_in_tst  => (others => '0'),---: in   std_logic_vector(31 downto 0);
p_out_tst => open,--: out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst => i_ethio_rst(0) -- : in    std_logic
);


process(i_hclk)
begin
if rising_edge(i_hclk) then
  sr_eth_hirq <= i_eth_hirq;
  sr_eth_hirq_dly <= (not i_eth_hirq and sr_eth_hirq) & sr_eth_hirq_dly(0 to sr_eth_hirq_dly'high - 1);
end if;
end process;


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

p_out_buf_clk => i_ethio_clk,
p_out_buf_rst => i_ethio_rst,

p_out_status_rdy      => core_ready,
--p_out_status_carier   => open,
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
p_in_sim_speedup_control => sim_speedup_control,
p_in_tst  => i_in_tst ,
p_out_tst => i_out_tst,

-------------------------------
--System
-------------------------------
p_in_dclk => clk_in,
p_in_rst  => reset
);


end architecture behavioral;
