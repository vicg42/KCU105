-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor (vicg42@gmail.com)
--
-- Create Date : 13.11.2015 10:08:38
-- Module Name : eth_mac_tx
--
-- To user stream data add MacDst and MacSrc
--
-- USR_Port : Len + Data;
-- Eth_Port : MacDst + MacSrc + Len + Data;
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
p_out_usr_axi_done   : out  std_logic;

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
--p_out_dbg : out  TEthDBG_MacTx;

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
S_TX_DE,
S_TX_DONE
);
signal i_fsm_eth_tx        : TEth_fsm_tx;

signal i_total_count_byte  : unsigned(15 downto 0);
signal i_rd_chunk_cnt      : unsigned(15 downto 0);
signal i_rd_chunk_count    : unsigned(15 downto 0);
signal i_rd_chunk_rem      : unsigned(15 downto 0);

constant CI_CHUNK    : integer := 8;
signal sr_txbuf_do         : std_logic_vector((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0));

signal i_eth_axi_tdata     : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal i_eth_axi_tkeep     : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal i_eth_axi_tvalid    : std_logic;
signal i_eth_axi_tlast     : std_logic;

constant CI_MAC_LEN  : integer := 2;--Field Length/Type - count byte
constant CI_ADD      : integer := CI_MAC_LEN;

signal i_usr_axi_done      : std_logic;
signal i_usr_axi_rd        : std_logic;
signal i_usr_axi_rden      : std_logic;

signal tst_fsm  : unsigned(2 downto 0);

signal tst_eth_axi_tready : std_logic;
signal tst_eth_axi_tdata  : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
signal tst_eth_axi_tkeep  : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal tst_eth_axi_tvalid : std_logic;
signal tst_eth_axi_tlast  : std_logic;


begin --architecture behavioral of eth_mac_tx is


