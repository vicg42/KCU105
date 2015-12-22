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
p_in_tfg_n : in  std_logic; --Camera -> FG
p_in_tfg_p : in  std_logic;
p_out_tc_n : out std_logic; --Camera <- FG
p_out_tc_p : out std_logic;

p_in_xclk_p : in  std_logic;
p_in_xclk_n : in  std_logic;
--p_in_x_p : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);
--p_in_x_n : in  std_logic_vector(G_CLIN_WIDTH - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

p_in_refclk : in std_logic;
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

type TFsm_fsync is (
S_SYNC_FIND,
S_SYNC_CHK
);
signal i_fsm_sync     : TFsm_fsync;


signal i_div_rst        : std_logic;
signal i_idelay_rst     : std_logic;
signal i_serdes_rst     : std_logic;
signal i_desr_ctrl_rst  : std_logic;
signal i_gearbox_rst    : std_logic;
signal sr_rst           : std_logic_vector(0 to 31);

signal i_idelayctrl_rst : std_logic;
signal i_idelayctrl_rdy : std_logic;

signal i_xclk_in        : std_logic;
signal g_xclk_in        : std_logic;
signal g_xclk_7xdiv4    : std_logic;
signal g_xclk_7xdiv7    : std_logic;
signal g_xclk_7x        : std_logic;
signal i_xclk_7x_lock   : std_logic;

type TSerDesVALOUT is array (0 to 0) of std_logic_vector(8 downto 0); --p_in_x_p'length - 1) of std_logic_vector(7 downto 0);
type TSerDesDOUT is array (0 to 0) of std_logic_vector(7 downto 0); --p_in_x_p'length - 1) of std_logic_vector(7 downto 0);
type TGearBoxDOUT is array (0 to 0) of std_logic_vector(6 downto 0); --p_in_x_p'length - 1) of std_logic_vector(6 downto 0);
type TDesData is array (0 to 0) of std_logic_vector(3 downto 0); --p_in_x_p'length - 1) of std_logic_vector(3 downto 0);
signal i_x              : std_logic_vector(0 downto 0);--(p_in_x_p'range);
signal i_idelay_do      : std_logic_vector(0 downto 0);--(p_in_x_p'range);
signal i_idelay_oval    : TSerDesVALOUT;
signal i_idelay_ce      : std_logic := '0';
signal i_idelay_inc     : std_logic := '0';
signal i_serdes_do      : TSerDesDOUT;
signal sr_serdes_do     : TDesData;
signal i_gearbox_do     : TGearBoxDOUT;

type TReg is array (0 to 6) of unsigned(3 downto 0); --p_in_x_p'length - 1) of std_logic_vector(3 downto 0);
signal sr_reg : TReg;

signal i_sync_det       : std_logic := '0';

signal i_fsync_pcnt     : unsigned(2 downto 0);
signal i_fsync_timeout  : unsigned(7 downto 0);
signal i_fsync_vldcnt   : unsigned(12 downto 0);
signal i_fsync_vld      : std_logic;

signal i_err            : std_logic := '0';


signal i_vio_cmp_count : std_logic_vector(3 downto 0);
type TVIOcmpval is array (0 to 6) of std_logic_vector(3 downto 0);
signal i_vio_cmp_val : TVIOcmpval;

component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(44 downto 0)
);
end component ila_dbg_cl;

component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(7 downto 0)
);
end component ila_dbg2_cl;

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
det_sync : std_logic;
tst_sync : std_logic;
idelay_inc : std_logic;
idelay_ce : std_logic;
idelay_oval : std_logic_vector(8 downto 0);
reg_det : TReg;
sr_reg : TReg;
sr_serdes_d : std_logic_vector(3 downto 0);
gearbox_do : std_logic_vector(6 downto 0);
end record;

signal i_dbg    : TMAIN_dbg;

attribute mark_debug : string;
attribute mark_debug of i_dbg  : signal is "true";



begin --architecture struct


m_ibufds_tfg : IBUFDS
port map (I => p_in_tfg_p, IB => p_in_tfg_n, O => p_out_rs232_tx);

m_obufds_tc : OBUFDS
port map (I => p_in_rs232_rx, O  => p_out_tc_p, OB => p_out_tc_n);


--m_IDELAYCTRL : IDELAYCTRL
--generic map (
--SIM_DEVICE => "ULTRASCALE"  -- Set the device version (7SERIES, ULTRASCALE)
--)
--port map (
--RDY    => i_idelayctrl_rdy, -- 1-bit output: Ready output
--REFCLK => p_in_refclk     , -- 1-bit input: Reference clock input
--RST    => i_idelayctrl_rst  -- 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
--                            -- REFCLK.
--);


--#########################################
--CL XCH
--#########################################
m_ibufds_xclk : IBUFDS
port map (I => p_in_xclk_p, IB => p_in_xclk_n, O => i_xclk_in);

m_bufg_xclk : BUFG
port map (I => i_xclk_in, O => g_xclk_in);

m_xclk : cl_clk_mmcd
port map(
clk_in1  => g_xclk_in,
clk_out1 => g_xclk_7x,
reset    => p_in_rst,
locked   => i_xclk_7x_lock
);

m_BUFGCE_DIV4 : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 4
)
port map (
I => g_xclk_7x,
O => g_xclk_7xdiv4,
CE => '1',
CLR => i_div_rst
);

