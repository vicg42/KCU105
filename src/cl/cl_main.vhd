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
G_CL_CHCOUNT : natural := 1
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

p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

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

signal i_cl_clkin        : std_logic;
signal g_cl_clkin        : std_logic;
signal g_cl_clkin_7xdiv4 : std_logic;
signal g_cl_clkin_7xdiv7 : std_logic;
signal g_cl_clkin_7x     : std_logic;
signal i_cl_clkin_7x_lock: std_logic;

type TSerDesVALOUT is array (0 to (p_in_cl_di_p'length - 1 + 1)) of std_logic_vector(8 downto 0); --(0 to 0)
type TSerDesDOUT   is array (0 to (p_in_cl_di_p'length - 1 + 1)) of std_logic_vector(7 downto 0); --(0 to 0)
type TGearBoxDOUT  is array (0 to (p_in_cl_di_p'length - 1 + 1)) of std_logic_vector(6 downto 0); --(0 to 0)
type TDesData      is array (0 to (p_in_cl_di_p'length - 1 + 1)) of std_logic_vector(3 downto 0); --(0 to 0)
signal i_cl_di          : std_logic_vector((p_in_cl_di_p'length - 1 + 1) downto 0); --(0 downto 0);
signal i_idelay_do      : std_logic_vector((p_in_cl_di_p'length - 1 + 1) downto 0); --(0 downto 0);
signal i_idelay_oval    : TSerDesVALOUT;
signal i_idelay_ce      : std_logic := '0';
signal i_idelay_inc     : std_logic := '0';
signal i_serdes_do      : TSerDesDOUT;
signal sr_serdes_do     : TDesData;
signal i_gearbox_do     : TGearBoxDOUT;

type TReg is array (0 to 6) of unsigned(3 downto 0);
signal sr_reg           : TReg;

signal i_sync_det       : std_logic := '0';

signal i_fsync_pcnt     : unsigned(2 downto 0);
signal i_fsync_timeout  : unsigned(7 downto 0);
signal i_fsync_vldcnt   : unsigned(12 downto 0);
signal i_fsync_vld      : std_logic;

signal i_err            : std_logic := '0';

signal i_cl_rxd         : std_logic_vector(27 downto 0);
signal i_clx_sync_val   : std_logic_vector(6 downto 0);


component ila_dbg_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(44 downto 0)
);
end component ila_dbg_cl;

component ila_dbg2_cl is
port (
clk : in std_logic;
probe0 : in std_logic_vector(33 downto 0)
);
end component ila_dbg2_cl;

type TCL_rxbyte_dbg is array (0 to 2) of std_logic_vector(7 downto 0);

type TMAIN_dbg is record
det_sync : std_logic;
tst_sync : std_logic;
idelay_inc : std_logic;
idelay_ce : std_logic;
idelay_oval : std_logic_vector(8 downto 0);
reg_det : TReg;
sr_reg : TReg;
sr_serdes_d : std_logic_vector(3 downto 0);
clx_sync_val : std_logic_vector(6 downto 0);
rxbyte : TCL_rxbyte_dbg;
clx_lval : std_logic;
clx_fval : std_logic;
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
port map (I => p_in_cl_clk_p(0), IB => p_in_cl_clk_n(0), O => i_cl_clkin);

m_bufg_xclk : BUFG
port map (I => i_cl_clkin, O => g_cl_clkin);

m_pllclk : cl_clk_mmcd
port map(
clk_in1  => g_cl_clkin,
clk_out1 => g_cl_clkin_7x,
reset    => p_in_rst,
locked   => i_cl_clkin_7x_lock
);

m_clkx7div4 : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 4
)
port map (
I => g_cl_clkin_7x,
O => g_cl_clkin_7xdiv4,
CE => '1',
CLR => i_div_rst
);

m_clkx7div7 : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 7
)
port map (
I => g_cl_clkin_7x,
O => g_cl_clkin_7xdiv7,
CE => '1',
CLR => i_div_rst
);


--reset ctrl
process(i_cl_clkin_7x_lock, g_cl_clkin_7x)
begin
if (i_cl_clkin_7x_lock = '0') then
  sr_rst <= (others => '0');
elsif rising_edge(g_cl_clkin_7x) then
  sr_rst <= '1' & sr_rst(0 to (sr_rst'high - 1));
end if;
end process;

i_div_rst <= sr_rst(7);
i_idelay_rst <= sr_rst(15);
i_serdes_rst <= sr_rst(23);
i_desr_ctrl_rst <= sr_rst(31);


--Set signal for deserialization
i_cl_di(0) <= i_cl_clkin;--!!!!!!!
gen_xch : for i in 0 to (p_in_cl_di_p'length - 1) generate
begin
m_ibufds : IBUFDS
port map (I => p_in_cl_di_p(i), IB => p_in_cl_di_n(i), O => i_cl_di(i + 1));
end generate gen_xch;


gen_deser_xch : for i in 0 to (p_in_cl_di_p'length - 1 + 1) generate
begin

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
IDATAIN     => i_cl_di(i),     -- 1-bit input: Data input from the IOBUF
DATAOUT     => i_idelay_do(i),     -- 1-bit output: Delayed data output

CASC_IN     => '0'        , -- 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
CASC_RETURN => '0'        , -- 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
CASC_OUT    => open       , -- 1-bit output: Cascade delay output to ODELAY input cascade
CNTVALUEOUT => i_idelay_oval(i)  , -- 9-bit output: Counter value output
EN_VTC      => '0'        , -- 1-bit input: Keep delay constant over VT

CNTVALUEIN  => "000000000" , -- 9-bit input: Counter value input
LOAD        => '0',          -- 1-bit input: Load DELAY_VALUE input
CE          => i_idelay_ce,   -- 1-bit input: Active high enable increment/decrement input
INC         => i_idelay_inc,  -- 1-bit input: Increment / Decrement tap delay input
CLK         => g_cl_clkin_7xdiv4, -- 1-bit input: Clock input

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
CLK   => g_cl_clkin_7x  , -- 1-bit input: High-speed clock
CLK_B => g_cl_clkin_7x  , -- 1-bit input: Inversion of High-speed clock CLK

Q      => i_serdes_do(i), -- 8-bit registered output
CLKDIV => g_cl_clkin_7xdiv4 , -- 1-bit input: Divided Clock

FIFO_RD_EN  => '0' ,    -- 1-bit input: Enables reading the FIFO when asserted
FIFO_RD_CLK => '0' ,    -- 1-bit input: FIFO read clock
FIFO_EMPTY  => open,    -- 1-bit output: FIFO empty flag

RST => i_serdes_rst
);

--Deserialization 1:4
process(g_cl_clkin_7xdiv4)
begin
if rising_edge(g_cl_clkin_7xdiv4) then
sr_serdes_do(i)(0) <= i_serdes_do(i)(0);
sr_serdes_do(i)(1) <= i_serdes_do(i)(2);
sr_serdes_do(i)(2) <= i_serdes_do(i)(4);
sr_serdes_do(i)(3) <= i_serdes_do(i)(6);
end if;
end process;

--4bit -> 7bit
m_gearbox : gearbox_4_to_7
generic map(D => 1)
port map(
datain       => sr_serdes_do(i),
input_clock  => g_cl_clkin_7xdiv4,

dataout      => i_gearbox_do(i),
output_clock => g_cl_clkin_7xdiv7,

jog          => '0',
reset        => i_gearbox_rst
);

end generate gen_deser_xch;

i_gearbox_rst <= not i_fsync_vld;


--find synch
process(i_desr_ctrl_rst, g_cl_clkin_7xdiv4)
begin
if (i_desr_ctrl_rst = '0') then
  i_sync_det <= '0';
elsif rising_edge(g_cl_clkin_7xdiv4) then

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


process(i_desr_ctrl_rst, g_cl_clkin_7xdiv4)
begin
if (i_desr_ctrl_rst = '0') then
  i_fsm_sync <= S_SYNC_FIND;

  i_idelay_ce <= '0';
  i_idelay_inc <= '0';

  i_fsync_pcnt <= (others => '0');
  i_fsync_timeout <= (others => '0');
  i_fsync_vldcnt <= (others => '0');
  i_fsync_vld <= '0';

elsif rising_edge(g_cl_clkin_7xdiv4) then
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
--Data Out
--#########################################
process(g_cl_clkin_7xdiv7)
begin
if rising_edge(g_cl_clkin_7xdiv7) then
--RxIN0
i_cl_rxd((7 * 0) + 0) <= i_gearbox_do(1)(6); --A0
i_cl_rxd((7 * 0) + 1) <= i_gearbox_do(1)(5); --A1
i_cl_rxd((7 * 0) + 2) <= i_gearbox_do(1)(4); --A2
i_cl_rxd((7 * 0) + 3) <= i_gearbox_do(1)(3); --A3
i_cl_rxd((7 * 0) + 4) <= i_gearbox_do(1)(2); --A4
i_cl_rxd((7 * 0) + 5) <= i_gearbox_do(1)(1); --A5
i_cl_rxd((7 * 0) + 6) <= i_gearbox_do(1)(0); --B0

--RxIN1
i_cl_rxd((7 * 1) + 0) <= i_gearbox_do(2)(6); --B1
i_cl_rxd((7 * 1) + 1) <= i_gearbox_do(2)(5); --B2
i_cl_rxd((7 * 1) + 2) <= i_gearbox_do(2)(4); --B3
i_cl_rxd((7 * 1) + 3) <= i_gearbox_do(2)(3); --B4
i_cl_rxd((7 * 1) + 4) <= i_gearbox_do(2)(2); --B5
i_cl_rxd((7 * 1) + 5) <= i_gearbox_do(2)(1); --C0
i_cl_rxd((7 * 1) + 6) <= i_gearbox_do(2)(0); --C1

--RxIN2
i_cl_rxd((7 * 2) + 0) <= i_gearbox_do(3)(6); --C2
i_cl_rxd((7 * 2) + 1) <= i_gearbox_do(3)(5); --C3
i_cl_rxd((7 * 2) + 2) <= i_gearbox_do(3)(4); --C4
i_cl_rxd((7 * 2) + 3) <= i_gearbox_do(3)(3); --C5
i_cl_rxd((7 * 2) + 4) <= i_gearbox_do(3)(2); --LVAL (Line Valid)
i_cl_rxd((7 * 2) + 5) <= i_gearbox_do(3)(1); --FVAL (Frame Valid)
i_cl_rxd((7 * 2) + 6) <= i_gearbox_do(3)(0); --DVAL (Data Valid)

--RxIN3
i_cl_rxd((7 * 3) + 0) <= i_gearbox_do(4)(6); --A6
i_cl_rxd((7 * 3) + 1) <= i_gearbox_do(4)(5); --A7
i_cl_rxd((7 * 3) + 2) <= i_gearbox_do(4)(4); --B6
i_cl_rxd((7 * 3) + 3) <= i_gearbox_do(4)(3); --B7
i_cl_rxd((7 * 3) + 4) <= i_gearbox_do(4)(2); --C6
i_cl_rxd((7 * 3) + 5) <= i_gearbox_do(4)(1); --C7
i_cl_rxd((7 * 3) + 6) <= i_gearbox_do(4)(0); --Reserv

end if;
end process;




--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_cl_clkin_7x_lock;
p_out_tst(1) <= i_err;
p_out_tst(2) <= i_idelay_oval(0)(3) or sr_serdes_do(0)(0);


process(g_cl_clkin_7xdiv7)
begin
if rising_edge(g_cl_clkin_7xdiv7) then
i_clx_sync_val <= i_gearbox_do(0);
end if;
end process;

i_dbg.det_sync <= i_sync_det;
i_dbg.tst_sync <= i_fsync_vld;
i_dbg.idelay_inc <= i_idelay_inc;
i_dbg.idelay_ce <= i_idelay_ce;
i_dbg.idelay_oval <= i_idelay_oval(0);

i_dbg.sr_serdes_d <= sr_serdes_do(0);
i_dbg.sr_reg(0) <= sr_reg(0);
i_dbg.sr_reg(1) <= sr_reg(1);
i_dbg.sr_reg(2) <= sr_reg(2);
i_dbg.sr_reg(3) <= sr_reg(3);
i_dbg.sr_reg(4) <= sr_reg(4);
i_dbg.sr_reg(5) <= sr_reg(5);
i_dbg.sr_reg(6) <= sr_reg(6);

i_dbg.clx_sync_val <= i_clx_sync_val;--i_gearbox_do(0);

i_dbg.clx_lval <= i_cl_rxd((7 * 2) + 4); --LVAL (Line Valid)
i_dbg.clx_fval <= i_cl_rxd((7 * 2) + 5); --FVAL (Frame Valid)

i_dbg.rxbyte(0)(0) <= i_cl_rxd((7 * 0) + 0); --A0
i_dbg.rxbyte(0)(1) <= i_cl_rxd((7 * 0) + 1); --A1
i_dbg.rxbyte(0)(2) <= i_cl_rxd((7 * 0) + 2); --A2
i_dbg.rxbyte(0)(3) <= i_cl_rxd((7 * 0) + 3); --A3
i_dbg.rxbyte(0)(4) <= i_cl_rxd((7 * 0) + 4); --A4
i_dbg.rxbyte(0)(5) <= i_cl_rxd((7 * 3) + 1); --A5
i_dbg.rxbyte(0)(6) <= i_cl_rxd((7 * 0) + 5); --A6
i_dbg.rxbyte(0)(7) <= i_cl_rxd((7 * 0) + 6); --A7

i_dbg.rxbyte(1)(0) <= i_cl_rxd((7 * 1) + 0); --B0
i_dbg.rxbyte(1)(1) <= i_cl_rxd((7 * 1) + 1); --B1
i_dbg.rxbyte(1)(2) <= i_cl_rxd((7 * 3) + 2); --B2
i_dbg.rxbyte(1)(3) <= i_cl_rxd((7 * 3) + 3); --B3
i_dbg.rxbyte(1)(4) <= i_cl_rxd((7 * 1) + 2); --B4
i_dbg.rxbyte(1)(5) <= i_cl_rxd((7 * 1) + 3); --B5
i_dbg.rxbyte(1)(6) <= i_cl_rxd((7 * 1) + 4); --B6
i_dbg.rxbyte(1)(7) <= i_cl_rxd((7 * 1) + 5); --B7

i_dbg.rxbyte(2)(0) <= i_cl_rxd((7 * 3) + 4); --C0
i_dbg.rxbyte(2)(1) <= i_cl_rxd((7 * 3) + 5); --C1
i_dbg.rxbyte(2)(2) <= i_cl_rxd((7 * 1) + 6); --C2
i_dbg.rxbyte(2)(3) <= i_cl_rxd((7 * 2) + 0); --C3
i_dbg.rxbyte(2)(4) <= i_cl_rxd((7 * 2) + 1); --C4
i_dbg.rxbyte(2)(5) <= i_cl_rxd((7 * 2) + 2); --C5
i_dbg.rxbyte(2)(6) <= i_cl_rxd((7 * 2) + 3); --C6
i_dbg.rxbyte(2)(7) <= i_cl_rxd((7 * 3) + 6); --C7


dbg_cl : ila_dbg_cl
port map(
clk => g_cl_clkin_7xdiv4,
probe0(0) => i_dbg.det_sync,
probe0(4 downto 1) => sr_serdes_do(0),
probe0(5) => i_dbg.idelay_inc,
probe0(6) => i_dbg.idelay_ce,
probe0(15 downto 7) => i_dbg.idelay_oval,
probe0(19 downto 16) => std_logic_vector(i_dbg.sr_reg(0)),
probe0(23 downto 20) => std_logic_vector(i_dbg.sr_reg(1)),
probe0(27 downto 24) => std_logic_vector(i_dbg.sr_reg(2)),
probe0(31 downto 28) => std_logic_vector(i_dbg.sr_reg(3)),
probe0(35 downto 32) => std_logic_vector(i_dbg.sr_reg(4)),
probe0(39 downto 36) => std_logic_vector(i_dbg.sr_reg(5)),
probe0(43 downto 40) => std_logic_vector(i_dbg.sr_reg(6)),

probe0(44) => i_dbg.tst_sync
);


dbg2_cl : ila_dbg2_cl
port map(
clk => g_cl_clkin_7xdiv7,
probe0(0) => i_dbg.tst_sync,
probe0(7 downto 1) => i_dbg.clx_sync_val,
probe0(8) => i_dbg.clx_lval,
probe0(9) => i_dbg.clx_fval,
probe0(17 downto 10) => i_dbg.rxbyte(0),
probe0(25 downto 18) => i_dbg.rxbyte(1),
probe0(33 downto 26) => i_dbg.rxbyte(2)
);



end architecture struct;
