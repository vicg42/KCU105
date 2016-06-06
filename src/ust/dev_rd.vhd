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
G_SDEV_COUNT_MAX : natural := 16;
G_TDEV_COUNT_MAX : natural := 16;
G_NDEV_COUNT_MAX : natural := 2;
G_OBUF_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--RQRD (Len + DEVID; Len + DEVID....)
--------------------------------------------------
p_in_rq_di     : in   std_logic_vector(7 downto 0);
p_in_rq_wr     : in   std_logic;
p_out_rq_rdy_n : out  std_logic;

--------------------------------------------------
--DEV
--------------------------------------------------
p_in_dev_drdy : in  TDevB; --data ready
p_in_dev_d    : in  TDevD; --data
p_out_dev_rd  : out TDevB; --read

--------------------------------------------------
--EthTx
--------------------------------------------------
p_in_obuf_axi_tready  : in  std_logic; --read
p_out_obuf_axi_tdata  : out std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
p_out_obuf_axi_tvalid : out std_logic; --empty
p_out_obuf_axi_tlast  : out std_logic; --EOF

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

constant CI_BUFO_ADR_MAX : natural := 2048; --byte
component bufo_devrd
port (
addra : in  std_logic_vector(log2(CI_BUFO_ADR_MAX) - 1 downto 0);
dina  : in  std_logic_vector(7 downto 0);
ena   : in  std_logic;
wea   : in  std_logic_vector(0 downto 0);
clka  : in  std_logic;

addrb : in  std_logic_vector(log2(CI_BUFO_ADR_MAX / (G_OBUF_DWIDTH / 8)) - 1 downto 0);
doutb : out std_logic_vector(G_OBUF_DWIDTH - 1 downto 0);
enb   : in  std_logic;
clkb  : in  std_logic
);
end component bufo_devrd;

component fifo_rdpkt_out
port (
s_aclk        : in  std_logic;
s_aresetn     : in  std_logic;
s_axis_tvalid : in  std_logic;
s_axis_tready : out std_logic;
s_axis_tdata  : in  std_logic_vector(63 downto 0);
s_axis_tlast  : in  std_logic;

m_axis_tvalid : out std_logic;
m_axis_tready : in  std_logic;
m_axis_tdata  : out std_logic_vector(63 downto 0);
m_axis_tlast  : out std_logic
);
end component fifo_rdpkt_out;


type TFsmRqRd is (
S_RQ_IDLE,
S_RQ_LEN,
S_RQ_ID,
S_RQ_RDY,
S_RQ_WAIT
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
S_PKT_DEV_DONE2,

S_PKT_SET_HDR0,
S_PKT_SET_HDR1,
S_PKT_SET_HDR2,
S_PKT_SET_HDR3,
S_PKT_RDY,
S_PKT_RD
);

type TRqRd is record
id : unsigned(15 downto 0);
plsize : unsigned(15 downto 0); --sizeof(DevHeader + DevData)
pktsize : unsigned(15 downto 0);--sizeof(Len + DevHeader + DevData)
rdy : std_logic;
end record;

type TDev is record
s : unsigned(3 downto 0); --subtype
t : unsigned(3 downto 0); --type
n : unsigned(3 downto 0); --num
dsize : unsigned(15 downto 0);--sizeof(DevData only)
busy : std_logic;
end record;

signal i_fsm_rq       : TFsmRqRd;
signal i_fsm_pkt      : TFsmPkt;

signal i_rqfifo_rden   : std_logic;
signal i_rqfifo_rd     : std_logic;
signal i_rqfifo_do      : std_logic_vector(7 downto 0);
signal i_rqfifo_full   : std_logic;
signal i_rqfifo_empty  : std_logic;

