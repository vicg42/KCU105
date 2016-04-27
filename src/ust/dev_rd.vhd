-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 15.04.2016 10:23:48
-- Module Name : dev_rd
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

entity dev_rd is
generic(
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;

G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQRD
--------------------------------------------------
p_in_rqrd_di     : in   std_logic_vector(7 downto 0);
p_in_rqrd_wr     : in   std_logic;
p_out_rqrd_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_rdrdy : in   std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);
p_in_dev_d     : in   std_logic_vector(7 downto 0);
p_out_dev_rd   : out  std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);

--------------------------------------------------
--EthTx
--------------------------------------------------
p_in_obuf_axi_tready  : out std_logic; --read
p_out_obuf_axi_tdata  : in  std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
p_out_obuf_axi_tvalid : in  std_logic; --empty
p_out_obuf_axi_tlast  : in  std_logic; --EOF

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity dev_rd;

architecture behavioral of dev_rd is

constant CI_PKT_LEN_LIMIT : natural := 128;

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

component bufo_devrd
port (
addra : in  std_logic_vector(10 downto 0);
dina  : in  std_logic_vector(7 downto 0);
ena   : in  std_logic;
wea   : in  std_logic_vector(0 downto 0);
clka  : in  std_logic;

addrb : in  std_logic_vector(7 downto 0);
doutb : out std_logic_vector(63 downto 0)
enb   : in  std_logic;
clkb  : in  std_logic
);
end component bufo_devrd;

type TFsmRqRd is (
S_RQ_IDLE,
S_RQ_LEN,
S_RQ_ID,
S_RQ_RDY
);

type TFsmPkt is (
S_PKT_IDLE,
S_PKT_IDLE2,
S_PKT_CHK,

S_PKT_DEV_HDR0,
S_PKT_DEV_HDR1,
S_PKT_DEV_HDR2,
S_PKT_DEV_HDR3,
S_PKT_DEV_RD,
S_PKT_DEV_DONE,

S_PKT_SET_HDR0,
S_PKT_SET_HDR1,
S_PKT_SET_HDR2,
S_PKT_SET_HDR3,
S_PKT_RDY,
S_PKT_RD
);

type TRqRd is record
hdr : unsigned(15 downto 0);
dsize : unsigned(15 downto 0);
pktsize : unsigned(15 downto 0);
end record;

type TDev is record
type : unsigned(3 downto 0);
num : unsigned(3 downto 0);
busy : std_logic;
end record;

signal i_fsm_rq       : TFsmRqRd;
signal i_fsm_pkt      : TFsmPkt;

signal i_rqbuf_rden   : std_logic;
signal i_rqbuf_d      : unsigned(7 downto 0);

