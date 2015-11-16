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
p_in_sim_speedup_control : in  std_logic;
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

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk : in  std_logic;
p_in_rst : in  std_logic
);
end component eth_mac_tx;


component eth_app is
generic (
G_AXI_DWIDTH : integer := 64;
G_GTCH_COUNT : integer := 1
);
port(
--Clock inputs
clk_in    : in  std_logic;       --Freerunning clock source

refclk_p  : in  std_logic;       --Transceiver reference clock source
refclk_n  : in  std_logic;
coreclk_out : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);

--Example design control inputs
reset                : in  std_logic;

sim_speedup_control  : in  std_logic;

--Example design status outputs
frame_error     : out  std_logic;

txuserrdy_out   : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
core_ready      : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
qplllock_out    : out  std_logic;

signal_detect   : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
tx_fault        : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);

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

--Serial I/O from/to transceiver
txp  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
txn  : out std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxp  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0);
rxn  : in  std_logic_vector(G_GTCH_COUNT - 1 downto 0)
);
end component eth_app;


signal i_reg_adr         : unsigned(p_in_cfg_adr'range);
signal h_reg_ethcfg      : TEthCfg;

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

signal i_coreclk_out     : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

signal i_txuserrdy_out   : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

--signal i_dbg_out         : TEthDBG;




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
--    for i in 0 to h_reg_ethcfg.mac.dst'high loop
--    h_reg_ethcfg.mac.dst(i) <= (others => '0');
--    h_reg_ethcfg.mac.src(i) <= (others => '0');
--    end loop;

    h_reg_ethcfg.mac.dst(0) <= std_logic_vector(TO_UNSIGNED(16#B1#, 8));
    h_reg_ethcfg.mac.dst(1) <= std_logic_vector(TO_UNSIGNED(16#B2#, 8));
    h_reg_ethcfg.mac.dst(2) <= std_logic_vector(TO_UNSIGNED(16#B3#, 8));
    h_reg_ethcfg.mac.dst(3) <= std_logic_vector(TO_UNSIGNED(16#B4#, 8));
    h_reg_ethcfg.mac.dst(4) <= std_logic_vector(TO_UNSIGNED(16#B5#, 8));
    h_reg_ethcfg.mac.dst(5) <= std_logic_vector(TO_UNSIGNED(16#B6#, 8));

    h_reg_ethcfg.mac.src(0) <= std_logic_vector(TO_UNSIGNED(16#A1#, 8));
    h_reg_ethcfg.mac.src(1) <= std_logic_vector(TO_UNSIGNED(16#A2#, 8));
    h_reg_ethcfg.mac.src(2) <= std_logic_vector(TO_UNSIGNED(16#A3#, 8));
    h_reg_ethcfg.mac.src(3) <= std_logic_vector(TO_UNSIGNED(16#A4#, 8));
    h_reg_ethcfg.mac.src(4) <= std_logic_vector(TO_UNSIGNED(16#A5#, 8));
    h_reg_ethcfg.mac.src(5) <= std_logic_vector(TO_UNSIGNED(16#A6#, 8));

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
  if p_in_rst = '1' then
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
gen_mac_ch: for i in 0 to (G_ETH_CH_COUNT - 1) generate
begin

m_mac_tx : eth_mac_tx
generic map(
G_AXI_DWIDTH => G_ETH_DWIDTH,
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
p_out_tst => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out(i),
p_in_rst => i_txuserrdy_out(i) --p_in_rst
);


m_mac_rx : eth_mac_rx
generic map(
G_AXI_DWIDTH => G_ETH_DWIDTH,
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
p_out_tst => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk => i_coreclk_out(i),
p_in_rst => i_txuserrdy_out(i) --p_in_rst
);

p_out_buf_clk(i) <= i_coreclk_out(i);
p_out_buf_rst(i) <= not i_txuserrdy_out(i);

end generate gen_mac_ch;


m_eth_app : eth_app
generic map(
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

txuserrdy_out => i_txuserrdy_out,
core_ready  => p_out_status_rdy,
qplllock_out => p_out_status_qplllock,

signal_detect => p_in_sfp_signal_detect,
tx_fault      => p_in_sfp_tx_fault,

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
