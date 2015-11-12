-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor (vicg42@gmail.com)
--
-- Create Date : 01.05.2011 16:43:52
-- Module Name : eth_mac_tx
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.eth_pkg.all;

entity eth_mac_tx is
generic(
G_AXI_DWIDTH : integer := 64;
G_DBG : string := "OFF"
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_cfg : in  TEthCfg;

--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_usr_axi_tdata   : in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_usr_axi_tready : out  std_logic;
p_in_usr_axi_tvalid  : in   std_logic;

--------------------------------------
--ETH core (Tx)
--------------------------------------
p_in_eth_axi_tready  : in   std_logic;
p_out_eth_axi_tdata  : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_eth_axi_tkeep  : out  std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_out_eth_axi_tvalid : out  std_logic;
p_out_eth_axi_tlast  : out  std_logic;

--------------------------------------
--DBG
--------------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk : in  std_logic;
p_in_rst : in  std_logic
);
end entity eth_mac_tx;

architecture behavioral of eth_mac_tx is

type TEth_fsm_tx is (
S_TX_IDLE,
S_TX_ADR0,
S_TX_ADR1,
S_TX_D,
S_TX_END
);
signal i_fsm_eth_tx        : TEth_fsm_tx;

signal i_usr_payload_byte  : unsigned(15 downto 0);
signal i_total_count_byte  : unsigned(15 downto 0);
signal i_rd_chunk_cnt      : unsigned(15 downto 0);
signal i_rd_chunk_count    : unsigned(15 downto 0);
signal i_rd_chunk_rem      : unsigned(15 downto 0);

signal sr_txbuf_do         : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);

signal i_eth_axi_tdata     : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal i_eth_axi_tkeep     : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal i_eth_axi_tvalid    : std_logic;
signal i_eth_axi_tlast     : std_logic;

constant CI_MAC_LEN  : integer := 2;
constant CI_MAC_DST  : integer := 6;
constant CI_MAC_SRC  : integer := 6;
constant CI_ADD      : integer := CI_MAC_LEN + CI_MAC_DST + CI_MAC_SRC;



begin --architecture behavioral of eth_mac_tx is


