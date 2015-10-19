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
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in   std_logic;

p_in_cfg_adr     : in   std_logic_vector(1 downto 0);
p_in_cfg_adr_ld  : in   std_logic;

p_in_cfg_txdata  : in   std_logic_vector(15 downto 0);
p_in_cfg_wr      : in   std_logic;

p_out_cfg_rxdata : out  std_logic_vector(15 downto 0);
p_in_cfg_rd      : in   std_logic;

-------------------------------
--
-------------------------------
p_in_tmr_clk     : in   std_logic;
p_out_tmr_irq    : out  std_logic_vector(C_TMR_COUNT - 1 downto 0);
p_out_tmr_en     : out  std_logic_vector(C_TMR_COUNT - 1 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst         : in   std_logic
);
end entity timers;

architecture behavioral of timers is

signal i_reg_adr        : unsigned(p_in_cfg_adr'range);

signal h_reg_tmr_num    : unsigned((C_TMR_REG_CTRL_NUM_M_BIT - C_TMR_REG_CTRL_NUM_L_BIT) downto 0);
signal h_tmr_en         : std_logic_vector(C_TMR_COUNT - 1 downto 0);
signal sr_tmr_en        : std_logic_vector(C_TMR_COUNT - 1 downto 0);

type TValCmp  is array (0 to C_TMR_COUNT - 1) of unsigned (31 downto 0);
signal h_reg_count      : TValCmp;
signal i_tmr_cnt        : TValCmp;
signal i_tmr_irq        : std_logic_vector(C_TMR_COUNT - 1 downto 0);
signal i_tmr_irq_width  : std_logic_vector(C_TMR_COUNT - 1 downto 0);

type TSrIrqTmr  is array (0 to C_TMR_COUNT - 1) of unsigned(3 downto 0);
signal sr_tmr_irq       : TSrIrqTmr;

--signal i_tmr_irq_out    : std_logic_vector(C_TMR_COUNT - 1 downto 0);


begin --architecture behavioral

----------------------------------------------------
--Configuration
----------------------------------------------------
--addres of register
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
    h_reg_tmr_num <= (others => '0');
    h_tmr_en <= (others => '0');

    for i in 0 to C_TMR_COUNT - 1 loop
      h_reg_count(i) <= (others => '0');
    end loop;

  else
    if p_in_cfg_wr = '1' then
      if i_reg_adr = TO_UNSIGNED(C_TMR_REG_CTRL, i_reg_adr'length) then

        h_reg_tmr_num <= UNSIGNED(p_in_cfg_txdata(C_TMR_REG_CTRL_NUM_M_BIT downto C_TMR_REG_CTRL_NUM_L_BIT));

        for i in 0 to C_TMR_COUNT - 1 loop
          if UNSIGNED(p_in_cfg_txdata(C_TMR_REG_CTRL_NUM_M_BIT downto C_TMR_REG_CTRL_NUM_L_BIT)) = i then
            if p_in_cfg_txdata(C_TMR_REG_CTRL_EN_BIT) = '1' then
              h_tmr_en(i) <= '1';
            else --elsif p_in_cfg_txdata(C_TMR_REG_CTRL_DIS_BIT) = '1' then
              h_tmr_en(i) <= '0';
            end if;
          end if;
        end loop;

      elsif i_reg_adr = TO_UNSIGNED(C_TMR_REG_CMP_L, i_reg_adr'length) then
        for i in 0 to C_TMR_COUNT - 1 loop
          if h_reg_tmr_num = i then
            h_reg_count(i)(15 downto 0) <= UNSIGNED(p_in_cfg_txdata);
          end if;
        end loop;

      elsif i_reg_adr = TO_UNSIGNED(C_TMR_REG_CMP_M, i_reg_adr'length) then
        for i in 0 to C_TMR_COUNT - 1 loop
          if h_reg_tmr_num = i then
            h_reg_count(i)(31 downto 16) <= UNSIGNED(p_in_cfg_txdata);
          end if;
        end loop;

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
    p_out_cfg_rxdata <= (others=>'0');
  else
    if p_in_cfg_rd = '1' then
      if i_reg_adr = TO_UNSIGNED(C_TMR_REG_CTRL, i_reg_adr'length) then
          p_out_cfg_rxdata(h_tmr_en'high downto 0) <= h_tmr_en;
          p_out_cfg_rxdata(15 downto h_tmr_en'high + 1) <= (others=>'0');

      elsif i_reg_adr = TO_UNSIGNED(C_TMR_REG_CMP_L, i_reg_adr'length) then
        for i in 0 to C_TMR_COUNT - 1 loop
          if h_reg_tmr_num = i then
            p_out_cfg_rxdata <= std_logic_vector(h_reg_count(i)(15 downto 0));
          end if;
        end loop;

      elsif i_reg_adr = TO_UNSIGNED(C_TMR_REG_CMP_M, i_reg_adr'length) then
        for i in 0 to C_TMR_COUNT - 1 loop
          if h_reg_tmr_num = i then
            p_out_cfg_rxdata <= std_logic_vector(h_reg_count(i)(31 downto 16));
          end if;
        end loop;

      end if;
    end if;
  end if;
end if;
end process;


----------------------------------------------------
--TMR
----------------------------------------------------
gen_tmr : for i in 0 to C_TMR_COUNT - 1 generate
begin

process(p_in_tmr_clk)
begin
if rising_edge(p_in_tmr_clk) then
  if p_in_rst = '1' then
    sr_tmr_en(i) <= '0';

    i_tmr_cnt(i) <= (others => '0');
    i_tmr_irq(i) <= '0';

  else

    sr_tmr_en(i) <= h_tmr_en(i);

    if sr_tmr_en(i) = '1' then
      if i_tmr_cnt(i) = h_reg_count(i) then
        i_tmr_cnt(i) <= (others => '0');
      else
        i_tmr_cnt(i) <= i_tmr_cnt(i) + 1;
      end if;
    else
      i_tmr_cnt(i) <= (others => '0');
    end if;

    if (i_tmr_cnt(i) = h_reg_count(i))
        and (h_reg_count(i) /= (h_reg_count(i)'range => '0')) then

      i_tmr_irq(i) <= '1';

    else

      i_tmr_irq(i) <= '0';

    end if;

  end if;
end if;
end process;


--expand IRQ strobe
process(p_in_tmr_clk)
begin
if rising_edge(p_in_tmr_clk) then
  if p_in_rst = '1' then
    i_tmr_irq_width(i) <= '0';
    sr_tmr_irq(i) <= (others => '0');
  else

    if i_tmr_irq(i) = '1' then
      i_tmr_irq_width(i) <= '1';
    elsif sr_tmr_irq(i)(sr_tmr_irq(i)'high) = '1' then
      i_tmr_irq_width(i) <= '0';
    end if;

    sr_tmr_irq(i) <= i_tmr_irq(i) & sr_tmr_irq(i)(0 to sr_tmr_irq'high - 1);

  end if;
end if;
end process;

----oversample IRQ strobe
--process(p_in_cfg_clk)
--begin
--if rising_edge(p_in_cfg_clk) then
--  i_tmr_irq_out(i) <= i_tmr_irq_width(i);
--end if;
--end process;

end generate gen_tmr;

p_out_tmr_irq <= i_tmr_irq_width;--i_tmr_irq_out;
p_out_tmr_en <= h_tmr_en;


end architecture behavioral;