signal i_rq           : TRqRd;
signal i_rq_len       : unsigned(15 downto 0);
signal i_rq_id        : unsigned(15 downto 0);
signal i_bcnt         : unsigned(log2(i_rq_len'length / 8) - 1 downto 0);--bus byte cnt

signal i_dev          : TDev;
signal i_dev_rd       : std_logic;
signal i_dev_hdr      : unsigned(7 downto 0);
signal i_dev_hdr_wr   : std_logic;

signal i_pkt_dcnt     : unsigned(15 downto 0);
signal i_pkt_hdr      : unsigned(7 downto 0);
signal i_pkt_hdr_wr   : std_logic;
signal i_pkt_rdy      : std_logic;

signal i_bufo_adr     : unsigned(15 downto 0);
signal i_bufo_di      : unsigned(7 downto 0);
signal i_bufo_wr      : std_logic;


begin --architecture behavioral


---------------------------------------------
--
---------------------------------------------
m_buf_rqrd : fifo_rqrd
port map(
din   => p_in_rqrd_di,
wr_en => p_in_rqrd_wr,

dout  => i_rqbuf_d,
rd_en => i_rqbuf_rd,

full  => i_rqbuf_full,
empty => i_rqbuf_empty,

wr_rst_busy => open,
rd_rst_busy => open,

clk => p_in_clk,
srst => p_in_rst
);

i_rqbuf_rd <= i_rqbuf_rden and (not i_rqbuf_empty);

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_rq <= S_RQ_IDLE;

    i_rqbuf_rden <= '0';

    i_rq_len <= (others => '0');
    i_rq_id <= (others => '0');
    i_bcnt <= (others => '0');

    i_rq.id <= (others => '0');
    i_rq.dsize <= (others => '0');
    i_rq.pktsize <= (others => '0');
    i_rq.rdy <= '0';

  else

      case i_fsm_rq is

        when S_RQ_IDLE =>

          i_rq.rdy <= '0';

          if (i_rqbuf_empty = '0') then
            i_rqbuf_rden <= '1';
            i_fsm_rq <= S_RQ_LEN;
          end if;

        --------------------------------------
        --Get Param Device read
        --------------------------------------
        when S_RQ_LEN =>

          if (i_rqbuf_empty = '0') then

            for idx in 0 to (i_rq_len'length / 8) - 1 loop
              if (i_bcnt = idx) then
                i_rq_len(8 * (idx + 1) - 1 downto 8 * idx) <= i_rqbuf_d;
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

          if (i_rqbuf_empty = '0') then

            for idx in 0 to (i_rq_id'length / 8) - 1 loop
              if (i_bcnt = idx) then
                i_rq_id(8 * (idx + 1) - 1 downto 8 * idx) <= i_rqbuf_d;
              end if;
            end loop;

            if (i_bcnt = TO_UNSIGNED((i_rq_id'length / 8) - 1, i_bcnt'length)) then
              i_bcnt <= (others => '0');
              i_rqbuf_rden <= '0';
              i_fsm_rq <= S_RQ_RDY;
            else
              i_bcnt <= i_bcnt + 1;
            end if;

          end if;

        when S_RQ_RDY =>

          if (i_dev.busy = '0') then

            i_rq.id <= i_rq_id;
            i_rq.dsize <= i_rq_len;
            i_rq.pktsize <= i_rq_len + 2;
            i_rq.rdy <= '1';
            i_fsm_rq <= S_RQ_IDLE;

          end if;

      end case;

  end if;
end if;
end process;

i_dev.type <= i_rq.id(3 downto 0); --type device
i_dev.num <= i_rq.id(7 downto 4); --number device


m_bufo : bufo_devrd
port map(
addra => i_bufo_adr,
dina  => i_bufo_di,
ena   => i_bufo_wr,
wea   => (others => '0'),
clka  => p_in_clk,

addrb => i_bufo_adr,
doutb => p_out_obuf_axi_tdata,
enb   => p_in_obuf_axi_tready,
clkb  => p_in_clk
);

i_bufo_di <= i_dev_hdr when (i_dev_hdr_wr = '1') and (i_pkt_hdr_wr = '0') else
             i_pkt_hdr when (i_dev_hdr_wr = '0') and (i_pkt_hdr_wr = '1') else
             p_in_dev_d;

i_bufo_wr <= (i_dev_hdr_wr or i_pkt_hdr_wr) or (i_dev_rd);

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_pkt <= S_PKT_IDLE;

    i_dev.busy <= '1';
    i_dev_rd <= '0';

    i_bufo_adr <= (others => '0');
    i_pkt_dcnt <= (others => '0');

    i_dev_hdr <= (others => '0');
    i_dev_hdr_wr <= '0';

    i_pkt_hdr <= (others => '0');
    i_pkt_hdr_wr <= '0';
    i_pkt_rdy <= '0';

  else

      case i_fsm_pkt is

        --------------------------------------
        --begin set RD Packet
        --------------------------------------
        when S_PKT_IDLE =>

          if (i_rq.rdy = '1') then
            i_dev.busy <= '1';
            i_bufo_adr <= TO_UNSIGNED(3, i_bufo_adr);
            i_pkt_dcnt <= TO_UNSIGNED(4, i_pkt_dcnt);--sizeof(pkt.len) + sizeof(pkt.header)
            i_fsm_pkt <= S_PKT_CHK;
          end if;

        --------------------------------------
        --continue set RD Packet
        --------------------------------------
        when S_PKT_IDLE2 =>

          if (i_rq.rdy = '1') then
            i_dev.busy <= '1';
            i_fsm_pkt <= S_PKT_CHK;
          end if;

        --------------------------------------
        --Check length of RD Packet
        --------------------------------------
        when S_PKT_CHK =>

          if (i_pkt_dcnt + i_rq.pktsize) <= TO_UNSIGNED(CI_PKT_LEN_LIMIT, 16)) then
            --read device
            i_fsm_pkt <= S_PKT_SET_HDR0;
          else
            --Send RD Packet
            i_bufo_adr <= (others => '0');
            i_fsm_pkt <= S_PKT_SET_HDR0;
          end if;


        --------------------------------------
        --Read Device
        --------------------------------------
        when S_PKT_DEV_HDR0 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr <= i_rq.dsize(7 downto 0);
          i_dev_hdr_wr <= '1';
          i_fsm_pkt <= S_PKT_DEV_HDR1;

        when S_PKT_DEV_HDR1 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr <= i_rq.dsize(15 downto 8);
          i_fsm_pkt <= S_PKT_DEV_HDR2;

        when S_PKT_DEV_HDR2 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr <= i_rq.id(7 downto 0);
          i_fsm_pkt <= S_PKT_DEV_HDR3;

        when S_PKT_DEV_HDR3 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr <= i_rq.id(15 downto 8);
          i_dev_rd <= '1';
          i_fsm_pkt <= S_PKT_DEV_RD;


        when S_PKT_DEV_RD =>

          i_dev_hdr_wr <= '0';

          for t in 0 to G_TDEV_COUNT_MAX - 1 loop
            if (i_dev.type = t) then --Detect Type Device

              for n in 0 to G_NDEV_COUNT_MAX - 1 loop
                if (i_dev.num = n) then --Detect Number Device

                  if (p_in_dev_rdrdy((t * G_NDEV_COUNT_MAX) + n) = '1') then
                    i_bufo_adr <= i_bufo_adr + 1;
                    i_pkt_dcnt <= i_pkt_dcnt + 1;
                    if (i_dev_dcnt = (i_dev_dcnt'range => '0') then
                      i_dev_rd <= '0';
                      i_fsm_pkt <= S_PKT_DEV_DONE;
                    else
                      i_dev_dcnt <= i_dev_dcnt - 1;
                    end if;
                  end if;

                end if;
              end loop;

            end if;
          end loop;

        when S_PKT_DEV_DONE =>

          i_dev_rd <= '0';
          i_dev.busy <= '0';
          i_fsm_pkt <= S_PKT_IDLE2;


        --------------------------------------
        --Set RD Packet header (len + ID) and Send It
        --------------------------------------
        when S_PKT_SET_HDR0 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_dcnt(7 downto 0);
          i_pkt_hdr_wr <= '1';
          i_fsm_pkt <= S_PKT_SET_HDR1;

        when S_PKT_SET_HDR1 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_dcnt(15 downto 8);
          i_fsm_pkt <= S_PKT_SET_HDR2;

        when S_PKT_SET_HDR2 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_id(7 downto 0);
          i_fsm_pkt <= S_PKT_SET_HDR3;

        when S_PKT_SET_HDR3 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_id(15 downto 8);
          i_pkt_hdr_wr <= '1';
          i_fsm_pkt <= S_PKT_RDY;

        when S_PKT_RDY =>

          i_pkt_hdr_wr <= '0';
          i_pkt_rdy <= '1';
          i_bufo_adr <= (others => '0');

        when S_PKT_RD =>

          if (p_in_obuf_axi_tready = '1') then
          i_bufo_adr <= i_bufo_adr + 1;

          if (i_pkt_dcnt = (i_pkt_dcnt'range => '0')) then
            i_pkt_rdy <= '0';
            i_fsm_pkt <= S_PKT_IDLE;
          else
            i_pkt_dcnt <= i_pkt_dcnt - 1;
          end if;

      end case;

  end if;
end if;
end process;



p_out_dev_rd(0) <= i_dev_rd;

end architecture behavioral;
