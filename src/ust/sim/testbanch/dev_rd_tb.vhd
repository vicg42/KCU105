-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 11.04.2016 10:31:57
-- Module Name : rx_if
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.ust_def.all;

entity dev_rd_tb is
generic(
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_OBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
p_out_obuf_axi_tdata  : out std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
p_out_obuf_axi_tvalid : out std_logic; --empty
p_out_obuf_axi_tlast  : out std_logic --EOF
);
end entity dev_rd_tb;

architecture behavioral of dev_rd_tb is

constant CI_CLK_PERIOD : TIME := 6.6 ns; --150MHz

component dev_rd is
generic(
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_OBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQRD
--------------------------------------------------
p_in_rqrd_di     : in   std_logic_vector(7 downto 0);
p_in_rqrd_wr     : in   std_logic;
p_out_rqrd_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdrdy : in   std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);
p_in_dev_d     : in   std_logic_vector(7 downto 0);
p_out_dev_rd   : out  std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);

--------------------------------------------------
--EthTx
--------------------------------------------------
p_in_obuf_axi_tready  : in  std_logic; --read
p_out_obuf_axi_tdata  : out std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
p_out_obuf_axi_tvalid : out std_logic; --empty
p_out_obuf_axi_tlast  : out std_logic; --EOF

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component dev_rd;


signal i_rst     : std_logic;
signal i_rst_n   : std_logic;
signal i_clk     : std_logic;

signal i_dev_rdrdy : std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);
signal i_dev_d     : std_logic_vector(7 downto 0);
signal i_dev_rd    : std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);

signal i_rqrd_di    : unsigned(7 downto 0);
signal i_rqrd_wr    : std_logic;
signal i_rqrd_rdy_n : std_logic;

signal i_axi_tready : std_logic; --read
signal i_axi_tdata  : std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
signal i_axi_tvalid : std_logic; --empty
signal i_axi_tlast  : std_logic; --EOF


begin --architecture behavioral


m_dev_rd : dev_rd
generic map(
G_TDEV_COUNT_MAX => G_TDEV_COUNT_MAX,
G_NDEV_COUNT_MAX => G_NDEV_COUNT_MAX,
G_OBUF_DWIDTH => G_OBUF_DWIDTH,
G_SIM => "OFF"
)
port map(
--------------------------------------------------
--RQRD
--------------------------------------------------
p_in_rqrd_di     => std_logic_vector(i_rqrd_di)   ,
p_in_rqrd_wr     => i_rqrd_wr   ,
p_out_rqrd_rdy_n => i_rqrd_rdy_n,

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdrdy => i_dev_rdrdy,
p_in_dev_d     => i_dev_d    ,
p_out_dev_rd   => i_dev_rd   ,

--------------------------------------------------
--EthTx
--------------------------------------------------
p_in_obuf_axi_tready  => '1',
p_out_obuf_axi_tdata  => p_out_obuf_axi_tdata ,
p_out_obuf_axi_tvalid => p_out_obuf_axi_tvalid,
p_out_obuf_axi_tlast  => p_out_obuf_axi_tlast ,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst => (others => '0'),

p_in_clk => i_clk,
p_in_rst => i_rst
);


i_dev_rdrdy <= (others => '1');
i_dev_d <= (others => '0');

gen_clk0 : process
begin
i_clk <= '0';
wait for (CI_CLK_PERIOD / 2);
i_clk <= '1';
wait for (CI_CLK_PERIOD / 2);
end process;

i_rst <= '1', '0' after 2 us;
i_rst_n <= not i_rst;


process
variable len : unsigned(15 downto 0);
variable id : unsigned(15 downto 0);
begin
i_rqrd_di <= (others => '0');
i_rqrd_wr <= '0';

len := (others => '0');
id  := (others => '0');

wait for 3 us;

wait until rising_edge(i_clk);
len := TO_UNSIGNED(16, len'length);
id(3 downto 0) := TO_UNSIGNED(C_UDEV_REG, 4); --type
id(7 downto 4) := TO_UNSIGNED(0         , 4); --num
i_rqrd_di <= len(7  downto 0);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= len(15 downto 8);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= id(7  downto 0);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= id(15 downto 8);
i_rqrd_wr <= '1';



wait until rising_edge(i_clk);
len := TO_UNSIGNED(8, len'length);
id(3 downto 0) := TO_UNSIGNED(C_UDEV_GPS, 4); --type
id(7 downto 4) := TO_UNSIGNED(1         , 4); --num
i_rqrd_di <= len(7  downto 0);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= len(15 downto 8);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= id(7  downto 0);
i_rqrd_wr <= '1';
wait until rising_edge(i_clk);
i_rqrd_di <= id(15 downto 8);
i_rqrd_wr <= '1';


wait until rising_edge(i_clk);
i_rqrd_wr <= '0';
wait;
end process;




end architecture behavioral;
