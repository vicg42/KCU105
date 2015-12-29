-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 29.12.2015 11:09:05
-- Module Name : cl_vprm_det
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cl_vprm_det is
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

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  : out std_logic_vector(15 downto 0);
p_out_linecount : out std_logic_vector(15 downto 0);
p_out_det_rdy   : out std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0)
);
end entity cl_vprm_det;

architecture behavioral of cl_vprm_det is

type TFsm_vprm is (
S_LINE_WAIT ,
S_PIXCOUNT  ,
S_FRAME_WAIT,
S_LINECOUNT,
S_DONE
);
signal i_fsm_vprm     : TFsm_vprm;

signal i_cnt       : unsigned(15 downto 0);
signal i_flag      : std_logic;
signal i_det_done  : std_logic;
signal i_pixcount  : unsigned(15 downto 0);
signal i_linecount : unsigned(15 downto 0);


begin --architecture behavioral


p_out_pixcount  <= std_logic_vector(i_pixcount);
p_out_linecount <= std_logic_vector(i_linecount);
p_out_det_rdy   <= i_det_done;


process(p_in_link, p_in_restart, p_in_rxclk)
begin
if (p_in_link = '0' or p_in_restart = '1') then
i_fsm_vprm <= S_LINE_WAIT;
i_cnt <= (others => '0');
i_flag <= '0';
i_det_done <= '0';

i_pixcount <= (others => '0');
i_linecount <= (others => '0');

elsif rising_edge(p_in_rxclk) then
case i_fsm_sync is

  when S_LINE_WAIT =>

    if (p_in_lval = '0') then
      i_fsm_vprm <= S_PIXCOUNT;
    end if;

  when S_PIXCOUNT =>

    if (p_in_lval = '1') then
      if (p_in_dval = '1') then
        i_cnt <= i_cnt + 1;
      end if;
    else
      i_pixcount <= i_cnt;
      i_fsm_vprm <= S_FRAME_WAIT;
    end if;

  when S_FRAME_WAIT =>

    if (p_in_fval = '0' and i_flag = '0') then
      i_flag <= '1';
    elsif (p_in_fval = '1' and i_flag = '1') then
      i_flag <= '0';
      i_fsm_vprm <= S_LINECOUNT;
    end if;

  when S_LINECOUNT =>

    if (p_in_fval = '0') then
      i_linecount <= i_cnt;
      i_flag <= '0';
      i_fsm_vprm <= S_WAIT_DONE;

    else
      if (p_in_lval = '0' and i_flag = '0') then
        i_cnt <= i_cnt + 1;
        i_flag <= '1';

      if (p_in_lval = '1' and i_flag = '1') then
        i_flag <= '0';

      end if;
    end if;

  when S_DONE =>

    i_det_done <= '1';

end case;
end if;
end process;



--#########################################
--DBG
--#########################################
p_out_tst <= (others => '0');


end architecture behavioral;
