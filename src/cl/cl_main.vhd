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

library work;
use work.reduce_pack.all;

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
--p_in_cl_x_p : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);
--p_in_cl_x_n : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);

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
port (
clk_in1  : in  std_logic;
clk_out1 : out std_logic;
reset    : in  std_logic;
locked   : out std_logic
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
signal g_cl_xclk_7xdiv        : std_logic;
signal g_cl_xclk_7x,g_cl_xclk_7x_inv        : std_logic;
signal i_cl_xclk_7x_lock   : std_logic;
signal g_cl_xclk_4x        : std_logic;
signal i_cl_xclk_4x_lock   : std_logic;

signal i_fifo_clkdiv       : unsigned(1 downto 0);
signal i_fifo_rd           : std_logic;

type TSerDesVALOUT is array (0 to 0) of std_logic_vector(8 downto 0); --p_in_cl_x_p'length - 1) of std_logic_vector(7 downto 0);
type TSerDesDOUT is array (0 to 0) of std_logic_vector(7 downto 0); --p_in_cl_x_p'length - 1) of std_logic_vector(7 downto 0);
type TGearBoxDOUT is array (0 to 0) of std_logic_vector(6 downto 0); --p_in_cl_x_p'length - 1) of std_logic_vector(6 downto 0);
type TDesData is array (0 to 0) of std_logic_vector(3 downto 0); --p_in_cl_x_p'length - 1) of std_logic_vector(3 downto 0);
signal i_cl_x              : std_logic_vector(0 downto 0);--(p_in_cl_x_p'range);
signal i_idelay_do         : std_logic_vector(0 downto 0);--(p_in_cl_x_p'range);
signal i_idelay_oval       : TSerDesVALOUT;
signal i_idelay_ce         : std_logic := '0';
signal i_idelay_ce_cnt     : unsigned(8 downto 0) := (others => '0');
signal i_idelay_inc        : std_logic := '0';
signal i_serdes_do         : TSerDesDOUT;
signal sr_serdes_do        : TDesData;
signal i_gearbox_do        : TGearBoxDOUT;

signal i_delay_cnt  : unsigned(31 downto 0) := (others => '0');

signal sr_idelay_inc       : std_logic_vector(0 to 1);
signal tst_sync : std_logic;

type TReg is array (0 to 6) of unsigned(3 downto 0); --p_in_cl_x_p'length - 1) of std_logic_vector(3 downto 0);
signal sr_reg : TReg;
signal reg_det: TReg;

signal i_det: std_logic := '0';



signal i_vio_cmp_count : std_logic_vector(3 downto 0);
type TVIOcmpval is array (0 to 6) of std_logic_vector(3 downto 0);
signal i_vio_cmp_val : TVIOcmpval;

component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(44 downto 0)
);
end component ila_dbg_cl;

component vio_dbg_cl is
Port (
clk : in STD_LOGIC;
probe_out0 : out STD_LOGIC_VECTOR ( 0 to 0 );
probe_out1 : out STD_LOGIC_VECTOR ( 0 to 0 );
probe_out2 : out STD_LOGIC_VECTOR ( 3 downto 0 );
probe_out3 : out STD_LOGIC_VECTOR ( 3 downto 0 );
probe_out4 : out STD_LOGIC_VECTOR ( 3 downto 0 );
probe_out5 : out STD_LOGIC_VECTOR ( 3 downto 0 );
probe_out6 : out STD_LOGIC_VECTOR ( 3 downto 0 );
probe_out7 : out STD_LOGIC_VECTOR ( 3 downto 0 )
);
end component vio_dbg_cl;

type TMAIN_dbg is record
det : std_logic;
tst_sync : std_logic;
idelay_inc : std_logic;
idelay_ce : std_logic;
idelay_oval : std_logic_vector(8 downto 0);
reg_det : TReg;
sr_serdes_d : std_logic_vector(3 downto 0);
end record;

signal i_dbg    : TMAIN_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct

--IDELAYCTRL_inst : IDELAYCTRL
--generic map (
--SIM_DEVICE => "7SERIES"  -- Set the device version (7SERIES, ULTRASCALE)
--)
--port map (
--RDY => RDY,       -- 1-bit output: Ready output
--REFCLK => REFCLK, -- 1-bit input: Reference clock input
--RST => RST        -- 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
--                -- REFCLK.
--);

--i_rst <= (not i_cl_xclk_7x_lock);-- and (not i_cl_xclk_4x_lock);


m_ibufds_tfg : IBUFDS
port map (I => p_in_cl_tfg_p, IB => p_in_cl_tfg_n, O => p_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I => p_in_rs232_rx, O  => p_out_cl_tc_p, OB => p_out_cl_tc_n);



m_ibufds_xclk : IBUFDS
port map (I => p_in_cl_xclk_p, IB => p_in_cl_xclk_n, O => i_cl_xclk_in);

m_bufg_xclk : BUFG
port map (I => i_cl_xclk_in, O => g_cl_xclk_in);

m_xclk_mmcd : cl_clk_mmcd
port map(
clk_in1  => g_cl_xclk_in,
clk_out1 => g_cl_xclk_7x,
reset    => p_in_rst,
locked   => i_cl_xclk_7x_lock
);

g_cl_xclk_7x_inv <= not g_cl_xclk_7x;

m_BUFGCE_DIV : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 4
)
port map (
I => g_cl_xclk_7x,
O => g_cl_xclk_7xdiv,
CE => '1',
CLR => i_cl_xclk_7x_lock
);


gen_deser1_7 : for i in 0 to 0 generate --(p_in_cl_x_p'length - 1) generate
begin

----deser1:4
--m_ibufds : IBUFDS
--port map (I => p_in_cl_x_p(i), IB => p_in_cl_x_n(i), O => i_cl_x(i));
i_cl_x(i) <= i_cl_xclk_in;

m_idelay : IDELAYE3
generic map (
CASCADE => "NONE",          -- Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
DELAY_FORMAT => "COUNT",    -- Units of the DELAY_VALUE (COUNT, TIME)
DELAY_SRC => "IDATAIN",     -- Delay input (DATAIN, IDATAIN)
DELAY_TYPE => "VARIABLE",      -- Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
DELAY_VALUE => 80,          -- Input delay value setting
IS_CLK_INVERTED => '0',     -- Optional inversion for CLK
IS_RST_INVERTED => '1',     -- Optional inversion for RST
REFCLK_FREQUENCY => 300.0,  -- IDELAYCTRL clock input frequency in MHz (200.0-2400.0)
SIM_DEVICE => "ULTRASCALE", -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS_ES1)
UPDATE_MODE => "ASYNC"      -- Determines when updates to the delay will take effect (ASYNC, MANUAL,
                            -- SYNC)
)
port map (
DATAIN      => '0'        , -- 1-bit input: Data input from the logic
IDATAIN     => i_cl_x(i),     -- 1-bit input: Data input from the IOBUF
DATAOUT     => i_idelay_do(i),     -- 1-bit output: Delayed data output

CASC_IN     => '0'        , -- 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
CASC_RETURN => '0'        , -- 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
CASC_OUT    => open       , -- 1-bit output: Cascade delay output to ODELAY input cascade
CNTVALUEOUT => i_idelay_oval(i)  , -- 9-bit output: Counter value output
EN_VTC      => '0'        , -- 1-bit input: Keep delay constant over VT

CNTVALUEIN  => "000000000" , -- 9-bit input: Counter value input
LOAD        => '0',          -- 1-bit input: Load DELAY_VALUE input
CE          => i_idelay_ce,     -- 1-bit input: Active high enable increment/decrement input
INC         => i_idelay_inc,    -- 1-bit input: Increment / Decrement tap delay input
CLK         => g_cl_xclk_7xdiv, -- 1-bit input: Clock input

RST         => i_cl_xclk_7x_lock
);

m_iserdes : ISERDESE3
generic map (
IDDR_MODE => "FALSE",
DATA_WIDTH => 8,           -- Parallel data width (4,8)
FIFO_ENABLE => "FALSE",    -- Enables the use of the FIFO
FIFO_SYNC_MODE => "FALSE", -- Enables the use of internal 2-stage synchronizers on the FIFO
IS_CLK_B_INVERTED => '1',  -- Optional inversion for CLK_B
IS_CLK_INVERTED => '0',    -- Optional inversion for CLK
IS_RST_INVERTED => '1',    -- Optional inversion for RST
SIM_DEVICE => "ULTRASCALE" -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS_ES1)
)
port map (
D     => i_idelay_do(i), -- 1-bit input: Serial Data Input
CLK   => g_cl_xclk_7x  , -- 1-bit input: High-speed clock
CLK_B => g_cl_xclk_7x  , -- 1-bit input: Inversion of High-speed clock CLK

Q      => i_serdes_do(i)  , -- 8-bit registered output
CLKDIV => g_cl_xclk_7xdiv , -- 1-bit input: Divided Clock

FIFO_RD_EN  => '0' ,    -- 1-bit input: Enables reading the FIFO when asserted
FIFO_RD_CLK => '0' ,    -- 1-bit input: FIFO read clock
FIFO_EMPTY  => open,    -- 1-bit output: FIFO empty flag

RST => i_cl_xclk_7x_lock
);

