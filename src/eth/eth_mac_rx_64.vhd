-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor (vicg42@gmail.com)
--
-- Create Date : 13.11.2015 10:08:49
-- Module Name : eth_mac_rx
--
-- From eth stream data extract MacDst + MacSrc
--
-- Eth_Port : MacDst + MacSrc + Len + Data;
-- USR_Port : Len + Data;
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.prj_def.all;

entity eth_mac_rx is
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
--USR RXBUF <- ETH
--------------------------------------
p_in_usr_axi_tready  : in   std_logic;
p_out_usr_axi_tdata  : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_out_usr_axi_tkeep  : out  std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_out_usr_axi_tvalid : out  std_logic;
p_out_usr_axi_tuser  : out  std_logic_vector(1 downto 0);

--------------------------------------
--ETH core (Rx)
--------------------------------------
p_out_eth_axi_tready : out  std_logic;
p_in_eth_axi_tdata   : in   std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_eth_axi_tkeep   : in   std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
p_in_eth_axi_tvalid  : in   std_logic;
p_in_eth_axi_tlast   : in   std_logic;

--------------------------------------
--DBG
--------------------------------------
p_in_tst  : in    std_logic_vector(31 downto 0);
p_out_tst : out   std_logic_vector(31 downto 0);
--p_out_dbg : out   TEthDBG_MacRx;

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk  : in  std_logic;
p_in_rst  : in  std_logic
);
end entity eth_mac_rx;

architecture behavioral of eth_mac_rx is

type TEth_fsm_rx is (
S_RX_IDLE,
S_RX_CHK,
S_RX_D,
S_RX_END,
S_RX_WAIT
);
signal i_fsm_eth_rx      : TEth_fsm_rx;

type TEth_rxd8 is array (0 to (G_AXI_DWIDTH / 8) - 1) of std_logic_vector(7 downto 0);
signal sr_eth_axi_data   : TEth_rxd8;
signal i_eth_axi_data    : TEth_rxd8;
signal i_rx_d            : TEth_rxd8;
signal i_rx_dv           : std_logic_vector(G_AXI_DWIDTH - 1 downto 0);

signal i_rx_wr           : std_logic;
signal i_rx_sof          : std_logic;
signal i_rx_eof          : std_logic;
signal i_usr_axi_tvalid  : std_logic;

signal i_ethrx_mac_valid : std_logic_vector(5 downto 0);
signal i_ethrx_len       : std_logic_vector(15 downto 0);
signal i_ethrx_dbe       : std_logic_vector((G_AXI_DWIDTH / 8) - 1 downto 0);
signal i_ethrx_sof       : std_logic;
signal i_ethrx_eof       : std_logic;
signal i_ethrx_wren      : std_logic;
signal i_usr_axi_de      : std_logic;

signal i_eth_axi_tready  : std_logic;
signal i_eth_axi_tready_out: std_logic;

signal tst_fsm : unsigned(2 downto 0);



begin --architecture behavioral of eth_mac_rx is

p_out_eth_axi_tready <= i_eth_axi_tready_out;
i_eth_axi_tready_out <= i_eth_axi_tready and (p_in_usr_axi_tready);

