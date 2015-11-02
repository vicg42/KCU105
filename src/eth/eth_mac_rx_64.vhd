-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor (vicg42@gmail.com)
--
-- Create Date : 08.08.2013 18:22:48
-- Module Name : eth_rx
--
-- Extrax from
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.eth_pkg.all;

entity eth_mac_rx is
generic(
G_USRBUF_DWIDTH : integer := 64;
G_AXI_DWIDTH : integer := 64;
G_DBG : string := "OFF"
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg : in TEthCfg;

--------------------------------------
--USR RXBUF <- ETH
--------------------------------------
p_out_rxbuf_di   : out   std_logic_vector(G_USRBUF_DWIDTH - 1 downto 0);
p_out_rxbuf_wr   : out   std_logic;
p_in_rxbuf_full  : in    std_logic;
p_out_rxbuf_sof  : out   std_logic;
p_out_rxbuf_eof  : out   std_logic;

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_in_axi_tdata   : in    std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_axi_tkeep   : in    std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_in_axi_tvalid  : in    std_logic;
p_in_axi_tlast   : in    std_logic;
p_out_axi_tready : out   std_logic;

--------------------------------------------------
--DBG
--------------------------------------------------
p_in_tst  : in    std_logic_vector(31 downto 0);
p_out_tst : out   std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk  : in    std_logic;
p_in_rst  : in    std_logic
);
end entity eth_mac_rx;

architecture behavioral of eth_mac_rx is

type TEth_fsm_rx is (
S_RX_IDLE,
S_RX_CHK,
S_RX_D,
S_RX_END
);
signal i_fsm_eth_rx      : TEth_fsm_rx;

type TEth_rxd8 is array (0 to (G_AXI_DWIDTH / 8) - 1) of std_logic_vector(7 downto 0);
signal sr_ethrx_d        : TEth_rxd8;
signal i_ethrx_d         : TEth_rxd8;
signal i_rx_d            : TEth_rxd8;
signal i_rx_dv           : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);

type TUSR_rxdchunk is array (0 to (G_USRBUF_DWIDTH / G_AXI_DWIDTH) - 1) of std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal i_rx_wr           : std_logic;
signal i_rx_sof          : std_logic;
signal i_rx_eof          : std_logic;
signal i_rxbuf_di        : TUSR_rxdchunk;
signal i_chunk_cnt       : unsigned(selval(1, log2(i_rxbuf_di'length), (i_rxbuf_di'length = 1)) - 1 downto 0);
signal i_rxbuf_wr        : std_logic;
signal i_rxbuf_sof       : std_logic;
signal i_rxbuf_eof       : std_logic;
signal i_rxbuf_sof_en    : std_logic;

