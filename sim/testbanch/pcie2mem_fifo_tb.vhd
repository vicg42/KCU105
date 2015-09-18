-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 17.09.2015 17:54:33
-- Module Name : pcie2mem_fifo_tb.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcie2mem_fifo_tb is
generic(
G_MEM_DWIDTH : integer := 64
);
port(
p_out_dout  : out std_logic_vector(G_MEM_DWIDTH - 1 downto 0) := (others => '0')
);
end entity pcie2mem_fifo_tb;

architecture behavioral of pcie2mem_fifo_tb is

constant CI_WRCLK_PERIOD : time := 3.2 ns;
constant CI_RDCLK_PERIOD : time := 6.6 ns;

constant CI_TEST_DCOUNT  : integer := 40;


component pcie2mem_fifo
port(
din         : in std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
wr_en       : in std_logic;
wr_clk      : in std_logic;
--wr_data_count    : out std_logic_vector(3 downto 0);

dout        : out std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
rd_en       : in std_logic;
rd_clk      : in std_logic;
--rd_data_count    : out std_logic_vector(3 downto 0);

empty       : out std_logic;
full        : out std_logic;
prog_full   : out std_logic;

--clk         : in std_logic;
rst         : in std_logic
);
end component;


signal i_rst   : std_logic := '0';
signal i_clk   : std_logic := '0';

signal i_fifo_di_wrclk_div  : std_logic := '0';
signal i_fifo_di            : unsigned(G_MEM_DWIDTH - 1 downto 0) := (others => '0');
signal i_fifo_di_wr         : std_logic := '0';
signal i_fifo_di_wrclk      : std_logic := '0';
signal i_fifo_wr_cnt        : unsigned(15 downto 0) := (others => '0');
signal i_fifo_wr_stop       : std_logic := '0';
signal i_fifo_di_o          : unsigned(G_MEM_DWIDTH - 1 downto 0) := (others => '0');
signal i_fifo_di_wr_o       : std_logic := '0';

signal i_fifo_do_rdclk_div  : std_logic := '0';
signal i_fifo_do            : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_fifo_do_rd         : std_logic := '0';
signal i_fifo_do_rdclk      : std_logic := '0';
signal i_fifo_rd_en         : std_logic := '0';
signal i_fifo_rd_cnt        : unsigned(15 downto 0) := (others => '0');
signal i_fifo_rd_stop       : std_logic := '0';

signal i_fifo_empty         : std_logic := '1';
signal i_fifo_full          : std_logic := '0';
signal i_fifo_pfull         : std_logic := '0';

signal i_wr_en              : std_logic := '0';
signal sr_wr_en             : std_logic := '0';


begin --architecture behavioral


gen_wrclk : process
begin
  i_fifo_di_wrclk <='0';
  wait for (CI_WRCLK_PERIOD / 2);
  i_fifo_di_wrclk <='1';
  wait for (CI_WRCLK_PERIOD / 2);
end process;

gen_rdclk : process
begin
  i_fifo_do_rdclk <='0';
  wait for (CI_RDCLK_PERIOD / 2);
  i_fifo_do_rdclk <='1';
  wait for (CI_RDCLK_PERIOD / 2);
end process;

i_rst <= '1', '0' after 1 us;


fifo : pcie2mem_fifo
port map(
din       => std_logic_vector(i_fifo_di_o),
wr_en     => i_fifo_di_wr_o,
wr_clk    => i_fifo_di_wrclk,
--wr_data_count => open,

dout      => i_fifo_do,
rd_en     => i_fifo_do_rd,
rd_clk    => i_fifo_do_rdclk,
--rd_data_count => open,

empty     => i_fifo_empty,
full      => i_fifo_full,
prog_full => i_fifo_pfull,

--clk       : in std_logic;
rst       => i_rst
);

process(i_fifo_do_rdclk)
begin
if rising_edge(i_fifo_do_rdclk) then
  if i_fifo_do_rd = '1' then
    p_out_dout <= i_fifo_do;
  end if;
end if;
end process;

i_wr_en <= '0','1' after 2 us;

i_fifo_di_wr <= i_fifo_di_wrclk_div and sr_wr_en and (not i_fifo_pfull) and (not i_fifo_wr_stop);

process(i_fifo_di_wrclk)
begin
if rising_edge(i_fifo_di_wrclk) then
  i_fifo_di_wrclk_div <= not i_fifo_di_wrclk_div;

  if i_fifo_di_wrclk_div = '1' then
    sr_wr_en <= i_wr_en;
    if sr_wr_en = '1' and i_fifo_pfull = '0' and i_fifo_wr_stop = '0' then
    i_fifo_di <= i_fifo_di + 1;
    end if;
  end if;

  if i_fifo_di_wr_o = '1' then
    if (i_fifo_wr_cnt = CI_TEST_DCOUNT) then
      i_fifo_wr_stop <= '1';
    else
      i_fifo_wr_cnt <= i_fifo_wr_cnt + 1;
    end if;
  end if;

  i_fifo_di_o <= i_fifo_di;
  i_fifo_di_wr_o <= i_fifo_di_wr;

end if;
end process;


i_fifo_do_rd <= i_fifo_do_rdclk_div and (not i_fifo_empty) and (not i_fifo_rd_stop);

process(i_fifo_do_rdclk)
begin
if rising_edge(i_fifo_do_rdclk) then
  i_fifo_do_rdclk_div <= not i_fifo_do_rdclk_div;

  if i_fifo_do_rd = '1' then
    if (i_fifo_rd_cnt = CI_TEST_DCOUNT) then
      i_fifo_rd_stop <= '1';
    else
      i_fifo_rd_cnt <= i_fifo_rd_cnt + 1;
    end if;
  end if;
end if;
end process;


end architecture behavioral;
