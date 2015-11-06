-------------------------------------------------------------------------
-- Company     : Linkos
-- Engineer    : Golovachenko Victor
--
-- Create Date : 03.05.2011 16:39:38
-- Module Name : eth_main
--
-- Назначение/Описание :
--  Прием/передача данных по Eth
--
-- Revision:
-- Revision 0.01 - File Created
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_def.all;
use work.eth_pkg.all;
use work.eth_unit_pkg.all;

entity eth_main is
generic(
G_DBG        : string:="OFF";
G_SIM        : string:="OFF"
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk      : in   std_logic;

p_in_cfg_adr      : in   std_logic_vector(2 downto 0);
p_in_cfg_adr_ld   : in   std_logic;

p_in_cfg_txdata   : in   std_logic_vector(15 downto 0);
p_in_cfg_wr       : in   std_logic;

p_out_cfg_rxdata  : out  std_logic_vector(15 downto 0);
p_in_cfg_rd       : in   std_logic;

p_in_cfg_done     : in   std_logic;
p_in_cfg_rst      : in   std_logic;

-------------------------------
--Связь с UsrBuf
-------------------------------
p_out_eth         : out   TEthOUTs;
p_in_eth          : in    TEthINs;

-------------------------------
--ETH
-------------------------------
p_out_ethphy      : out   TEthPhyOUT;
p_in_ethphy       : in    TEthPhyIN;

-------------------------------
--DBG
-------------------------------
p_out_dbg         : out   TEthDBG;
p_in_tst          : in    std_logic_vector(31 downto 0);
p_out_tst         : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst          : in    std_logic
);
end entity eth_main;

architecture behavioral of eth_main is


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
--ETH -> USR RXBUF
--------------------------------------
p_out_rxbuf_di   : out   std_logic_vector(G_USRBUF_DWIDTH - 1 downto 0);
p_out_rxbuf_wr   : out   std_logic;
p_in_rxbuf_full  : in    std_logic;
p_out_rxbuf_sof  : out   std_logic;
p_out_rxbuf_eof  : out   std_logic;

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_axi_tready : out   std_logic;
p_in_axi_tdata   : in    std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_axi_tkeep   : in    std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_in_axi_tvalid  : in    std_logic;
p_in_axi_tlast   : in    std_logic;

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

component eth_mac_tx is
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
--ETH <- USR TXBUF
--------------------------------------
p_in_txbuf_do    : in   std_logic_vector(G_USRBUF_DWIDTH - 1 downto 0);
p_out_txbuf_rd   : out  std_logic;
p_in_txbuf_empty : in   std_logic;
--p_in_txd_rdy     : in  std_logic;

--------------------------------------

--------------------------------------
p_in_axi_tready  : in   std_logic;
p_out_axi_tdata  : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_axi_tkeep  : out  std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_out_axi_tvalid : out  std_logic;
p_out_axi_tlast  : out  std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk : in   std_logic;
p_in_rst : in   std_logic
);
end component eth_mac_tx;


component eth_core_fifo_block is
generic(
G_GT_CHANNEL_COUNT : integer := 1;
FIFO_SIZE : integer := 1024
);
port(
-- Port declarations
refclk_p                     : in  std_logic;
refclk_n                     : in  std_logic;
dclk                         : in  std_logic;
reset                        : in  std_logic;
resetdone_out                : out std_logic;
qplllock_out                 : out std_logic;
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
pcspma_status               : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0)
);
end component eth_core_fifo_block;

signal i_reg_adr             : unsigned(p_in_cfg_adr'range);

signal h_reg_ethcfg          : TEthCfg;


signal i_tx_axis_mac_aresetn  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_fifo_aresetn : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tdata   : std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_tx_axis_fifo_tkeep   : std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_tx_axis_fifo_tvalid  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tlast   : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tready  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

signal i_rx_axis_mac_aresetn  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_fifo_aresetn : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tdata   : std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_rx_axis_fifo_tkeep   : std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
signal i_rx_axis_fifo_tvalid  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tlast   : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tready  : std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);


signal i_eth_main_tst_out    : std_logic_vector(31 downto 0);
signal i_dbg_out             : TEthDBG;


begin --architecture behavioral of eth_main is


----------------------------------------------------
--Configuration
----------------------------------------------------
--adress
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    i_reg_adr <= (others => '0');
  else
    if p_in_cfg_adr_ld = '1' then
      i_reg_adr <= UNSIGNED(p_in_cfg_adr);
    else
      if (p_in_cfg_wr = '1' or p_in_cfg_rd = '1') then
        i_reg_adr <= i_reg_adr + 1;
      end if;
    end if;
  end if;
end if;
end process;

--write registers
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_cfg_rst = '1' then
    for i in 0 to h_reg_ethcfg.mac.dst'high loop
    h_reg_ethcfg.mac.dst(i) <= (others => '0');
    h_reg_ethcfg.mac.src(i) <= (others => '0');
    end loop;

  else
    if p_in_cfg_wr = '1' then
        if i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN0, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(0) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.dst(1) <= p_in_cfg_txdata(15 downto 8);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN1, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(2) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.dst(3) <= p_in_cfg_txdata(15 downto 8);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN2, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(4) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.dst(5) <= p_in_cfg_txdata(15 downto 8);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN3, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(0) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.src(1) <= p_in_cfg_txdata(15 downto 8);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN4, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(2) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.src(3) <= p_in_cfg_txdata(15 downto 8);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN5, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(4) <= p_in_cfg_txdata(7 downto 0);
          h_reg_ethcfg.mac.src(5) <= p_in_cfg_txdata(15 downto 8);

        end if;
    end if;
  end if;
