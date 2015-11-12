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
use work.eth_phypin_pkg.all;
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
G_AXI_DWIDTH : integer := 64;
G_DBG        : string:="OFF";
G_SIM        : string:="OFF"
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
p_out_bufeth     : out TEthIO_OUTs;
p_in_bufeth      : in  TEthIO_INs;

p_out_status_eth : out TEthStatus_OUT;
p_in_status_eth  : in  TEthStatus_IN;

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy : out TEthPhyPin_OUT;
p_in_ethphy  : in  TEthPhyPin_IN;

-------------------------------
--DBG
-------------------------------
--p_out_dbg : out  TEthDBG;
p_in_sim  : in   TEthSIM_IN;
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_dclk : in  std_logic;
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


signal i_out_bufeth      : TEthIO_OUTs;
signal i_in_bufeth       : TEthIO_INs;

signal i_out_status_eth  : TEthStatus_OUT;
signal i_in_status_eth   : TEthStatus_IN;

signal i_out_ethphy      : TEthPhyPin_OUT;
signal i_in_ethphy       : TEthPhyPin_IN;

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

qplllock_out       <= '0';

i_in_ethphy.fiber.refclk_p <= refclk_p;
i_in_ethphy.fiber.refclk_n <= refclk_n;

gen_ch : for i in 0 to (C_GTCH_COUNT - 1) generate
begin
i_in_status_eth.signal_detect(i) <= '1';
i_in_status_eth.tx_fault(i) <= '0';

core_ready(i) <= i_out_status_eth.rdy(i);

i_in_ethphy.fiber.rxp(i) <= rxp(i);
i_in_ethphy.fiber.rxn(i) <= rxn(i);
txp(i) <= i_out_ethphy.fiber.txp(i);
txn(i) <= i_out_ethphy.fiber.txn(i);

coreclk_out(i) <= i_out_bufeth(i).clk;

end generate gen_ch;


--i_in_bufeth(0).tx_axi_tdata  <= std_logic_vector(TO_UNSIGNED(16#A0001#, i_in_bufeth(0).tx_axi_tdata'length));
--i_in_bufeth(0).tx_axi_tvalid <= '1';
--i_in_bufeth(0).rx_axi_tready <= '1';

--i_in_bufeth(0).tx_axi_tdata <= i_out_bufeth(0).rx_axi_tdata;
--i_in_bufeth(0).tx_axi_tvalid <= i_out_bufeth(0).rx_axi_tvalid;
--
--i_in_bufeth(0).rx_axi_tready <= '1';--i_out_bufeth(0).tx_axi_tready;



i_fifo_di <= RESIZE(UNSIGNED(i_out_bufeth(0).rx_axi_tdata), i_fifo_di'length);
i_fifo_wr <= i_out_bufeth(0).rx_axi_tvalid;
i_in_bufeth(0).rx_axi_tready <= not i_fifo_full;

i_in_bufeth(0).tx_axi_tdata <= i_fifo_do(i_in_bufeth(0).tx_axi_tdata'range);
i_fifo_rd <= i_out_bufeth(0).tx_axi_tready;
i_in_bufeth(0).tx_axi_tvalid <= not i_fifo_empty;

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

clk       => i_out_bufeth(0).clk,
srst      => i_out_bufeth(0).rst
);


m_eth : eth_main
generic map(
G_AXI_DWIDTH => G_AXI_DWIDTH,
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
p_out_bufeth => i_out_bufeth,
p_in_bufeth  => i_in_bufeth ,

p_out_status_eth => i_out_status_eth,
p_in_status_eth  => i_in_status_eth,

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy => i_out_ethphy,
p_in_ethphy  => i_in_ethphy ,

-------------------------------
--DBG
-------------------------------
--p_out_dbg : out   TEthDBG;
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