signal i_ethrx_mac_dst   : TEthMacAdr;
signal i_ethrx_mac_valid : std_logic_vector(i_ethrx_mac_dst'length - 1 downto 0);

signal i_ethrx_sof       : std_logic;
signal i_ethrx_wren      : std_logic;
signal i_ethrx_de        : std_logic;

signal i_axi_tready      : std_logic;


begin --architecture behavioral of eth_mac_rx is


p_out_axi_tready <= i_axi_tready and (not p_in_rxbuf_full);

gen : for i in 0 to (G_AXI_DWIDTH / i_ethrx_d(0)'length) - 1 generate begin
i_ethrx_d(i) <= p_in_axi_tdata((i_ethrx_d(i)'length * (i + 1)) - 1 downto (i_ethrx_d(i)'length * i));
end generate;


---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_eth_rx <= S_RX_IDLE;

    for i in 0 to i_ethrx_mac_dst'length - 1 loop
    i_ethrx_mac_valid(i) <= '0';
    end loop;

    for i in 0 to i_ethrx_d'length - 1 loop
    sr_ethrx_d(i) <= (others=>'0');
    end loop;

    i_ethrx_sof <= '0';
    i_ethrx_wren <= '0';
    i_ethrx_de <= '0';

    i_axi_tready <= '1';

  elsif (p_in_rxbuf_full = '0') then

      case i_fsm_eth_rx is

        --------------------------------------
        --
        --------------------------------------
        when S_RX_IDLE =>

          i_ethrx_wren <= '0';

          if (p_in_axi_tvalid = '1') then

            for i in 0 to i_ethrx_mac_dst'length - 1 loop
              if (p_in_cfg.mac.src(i) = UNSIGNED(i_ethrx_d(i))) then
                i_ethrx_mac_valid(i) <= '1';
              end if;
            end loop;

            i_fsm_eth_rx <= S_RX_CHK;

          end if;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_CHK =>

          if (p_in_axi_tvalid = '1') then

            --Swap length fiald
            sr_ethrx_d(5) <= i_ethrx_d(4);
            sr_ethrx_d(4) <= i_ethrx_d(5);

            for i in 6 to i_ethrx_d'length - 1 loop
            sr_ethrx_d(i) <= i_ethrx_d(i);
            end loop;

            if (AND_reduce(i_ethrx_mac_valid) = '1') then
            --Valid adress

                i_ethrx_sof <= '1';
                i_ethrx_wren <= '1';

                if (p_in_axi_tlast = '1') then

                  i_ethrx_sof <= '1';

                  if (p_in_axi_tkeep(7 downto 4) /= "0000") then

                    i_axi_tready <= '0';
                    i_ethrx_de <= '1';
                    i_fsm_eth_rx <= S_RX_END;

                  else

                    i_fsm_eth_rx <= S_RX_IDLE;

                  end if;

                else

                  for i in 4 to i_ethrx_d'length - 1 loop
                  sr_ethrx_d(i) <= i_ethrx_d(i);
                  end loop;

                  i_fsm_eth_rx <= S_RX_D;

                end if;

            else
            --Bad adress
                i_axi_tready <= '1';

                if p_in_axi_tlast = '1' then
                  i_fsm_eth_rx <= S_RX_IDLE;
                end if;

            end if;

          end if;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_D =>

          if (p_in_axi_tvalid = '1') then

              i_ethrx_sof <= '0';

              for i in 0 to i_ethrx_d'length - 1 loop
              sr_ethrx_d(i) <= i_ethrx_d(i);
              end loop;

              i_ethrx_wren <= '1';

              if (p_in_axi_tlast = '1') then

                  if (p_in_axi_tkeep(7 downto 4) /= "0000") then

                    i_axi_tready <= '0';
                    i_ethrx_de <= '1';
                    i_fsm_eth_rx <= S_RX_END;

                  else

                    i_fsm_eth_rx <= S_RX_IDLE;

                  end if;

              end if;

          end if;

        when S_RX_END =>

            i_ethrx_wren <= '0';
            i_ethrx_sof <= '0';
            i_ethrx_de <= '0';

            i_axi_tready <= '1';

            i_fsm_eth_rx <= S_RX_IDLE;

      end case;

  end if;
end if;
end process;


i_rx_d(0) <= sr_ethrx_d(4);
i_rx_d(1) <= sr_ethrx_d(5);
i_rx_d(2) <= sr_ethrx_d(6);
i_rx_d(3) <= sr_ethrx_d(7);
i_rx_d(4) <= i_ethrx_d(0);
i_rx_d(5) <= i_ethrx_d(1);
i_rx_d(6) <= i_ethrx_d(2);
i_rx_d(7) <= i_ethrx_d(3);

gen_rx_dv : for i in 0 to i_rx_d'length - 1 generate begin
i_rx_dv((i_rx_d(i)'length * (i + 1)) - 1 downto (i_rx_d(i)'length * i)) <= i_rx_d(i);
end generate gen_rx_dv;

i_rx_wr <= i_ethrx_wren and (not p_in_rxbuf_full) and (p_in_axi_tvalid or i_ethrx_de);
i_rx_sof <= i_ethrx_sof and (not p_in_rxbuf_full) and (p_in_axi_tvalid or i_ethrx_de);
i_rx_eof <= (p_in_axi_tvalid and (not p_in_rxbuf_full)) when p_in_axi_tlast = '1' and OR_reduce(p_in_axi_tkeep(7 downto 4)) = '0' else i_ethrx_de;


process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    for i in 0 to i_rxbuf_di'length - 1 loop
      i_rxbuf_di(i) <= (others => '0');
    end loop;
    i_rxbuf_wr <= '0';
    i_rxbuf_sof_en <= '0';
    i_rxbuf_sof <= '0';
    i_rxbuf_eof <= '0';

    i_chunk_cnt <= (others => '0');

  else
    if (i_rx_wr = '1') then

      if (i_rx_eof = '1') then
        i_chunk_cnt <= (others => '0');
      else
        i_chunk_cnt <= i_chunk_cnt + 1;
      end if;

      for i in 0 to i_rxbuf_di'length - 1 loop
        if (i_chunk_cnt = i) then
          i_rxbuf_di(i) <= i_rx_dv;
        end if;
      end loop;

    end if;

    i_rxbuf_wr <= AND_reduce(i_chunk_cnt) or i_rx_eof;

    i_rxbuf_eof <= i_rx_eof;

    if (i_rx_wr = '1' and i_rx_sof = '1' and i_rx_eof = '1') then
      i_rxbuf_sof <= '1';

    elsif (i_rx_wr = '1' and i_rx_sof = '1' and i_rx_eof = '0') then
      i_rxbuf_sof_en <= '1';

    elsif (i_rx_wr = '1' and i_rxbuf_sof_en = '1' and (AND_reduce(i_chunk_cnt) = '1' or i_rx_eof = '1')) then
      i_rxbuf_sof_en <= '0';
      i_rxbuf_sof <= '1';

    else
      i_rxbuf_sof <= '0';

    end if;

  end if;
end if;
end process;

gen_rxbuf_di : for i in 0 to i_rxbuf_di'length - 1 generate begin
p_out_rxbuf_di((i_rxbuf_di(i)'length * (i + 1)) - 1 downto (i_rxbuf_di(i)'length * i)) <= (i_rxbuf_di(i));
end generate gen_rxbuf_di;
p_out_rxbuf_wr  <= i_rxbuf_wr ;
p_out_rxbuf_sof <= i_rxbuf_sof;
p_out_rxbuf_eof <= i_rxbuf_eof;


------------------------------------
--DBG
------------------------------------
gen_dbg_off : if strcmp(G_DBG,"OFF") generate
p_out_tst(31 downto 0) <= (others=>'0');
end generate gen_dbg_off;

gen_dbg_on : if strcmp(G_DBG,"ON") generate
p_out_tst(31 downto 0) <= (others=>'0');
end generate gen_dbg_on;

end architecture behavioral;

