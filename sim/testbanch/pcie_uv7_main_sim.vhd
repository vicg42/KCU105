-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 17:33:55
-- Module Name : pcie_uv7_main_sim.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pcie_pkg.all;
use work.prj_def.all;
use work.prj_cfg.all;

entity pcie_uv7_main_sim is
port(
pci_exp_txp  : out std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
pci_exp_txn  : out std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
pci_exp_rxp  : in  std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
pci_exp_rxn  : in  std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);

sys_clk_p    : in  std_logic;
sys_clk_n    : in  std_logic;
sys_rst_n    : in  std_logic
);
end entity pcie_uv7_main_sim;

architecture behavioral of pcie_uv7_main_sim is

component pcie_main is
generic (
G_SIM : string := "OFF";
G_DBGCS : string := "OFF"
);
port(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk           : out   std_logic ;
p_out_gctrl          : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

p_out_dev_ctrl       : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din        : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout        : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr         : out   std_logic;
p_out_dev_rd         : out   std_logic;
p_in_dev_status      : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto C_HREG_DEV_STATUS_FST_BIT);
p_in_dev_irq         : in    std_logic_vector((C_HIRQ_COUNT - 1) downto C_HIRQ_FST_BIT);
p_in_dev_opt         : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto C_HDEV_OPTIN_FST_BIT);
p_out_dev_opt        : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto C_HDEV_OPTOUT_FST_BIT);

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst        : out   std_logic_vector(127 downto 0);
p_in_usr_tst         : in    std_logic_vector(127 downto 0);
p_in_tst             : in    std_logic_vector(31 downto 0);
p_out_tst            : out   std_logic_vector(255 downto 0);

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy        : in    TPCIE_pinin;
p_out_pcie_phy       : out   TPCIE_pinout;
p_out_pcie_rst_n     : out   std_logic
);
end component pcie_main;

signal p_in_pcie_phy     :  TPCIE_pinin;
signal p_out_pcie_phy    :  TPCIE_pinout;


begin --architecture behavioral


p_in_pcie_phy.rxp   <= pci_exp_rxp;
p_in_pcie_phy.rxn   <= pci_exp_rxn;
p_in_pcie_phy.clk_p <= sys_clk_p;
p_in_pcie_phy.clk_n <= sys_clk_n;
p_in_pcie_phy.rst_n <= sys_rst_n;

pci_exp_txp <= p_out_pcie_phy.txp;
pci_exp_txn <= p_out_pcie_phy.txn;


m_main : pcie_main
generic map (
G_SIM => "ON",
G_DBGCS => "OFF"
)
port map(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk  => open,
p_out_gctrl => open,

p_out_dev_ctrl  => open,
p_out_dev_din   => open,
p_in_dev_dout   => (others => '0'),
p_out_dev_wr    => open,
p_out_dev_rd    => open,
p_in_dev_status => (others => '0'),
p_in_dev_irq    => (others => '0'),
p_in_dev_opt    => (others => '0'),
p_out_dev_opt   => open,

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst => open,
p_in_usr_tst  => (others => '0'),
p_in_tst      => (others => '0'),
p_out_tst     => open,

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_pcie_phy  => p_in_pcie_phy ,
p_out_pcie_phy => p_out_pcie_phy,
p_out_pcie_rst_n => open
);



end architecture behavioral;
