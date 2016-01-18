-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 14.01.2016 12:23:42
-- Module Name : cl_mmcm
--
-- Description : p_out_gclkx7 = p_in_clk x 7
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.cl_pkg.all;

entity cl_mmcm is
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
p_in_rst     : in  std_logic;
p_out_locked : out std_logic
);
end entity cl_mmcm;

architecture behavioral of cl_mmcm is

signal i_clkx7 : std_logic;
signal i_clkfbi: std_logic;
signal i_clkfbo: std_logic;


begin --architecture behavioral

m_bufg_out : BUFG port map(I => i_clkx7, O => p_out_gclkx7);

gen_pll : if (G_DCM_TYPE = C_CL_PLL) generate begin
--PLL_FVCO = 600...1335 !!!
m_plle3_adv : PLLE3_ADV
generic map (
CLKFBOUT_MULT => G_CLKFBOUT_MULT,         -- Multiply value for all CLKOUT, (1-19)
CLKFBOUT_PHASE => 0.0,      -- Phase offset in degrees of CLKFB, (-360.000-360.000)
CLKIN_PERIOD => G_CLKIN_PERIOD,        -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
-- CLKOUT0 Attributes: Divide, Phase and Duty Cycle for the CLKOUT0 output
CLKOUT0_DIVIDE => G_CLKOUT0_DIVIDE,        -- Divide amount for CLKOUT0 (1-128)
CLKOUT0_DUTY_CYCLE => 0.5,  -- Duty cycle for CLKOUT0 (0.001-0.999)
CLKOUT0_PHASE => 0.0,       -- Phase offset for CLKOUT0 (-360.000-360.000)
-- CLKOUT1 Attributes: Divide, Phase and Duty Cycle for the CLKOUT1 output
CLKOUT1_DIVIDE => 1,        -- Divide amount for CLKOUT1 (1-128)
CLKOUT1_DUTY_CYCLE => 0.5,  -- Duty cycle for CLKOUT1 (0.001-0.999)
CLKOUT1_PHASE => 0.0,       -- Phase offset for CLKOUT1 (-360.000-360.000)
CLKOUTPHY_MODE => "VCO_2X", -- Frequency of the CLKOUTPHY (VCO, VCO_2X, VCO_HALF)
COMPENSATION => "AUTO",     -- AUTO, BUF_IN, INTERNAL
DIVCLK_DIVIDE => G_DIVCLK_DIVIDE,         -- Master division value, (1-15)
-- Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
IS_CLKFBIN_INVERTED => '0', -- Optional inversion for CLKFBIN
IS_CLKIN_INVERTED => '0',   -- Optional inversion for CLKIN
IS_PWRDWN_INVERTED => '0',  -- Optional inversion for PWRDWN
IS_RST_INVERTED => '0',     -- Optional inversion for RST
REF_JITTER => 0.0,          -- Reference input jitter in UI (0.000-0.999)
STARTUP_WAIT => "FALSE"     -- Delays DONE until PLL is locked (FALSE, TRUE)
)
port map (
-- Clock Outputs outputs: User configurable clock outputs
CLKOUT0 => i_clkx7,         -- 1-bit output: General Clock output
CLKOUT0B => open,       -- 1-bit output: Inverted CLKOUT0
CLKOUT1 => open,         -- 1-bit output: General Clock output
CLKOUT1B => open,       -- 1-bit output: Inverted CLKOUT1
CLKOUTPHY => open,     -- 1-bit output: Bitslice clock
-- DRP Ports outputs: Dynamic reconfiguration ports
DO => open,                   -- 16-bit output: DRP data
DRDY => open,               -- 1-bit output: DRP ready
-- Feedback Clocks outputs: Clock feedback ports
CLKFBOUT => i_clkfbo,       -- 1-bit output: Feedback clock
LOCKED => p_out_locked,           -- 1-bit output: LOCK
CLKIN => p_in_clk,             -- 1-bit input: Input clock
-- Control Ports inputs: PLL control ports
CLKOUTPHYEN => '0', -- 1-bit input: CLKOUTPHY enable
PWRDWN => '0',           -- 1-bit input: Power-down
RST => p_in_rst,                 -- 1-bit input: Reset
-- DRP Ports inputs: Dynamic reconfiguration ports
DADDR => "0000000",             -- 7-bit input: DRP address
DCLK => '0',               -- 1-bit input: DRP clock
DEN => '0',                 -- 1-bit input: DRP enable
DI => "0000000000000000",                   -- 16-bit input: DRP data
DWE => '0',                 -- 1-bit input: DRP write enable
-- Feedback Clocks inputs: Clock feedback ports
CLKFBIN => i_clkfbi          -- 1-bit input: Feedback clock
);

