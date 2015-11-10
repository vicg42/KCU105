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
use work.eth_phypin_pkg.all;
use work.eth_pkg.all;


entity eth_main is
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

p_out_status_eth : out TEthStatus_OUTs;

-------------------------------
--PHY pin
-------------------------------
p_out_ethphy : out TEthPhyPin_OUT;
p_in_ethphy  : in  TEthPhyPin_IN;

-------------------------------
--DBG
-------------------------------
--p_out_dbg : out TEthDBG;
p_out_sim : out TEthSIM_OUTs;
p_in_sim  : in  TEthSIM_INs;
p_in_tst  : in  std_logic_vector(31 downto 0);
p_out_tst : out std_logic_vector(31 downto 0);

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

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk : in  std_logic;
p_in_rst : in  std_logic
);
end component eth_mac_tx;


component eth_core_fifo_block is
generic(
G_GTCH_COUNT : integer := 1;
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
coreclk_out                  : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rxrecclk_out                 : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);

mac_tx_configuration_vector  : in  std_logic_vector((80 * C_GTCH_COUNT) - 1 downto 0);
mac_rx_configuration_vector  : in  std_logic_vector((80 * C_GTCH_COUNT) - 1 downto 0);
mac_status_vector            : out std_logic_vector((2 * C_GTCH_COUNT) - 1 downto 0);
pcs_pma_configuration_vector : in  std_logic_vector((536 * C_GTCH_COUNT) - 1 downto 0);
pcs_pma_status_vector        : out std_logic_vector((448 * C_GTCH_COUNT) - 1 downto 0);

tx_ifg_delay                 : in  std_logic_vector(7 downto 0);
tx_statistics_vector         : out std_logic_vector((26 * C_GTCH_COUNT) - 1 downto 0);
rx_statistics_vector         : out std_logic_vector((30 * C_GTCH_COUNT) - 1 downto 0);
tx_statistics_valid          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rx_statistics_valid          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
tx_axis_mac_aresetn          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_aresetn         : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tdata           : in  std_logic_vector((G_AXI_DWIDTH * C_GTCH_COUNT) - 1 downto 0);
tx_axis_fifo_tkeep           : in  std_logic_vector(((G_AXI_DWIDTH / 8) * C_GTCH_COUNT) - 1 downto 0);
tx_axis_fifo_tvalid          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tlast           : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tready          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);

rx_axis_mac_aresetn          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_aresetn         : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tdata           : out std_logic_vector((G_AXI_DWIDTH * C_GTCH_COUNT) - 1 downto 0);
rx_axis_fifo_tkeep           : out std_logic_vector(((G_AXI_DWIDTH / 8) * C_GTCH_COUNT) - 1 downto 0);
rx_axis_fifo_tvalid          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tlast           : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tready          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);

pause_val                    : in  std_logic_vector(15 downto 0);
pause_req                    : in  std_logic;

txp                          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
txn                          : out std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rxp                          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
rxn                          : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);

signal_detect                : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
sim_speedup_control          : in  std_logic;
tx_fault                     : in  std_logic_vector(C_GTCH_COUNT - 1 downto 0);
pcspma_status               : out std_logic_vector((8 * C_GTCH_COUNT) - 1 downto 0)
);
end component eth_core_fifo_block;

signal i_reg_adr             : unsigned(p_in_cfg_adr'range);
signal h_reg_ethcfg          : TEthCfg;

signal i_tx_axis_mac_aresetn  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_tx_axis_fifo_aresetn : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tdata   : std_logic_vector((G_AXI_DWIDTH * C_GTCH_COUNT) - 1 downto 0);
signal i_tx_axis_fifo_tkeep   : std_logic_vector(((G_AXI_DWIDTH / 8) * C_GTCH_COUNT) - 1 downto 0);
signal i_tx_axis_fifo_tvalid  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tlast   : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_tx_axis_fifo_tready  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);

signal i_rx_axis_mac_aresetn  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_rx_axis_fifo_aresetn : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tdata   : std_logic_vector((G_AXI_DWIDTH * C_GTCH_COUNT) - 1 downto 0);
signal i_rx_axis_fifo_tkeep   : std_logic_vector(((G_AXI_DWIDTH / 8) * C_GTCH_COUNT) - 1 downto 0);
signal i_rx_axis_fifo_tvalid  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tlast   : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_rx_axis_fifo_tready  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);


signal i_qplllock             : std_logic;
signal i_coreclk_out          : std_logic_vector(C_GTCH_COUNT - 1 downto 0);

signal i_mac_status_vector    : std_logic_vector((2 * C_GTCH_COUNT) - 1 downto 0);
signal i_pcspma_status        : std_logic_vector((8 * C_GTCH_COUNT) - 1 downto 0);
signal i_mac_tx_configuration_vector : std_logic_vector((80 * C_GTCH_COUNT) - 1 downto 0);
signal i_mac_rx_configuration_vector : std_logic_vector((80 * C_GTCH_COUNT) - 1 downto 0);
signal i_pcs_pma_configuration_vector : std_logic_vector((536 * C_GTCH_COUNT) - 1 downto 0);

