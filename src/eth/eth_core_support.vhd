-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 03.05.2011 16:39:38
-- Module Name : eth_core_support
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_core_support is
port(
--Port declarations
p_in_refclk_p                     : in   std_logic;
p_in_refclk_n                     : in   std_logic;
p_in_dclk                         : in   std_logic;
p_out_coreclk                       : out  std_logic;
p_in_reset                        : in   std_logic;
p_out_qpll0outclk                   : out  std_logic;
p_out_qpll0outrefclk                : out  std_logic;
p_out_qpll0lock                     : out  std_logic;
p_out_qpll0reset                    : out  std_logic;
p_out_resetdone_out               : out  std_logic;
txusrclk_out                      : out  std_logic;
txusrclk2_out                     : out  std_logic;
p_out_gttxreset                     : out  std_logic;
p_out_gtrxreset                     : out  std_logic;
p_out_txuserrdy                     : out  std_logic;
p_out_reset_counter_done            : out  std_logic;

p_in_mac_tx_configuration_vector  : in   std_logic_vector(79 downto 0);
p_in_mac_rx_configuration_vector  : in   std_logic_vector(79 downto 0);
p_out_mac_status_vector           : out  std_logic_vector(1 downto 0);
p_in_pcs_pma_configuration_vector : in   std_logic_vector(535 downto 0);
p_out_pcs_pma_status_vector       : out  std_logic_vector(447 downto 0);

p_in_tx_ifg_delay                 : in   std_logic_vector(7 downto 0);

p_out_tx_statistics_vector        : out  std_logic_vector(25 downto 0);
p_out_rx_statistics_vector        : out  std_logic_vector(29 downto 0);
p_out_tx_statistics_valid         : out  std_logic;
p_out_rx_statistics_valid         : out  std_logic;

p_in_tx_axis_aresetn              : in   std_logic;
p_in_axis_tx_tdata                : in   std_logic_vector(63 downto 0);
p_in_axis_tx_tkeep                : in   std_logic_vector(7 downto 0);
p_in_axis_tx_tvalid               : in   std_logic;
p_in_axis_tx_tlast                : in   std_logic;
p_in_axis_tx_tuser                : in   std_logic;
p_out_axis_tx_tready              : out  std_logic;

p_in_rx_axis_aresetn              : in   std_logic;
p_out_axis_rx_tdata               : out  std_logic_vector(63 downto 0);
p_out_axis_rx_tkeep               : out  std_logic_vector(7 downto 0);
p_out_axis_rx_tvalid              : out  std_logic;
p_out_axis_rx_tuser               : out  std_logic;
p_out_axis_rx_tlast               : out  std_logic;

--Pause axis
p_in_axis_pause_tdata             : in   std_logic_vector(15 downto 0);
p_in_axis_pause_tvalid            : in   std_logic;

p_out_txp                         : out  std_logic;
p_out_txn                         : out  std_logic;
p_in_rxp                          : in   std_logic;
p_in_rxn                          : in   std_logic;

p_out_tx_disable                  : out  std_logic;
p_out_rxrecclk_out                : out  std_logic;
p_in_signal_detect                : in   std_logic;
p_in_sim_speedup_control          : in   std_logic;
p_in_tx_fault                     : in   std_logic;
p_out_pcspma_status               : out  std_logic_vector(7 downto 0)
);
end entity eth_core_support;

architecture behavioral of eth_core_support is

