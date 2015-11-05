-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 03.05.2011 16:39:38
-- Module Name : eth_core_fifo_block
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_core_fifo_block is
generic(
G_GT_CHANNEL_COUNT : integer := 1;
G_FIFO_SIZE : integer := 1024
);
port(
-- Port declarations
refclk_p                     : in  std_logic;
refclk_n                     : in  std_logic;
dclk                         : in  std_logic;
reset                        : in  std_logic;
resetdone_out                : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
qplllock_out                 : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
coreclk_out                  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxrecclk_out                 : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

mac_tx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
mac_rx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
mac_status_vector            : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
pcs_pma_configuration_vector : in  std_logic_vector((536 * G_GT_CHANNEL_COUNT) - 1 downto 0);
pcs_pma_status_vector        : out std_logic_vector((448 * G_GT_CHANNEL_COUNT) - 1 downto 0);

tx_ifg_delay                 : in  std_logic_vector(7 downto 0);
tx_statistics_vector         : out std_logic_vector((26 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_statistics_vector         : out std_logic_vector((30 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_statistics_valid          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_statistics_valid          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_mac_aresetn          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_aresetn         : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tdata           : in  std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_axis_fifo_tkeep           : in  std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_axis_fifo_tvalid          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tlast           : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tready          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

rx_axis_mac_aresetn          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_aresetn         : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tdata           : out std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_axis_fifo_tkeep           : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_axis_fifo_tvalid          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tlast           : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tready          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

pause_val                    : in  std_logic_vector(15 downto 0);
pause_req                    : in  std_logic;

txp                          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
txn                          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxp                          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxn                          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

signal_detect                : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
sim_speedup_control          : in  std_logic;
tx_fault                     : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
pcspma_status               : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
);
end entity eth_core_fifo_block;

architecture behavioral of eth_core_fifo_block is

component eth_core_xgmac_fifo is
generic(
TX_FIFO_SIZE : integer := 512;
RX_FIFO_SIZE : integer := 512
);
port
(
----------------------------------------------------------------
-- client interface                                           --
----------------------------------------------------------------
-- tx_wr_clk domain
tx_axis_fifo_aresetn : in  std_logic;
tx_axis_fifo_aclk    : in  std_logic;
tx_axis_fifo_tdata   : in  std_logic_vector(63 downto 0);
tx_axis_fifo_tkeep   : in  std_logic_vector(7 downto 0);
tx_axis_fifo_tvalid  : in  std_logic;
tx_axis_fifo_tlast   : in  std_logic;
tx_axis_fifo_tready  : out std_logic;
tx_fifo_full         : out std_logic;
tx_fifo_status       : out std_logic_vector(3 downto 0);
--rx_rd_clk domain
rx_axis_fifo_aresetn : in  std_logic;
rx_axis_fifo_aclk    : in  std_logic;
rx_axis_fifo_tdata   : out std_logic_vector(63 downto 0);
rx_axis_fifo_tkeep   : out std_logic_vector(7 downto 0);
rx_axis_fifo_tvalid  : out std_logic;
rx_axis_fifo_tlast   : out std_logic;
rx_axis_fifo_tready  : in  std_logic;
rx_fifo_status       : out std_logic_vector(3 downto 0);
----------------------------------------------------------------
-- mac transmitter interface                                  --
----------------------------------------------------------------
tx_axis_mac_aresetn : in  std_logic;
tx_axis_mac_aclk    : in  std_logic;
tx_axis_mac_tdata   : out std_logic_vector(63 downto 0);
tx_axis_mac_tkeep   : out std_logic_vector(7 downto 0);
tx_axis_mac_tvalid  : out std_logic;
tx_axis_mac_tlast   : out std_logic;
tx_axis_mac_tready  : in  std_logic;
----------------------------------------------------------------
-- mac receiver interface                                     --
----------------------------------------------------------------
rx_axis_mac_aresetn : in  std_logic;
rx_axis_mac_aclk    : in  std_logic;
rx_axis_mac_tdata   : in  std_logic_vector(63 downto 0);
rx_axis_mac_tkeep   : in  std_logic_vector(7 downto 0);
rx_axis_mac_tvalid  : in  std_logic;
rx_axis_mac_tlast   : in  std_logic;
rx_axis_mac_tuser   : in  std_logic;
rx_fifo_full        : out std_logic
);
end component eth_core_xgmac_fifo;

component eth_core_support
generic(
G_GT_CHANNEL_COUNT : integer := 1
);
port(
-- Port declarations
p_in_refclk_p                 : in  std_logic;
p_in_refclk_n                 : in  std_logic;
p_in_dclk                     : in  std_logic;
p_out_coreclk              : out std_logic;
p_in_reset                 : in  std_logic;
p_out_qpll0outclk          : out std_logic;
p_out_qpll0outrefclk       : out std_logic;
p_out_qpll0lock            : out std_logic;
p_out_qpll0reset           : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_resetdone            : out std_logic;
p_out_txusrclk             : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_txusrclk2            : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_gttxreset            : out std_logic;
p_out_gtrxreset            : out std_logic;
p_out_txuserrdy            : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_reset_counter_done   : out std_logic;

p_in_mac_tx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_mac_rx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_mac_status_vector           : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_pcs_pma_configuration_vector : in  std_logic_vector((536 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_pcs_pma_status_vector       : out std_logic_vector((448 * G_GT_CHANNEL_COUNT) - 1 downto 0);

p_in_tx_ifg_delay   : in  std_logic_vector(7 downto 0);

p_out_tx_statistics_vector   : out std_logic_vector((26 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_rx_statistics_vector   : out std_logic_vector((30 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_tx_statistics_valid    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_rx_statistics_valid    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_in_tx_axis_aresetn    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tdata    : in  std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1  downto 0);
p_in_s_axis_tx_tkeep    : in  std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_s_axis_tx_tvalid   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tlast    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tuser    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_s_axis_tx_tready  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_in_rx_axis_aresetn    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tdata   : out std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1  downto 0);
p_out_m_axis_rx_tkeep   : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_m_axis_rx_tvalid  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tuser   : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tlast   : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

--transceiver_debug_gt_eyescanreset        : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_eyescantrigger      : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxcdrhold           : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txprbsforceerr      : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txpolarity          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpolarity          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxrate              : in  std_logic_vector((3 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txpmareset          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpmareset          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxdfelpmreset       : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txprecursor         : in  std_logic_vector((5 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txpostcursor        : in  std_logic_vector((5 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txdiffctrl          : in  std_logic_vector((4 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_rxlpmen             : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_eyescandataerror    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txbufstatus         : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txresetdone         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpmaresetdone      : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxresetdone         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxbufstatus         : out std_logic_vector((3 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_rxprbserr           : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_dmonitorout         : out std_logic_vector((17 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_pcsrsvdin           : in  std_logic_vector((16 * G_GT_CHANNEL_COUNT) - 1 downto 0);


--Pause axis
p_in_s_axis_pause_tdata    : in  std_logic_vector(15 downto 0);
p_in_s_axis_pause_tvalid   : in  std_logic;

p_out_txp  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_txn  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_rxp   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_rxn   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_out_tx_disable         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_rxrecclk_out       : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_signal_detect       : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_sim_speedup_control : in  std_logic;
p_in_tx_fault            : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_pcspma_status      : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0)
);
end component eth_core_support;


signal i_tx_axis_mac_tdata  : std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_tx_axis_mac_tkeep  : std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_tx_axis_mac_tvalid : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_mac_tlast  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_mac_tready : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

signal i_rx_axis_mac_tdata  : std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_rx_axis_mac_tkeep  : std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_rx_axis_mac_tvalid : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_mac_tuser  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_mac_tlast  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

signal i_coreclk            : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_disable         : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);



begin --architecture behavioral of eth_core_fifo_block is

gen_fifo : for i in 0 to G_GT_CHANNEL_COUNT - 1 generate
begin

m_gmac_fifo : eth_core_xgmac_fifo
generic map(
TX_FIFO_SIZE => G_FIFO_SIZE,
RX_FIFO_SIZE => G_FIFO_SIZE
)
port (
----------------------------------------------------------------
-- client interface                                           --
----------------------------------------------------------------
-- tx_wr_clk domain
tx_axis_fifo_aresetn : in  std_logic;
tx_axis_fifo_aclk    => i_coreclk,--: in  std_logic;
tx_axis_fifo_tdata   => tx_axis_fifo_tdata((64 * (i + 1)) - 1 downto (64 * i)),
tx_axis_fifo_tkeep   => tx_axis_fifo_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
tx_axis_fifo_tvalid  => tx_axis_fifo_tvalid(i), --: in  std_logic;
tx_axis_fifo_tlast   => tx_axis_fifo_tlast(i) , --: in  std_logic;
tx_axis_fifo_tready  => tx_axis_fifo_tready(i), --: out std_logic;
tx_fifo_full         => open,
tx_fifo_status       => open,
--rx_rd_clk domain
rx_axis_fifo_aresetn : in  std_logic;
rx_axis_fifo_aclk    => i_coreclk ,--: in  std_logic;
rx_axis_fifo_tdata   => rx_axis_fifo_tdata((64 * (i + 1)) - 1 downto (64 * i)),
rx_axis_fifo_tkeep   => rx_axis_fifo_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
rx_axis_fifo_tvalid  => rx_axis_fifo_tvalid(i),
rx_axis_fifo_tlast   => rx_axis_fifo_tlast(i) ,
rx_axis_fifo_tready  => rx_axis_fifo_tready(i),
rx_fifo_status       => open,
----------------------------------------------------------------
-- mac transmitter interface                                  --
----------------------------------------------------------------
tx_axis_mac_aresetn : in  std_logic;
tx_axis_mac_aclk    : in  std_logic;
tx_axis_mac_tdata   => i_tx_axis_mac_tdata((64 * (i + 1)) - 1 downto (64 * i)),
tx_axis_mac_tkeep   => i_tx_axis_mac_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
tx_axis_mac_tvalid  => i_tx_axis_mac_tvalid(i),
tx_axis_mac_tlast   => i_tx_axis_mac_tlast(i) ,
tx_axis_mac_tready  => i_tx_axis_mac_tready(i),
----------------------------------------------------------------
-- mac receiver interface                                     --
----------------------------------------------------------------
rx_axis_mac_aresetn : in  std_logic;
rx_axis_mac_aclk    : in  std_logic;
rx_axis_mac_tdata   => i_rx_axis_mac_tdata((64 * (i + 1)) - 1 downto (64 * i)),
rx_axis_mac_tkeep   => i_rx_axis_mac_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
rx_axis_mac_tvalid  => i_rx_axis_mac_tvalid(i),
rx_axis_mac_tlast   => i_rx_axis_mac_tlast(i) ,
rx_axis_mac_tuser   => i_rx_axis_mac_tuser(i) ,
rx_fifo_full        => open,
);
end generate gen_fifo;



m_eth_core_support : eth_core_support
generic map(
G_GT_CHANNEL_COUNT => G_GT_CHANNEL_COUNT
)
port map(
-- Port declarations
p_in_refclk_p                 : in  std_logic;
p_in_refclk_n                 : in  std_logic;
p_in_dclk                     : in  std_logic;
p_out_coreclk              : out std_logic;
p_in_reset                 : in  std_logic;
p_out_qpll0outclk          : out std_logic;
p_out_qpll0outrefclk       : out std_logic;
p_out_qpll0lock            : out std_logic;
p_out_qpll0reset           : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_resetdone            : out std_logic;
p_out_txusrclk             : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_txusrclk2            : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_gttxreset            : out std_logic;
p_out_gtrxreset            : out std_logic;
p_out_txuserrdy            : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_reset_counter_done   : out std_logic;

p_in_mac_tx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_mac_rx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_mac_status_vector           : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_pcs_pma_configuration_vector : in  std_logic_vector((536 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_pcs_pma_status_vector       : out std_logic_vector((448 * G_GT_CHANNEL_COUNT) - 1 downto 0);

p_in_tx_ifg_delay   : in  std_logic_vector(7 downto 0);

p_out_tx_statistics_vector   : out std_logic_vector((26 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_rx_statistics_vector   : out std_logic_vector((30 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_tx_statistics_valid    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_rx_statistics_valid    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_in_tx_axis_aresetn    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tdata    : in  std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1  downto 0);
p_in_s_axis_tx_tkeep    : in  std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_in_s_axis_tx_tvalid   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tlast    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_s_axis_tx_tuser    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_s_axis_tx_tready  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_in_rx_axis_aresetn    : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tdata   : out std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1  downto 0);
p_out_m_axis_rx_tkeep   : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
p_out_m_axis_rx_tvalid  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tuser   : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_m_axis_rx_tlast   : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

--transceiver_debug_gt_eyescanreset        : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_eyescantrigger      : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxcdrhold           : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txprbsforceerr      : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txpolarity          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpolarity          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxrate              : in  std_logic_vector((3 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txpmareset          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpmareset          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxdfelpmreset       : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txprecursor         : in  std_logic_vector((5 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txpostcursor        : in  std_logic_vector((5 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txdiffctrl          : in  std_logic_vector((4 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_rxlpmen             : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_eyescandataerror    : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_txbufstatus         : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_txresetdone         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxpmaresetdone      : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxresetdone         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_rxbufstatus         : out std_logic_vector((3 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_rxprbserr           : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
--transceiver_debug_gt_dmonitorout         : out std_logic_vector((17 * G_GT_CHANNEL_COUNT) - 1 downto 0);
--transceiver_debug_gt_pcsrsvdin           : in  std_logic_vector((16 * G_GT_CHANNEL_COUNT) - 1 downto 0);


--Pause axis
p_in_s_axis_pause_tdata    : in  std_logic_vector(15 downto 0);
p_in_s_axis_pause_tvalid   : in  std_logic;

p_out_txp  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_txn  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_rxp   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_rxn   : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

p_out_tx_disable         : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_rxrecclk_out       : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_signal_detect       : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_in_sim_speedup_control : in  std_logic;
p_in_tx_fault            : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
p_out_pcspma_status      : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0)
);

end architecture behavioral;
