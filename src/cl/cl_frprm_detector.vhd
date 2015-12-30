-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 29.12.2015 11:09:05
-- Module Name : cl_frprm_detector
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cl_frprm_detector is
port(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart : in std_logic;

--------------------------------------------------
--video
--------------------------------------------------
p_in_link   : in std_logic;
p_in_fval   : in std_logic;
p_in_lval   : in std_logic;
p_in_dval   : in std_logic;
p_in_rxclk  : in std_logic;

----------------------------------------------------
----DBG
----------------------------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  : out std_logic_vector(15 downto 0);
p_out_linecount : out std_logic_vector(15 downto 0);
p_out_det_rdy   : out std_logic
);
end entity cl_frprm_detector;

architecture behavioral of cl_frprm_detector is

type TFsm_vprm is (
S_IDLE      ,
S_LINE_WAIT ,
S_PIXCOUNT  ,
S_FRAME_WAIT,
S_LINECOUNT ,
S_DONE
);
signal i_fsm_vprm     : TFsm_vprm;

signal i_cnt       : unsigned(15 downto 0);
signal i_flag      : std_logic;
signal i_det_done  : std_logic;
signal i_pixcount  : unsigned(15 downto 0);
signal i_linecount : unsigned(15 downto 0);
signal sr_lval     : std_logic_vector(0 to 1);
signal sr_fval     : std_logic_vector(0 to 1);

begin --architecture behavioral


p_out_pixcount  <= std_logic_vector(i_pixcount);
p_out_linecount <= std_logic_vector(i_linecount);
p_out_det_rdy   <= i_det_done;


process(p_in_link, p_in_restart, p_in_rxclk)
begin
if (p_in_link = '0' or p_in_restart = '1') then
sr_lval <= (others => '1');
sr_fval <= (others => '1');
elsif rising_edge(p_in_rxclk) then
sr_lval <= p_in_lval & sr_lval(0 to 0);
sr_fval <= p_in_fval & sr_fval(0 to 0);
end if;
end process;

process(p_in_link, p_in_restart, p_in_rxclk)
begin
if (p_in_link = '0' or p_in_restart = '1') then
i_fsm_vprm <= S_IDLE;
i_cnt <= (others => '0');
i_flag <= '0';
i_det_done <= '0';

i_pixcount <= (others => '0');
i_linecount <= (others => '0');

elsif rising_edge(p_in_rxclk) then
case i_fsm_vprm is

  when S_IDLE =>

    if (sr_fval(0) = '0' and sr_fval(1) = '1') then
      if (i_cnt = TO_UNSIGNED(64, i_cnt'length)) then
        i_cnt <= (others => '0');
        i_fsm_vprm <= S_LINE_WAIT;
      else
        i_cnt <= i_cnt + 1;
      end if;
    end if;

  when S_LINE_WAIT =>

    if (p_in_fval = '1' and sr_lval(1) = '0') then
      i_fsm_vprm <= S_PIXCOUNT;
    end if;

  when S_PIXCOUNT =>

    if (p_in_fval = '1') then
      if (p_in_lval = '1') then --and p_in_dval = '1'
        i_cnt <= i_cnt + 1;
      end if;

      --falling edge of p_in_lval
      if (sr_lval(0) = '0' and sr_lval(1) = '1') then
        i_pixcount <= i_cnt;
        i_fsm_vprm <= S_FRAME_WAIT;
      end if;
    end if;

  when S_FRAME_WAIT =>

    i_cnt <= (others => '0');

    if (sr_fval(1) = '0') then
      i_fsm_vprm <= S_LINECOUNT;
    end if;

  when S_LINECOUNT =>

     --rissing edge of p_in_lval
    if (p_in_fval = '1') and (sr_lval(0) = '1' and sr_lval(1) = '0') then
      i_cnt <= i_cnt + 1;
    end if;

    --falling edge of p_in_fval
    if (sr_fval(0) = '0' and sr_fval(1) = '1') then
      i_linecount <= i_cnt;
      i_fsm_vprm <= S_DONE;
    end if;

  when S_DONE =>

    if (p_in_restart = '1') then
      i_det_done <= '1';
    end if;

end case;
end if;
end process;



----#########################################
----DBG
----#########################################
--p_out_tst <= (others => '0');


end architecture behavioral;
