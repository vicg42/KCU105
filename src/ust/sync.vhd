-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.01.2016 12:30:10
-- Module Name : sync
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;

entity sync is
generic(
G_T100us : natural := 64 --100us/(1/clk_ferq) , clk_ferq=125MHz
);
port(
--p_in_time_set  : in  std_logic;
p_in_time_val  : in  std_logic_vector(31 downto 0);
p_out_time     : out std_logic_vector(31 downto 0);

----Input synchrotization
--p_in_sync_src    : in std_logic_vector(2 downto 0); --source of sync
--p_in_sync_pps    : in std_logic; --1 strobe per 1 sec
--p_in_sync_ext_1m : in std_logic;
--p_in_sync_ext_1s : in std_logic;
--p_in_sync_iedge  : in std_logic; --управл€ющие фронты входов внешней синхронизации (0-rissing)

----Device synchrotization
--p_in_sync_oedge   : in std_logic; --управл€ющие фронты выходов на внешнюю синхронизацию (0-rissing)
--p_out_dev_sync_1m : out  std_logic;
--p_out_dev_sync_1s : out  std_logic;
--p_out_dev_sync_120Hz: out  std_logic;

-------------------------------
--System
-------------------------------
p_in_clk : in   std_logic;
p_in_rst : in   std_logic
);
end entity sync;

architecture behavioral of sync is

constant CI_Tdiscret : integer := G_T100us;-- 1disrct = 100us/(1/clk_ferq)
constant CI_Tms      : integer := 10#10#  ;-- 1ms = 10 discret
constant CI_Tsec     : integer := 10#1000#;-- 1sec = 1000ms
constant CI_Tmin     : integer := 10#0060#;-- 1min = 60sec
constant CI_Thour    : integer := 10#0060#;-- 1hour = 60min
constant CI_Tday     : integer := 10#0024#;-- 1day = 24hour

signal i_cnt_discret : unsigned(log2(CI_Tdiscret) - 1 downto 0);
signal i_cnt_us      : unsigned(log2(CI_Tms) - 1 downto 0);
signal i_cnt_ms      : unsigned(log2(CI_Tsec) - 1 downto 0);
signal i_cnt_min     : unsigned(log2(CI_Tmin) - 1 downto 0);
signal i_cnt_sec     : unsigned(log2(CI_Thour) - 1 downto 0);
signal i_cnt_hour    : unsigned(log2(CI_Tday) - 1 downto 0);
signal i_cnt_day     : unsigned(0 downto 0);

signal i_100us       : std_logic;
signal i_1ms         : std_logic;
signal i_1sec        : std_logic;
signal i_1min        : std_logic;

signal sr_sync_pps    : std_logic_vector(0 to 2);
signal sr_sync_ext_1m : std_logic_vector(0 to 2);
signal sr_sync_ext_1s : std_logic_vector(0 to 2);

signal i_sync_pps_redge    : Std_logic;
signal i_sync_ext_1m_redge : Std_logic;
signal i_sync_ext_1s_redge : Std_logic;

signal i_sync_pps_fedge    : std_logic;
signal i_sync_ext_1m_fedge : std_logic;
signal i_sync_ext_1s_fedge : std_logic;

signal i_rst_pps    : std_logic;
signal i_rst_ext_1m : std_logic;
signal i_rst_ext_1s : std_logic;

signal i_dev_sync_1m_width : unsigned(15 downto 0);
signal i_dev_sync_1m       : std_logic;
signal i_dev_sync_1s_width : unsigned(15 downto 0);
signal i_dev_sync_1s       : std_logic;

signal i_time_sync         : std_logic;



begin --architecture behavioral

----##########################################
----Input sync
----##########################################
----input sync - edge detector
--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--  sr_sync_pps    <= p_in_sync_pps    & sr_sync_pps(0 to 1);
--  sr_sync_ext_1m <= p_in_sync_ext_1m & sr_sync_ext_1m(0 to 1);
--  sr_sync_ext_1s <= p_in_sync_ext_1s & sr_sync_ext_1s(0 to 1);
--
--  --rising edge
--  i_sync_pps_redge    <= sr_sync_pps(1)    and (not sr_sync_pps(2)   );
--  i_sync_ext_1m_redge <= sr_sync_ext_1m(1) and (not sr_sync_ext_1m(2));
--  i_sync_ext_1s_redge <= sr_sync_ext_1s(1) and (not sr_sync_ext_1s(2));
--
--  --falling edge
--  i_sync_pps_fedge    <= (not sr_sync_pps(1)   ) and sr_sync_pps(2)   ;
--  i_sync_ext_1m_fedge <= (not sr_sync_ext_1m(1)) and sr_sync_ext_1m(2);
--  i_sync_ext_1s_fedge <= (not sr_sync_ext_1s(1)) and sr_sync_ext_1s(2);
--
--end if;
--end process;
--
----input sync select edge
--i_rst_pps    <= i_sync_pps_fedge    when p_in_sync_iedge = '1' else i_sync_pps_redge   ;
--i_rst_ext_1m <= i_sync_ext_1m_fedge when p_in_sync_iedge = '1' else i_sync_ext_1m_redge;
--i_rst_ext_1s <= i_sync_ext_1s_fedge when p_in_sync_iedge = '1' else i_sync_ext_1s_redge;
--
--
--
--##########################################
--Time
--##########################################
--i_time_sync <= i_rst_pps     when p_in_sync_src = "01" else
--               i_rst_ext_1s  when p_in_sync_src = "10" else
--               p_in_time_set;-- when p_in_sync_src = "00"