signal i_signal_detect        : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_tx_fault             : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_sim_speedup_control  : std_logic_vector(C_GTCH_COUNT - 1 downto 0);

signal i_block_lock          : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
signal i_no_remote_and_local_faults : std_logic_vector(C_GTCH_COUNT - 1 downto 0);
--signal i_core_ready          : std_logic_vector(C_GTCH_COUNT - 1 downto 0);


signal i_eth_main_tst_out    : std_logic_vector(31 downto 0);
--signal i_dbg_out             : TEthDBG;




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
  if p_in_rst = '1' then
    for i in 0 to h_reg_ethcfg.mac.dst'high loop
    h_reg_ethcfg.mac.dst(i) <= (others => '0');
    h_reg_ethcfg.mac.src(i) <= (others => '0');
    end loop;

  else
    if p_in_cfg_wr = '1' then
        if i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN0, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(0) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.dst(1) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN1, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(2) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.dst(3) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN2, i_reg_adr'length) then
          h_reg_ethcfg.mac.dst(4) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.dst(5) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN3, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(0) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.src(1) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN4, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(2) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.src(3) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN5, i_reg_adr'length) then
          h_reg_ethcfg.mac.src(4) <= UNSIGNED(p_in_cfg_txdata(7 downto 0));
          h_reg_ethcfg.mac.src(5) <= UNSIGNED(p_in_cfg_txdata(15 downto 8));

        end if;
    end if;
  end if;
end if;
end process;

--read registers
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    p_out_cfg_rxdata <= (others => '0');
  else
    if p_in_cfg_rd = '1' then
        if i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN0, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.dst(0));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.dst(1));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN1, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.dst(2));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.dst(3));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN2, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.dst(4));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.dst(5));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN3, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.src(0));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.src(1));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN4, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.src(2));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.src(3));

        elsif i_reg_adr = TO_UNSIGNED(C_ETH_REG_MAC_PATRN5, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0)  <= std_logic_vector(h_reg_ethcfg.mac.src(4));
          p_out_cfg_rxdata(15 downto 8) <= std_logic_vector(h_reg_ethcfg.mac.src(5));

        end if;
    end if;
  end if;
end if;
end process;



----------------------------------------------------
--
----------------------------------------------------
gen_mac_ch: for i in 0 to (C_GTCH_COUNT - 1) generate
begin

m_mac_tx : eth_mac_tx
generic map(
G_AXI_DWIDTH => G_AXI_DWIDTH,
G_DBG => "OFF"
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => h_reg_ethcfg,

--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_usr_axi_tdata   => p_in_bufeth (i).tx_axi_tdata,
p_out_usr_axi_tready => p_out_bufeth(i).tx_axi_tready,
p_in_usr_axi_tvalid  => p_in_bufeth (i).tx_axi_tvalid,

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_eth_axi_tready  => i_tx_axis_fifo_tready(i),
p_out_eth_axi_tdata  => i_tx_axis_fifo_tdata((G_AXI_DWIDTH * (i + 1)) - 1 downto (G_AXI_DWIDTH * i)),
p_out_eth_axi_tkeep  => i_tx_axis_fifo_tkeep(((G_AXI_DWIDTH / 8) * (i + 1)) - 1 downto ((G_AXI_DWIDTH / 8) * i)),
p_out_eth_axi_tvalid => i_tx_axis_fifo_tvalid(i),
p_out_eth_axi_tlast  => i_tx_axis_fifo_tlast(i),

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out(i),
p_in_rst => p_in_rst
);


m_mac_rx : eth_mac_rx
generic map(
G_AXI_DWIDTH => G_AXI_DWIDTH,
G_DBG => "OFF"
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg => h_reg_ethcfg,

--------------------------------------
--USR RXBUF <- ETH
--------------------------------------
p_in_usr_axi_tready  => p_in_bufeth (i).rx_axi_tready,
p_out_usr_axi_tdata  => p_out_bufeth(i).rx_axi_tdata ,
p_out_usr_axi_tkeep  => p_out_bufeth(i).rx_axi_tkeep ,
p_out_usr_axi_tvalid => p_out_bufeth(i).rx_axi_tvalid,
p_out_usr_axi_tuser  => p_out_bufeth(i).rx_axi_tuser ,

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_eth_axi_tready => i_rx_axis_fifo_tready(i),
p_in_eth_axi_tdata   => i_rx_axis_fifo_tdata((G_AXI_DWIDTH * (i + 1)) - 1 downto (G_AXI_DWIDTH * i)),
p_in_eth_axi_tkeep   => i_rx_axis_fifo_tkeep(((G_AXI_DWIDTH / 8) * (i + 1)) - 1 downto ((G_AXI_DWIDTH / 8) * i)),
p_in_eth_axi_tvalid  => i_rx_axis_fifo_tvalid(i),
p_in_eth_axi_tlast   => i_rx_axis_fifo_tlast(i),

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out(i),
p_in_rst => i_no_remote_and_local_faults(i) --p_in_rst
);


i_signal_detect(i) <= '1';
i_tx_fault(i) <= '0';

