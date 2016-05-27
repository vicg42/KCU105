-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cl_core
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
use work.vicg_common_pkg.all;
use work.cl_pkg.all;

entity cl_core is
generic(
G_CLKIN_PERIOD : real := 11.764000; --85MHz
G_DIVCLK_DIVIDE : natural := 1;
G_CLKFBOUT_MULT : natural := 2;
G_CLKOUT0_DIVIDE : natural := 2;
G_DCM_TYPE : natural := 0
);
port(
-----------------------------
--CameraLink (IN)
-----------------------------
p_in_cl_clk_p : in  std_logic;
p_in_cl_clk_n : in  std_logic;
p_in_cl_di_p  : in  std_logic_vector(3 downto 0);
p_in_cl_di_n  : in  std_logic_vector(3 downto 0);

-----------------------------
--RxData
-----------------------------
p_out_rxd     : out std_logic_vector(27 downto 0);
p_out_rxclk   : out std_logic;
p_out_link    : out std_logic;

-----------------------------
--DBG
-----------------------------
p_out_clk_synval : out  std_logic_vector(6 downto 0);
p_out_tst : out  std_logic;
p_in_tst  : in   std_logic;
p_out_dbg : out  TCL_core_dbg;

-----------------------------
--System
-----------------------------
p_in_idlyctrl_rdy  : in  std_logic;
p_out_idlyctrl_clk : out std_logic;
p_out_idlyctrl_rst : out std_logic;
p_out_plllock      : out std_logic;
p_in_rst           : in  std_logic
);
end entity cl_core;

architecture struct of cl_core is

component cl_mmcm is
generic(
G_CLKIN_PERIOD : real := 11.764000; --85MHz
G_DIVCLK_DIVIDE : natural := 1;
G_CLKFBOUT_MULT : natural := 2;
G_CLKOUT0_DIVIDE : natural := 2;
G_DCM_TYPE : natural := 0
);
port(
p_in_clk     : in  std_logic;
p_out_gclkx7 : out std_logic;
p_out_gdlyctrl: out std_logic;
p_in_rst     : in  std_logic;
p_out_locked : out std_logic
);
end component cl_mmcm;

component gearbox_4_to_7 is
generic (D : integer := 8); -- Set the number of inputs
port (
input_clock  :  in std_logic;       -- high speed clock input
output_clock :  in std_logic;       -- low speed clock input
datain       :  in std_logic_vector(D*4-1 downto 0) ;  -- data inputs
reset        :  in std_logic;       -- Reset line
jog          :  in std_logic;       -- jog input, slips by 4 bits
dataout      : out std_logic_vector(D*7-1 downto 0)   -- data outputs
);
end component;

type TFsm_sync is (
S_SYNC_IDLE,
S_SYNC_WAIT,
S_SYNC_LINK,
S_SYNC_ADJ,
S_SYNC_EDGE0_FIND,
S_SYNC_EDGE1_ADJ,
S_SYNC_EDGE1_FIND,
S_SYNC_EDGE1_STABLE,
S_SYNC_MID_ADJ,
S_SYNC_MID_FIND,
S_SYNC_MID_STABLE,
S_SYNC_STOP,
S_SYNC_ERR
);
signal i_fsm_sync     : TFsm_sync;

type TFsm_adj is (
S_ADJ_IDLE,
S_ADJ_0    ,
S_ADJ_1    ,
S_ADJ_2
);
signal i_fsm_adj      : TFsm_adj;


signal i_div_rst        : std_logic;
signal i_idelay_rst     : std_logic;
signal i_serdes_rst     : std_logic;
signal i_desr_ctrl_rst  : std_logic;
signal i_gearbox_rst    : std_logic := '1';
signal i_idlyctrl_rst   : std_logic;
signal sr_rst           : std_logic_vector(0 to 31);