p_out_time(3 downto 0)   <= std_logic_vector(i_cnt_us  );
p_out_time(13 downto 4)  <= std_logic_vector(i_cnt_ms  );
p_out_time(19 downto 14) <= std_logic_vector(i_cnt_sec );
p_out_time(25 downto 20) <= std_logic_vector(i_cnt_min );
p_out_time(30 downto 26) <= std_logic_vector(i_cnt_hour);
p_out_time(31)           <= i_cnt_day(0);

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then -- or i_time_sync = '1') then

  i_cnt_discret <= (others => '0');
  i_cnt_us     <= UNSIGNED(p_in_time_val(3 downto 0))  ;
  i_cnt_ms     <= UNSIGNED(p_in_time_val(13 downto 4)) ;
  i_cnt_sec    <= UNSIGNED(p_in_time_val(19 downto 14));
  i_cnt_min    <= UNSIGNED(p_in_time_val(25 downto 20));
  i_cnt_hour   <= UNSIGNED(p_in_time_val(30 downto 26));
  i_cnt_day(0) <= p_in_time_val(31)                    ;

  i_100us  <= '0';
  i_1ms  <= '0';
  i_1sec <= '0';
  i_1min <= '0';

  else
--    if i_timecnt_en = '1' then
      if (i_cnt_discret = TO_UNSIGNED((CI_Tdiscret - 1), i_cnt_discret'length)) then
        i_cnt_discret <= (others => '0'); i_100us <= '1';

        if (i_cnt_us = TO_UNSIGNED((CI_Tms - 1), i_cnt_us'length)) then
          i_cnt_us <= (others => '0'); i_1ms  <= '1';

          if (i_cnt_ms = TO_UNSIGNED((CI_Tsec - 1), i_cnt_ms'length)) then
            i_cnt_ms <= (others => '0'); i_1sec <= '1';

            if (i_cnt_sec = TO_UNSIGNED((CI_Tmin - 1), i_cnt_sec'length)) then
              i_cnt_sec <= (others => '0'); i_1min <= '1';

              if (i_cnt_min = TO_UNSIGNED((CI_Thour - 1), i_cnt_min'length)) then
                i_cnt_min <= (others => '0');

                if (i_cnt_hour = TO_UNSIGNED((CI_Tday - 1), i_cnt_hour'length)) then
                  i_cnt_hour <= (others => '0');
                  i_cnt_day <= i_cnt_day + 1;
                else
                  i_cnt_hour <= i_cnt_hour + 1;
                end if;

              else
                i_cnt_min <= i_cnt_min + 1;
              end if;

            else
              i_cnt_sec <= i_cnt_sec + 1; i_1min <= '0';
            end if;

          else
            i_cnt_ms <= i_cnt_ms + 1; i_1sec <= '0';
          end if;

        else
          i_cnt_us <= i_cnt_us + 1; i_1ms  <= '0';
        end if;

      else
        i_cnt_discret <= i_cnt_discret + 1; i_100us <= '0';
      end if;

--    end if;
  end if;
end if;
end process;



----##########################################
----Output sync
----##########################################
----Expand strobe for device sync
--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--  if (i_1min = '1') then
--    i_dev_sync_1m_width <= TO_UNSIGNED(32766, i_dev_sync_1m_width'length);
--    i_dev_sync_1m <= (not p_in_sync_oedge);
--
--  elsif (i_dev_sync_1m_width /= (i_dev_sync_1m_width'range => '0')) then
--    i_dev_sync_1m_width <= i_dev_sync_1m_width - 1;
--
--  else
--    i_dev_sync_1m <= p_in_sync_oedge;
--  end if;
--end if;
--end process;
--
--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--  if (i_1sec = '1') then
--    i_dev_sync_1s_width <= TO_UNSIGNED(32766, i_dev_sync_1s_width'length);
--    i_dev_sync_1s <= (not p_in_sync_oedge);
--
--  elsif (i_dev_sync_1s_width /= (i_dev_sync_1s_width'range => '0')) then
--    i_dev_sync_1s_width <= i_dev_sync_1s_width - 1;
--
--  else
--    i_dev_sync_1s <= p_in_sync_oedge;
--  end if;
--end if;
--end process;
--
--p_out_dev_sync_1m <= i_dev_sync_1m;
--p_out_dev_sync_1s <= i_dev_sync_1s;
--
--p_out_dev_sync_120Hz <= '0';


end architecture behavioral;