gen : for i in 0 to (G_AXI_DWIDTH / i_eth_axi_data(0)'length) - 1 generate begin
i_eth_axi_data(i) <= p_in_eth_axi_tdata((i_eth_axi_data(i)'length * (i + 1)) - 1 downto (i_eth_axi_data(i)'length * i));
end generate;


--######## !!!! Swap length fiald !!! ##########
i_ethrx_len(15 downto 8) <= i_eth_axi_data(4);
i_ethrx_len(7  downto 0) <= i_eth_axi_data(5);

---------------------------------------------
--
---------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_eth_rx <= S_RX_IDLE;

    for i in 0 to i_ethrx_mac_valid'length - 1 loop
    i_ethrx_mac_valid(i) <= '0';
    end loop;

    for i in 0 to i_eth_axi_data'length - 1 loop
    sr_eth_axi_data(i) <= (others => '1');
    end loop;

    i_ethrx_dbe <= (others => '0');

    i_ethrx_sof <= '0';
    i_ethrx_eof <= '0';
    i_ethrx_wren <= '0';
    i_usr_axi_de <= '0';

    i_eth_axi_tready <= '1';

  elsif (p_in_usr_axi_tready = '1') then

      case i_fsm_eth_rx is

        --------------------------------------
        --
        --------------------------------------
        when S_RX_IDLE =>

          i_ethrx_wren <= '0';
          i_ethrx_sof <= '0';
          i_ethrx_eof <= '0';

          if (p_in_eth_axi_tvalid = '1') then

            for i in 0 to i_ethrx_mac_valid'length - 1 loop
            if strcmp(G_DBG, "LOOPBACK") then

              if (p_in_cfg.mac.dst(i) = i_eth_axi_data(i)) then
                i_ethrx_mac_valid(i) <= '1';
              end if;

            else

              if (p_in_cfg.mac.src(i) = i_eth_axi_data(i)) then
                i_ethrx_mac_valid(i) <= '1';
              end if;

            end if;
            end loop;

            i_fsm_eth_rx <= S_RX_CHK;

          end if;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_CHK =>

          if (p_in_eth_axi_tvalid = '1') then

            sr_eth_axi_data(4) <= i_ethrx_len(7 downto 0);
            sr_eth_axi_data(5) <= i_ethrx_len(15 downto 8);

            for i in 6 to i_eth_axi_data'length - 1 loop
            sr_eth_axi_data(i) <= i_eth_axi_data(i);
            end loop;

            if (AND_reduce(i_ethrx_mac_valid) = '1')
              and (UNSIGNED(i_ethrx_len) <= TO_UNSIGNED(16#600#, i_ethrx_len'length)) then
            --Valid adress + Field Length/Type of MAC frame is Length

                i_ethrx_wren <= '1';
                i_ethrx_sof <= '1';

                if (p_in_eth_axi_tlast = '1') then

                  i_ethrx_eof <= '1';

                  i_ethrx_dbe(3 downto 0) <= p_in_eth_axi_tkeep(7 downto 4);
                  i_ethrx_dbe(7 downto 4) <= (others => '0');

                  i_fsm_eth_rx <= S_RX_IDLE;

                else

                  i_ethrx_dbe <= (others => '1');
                  i_fsm_eth_rx <= S_RX_D;

                end if;

            else
            --Bad (don`t write current packet to USR RXBUF)
                i_eth_axi_tready <= '1';

                if (p_in_eth_axi_tlast = '1') then
                  i_fsm_eth_rx <= S_RX_IDLE;
                else
                  i_fsm_eth_rx <= S_RX_WAIT;
                end if;

            end if;

          end if;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_D =>

          if (p_in_eth_axi_tvalid = '1') then

              i_ethrx_sof <= '0';

              for i in 0 to i_eth_axi_data'length - 1 loop
              sr_eth_axi_data(i) <= i_eth_axi_data(i);
              end loop;

              i_ethrx_wren <= '1';

              if (p_in_eth_axi_tlast = '1') then

                  if (p_in_eth_axi_tkeep(7 downto 4) /= "0000") then

                    i_eth_axi_tready <= '0';

                    i_usr_axi_de <= '1';

                    i_ethrx_dbe(3 downto 0) <= p_in_eth_axi_tkeep(7 downto 4);
                    i_ethrx_dbe(7 downto 4) <= (others => '0');

                    i_fsm_eth_rx <= S_RX_END;

                  else

                    i_fsm_eth_rx <= S_RX_IDLE;

                  end if;

              end if;

          end if;

        when S_RX_END =>

            i_ethrx_wren <= '0';
            i_ethrx_sof <= '0';
            i_usr_axi_de <= '0';

            i_eth_axi_tready <= '1';

            i_fsm_eth_rx <= S_RX_IDLE;

        --------------------------------------
        --
        --------------------------------------
        when S_RX_WAIT =>

            if (p_in_eth_axi_tvalid = '1' and p_in_eth_axi_tlast = '1') then

              i_fsm_eth_rx <= S_RX_IDLE;

            end if;

      end case;

  end if;
end if;
end process;


i_rx_d(0) <= sr_eth_axi_data(4);
i_rx_d(1) <= sr_eth_axi_data(5);
i_rx_d(2) <= sr_eth_axi_data(6);
i_rx_d(3) <= sr_eth_axi_data(7);
i_rx_d(4) <= i_eth_axi_data(0);
i_rx_d(5) <= i_eth_axi_data(1);
i_rx_d(6) <= i_eth_axi_data(2);
i_rx_d(7) <= i_eth_axi_data(3);

i_rx_wr <= i_ethrx_wren and (p_in_usr_axi_tready) and (p_in_eth_axi_tvalid or i_usr_axi_de);
i_rx_sof <= i_ethrx_sof and (p_in_usr_axi_tready) and (p_in_eth_axi_tvalid or i_usr_axi_de);
i_rx_eof <= (p_in_eth_axi_tvalid and (p_in_usr_axi_tready)) when p_in_eth_axi_tlast = '1'
                                                                  and OR_reduce(p_in_eth_axi_tkeep(7 downto 4)) = '0'
                                                            else i_usr_axi_de or i_ethrx_eof;

gen_rxbuf_di : for i in 0 to i_rx_d'length - 1 generate begin
p_out_usr_axi_tdata((i_rx_d(i)'length * (i + 1)) - 1 downto (i_rx_d(i)'length * i)) <= i_rx_d(i);
end generate gen_rxbuf_di;

p_out_usr_axi_tkeep <= (p_in_eth_axi_tkeep(3 downto 0) & "1111") when p_in_eth_axi_tlast = '1'
                                                                  and OR_reduce(p_in_eth_axi_tkeep(7 downto 4)) = '0'
                                                            else i_ethrx_dbe;

p_out_usr_axi_tvalid <= i_rx_wr;
p_out_usr_axi_tuser(0) <= i_rx_sof;
p_out_usr_axi_tuser(1) <= i_rx_eof;


--##################################
--DBG
--##################################
--gen_dbg_on : if strcmp(G_DBG,"ON") generate
--p_out_tst(31 downto 0) <= (others => '0');
--end generate gen_dbg_on;

p_out_tst(2 downto 0) <= std_logic_vector(tst_fsm);
p_out_tst(31 downto 3) <= (others => '0');

--p_out_dbg.eth_axi_tdata  <= p_in_eth_axi_tdata;
--p_out_dbg.eth_axi_tkeep  <= p_in_eth_axi_tkeep;
--
--p_out_dbg.eth_axi_tvalid <= p_in_eth_axi_tvalid;
--p_out_dbg.eth_axi_tlast  <= p_in_eth_axi_tlast;
--
--p_out_dbg.usr_axi_tvalid <= i_rx_wr;
--p_out_dbg.usr_axi_tuser  <= i_rx_eof & i_rx_sof;
--
--p_out_dbg.fsm <= std_logic_vector(tst_fsm);

tst_fsm <= TO_UNSIGNED(16#01#, tst_fsm'length) when i_fsm_eth_rx = S_RX_WAIT  else
           TO_UNSIGNED(16#02#, tst_fsm'length) when i_fsm_eth_rx = S_RX_END   else
           TO_UNSIGNED(16#03#, tst_fsm'length) when i_fsm_eth_rx = S_RX_D     else
           TO_UNSIGNED(16#04#, tst_fsm'length) when i_fsm_eth_rx = S_RX_CHK   else
           TO_UNSIGNED(16#00#, tst_fsm'length);-- when i_fsm_eth_rx = S_RX_IDLE   else


end architecture behavioral;

