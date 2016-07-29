-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 17:33:55
-- Module Name : bram_sim.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_sim is
port(
p_out_dout  : out std_logic_vector((32 * 2) - 1 downto 0)
);
end entity bram_sim;

architecture behavioral of bram_sim is

constant CI_CLK_PERIOD : time := 6.6 ns;--150MHz

component bram_dma_params
port(
addra : in   std_logic_vector(9 downto 0);
dina  : in   std_logic_vector(31 downto 0);
douta : out  std_logic_vector(31 downto 0);
ena   : in   std_logic;
wea   : in   std_logic_vector(0 downto 0);
clka  : in   std_logic;

addrb : in   std_logic_vector(9 downto 0);
dinb  : in   std_logic_vector(31 downto 0);
doutb : out  std_logic_vector(31 downto 0);
enb   : in   std_logic;
web   : in   std_logic_vector(0 downto 0);
clkb  : in   std_logic
);
end component;

signal i_addra : unsigned(9 downto 0);
signal i_dina  : unsigned(31 downto 0);
signal i_douta : std_logic_vector(31 downto 0);
signal i_ena   : std_logic;
signal i_wea   : std_logic_vector(0 downto 0);
signal i_clka  : std_logic;

signal i_addrb : unsigned(9 downto 0);
signal i_dinb  : unsigned(31 downto 0);
signal i_doutb : std_logic_vector(31 downto 0);
signal i_enb   : std_logic;
signal i_web   : std_logic_vector(0 downto 0);
signal i_clkb  : std_logic;

signal i_clk   : std_logic;


begin --architecture behavioral


p_out_dout <= i_doutb & i_douta;

m_bram : bram_dma_params
port map(
addra => std_logic_vector(i_addra),
dina  => std_logic_vector(i_dina) ,
douta => i_douta,
ena   => '1'    ,
wea   => i_wea  ,
clka  => i_clk ,

addrb => std_logic_vector(i_addrb),
dinb  => (others => '0'),--std_logic_vector(i_dinb ),
doutb => i_doutb,
enb   => '1',--i_enb  ,
web   => "0",--i_web  ,
clkb  => i_clk
);

gen_clk : process
begin
  i_clk <='0';
  wait for (CI_CLK_PERIOD / 2);
  i_clk <='1';
  wait for (CI_CLK_PERIOD / 2);
end process;


process
begin
i_addra <= (others => '0');
i_dina  <= (others => '0');
i_wea   <= (others => '0');

i_addrb <= (others => '0');
i_dinb  <= (others => '0');


wait for 1 us;

for i in 0 to 5 loop
wait until rising_edge(i_clk);
i_wea <= "1";
i_dina <= TO_UNSIGNED((i + 1), i_dina'length);
i_addra <= TO_UNSIGNED(i, i_addra'length);
end loop;

wait until rising_edge(i_clk);
i_wea <= "0";


wait for 0.5 us;

for i in 0 to 5 loop
wait until rising_edge(i_clk);
i_addrb <= TO_UNSIGNED(i, i_addrb'length);
end loop;



wait;
end process;


end architecture behavioral;
