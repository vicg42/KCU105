-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 27.07.2015 16:11:21
-- Module Name : pcie_irq.vhd
--
-- Description : Endpoint Intrrupt Controller
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.prj_def.all;

entity pcie_irq is
port(
-----------------------------
--Usr Ctrl
-----------------------------
p_in_irq_clr         : in   std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_irq_set         : in   std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_out_irq_status     : out  std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);

-----------------------------
--PCIE Port
-----------------------------
p_in_cfg_msi         : in   std_logic;
p_in_cfg_irq_rdy     : in   std_logic;
p_out_cfg_irq        : out  std_logic;
p_out_cfg_irq_assert : out  std_logic;

-------------------------------
----DBG
-------------------------------
--p_in_tst             : in   std_logic_vector(31 downto 0);
--p_out_tst            : out  std_logic_vector(31 downto 0);

-----------------------------
--SYSTEM
-----------------------------
p_in_clk             : in   std_logic;
p_in_rst_n           : in   std_logic
);
end entity pcie_irq;

architecture behavioral of pcie_irq is

component pcie_irq_dev
port(
-----------------------------
--Usr Ctrl
-----------------------------
p_in_irq_set         : in   std_logic;
p_in_irq_clr         : in   std_logic;
p_out_irq_status     : out  std_logic;

-----------------------------
--PCIE Port
-----------------------------
p_in_cfg_msi         : in   std_logic;
p_in_cfg_irq_rdy     : in   std_logic;
p_out_cfg_irq        : out  std_logic;
p_out_cfg_irq_assert : out  std_logic;

-------------------------------
----DBG
-------------------------------
--p_in_tst             : in  std_logic_vector(31 downto 0);
--p_out_tst            : out std_logic_vector(31 downto 0);

-----------------------------
--SYSTEM
-----------------------------
p_in_clk             : in   std_logic;
p_in_rst_n           : in   std_logic
);
end component;


signal i_cfg_irq         : std_logic_vector(C_HIRQ_COUNT - 1 downto 0);
signal i_cfg_irq_assert  : std_logic_vector(C_HIRQ_COUNT - 1 downto 0);


begin --architecture behavioral


--bit(0) - PCI_EXPRESS_LEGACY_INTA
--bit(1) - PCI_EXPRESS_LEGACY_INTB
--bit(2) - PCI_EXPRESS_LEGACY_INTC
--bit(3) - PCI_EXPRESS_LEGACY_INTD
p_out_cfg_irq <= OR_reduce(i_cfg_irq(C_HIRQ_COUNT - 1 downto C_HIRQ_PCIE_DMA));

p_out_cfg_irq_assert <= OR_reduce(i_cfg_irq_assert(C_HIRQ_COUNT - 1 downto C_HIRQ_PCIE_DMA));

gen_ch: for ch in C_HIRQ_PCIE_DMA to C_HIRQ_COUNT - 1 generate

m_irq_dev : pcie_irq_dev
port map(
--USER Ctrl
p_in_irq_set         => p_in_irq_set(ch),
p_in_irq_clr         => p_in_irq_clr(ch),
p_out_irq_status     => p_out_irq_status(ch),

--PCIE Port
p_in_cfg_msi         => p_in_cfg_msi,
p_in_cfg_irq_rdy     => p_in_cfg_irq_rdy,
p_out_cfg_irq        => i_cfg_irq(ch),
p_out_cfg_irq_assert => i_cfg_irq_assert(ch),

----DBG
--p_in_tst  => (others => '0'),
--p_out_tst => open,--i_tst_out(ch),

--SYSTEM
p_in_clk             => p_in_clk,
p_in_rst_n           => p_in_rst_n
);

end generate gen_ch;


--###############################
--DBG
--###############################
--p_out_tst <= (others => '0');

end architecture behavioral;

