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

entity ust_rd_tb is
generic(
G_IBUF_DWIDTH : natural := 64;
G_OBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
p_in_dev_rdy : in  TDevB; --ready
p_out_dev_d  : out TDevD; --data
p_out_dev_wr : out TDevB; --write

--i_dev_empty : out TUDevRD;
p_out_obuf_axi_tdata  : out std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
p_out_obuf_axi_tvalid : out std_logic; --empty
p_out_obuf_axi_tlast  : out std_logic --EOF
);
end entity ust_rd_tb;

architecture behavioral of ust_rd_tb is

constant CI_CLK_PERIOD : TIME := 6.6 ns; --150MHz

--after change, need correct value into array C_DEV_VALID!!!!
constant CI_NDEV_CAM : natural := 0;
constant CI_NDEV_GPS : natural := 1;

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

component dev_rd is
generic(
G_SDEV_COUNT_MAX : natural := 4;
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_OBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQRD
--------------------------------------------------
p_in_rq_di     : in   std_logic_vector(7 downto 0);
p_in_rq_wr     : in   std_logic;
p_out_rq_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_drdy : in  TDevB;
p_in_dev_d    : in  TDevD;
p_out_dev_rd  : out TDevB;

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

component dev_wr is
generic(
G_SDEV_COUNT_MAX : natural := 4;
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQWR (Len + DEVID + WRDATA; Len + DEVID + WRDATA....)
--------------------------------------------------
p_in_rq_di     : in   std_logic_vector(7 downto 0);
p_in_rq_wr     : in   std_logic;
p_out_rq_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdy : in  TDevB; --ready
p_out_dev_d  : out TDevD; --data
p_out_dev_wr : out TDevB; --write

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component dev_wr;

component fifo_rqrd
port (
din   : in std_logic_vector(7 downto 0);
wr_en : in std_logic;

dout  : out std_logic_vector(7 downto 0);
rd_en : in std_logic;

full  : out std_logic;
empty : out std_logic;

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk  : in std_logic;
srst : in std_logic
);
end component fifo_rqrd;

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

signal i_rqwr_di    : std_logic_vector(7 downto 0);
signal i_rqwr_wr    : std_logic;
signal i_rqwr_rdy_n : std_logic;

signal i_rqrd_di    : std_logic_vector(7 downto 0);
signal i_rqrd_wr    : std_logic;
signal i_rqrd_rdy_n : std_logic;

signal i_axi_tready : std_logic; --read
signal i_axi_tdata  : std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
signal i_axi_tvalid : std_logic; --empty
signal i_axi_tlast  : std_logic; --EOF

signal i_obuf_axi_tdata  : std_logic_vector(63 downto 0);
signal i_obuf_axi_tvalid : std_logic;
signal i_obuf_axi_tlast  : std_logic;
signal i_obuf_axi_tready : std_logic;

signal i_wdev_rdy : TDevB;
signal i_wdev_d   : TDevD;
signal i_wdev_wr  : TDevB;

signal i_rdev_rdy : TDevB;
signal i_rdev_d   : TDevD;
signal i_rdev_rd  : TDevB;

signal i_dev_di : TDevD;
signal i_dev_do : TDevD;
signal i_dev_wr : TDevB;
signal i_dev_empty : TDevB;


signal i_bufi_di     : unsigned(G_IBUF_DWIDTH - 1 downto 0);
signal i_bufi_wr     : std_logic;
signal i_bufi_wr_last: std_logic;
signal i_bufi_full   : std_logic;
signal i_bufi_do     : std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
signal i_bufi_rd     : std_logic;
signal i_bufi_rd_last: std_logic;
signal i_bufi_empty  : std_logic;


begin --architecture behavioral


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
p_out_ibuf_axi_tready => i_bufi_rd,--: out  std_logic; --read
p_in_ibuf_axi_tdata   => i_bufi_do, --: in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_ibuf_axi_tvalid  => i_bufi_empty,--: in   std_logic; --empty
p_in_ibuf_axi_tlast   => i_bufi_rd_last,--: in   std_logic; --EOF

--------------------------------------------------
--DEV
--------------------------------------------------
--request write to dev
p_out_rqwr_di   => i_rqwr_di,
p_out_rqwr_wr   => i_rqwr_wr,
p_in_rqwr_rdy_n => i_rqwr_rdy_n,

--request read from dev
p_out_rqrd_di   => i_rqrd_di,
p_out_rqrd_wr   => i_rqrd_wr,
p_in_rqrd_rdy_n => i_rqrd_rdy_n,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0'),

p_out_err => open,
p_in_clk => i_clk,
p_in_rst => i_rst
);

m_dev_wr : dev_wr
generic map(
G_SDEV_COUNT_MAX => C_SDEV_COUNT_MAX,
G_TDEV_COUNT_MAX => C_TDEV_COUNT_MAX,
G_NDEV_COUNT_MAX => C_NDEV_COUNT_MAX,
G_SIM => "OFF"
)
port map(
--------------------------------------------------
--RQWR (Len + DEVID + WRDATA; Len + DEVID + WRDATA....)
--------------------------------------------------
p_in_rq_di     => i_rqwr_di,
p_in_rq_wr     => i_rqwr_wr,
p_out_rq_rdy_n => i_rqwr_rdy_n,

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdy => i_wdev_rdy, --: in  TDevB; --ready
p_out_dev_d  => i_wdev_d  , --: out TDevD; --data
p_out_dev_wr => i_wdev_wr , --: out TDevB; --write

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst  => (others => '0'),

p_in_clk => i_clk,
p_in_rst => i_rst
);

--i_wdev_rdy <= p_in_dev_rdy;
genwr_sdev : for s in 0 to C_SDEV_COUNT_MAX - 1 generate begin
  genwr_tdev : for t in 0 to C_TDEV_COUNT_MAX - 1 generate begin
    genwr_ndev : for n in 0 to C_NDEV_COUNT_MAX - 1 generate begin

      i_wdev_rdy(s)(t)(n) <= '1' when C_WDEV_VALID(s)(t)(n) = '1' else '0';

    end generate genwr_ndev;
  end generate genwr_tdev;
end generate genwr_sdev;

p_out_dev_d  <= i_wdev_d ;
p_out_dev_wr <= i_wdev_wr;



m_dev_rd : dev_rd
generic map(
G_SDEV_COUNT_MAX => C_SDEV_COUNT_MAX,
G_TDEV_COUNT_MAX => C_TDEV_COUNT_MAX,
G_NDEV_COUNT_MAX => C_NDEV_COUNT_MAX,
G_OBUF_DWIDTH => G_OBUF_DWIDTH,
G_SIM => "OFF"
)
port map(
--------------------------------------------------
--RQRD
--------------------------------------------------
p_in_rq_di     => i_rqrd_di   ,
p_in_rq_wr     => i_rqrd_wr   ,
p_out_rq_rdy_n => i_rqrd_rdy_n,

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_drdy => i_rdev_rdy,
p_in_dev_d    => i_rdev_d  ,
p_out_dev_rd  => i_rdev_rd ,

--------------------------------------------------
--EthTx
--------------------------------------------------
p_in_obuf_axi_tready  => '1',
p_out_obuf_axi_tdata  => p_out_obuf_axi_tdata , --i_obuf_axi_tdata ,--
p_out_obuf_axi_tvalid => p_out_obuf_axi_tvalid, --i_obuf_axi_tvalid,--
p_out_obuf_axi_tlast  => p_out_obuf_axi_tlast , --i_obuf_axi_tlast ,--

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst => open,
p_in_tst => (others => '0'),

p_in_clk => i_clk,
p_in_rst => i_rst
);


gen_sdev : for s in 0 to C_SDEV_COUNT_MAX - 1 generate begin
  gen_tdev : for t in 0 to C_TDEV_COUNT_MAX - 1 generate begin
    gen_ndev : for n in 0 to C_NDEV_COUNT_MAX - 1 generate begin

      i_rdev_rdy(s)(t)(n) <= not i_dev_empty(s)(t)(n) when C_RDEV_VALID(s)(t)(n) = '1' else '0';
      i_rdev_d   (s)(t)(n) <= i_dev_do       (s)(t)(n) when C_RDEV_VALID(s)(t)(n) = '1' else (others => '0');

    end generate gen_ndev;
  end generate gen_tdev;
end generate gen_sdev;


m_fifo_reg_0 : fifo_rqrd
port map(
din   => i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM),
wr_en => i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM),