i_rd_chunk_count <= RESIZE(i_total_count_byte(i_rd_chunk_count'high downto log2(G_AXI_DWIDTH / 8)), i_rd_chunk_count'length)
              + (TO_UNSIGNED(0, i_rd_chunk_count'length - 2)
                  & OR_reduce(i_total_count_byte(log2(G_AXI_DWIDTH / 8) - 1 downto 0)));

i_rd_chunk_rem <= i_rd_chunk_count((i_total_count_byte'length - log2(G_AXI_DWIDTH / 8)) - 1 downto 0)
                                                    & TO_UNSIGNED(0, (log2(G_AXI_DWIDTH / 8))) - i_total_count_byte;

---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '0' then
    i_fsm_eth_tx <= S_TX_IDLE;

    i_eth_axi_tdata <= (others => '0');
    i_eth_axi_tkeep <= (others => '0');
    i_eth_axi_tvalid <= '0';
    i_eth_axi_tlast <= '0';

    i_total_count_byte <= (others => '0');

    i_rd_chunk_cnt <= (others => '0');

    sr_txbuf_do <= (others => '0');

  else

      case i_fsm_eth_tx is

        --------------------------------------
        --WAIT USR DATA
        --------------------------------------
        when S_TX_IDLE =>

          i_eth_axi_tvalid <= '0';
          i_eth_axi_tlast <= '0';

          i_rd_chunk_cnt <= (others =>'0');

          if (p_in_usr_axi_tvalid = '1') then

              i_total_count_byte((8 * 2) - 1 downto 8 * 0) <= UNSIGNED(p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 0)) + CI_ADD;

              if UNSIGNED(p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 0)) /= TO_UNSIGNED(0, 16) then

                i_fsm_eth_tx <= S_TX_ADR0;

              end if;

          end if;

        when S_TX_ADR0 =>

          if (p_in_eth_axi_tready = '1' and p_in_usr_axi_tvalid = '1') then

              i_eth_axi_tdata((8 * 1) - 1 downto 8 * 0) <= p_in_cfg.mac.dst(0);
              i_eth_axi_tdata((8 * 2) - 1 downto 8 * 1) <= p_in_cfg.mac.dst(1);
              i_eth_axi_tdata((8 * 3) - 1 downto 8 * 2) <= p_in_cfg.mac.dst(2);
              i_eth_axi_tdata((8 * 4) - 1 downto 8 * 3) <= p_in_cfg.mac.dst(3);
              i_eth_axi_tdata((8 * 5) - 1 downto 8 * 4) <= p_in_cfg.mac.dst(4);
              i_eth_axi_tdata((8 * 6) - 1 downto 8 * 5) <= p_in_cfg.mac.dst(5);

              i_eth_axi_tdata((8 * 7) - 1 downto 8 * 6) <= p_in_cfg.mac.src(0);
              i_eth_axi_tdata((8 * 8) - 1 downto 8 * 7) <= p_in_cfg.mac.src(1);

              i_eth_axi_tkeep(7 downto 0) <= "11111111";

              i_eth_axi_tvalid <= '1';

              i_rd_chunk_cnt <= i_rd_chunk_cnt + 1;

              i_fsm_eth_tx <= S_TX_ADR1;

          end if;

        when S_TX_ADR1 =>

          if (p_in_eth_axi_tready = '1' and p_in_usr_axi_tvalid = '1') then

              i_eth_axi_tdata((8 * 1) - 1 downto 8 * 0) <= p_in_cfg.mac.src(2);
              i_eth_axi_tdata((8 * 2) - 1 downto 8 * 1) <= p_in_cfg.mac.src(3);
              i_eth_axi_tdata((8 * 3) - 1 downto 8 * 2) <= p_in_cfg.mac.src(4);
              i_eth_axi_tdata((8 * 4) - 1 downto 8 * 3) <= p_in_cfg.mac.src(5);

              --!!@@@@@@@@!! Swap length fiald !!@@@@@@@@!!
              i_eth_axi_tdata((8 * 5) - 1 downto 8 * 4) <= p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 1);
              i_eth_axi_tdata((8 * 6) - 1 downto 8 * 5) <= p_in_usr_axi_tdata((8 * 1) - 1 downto 8 * 0);

              i_eth_axi_tkeep(5 downto 0) <= "111111";

              --Usr Data
              i_eth_axi_tdata((8 * 7) - 1 downto 8 * 6) <= p_in_usr_axi_tdata((8 * 3) - 1 downto 8 * 2);
              i_eth_axi_tdata((8 * 8) - 1 downto 8 * 7) <= p_in_usr_axi_tdata((8 * 4) - 1 downto 8 * 3);

              sr_txbuf_do((8 * 4) - 1 downto (8 * 0)) <= p_in_usr_axi_tdata((8 * 8) - 1 downto (8 * 4));

              if (i_rd_chunk_cnt = (i_rd_chunk_count - 1)) then

                if (i_rd_chunk_rem(2 downto 0) <= TO_UNSIGNED(2, 3)) then

                  i_eth_axi_tlast <= '1';

                  case (i_rd_chunk_rem(1 downto 0)) is
                  when "10" => i_eth_axi_tkeep(7 downto 6) <= "00";
                  when "01" => i_eth_axi_tkeep(7 downto 6) <= "01";
                  when "00" => i_eth_axi_tkeep(7 downto 6) <= "11";
                  when others => null;
                  end case;

                  i_fsm_eth_tx <= S_TX_IDLE;

                else

                  i_fsm_eth_tx <= S_TX_END;

                end if;

              else

                i_eth_axi_tkeep(7 downto 6) <= "11";
                i_rd_chunk_cnt <= i_rd_chunk_cnt + 1;
                i_fsm_eth_tx <= S_TX_D;

              end if;

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_TX_D =>

          if (p_in_eth_axi_tready = '1' and p_in_usr_axi_tvalid = '1') then

            if (i_rd_chunk_cnt = (i_rd_chunk_count - 1)) then

                if i_rd_chunk_rem(2 downto 0) <= TO_UNSIGNED(4, 3) then

                  i_eth_axi_tlast <= '1';

                  case (i_rd_chunk_rem(2 downto 0)) is
                  when "111" => i_eth_axi_tkeep(7 downto 0) <= "00000001";
                  when "110" => i_eth_axi_tkeep(7 downto 0) <= "00000011";
                  when "101" => i_eth_axi_tkeep(7 downto 0) <= "00000111";
                  when "100" => i_eth_axi_tkeep(7 downto 0) <= "00001111";
                  when "011" => i_eth_axi_tkeep(7 downto 0) <= "00011111";
                  when "010" => i_eth_axi_tkeep(7 downto 0) <= "00111111";
                  when "001" => i_eth_axi_tkeep(7 downto 0) <= "01111111";
                  when "000" => i_eth_axi_tkeep(7 downto 0) <= "11111111";
                  when others => null;
                  end case;

                  i_fsm_eth_tx <= S_TX_IDLE;

                else
                  i_fsm_eth_tx <= S_TX_END;
                end if;

            else
              i_rd_chunk_cnt <= i_rd_chunk_cnt + 1;
            end if;

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_TX_END =>

          if (p_in_eth_axi_tready = '1') then

            i_eth_axi_tlast <= '1';

            case (i_rd_chunk_rem(2 downto 0)) is
            when "111" => i_eth_axi_tkeep(7 downto 0) <= "00000001";
            when "110" => i_eth_axi_tkeep(7 downto 0) <= "00000011";
            when "101" => i_eth_axi_tkeep(7 downto 0) <= "00000111";
            when "100" => i_eth_axi_tkeep(7 downto 0) <= "00001111";
            when "011" => i_eth_axi_tkeep(7 downto 0) <= "00011111";
            when "010" => i_eth_axi_tkeep(7 downto 0) <= "00111111";
            when "001" => i_eth_axi_tkeep(7 downto 0) <= "01111111";
            when "000" => i_eth_axi_tkeep(7 downto 0) <= "11111111";
            when others => null;
            end case;

            i_fsm_eth_tx <= S_TX_IDLE;

          end if;

      end case;
  end if;
end if;
end process;

p_out_eth_axi_tdata <= i_eth_axi_tdata;
p_out_eth_axi_tkeep <= i_eth_axi_tkeep;
p_out_eth_axi_tvalid <= i_eth_axi_tvalid;
p_out_eth_axi_tlast <= i_eth_axi_tlast;


p_out_usr_axi_tready <= (p_in_usr_axi_tvalid) and p_in_eth_axi_tready and i_eth_axi_tvalid;


------------------------------------
--DBG
------------------------------------
gen_dbg_off : if strcmp(G_DBG,"OFF") generate
p_out_tst(31 downto 0) <= (others => '0');
end generate gen_dbg_off;

gen_dbg_on : if strcmp(G_DBG,"ON") generate
p_out_tst(31 downto 0) <= (others => '0');
end generate gen_dbg_on;

end architecture behavioral;