signal g_idlyctrl_clk     : std_logic;
signal i_cl_clkin         : std_logic;
signal g_cl_clkin         : std_logic;
signal g_cl_clkin_7x, i_clk_7x : std_logic;
signal g_cl_clkin_7xdiv4  : std_logic;
signal g_cl_clkin_7xdiv7  : std_logic;
signal i_cl_clkin_7x_lock : std_logic;

type TCL_SerDesVALOUT is array (0 to 4) of std_logic_vector((9 * 1) - 1 downto 0);
type TCL_SerDesDOUT   is array (0 to 4) of std_logic_vector(7 downto 0);
type TCL_GearBoxDOUT  is array (0 to 4) of std_logic_vector(6 downto 0);
type TCL_DesData      is array (0 to 4) of std_logic_vector(3 downto 0);
signal i_cl_din         : std_logic_vector(4 downto 0);
signal i_idelay_do      : std_logic_vector(4 downto 0);
signal i_idelay_co      : std_logic_vector(4 downto 0);
signal i_idelay_oval    : TCL_SerDesVALOUT;
signal i_idelay_ce      : std_logic;
signal i_idelay_inc     : std_logic := '0';
signal i_idelay_vtc     : std_logic;
signal i_idelay_usrcnt  : unsigned(4 downto 0);
signal i_odelay_co      : std_logic_vector(4 downto 0);
signal i_serdes_do      : TCL_SerDesDOUT;
signal i_des_d          : TCL_DesData;
type TCL_SrDesData is array (0 to 5) of unsigned(3 downto 0);
signal sr_des_d         : TCL_SrDesData;
signal i_gearbox_do     : TCL_GearBoxDOUT;

signal i_adj_rq         : std_logic := '0';
signal i_adj_dir        : std_logic := '0';
signal i_usrcnt         : unsigned(8 downto 0);
signal i_sync_cnt       : unsigned(2 downto 0) := (others => '0');
signal i_sync_find      : std_logic := '0';
signal i_link           : std_logic;

signal i_cl_rxd        : std_logic_vector(27 downto 0);
signal i_cl_sync_val   : std_logic_vector(6 downto 0);
--signal i_sync_val      : std_logic_vector(6 downto 0);

signal i_btn           : std_logic;
signal sr_btn          : std_logic_vector(0 to 2);
signal i_btn_det       : std_logic;

signal i_edge1_stable  : std_logic := '0';
signal i_middle_stable : std_logic := '0';
signal i_edge1         : std_logic := '0';
signal i_middle        : std_logic := '0';
signal i_measure_cnt   : unsigned(8 downto 0);
signal i_measure_val   : unsigned(8 downto 0);
signal i_stop          : std_logic;

signal tst_fsm_sync    : unsigned(3 downto 0);
signal i_dbg           : TCL_core_dbg;

--component ila_dbg_cl_core is
--port (
--clk : in std_logic;
--probe0 : in std_logic_vector(73 downto 0)
--);
--end component ila_dbg_cl_core;


begin --architecture struct


--Set working clock
m_ibufds_clk : IBUFDS
port map (I => p_in_cl_clk_p, IB => p_in_cl_clk_n, O => i_cl_clkin);

m_bufg_clk : BUFG
port map (I => i_cl_clkin, O => g_cl_clkin);

m_dcm : cl_mmcm
generic map(
G_CLKIN_PERIOD => 11.764000, --85MHz
G_DIVCLK_DIVIDE => 1,
G_CLKFBOUT_MULT => 14,
G_CLKOUT0_DIVIDE => 2,
G_DCM_TYPE => G_DCM_TYPE
)
port map(
p_in_clk     => g_cl_clkin,
p_out_gclkx7 => i_clk_7x,
p_out_gdlyctrl=> g_idlyctrl_clk,
p_in_rst     => p_in_rst,
p_out_locked => i_cl_clkin_7x_lock
);

m_gclkx7 : BUFG port map(I => i_clk_7x, O => g_cl_clkin_7x);