end if;
end process;

--read registers
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_cfg_rst = '1' then
    p_out_cfg_rxdata <= (others => '0');
  else
    if p_in_cfg_rd = '1' then
        if i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN0, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.dst(0);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.dst(1);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN1, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.dst(2);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.dst(3);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN2, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.dst(4);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.dst(5);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN3, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.src(0);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.src(1);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN4, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.src(2);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.src(3);

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN5, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= h_reg_ethcfg.mac.src(4);
          p_out_cfg_rxdata(15 downto 8) <= h_reg_ethcfg.mac.src(5);

        end if;
    end if;
  end if;
end if;
end process;



----------------------------------------------------
--
----------------------------------------------------
gen_mac_ch: for i 0 to 1 generate
begin

m_mac_tx : eth_mac_tx
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
--ETH <- USR TXBUF
--------------------------------------
p_in_txbuf_do => std_logic_vector(i_txbuf_dout),
p_out_txbuf_rd => open,
p_in_txbuf_empty => '0',
--p_in_txd_rdy      : in    std_logic;

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_axi_tready  => i_tx_axis_fifo_tready(i),
p_out_axi_tdata  => i_tx_axis_fifo_tdata((64 * (i + 1)) - 1 downto (64 * i)),
p_out_axi_tkeep  => i_tx_axis_fifo_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
p_out_axi_tvalid => i_tx_axis_fifo_tvalid(i),
p_out_axi_tlast  => i_tx_axis_fifo_tlast(i),

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


m_mac_rx : eth_mac_rx
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
--ETH -> USR RXBUF
--------------------------------------
p_out_rxbuf_di  => p_out_rxbuf_di,
p_out_rxbuf_wr  => p_out_rxbuf_wr,
p_in_rxbuf_full => '0',
p_out_rxbuf_sof => p_out_rxd_sof,
p_out_rxbuf_eof => p_out_rxd_eof,

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_axi_tready => i_rx_axis_fifo_tready(i),
p_in_axi_tdata   => i_rx_axis_fifo_tdata((64 * (i + 1)) - 1 downto (64 * i)),
p_in_axi_tkeep   => i_rx_axis_fifo_tkeep((8 * (i + 1)) - 1 downto (8 * i)),
p_in_axi_tvalid  => i_rx_axis_fifo_tvalid(i),
p_in_axi_tlast   => i_rx_axis_fifo_tlast(i),

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

end generate gen_mac_ch;


m_eth_phy : eth_core_fifo_block
generic map (
G_GT_CHANNEL_COUNT => 1,
FIFO_SIZE => 1024
)
port(
-- Port declarations
refclk_p                     : in  std_logic;
refclk_n                     : in  std_logic;
dclk                         : in  std_logic;
reset                        : in  std_logic;
resetdone_out                : out std_logic;
qplllock_out                 : out std_logic;
coreclk_out                  : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxrecclk_out                 : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

mac_tx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
mac_rx_configuration_vector  : in  std_logic_vector((80 * G_GT_CHANNEL_COUNT) - 1 downto 0);
mac_status_vector            : out std_logic_vector((2 * G_GT_CHANNEL_COUNT) - 1 downto 0);
pcs_pma_configuration_vector : in  std_logic_vector((536 * G_GT_CHANNEL_COUNT) - 1 downto 0);
pcs_pma_status_vector        : out std_logic_vector((448 * G_GT_CHANNEL_COUNT) - 1 downto 0);

tx_ifg_delay => "00000000",

tx_statistics_vector         : out std_logic_vector((26 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_statistics_vector         : out std_logic_vector((30 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_statistics_valid          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_statistics_valid          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

tx_axis_mac_aresetn  => i_tx_axis_mac_aresetn ,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_aresetn => i_tx_axis_fifo_aresetn,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tdata   => i_tx_axis_fifo_tdata  ,-- : in  std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_axis_fifo_tkeep   => i_tx_axis_fifo_tkeep  ,-- : in  std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
tx_axis_fifo_tvalid  => i_tx_axis_fifo_tvalid ,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tlast   => i_tx_axis_fifo_tlast  ,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
tx_axis_fifo_tready  => i_tx_axis_fifo_tready ,-- : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

rx_axis_mac_aresetn  => i_rx_axis_mac_aresetn ,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_aresetn => i_rx_axis_fifo_aresetn,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tdata   => i_rx_axis_fifo_tdata  ,-- : out std_logic_vector((64 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_axis_fifo_tkeep   => i_rx_axis_fifo_tkeep  ,-- : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0);
rx_axis_fifo_tvalid  => i_rx_axis_fifo_tvalid ,-- : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tlast   => i_rx_axis_fifo_tlast  ,-- : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rx_axis_fifo_tready  => i_rx_axis_fifo_tready ,-- : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

pause_val => "0000000000000000",
pause_req => '0',

txp                          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
txn                          : out std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxp                          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
rxn                          : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);

signal_detect                : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
sim_speedup_control          : in  std_logic;
tx_fault                     : in  std_logic_vector(G_GT_CHANNEL_COUNT - 1 downto 0);
pcspma_status               : out std_logic_vector((8 * G_GT_CHANNEL_COUNT) - 1 downto 0)
);


----------------------------------------------------
--DBG
----------------------------------------------------
gen_use_on : if strcmp(G_MODULE_USE, "ON") generate
p_out_tst <= (others => '0');
end generate gen_use_on;

gen_use_off : if strcmp(G_MODULE_USE, "OFF") generate
p_out_tst <= (others => '0');
end generate gen_use_off;

end architecture behavioral;