component eth_core
port (
tx_axis_aresetn : in std_logic;
rx_axis_aresetn : in std_logic;
tx_ifg_delay : in std_logic_vector(7 downto 0);
dclk : in std_logic;
txp : out std_logic;
txn : out std_logic;
rxp : in std_logic;
rxn : in std_logic;
signal_detect : in std_logic;
tx_fault : in std_logic;
tx_disable : out std_logic;
pcspma_status : out std_logic_vector(7 downto 0);
sim_speedup_control : in std_logic;
rxrecclk_out : out std_logic;
mac_tx_configuration_vector : in std_logic_vector(79 downto 0);
mac_rx_configuration_vector : in std_logic_vector(79 downto 0);
mac_status_vector : out std_logic_vector(1 downto 0);
pcs_pma_configuration_vector : in std_logic_vector(535 downto 0);
pcs_pma_status_vector : out std_logic_vector(447 downto 0);
areset_coreclk : in std_logic;
txusrclk : in std_logic;
txusrclk2 : in std_logic;
txoutclk : out std_logic;
txuserrdy : in std_logic;
tx_resetdone : out std_logic;
rx_resetdone : out std_logic;
coreclk : in std_logic;
areset : in std_logic;
gttxreset : in std_logic;
gtrxreset : in std_logic;
qpll0lock : in std_logic;
qpll0outclk : in std_logic;
qpll0outrefclk : in std_logic;
qpll0reset : out std_logic;
reset_counter_done : in std_logic;
reset_tx_bufg_gt : out std_logic;
s_axis_tx_tdata : in std_logic_vector(63 downto 0);
s_axis_tx_tkeep : in std_logic_vector(7 downto 0);
s_axis_tx_tlast : in std_logic;
s_axis_tx_tready : out std_logic;
s_axis_tx_tuser : in std_logic_vector(0 downto 0);
s_axis_tx_tvalid : in std_logic;
s_axis_pause_tdata : in std_logic_vector(15 downto 0);
s_axis_pause_tvalid : in std_logic;
m_axis_rx_tdata : out std_logic_vector(63 downto 0);
m_axis_rx_tkeep : out std_logic_vector(7 downto 0);
m_axis_rx_tlast : out std_logic;
m_axis_rx_tuser : out std_logic;
m_axis_rx_tvalid : out std_logic;
tx_statistics_valid : out std_logic;
tx_statistics_vector : out std_logic_vector(25 downto 0);
rx_statistics_valid : out std_logic;
rx_statistics_vector : out std_logic_vector(29 downto 0);
transceiver_debug_gt_dmonitorout : out std_logic_vector(16 downto 0);
transceiver_debug_gt_eyescandataerror : out std_logic;
transceiver_debug_gt_eyescanreset : in std_logic;
transceiver_debug_gt_eyescantrigger : in std_logic;
transceiver_debug_gt_pcsrsvdin : in std_logic_vector(15 downto 0);
transceiver_debug_gt_rxbufstatus : out std_logic_vector(2 downto 0);
transceiver_debug_gt_rxcdrhold : in std_logic;
transceiver_debug_gt_rxdfelpmreset : in std_logic;
transceiver_debug_gt_rxlpmen : in std_logic;
transceiver_debug_gt_rxpmareset : in std_logic;
transceiver_debug_gt_rxpmaresetdone : out std_logic;
transceiver_debug_gt_rxpolarity : in std_logic;
transceiver_debug_gt_rxprbserr : out std_logic;
transceiver_debug_gt_rxrate : in std_logic_vector(2 downto 0);
transceiver_debug_gt_rxresetdone : out std_logic;
transceiver_debug_gt_txbufstatus : out std_logic_vector(1 downto 0);
transceiver_debug_gt_txdiffctrl : in std_logic_vector(3 downto 0);
transceiver_debug_gt_txpmareset : in std_logic;
transceiver_debug_gt_txpolarity : in std_logic;
transceiver_debug_gt_txpostcursor : in std_logic_vector(4 downto 0);
transceiver_debug_gt_txprbsforceerr : in std_logic;
transceiver_debug_gt_txprecursor : in std_logic_vector(4 downto 0);
transceiver_debug_gt_txresetdone : out std_logic
);
end component eth_core;

component eth_core_shared_clocking_wrapper is
port (
reset              : in  std_logic;
refclk_p           : in  std_logic;
refclk_n           : in  std_logic;
qpll0reset         : in  std_logic;
dclk               : in  std_logic;
txoutclk           : in  std_logic;
txoutclk_out       : out std_logic;
coreclk            : out std_logic;
reset_tx_bufg_gt   : in  std_logic;
areset_coreclk     : out std_logic;
areset_txusrclk2   : out std_logic;
gttxreset          : out std_logic;
gtrxreset          : out std_logic;
txuserrdy          : out std_logic;
txusrclk           : out std_logic;
txusrclk2          : out std_logic;
reset_counter_done : out std_logic;
qpll0lock_out      : out std_logic;
qpll0outclk        : out std_logic;
qpll0outrefclk     : out std_logic;
--DRP signals
gt_common_drpaddr  : in  std_logic_vector(8 downto 0);
gt_common_drpclk   : in  std_logic;
gt_common_drpdi    : in  std_logic_vector(15 downto 0);
gt_common_drpdo    : out std_logic_vector(15 downto 0);
gt_common_drpen    : in  std_logic;
gt_common_drprdy   : out std_logic;
gt_common_drpwe    : in  std_logic
);
end component eth_core_shared_clocking_wrapper;