--Assign the configuration settings to the configuration vectors
i_mac_rx_configuration_vector((80 * i) + 0) <= '0';
i_mac_rx_configuration_vector((80 * i) + 1) <= '1';
i_mac_rx_configuration_vector((80 * (i + 1)) - 1 downto ((80 * i) + 2)) <= (others => '0');

i_mac_tx_configuration_vector((80 * i) + 0) <= '0';
i_mac_tx_configuration_vector((80 * i) + 1) <= '1';
i_mac_tx_configuration_vector((80 * (i + 1)) - 1 downto ((80 * i) + 2)) <= (others => '0');

i_pcs_pma_configuration_vector((536 * (i + 1)) - 1 downto (536 * i)) <= (others => '0');

i_block_lock(i) <= i_pcspma_status((8 * i) + 0);
i_no_remote_and_local_faults(i) <= (not i_mac_status_vector((2 * i) + 0)) and (not i_mac_status_vector((2 * i) + 1));
--i_core_ready(i) <= i_block_lock(i) and i_no_remote_and_local_faults(i);
p_out_status_eth(i).rdy <= i_block_lock(i) and i_no_remote_and_local_faults(i);
--p_out_status_eth(i).rdy <= i_qplllock;


i_tx_axis_mac_aresetn(i) <= not p_in_rst;
i_tx_axis_fifo_aresetn(i) <= not p_in_rst;

i_rx_axis_mac_aresetn(i) <= not p_in_rst;
i_rx_axis_fifo_aresetn(i) <= not p_in_rst;

end generate gen_mac_ch;


m_eth_phy : eth_core_fifo_block
generic map (
G_GTCH_COUNT => C_GTCH_COUNT,
FIFO_SIZE => 1024
)
port map(
-- Port declarations
refclk_p => p_in_ethphy.fiber.refclk_p,
refclk_n => p_in_ethphy.fiber.refclk_n,
dclk     => p_in_dclk,
reset    => p_in_rst,
resetdone_out => open,
qplllock_out  => i_qplllock,
coreclk_out   => i_coreclk_out ,--  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxrecclk_out  => open,          --  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

mac_tx_configuration_vector => i_mac_tx_configuration_vector,-- : in  std_logic_vector((80 * G_GTCH_COUNT) - 1 downto 0);
mac_rx_configuration_vector => i_mac_rx_configuration_vector,-- : in  std_logic_vector((80 * G_GTCH_COUNT) - 1 downto 0);
mac_status_vector           => i_mac_status_vector          ,-- : out std_logic_vector((2 * G_GTCH_COUNT) - 1 downto 0);
pcs_pma_configuration_vector => i_pcs_pma_configuration_vector,
pcs_pma_status_vector       => open,--: out std_logic_vector((448 * G_GTCH_COUNT) - 1 downto 0);

tx_ifg_delay => "00000000",

tx_statistics_vector => open,--: out std_logic_vector((26 * G_GTCH_COUNT) - 1 downto 0);
rx_statistics_vector => open,--: out std_logic_vector((30 * G_GTCH_COUNT) - 1 downto 0);
tx_statistics_valid  => open,--: out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_statistics_valid  => open,--: out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

tx_axis_mac_aresetn  => i_tx_axis_mac_aresetn ,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_aresetn => i_tx_axis_fifo_aresetn,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tdata   => i_tx_axis_fifo_tdata  ,-- : in  std_logic_vector((64 * G_GTCH_COUNT) - 1 downto 0);
tx_axis_fifo_tkeep   => i_tx_axis_fifo_tkeep  ,-- : in  std_logic_vector((8 * G_GTCH_COUNT) - 1 downto 0);
tx_axis_fifo_tvalid  => i_tx_axis_fifo_tvalid ,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tlast   => i_tx_axis_fifo_tlast  ,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_axis_fifo_tready  => i_tx_axis_fifo_tready ,-- : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

rx_axis_mac_aresetn  => i_rx_axis_mac_aresetn ,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_aresetn => i_rx_axis_fifo_aresetn,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tdata   => i_rx_axis_fifo_tdata  ,-- : out std_logic_vector((64 * G_GTCH_COUNT) - 1 downto 0);
rx_axis_fifo_tkeep   => i_rx_axis_fifo_tkeep  ,-- : out std_logic_vector((8 * G_GTCH_COUNT) - 1 downto 0);
rx_axis_fifo_tvalid  => i_rx_axis_fifo_tvalid ,-- : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tlast   => i_rx_axis_fifo_tlast  ,-- : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rx_axis_fifo_tready  => i_rx_axis_fifo_tready ,-- : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);

pause_val => "0000000000000000",
pause_req => '0',

txp => p_out_ethphy.fiber.txp,
txn => p_out_ethphy.fiber.txp,
rxp => p_in_ethphy.fiber.rxp,
rxn => p_in_ethphy.fiber.rxn,

signal_detect  => i_signal_detect,
sim_speedup_control => p_in_sim(0).sim_speedup_control,
tx_fault       => i_tx_fault,
pcspma_status => i_pcspma_status
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