m_clkx7div4 : BUFGCE_DIV
generic map (
IS_CLR_INVERTED => '1',
BUFGCE_DIVIDE => 4
)
port map (
I => i_clk_7x,
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
I => i_clk_7x,
O => g_cl_clkin_7xdiv7,
CE => '1',
CLR => i_div_rst
);


--reset ctrl
process(g_cl_clkin_7xdiv4)
begin
if rising_edge(g_cl_clkin_7xdiv4) then
  sr_rst <= i_cl_clkin_7x_lock & sr_rst(0 to (sr_rst'high - 1));
end if;
end process;

i_div_rst       <= i_cl_clkin_7x_lock;
i_idelay_rst    <= sr_rst(7)       and i_cl_clkin_7x_lock ;
i_serdes_rst    <= sr_rst(15)      and i_cl_clkin_7x_lock ;
i_idlyctrl_rst  <= not (sr_rst(23) and i_cl_clkin_7x_lock);
i_desr_ctrl_rst <= sr_rst(31)      and i_cl_clkin_7x_lock ;


--Set signal for deserialization
i_cl_din(0) <= i_cl_clkin;--!!!!!!!
gen_ch : for i in 0 to 3 generate
begin
m_ibufds : IBUFDS
port map (I => p_in_cl_di_p(i), IB => p_in_cl_di_n(i), O => i_cl_din(i + 1));
end generate gen_ch;


--Deserialization
gen_deser : for i in 0 to 4 generate
begin
--85MHz * 7 = 595MHz
m_idelay : IDELAYE3
generic map (
CASCADE => "MASTER",        -- Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
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
IDATAIN     => i_cl_din(i),    -- 1-bit input: Data input from the IOBUF
DATAOUT     => i_idelay_do(i), -- 1-bit output: Delayed data output

CASC_IN     => '0'        , -- 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
CASC_RETURN => i_odelay_co(i), -- 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
CASC_OUT    => i_idelay_co(i), -- 1-bit output: Cascade delay output to ODELAY input cascade
CNTVALUEOUT => i_idelay_oval(i)((9 * 1) - 1 downto (9 * 0)) , -- 9-bit output: Counter value output
EN_VTC      => i_idelay_vtc  , -- 1-bit input: Keep delay constant over VT

CNTVALUEIN  => "000000000" , -- 9-bit input: Counter value input
LOAD        => '0',          -- 1-bit input: Load DELAY_VALUE input
CE          => i_idelay_ce,  -- 1-bit input: Active high enable increment/decrement input
INC         => i_idelay_inc, -- 1-bit input: Increment / Decrement tap delay input
CLK         => g_cl_clkin_7xdiv4, -- 1-bit input: Clock input

RST         => i_idelay_rst
);

m_odelay : ODELAYE3
generic map (
CASCADE => "SLAVE_END",     -- Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
DELAY_FORMAT => "COUNT",    -- (COUNT, TIME)
DELAY_TYPE => "VARIABLE",   -- Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
DELAY_VALUE => 80,         -- Output delay tap setting
IS_CLK_INVERTED => '0',     -- Optional inversion for CLK
IS_RST_INVERTED => '1',     -- Optional inversion for RST
REFCLK_FREQUENCY => 300.0,  -- IDELAYCTRL clock input frequency in MHz (200.0-2400.0).
SIM_DEVICE => "ULTRASCALE", -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS_ES1)
UPDATE_MODE => "ASYNC"      -- Determines when updates to the delay will take effect (ASYNC, MANUAL,
                            -- SYNC)
)
port map (
ODATAIN => '0',             -- 1-bit input: Data input
DATAOUT => i_odelay_co(i),  -- 1-bit output: Delayed data from ODATAIN input port

CASC_IN => i_idelay_co(i),  -- 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
CASC_RETURN => '0',         -- 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
CASC_OUT => open, -- 1-bit output: Cascade delay output to IDELAY input cascade
CNTVALUEOUT => open,        -- 9-bit output: Counter value output
EN_VTC => i_idelay_vtc,     -- 1-bit input: Keep delay constant over VT

CNTVALUEIN => "000000000",  -- 9-bit input: Counter value input
LOAD => '0',                -- 1-bit input: Load DELAY_VALUE input
CE => i_idelay_ce,          -- 1-bit input: Active high enable increment/decrement input
INC => i_idelay_inc,        -- 1-bit input: Increment/Decrement tap delay input
CLK => g_cl_clkin_7xdiv4,   -- 1-bit input: Clock input

RST => i_idelay_rst         -- 1-bit input: Asynchronous Reset to the DELAY_VALUE
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
CLK   => g_cl_clkin_7x , -- 1-bit input: High-speed clock
CLK_B => g_cl_clkin_7x , -- 1-bit input: Inversion of High-speed clock CLK

Q      => i_serdes_do(i), -- 8-bit registered output
CLKDIV => g_cl_clkin_7xdiv4 , -- 1-bit input: Divided Clock

FIFO_RD_EN  => '0' ,    -- 1-bit input: Enables reading the FIFO when asserted
FIFO_RD_CLK => '0' ,    -- 1-bit input: FIFO read clock
FIFO_EMPTY  => open,    -- 1-bit output: FIFO empty flag

RST => i_serdes_rst
);

--Deserialization 1 -> 4
--process(g_cl_clkin_7xdiv4)
--begin
--if rising_edge(g_cl_clkin_7xdiv4) then
i_des_d(i)(0) <= i_serdes_do(i)(0);
i_des_d(i)(1) <= i_serdes_do(i)(2);
i_des_d(i)(2) <= i_serdes_do(i)(4);
i_des_d(i)(3) <= i_serdes_do(i)(6);
--end if;
--end process;

--4bit -> 7bit
m_gbox : gearbox_4_to_7
generic map(D => 1)
port map(
datain       => i_des_d(i),
input_clock  => g_cl_clkin_7xdiv4,

dataout      => i_gearbox_do(i),
output_clock => g_cl_clkin_7xdiv7,

jog          => '0',
reset        => i_gearbox_rst
);

end generate gen_deser;


process(i_desr_ctrl_rst, g_cl_clkin_7xdiv4)
begin
if (i_desr_ctrl_rst = '0') then

    i_fsm_adj <= S_ADJ_IDLE;

    i_idelay_ce <= '0';
    i_idelay_inc <= '0';
    i_idelay_vtc <= '0'; --only for DELAY_FORMAT -"COUNT" of IDELAYE3
    --i_idelay_vtc <= '1'; --only for DELAY_FORMAT -"TIME" of IDELAYE3
    i_idelay_usrcnt <= (others => '0');

elsif rising_edge(g_cl_clkin_7xdiv4) then

    case i_fsm_adj is

      when S_ADJ_IDLE =>

        if (i_adj_rq = '1') then
          i_idelay_vtc <= '0';
          i_fsm_adj <= S_ADJ_0;
        end if;

      when S_ADJ_0 =>

        if (i_idelay_usrcnt(4) = '1') then --16clk
          i_idelay_usrcnt <= (others => '0');
          i_idelay_ce <= '1';
          i_idelay_inc <= i_adj_dir; --1/0 - increment/decrement
          i_fsm_adj <= S_ADJ_1;
        else
          i_idelay_vtc <= '0';
          i_idelay_usrcnt <= i_idelay_usrcnt + 1;
        end if;

      when S_ADJ_1 =>

        i_idelay_ce <= '0';

        if (i_idelay_usrcnt(0) = '1') then --2clk
          i_idelay_usrcnt <= (others => '0');
          i_idelay_inc <= '0';
          i_fsm_adj <= S_ADJ_2;
        else
          i_idelay_usrcnt <= i_idelay_usrcnt + 1;
        end if;

      when S_ADJ_2 =>

        if (i_idelay_usrcnt(4) = '1') then --16clk
          i_idelay_usrcnt <= (others => '0');
          i_idelay_vtc <= '0'; --only for DELAY_FORMAT -"COUNT" of IDELAYE3
--          i_idelay_vtc <= '1'; --only for DELAY_FORMAT -"TIME" of IDELAYE3
          i_fsm_adj <= S_ADJ_IDLE;
        else
          i_idelay_usrcnt <= i_idelay_usrcnt + 1;
        end if;

    end case;

end if;
end process;

--find synch
process(g_cl_clkin_7xdiv4)
begin
if rising_edge(g_cl_clkin_7xdiv4) then

--  i_sync_val <= i_gearbox_do(0);

  sr_des_d <= UNSIGNED(i_des_d(0)) & sr_des_d(0 to (sr_des_d'high - 1));

  if (  (UNSIGNED(i_des_d(0)) = (TO_UNSIGNED(16#8#, i_des_d(0)'length)))
              and (sr_des_d(0) = (TO_UNSIGNED(16#F#, sr_des_d(0)'length)))
                and (sr_des_d(1) = (TO_UNSIGNED(16#1#, sr_des_d(0)'length)))
                  and (sr_des_d(2) = (TO_UNSIGNED(16#E#, sr_des_d(0)'length)))
                    and (sr_des_d(3) = (TO_UNSIGNED(16#3#, sr_des_d(0)'length)))
                      and (sr_des_d(4) = (TO_UNSIGNED(16#C#, sr_des_d(0)'length)))
                        and (sr_des_d(5) = (TO_UNSIGNED(16#7#, sr_des_d(0)'length))) ) then

    i_sync_find <= '1';
  else
    i_sync_find <= '0';
  end if;


  if (i_sync_find = '1')
      or (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then

    i_sync_cnt <= (others => '0');
  else
    i_sync_cnt <= i_sync_cnt + 1;
  end if;

end if;
end process;


--         edge0         middle         edge1
--   ________ ___________________________ ________
--   ________X___________________________X________
--

process(i_desr_ctrl_rst, g_cl_clkin_7xdiv4)
begin
if (i_desr_ctrl_rst = '0') then

    i_fsm_sync <= S_SYNC_IDLE;

    i_adj_rq <= '0';
    i_adj_dir <= '0';

    i_usrcnt <= (others => '0');
    i_measure_cnt <= (others => '0');
    i_measure_val <= (others => '0');
    i_link <= '0';

    i_gearbox_rst <= '1';

    i_edge1 <= '0'; i_edge1_stable <= '0';
    i_middle <= '0'; i_middle_stable <= '0';

    i_btn_det <= '0';
    i_stop <= '0';

elsif rising_edge(g_cl_clkin_7xdiv4) then

    case i_fsm_sync is

      when S_SYNC_IDLE =>

--        if (i_btn = '1') then
          if (p_in_idlyctrl_rdy = '1') then
            i_fsm_sync <= S_SYNC_WAIT;
          end if;
--        end if;


      when S_SYNC_WAIT =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '1') then
            if (i_usrcnt = (i_usrcnt'range => '1') ) then
              i_usrcnt <= (others => '0');
              i_gearbox_rst <= '0';
              i_fsm_sync <= S_SYNC_LINK;
            else
              i_usrcnt <= i_usrcnt + 1;
            end if;
          else
            i_usrcnt <= (others => '0');
            i_fsm_sync <= S_SYNC_ADJ;
          end if;
        end if;


      when S_SYNC_LINK =>

--        if (i_btn = '1') then
--          i_btn_det <= '1';
--        end if;

        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '1') then
--            if (i_btn_det = '1') then
            i_fsm_sync <= S_SYNC_ADJ;
--            end if;
          else
            i_fsm_sync <= S_SYNC_WAIT;
          end if;
        end if;


      --###############################
      --IDELAY ADJUST
      --###############################
      when S_SYNC_ADJ =>

        if (i_fsm_adj = S_ADJ_IDLE) then
          i_adj_rq <= '1';
          if (i_gearbox_rst = '1') then
            i_adj_dir <= '1';
            i_fsm_sync <= S_SYNC_WAIT;
          else
            i_adj_dir <= '0';
            i_fsm_sync <= S_SYNC_EDGE0_FIND;
          end if;
        end if;


      when S_SYNC_EDGE0_FIND =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '0') then
            i_fsm_sync <= S_SYNC_STOP;
            i_edge1 <= '1';
          else
            if (i_fsm_adj = S_ADJ_IDLE) then
              i_fsm_sync <= S_SYNC_ADJ;
            end if;
          end if;
        end if;



      --#############################
      --
      --#############################
      when S_SYNC_EDGE1_FIND =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '0') then
--            i_stop <= '1';
            i_middle <= '1';
            i_measure_val <= i_measure_cnt;
            i_fsm_sync <= S_SYNC_STOP;
          else
            if (i_fsm_adj = S_ADJ_IDLE) then
              i_fsm_sync <= S_SYNC_EDGE1_ADJ;
            end if;
          end if;
        end if;

      when S_SYNC_EDGE1_STABLE =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '1') then
            if (i_usrcnt = (i_usrcnt'range => '1') ) then
              i_usrcnt <= (others => '0');
              i_edge1_stable <= '1';
              i_fsm_sync <= S_SYNC_EDGE1_ADJ;
            else
              i_usrcnt <= i_usrcnt + 1;
            end if;
          else
            i_usrcnt <= (others => '0');
            i_fsm_sync <= S_SYNC_EDGE1_ADJ;
          end if;
        end if;

      when S_SYNC_EDGE1_ADJ =>

        if (i_fsm_adj = S_ADJ_IDLE) then
          i_adj_rq <= '1';
          i_adj_dir <= '1';
          if (i_edge1_stable = '1') then
            i_measure_cnt <= i_measure_cnt + 1;
            i_fsm_sync <= S_SYNC_EDGE1_FIND;
          else
            i_fsm_sync <= S_SYNC_EDGE1_STABLE;
          end if;
        end if;


      --#############################
      --
      --#############################
      when S_SYNC_MID_FIND =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '1') then
            if (i_measure_cnt = ('0' & i_measure_val(i_measure_val'high downto 1)) ) then
              i_stop <= '1';
              i_fsm_sync <= S_SYNC_STOP;
            else
              i_fsm_sync <= S_SYNC_MID_ADJ;
            end if;
          end if;
        end if;

      when S_SYNC_MID_STABLE =>

        i_adj_rq <= '0';
        if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
          if (i_sync_find = '1') then
            if (i_usrcnt = (i_usrcnt'range => '1') ) then
              i_usrcnt <= (others => '0');
              i_middle_stable <= '1';
              i_fsm_sync <= S_SYNC_MID_ADJ;
            else
              i_usrcnt <= i_usrcnt + 1;
            end if;
          else
            i_usrcnt <= (others => '0');
            i_fsm_sync <= S_SYNC_MID_ADJ;
          end if;
        end if;

      when S_SYNC_MID_ADJ =>

        if (i_fsm_adj = S_ADJ_IDLE) then
          i_adj_rq <= '1';
          i_adj_dir <= '0';
--          i_measure_cnt <= i_measure_cnt - 1;
          if (i_middle_stable = '1') then
          i_measure_cnt <= i_measure_cnt - 1;
          i_fsm_sync <= S_SYNC_MID_FIND;
          else
          i_fsm_sync <= S_SYNC_MID_STABLE;
          end if;
        end if;


      --#############################
      --
      --#############################
      when S_SYNC_STOP =>

        if (i_stop = '1') then
            if (i_sync_cnt = TO_UNSIGNED(6, i_sync_cnt'length)) then
              if (i_sync_find = '1') then
                i_link <= '1';
                i_fsm_sync <= S_SYNC_STOP;
              else
                i_link <= '0';
                i_fsm_sync <= S_SYNC_ERR;
              end if;
            end if;

        elsif (i_middle = '1') then
          i_fsm_sync <= S_SYNC_MID_ADJ;

        elsif (i_edge1 = '1') then
          i_fsm_sync <= S_SYNC_EDGE1_ADJ;

        end if;

      when S_SYNC_ERR =>

          i_link <= '0';

    end case;

end if;
end process;





--dout Register
--process(g_cl_clkin_7xdiv7)
--begin
--if rising_edge(g_cl_clkin_7xdiv7) then

i_cl_sync_val <= i_gearbox_do(0);

--RxIN0
i_cl_rxd((7 * 0) + 0) <= i_gearbox_do(1)(6);
i_cl_rxd((7 * 0) + 1) <= i_gearbox_do(1)(5);
i_cl_rxd((7 * 0) + 2) <= i_gearbox_do(1)(4);
i_cl_rxd((7 * 0) + 3) <= i_gearbox_do(1)(3);
i_cl_rxd((7 * 0) + 4) <= i_gearbox_do(1)(2);
i_cl_rxd((7 * 0) + 5) <= i_gearbox_do(1)(1);
i_cl_rxd((7 * 0) + 6) <= i_gearbox_do(1)(0);

--RxIN1
i_cl_rxd((7 * 1) + 0) <= i_gearbox_do(2)(6);
i_cl_rxd((7 * 1) + 1) <= i_gearbox_do(2)(5);
i_cl_rxd((7 * 1) + 2) <= i_gearbox_do(2)(4);
i_cl_rxd((7 * 1) + 3) <= i_gearbox_do(2)(3);
i_cl_rxd((7 * 1) + 4) <= i_gearbox_do(2)(2);
i_cl_rxd((7 * 1) + 5) <= i_gearbox_do(2)(1);
i_cl_rxd((7 * 1) + 6) <= i_gearbox_do(2)(0);

--RxIN2
i_cl_rxd((7 * 2) + 0) <= i_gearbox_do(3)(6);
i_cl_rxd((7 * 2) + 1) <= i_gearbox_do(3)(5);
i_cl_rxd((7 * 2) + 2) <= i_gearbox_do(3)(4);
i_cl_rxd((7 * 2) + 3) <= i_gearbox_do(3)(3);
i_cl_rxd((7 * 2) + 4) <= i_gearbox_do(3)(2);
i_cl_rxd((7 * 2) + 5) <= i_gearbox_do(3)(1);
i_cl_rxd((7 * 2) + 6) <= i_gearbox_do(3)(0);

--RxIN3
i_cl_rxd((7 * 3) + 0) <= i_gearbox_do(4)(6);
i_cl_rxd((7 * 3) + 1) <= i_gearbox_do(4)(5);
i_cl_rxd((7 * 3) + 2) <= i_gearbox_do(4)(4);
i_cl_rxd((7 * 3) + 3) <= i_gearbox_do(4)(3);
i_cl_rxd((7 * 3) + 4) <= i_gearbox_do(4)(2);
i_cl_rxd((7 * 3) + 5) <= i_gearbox_do(4)(1);
i_cl_rxd((7 * 3) + 6) <= i_gearbox_do(4)(0);

--end if;
--end process;

p_out_rxd <= i_cl_rxd;

p_out_rxclk <= g_cl_clkin_7xdiv7;
p_out_link <= i_link;
p_out_plllock <= i_cl_clkin_7x_lock;

p_out_idlyctrl_clk <= g_idlyctrl_clk;
p_out_idlyctrl_rst <= i_idlyctrl_rst;

p_out_clk_synval <= i_cl_sync_val;




--#########################################
--DBG
--#########################################
p_out_tst <= g_cl_clkin_7xdiv4;

process(g_cl_clkin_7xdiv4)
begin
if rising_edge(g_cl_clkin_7xdiv4) then
  if (i_desr_ctrl_rst = '0') then
    sr_btn <= (others => '0');
    i_btn <= '0';
  else
    sr_btn <= p_in_tst & sr_btn(0 to 1);
    i_btn <= sr_btn(1) and (not sr_btn(2));
  end if;
end if;
end process;


p_out_dbg <= i_dbg;

tst_fsm_sync <= TO_UNSIGNED(16#01#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_LINK         else
                TO_UNSIGNED(16#02#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_ADJ          else
                TO_UNSIGNED(16#03#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_EDGE0_FIND   else
                TO_UNSIGNED(16#04#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_IDLE         else
                TO_UNSIGNED(16#05#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_STOP         else
                TO_UNSIGNED(16#06#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_EDGE1_ADJ    else
                TO_UNSIGNED(16#07#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_EDGE1_FIND   else
                TO_UNSIGNED(16#08#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_EDGE1_STABLE else
                TO_UNSIGNED(16#09#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_MID_ADJ      else
                TO_UNSIGNED(16#0A#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_MID_FIND     else
                TO_UNSIGNED(16#0B#, tst_fsm_sync'length) when i_fsm_sync = S_SYNC_MID_STABLE   else
                TO_UNSIGNED(16#00#, tst_fsm_sync'length); --i_fsm_fgwr = S_SYNC_WAIT        else


i_dbg.fsm_sync <= std_logic_vector(tst_fsm_sync);

i_dbg.sync_find <= i_sync_find;
i_dbg.gearbox_rst <= i_gearbox_rst;
i_dbg.idelay_inc <= i_idelay_inc;
i_dbg.idelay_ce <= i_idelay_ce;
i_dbg.idelay_vtc <= i_idelay_vtc;
i_dbg.idelay_oval <= i_idelay_oval(0);
i_dbg.link <= i_link;
i_dbg.sr_des_d(0) <= UNSIGNED(i_des_d(0));
i_dbg.sr_des_d(1) <= sr_des_d(0);
i_dbg.sr_des_d(2) <= sr_des_d(1);
i_dbg.sr_des_d(3) <= sr_des_d(2);
i_dbg.sr_des_d(4) <= sr_des_d(3);
i_dbg.sr_des_d(5) <= sr_des_d(4);
i_dbg.sr_des_d(6) <= sr_des_d(5);

i_dbg.sync_val <= (others => '0');--i_sync_val;

i_dbg.sync_cnt(2 downto 0) <= std_logic_vector(i_sync_cnt);
i_dbg.usrcnt(7 downto 0) <= std_logic_vector(i_usrcnt(7 downto 0));
i_dbg.middle_stable <= i_middle_stable;
i_dbg.measure_cnt <= std_logic_vector(i_measure_cnt);

--
--dbg_cl_core : ila_dbg_cl_core
--port map(
--clk                  => g_cl_clkin_7xdiv4,
--probe0(0)            => i_dbg.sync_find,
--probe0(1)            => i_dbg.gearbox_rst,
--probe0(5 downto 2)   => std_logic_vector(i_dbg.sr_des_d(0)),
--probe0(9 downto 6)   => std_logic_vector(i_dbg.sr_des_d(1)),
--probe0(13 downto 10) => std_logic_vector(i_dbg.sr_des_d(2)),
--probe0(17 downto 14) => std_logic_vector(i_dbg.sr_des_d(3)),
--probe0(21 downto 18) => std_logic_vector(i_dbg.sr_des_d(4)),
--probe0(25 downto 22) => std_logic_vector(i_dbg.sr_des_d(5)),
--probe0(29 downto 26) => std_logic_vector(i_dbg.sr_des_d(6)),
--probe0(38 downto 30) => i_dbg.idelay_oval,
--probe0(39)           => i_dbg.idelay_inc,
--probe0(40)           => i_dbg.idelay_ce,
--probe0(41)           => i_dbg.idelay_vtc,
--probe0(42)           => i_dbg.link,
--probe0(46 downto 43) => i_dbg.fsm_sync,
--probe0(53 downto 47) => i_dbg.sync_val,
--probe0(56 downto 54) => i_dbg.sync_cnt,
--probe0(64 downto 57) => i_dbg.usrcnt,
--probe0(73 downto 65) => i_dbg.measure_cnt
--);



end architecture struct;