signal i_tx_resetdone   : std_logic;
signal i_rx_resetdone   : std_logic;

signal i_coreclk        : std_logic;
signal i_gttxreset      : std_logic;
signal i_gtrxreset      : std_logic;
signal i_qpll0lock      : std_logic;
signal i_qpll0outclk    : std_logic;
signal i_qpll0outrefclk : std_logic;
signal i_reset_counter_done : std_logic;

signal i_qpll0reset         : std_logic;
signal i_txuserrdy          : std_logic;
signal i_areset_coreclk     : std_logic;
--signal i_areset_txusrclk2   : std_logic;

signal i_reset_tx_bufg_gt   : std_logic_vector(0 downto 0);
signal i_txoutclk           : std_logic_vector(0 downto 0);
signal i_txusrclk           : std_logic_vector(0 downto 0)
signal i_txusrclk2          : std_logic_vector(0 downto 0)


begin --architecture behavioral of eth_core_support is



m_eth_core_shared : eth_core_shared_clocking_wrapper
port map(
reset                 => p_in_reset,
refclk_p              => p_in_refclk_p,
refclk_n              => p_in_refclk_n,
qpll0reset            => i_qpll0reset,--: in  std_logic;
dclk                  => p_in_dclk,
txoutclk              : in  std_logic;
txoutclk_out          : out std_logic;
coreclk               => i_coreclk,--: out std_logic;
reset_tx_bufg_gt      => i_reset_tx_bufg_gt,--: in  std_logic;
areset_coreclk   => i_areset_coreclk,--: out std_logic;
areset_txusrclk2 => open,--i_areset_txusrclk2,--: out std_logic;
gttxreset             => i_gttxreset,--: out std_logic;
gtrxreset             => i_gtrxreset,--: out std_logic;
txuserrdy             => i_txuserrdy,--: out std_logic;
txusrclk              : out std_logic;
txusrclk2             : out std_logic;
reset_counter_done    => i_reset_counter_done,--: out std_logic;
qpll0lock_out         => i_qpll0lock,--: out std_logic;
qpll0outclk           => i_qpll0outclk,--: out std_logic;
qpll0outrefclk        => i_qpll0outrefclk,--: out std_logic;
--DRP signals
gt_common_drpaddr     => "000000000",--: in  std_logic_vector(8 downto 0);
gt_common_drpclk      => '0',
gt_common_drpdi       => "0000000000000000",--: in  std_logic_vector(15 downto 0);
gt_common_drpdo       => open,
gt_common_drpen       => '0',
gt_common_drprdy      => open,
gt_common_drpwe       => '0'
);

p_out_coreclk <= i_coreclk;
p_out_gttxreset <= i_gttxreset;
p_out_gtrxreset <= i_gtrxreset;

p_out_qpll0lock <= i_qpll0lock;
p_out_qpll0outclk <= i_qpll0outclk;
p_out_qpll0outrefclk <= i_qpll0outrefclk;
p_out_reset_counter_done <= i_reset_counter_done;

p_out_qpll0reset <= i_qpll0reset;

p_out_txuserrdy <= i_txuserrdy;



-----------------------------------------------------------------------------
-- Instantiate the 10GBASER/KR GT Common block
-----------------------------------------------------------------------------
gt_common_block_i : eth_core_gt_common
generic map (
WRAPPER_SIM_GTRESET_SPEEDUP => "TRUE"
)
port map (
refclk            => i_gt3_refclk    ,--input  refclk,
qpllreset         => i_qpll0reset    ,--input  qpllreset,
qpll0lock         => i_qpll0lock     ,--output qpll0lock,
qpll0outclk       => i_qpll0outclk   ,--output qpll0outclk,
qpll0outrefclk    => i_qpll0outrefclk,--output qpll0outrefclk,
-- DRP signals
gt_common_drpaddr => "000000000",
gt_common_drpclk  => '0',
gt_common_drpdi   => "0000000000000000",
gt_common_drpdo   => open,
gt_common_drpen   => '0',
gt_common_drprdy  => open,
gt_common_drpwe   => '0'
);

