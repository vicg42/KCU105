-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.06.2016 12:42:00
-- Module Name : dev_wr
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.ust_def.all;

entity dev_wr is
generic(
G_SDEV_COUNT_MAX : natural := 16;
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQWR (Len + DEVID + WRDATA; Len + DEVID + WRDATA....)
--------------------------------------------------
p_in_rq_di     : in   std_logic_vector(7 downto 0);
p_in_rq_wr     : in   std_logic;
p_out_rq_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdy : in  TDevB; --ready
p_out_dev_d  : out TDevD; --data
p_out_dev_wr : out TDevB; --write

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity dev_wr;

architecture behavioral of dev_wr is

component fifo_rqrd
port (
din   : in std_logic_vector(7 downto 0);
wr_en : in std_logic;

dout  : out std_logic_vector(7 downto 0);
rd_en : in std_logic;

full  : out std_logic;
empty : out std_logic;

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk  : in std_logic;
srst : in std_logic
);
end component fifo_rqrd;

type TFsmRq is (
S_RQ_IDLE,
S_RQ_LEN,
S_RQ_ID,
S_RQ_CHK,
--S_RQ_CHK1,
--S_RQ_CHK2,
S_RQ_DATA
);

signal i_fsm_rq       : TFsmRq;

signal i_rqfifo_rden  : std_logic;
signal i_rqfifo_rd    : std_logic;
signal i_rqfifo_do    : std_logic_vector(7 downto 0);
signal i_rqfifo_full  : std_logic;
signal i_rqfifo_empty : std_logic;

signal i_rq_len       : unsigned(15 downto 0);
signal i_rq_id        : unsigned(15 downto 0);
signal i_bcnt         : unsigned(log2(i_rq_len'length / 8) - 1 downto 0);--bus byte cnt

type TDev is record
s : unsigned(3 downto 0); --subtype
t : unsigned(3 downto 0); --type
n : unsigned(3 downto 0); --num
dsize : unsigned(15 downto 0);--sizeof(DevData only)
hrd : std_logic;--Read from fifo_rq : Len + Header
drd : std_logic;--Read from fifo_rq : WrData
end record;

signal i_dev          : TDev;
signal i_dcnt         : unsigned(15 downto 0);
signal i_dev_rdy      : std_logic_vector((G_SDEV_COUNT_MAX * G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);
signal i_dev_wr       : std_logic;
signal i_dev_cs       : TDevB;


begin --architecture behavioral


---------------------------------------------
--Read request
---------------------------------------------
p_out_rq_rdy_n <= '0';

m_fifo_rq : fifo_rqrd
port map(
din   => p_in_rq_di,
wr_en => p_in_rq_wr,

dout  => i_rqfifo_do,
rd_en => i_rqfifo_rd,

full  => open, --i_rqfifo_full,
empty => i_rqfifo_empty,

wr_rst_busy => open,
rd_rst_busy => open,

clk => p_in_clk,
srst => p_in_rst
);

i_rqfifo_rd <= (i_dev.hrd and (not i_rqfifo_empty)) or i_dev_wr;
i_dev_wr <= (i_dev.drd and (not i_rqfifo_empty) and OR_reduce(i_dev_rdy));

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_rq <= S_RQ_IDLE;

    i_rq_len <= (others => '0');
    i_rq_id <= (others => '0');
    i_bcnt <= (others => '0');

    i_dev.hrd <= '0';
    i_dev.drd <= '0';
    i_dev.dsize <= (others => '0');
    i_dcnt <= (others => '0');

    for s in 0 to G_SDEV_COUNT_MAX - 1 loop
      for t in 0 to G_TDEV_COUNT_MAX - 1 loop
        for n in 0 to G_NDEV_COUNT_MAX - 1 loop
          i_dev_cs(s)(t)(n) <= '0';
        end loop;
      end loop;
    end loop;
--
--    i_dev.s <= (others => '0');
--    i_dev.t <= (others => '0');
--    i_dev.n <= (others => '0');

  else

      case i_fsm_rq is

        when S_RQ_IDLE =>

          if (i_rqfifo_empty = '0') then
            i_dev.hrd <= '1';
            i_fsm_rq <= S_RQ_LEN;
          end if;

        --------------------------------------
        --Get Param Device read
        --------------------------------------
        when S_RQ_LEN =>

          if (i_rqfifo_empty = '0') then

            for idx in 0 to (i_rq_len'length / 8) - 1 loop
              if (i_bcnt = idx) then
                i_rq_len(8 * (idx + 1) - 1 downto 8 * idx) <= UNSIGNED(i_rqfifo_do);
              end if;
            end loop;

            if (i_bcnt = TO_UNSIGNED((i_rq_len'length / 8) - 1, i_bcnt'length)) then
              i_bcnt <= (others => '0');
              i_fsm_rq <= S_RQ_ID;
            else
              i_bcnt <= i_bcnt + 1;
            end if;

          end if;

        when S_RQ_ID =>

          if (i_rqfifo_empty = '0') then

            for idx in 0 to (i_rq_id'length / 8) - 1 loop
              if (i_bcnt = idx) then
                i_rq_id(8 * (idx + 1) - 1 downto 8 * idx) <= UNSIGNED(i_rqfifo_do);
              end if;
            end loop;

            if (i_bcnt = TO_UNSIGNED((i_rq_id'length / 8) - 1, i_bcnt'length)) then
              i_bcnt <= (others => '0');
              i_dev.hrd <= '0';
              i_dev.dsize <= i_rq_len - 2; --subtraction sizeof(Header)
              i_fsm_rq <= S_RQ_CHK;
            else
              i_bcnt <= i_bcnt + 1;
            end if;

          end if;

        when S_RQ_CHK =>

          for s in 0 to G_SDEV_COUNT_MAX - 1 loop --SubType Device
            if (i_dev.s = s) then
              for t in 0 to G_TDEV_COUNT_MAX - 1 loop --Type Device
                if (i_dev.t = t) then
                  for n in 0 to G_NDEV_COUNT_MAX - 1 loop --Number Device
                    if (i_dev.n = n) then
                      i_dev_cs(s)(t)(n) <= '1';
                    end if;
                  end loop;
                end if;
              end loop;
            end if;
          end loop;

          if ((i_rqfifo_empty = '0') and (OR_reduce(i_dev_rdy) = '1')) then
            i_dev.drd <= '1';
            i_fsm_rq <= S_RQ_DATA;
          end if;

        when S_RQ_DATA =>

          if (i_rqfifo_empty = '0') then
            if (OR_reduce(i_dev_rdy) = '1') then
                if (i_dcnt = (i_dev.dsize - 1)) then
                  i_dcnt <= (others => '0');
                  i_dev.drd <= '0';

                  for s in 0 to G_SDEV_COUNT_MAX - 1 loop
                    for t in 0 to G_TDEV_COUNT_MAX - 1 loop
                      for n in 0 to G_NDEV_COUNT_MAX - 1 loop
                        i_dev_cs(s)(t)(n) <= '0';
                      end loop;
                    end loop;
                  end loop;

                  i_fsm_rq <= S_RQ_IDLE;
                else
                  i_dcnt <= i_dcnt + 1;
                end if;
            end if;
          end if;

      end case;

  end if;
end if;
end process;

i_dev.s <= i_rq_id( 3 downto 0); --subtype device
i_dev.t <= i_rq_id( 7 downto 4); --type device
i_dev.n <= i_rq_id(11 downto 8); --number device

gen_sdev : for s in 0 to C_SDEV_COUNT_MAX - 1 generate begin
  gen_tdev : for t in 0 to C_TDEV_COUNT_MAX - 1 generate begin
    gen_ndev : for n in 0 to C_NDEV_COUNT_MAX - 1 generate begin

      i_dev_rdy((s * G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) + (t * G_NDEV_COUNT_MAX) + n) <= p_in_dev_rdy(s)(t)(n) and i_dev_cs(s)(t)(n);

      p_out_dev_d(s)(t)(n) <= i_rqfifo_do;

      p_out_dev_wr(s)(t)(n) <= i_dev_wr and i_dev_cs(s)(t)(n);

    end generate gen_ndev;
  end generate gen_tdev;
end generate gen_sdev;

end architecture behavioral;
