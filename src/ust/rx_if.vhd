-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 11.04.2016 10:31:57
-- Module Name : rx_if
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

entity rx_if is
generic(
G_IBUF_DWIDTH : natural := 64; --min32
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--INPUT
--------------------------------------------------
p_out_ibuf_axi_tready : out  std_logic; --read
p_in_ibuf_axi_tdata   : in   std_logic_vector(G_IBUF_DWIDTH - 1 downto 0);
p_in_ibuf_axi_tvalid  : in   std_logic; --empty
p_in_ibuf_axi_tlast   : in   std_logic; --EOF
--p_in_ibuf_axi_tuser   : in   std_logic_vector(1 downto 0); --(0) - SOF; (1) - EOF

--------------------------------------------------
--DEV
--------------------------------------------------
--request write to dev
p_out_rqwr_di   : out  std_logic_vector(7 downto 0);
p_out_rqwr_adr  : out  std_logic_vector(7 downto 0);
p_out_rqwr_wr   : out  std_logic;
p_in_rqwr_rdy_n : in   std_logic;

--request read from dev
p_out_rqrd_di   : out  std_logic_vector(7 downto 0);
p_out_rqrd_wr   : out  std_logic;
p_in_rqrd_rdy_n : in   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(1 downto 0);
p_in_tst  : in   std_logic_vector(0 downto 0);

p_out_err : out std_logic;
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity rx_if;

architecture behavioral of rx_if is

type TFsmPktRx is (
S_RX_IDLE,
S_RX_D,
S_RX_DONE,
S_RX_ERR
);
signal i_fsm_pkt_rx    : TFsmPktRx;

type TFsmRqWr is (
--S_RQWR_IDLE,
S_RQWR_LEN,
S_RQWR_ADR,
S_RQWR_D
);
signal i_fsm_rqwr      : TFsmRqWr;

signal i_ibuf_rd       : std_logic;
signal i_ibuf_rden     : std_logic;

signal i_pkt_bin_en    : std_logic;
signal i_pkt_bin       : unsigned(7 downto 0); --byte input
signal i_pkt_type      : unsigned(7 downto 0);
signal i_pkt_bcnt      : unsigned(15 downto 0);--packet byte cnt
signal i_pkt_bcount    : unsigned(15 downto 0);--packet byte cnt
signal i_ibuf_bcnt     : unsigned(log2(G_IBUF_DWIDTH / 8) - 1 downto 0);--bus byte cnt

signal i_dev_bcnt      : unsigned(15 downto 0);
signal i_dev_cnt       : unsigned(15 downto 0);
signal i_rqwr_adr      : unsigned(15 downto 0);
signal i_rqwr_di       : unsigned(7 downto 0);
signal i_rqwr_wr       : std_logic;

signal i_err           : std_logic;


begin --architecture behavioral


p_out_err <= i_err;
p_out_ibuf_axi_tready <= p_in_ibuf_axi_tvalid and i_ibuf_rden and
                          (AND_reduce(i_ibuf_bcnt) or (not OR_reduce(i_pkt_bcnt)));

---------------------------------------------
--Convernt IBUF BUS(Nbit) -> bus 8bit
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_pkt_rx <= S_RX_IDLE;

    i_pkt_bin_en <= '0';
    i_pkt_bin <= (others => '0');
    i_pkt_type <= (others => '0');
    i_pkt_bcnt <= (others => '0');
    i_ibuf_bcnt <= (others => '0');
    i_ibuf_rden <= '0';

    i_err <= '0';

  else

      case i_fsm_pkt_rx is

        --------------------------------------
        --
        --------------------------------------
        when S_RX_IDLE =>

          if (p_in_ibuf_axi_tvalid = '1') then

              i_pkt_bcnt <= UNSIGNED(p_in_ibuf_axi_tdata(15 downto 0)) - 3;
              i_ibuf_bcnt <= TO_UNSIGNED(4, i_ibuf_bcnt'length);

              if (UNSIGNED(p_in_ibuf_axi_tdata(C_UST_LPKT_MSB_BIT downto C_UST_LPKT_LSB_BIT)) = TO_UNSIGNED(0, (C_UST_LPKT_MSB_BIT - C_UST_LPKT_LSB_BIT + 1) )) then
                  i_pkt_type <= (others => '0');
                  i_fsm_pkt_rx <= S_RX_ERR;

              elsif (UNSIGNED(p_in_ibuf_axi_tdata(C_UST_TPKT_MSB_BIT downto C_UST_TPKT_LSB_BIT)) = TO_UNSIGNED(C_UST_TPKT_D2H, (C_UST_LPKT_MSB_BIT - C_UST_LPKT_LSB_BIT + 1) )) then
                  i_pkt_type <= TO_UNSIGNED(C_UST_TPKT_D2H, i_pkt_type'length);
                  i_ibuf_rden <= '1';
                  i_fsm_pkt_rx <= S_RX_D;

              elsif (UNSIGNED(p_in_ibuf_axi_tdata(C_UST_TPKT_MSB_BIT downto C_UST_TPKT_LSB_BIT)) = TO_UNSIGNED(C_UST_TPKT_H2D, (C_UST_LPKT_MSB_BIT - C_UST_LPKT_LSB_BIT + 1) )) then
                  i_pkt_type <= TO_UNSIGNED(C_UST_TPKT_H2D, i_pkt_type'length);
                  i_fsm_pkt_rx <= S_RX_D;

              else
                  i_pkt_type <= (others => '0');
                  i_fsm_pkt_rx <= S_RX_ERR;
              end if;

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_RX_D =>

            for idx in 0 to (p_in_ibuf_axi_tdata'length / 8) - 1 loop
              if (i_ibuf_bcnt = idx) then
                i_pkt_bin <= UNSIGNED(p_in_ibuf_axi_tdata(8 * (idx + 1) - 1 downto 8 * idx));
              end if;
            end loop;

            if (p_in_ibuf_axi_tvalid = '1') then
                i_pkt_bin_en <= '1';
                i_ibuf_bcnt <= i_ibuf_bcnt + 1;

                if (i_pkt_bcnt = (i_pkt_bcnt'range => '0')) then
                  i_pkt_bcnt <= (others => '0');
                  i_ibuf_rden <= '0';
                  i_fsm_pkt_rx <= S_RX_DONE;
                else
                  i_pkt_bcnt <= i_pkt_bcnt - 1;
                end if;
            end if;

        when S_RX_DONE =>

          i_pkt_bin_en <= '0';
          i_fsm_pkt_rx <= S_RX_IDLE;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_ERR =>
          i_err <= '1';

      end case;

  end if;
end if;
end process;


---------------------------------------------
--
---------------------------------------------
p_out_rqrd_di <= std_logic_vector(i_pkt_bin);
p_out_rqrd_wr <= i_pkt_bin_en when i_pkt_type = TO_UNSIGNED(C_UST_TPKT_D2H, i_pkt_type'length) else '0';

---------------------------------------------
--
---------------------------------------------
p_out_rqwr_di <= std_logic_vector(i_rqwr_di);
p_out_rqwr_adr <= std_logic_vector(i_rqwr_adr(7 downto 0));
p_out_rqwr_wr <= i_rqwr_wr;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_rqwr <= S_RQWR_LEN;

    i_dev_bcnt <= (others => '0');

    i_rqwr_adr <= (others => '0');
    i_rqwr_di <= (others => '0');
    i_rqwr_wr <= '0';

    i_dev_cnt <= (others => '0');

  elsif (i_pkt_type = C_UST_TPKT_H2D) then

      case i_fsm_rqwr is

        --------------------------------------
        --
        --------------------------------------
--        when S_RQWR_IDLE =>
--
--          i_rqwr_wr <= '0';
--
--          if (i_pkt_bin_en = '1') then
--              i_dev_bcount(7 downto 0) <= i_pkt_bin;
--
--              i_fsm_rqwr <= S_RQWR_LEN;
--          end if;

        when S_RQWR_LEN =>

          if (i_pkt_bin_en = '1') then
--              i_dev_bcount(15 downto 8) <= i_pkt_bin;

              for idx in 0 to (i_dev_bcnt'length / 8) - 1 loop
                if (i_dev_cnt = idx) then
                  i_dev_bcnt(8 * (idx + 1) - 1 downto 8 * idx) <= i_pkt_bin;
                end if;
              end loop;

              if (i_dev_cnt = TO_UNSIGNED((i_dev_bcnt'length / 8) - 1, i_dev_cnt'length)) then
                i_dev_cnt <= (others => '0');
                i_fsm_rqwr <= S_RQWR_ADR;
              else
                i_dev_cnt <= i_dev_cnt + 1;
              end if;

          end if;

        when S_RQWR_ADR =>

          if (i_pkt_bin_en = '1') then
--              i_dev_bcnt <= i_dev_bcnt + 2;
--              i_rqwr_adr <= i_pkt_bin;--dev_num(7..4) & dev_type(3..0)

              for idx in 0 to (i_rqwr_adr'length / 8) - 1 loop
                if (i_dev_cnt = idx) then
                  i_rqwr_adr(8 * (idx + 1) - 1 downto 8 * idx) <= i_pkt_bin;
                end if;
              end loop;

              if (i_dev_cnt = TO_UNSIGNED((i_rqwr_adr'length / 8) - 1, i_dev_cnt'length)) then
                i_dev_cnt <= (others => '0');
                i_dev_bcnt <= i_dev_bcnt + 1;
                i_fsm_rqwr <= S_RQWR_D;
              else
                i_dev_cnt <= i_dev_cnt + 1;
              end if;

          end if;

        when S_RQWR_D =>

          if (i_pkt_bin_en = '1') then
              i_rqwr_di <= i_pkt_bin;
              i_rqwr_wr <= '1';

              if (i_dev_bcnt = (i_dev_bcnt'range => '0')) then
                i_fsm_rqwr <= S_RQWR_LEN;
              else
                i_dev_bcnt <= i_dev_bcnt - 1;
              end if;
          end if;

      end case;

  else

    i_rqwr_wr <= '0';

  end if;
end if;
end process;

end architecture behavioral;