signal i_rq           : TRqRd;
signal i_rq_len       : unsigned(15 downto 0);
signal i_rq_id        : unsigned(15 downto 0);
signal i_bcnt         : unsigned(log2(i_rq_len'length / 8) - 1 downto 0);--bus byte cnt
signal i_dcnt         : unsigned(15 downto 0);

signal i_dev          : TDev;
signal i_dev_hdr      : unsigned(7 downto 0);
signal i_dev_hdr_wr   : std_logic;
signal i_dev_cs       : TDevB;
signal i_dev_d        : std_logic_vector(7 downto 0);
signal i_dev_dwr      : std_logic_vector((G_SDEV_COUNT_MAX * G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);

signal i_pkt_id       : unsigned(15 downto 0);
signal i_pkt_dcnt     : unsigned(15 downto 0);
signal i_pkt_hdr      : unsigned(7 downto 0);
signal i_pkt_hdr_wr   : std_logic;
signal i_pkt_rdy      : std_logic;
signal i_pkt_len      : unsigned(15 downto 0);
signal i_pkt_rdcnt    : unsigned(15 downto 0);

signal i_bufo_adr     : unsigned(15 downto 0);
signal i_bufo_di      : unsigned(7 downto 0);
signal i_bufo_wr      : std_logic;
signal i_bufo_rd      : std_logic;
signal i_bufo_do      : std_logic_vector(63 downto 0);

signal i_fifo_out_wr    : std_logic := '0';
signal i_fifo_out_empty : std_logic;
signal i_rstn           : std_logic;


begin --architecture behavioral


---------------------------------------------
--Read request
---------------------------------------------
m_buf_rqrd : fifo_rqrd
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

i_rqfifo_rd <= i_rqfifo_rden and (not i_rqfifo_empty);

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_rq <= S_RQ_IDLE;

    i_rqfifo_rden <= '0';

    i_rq_len <= (others => '0');
    i_rq_id <= (others => '0');
    i_bcnt <= (others => '0');

    i_rq.id <= (others => '0');
    i_rq.plsize <= (others => '0');
    i_rq.pktsize <= (others => '0');
    i_rq.rdy <= '0';

  else

      case i_fsm_rq is

        when S_RQ_IDLE =>

          i_rq.rdy <= '0';

          if (i_rqfifo_empty = '0' and i_dev.busy = '0') then
            i_rqfifo_rden <= '1';
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
              i_rqfifo_rden <= '0';
              i_fsm_rq <= S_RQ_RDY;
            else
              i_bcnt <= i_bcnt + 1;
            end if;

          end if;

        when S_RQ_RDY =>

            i_rq.id <= i_rq_id;
            i_rq.plsize <= i_rq_len;
            i_rq.pktsize <= i_rq_len + 2;
            i_rq.rdy <= '1';
            i_fsm_rq <= S_RQ_WAIT;

        when S_RQ_WAIT =>

          if (i_dev.busy = '1') then
          i_rq.rdy <= '0';
            i_fsm_rq <= S_RQ_IDLE;
          end if;

      end case;

  end if;
end if;
end process;

i_dev.s <= i_rq.id( 3 downto 0); --subtype device
i_dev.t <= i_rq.id( 7 downto 4); --type device
i_dev.n <= i_rq.id(11 downto 8); --number device

i_pkt_id(7 downto 0) <= TO_UNSIGNED(16#BB#, 8); --
i_pkt_id(15 downto 8) <= TO_UNSIGNED(16#CC#, 8);


--------------------------------------------------
--Set Read Packet
--------------------------------------------------
m_bufo : bufo_devrd
port map(
addra => std_logic_vector(i_bufo_adr(log2(CI_BUFO_ADR_MAX) - 1 downto 0)),
dina  => std_logic_vector(i_bufo_di),
ena   => i_bufo_wr,
wea   => "1",
clka  => p_in_clk,

addrb => std_logic_vector(i_bufo_adr(log2(CI_BUFO_ADR_MAX / (G_OBUF_DWIDTH / 8)) - 1 downto 0)),
doutb => i_bufo_do,
enb   => i_bufo_rd,
clkb  => p_in_clk
);

i_bufo_di <= i_dev_hdr when (i_dev_hdr_wr = '1') and (i_pkt_hdr_wr = '0') else
             i_pkt_hdr when (i_dev_hdr_wr = '0') and (i_pkt_hdr_wr = '1') else
             UNSIGNED(i_dev_d);

i_bufo_wr <= (i_dev_hdr_wr or i_pkt_hdr_wr) or (OR_reduce(i_dev_dwr));

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_pkt <= S_PKT_IDLE;

    i_dcnt <= (others => '0');

    i_dev.busy <= '0';
    i_dev.dsize <= (others => '0');
    i_dev_d <= (others => '0');

    for s in 0 to G_SDEV_COUNT_MAX - 1 loop
        for t in 0 to G_TDEV_COUNT_MAX - 1 loop
            for n in 0 to G_NDEV_COUNT_MAX - 1 loop
              i_dev_cs(s)(t)(n) <= '0';
            end loop;
        end loop;
    end loop;

    i_bufo_rd <= '0';
    i_bufo_adr <= (others => '0');
    i_pkt_dcnt <= (others => '0');
    i_pkt_rdcnt <= (others => '0');
    i_pkt_len <= (others => '0');

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
            i_bufo_adr <= TO_UNSIGNED(3, i_bufo_adr'length);
            i_pkt_dcnt <= TO_UNSIGNED(4, i_pkt_dcnt'length);--sizeof(pkt.len) + sizeof(pkt.header)
            i_dev.dsize <= i_rq.plsize - 2; --Only sizeof(DATA). Without sizeof(DevHeader)
            i_fsm_pkt <= S_PKT_CHK;
          end if;

        --------------------------------------
        --continue set RD Packet
        --------------------------------------
        when S_PKT_IDLE2 =>

          if (i_rq.rdy = '1') then
            i_dev.busy <= '1';
            i_dev.dsize <= i_rq.plsize - 2; --Only sizeof(DATA). Without sizeof(DevHeader)
            i_fsm_pkt <= S_PKT_CHK;
          end if;

        --------------------------------------
        --Check length of RD Packet
        --------------------------------------
        when S_PKT_CHK =>

          if ((i_pkt_dcnt + i_rq.pktsize) <= TO_UNSIGNED(CI_PKT_LEN_LIMIT, 16)) then
            --read device
            i_dev_hdr <= i_rq.plsize(7 downto 0);
            i_dev_hdr_wr <= '1';

            i_fsm_pkt <= S_PKT_DEV_HDR0;
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
          i_dev_hdr <= i_rq.plsize(15 downto 8);
          i_fsm_pkt <= S_PKT_DEV_HDR1;

        when S_PKT_DEV_HDR1 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr <= i_rq.id(7 downto 0);
          i_fsm_pkt <= S_PKT_DEV_HDR2;

        when S_PKT_DEV_HDR2 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr(6 downto 0) <= i_rq.id(14 downto 8);
          i_dev_hdr(7) <= '0';--#####################################!!!!!! ###############
          i_fsm_pkt <= S_PKT_DEV_HDR3;

        when S_PKT_DEV_HDR3 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_dcnt <= i_pkt_dcnt + 1;
          i_dev_hdr_wr <= '0';

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

          i_fsm_pkt <= S_PKT_DEV_RD;

        when S_PKT_DEV_RD =>

          for s in 0 to G_SDEV_COUNT_MAX - 1 loop --SubType Device
            if (i_dev.s = s) then
              for t in 0 to G_TDEV_COUNT_MAX - 1 loop --Type Device
                if (i_dev.t = t) then
                  for n in 0 to G_NDEV_COUNT_MAX - 1 loop --Number Device
                    if (i_dev.n = n) then

                        if (p_in_dev_drdy(s)(t)(n) = '1') then
                            i_dev_d <= p_in_dev_d(s)(t)(n);
                            if (i_dcnt = (i_dev.dsize - 1)) then
                              i_dev_cs(s)(t)(n) <= '0';
                              i_dcnt <= (others => '0');
                              i_fsm_pkt <= S_PKT_DEV_DONE;
                            else
                              i_dcnt <= i_dcnt + 1;
                            end if;
                        end if;

                    end if;
                  end loop;
                end if;
              end loop;
            end if;
          end loop;

          if (OR_reduce(i_dev_dwr) = '1') then
            i_bufo_adr <= i_bufo_adr + 1;
            i_pkt_dcnt <= i_pkt_dcnt + 1;
          end if;

        when S_PKT_DEV_DONE =>

          i_dev.busy <= '0';

          if (OR_reduce(i_dev_dwr) = '1') then
            i_bufo_adr <= i_bufo_adr + 1;
            i_pkt_dcnt <= i_pkt_dcnt + 1;
          end if;

          if (i_rq.id(15) = '1') then --Last RD request
            --Send RD Packet
            i_fsm_pkt <= S_PKT_DEV_DONE2;
          else
            i_fsm_pkt <= S_PKT_IDLE2;
          end if;

        when S_PKT_DEV_DONE2 =>

          i_pkt_len <= i_pkt_dcnt - 2;
          i_pkt_rdcnt <= RESIZE(i_pkt_dcnt(i_pkt_dcnt'high downto log2(G_OBUF_DWIDTH / 8))
                                                                                , i_pkt_rdcnt'length)
                           + (TO_UNSIGNED(0, i_pkt_rdcnt'length - 2)
                              & OR_reduce(i_pkt_dcnt(log2(G_OBUF_DWIDTH / 8) - 1 downto 0)));

          i_fsm_pkt <= S_PKT_SET_HDR0;

        --------------------------------------
        --Set RD Packet header (len + ID) and Send It
        --------------------------------------
        when S_PKT_SET_HDR0 =>

          i_bufo_adr <= (others => '0');
          i_pkt_hdr <= i_pkt_len(7 downto 0);
          i_pkt_hdr_wr <= '1';
          i_fsm_pkt <= S_PKT_SET_HDR1;

        when S_PKT_SET_HDR1 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_len(15 downto 8);
          i_fsm_pkt <= S_PKT_SET_HDR2;

        when S_PKT_SET_HDR2 =>

          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_id(7 downto 0);
          i_fsm_pkt <= S_PKT_SET_HDR3;

        when S_PKT_SET_HDR3 =>


          i_bufo_adr <= i_bufo_adr + 1;
          i_pkt_hdr <= i_pkt_id(15 downto 8);
          i_fsm_pkt <= S_PKT_RDY;

        when S_PKT_RDY =>

          i_bufo_adr <= (others => '0');
          i_pkt_hdr_wr <= '0';
          i_bufo_rd <= '1';
          i_fsm_pkt <= S_PKT_RD;

        when S_PKT_RD =>

          i_bufo_adr <= i_bufo_adr + 1;

          if (i_dcnt = (i_pkt_rdcnt - 1)) then
            i_bufo_rd <= '0';
            i_fsm_pkt <= S_PKT_IDLE;
          else
            i_dcnt <= i_dcnt + 1;
          end if;

      end case;

  end if;
end if;
end process;


gen_sdev : for s in 0 to G_SDEV_COUNT_MAX - 1 generate begin
  gen_tdev : for t in 0 to G_TDEV_COUNT_MAX - 1 generate begin
    gen_ndev : for n in 0 to G_NDEV_COUNT_MAX - 1 generate begin

      p_out_dev_rd(s)(t)(n) <= p_in_dev_drdy(s)(t)(n) and i_dev_cs(s)(t)(n);

      process(p_in_clk)
      begin
      if rising_edge(p_in_clk) then
        if (p_in_rst = '1') then
          i_dev_dwr((s * G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) + (t * G_NDEV_COUNT_MAX) + n) <= '0';
        else
          i_dev_dwr((s * G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) + (t * G_NDEV_COUNT_MAX) + n) <= p_in_dev_drdy(s)(t)(n) and i_dev_cs(s)(t)(n);
        end if;
      end if;
      end process;

    end generate gen_ndev;
  end generate gen_tdev;
end generate gen_sdev;



---------------------------------------------
--FIFO output
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  i_fifo_out_wr <= i_bufo_rd;
end if;
end process;

i_rstn <= not p_in_rst;

m_fifo_out : fifo_rdpkt_out
port map(
s_aclk        => p_in_clk,
s_aresetn     => i_rstn,

s_axis_tvalid => i_fifo_out_wr   ,
s_axis_tready => i_fifo_out_empty,
s_axis_tdata  => i_bufo_do,
s_axis_tlast  => '0',

m_axis_tvalid => p_out_obuf_axi_tvalid, --: out std_logic;
m_axis_tready => p_in_obuf_axi_tready , --: in  std_logic;
m_axis_tdata  => p_out_obuf_axi_tdata , --: out std_logic_vector(63 downto 0);
m_axis_tlast  => p_out_obuf_axi_tlast   --: out std_logic
);


end architecture behavioral;