i_rd_chunk_count <= RESIZE(i_total_count_byte(i_rd_chunk_count'high downto log2(G_AXI_DWIDTH / CI_CHUNK)), i_rd_chunk_count'length)
              + (TO_UNSIGNED(0, i_rd_chunk_count'length - 2)
                  & OR_reduce(i_total_count_byte(log2(G_AXI_DWIDTH / CI_CHUNK) - 1 downto 0)));

i_rd_chunk_rem <= i_rd_chunk_count((i_total_count_byte'length - log2(G_AXI_DWIDTH / CI_CHUNK)) - 1 downto 0)
                                                    & TO_UNSIGNED(0, (log2(G_AXI_DWIDTH / CI_CHUNK))) - i_total_count_byte;

---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then
    i_fsm_eth_tx <= S_TX_IDLE;

    i_eth_axi_tdata <= (others => '0');
    i_eth_axi_tkeep <= (others => '0');
    i_eth_axi_tvalid <= '0';
    i_eth_axi_tlast <= '0';

    i_total_count_byte <= (others => '0');

    i_rd_chunk_cnt <= (others => '0');

    sr_txbuf_do <= (others => '0');

    i_usr_axi_rden <= '0';

  else

      case i_fsm_eth_tx is

        --------------------------------------
        --WAIT USR DATA
        --------------------------------------
        when S_TX_IDLE =>

          i_eth_axi_tvalid <= '0';
          i_eth_axi_tlast <= '0';

          if (p_in_usr_axi_tvalid = '1') then

              i_total_count_byte((8 * 2) - 1 downto 8 * 0) <= UNSIGNED(p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 0)) + CI_ADD;

              if (UNSIGNED(p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 0)) /= TO_UNSIGNED(0, 16)) then

                i_fsm_eth_tx <= S_TX_ADR0;

              end if;

          end if;

        when S_TX_ADR0 =>

          if (i_usr_axi_rd = '1') then

              i_eth_axi_tdata((CI_CHUNK * 1) - 1 downto CI_CHUNK * 0) <= p_in_cfg.mac.dst(0);
              i_eth_axi_tdata((CI_CHUNK * 2) - 1 downto CI_CHUNK * 1) <= p_in_cfg.mac.dst(1);
              i_eth_axi_tdata((CI_CHUNK * 3) - 1 downto CI_CHUNK * 2) <= p_in_cfg.mac.dst(2);
              i_eth_axi_tdata((CI_CHUNK * 4) - 1 downto CI_CHUNK * 3) <= p_in_cfg.mac.dst(3);
              i_eth_axi_tdata((CI_CHUNK * 5) - 1 downto CI_CHUNK * 4) <= p_in_cfg.mac.dst(4);
              i_eth_axi_tdata((CI_CHUNK * 6) - 1 downto CI_CHUNK * 5) <= p_in_cfg.mac.dst(5);

              i_eth_axi_tdata((CI_CHUNK * 7) - 1 downto CI_CHUNK * 6) <= p_in_cfg.mac.src(0);
              i_eth_axi_tdata((CI_CHUNK * CI_CHUNK) - 1 downto CI_CHUNK * 7) <= p_in_cfg.mac.src(1);

              i_eth_axi_tkeep(7 downto 0) <= "11111111";

              i_eth_axi_tvalid <= '1';
              i_usr_axi_rden <= '1';

              i_fsm_eth_tx <= S_TX_ADR1;

          end if;

        when S_TX_ADR1 =>

          if (i_usr_axi_rd = '1') then

              i_eth_axi_tvalid <= '1';

              i_eth_axi_tdata((CI_CHUNK * 1) - 1 downto CI_CHUNK * 0) <= p_in_cfg.mac.src(2);
              i_eth_axi_tdata((CI_CHUNK * 2) - 1 downto CI_CHUNK * 1) <= p_in_cfg.mac.src(3);
              i_eth_axi_tdata((CI_CHUNK * 3) - 1 downto CI_CHUNK * 2) <= p_in_cfg.mac.src(4);
              i_eth_axi_tdata((CI_CHUNK * 4) - 1 downto CI_CHUNK * 3) <= p_in_cfg.mac.src(5);

              i_eth_axi_tkeep(3 downto 0) <= "1111";

              --!!@@@@@@@@!! Swap length fiald !!@@@@@@@@!!
              i_eth_axi_tdata((CI_CHUNK * 5) - 1 downto CI_CHUNK * 4) <= p_in_usr_axi_tdata((8 * 2) - 1 downto 8 * 1);
              i_eth_axi_tdata((CI_CHUNK * 6) - 1 downto CI_CHUNK * 5) <= p_in_usr_axi_tdata((8 * 1) - 1 downto 8 * 0);

              i_eth_axi_tkeep(5 downto 4) <= "11";

              --Usr Data
              i_eth_axi_tdata((CI_CHUNK * 7) - 1 downto CI_CHUNK * 6) <= p_in_usr_axi_tdata((CI_CHUNK * 3) - 1 downto CI_CHUNK * 2);
              i_eth_axi_tdata((CI_CHUNK * 8) - 1 downto CI_CHUNK * 7) <= p_in_usr_axi_tdata((CI_CHUNK * 4) - 1 downto CI_CHUNK * 3);

              sr_txbuf_do((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0)) <= p_in_usr_axi_tdata((CI_CHUNK * 8) - 1 downto (CI_CHUNK * 4));

              if (i_rd_chunk_cnt = (i_rd_chunk_count - 1)) then

                i_rd_chunk_cnt <= (others => '0');

                if (i_rd_chunk_rem(3 downto 0) < TO_UNSIGNED(4, 4)) then

                  i_eth_axi_tkeep(7 downto 6) <= "11";

                  i_fsm_eth_tx <= S_TX_DE;

                else

                  i_eth_axi_tlast <= '1';

                  case (i_rd_chunk_rem(2 downto 0)) is
                  when "100" => i_eth_axi_tkeep(7 downto 6) <= "11";
                  when "101" => i_eth_axi_tkeep(7 downto 6) <= "01";
                  when others => null;
                  end case;

                  i_fsm_eth_tx <= S_TX_DONE;

                end if;

              else

                i_eth_axi_tkeep(7 downto 6) <= "11";

                i_rd_chunk_cnt <= i_rd_chunk_cnt + 1;

                i_fsm_eth_tx <= S_TX_D;

              end if;

          elsif (p_in_eth_axi_tready = '1' and p_in_usr_axi_tvalid = '0') then

            i_eth_axi_tvalid <= '0';

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_TX_D =>

          if (i_usr_axi_rd = '1') then

            i_eth_axi_tvalid <= '1';

            i_eth_axi_tdata((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0)) <= sr_txbuf_do((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0));
            i_eth_axi_tdata((CI_CHUNK * 8) - 1 downto (CI_CHUNK * 4)) <= p_in_usr_axi_tdata((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0));

            sr_txbuf_do((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0)) <= p_in_usr_axi_tdata((CI_CHUNK * 8) - 1 downto (CI_CHUNK * 4));

            if (i_rd_chunk_cnt = (i_rd_chunk_count - 1)) then

                i_rd_chunk_cnt <= (others => '0');
                i_usr_axi_rden <= '0';

                if i_rd_chunk_rem(3 downto 0) < TO_UNSIGNED(4, 3) then

                  i_fsm_eth_tx <= S_TX_DE;

                else

                  i_eth_axi_tlast <= '1';

                  i_eth_axi_tkeep(3 downto 0) <= (others => '1');

                  case (i_rd_chunk_rem(2 downto 0)) is
                  when "111" => i_eth_axi_tkeep(7 downto 4) <= "0001";
                  when "110" => i_eth_axi_tkeep(7 downto 4) <= "0011";
                  when "101" => i_eth_axi_tkeep(7 downto 4) <= "0111";
                  when "100" => i_eth_axi_tkeep(7 downto 4) <= "1111";
                  when others => null;
                  end case;

                  i_fsm_eth_tx <= S_TX_DONE;

                end if;

            else

              i_rd_chunk_cnt <= i_rd_chunk_cnt + 1;

            end if;

          elsif (p_in_eth_axi_tready = '1' and p_in_usr_axi_tvalid = '0') then

            i_eth_axi_tvalid <= '0';

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_TX_DE =>

          if (p_in_eth_axi_tready = '1') then

            i_eth_axi_tdata((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0)) <= sr_txbuf_do((CI_CHUNK * 4) - 1 downto (CI_CHUNK * 0));
            i_eth_axi_tdata((CI_CHUNK * 8) - 1 downto (CI_CHUNK * 4)) <= (others => '0');

            i_eth_axi_tlast <= '1';

            case (i_rd_chunk_rem(1 downto 0)) is
            when "11" => i_eth_axi_tkeep(3 downto 0) <= "0001";
            when "10" => i_eth_axi_tkeep(3 downto 0) <= "0011";
            when "01" => i_eth_axi_tkeep(3 downto 0) <= "0111";
            when "00" => i_eth_axi_tkeep(3 downto 0) <= "1111";
            when others => null;
            end case;

            i_eth_axi_tkeep(7 downto 4) <= (others => '0');

            i_fsm_eth_tx <= S_TX_DONE;

          end if;


        --------------------------------------
        --
        --------------------------------------
        when S_TX_DONE =>

          i_eth_axi_tvalid <= '0';
          i_eth_axi_tlast <= '0';

          if (p_in_eth_axi_tready = '1') then -- and p_in_usr_axi_tvalid = '0') then

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


i_usr_axi_rd <= (p_in_usr_axi_tvalid) and p_in_eth_axi_tready;
p_out_usr_axi_tready <= i_usr_axi_rd and i_usr_axi_rden;

i_usr_axi_done <= i_eth_axi_tlast and p_in_eth_axi_tready;
p_out_usr_axi_done <= i_usr_axi_done;


--##################################
--DBG
--##################################
--gen_dbg_on : if strcmp(G_DBG,"ON") generate
--p_out_tst(31 downto 0) <= (others => '0');
--end generate gen_dbg_on;

p_out_tst(2 downto 0) <= std_logic_vector(tst_fsm);
p_out_tst(31 downto 3) <= (others => '0');

--p_out_dbg.usr_axi_tready <= i_usr_axi_rd;
--p_out_dbg.usr_axi_tvalid <= p_in_usr_axi_tvalid;
--p_out_dbg.usr_axi_done   <= i_usr_axi_done;
--p_out_dbg.usr_axi_tdata  <= p_in_usr_axi_tdata;

--p_out_dbg.eth_axi_tready <= tst_eth_axi_tready;
--p_out_dbg.eth_axi_tdata  <= tst_eth_axi_tdata;
--p_out_dbg.eth_axi_tkeep  <= tst_eth_axi_tkeep;
--p_out_dbg.eth_axi_tvalid <= tst_eth_axi_tvalid;
--p_out_dbg.eth_axi_tlast  <= tst_eth_axi_tlast;
--
--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--tst_eth_axi_tready <= p_in_eth_axi_tready;
--tst_eth_axi_tdata  <= i_eth_axi_tdata;
--tst_eth_axi_tkeep  <= i_eth_axi_tkeep;
--tst_eth_axi_tvalid <= i_eth_axi_tvalid;
--tst_eth_axi_tlast  <= i_eth_axi_tlast;
--end if;
--end process;

--p_out_dbg.fsm <= std_logic_vector(tst_fsm);

tst_fsm <= TO_UNSIGNED(16#01#, tst_fsm'length) when i_fsm_eth_tx = S_TX_ADR0  else
           TO_UNSIGNED(16#02#, tst_fsm'length) when i_fsm_eth_tx = S_TX_ADR1  else
           TO_UNSIGNED(16#03#, tst_fsm'length) when i_fsm_eth_tx = S_TX_D     else
           TO_UNSIGNED(16#04#, tst_fsm'length) when i_fsm_eth_tx = S_TX_DE    else
           TO_UNSIGNED(16#05#, tst_fsm'length) when i_fsm_eth_tx = S_TX_DONE  else
           TO_UNSIGNED(16#00#, tst_fsm'length);-- when i_fsm_eth_tx = S_TX_IDLE   else

end architecture behavioral;
