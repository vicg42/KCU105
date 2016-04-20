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

entity rx_if_tb is
generic(
G_IBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
p_out_rqwr_di   : out  std_logic_vector(7 downto 0);
p_out_rqwr_adr  : out  std_logic_vector(7 downto 0);
p_out_rqwr_wr   : out  std_logic;

p_out_rqrd_di   : out  std_logic_vector(7 downto 0);
p_out_rqrd_wr   : out  std_logic
);
end entity rx_if_tb;

architecture behavioral of rx_if_tb is

constant CI_CLK_PERIOD : TIME := 6.6 ns; --150MHz

component rx_if is
generic(
G_IBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--INPUT
--------------------------------------------------
p_out_ibuf_axi_tready : out  std_logic; --read
p_in_ibuf_axi_tdata   : in   std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
p_in_ibuf_axi_tvalid  : in   std_logic; --empty
p_in_ibuf_axi_tlast   : in   std_logic; --EOF
--p_in_ibuf_axi_tuser   : in   std_logic_vector(0 downto 0); --SOF

--------------------------------------------------
--DEV
--------------------------------------------------
--request write to dev
p_out_rqwr_di   : out  std_logic_vector(7 downto 0);
p_out_rqwr_adr  : out  std_logic_vector(7 downto 0);
p_out_rqwr_wr   : out  std_logic;
p_in_rqwr_rdy_n : in   std_logic;

--request read from dev
p_out_rqrd_di   : out  std_logic_vector(7 downto 0);
p_out_rqrd_wr   : out  std_logic;
p_in_rqrd_rdy_n : in   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_out_err : out std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component rx_if;

--component fifo_ust_ibufrx
--port (
--din       : in  std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
--wr_en     : in  std_logic;
----wr_clk    : in  std_logic;
--
--dout      : out std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
--rd_en     : in  std_logic;
----rd_clk    : in  std_logic;
--
--empty     : out std_logic;
--full      : out std_logic;
----prog_full : out std_logic;
--
--clk       : in  std_logic;
--rst       : in  std_logic
--);
--end component fifo_ust_ibufrx;

component fifo_ust_ibufrx
port (
S_AXIS_TDATA  : in  std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
S_AXIS_TVALID : in  std_logic; --write
S_AXIS_TLAST  : in  std_logic;
S_AXIS_TUSER  : in  std_logic_vector(0 downto 0);
S_AXIS_TREADY : out std_logic; --full

M_AXIS_TDATA  : out std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
M_AXIS_TVALID : out std_logic; --empty
M_AXIS_TLAST  : out std_logic;
M_AXIS_TUSER  : out std_logic_vector(0 downto 0);
M_AXIS_TREADY : in  std_logic; --read

S_ACLK    : in std_logic;
S_ARESETN : in std_logic
);
end component;

signal i_rst     : std_logic;
signal i_rst_n   : std_logic;
signal i_clk     : std_logic;

signal i_bufi_di     : unsigned(G_IBUF_DWIDTH - 1 downto 0);
signal i_bufi_wr     : std_logic;
signal i_bufi_wr_last: std_logic;
signal i_bufi_full   : std_logic;
signal i_bufi_do     : std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
signal i_bufi_rd     : std_logic;
signal i_bufi_rd_last: std_logic;
signal i_bufi_empty  : std_logic;



begin --architecture behavioral

--m_ibuf : fifo_ust_ibufrx
--port map(
--din       => i_bufi_di,
--wr_en     => i_bufi_wr,
----wr_clk    : in  std_logic;
--
--dout      => i_bufi_do,
--rd_en     => i_bufi_rd,
----rd_clk    : in  std_logic;
--
--empty     => i_bufi_empty,
--full      => open,
----prog_full : out std_logic;
--
--clk       => i_clk,
--rst       => i_rst
--);

m_ibuf : fifo_ust_ibufrx
port map(
S_AXIS_TDATA  => std_logic_vector(i_bufi_di),--: in  std_logic_vector(63 downto 0);
S_AXIS_TVALID => i_bufi_wr,--: in  std_logic; --write
S_AXIS_TLAST  => i_bufi_wr_last,--: in  std_logic;
S_AXIS_TUSER  => (others => '0'),--: in  std_logic_vector(0 downto 0);
S_AXIS_TREADY => i_bufi_full,--: out std_logic; --full

M_AXIS_TDATA  => i_bufi_do,--: out std_logic_vector(63 downto 0);
M_AXIS_TVALID => i_bufi_empty,--: out std_logic; --empty
M_AXIS_TLAST  => i_bufi_rd_last,--: out std_logic;
M_AXIS_TUSER  => open,--: out std_logic_vector(0 downto 0);
M_AXIS_TREADY => i_bufi_rd,--: in  std_logic; --read

S_ACLK    => i_clk,
S_ARESETN => i_rst_n
);


m_rx : rx_if
generic map(
G_IBUF_DWIDTH => G_IBUF_DWIDTH,
G_SIM => G_SIM
)
port map(
--------------------------------------------------
--INPUT
--------------------------------------------------
--p_in_ibuf_empty => i_ibuf_empty,
--p_in_ibuf_do    => i_ibuf_do,
--p_out_ibuf_rd   => i_ibuf_rd,
p_out_ibuf_axi_tready => i_bufi_rd,--: out  std_logic; --read
p_in_ibuf_axi_tdata   => i_bufi_do, --: in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_ibuf_axi_tvalid  => i_bufi_empty,--: in   std_logic; --empty
p_in_ibuf_axi_tlast   => i_bufi_rd_last,--: in   std_logic; --EOF
--p_in_ibuf_axi_tuser   : in   std_logic_vector(0 downto 0); --SOF

--------------------------------------------------
--DEV
--------------------------------------------------
--request write to dev
p_out_rqwr_di   => p_out_rqwr_di ,
p_out_rqwr_adr  => p_out_rqwr_adr,
p_out_rqwr_wr   => p_out_rqwr_wr ,
p_in_rqwr_rdy_n => '0',

--request read from dev
p_out_rqrd_di   => p_out_rqrd_di,
p_out_rqrd_wr   => p_out_rqrd_wr,
p_in_rqrd_rdy_n => '0',

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0'),

p_out_err => open,
p_in_clk => i_clk,
p_in_rst => i_rst
);



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
begin
i_bufi_di <= (others => '0');
i_bufi_wr <= '0';
i_bufi_wr_last <= '0';

wait for 3 us;

wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED(2 + (2 + (2 + 8)) + (2 + (2 + 11))   , 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_PKT_TYPE_H2D, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED((2 + 8)       , 16); --2
i_bufi_di(63 downto 48) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
--i_bufi_di(63 downto 57) <= TO_UNSIGNED(, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(7 downto   0) <= TO_UNSIGNED(1, 8); --8byte
i_bufi_di(15 downto  8) <= TO_UNSIGNED(2, 8);
i_bufi_di(23 downto 16) <= TO_UNSIGNED(3, 8);
i_bufi_di(31 downto 24) <= TO_UNSIGNED(4, 8);
i_bufi_di(39 downto 32) <= TO_UNSIGNED(5, 8);
i_bufi_di(47 downto 40) <= TO_UNSIGNED(6, 8);
i_bufi_di(55 downto 48) <= TO_UNSIGNED(7, 8);
i_bufi_di(63 downto 56) <= TO_UNSIGNED(8, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(15 downto  0) <= TO_UNSIGNED((2 + 11), 16);
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_UDEV_GPS, 16);
i_bufi_di(39 downto 32) <= TO_UNSIGNED(32, 8); --12Byte
i_bufi_di(47 downto 40) <= TO_UNSIGNED(33, 8);
i_bufi_di(55 downto 48) <= TO_UNSIGNED(34, 8);
i_bufi_di(63 downto 56) <= TO_UNSIGNED(35, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(7 downto   0) <= TO_UNSIGNED(36, 8);
i_bufi_di(15 downto  8) <= TO_UNSIGNED(37, 8);
i_bufi_di(23 downto 16) <= TO_UNSIGNED(38, 8);
i_bufi_di(31 downto 24) <= TO_UNSIGNED(39, 8);
i_bufi_di(39 downto 32) <= TO_UNSIGNED(40, 8);
i_bufi_di(47 downto 40) <= TO_UNSIGNED(41, 8);
i_bufi_di(55 downto 48) <= TO_UNSIGNED(42, 8);
i_bufi_di(63 downto 56) <= TO_UNSIGNED(43, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '1';

wait until rising_edge(i_clk);
i_bufi_wr <= '0';
i_bufi_wr_last <= '0';


wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED(2 + (4 + 4 + 4 + 4 + 4)   , 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_PKT_TYPE_D2H, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED((2 + 8)       , 16); --2
i_bufi_di(63 downto 48) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
--i_bufi_di(63 downto 57) <= TO_UNSIGNED(, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED((2 + 11)   , 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED((2 + 8)       , 16); --2
i_bufi_di(63 downto 48) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED((2 + 12)   , 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED((2 + 8)       , 16); --2
i_bufi_di(63 downto 48) <= TO_UNSIGNED(C_UDEV_REG, 16); --2
i_bufi_wr <= '1';
i_bufi_wr_last <= '1';

wait until rising_edge(i_clk);
i_bufi_wr <= '0';
i_bufi_wr_last <= '0';

wait;
end process;




end architecture behavioral;