m_ibufds_gt3 : IBUFDS_GTE3
port map (
O     => i_gt3_refclk,
ODIV2 => i_gt3_refclkcopy,
CEB   => '0',
I     => p_in_refclk_p,
IB    => p_in_refclk_n
);

m_refclk_bufg_gt : BUFG_GT
port map (
I       => i_gt3_refclkcopy,
CE      => '1',--(1'b1),
CEMASK  => '1',--(1'b1),
CLR     => '0',--(1'b0),
CLRMASK => '1',--(1'b1),
DIV     => "000",--(3'b000),
O       => i_coreclk
);


-- Asynch reset synchronizers...

m_areset_coreclk_sync : eth_core_ff_synchronizer_rst2
generic map (
C_NUM_SYNC_REGS => 5, --(5),
C_RVAL => '1'         -- (1'b1)
)
port map (
clk      => i_coreclk,
rst      => p_in_reset,--(areset),
data_in  => (1'b0),
data_out => (areset_coreclk)
);

  always @(posedge coreclk)
  begin
    if (areset_coreclk == 1'b1)
      reset_pulse   <=   4'b1110;
    else if(reset_counter[8])
      reset_pulse   <=   {1'b0, reset_pulse[3:1]};
  end


----------------------------
--CH_COUNT
----------------------------
m_txoutclk_bufg_gt : BUFG_GT
port map (
I       => i_txoutclk(0),
CE      => '1',--(1'b1),
CEMASK  => '1',--(1'b1),
CLR     => i_reset_tx_bufg_gt(0),
CLRMASK => '0',--(1'b0),
DIV     => "000",--(3'b000),
O       => i_txusrclk(0)
);

m_txusrclk2_bufg_gt : BUFG_GT
port map (
I       => i_txoutclk(0),
CE      => '1',--(1'b1),
CEMASK  => '1',--(1'b1),
CLR     => i_reset_tx_bufg_gt(0),
CLRMASK => '0',--(1'b0),
DIV     => "001",--(3'b001),
O       => i_txusrclk2(0)
);


p_out_resetdone_out <= i_tx_resetdone and i_rx_resetdone;

------------------------------------------
-- Instantiate the AXI 10G Ethernet core
------------------------------------------
m_eth_core : eth_core
port map(
dclk                         => p_in_dclk,
coreclk                      => i_coreclk,
txoutclk                     => i_txoutclk(0),
txusrclk                     => i_txusrclk(0),
txusrclk2                    => i_txusrclk2(0),
areset_coreclk               => i_areset_coreclk,
txuserrdy                    => i_txuserrdy,
rxrecclk_out                 => p_out_rxrecclk_out,
areset                       => p_in_reset,
tx_resetdone                 => i_tx_resetdone,
rx_resetdone                 => i_rx_resetdone,
reset_counter_done           => i_reset_counter_done,
gttxreset                    => i_gttxreset,
gtrxreset                    => i_gtrxreset,
qpll0lock                    => i_qpll0lock,
qpll0outclk                  => i_qpll0outclk,
qpll0outrefclk               => i_qpll0outrefclk,
qpll0reset                   => i_qpll0reset,
reset_tx_bufg_gt             => i_reset_tx_bufg_gt(0),
tx_ifg_delay                 => p_in_tx_ifg_delay,
tx_statistics_vector         => p_out_tx_statistics_vector,
tx_statistics_valid          => p_out_tx_statistics_valid,
rx_statistics_vector         => p_out_rx_statistics_vector,
rx_statistics_valid          => p_out_rx_statistics_valid,
s_axis_pause_tdata           => p_in_axis_pause_tdata,
s_axis_pause_tvalid          => p_in_axis_pause_tvalid,

tx_axis_aresetn              => p_in_tx_axis_aresetn,
s_axis_tx_tdata              => p_in_axis_tx_tdata,
s_axis_tx_tvalid             => p_in_axis_tx_tvalid,
s_axis_tx_tlast              => p_in_axis_tx_tlast,
s_axis_tx_tuser              => p_in_axis_tx_tuser,
s_axis_tx_tkeep              => p_in_axis_tx_tkeep,
s_axis_tx_tready             => p_out_axis_tx_tready,

rx_axis_aresetn              => p_in_rx_axis_aresetn,
m_axis_rx_tdata              => p_out_axis_rx_tdata,
m_axis_rx_tkeep              => p_out_axis_rx_tkeep,
m_axis_rx_tvalid             => p_out_axis_rx_tvalid,
m_axis_rx_tuser              => p_out_axis_rx_tuser,
m_axis_rx_tlast              => p_out_axis_rx_tlast,
mac_tx_configuration_vector  => p_in_mac_tx_configuration_vector,
mac_rx_configuration_vector  => p_in_mac_rx_configuration_vector,
mac_status_vector            => p_out_mac_status_vector,
pcs_pma_configuration_vector => p_in_pcs_pma_configuration_vector,
pcs_pma_status_vector        => p_out_pcs_pma_status_vector,

--Serial links
txp                          => p_out_txp,
txn                          => p_out_txn,
rxp                          => p_in_rxp,
rxn                          => p_in_rxn,

transceiver_debug_gt_eyescanreset     => '0',     --transceiver_debug_gt_eyescanreset,
transceiver_debug_gt_eyescantrigger   => '0',     --transceiver_debug_gt_eyescantrigger,
transceiver_debug_gt_rxcdrhold        => '0',     --transceiver_debug_gt_rxcdrhold,
transceiver_debug_gt_txprbsforceerr   => '0',     --transceiver_debug_gt_txprbsforceerr,
transceiver_debug_gt_txpolarity       => '0',     --transceiver_debug_gt_txpolarity,
transceiver_debug_gt_rxpolarity       => '0',     --transceiver_debug_gt_rxpolarity,
transceiver_debug_gt_rxrate           => "000",   --transceiver_debug_gt_rxrate,
transceiver_debug_gt_txpmareset       => '0',     --transceiver_debug_gt_txpmareset,
transceiver_debug_gt_rxpmareset       => '0',     --transceiver_debug_gt_rxpmareset,
transceiver_debug_gt_rxdfelpmreset    => '0',     --transceiver_debug_gt_rxdfelpmreset,
transceiver_debug_gt_rxpmaresetdone   => "00000", --transceiver_debug_gt_rxpmaresetdone,
transceiver_debug_gt_txresetdone      => "00000", --transceiver_debug_gt_txresetdone,
transceiver_debug_gt_rxresetdone      => "0000",  --transceiver_debug_gt_rxresetdone,
transceiver_debug_gt_txprecursor      => '0',     --transceiver_debug_gt_txprecursor,
transceiver_debug_gt_txpostcursor     => open,    --transceiver_debug_gt_txpostcursor,
transceiver_debug_gt_txdiffctrl       => open,    --transceiver_debug_gt_txdiffctrl,
transceiver_debug_gt_rxlpmen          => open,    --transceiver_debug_gt_rxlpmen,
transceiver_debug_gt_eyescandataerror => open,    --transceiver_debug_gt_eyescandataerror,
transceiver_debug_gt_txbufstatus      => open,    --transceiver_debug_gt_txbufstatus,
transceiver_debug_gt_rxbufstatus      => open,    --transceiver_debug_gt_rxbufstatus,
transceiver_debug_gt_rxprbserr        => open,    --transceiver_debug_gt_rxprbserr,
transceiver_debug_gt_dmonitorout      => open,    --transceiver_debug_gt_dmonitorout,
transceiver_debug_gt_pcsrsvdin        => "0000000000000000",--transceiver_debug_gt_pcsrsvdin,

sim_speedup_control => p_in_sim_speedup_control,
signal_detect       => p_in_signal_detect,
tx_fault            => p_in_tx_fault,
tx_disable          => p_out_tx_disable,
pcspma_status       => p_out_pcspma_status
);

end architecture behavioral;
