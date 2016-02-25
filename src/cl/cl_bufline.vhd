-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_bufline
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;

entity cl_bufline is
generic(
G_CL_PIXBIT : natural := 8; --Amount bit per 1 pix
G_CL_TAP : natural := 8; --Amount pixel per 1 clk
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--Input
--------------------------------------------------
p_in_fval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_in_lval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_in_dval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_in_rxbyte : in  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_in_rxclk  : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--Output
--------------------------------------------------
p_out_buf_empty : out  std_logic;
p_out_buf_do    : out  std_logic_vector(63 downto 0);
p_in_buf_rd     : in   std_logic;
p_in_buf_rdclk  : in   std_logic;
p_in_buf_rstn   : in   std_logic
);
end entity cl_bufline;

architecture behavioral of cl_bufline is

component cl_fifo_line
port (
din       : in  std_logic_vector(G_CL_PIXBIT - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_CL_PIXBIT - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
--prog_full : out std_logic;

--rst       : in  std_logic

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

--clk       : in  std_logic;
srst      : in  std_logic
);
end component cl_fifo_line;


signal i_buf_rst    : std_logic;
signal i_buf_wr     : std_logic_vector(2 downto 0);
signal i_buf_empty  : std_logic_vector(9 downto 0);


begin --architecture behavioral


p_out_buf_empty <= OR_reduce(i_buf_empty(G_CL_TAP - 1 downto 0));

i_buf_rst <= (not p_in_buf_rstn);


--##############################
--######### CHANNEL X ##########
--##############################
i_buf_wr(0) <= p_in_fval(0) and p_in_lval(0) and p_in_dval(0);

m_buf_byteA : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 1) - 1 downto (8 * 0)),
wr_en     => i_buf_wr(0),
wr_clk    => p_in_rxclk(0),

dout      => p_out_buf_do((8 * 1) - 1 downto (8 * 0)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(0),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);

m_buf_byteB : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 2) - 1 downto (8 * 1)),
wr_en     => i_buf_wr(0),
wr_clk    => p_in_rxclk(0),

dout      => p_out_buf_do((8 * 2) - 1 downto (8 * 1)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(1),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);

m_buf_byteC : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 3) - 1 downto (8 * 2)),
wr_en     => i_buf_wr(0),
wr_clk    => p_in_rxclk(0),

dout      => p_out_buf_do((8 * 3) - 1 downto (8 * 2)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(2),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);



--##############################
--######### CHANNEL Y ##########
--##############################
i_buf_wr(1) <= p_in_fval(1) and p_in_lval(1) and p_in_dval(1);

m_buf_byteD : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 4) - 1 downto (8 * 3)),
wr_en     => i_buf_wr(1),
wr_clk    => p_in_rxclk(1),

dout      => p_out_buf_do((8 * 4) - 1 downto (8 * 3)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(3),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);

m_buf_byteE : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 5) - 1 downto (8 * 4)),
wr_en     => i_buf_wr(1),
wr_clk    => p_in_rxclk(1),

dout      => p_out_buf_do((8 * 5) - 1 downto (8 * 4)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(4),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);

m_buf_byteF : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 6) - 1 downto (8 * 5)),
wr_en     => i_buf_wr(1),
wr_clk    => p_in_rxclk(1),

dout      => p_out_buf_do((8 * 6) - 1 downto (8 * 5)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(5),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);


--##############################
--######### CHANNEL Z ##########
--##############################
i_buf_wr(2) <= p_in_fval(2) and p_in_lval(2) and p_in_dval(2);

m_buf_byteG : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 7) - 1 downto (8 * 6)),
wr_en     => i_buf_wr(2),
wr_clk    => p_in_rxclk(2),

dout      => p_out_buf_do((8 * 7) - 1 downto (8 * 6)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(6),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);

m_buf_byteH : cl_fifo_line
port map(
din       => p_in_rxbyte((8 * 8) - 1 downto (8 * 7)),
wr_en     => i_buf_wr(2),
wr_clk    => p_in_rxclk(2),

dout      => p_out_buf_do((8 * 8) - 1 downto (8 * 7)),
rd_en     => p_in_buf_rd,
rd_clk    => p_in_buf_rdclk,

empty     => i_buf_empty(7),
full      => open,
--prog_full => open,

--rst       => i_buf_rst

wr_rst_busy => open,
rd_rst_busy => open,

--clk       : in  std_logic;
srst      => i_buf_rst
);


end architecture behavioral;