i_clkfbi <= i_clkfbo;
end generate gen_pll;


gen_mmcm : if (G_DCM_TYPE = C_CL_MMCM) generate begin
--MMCM_FVCO = 600...1440 !!!
mmcme3_adv_inst: unisim.vcomponents.MMCME3_ADV
generic map (
BANDWIDTH => "OPTIMIZED",        -- Jitter programming (HIGH, LOW, OPTIMIZED)
CLKFBOUT_MULT_F => real(G_CLKFBOUT_MULT),          -- Multiply value for all CLKOUT (2.000-64.000)
CLKFBOUT_PHASE => 0.0,           -- Phase offset in degrees of CLKFB (-360.000-360.000)
-- CLKIN_PERIOD: Input clock period in ns units, ps resolution (i.e. 33.333 is 30 MHz).
CLKIN1_PERIOD => G_CLKIN_PERIOD,
CLKIN2_PERIOD => 0.0,
CLKOUT0_DIVIDE_F => 1.0,         -- Divide amount for CLKOUT0 (1.000-128.000)
-- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
CLKOUT0_DUTY_CYCLE => 0.5,
CLKOUT1_DUTY_CYCLE => 0.5,
CLKOUT2_DUTY_CYCLE => 0.5,
CLKOUT3_DUTY_CYCLE => 0.5,
CLKOUT4_DUTY_CYCLE => 0.5,
CLKOUT5_DUTY_CYCLE => 0.5,
CLKOUT6_DUTY_CYCLE => 0.5,
-- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
CLKOUT0_PHASE => 0.0,
CLKOUT1_PHASE => 0.0,
CLKOUT2_PHASE => 0.0,
CLKOUT3_PHASE => 0.0,
CLKOUT4_PHASE => 0.0,
CLKOUT5_PHASE => 0.0,
CLKOUT6_PHASE => 0.0,
-- CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
CLKOUT1_DIVIDE => G_CLKOUT0_DIVIDE,
CLKOUT2_DIVIDE => 1,
CLKOUT3_DIVIDE => 1,
CLKOUT4_CASCADE => "FALSE",
CLKOUT4_DIVIDE => 1,
CLKOUT5_DIVIDE => 1,
CLKOUT6_DIVIDE => 1,
COMPENSATION => "AUTO",          -- AUTO, BUF_IN, EXTERNAL, INTERNAL, ZHOLD
DIVCLK_DIVIDE => G_DIVCLK_DIVIDE,              -- Master division value (1-106)
-- Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
IS_CLKFBIN_INVERTED => '0',      -- Optional inversion for CLKFBIN
IS_CLKIN1_INVERTED => '0',       -- Optional inversion for CLKIN1
IS_CLKIN2_INVERTED => '0',       -- Optional inversion for CLKIN2
IS_CLKINSEL_INVERTED => '0',     -- Optional inversion for CLKINSEL
IS_PSEN_INVERTED => '0',         -- Optional inversion for PSEN
IS_PSINCDEC_INVERTED => '0',     -- Optional inversion for PSINCDEC
IS_PWRDWN_INVERTED => '0',       -- Optional inversion for PWRDWN
IS_RST_INVERTED => '0',          -- Optional inversion for RST
-- REF_JITTER: Reference input jitter in UI (0.000-0.999).
REF_JITTER1 => 0.0,
REF_JITTER2 => 0.0,
STARTUP_WAIT => "FALSE",         -- Delays DONE until MMCM is locked (FALSE, TRUE)
-- Spread Spectrum: Spread Spectrum Attributes
SS_EN => "FALSE",                -- Enables spread spectrum (FALSE, TRUE)
SS_MODE => "CENTER_HIGH",        -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
SS_MOD_PERIOD => 10000,          -- Spread spectrum modulation period (ns) (4000-40000)
-- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
CLKFBOUT_USE_FINE_PS => "FALSE",
CLKOUT0_USE_FINE_PS => "FALSE",
CLKOUT1_USE_FINE_PS => "FALSE",
CLKOUT2_USE_FINE_PS => "FALSE",
CLKOUT3_USE_FINE_PS => "FALSE",
CLKOUT4_USE_FINE_PS => "FALSE",
CLKOUT5_USE_FINE_PS => "FALSE",
CLKOUT6_USE_FINE_PS => "FALSE"
)
port map (
-- Clock Outputs outputs: User configurable clock outputs
CLKOUT0 => open,           -- 1-bit output: CLKOUT0
CLKOUT0B => open,         -- 1-bit output: Inverted CLKOUT0
CLKOUT1 => i_clkx7,           -- 1-bit output: Primary clock
CLKOUT1B => open,         -- 1-bit output: Inverted CLKOUT1
CLKOUT2 => open,           -- 1-bit output: CLKOUT2
CLKOUT2B => open,         -- 1-bit output: Inverted CLKOUT2
CLKOUT3 => open,           -- 1-bit output: CLKOUT3
CLKOUT3B => open,         -- 1-bit output: Inverted CLKOUT3
CLKOUT4 => open,           -- 1-bit output: CLKOUT4
CLKOUT5 => open,           -- 1-bit output: CLKOUT5
CLKOUT6 => open,           -- 1-bit output: CLKOUT6
-- DRP Ports outputs: Dynamic reconfiguration ports
DO => open,                     -- 16-bit output: DRP data
DRDY => open,                 -- 1-bit output: DRP ready
-- Dynamic Phase Shift Ports outputs: Ports used for dynamic phase shifting of the outputs
PSDONE => open,             -- 1-bit output: Phase shift done
-- Feedback outputs: Clock feedback ports
CLKFBOUT => i_clkfbo,         -- 1-bit output: Feedback clock
CLKFBOUTB => open,       -- 1-bit output: Inverted CLKFBOUT
-- Status Ports outputs: MMCM status ports
CDDCDONE => open,         -- 1-bit output: Clock dynamic divide done
CLKFBSTOPPED => open, -- 1-bit output: Feedback clock stopped
CLKINSTOPPED => open, -- 1-bit output: Input clock stopped
LOCKED => p_out_locked,             -- 1-bit output: LOCK
CDDCREQ => '0',           -- 1-bit input: Request to dynamic divide clock
-- Clock Inputs inputs: Clock inputs
CLKIN1 => p_in_clk,             -- 1-bit input: Primary clock
CLKIN2 => '0',             -- 1-bit input: Secondary clock
-- Control Ports inputs: MMCM control ports
CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
PWRDWN => '0',             -- 1-bit input: Power-down
RST => p_in_rst,                   -- 1-bit input: Reset
-- DRP Ports inputs: Dynamic reconfiguration ports
DADDR => "0000000",               -- 7-bit input: DRP address
DCLK => '0',                 -- 1-bit input: DRP clock
DEN => '0',                   -- 1-bit input: DRP enable
DI => "0000000000000000",                     -- 16-bit input: DRP data
DWE => '0',                   -- 1-bit input: DRP write enable
-- Dynamic Phase Shift Ports inputs: Ports used for dynamic phase shifting of the outputs
PSCLK => '0',               -- 1-bit input: Phase shift clock
PSEN => '0',                 -- 1-bit input: Phase shift enable
PSINCDEC => '0',         -- 1-bit input: Phase shift increment/decrement
-- Feedback inputs: Clock feedback ports
CLKFBIN => i_clkfbi            -- 1-bit input: Feedback clock
);

i_clkfbi <= i_clkfbo;
end generate gen_mmcm;


end architecture behavioral;
