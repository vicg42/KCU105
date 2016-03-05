-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 22.07.2012 11:10:51
-- Module Name : cl_main
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cl_pkg.all;

entity cl_main is
generic(
G_DCM_TYPE : TCL_DCM_TYPE_ARRAY := (C_CL_PLL, --type dcm for chanal 3
                                    C_CL_PLL, --type dcm for chanal 2
                                    C_CL_MMCM --type dcm for chanal 1
                                   );
G_DCM_CLKIN_PERIOD : real := 11.764000; --85MHz => clkx7 = ((85/1)*14)/2 = 1190/2 = 595MHz
G_DCM_DIVCLK_DIVIDE : natural := 1;
G_DCM_CLKFBOUT_MULT : natural := 14;
G_DCM_CLKOUT0_DIVIDE : natural := 2;
G_CL_PIXBIT : natural := 8; --Amount bit per 1 pix
G_CL_TAP : natural := 8; --Amount pixel per 1 clk
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_plllock: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cl_main;

architecture behavior of cl_main is

constant CI_CLK_PERIOD : TIME := 11.765 ns; --85MHz

type TFsm is (
S_VSYNC,
S_HSYNC,
S_PIX
);
signal i_fsm     : TFsm;

signal i_rst     : std_logic;
signal i_clk     : std_logic;
signal i_pixval  : unsigned(15 downto 0) := (others => '0');
signal i_pixval2  : unsigned(15 downto 0) := (others => '0');
signal i_pixcnt  : unsigned(15 downto 0) := (others => '0');
signal i_cnt     : unsigned(15 downto 0) := (others => '0');
signal i_linecnt : unsigned(15 downto 0) := (others => '0');
signal i_fval    : std_logic := '0';
signal i_lval    : std_logic := '0';



begin --architecture behavior of cl_main is


gen_clk0 : process
begin
i_clk <= '0';
wait for (CI_CLK_PERIOD / 2);
i_clk <= '1';
wait for (CI_CLK_PERIOD / 2);
end process;


i_rst <= '1','0' after 2.5 us;


p_out_plllock <= ((not i_rst) & (not i_rst) & (not i_rst));--(others => '1');--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_link   <= ((not i_rst) & (not i_rst) & (not i_rst));--;--(others => '1');--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   <= (i_fval & i_fval & i_fval);--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   <= (i_lval & i_lval & i_lval);--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   <= (others => '1');--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte <= std_logic_vector(RESIZE(i_pixval2, 32)) & std_logic_vector(RESIZE(i_pixval, 32));--: out  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  <= (i_clk & i_clk & i_clk);--: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

i_pixval2 <= i_pixval + 1;

process(i_rst, i_clk)
begin
if rising_edge(i_clk) then
if (i_rst = '1') then

i_cnt <= (others => '0'); i_pixcnt <= (others => '0'); i_pixval <= (others => '0');
i_linecnt <= (others => '0');
i_fval <= '0';
i_lval <= '0';

else
  case i_fsm is

    when S_VSYNC =>

      if (i_cnt = TO_UNSIGNED(48, i_cnt'length)) then
        i_cnt <= (others => '0');
        i_fval <= '1';
        i_lval <= '0';
        i_fsm <= S_HSYNC;
      else
        i_fval <= '0';
        i_lval <= '0';
        i_cnt <= i_cnt + 1;
      end if;

    when S_HSYNC =>

      if (i_cnt = TO_UNSIGNED(32, i_cnt'length)) then
        i_cnt <= (others => '0');
        i_fval <= '1';
        i_lval <= '1';
        i_fsm <= S_PIX;
      else
        i_fval <= '1';
        i_lval <= '0';
        i_cnt <= i_cnt + 1;
      end if;

    when S_PIX =>

      if (i_cnt = TO_UNSIGNED((270 - 1), i_cnt'length)) then
        i_cnt <= (others => '0'); i_pixcnt <= (others => '0'); i_pixval <= (others => '0');
        if (i_linecnt = TO_UNSIGNED((8 - 1), i_cnt'length)) then
          i_linecnt <= (others => '0');
          i_fval <= '0';
          i_lval <= '0';
          i_fsm <= S_VSYNC;
        else
          i_linecnt <= i_linecnt + 1;
          i_fval <= '1';
          i_lval <= '0';
          i_fsm <= S_HSYNC;
        end if;
      else
        i_cnt <= i_cnt + 1;
        i_pixcnt <= i_pixcnt + 1;
        i_pixval <= i_pixval + 2;
      end if;
  end case;
end if;
end if;
end process;



end architecture behavior;
