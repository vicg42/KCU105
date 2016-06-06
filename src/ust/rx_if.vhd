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
S_RX_TPKT,
S_RX_DPKT,
S_RX_PKT_DONE,
S_RX_PKT_ERR
);
signal i_fsm_pkt_rx   : TFsmPktRx;

type TFsmRqWr is (
S_RQWR_LEN,
S_RQWR_ADR,
S_RQWR_D,
S_RQWR_DONE
);
signal i_fsm_rqwr     : TFsmRqWr;

signal i_ibuf_rd      : std_logic;
signal i_ibuf_rden    : std_logic;

signal i_pkt_den      : std_logic;
signal i_pkt_d        : unsigned(7 downto 0); --byte input
signal i_pkt_type     : unsigned(1 downto 0);
signal i_pkt_dcnt     : unsigned((C_FLEN_BCOUNT * 8) - 1 downto 0);--packet byte cnt
signal i_pkt_dcount   : unsigned((C_FLEN_BCOUNT * 8) - 1 downto 0);--packet byte cnt
signal i_bcnt_a       : unsigned(log2(G_IBUF_DWIDTH / 8) - 1 downto 0);--bus byte cnt
signal i_bcnt_b       : unsigned(7 downto 0);

type TDev is record
s : unsigned(3 downto 0); --subtype
t : unsigned(3 downto 0); --type
n : unsigned(3 downto 0); --num
end record;
signal i_dev          : TDev;
signal i_dev_dcnt     : unsigned((C_FLEN_BCOUNT * 8) - 1 downto 0);
signal i_rqwr_adr     : unsigned(15 downto 0);
signal i_rqwr_di      : unsigned(7 downto 0);
signal i_rqwr_wr      : std_logic;

signal i_err          : std_logic;

constant CI_PKT_DECR : natural := C_TPKT_H2D_HDR_BCOUNT - 1;
constant CI_DEV_DECR : natural := C_DEV_HDR_BCOUNT - 1;


begin --architecture behavioral


p_out_err <= i_err;
p_out_ibuf_axi_tready <= p_in_ibuf_axi_tvalid and i_ibuf_rden and
                          (AND_reduce(i_bcnt_a) or (not OR_reduce(i_pkt_dcnt)));

---------------------------------------------
--Convernt IBUF BUS(Nbit) -> bus 8bit
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_pkt_rx <= S_RX_TPKT;

    i_pkt_den <= '0';
    i_pkt_d <= (others => '0');
    i_pkt_type <= (others => '0');
    i_pkt_dcnt <= (others => '0');
    i_bcnt_a <= (others => '0');
    i_ibuf_rden <= '0';

    i_err <= '0';

  else

      case i_fsm_pkt_rx is

        --------------------------------------
        --
        --------------------------------------
        when S_RX_TPKT =>

          if (p_in_ibuf_axi_tvalid = '1' and p_in_ibuf_axi_tlast = '0') then

              i_pkt_dcnt <= UNSIGNED(p_in_ibuf_axi_tdata(15 downto 0)) - CI_PKT_DECR;
--              i_pkt_dcount <= UNSIGNED(p_in_ibuf_axi_tdata(15 downto 0));

              i_bcnt_a <= TO_UNSIGNED(4, i_bcnt_a'length);

              if (UNSIGNED(p_in_ibuf_axi_tdata((C_FLEN_BCOUNT * 8) - 1 downto 0)) = TO_UNSIGNED(0, (C_FLEN_BCOUNT * 8)) ) then
              --ERROR
                  i_pkt_type <= (others => '0');
                  i_fsm_pkt_rx <= S_RX_PKT_ERR;

              --FPGA -> HOST
              elsif (UNSIGNED(p_in_ibuf_axi_tdata((C_FLEN_BCOUNT * 8) + 8 - 1 downto (C_FLEN_BCOUNT * 8))) = TO_UNSIGNED(C_TPKT_D2H, 8) ) then
                  i_pkt_type <= TO_UNSIGNED(C_TPKT_D2H, i_pkt_type'length);
                  i_ibuf_rden <= '1';
                  i_fsm_pkt_rx <= S_RX_DPKT;

              --FPGA <- HOST
              elsif (UNSIGNED(p_in_ibuf_axi_tdata((C_FLEN_BCOUNT * 8) + 8 - 1 downto (C_FLEN_BCOUNT * 8))) = TO_UNSIGNED(C_TPKT_H2D, 8) ) then
                  i_pkt_type <= TO_UNSIGNED(C_TPKT_H2D, i_pkt_type'length);
                  i_ibuf_rden <= '1';
                  i_fsm_pkt_rx <= S_RX_DPKT;

              else
                  i_pkt_type <= (others => '0');
                  i_fsm_pkt_rx <= S_RX_PKT_ERR;
              end if;

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_RX_DPKT =>

            for idx in 0 to (p_in_ibuf_axi_tdata'length / 8) - 1 loop
              if (i_bcnt_a = idx) then
                i_pkt_d <= UNSIGNED(p_in_ibuf_axi_tdata(8 * (idx + 1) - 1 downto 8 * idx));
              end if;
            end loop;

            if (p_in_ibuf_axi_tvalid = '1') then
                i_pkt_den <= '1';
                i_bcnt_a <= i_bcnt_a + 1;

                if (i_pkt_dcnt = (i_pkt_dcnt'range => '0')) then
                  i_pkt_dcnt <= (others => '0');
                  i_ibuf_rden <= '0';
                  i_fsm_pkt_rx <= S_RX_PKT_DONE;
                else
                  i_pkt_dcnt <= i_pkt_dcnt - 1;
                end if;
            else
              i_pkt_den <= '0';
            end if;

        when S_RX_PKT_DONE =>

          i_pkt_den <= '0';
          i_fsm_pkt_rx <= S_RX_TPKT;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_PKT_ERR =>

          i_err <= '1';

          if (p_in_ibuf_axi_tlast = '1') then
            i_fsm_pkt_rx <= S_RX_TPKT;
          end if;

      end case;

  end if;
end if;
end process;


---------------------------------------------
--
---------------------------------------------
p_out_rqrd_di <= std_logic_vector(i_pkt_d);
p_out_rqrd_wr <= i_pkt_den when i_pkt_type = TO_UNSIGNED(C_TPKT_D2H, i_pkt_type'length) else '0';

---------------------------------------------
--
---------------------------------------------
p_out_rqwr_di <= std_logic_vector(i_pkt_d);
p_out_rqwr_wr <= i_pkt_den when i_pkt_type = TO_UNSIGNED(C_TPKT_H2D, i_pkt_type'length) else '0';

end architecture behavioral;