dout  => i_dev_do(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM),
rd_en => i_rdev_rd(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM),

full  => open, --i_rqbuf_full,
empty => i_dev_empty(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM),

wr_rst_busy => open,
rd_rst_busy => open,

clk => i_clk,
srst => i_rst
);

m_fifo_gps_0 : fifo_rqrd
port map(
din   => i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS),
wr_en => i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS),

dout  => i_dev_do(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS),
rd_en => i_rdev_rd(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS),

full  => open, --i_rqbuf_full,
empty => i_dev_empty(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS),

wr_rst_busy => open,
rd_rst_busy => open,

clk => i_clk,
srst => i_rst
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

--
--process
--variable len : unsigned(15 downto 0);
--variable id : unsigned(15 downto 0);
--begin
--i_rqrd_di <= (others => '0');
--i_rqrd_wr <= '0';
--
--len := (others => '0');
--id  := (others => '0');
--
--wait for 3 us;
--
--wait until rising_edge(i_clk);
--len := TO_UNSIGNED(6, len'length);
--id(3  downto 0) := TO_UNSIGNED(C_SDEV_D2H, 4); --subtype
--id(7  downto 4) := TO_UNSIGNED(C_TDEV_CAM, 4); --type
--id(11 downto 8) := TO_UNSIGNED(CI_NDEV_CAM, 4); --num
--id(14 downto 12) := (others => '0');
--id(15) := '0';
--
--i_rqrd_di <= len(7  downto 0);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= len(15 downto 8);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= id(7  downto 0);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= id(15 downto 8);
--i_rqrd_wr <= '1';
--
--
--
--wait until rising_edge(i_clk);
--len := TO_UNSIGNED(7, len'length);
--id(3  downto 0) := TO_UNSIGNED(C_SDEV_D2H, 4); --subtype
--id(7  downto 4) := TO_UNSIGNED(C_TDEV_GPS, 4); --type
--id(11 downto 8) := TO_UNSIGNED(CI_NDEV_GPS, 4); --num
--id(14 downto 12) := (others => '0');
--id(15) := '0';
--
--i_rqrd_di <= len(7  downto 0);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= len(15 downto 8);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= id(7  downto 0);
--i_rqrd_wr <= '1';
--wait until rising_edge(i_clk);
--i_rqrd_di <= id(15 downto 8);
--i_rqrd_wr <= '1';
--
--
--wait until rising_edge(i_clk);
--i_rqrd_wr <= '0';
--wait;
--end process;



process
begin

i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= (others => '0');
i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '0';

wait for 3.1 us;
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#1C#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#2C#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#3C#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
wait until rising_edge(i_clk);

--i_dev_wr(C_TDEV_CAM)(CI_NDEV_CAM) <= '0';
--wait until rising_edge(i_clk);
--
--wait for 0.5 us;

i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#4C#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
wait until rising_edge(i_clk);

i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '0';
wait until rising_edge(i_clk);

--i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#5C#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
--wait until rising_edge(i_clk);
--
--i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#6C#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
--wait until rising_edge(i_clk);
--
--i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#7C#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '1';
--wait until rising_edge(i_clk);
--
--i_dev_di(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= std_logic_vector(TO_UNSIGNED(16#8C#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_CAM)(CI_NDEV_CAM) <= '0';
--wait until rising_edge(i_clk);

wait;
end process;


process
begin

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= (others => '0');
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '0';

wait for 3.7 us;
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#1D#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#2D#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#3D#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#4D#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
wait until rising_edge(i_clk);

i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#5D#, 8));
i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '0';
wait until rising_edge(i_clk);

--i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#6D#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
--wait until rising_edge(i_clk);
--
--i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#7D#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '1';
--wait until rising_edge(i_clk);
--
--i_dev_di(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= std_logic_vector(TO_UNSIGNED(16#8D#, 8));
--i_dev_wr(C_SDEV_D2H)(C_TDEV_GPS)(CI_NDEV_GPS) <= '0';
--wait until rising_edge(i_clk);

wait;
end process;


process
begin
i_bufi_di <= (others => '0');
i_bufi_wr <= '0';
i_bufi_wr_last <= '0';

wait for 3 us;

wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED(2 + (2 + 10) + (2 + 14), 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_TPKT_H2D, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED(10, 16); --sizeof(Heade) + sizeof(DataWR) = 2 + 8
i_bufi_di(63 downto 48) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_CAM, 4) & TO_UNSIGNED(C_TDEV_CAM, 4) & TO_UNSIGNED(C_SDEV_H2D, 4);
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
i_bufi_di(15 downto  0) <= TO_UNSIGNED(14, 16); --sizeof(Header) + sizeof(DataWR) = 2 + 12
i_bufi_di(31 downto 16) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_GPS, 4) & TO_UNSIGNED(C_TDEV_GPS, 4) & TO_UNSIGNED(C_SDEV_H2D, 4);
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
i_bufi_di(15 downto 0)  <= TO_UNSIGNED(2 + (2 + 2) + (2 + 2), 16); --
i_bufi_di(31 downto 16) <= TO_UNSIGNED(C_TPKT_D2H, 16); --2
i_bufi_di(47 downto 32) <= TO_UNSIGNED(6 , 16); --sizeof(Header) + sizeof(DataRD) = 2 + 4
i_bufi_di(63 downto 48) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_CAM, 4) & TO_UNSIGNED(C_TDEV_CAM, 4) & TO_UNSIGNED(C_SDEV_D2H, 4);
--i_bufi_di(63 downto 57) <= TO_UNSIGNED(, 8);
i_bufi_wr <= '1';
i_bufi_wr_last <= '0';

wait until rising_edge(i_clk);
i_bufi_di(15 downto 0)  <= TO_UNSIGNED(7 , 16); --sizeof(Header) + sizeof(DataRD) = 2 + 5
i_bufi_di(31 downto 16) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_GPS, 4) & TO_UNSIGNED(C_TDEV_GPS, 4) & TO_UNSIGNED(C_SDEV_D2H, 4);
i_bufi_di(47 downto 32) <= (others => '0'); --TO_UNSIGNED(10 , 16);  --sizeof(Header) + sizeof(DataRD) = 2 + 8
i_bufi_di(63 downto 48) <= (others => '0'); --TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_GPS, 4) & TO_UNSIGNED(C_TDEV_GPS, 4) & TO_UNSIGNED(C_SDEV_GPS, 4);
i_bufi_wr <= '1';
i_bufi_wr_last <= '1';

--wait until rising_edge(i_clk);
--i_bufi_di(15 downto 0)  <= TO_UNSIGNED((2 + 12)   , 16); --
--i_bufi_di(31 downto 16) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_CAM, 4) & TO_UNSIGNED(C_TDEV_CAM, 4) & TO_UNSIGNED(C_SDEV_D2H, 4);
--i_bufi_di(47 downto 32) <= TO_UNSIGNED((2 + 8)       , 16); --2
--i_bufi_di(63 downto 48) <= TO_UNSIGNED(0, 4) & TO_UNSIGNED(CI_NDEV_CAM, 4) & TO_UNSIGNED(C_TDEV_CAM, 4) & TO_UNSIGNED(C_SDEV_D2H, 4);
--i_bufi_wr <= '1';
--i_bufi_wr_last <= '1';

wait until rising_edge(i_clk);
i_bufi_wr <= '0';
i_bufi_wr_last <= '0';

wait;
end process;






end architecture behavioral;
