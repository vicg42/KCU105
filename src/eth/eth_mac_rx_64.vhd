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
p_out_rxd_sof    : out   std_logic;
p_out_rxd_eof    : out   std_logic;

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

type TEth_rxd is array (0 to (G_AXI_DWIDTH / 8) - 1) of std_logic_vector(7 downto 0);
signal sr_ethrx_d        : TEth_rxd;
signal i_ethrx_d         : TEth_rxd;
signal i_rxbuf_di        : TEth_rxd;

signal i_ethrx_mac_dst   : TEthMacAdr;
signal i_ethrx_mac_valid : std_logic_vector(i_ethrx_mac_dst'length - 1 downto 0);

signal i_ethrx_sof       : std_logic;
signal i_ethrx_wren      : std_logic;
signal i_ethrx_de        : std_logic;

signal i_axi_tready      : std_logic;


begin --architecture behavioral of eth_mac_rx is



p_out_axi_tready <= i_axi_tready and (not p_in_rxbuf_full);

i_rxbuf_di(0) <= sr_ethrx_d(4);
i_rxbuf_di(1) <= sr_ethrx_d(5);
i_rxbuf_di(2) <= sr_ethrx_d(6);
i_rxbuf_di(3) <= sr_ethrx_d(7);
i_rxbuf_di(4) <= i_ethrx_d(0);
i_rxbuf_di(5) <= i_ethrx_d(1);
i_rxbuf_di(6) <= i_ethrx_d(2);
i_rxbuf_di(7) <= i_ethrx_d(3);

gen_rxbuf : for i in 0 to i_rxbuf_di'length - 1 generate begin
p_out_rxbuf_di((32 * (i + 1)) - 1 downto (32 * i)) <= i_rxbuf_di(i);
end generate gen_rxbuf;

p_out_rxbuf_wr <= i_ethrx_wren and (not p_in_rxbuf_full) and (p_in_axi_tvalid or i_ethrx_de);
p_out_rxbuf_sof <= i_ethrx_sof and (not p_in_rxbuf_full) and (p_in_axi_tvalid or i_ethrx_de);
p_out_rxd_eof <= '0';

gen : for i in 0 to (G_AXI_DWIDTH / 8) - 1 generate begin
i_ethrx_d(i) <= p_in_axis_tdata((8 * (i + 1)) - 1 downto (8 * i));
end generate;


gen_mac_check : for i in 0 to p_in_cfg.mac.src'length - 1 generate
i_ethrx_mac_valid(i) <= '1' when i_ethrx_mac_dst(i) = p_in_cfg.mac.src(i) else '0';
--i_ethrx_mac_valid(i) <= '1' when i_ethrx_mac_dst(i) = p_in_cfg.mac.dst(i) else '0';--for TEST
end generate gen_mac_check;

---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_eth_rx <= S_RX_IDLE;

    for i in 0 to i_ethrx_mac_dst'length - 1 loop
    i_ethrx_mac_dst(i) <= (others=>'0');
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
            i_ethrx_mac_dst(i) <= i_ethrx_d(i);
            end loop;

            i_fsm_eth_rx <= S_RX_CHK;

          end if;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_CHK =>

          if (p_in_axi_tvalid = '1') then

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
                  i_ethrx_de <= '1';

                  i_axi_tready <= '0';
                  i_fsm_eth_rx <= S_RX_END;

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

            i_fsm_eth_rx <= S_RX_CHK;

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

              i_usr_rxd((8 * 8) - 1 downto 8 * 5) <= p_in_ethrx_d((8 * 4) - 1 downto 8 * 0);
              i_usr_rxd((8 * 4) - 1 downto 8 * 0) <= sr_ethrx_d;

              i_ethrx_wren <= '1';

              if (p_in_axi_tlast = '1') then

                  if( p_in_axi_tkeep(7 downto 4) /= "0000") then

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

