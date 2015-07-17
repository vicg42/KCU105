-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 17:27:04
-- Module Name : clocks
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.clocks_pkg.all;
use work.vicg_common_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity clocks is
port(
p_out_rst  : out   std_logic;
p_out_gclk : out   std_logic_vector(7 downto 0);

p_in_clkopt: in    std_logic_vector(3 downto 0);
p_in_clk   : in    TRefClkPinIN
);
end entity clocks;

architecture synth of clocks is

signal g_clk         : std_logic_vector(2 downto 0);
signal i_pll_rst_cnt : unsigned(4 downto 0) := "11111";
signal i_pll_rst     : std_logic := '1';


begin --architecture synth


process(g_clk(0))
begin
  if rising_edge(g_clk(0)) then
    if i_pll_rst_cnt = (i_pll_rst_cnt'range => '0') then
      i_pll_rst <= '0';
    else
      i_pll_rst <= '1';
      i_pll_rst_cnt <= i_pll_rst_cnt - 1;
    end if;
  end if;
end process;

p_out_rst <= i_pll_rst;

--m_bufg_90M  : IBUFG   port map(I => p_in_clk.M90, O  => g_clk(2));
--m_bufg_300M : IBUFGDS port map(I => p_in_clk.M300_p, IB => p_in_clk.M300_n, O  => g_clk(1));
m_bufg_125M : IBUFGDS port map(I => p_in_clk.M125_p, IB => p_in_clk.M125_n, O  => g_clk(0));

p_out_gclk(2 downto 0) <= g_clk(2 downto 0);


end architecture synth;
