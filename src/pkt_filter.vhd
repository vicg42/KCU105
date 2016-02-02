-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 31.08.2015 11:22:48
-- Module Name : pkt_filter
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.prj_def.all;
use work.reduce_pack.all;

entity pkt_filter is
generic(
G_DWIDTH : integer := 32;
G_FRR_COUNT : integer := 3
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_frr        : in    TSwtFrrMasks;

--------------------------------------
--Upstream Port
--------------------------------------
p_in_upp_data   : in    std_logic_vector(G_DWIDTH - 1 downto 0);
p_in_upp_wr     : in    std_logic;
p_in_upp_eof    : in    std_logic;
p_in_upp_sof    : in    std_logic;

--------------------------------------
--Downstream Port
--------------------------------------
p_out_dwnp_data : out   std_logic_vector(G_DWIDTH - 1 downto 0);
p_out_dwnp_wr   : out   std_logic;
p_out_dwnp_eof  : out   std_logic;
--p_out_dwnp_sof  : out   std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst        : in    std_logic_vector(31 downto 0);
p_out_tst       : out   std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk        : in    std_logic;
p_in_rst        : in    std_logic
);
end entity pkt_filter;

architecture behavioral of pkt_filter is

signal i_dwnp_data   : std_logic_vector(G_DWIDTH - 1 downto 0) := (others => '0');
signal i_dwnp_wr     : std_logic := '0';
signal i_dwnp_eof    : std_logic := '0';
--signal i_dwnp_sof    : std_logic := '0';

type TSrDLocal is array (0 to 1) of std_logic_vector(G_DWIDTH - 1 downto 0);
signal sr_upp_data   : TSrDLocal;
signal sr_upp_sof    : std_logic_vector(0 to 1);
signal sr_upp_wr     : std_logic_vector(0 to 1);
signal sr_upp_eof    : std_logic_vector(0 to 1);

signal i_pkt_type    : std_logic_vector(3 downto 0);
signal i_pkt_subtype : std_logic_vector(3 downto 0);
signal i_pkt_en      : std_logic_vector(G_FRR_COUNT - 1 downto 0) := (others => '0');

type TFrrLocal is array (0 to G_FRR_COUNT - 1) of std_logic_vector(7 downto 0);
signal i_frr         : TFrrLocal;


begin --architecture behavioral


process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    sr_upp_eof <= (others => '0');
    sr_upp_sof <= (others => '0');
    sr_upp_wr  <= (others => '0');

    for i in 0 to (sr_upp_data'length - 1) loop
      sr_upp_data(i) <= (others => '0');
    end loop;

    for i in 0 to (i_frr'length - 1) loop
      i_frr(i) <= (others => '0');
    end loop;

  else
    sr_upp_eof <= p_in_upp_eof & sr_upp_eof(0 to 0);
    sr_upp_sof <= p_in_upp_sof & sr_upp_sof(0 to 0);
    sr_upp_wr  <= p_in_upp_wr & sr_upp_wr(0 to 0);
    sr_upp_data <= p_in_upp_data & sr_upp_data(0 to 0);

    --Update local FRR(frame routing rule) olny on SOF(start of frame)
    if (p_in_upp_sof = '1') then
      for i in 0 to G_FRR_COUNT - 1 loop
        i_frr(i) <= p_in_frr(i);
      end loop;
    end if;
  end if;
end if;
end process;


i_pkt_type(3 downto 0) <= sr_upp_data(0)(19 downto 16);
i_pkt_subtype(3 downto 0) <= sr_upp_data(0)(23 downto 20);


process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    i_pkt_en <= (others => '0');

  else

    if sr_upp_sof(0) = '1' and sr_upp_wr(0) = '1' then

        --Find rule of commutation
        for i in 0 to G_FRR_COUNT - 1 loop
          if (i_frr(i) /= (i_frr(i)'range => '0')) then
            if (i_frr(i) = (i_pkt_subtype & i_pkt_type)) then
              i_pkt_en(i) <= '1';
            end if;
          end if;
        end loop;

    elsif sr_upp_eof(1) = '1' then

      i_pkt_en <= (others => '0');

    end if;

  end if;
end if;
end process;


process(p_in_clk)
begin
if rising_edge(p_in_clk) then

--  i_dwnp_sof  <= sr_upp_sof(1) and OR_reduce(i_pkt_en);
  i_dwnp_eof  <= sr_upp_eof(1) and OR_reduce(i_pkt_en);
  i_dwnp_wr   <= sr_upp_wr(1)  and OR_reduce(i_pkt_en);
  i_dwnp_data <= sr_upp_data(1);

end if;
end process;


--p_out_dwnp_sof  <= i_dwnp_sof ;
p_out_dwnp_eof  <= i_dwnp_eof ;
p_out_dwnp_wr   <= i_dwnp_wr  ;
p_out_dwnp_data <= i_dwnp_data;


------------------------------------
--DBG
------------------------------------
p_out_tst(31 downto 0) <= (others => '0');

end architecture behavioral;