--Deserialization 1:4
process(g_cl_xclk_7xdiv)
begin
if rising_edge(g_cl_xclk_7xdiv) then
sr_serdes_do(i)(0) <= i_serdes_do(i)(0);
sr_serdes_do(i)(1) <= i_serdes_do(i)(2);
sr_serdes_do(i)(2) <= i_serdes_do(i)(4);
sr_serdes_do(i)(3) <= i_serdes_do(i)(6);
end if;
end process;

end generate gen_deser1_7;




process(g_cl_xclk_7xdiv)
begin
if rising_edge(g_cl_xclk_7xdiv) then
  if (i_cl_xclk_7x_lock = '1') then
    if i_delay_cnt = TO_UNSIGNED(32, i_delay_cnt'length) then
      i_delay_cnt <= (others => '0');
      i_idelay_ce <= '1';
      if (UNSIGNED(i_idelay_oval(0)) = TO_UNSIGNED(511, i_idelay_ce_cnt'length)) then
        i_idelay_inc <= not i_idelay_inc;
      end if;
    else
      i_delay_cnt <= i_delay_cnt + 1;
      i_idelay_ce <= '0';
    end if;
  end if;
end if;
end process;





--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_cl_xclk_7x_lock;
p_out_tst(1) <= tst_sync;
p_out_tst(2) <= i_idelay_oval(0)(3) or sr_serdes_do(0)(0) or reg_det(0)(0);



process(g_cl_xclk_7xdiv)
begin
if rising_edge(g_cl_xclk_7xdiv) then
  if (i_cl_xclk_7x_lock = '1') then

    sr_reg <= UNSIGNED(sr_serdes_do(0)) & sr_reg(0 to (sr_reg'high - 1));

    if (UNSIGNED(i_vio_cmp_count) = TO_UNSIGNED(1, i_vio_cmp_count'length)) then

        if (sr_reg(6) = UNSIGNED(i_vio_cmp_val(0)) )then
            reg_det <= sr_reg;
            i_det <= '1';
        else
          i_det <= '0';
        end if;

    elsif (UNSIGNED(i_vio_cmp_count) = TO_UNSIGNED(2, i_vio_cmp_count'length)) then

        if (sr_reg(6) = UNSIGNED(i_vio_cmp_val(0))
          and sr_reg(5) = UNSIGNED(i_vio_cmp_val(1)) )then
            reg_det <= sr_reg;
            i_det <= '1';
        else
          i_det <= '0';
        end if;

    elsif (UNSIGNED(i_vio_cmp_count) = TO_UNSIGNED(3, i_vio_cmp_count'length)) then

        if (sr_reg(6) = UNSIGNED(i_vio_cmp_val(0))
          and sr_reg(5) = UNSIGNED(i_vio_cmp_val(1))
            and sr_reg(4) = UNSIGNED(i_vio_cmp_val(2)) )then
            reg_det <= sr_reg;
            i_det <= '1';
        else
          i_det <= '0';
        end if;

    elsif (UNSIGNED(i_vio_cmp_count) = TO_UNSIGNED(4, i_vio_cmp_count'length)) then

        if (sr_reg(6) = UNSIGNED(i_vio_cmp_val(0))
          and sr_reg(5) = UNSIGNED(i_vio_cmp_val(1))
            and sr_reg(4) = UNSIGNED(i_vio_cmp_val(2))
              and sr_reg(3) = UNSIGNED(i_vio_cmp_val(3)) )then
            reg_det <= sr_reg;
            i_det <= '1';
        else
          i_det <= '0';
        end if;
    else

    reg_det <= sr_reg;

    end if;
  end if;
end if;
end process;

process(g_cl_xclk_7xdiv)
begin
if rising_edge(g_cl_xclk_7xdiv) then
  if (i_cl_xclk_7x_lock = '1') then
    sr_idelay_inc <= i_idelay_inc & sr_idelay_inc(0 to 0);
    tst_sync <= XOR_reduce(sr_idelay_inc);
  end if;
end if;
end process;


i_dbg.det <= i_det;
i_dbg.tst_sync <= tst_sync;
i_dbg.idelay_inc <= i_idelay_inc;
i_dbg.idelay_ce <= i_idelay_ce;
i_dbg.idelay_oval <= i_idelay_oval(0);

i_dbg.sr_serdes_d <= sr_serdes_do(0);
i_dbg.reg_det(0) <= reg_det(0);
i_dbg.reg_det(1) <= reg_det(1);
i_dbg.reg_det(2) <= reg_det(2);
i_dbg.reg_det(3) <= reg_det(3);
i_dbg.reg_det(4) <= reg_det(4);
i_dbg.reg_det(5) <= reg_det(5);
i_dbg.reg_det(6) <= reg_det(6);

dbg_cl : ila_dbg_cl
port map(
clk => g_cl_xclk_7xdiv,
probe0(0) => i_dbg.det,
probe0(4 downto 1)   => sr_serdes_do(0),
probe0(8 downto 5)   => std_logic_vector(i_dbg.reg_det(0)),
probe0(12 downto 9)  => std_logic_vector(i_dbg.reg_det(1)),
probe0(16 downto 13) => std_logic_vector(i_dbg.reg_det(2)),
probe0(20 downto 17) => std_logic_vector(i_dbg.reg_det(3)),
probe0(24 downto 21) => std_logic_vector(i_dbg.reg_det(4)),
probe0(28 downto 25) => std_logic_vector(i_dbg.reg_det(5)),
probe0(32 downto 29) => std_logic_vector(i_dbg.reg_det(6)),

probe0(33) => i_dbg.idelay_inc,
probe0(34) => i_dbg.idelay_ce,
probe0(43 downto 35) => i_dbg.idelay_oval,
probe0(44) => i_dbg.tst_sync
);


dbg_vio : vio_dbg_cl
port map(
clk => g_cl_xclk_7xdiv,
probe_out0 => open,
probe_out1 => open,
probe_out2 => i_vio_cmp_count,
probe_out3 => i_vio_cmp_val(0),
probe_out4 => i_vio_cmp_val(1),
probe_out5 => i_vio_cmp_val(2),
probe_out6 => i_vio_cmp_val(3),
probe_out7 => i_vio_cmp_val(4)
);


end architecture struct;

----deser4:7
--m_gearbox_4_to_7 : gearbox_4_to_7
--generic map(D => 1)
--port map(
--input_clock  => g_cl_xclk_4x,-- :  in std_logic ;       -- high speed clock input
--datain       => sr_serdes_do(i)  ,-- :  in std_logic_vector(D*4-1 downto 0) ;  -- data inputs
--
--output_clock => g_cl_xclk_in,-- :  in std_logic ;       -- low speed clock input
--dataout      => i_gearbox_do(i),-- : out std_logic_vector(D*7-1 downto 0);
--
--jog          => '0',-- :  in std_logic ;       -- jog input, slips by 4 bits
--reset        => i_rst -- :  in std_logic ;       -- Reset line
--);