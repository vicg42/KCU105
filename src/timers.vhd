-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 08.10.2015 10:32:07
-- Module Name : timers
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.prj_def.all;

entity timers is
generic(
G_TMR_COUNT : natural := 1
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TTmrCtrl;

-------------------------------
--
-------------------------------
p_in_tmr_clk  : in   std_logic;
p_out_tmr_irq : out  std_logic_vector(G_TMR_COUNT - 1 downto 0);
p_out_tmr_en  : out  std_logic_vector(G_TMR_COUNT - 1 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst : in std_logic
);
end entity timers;

architecture behavioral of timers is

constant CI_EXP_VALUE : integer := 7;

signal i_tmr_en         : std_logic_vector(G_TMR_COUNT - 1 downto 0);
signal i_reg_count      : TTmrVal;
signal i_tmr_cnt        : TTmrVal;
signal i_tmr_irq        : std_logic_vector(G_TMR_COUNT - 1 downto 0);
signal i_tmr_irq_exp    : std_logic_vector(G_TMR_COUNT - 1 downto 0);

type TSrIrqTmr  is array (0 to G_TMR_COUNT - 1) of unsigned(0 to CI_EXP_VALUE);
signal sr_tmr_irq       : TSrIrqTmr;


begin --architecture behavioral


gen_tmr : for i in 0 to G_TMR_COUNT - 1 generate
begin

process(p_in_tmr_clk)
begin
if rising_edge(p_in_tmr_clk) then
  if p_in_rst = '1' then
    i_tmr_en(i) <= '0';

    i_tmr_cnt(i) <= (others => '0');
    i_tmr_irq(i) <= '0';

  else

    i_tmr_en(i) <= p_in_reg.en(i);
    i_reg_count(i) <= p_in_reg.data(i);

    if i_tmr_en(i) = '1' then
      if i_tmr_cnt(i) = (i_reg_count(i) - 1) then
        i_tmr_cnt(i) <= (others => '0');
      else
        i_tmr_cnt(i) <= i_tmr_cnt(i) + 1;
      end if;
    else
      i_tmr_cnt(i) <= (others => '0');
    end if;

    if (i_tmr_cnt(i) = (i_reg_count(i) - 1))
        and (i_reg_count(i) /= (i_reg_count(i)'range => '0')) then

      i_tmr_irq(i) <= '1';

    else
      i_tmr_irq(i) <= '0';
    end if;

  end if;
end if;
end process;


--expand IRQ strobe
process(p_in_tmr_clk, p_in_rst)
begin
if p_in_rst = '1' then
  i_tmr_irq_exp(i) <= '0';
  sr_tmr_irq(i) <= (others => '0');

elsif rising_edge(p_in_tmr_clk) then
    if i_tmr_irq(i) = '1' then
      i_tmr_irq_exp(i) <= '1';
    elsif sr_tmr_irq(i)(sr_tmr_irq(i)'high) = '1' then
      i_tmr_irq_exp(i) <= '0';
    end if;

    sr_tmr_irq(i) <= i_tmr_irq(i) & sr_tmr_irq(i)(0 to sr_tmr_irq(i)'high - 1);

end if;
end process;

end generate gen_tmr;


p_out_tmr_irq <= i_tmr_irq_exp;
p_out_tmr_en <= i_tmr_en;

end architecture behavioral;
