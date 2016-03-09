-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 17:10:15
-- Module Name : eth_main
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.prj_def.all;
use work.eth_pkg.all;

entity eth_main is
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
p_in_reg : TEthCtrl;

-------------------------------
--UsrBuf
-------------------------------
--rxbuf <- eth
p_in_rxbuf_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tkeep  : out  std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_out_rxbuf_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_rxbuf_axi_tuser  : out  std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--txbuf -> eth
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
p_out_sfp_tx_disable   : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

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
p_out_dbg : out TEthDBG;

-------------------------------
--System
-------------------------------
p_in_dclk : in  std_logic; --DRP clk
p_in_rst : in  std_logic
);
end entity eth_main;

architecture behavioral of eth_main is


component eth_mac_rx is
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
--USR RXBUF <- ETH
--------------------------------------
p_in_usr_axi_tready  : in   std_logic;
p_out_usr_axi_tdata  : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_usr_axi_tkeep  : out  std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_out_usr_axi_tvalid : out  std_logic;
p_out_usr_axi_tuser  : out  std_logic_vector(1 downto 0);

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_eth_axi_tready : out  std_logic;
p_in_eth_axi_tdata   : in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_eth_axi_tkeep   : in   std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_in_eth_axi_tvalid  : in   std_logic;
p_in_eth_axi_tlast   : in   std_logic;

--------------------------------------
--DBG
--------------------------------------
p_in_tst  : in    std_logic_vector(31 downto 0);
p_out_tst : out   std_logic_vector(31 downto 0);
--p_out_dbg : out   TEthDBG_MacRx;

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk  : in  std_logic;
p_in_rst  : in  std_logic
);
end component eth_mac_rx;

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


component eth_app is
generic (
G_FIFO_SIZE : integer := 1024; -- Set FIFO memory size
G_AXI_DWIDTH : integer := 64;
G_GTCH_COUNT : integer := 1
);
port(
--Clock inputs
clk_in    : in  std_logic;       --Freerunning clock source

refclk_p  : in  std_logic;       --Transceiver reference clock source
refclk_n  : in  std_logic;
coreclk_out : out std_logic;

--Example design control inputs
reset                : in  std_logic;

sim_speedup_control  : in  std_logic;

--Example design status outputs
frame_error     : out  std_logic;

block_lock      : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
core_ready      : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
qplllock_out    : out  std_logic;

signal_detect   : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_fault        : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_disable      : out std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

tx_axis_tdata   : in  std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0);
tx_axis_tkeep   : in  std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
tx_axis_tvalid  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_tlast   : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_tready  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

rx_axis_tdata   : out std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0);
rx_axis_tkeep   : out std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
rx_axis_tvalid  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_tlast   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_tready  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);

dbg_rx_axis_mac_tdata   : out std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0)      ;
dbg_rx_axis_mac_tkeep   : out std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
dbg_rx_axis_mac_tvalid  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_rx_axis_mac_tlast   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_rx_axis_mac_tuser   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;

dbg_tx_axis_mac_tdata   : out std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0)      ;
dbg_tx_axis_mac_tkeep   : out std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
dbg_tx_axis_mac_tvalid  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_tx_axis_mac_tlast   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_tx_axis_mac_tready  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;

dbg_tx_axis_fifo_tdata   : out std_logic_vector((G_AXI_DWIDTH * G_GTCH_COUNT) - 1 downto 0)      ;
dbg_tx_axis_fifo_tkeep   : out std_logic_vector(((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 downto 0);
dbg_tx_axis_fifo_tvalid  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_tx_axis_fifo_tlast   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;
dbg_tx_axis_fifo_tready  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0)                       ;

--Serial I/O from/to transceiver
txp  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
txn  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxp  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxn  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0)
);
end component eth_app;


Type TEthCH_CFG is array (0 to G_ETH_CH_COUNT - 1) of TEthCfg;
signal i_reg_ethcfg      : TEthCH_CFG;

signal i_tx_mac_aresetn  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_tx_fifo_aresetn : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_tx_fifo_tdata   : std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
signal i_tx_fifo_tkeep   : std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
signal i_tx_fifo_tvalid  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_tx_fifo_tlast   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_tx_fifo_tready  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

signal i_rx_mac_aresetn  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_rx_fifo_aresetn : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_rx_fifo_tdata   : std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
signal i_rx_fifo_tkeep   : std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
signal i_rx_fifo_tvalid  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_rx_fifo_tlast   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_rx_fifo_tready  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

signal i_coreclk_out     : std_logic;
signal i_block_lock      : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal i_buf_rst         : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

signal dbg_rx_axis_mac_tdata   : std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0)      ;
signal dbg_rx_axis_mac_tkeep   : std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
signal dbg_rx_axis_mac_tvalid  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_rx_axis_mac_tlast   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_rx_axis_mac_tuser   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;

