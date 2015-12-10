-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_main
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity cl_main is
generic(
G_CLIN_WIDTH : natural := 1
);
port(
--------------------------------------------------
--RS232(PC)
--------------------------------------------------
p_in_rs232_rx  : in  std_logic;
p_out_rs232_tx : out std_logic;

--------------------------------------------------
--CameraLink
--------------------------------------------------
p_in_cl_tfg_n : in  std_logic; --Camera -> FG
p_in_cl_tfg_p : in  std_logic;
p_out_cl_tc_n : out std_logic; --Camera <- FG
p_out_cl_tc_p : out std_logic;

p_in_cl_xclk_p : in  std_logic;
p_in_cl_xclk_n : in  std_logic;
p_in_cl_x_p : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);
p_in_cl_x_n : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cl_main;

architecture struct of cl_main is

component cl_clk_mmcd is
Port (
clk_in1   : in std_logic;
clk_out1  : out std_logic;
clk_out2  : out std_logic;
reset     : in std_logic;
locked    : out std_logic
);
end component cl_clk_mmcd;

component cl_clk_pll is
Port (
clk_in1   : in std_logic;
clk_out1  : out std_logic;
reset     : in std_logic;
locked    : out std_logic
);
end component cl_clk_pll;

component gearbox_4_to_7 is generic (
  D       : integer := 8) ;       -- Set the number of inputs
port (
  input_clock   :  in std_logic ;       -- high speed clock input
  output_clock    :  in std_logic ;       -- low speed clock input
  datain      :  in std_logic_vector(D*4-1 downto 0) ;  -- data inputs
  reset     :  in std_logic ;       -- Reset line
  jog     :  in std_logic ;       -- jog input, slips by 4 bits
  dataout     : out std_logic_vector(D*7-1 downto 0)) ;   -- data outputs
end component ;

signal i_rst               : std_logic;

signal i_cl_xclk_in        : std_logic;
signal g_cl_xclk_in        : std_logic;
signal g_cl_xclk           : std_logic;
signal g_cl_xclk_7x        : std_logic;
signal i_cl_xclk_7x_lock   : std_logic;
signal g_cl_xclk_4x        : std_logic;
signal i_cl_xclk_4x_lock   : std_logic;

signal i_fifo_clkdiv       : unsigned(1 downto 0);
signal i_fifo_rd           : std_logic;

type TSerDesDOUT is array (0 to p_in_cl_x_p'length - 1) of std_logic_vector(7 downto 0);
type TGearBoxDOUT is array (0 to p_in_cl_x_p'length - 1) of std_logic_vector(6 downto 0);
type TDesData is array (0 to p_in_cl_x_p'length - 1) of std_logic_vector(3 downto 0);
signal i_cl_x              : std_logic_vector(p_in_cl_x_p'range);
signal serdes_do           : TSerDesDOUT;
signal i_des_d             : TDesData;
signal i_gearbox_do        : TGearBoxDOUT;


begin --architecture struct


m_ibufds_tfg : IBUFDS
port map (I  => p_in_cl_tfg_p , IB => p_in_cl_tfg_n, O  => p_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I  => p_in_rs232_rx, O  => p_out_cl_tc_p, OB => p_out_cl_tc_n);




m_ibufds_xclk : IBUFDS
port map (I  => p_in_cl_xclk_p , IB => p_in_cl_xclk_n, O  => i_cl_xclk_in);

m_bufg_xclk : BUFG
port map (I  => i_cl_xclk_in , O  => g_cl_xclk_in);

m_xclk_mmcd : cl_clk_mmcd
port map(
clk_in1   => g_cl_xclk_in,
clk_out1  => g_cl_xclk,
clk_out2  => g_cl_xclk_7x,
reset     => p_in_rst,
locked    => i_cl_xclk_7x_lock
);

m_xclk_pll : cl_clk_pll
port map(
clk_in1   => g_cl_xclk_in,
clk_out1  => g_cl_xclk_4x,
reset     => p_in_rst,
locked    => i_cl_xclk_4x_lock
);

i_rst <= (not i_cl_xclk_7x_lock) and (not i_cl_xclk_4x_lock);

--process(i_rst, g_cl_xclk_7x)
--begin
--if (i_rst = '1') then
--  i_fifo_rd <= '0';
--  i_fifo_clkdiv <= (others => '0');
--elsif rising_edge(g_cl_xclk_7x) then
--  i_fifo_clkdiv <= i_fifo_clkdiv + 1;
--  i_fifo_rd <= AND_Reduce(i_fifo_clkdiv);
--end if;
--end process;



gen_deser1_7 : for i in 0 to (p_in_cl_x_p'length - 1) generate
begin

--deser1:4
m_ibufds : IBUFDS
port map (I => p_in_cl_x_p(i), IB => p_in_cl_x_n(i), O => i_cl_x(i));

m_serdes : ISERDESE3
generic map (
DATA_WIDTH => 4,            -- Parallel data width (4,8)
FIFO_ENABLE => "FALSE",      -- Enables the use of the FIFO
FIFO_SYNC_MODE => "FALSE",   -- Enables the use of internal 2-stage synchronizers on the FIFO
IS_CLK_B_INVERTED => '0',   -- Optional inversion for CLK_B
IS_CLK_INVERTED => '0',     -- Optional inversion for CLK
IS_RST_INVERTED => '0',     -- Optional inversion for RST
SIM_DEVICE => "ULTRASCALE"  -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS_ES1)
)
port map (
FIFO_EMPTY => open,         -- 1-bit output: FIFO empty flag
Q => serdes_do(i),          -- 8-bit registered output
CLK => g_cl_xclk_7x,        -- 1-bit input: High-speed clock
CLKDIV => g_cl_xclk_4x,     -- 1-bit input: Divided Clock
CLK_B => '0',               -- 1-bit input: Inversion of High-speed clock CLK
D => i_cl_x(i),             -- 1-bit input: Serial Data Input
FIFO_RD_CLK => '0', -- 1-bit input: FIFO read clock
FIFO_RD_EN => '0',     -- 1-bit input: Enables reading the FIFO when asserted
RST => i_rst
);

i_des_d(i) <= serdes_do(i)(i_des_d(i)'range);

--deser4:7
m_gearbox_4_to_7 : gearbox_4_to_7
generic map(D => 1)
port map(
input_clock  => g_cl_xclk_4x,-- :  in std_logic ;       -- high speed clock input
datain       => i_des_d(i)  ,-- :  in std_logic_vector(D*4-1 downto 0) ;  -- data inputs

output_clock => g_cl_xclk_in,-- :  in std_logic ;       -- low speed clock input
dataout      => i_gearbox_do(i),-- : out std_logic_vector(D*7-1 downto 0);

jog          => '0',-- :  in std_logic ;       -- jog input, slips by 4 bits
reset        => i_rst -- :  in std_logic ;       -- Reset line
);

end generate gen_deser1_7;

p_out_tst(6 downto 0) <= i_gearbox_do(0);


end architecture struct;