m_BUFGCE_DIV7 : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 7
)
port map (
I => g_xclk_7x,
O => g_xclk_7xdiv7,
CE => '1',
CLR => i_div_rst
);


--RESET CTRL
process(i_xclk_7x_lock, g_xclk_7x)
begin
if (i_xclk_7x_lock = '0') then
  sr_rst <= (others => '0');
elsif rising_edge(g_xclk_7x) then
  sr_rst <= '1' & sr_rst(0 to (sr_rst'high - 1));
end if;
end process;

i_div_rst <= sr_rst(7);
i_idelay_rst <= sr_rst(15);
i_serdes_rst <= sr_rst(23);
i_desr_ctrl_rst <= sr_rst(31);


gen_deser_xch : for i in 0 to 0 generate --(p_in_x_p'length - 1) generate
begin

--m_ibufds : IBUFDS
--port map (I => p_in_x_p(i), IB => p_in_x_n(i), O => i_x(i));
i_x(i) <= i_xclk_in;

m_idelay : IDELAYE3
generic map (
CASCADE => "NONE",          -- Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
DELAY_FORMAT => "COUNT",    -- Units of the DELAY_VALUE (COUNT, TIME)
DELAY_SRC => "IDATAIN",     -- Delay input (DATAIN, IDATAIN)
DELAY_TYPE => "VARIABLE",   -- Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
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
IDATAIN     => i_x(i),     -- 1-bit input: Data input from the IOBUF
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
CLK         => g_xclk_7xdiv4, -- 1-bit input: Clock input

RST         => i_idelay_rst
);

m_iserdes : ISERDESE3
generic map (
IDDR_MODE => "FALSE",
DATA_WIDTH => 8,           -- Parallel data width (4,8)
FIFO_ENABLE => "FALSE",    -- Enables the use of the FIFO
FIFO_SYNC_MODE => "FALSE", -- Enables the use of internal 2-stage synchronizers on the FIFO
IS_CLK_B_INVERTED => '0',  -- Optional inversion for CLK_B
IS_CLK_INVERTED => '0',    -- Optional inversion for CLK
IS_RST_INVERTED => '1',    -- Optional inversion for RST
SIM_DEVICE => "ULTRASCALE" -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS_ES1)
)
port map (
D     => i_idelay_do(i), -- 1-bit input: Serial Data Input
CLK   => g_xclk_7x  , -- 1-bit input: High-speed clock
CLK_B => g_xclk_7x  , -- 1-bit input: Inversion of High-speed clock CLK

Q      => i_serdes_do(i)  , -- 8-bit registered output
CLKDIV => g_xclk_7xdiv4 , -- 1-bit input: Divided Clock

FIFO_RD_EN  => '0' ,    -- 1-bit input: Enables reading the FIFO when asserted
FIFO_RD_CLK => '0' ,    -- 1-bit input: FIFO read clock
FIFO_EMPTY  => open,    -- 1-bit output: FIFO empty flag

RST => i_serdes_rst
);

--Deserialization 1:4
process(g_xclk_7xdiv4)
begin
if rising_edge(g_xclk_7xdiv4) then
sr_serdes_do(i)(0) <= i_serdes_do(i)(0);
sr_serdes_do(i)(1) <= i_serdes_do(i)(2);
sr_serdes_do(i)(2) <= i_serdes_do(i)(4);
sr_serdes_do(i)(3) <= i_serdes_do(i)(6);
end if;
end process;

m_gearbox : gearbox_4_to_7
generic map(D => 1)
port map(
datain       => sr_serdes_do(i),
input_clock  => g_xclk_7xdiv4,

dataout      => i_gearbox_do(i),
output_clock => g_xclk_7xdiv7,

jog          => '0',
reset        => i_gearbox_rst
);

end generate gen_deser_xch;

i_gearbox_rst <= not i_fsync_vld;


--find synch
process(g_xclk_7xdiv4)
begin
if rising_edge(g_xclk_7xdiv4) then

    sr_reg <= UNSIGNED(sr_serdes_do(0)) & sr_reg(0 to (sr_reg'high - 1));

    if (  (sr_reg(0) = (TO_UNSIGNED(16#F#, sr_reg(0)'length)))
        and (sr_reg(1) = (TO_UNSIGNED(16#1#, sr_reg(0)'length)))
          and (sr_reg(2) = (TO_UNSIGNED(16#E#, sr_reg(0)'length)))
            and (sr_reg(3) = (TO_UNSIGNED(16#3#, sr_reg(0)'length)))
              and (sr_reg(4) = (TO_UNSIGNED(16#C#, sr_reg(0)'length)))
                and (sr_reg(5) = (TO_UNSIGNED(16#7#, sr_reg(0)'length)))
                  and (sr_reg(6) = (TO_UNSIGNED(16#8#, sr_reg(0)'length))) ) then

      i_sync_det <= '1';
    else
      i_sync_det <= '0';
    end if;

end if;
end process;


process(i_desr_ctrl_rst, g_xclk_7xdiv4)
begin
if (i_desr_ctrl_rst = '0') then
  i_fsm_sync <= S_SYNC_FIND;

  i_idelay_ce <= '0';
  i_idelay_inc <= '0';

  i_fsync_pcnt <= (others => '0');
  i_fsync_timeout <= (others => '0');
  i_fsync_vldcnt <= (others => '0');
  i_fsync_vld <= '0';

elsif rising_edge(g_xclk_7xdiv4) then
  case i_fsm_sync is

    when S_SYNC_FIND =>

      i_fsync_pcnt <= (others => '0');

      if (i_fsync_timeout = (i_fsync_timeout'range => '1')) then
        i_fsync_timeout <= (others => '0');

        i_idelay_ce <= '1';
        i_idelay_inc <= '1';

      else
        i_idelay_ce <= '0';
        i_fsync_timeout <= i_fsync_timeout + 1;
      end if;

      if (i_sync_det = '1') then
        i_fsm_sync <= S_SYNC_CHK;
      end if;


    when S_SYNC_CHK =>

      i_idelay_ce <= '0';
      i_fsync_timeout <= (others => '0');

      --period sync strob (i_sync_det)
      if (i_fsync_pcnt = (TO_UNSIGNED(6, i_fsync_pcnt'length))) then
        i_fsync_pcnt <= (others => '0');

        if (i_sync_det = '1') then

          --count valid period
          if (i_fsync_vld = '0') then
            if (i_fsync_vldcnt = (TO_UNSIGNED(4096, i_fsync_vldcnt'length))) then
              i_fsync_vldcnt <= (others => '0');
              i_fsync_vld <= '1';
            else
              i_fsync_vldcnt <= i_fsync_vldcnt + 1;
            end if;
          end if;

        else
          i_fsync_vld <= '0';

          if (i_fsync_vld = '1') then
            i_err <= '1';
          end if;

          i_fsm_sync <= S_SYNC_FIND;
        end if;

      else
        i_fsync_pcnt <= i_fsync_pcnt + 1;
      end if;

  end case;

end if;
end process;


--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_xclk_7x_lock;
p_out_tst(1) <= i_err;
p_out_tst(2) <= i_idelay_oval(0)(3) or sr_serdes_do(0)(0);



i_dbg.det_sync <= i_sync_det;
i_dbg.tst_sync <= i_fsync_vld;
i_dbg.idelay_inc <= i_idelay_inc;
i_dbg.idelay_ce <= i_idelay_ce;
i_dbg.idelay_oval <= i_idelay_oval(0);

i_dbg.sr_serdes_d <= sr_serdes_do(0);
--i_dbg.reg_det(0) <= reg_det(0);
--i_dbg.reg_det(1) <= reg_det(1);
--i_dbg.reg_det(2) <= reg_det(2);
--i_dbg.reg_det(3) <= reg_det(3);
--i_dbg.reg_det(4) <= reg_det(4);
--i_dbg.reg_det(5) <= reg_det(5);
--i_dbg.reg_det(6) <= reg_det(6);

i_dbg.sr_reg(0) <= sr_reg(0);
i_dbg.sr_reg(1) <= sr_reg(1);
i_dbg.sr_reg(2) <= sr_reg(2);
i_dbg.sr_reg(3) <= sr_reg(3);
i_dbg.sr_reg(4) <= sr_reg(4);
i_dbg.sr_reg(5) <= sr_reg(5);
i_dbg.sr_reg(6) <= sr_reg(6);

i_dbg.gearbox_do <= i_gearbox_do(0);

dbg_cl : ila_dbg_cl
port map(
clk => g_xclk_7xdiv4,
probe0(0) => i_dbg.det_sync,
probe0(4 downto 1) => sr_serdes_do(0),
probe0(5) => i_dbg.idelay_inc,
probe0(6) => i_dbg.idelay_ce,
probe0(15 downto 7) => i_dbg.idelay_oval,
probe0(19 downto 16) => std_logic_vector(i_dbg.sr_reg(0)),--(i_dbg.reg_det(0)),
probe0(23 downto 20) => std_logic_vector(i_dbg.sr_reg(1)),--(i_dbg.reg_det(1)),
probe0(27 downto 24) => std_logic_vector(i_dbg.sr_reg(2)),--(i_dbg.reg_det(2)),
probe0(31 downto 28) => std_logic_vector(i_dbg.sr_reg(3)),--(i_dbg.reg_det(3)),
probe0(35 downto 32) => std_logic_vector(i_dbg.sr_reg(4)),--(i_dbg.reg_det(4)),
probe0(39 downto 36) => std_logic_vector(i_dbg.sr_reg(5)),--(i_dbg.reg_det(5)),
probe0(43 downto 40) => std_logic_vector(i_dbg.sr_reg(6)),--(i_dbg.reg_det(6)),

probe0(44) => i_dbg.tst_sync
);


dbg2_cl : ila_dbg2_cl
port map(
clk => g_xclk_7xdiv7,
probe0(0) => i_dbg.tst_sync,
probe0(7 downto 1) => i_dbg.gearbox_do
);

--dbg_vio : vio_dbg_cl
--port map(
--clk => g_xclk_7xdiv4,
--probe_out0 => open,
--probe_out1 => open,
--probe_out2 => i_vio_cmp_count,
--probe_out3 => i_vio_cmp_val(0),
--probe_out4 => i_vio_cmp_val(1),
--probe_out5 => i_vio_cmp_val(2),
--probe_out6 => i_vio_cmp_val(3),
--probe_out7 => i_vio_cmp_val(4)
--);


end architecture struct;
