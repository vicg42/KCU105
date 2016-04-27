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
p_in_dev_rdrdy  : in   std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);
p_in_dev_d      : in   std_logic_vector(7 downto 0);
p_out_dev_rd    : out  std_logic_vector((G_TDEV_COUNT_MAX * G_NDEV_COUNT_MAX) - 1 downto 0);

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

constant CI_PKT_DLEN_LIMIT : natural := 128;

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
end component;


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
end component;

type TFsmRqRd is (
S_RQRD_IDLE,
S_RQRD_LEN,
S_RQRD_ADR,
S_RQRD_D,
S_RQRD_DONE
);
signal i_fsm_rqrd      : TFsmRqRd;

signal i_ibuf_rd       : std_logic;
signal i_ibuf_rden     : std_logic;

signal i_pkt_den       : std_logic;
signal i_pkt_d         : unsigned(7 downto 0); --byte input
signal i_pkt_type      : unsigned(1 downto 0);
signal i_pkt_dcnt      : unsigned((C_FLEN_BCOUNT * 8) - 1 downto 0);--packet byte cnt
signal i_bcnt_a        : unsigned(log2(G_IBUF_DWIDTH / 8) - 1 downto 0);--bus byte cnt
signal i_bcnt_b        : unsigned(7 downto 0);

signal i_dev_dcnt      : unsigned((C_FLEN_BCOUNT * 8) - 1 downto 0);
signal i_rqwr_adr      : unsigned(15 downto 0);
signal i_rqwr_di       : unsigned(7 downto 0);
signal i_rqwr_wr       : std_logic;

signal i_err           : std_logic;

constant CI_PKT_DECR : natural := C_PKT_H2D_HDR_BCOUNT - 1;
constant CI_DEV_DECR : natural := C_UDEV_HDR_BCOUNT - 1;


begin --architecture behavioral


m_buf_rqrd : fifo_rqrd
port map(
din   => p_in_rqrd_di,
wr_en => p_in_rqrd_wr,

dout  => i_rqbuf_d,
rd_en => i_rqbuf_rd,

full  => i_rqbuf_full,
empty => i_rqbuf_empty,

wr_rst_busy => ope,
rd_rst_busy => ope,

clk => p_in_clk,
srst => p_in_rst
);


m_bufo : bufo_devrd
port map(
addra => i_bufo_adr,
dina  => i_bufo_di
ena   => i_bufo_wr,
wea   => (others => '0'),
clka  => p_in_clk,

addrb : in  std_logic_vector(7 downto 0);
doutb => p_out_obuf_axi_tdata,
enb   : in  std_logic;
clkb  => p_in_clk
);

i_bufo_adr <= i_pkt_dcnt - 1;


---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_rqrd <= S_RQRD_IDLE;
    i_pkt_dcnt <= (others => '0');
    i_dev_adr <= (others => '0');
    i_dev_dcnt <= (others => '0');
    i_bcnt_b <= (others => '0');

  else

      case i_fsm_rqrd is

        when S_RQRD_IDLE =>

          if (i_rqbuf_empty = '0') then
            i_pkt_dcnt <= TO_UNSIGNED(4, i_pkt_dcnt);--sizeof(pkt.len) + sizeof(pkt.header)
            i_fsm_rqwr <= S_RQRD_DLEN;
          end if;

        --------------------------------------
        --Get Param Device read
        --------------------------------------
        when S_RQRD_DLEN =>

          if (i_rqbuf_empty = '0') then
            for idx in 0 to (i_dev_dcnt'length / 8) - 1 loop
              if (i_bcnt_b = idx) then
                i_dev_dcnt(8 * (idx + 1) - 1 downto 8 * idx) <= i_rqbuf_d;
              end if;
            end loop;
            i_rqbuf_rd <= '1';
            i_bufo_wr <= '1';

            i_pkt_dcnt <= i_pkt_dcnt + 1;

            if (i_bcnt_b = TO_UNSIGNED((i_dev_dcnt'length / 8) - 1, i_bcnt_b'length)) then
              i_bcnt_b <= (others => '0');
              i_fsm_rqwr <= S_RQRD_HDR;
            else
              i_bcnt_b <= i_bcnt_b + 1;
            end if;
          else
            i_rqbuf_rd <= '0';
            i_bufo_wr <= '0';
          end if;

        when S_RQRD_HDR =>

          if (i_rqbuf_empty = '0') then
            for idx in 0 to (i_dev_adr'length / 8) - 1 loop
              if (i_bcnt_b = idx) then
                i_dev_adr(8 * (idx + 1) - 1 downto 8 * idx) <= i_rqbuf_d;
              end if;
            end loop;

            i_pkt_dcnt <= i_pkt_dcnt + 1;
            i_bufo_wr <= '1';

            if (i_bcnt_b = TO_UNSIGNED((i_dev_dcnt'length / 8) - 1, i_bcnt_b'length)) then
              i_bcnt_b <= (others => '0');
              i_rqbuf_rd <= '0';
              i_fsm_rqwr <= S_RQRD_HDR;
            else
              i_rqbuf_rd <= '1';
              i_bcnt_b <= i_bcnt_b + 1;
            end if;

            if (i_bcnt_b = (i_bcnt_b'range => '0'))) then
              i_dev_dcnt <= i_dev_dcnt - 2;
            end if;

          else
            i_rqbuf_rd <= '0';
            i_bufo_wr <= '0';
          end if;

        when S_RQRD_CHK =>

          if (i_pkt_dcnt + i_dev_dcnt) <= TO_UNSIGNED(CI_PKT_DLEN_LIMIT, 16)) then

            if (i_dev_dcnt > TO_UNSIGNED(0, i_dev_dcnt'length) ) then
              i_dev_dcnt <= i_dev_dcnt - 1;
              i_fsm_rqwr <= S_DEV_RD;
            else
              i_fsm_rqwr <= S_RQRD_CHK;
            end if;
          else
            i_fsm_rqwr <= S_RQRD_CHK;
          end if;

        --------------------------------------
        --Read Device
        --------------------------------------
        when S_DEV_RD =>

          for t in 0 to G_TDEV_COUNT_MAX - 1 loop
            if (i_tdev = t) then --Detect Type Device

              for n in 0 to G_NDEV_COUNT_MAX - 1 loop
                if (i_ndev = n) then --Detect Number Device

                  if (p_in_dev_rdrdy((t * G_NDEV_COUNT_MAX) + n) = '1') then
                    i_pkt_dcnt <= i_pkt_dcnt + 1;
                    i_dev_rd <= '1';
                    if (i_dev_dcnt = (i_dev_dcnt'range => '0') then
                      i_fsm_rqwr <= S_DEV_DONE;
                    else
                      i_dev_dcnt <= i_dev_dcnt - 1;
                    end if;
                  end if;

                end if;
              end loop;

            end if;
          end loop;


        when S_DEV_DONE =>
          i_dev_rd <= '0';
          i_fsm_rqwr <= S_RQRD_HDR;

      end case;

  end if;
end if;
end process;


i_tdev <= i_dev_adr(3 downto 0); --type device
i_ndev <= i_dev_adr(7 downto 4); --number device


p_in_dev_rdrdy

end architecture behavioral;