signal dbg_tx_axis_mac_tdata   : std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0)      ;
signal dbg_tx_axis_mac_tkeep   : std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
signal dbg_tx_axis_mac_tvalid  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_tx_axis_mac_tlast   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_tx_axis_mac_tready  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;

signal dbg_tx_axis_fifo_tdata  : std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0)      ;
signal dbg_tx_axis_fifo_tkeep  : std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
signal dbg_tx_axis_fifo_tvalid : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_tx_axis_fifo_tlast  : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;
signal dbg_tx_axis_fifo_tready : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0)                       ;

signal i_eth_mac_tx_tst_out : std_logic_vector((32 * G_ETH_CH_COUNT) - 1 downto 0);
signal i_eth_mac_rx_tst_out : std_logic_vector((32 * G_ETH_CH_COUNT) - 1 downto 0);

--signal i_dbg_out         : TEthDBG;



begin --architecture behavioral of eth_main is


----------------------------------------------------
--
----------------------------------------------------
gen_mac_ch: for i in 0 to (G_ETH_CH_COUNT - 1) generate
begin

process(i_coreclk_out)
begin
if rising_edge(i_coreclk_out) then
  i_reg_ethcfg(i) <= p_in_reg(0);
end if;
end process;

m_mac_tx : eth_mac_tx
generic map(
G_AXI_DWIDTH => G_ETH_DWIDTH,
G_DBG => "OFF"
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => i_reg_ethcfg(i),

--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_usr_axi_tdata   => p_in_txbuf_axi_tdata((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i)),
p_out_usr_axi_tready => p_out_txbuf_axi_tready(i),
p_in_usr_axi_tvalid  => p_in_txbuf_axi_tvalid(i),
p_out_usr_axi_done   => p_out_txbuf_axi_done(i),

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_eth_axi_tready  => i_tx_fifo_tready(i),
p_out_eth_axi_tdata  => i_tx_fifo_tdata((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i)),
p_out_eth_axi_tkeep  => i_tx_fifo_tkeep(((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i)),
p_out_eth_axi_tvalid => i_tx_fifo_tvalid(i),
p_out_eth_axi_tlast  => i_tx_fifo_tlast(i),

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => i_eth_mac_tx_tst_out((32 * (i + 1)) - 1 downto (32 * i)),
--p_out_dbg => p_out_dbg.tx(i),

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out,
p_in_rst => i_buf_rst(i) --p_in_rst
);


m_mac_rx : eth_mac_rx
generic map(
G_AXI_DWIDTH => G_ETH_DWIDTH,
G_DBG => G_DBG
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => i_reg_ethcfg(i),

--------------------------------------
--USR RXBUF <- ETH
--------------------------------------
p_in_usr_axi_tready  => p_in_rxbuf_axi_tready (i),
p_out_usr_axi_tdata  => p_out_rxbuf_axi_tdata ((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i)),
p_out_usr_axi_tkeep  => p_out_rxbuf_axi_tkeep (((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i)),
p_out_usr_axi_tvalid => p_out_rxbuf_axi_tvalid(i),
p_out_usr_axi_tuser  => p_out_rxbuf_axi_tuser ((2 * (i + 1)) - 1 downto (2 * i)),

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_eth_axi_tready => i_rx_fifo_tready(i),
p_in_eth_axi_tdata   => i_rx_fifo_tdata((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i)),
p_in_eth_axi_tkeep   => i_rx_fifo_tkeep(((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i)),
p_in_eth_axi_tvalid  => i_rx_fifo_tvalid(i),
p_in_eth_axi_tlast   => i_rx_fifo_tlast(i),

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => i_eth_mac_rx_tst_out((32 * (i + 1)) - 1 downto (32 * i)),
--p_out_dbg => p_out_dbg.rx(i),

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out,
p_in_rst => i_buf_rst(i) --p_in_rst
);

p_out_buf_clk(i) <= i_coreclk_out;
i_buf_rst(i) <= not i_block_lock(i);
p_out_buf_rst(i) <= i_buf_rst(i);

p_out_dbg.rx(i).fsm <= i_eth_mac_rx_tst_out((32 * i) + 2 downto (32 * i) + 0);

p_out_dbg.rx(i).mac_tdata  <= dbg_rx_axis_mac_tdata ((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i))            ;
p_out_dbg.rx(i).mac_tkeep  <= dbg_rx_axis_mac_tkeep (((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i));
p_out_dbg.rx(i).mac_tvalid <= dbg_rx_axis_mac_tvalid(i)                                                                 ;
p_out_dbg.rx(i).mac_tlast  <= dbg_rx_axis_mac_tlast (i)                                                                 ;
p_out_dbg.rx(i).mac_tuser  <= dbg_rx_axis_mac_tuser (i)                                                                 ;


p_out_dbg.tx(i).fsm          <= i_eth_mac_tx_tst_out((32 * i) + 2 downto (32 * i) + 0);

p_out_dbg.tx(i).mac_tdata  <= dbg_tx_axis_mac_tdata ((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i))            ;
p_out_dbg.tx(i).mac_tkeep  <= dbg_tx_axis_mac_tkeep (((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i));
p_out_dbg.tx(i).mac_tvalid <= dbg_tx_axis_mac_tvalid(i)                                                                 ;
p_out_dbg.tx(i).mac_tlast  <= dbg_tx_axis_mac_tlast (i)                                                                 ;
p_out_dbg.tx(i).mac_tready <= dbg_tx_axis_mac_tready(i)                                                                 ;

p_out_dbg.tx(i).fifo_tdata  <= dbg_tx_axis_fifo_tdata ((G_ETH_DWIDTH * (i + 1)) - 1 downto (G_ETH_DWIDTH * i))            ;
p_out_dbg.tx(i).fifo_tkeep  <= dbg_tx_axis_fifo_tkeep (((G_ETH_DWIDTH / 8) * (i + 1)) - 1 downto ((G_ETH_DWIDTH / 8) * i));
p_out_dbg.tx(i).fifo_tvalid <= dbg_tx_axis_fifo_tvalid(i)                                                                 ;
p_out_dbg.tx(i).fifo_tlast  <= dbg_tx_axis_fifo_tlast (i)                                                                 ;
p_out_dbg.tx(i).fifo_tready <= dbg_tx_axis_fifo_tready(i)                                                                 ;

end generate gen_mac_ch;


m_eth_app : eth_app
generic map(
G_FIFO_SIZE => 2048, -- Set FIFO memory size
G_AXI_DWIDTH => G_ETH_DWIDTH,
G_GTCH_COUNT => G_ETH_CH_COUNT
)
port map(
--Clock inputs
clk_in => p_in_dclk,  --Freerunning clock source

refclk_p => p_in_ethphy_refclk_p, --Transceiver reference clock source
refclk_n => p_in_ethphy_refclk_n,

coreclk_out => i_coreclk_out,

--Example design control inputs
reset    => p_in_rst,

sim_speedup_control => p_in_sim_speedup_control,

--Example design status outputs
frame_error  => open,

block_lock => i_block_lock,
core_ready  => p_out_status_rdy,
qplllock_out => p_out_status_qplllock,

signal_detect => p_in_sfp_signal_detect,
tx_fault      => p_in_sfp_tx_fault,
tx_disable    => p_out_sfp_tx_disable,

tx_axis_tdata   => i_tx_fifo_tdata,
tx_axis_tkeep   => i_tx_fifo_tkeep,
tx_axis_tvalid  => i_tx_fifo_tvalid,
tx_axis_tlast   => i_tx_fifo_tlast,
tx_axis_tready  => i_tx_fifo_tready,

rx_axis_tdata   => i_rx_fifo_tdata,
rx_axis_tkeep   => i_rx_fifo_tkeep,
rx_axis_tvalid  => i_rx_fifo_tvalid,
rx_axis_tlast   => i_rx_fifo_tlast,
rx_axis_tready  => i_rx_fifo_tready,

dbg_rx_axis_mac_tdata   => dbg_rx_axis_mac_tdata ,
dbg_rx_axis_mac_tkeep   => dbg_rx_axis_mac_tkeep ,
dbg_rx_axis_mac_tvalid  => dbg_rx_axis_mac_tvalid,
dbg_rx_axis_mac_tlast   => dbg_rx_axis_mac_tlast ,
dbg_rx_axis_mac_tuser   => dbg_rx_axis_mac_tuser ,

dbg_tx_axis_mac_tdata   => dbg_tx_axis_mac_tdata ,
dbg_tx_axis_mac_tkeep   => dbg_tx_axis_mac_tkeep ,
dbg_tx_axis_mac_tvalid  => dbg_tx_axis_mac_tvalid,
dbg_tx_axis_mac_tlast   => dbg_tx_axis_mac_tlast ,
dbg_tx_axis_mac_tready  => dbg_tx_axis_mac_tready,

dbg_tx_axis_fifo_tdata  => dbg_tx_axis_fifo_tdata ,
dbg_tx_axis_fifo_tkeep  => dbg_tx_axis_fifo_tkeep ,
dbg_tx_axis_fifo_tvalid => dbg_tx_axis_fifo_tvalid,
dbg_tx_axis_fifo_tlast  => dbg_tx_axis_fifo_tlast ,
dbg_tx_axis_fifo_tready => dbg_tx_axis_fifo_tready,


--Serial I/O from/to transceiver
txp => p_out_ethphy_txp,
txn => p_out_ethphy_txn,
rxp => p_in_ethphy_rxp,
rxn => p_in_ethphy_rxn
);


----------------------------------------------------
--DBG
----------------------------------------------------
--gen_use_on : if strcmp(G_MODULE_USE, "ON") generate
p_out_tst <= (others => '0');
--end generate gen_use_on;

--gen_use_off : if strcmp(G_MODULE_USE, "OFF") generate
--p_out_tst <= (others => '0');
--end generate gen_use_off;

end architecture behavioral;
