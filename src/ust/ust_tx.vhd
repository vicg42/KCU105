-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 15.04.2016 11:15:24
-- Module Name : ust_tx
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.ust_pkg.all;

entity ust_tx is
generic(
G_OBUF_COUNT : natural := 1;
G_ETH_AXI_DWIDTH : natural := 64;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--OBUFs
--------------------------------------------------
p_out_obuf_axi_tready : out std_logic_vector(G_OBUF_COUNT - 1 downto 0); --read
p_in_obuf_axi_tdata   : in  std_logic_vector((G_ETH_AXI_DWIDTH * G_OBUF_COUNT) - 1 downto 0);
p_in_obuf_axi_tvalid  : in  std_logic_vector(G_OBUF_COUNT - 1 downto 0); --empty
p_in_obuf_axi_tlast   : in  std_logic_vector(G_OBUF_COUNT - 1 downto 0); --EOF

--------------------------------------------------
--to eth_mac
--------------------------------------------------
p_out_eth_axi_tdata  : out  std_logic_vector(G_ETH_AXI_DWIDTH - 1 downto 0);
p_in_eth_axi_tready  : in   std_logic; --rd obuf
p_out_eth_axi_tvalid : out  std_logic; --obuf_empty
p_in_eth_axi_done    : in   std_logic; --send done

--------------------------------------------------
--
--------------------------------------------------
p_in_eth_clk         : in   std_logic;
p_in_rst : in std_logic
);
end entity ust_tx;

architecture behavioral of ust_tx is

signal i_obuf_sel : unsigned(3 downto 0);
signal i_sel      : unsigned(3 downto 0);


begin --architecture behavioral


p_out_eth_axi_tdata  <= p_in_obuf_axi_tdata((G_ETH_AXI_DWIDTH * (2 + 1)) - 1 downto (G_ETH_AXI_DWIDTH * 2)) when i_obuf_sel = TO_UNSIGNED(3, i_obuf_sel'length) else
                        p_in_obuf_axi_tdata((G_ETH_AXI_DWIDTH * (1 + 1)) - 1 downto (G_ETH_AXI_DWIDTH * 1)) when i_obuf_sel = TO_UNSIGNED(2, i_obuf_sel'length) else
                        p_in_obuf_axi_tdata((G_ETH_AXI_DWIDTH * (0 + 1)) - 1 downto (G_ETH_AXI_DWIDTH * 0));

--obuf_empty
p_out_eth_axi_tvalid <= p_in_obuf_axi_tvalid(2) when i_obuf_sel = TO_UNSIGNED(3, i_obuf_sel'length) else
                        p_in_obuf_axi_tvalid(1) when i_obuf_sel = TO_UNSIGNED(2, i_obuf_sel'length) else
                        p_in_obuf_axi_tvalid(0) when i_obuf_sel = TO_UNSIGNED(1, i_obuf_sel'length) else
                        '0';

--rd obuf
p_out_obuf_axi_tready(2) <= p_in_eth_axi_tready when i_obuf_sel = TO_UNSIGNED(3, i_obuf_sel'length) else '0';
p_out_obuf_axi_tready(1) <= p_in_eth_axi_tready when i_obuf_sel = TO_UNSIGNED(2, i_obuf_sel'length) else '0';
p_out_obuf_axi_tready(0) <= p_in_eth_axi_tready when i_obuf_sel = TO_UNSIGNED(1, i_obuf_sel'length) else '0';


process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_sel <= (others => '0');
    i_obuf_sel <= (others => '0');
    i_fsm_arb <= S_CH_CHK;

  else

      case i_fsm_arb is

        --------------------------------------
        --
        --------------------------------------
        when S_CH_CHK =>

          if (OR_reduce(p_in_obuf_axi_tvalid) = '1') then

            for i in 0 to G_OBUF_COUNT - 1 loop
              if (i = i_sel) then

                  if (p_in_obuf_axi_tvalid(i) = '1') then

                      i_obuf_sel <= TO_UNSIGNED((i + 1), i_obuf_sel'length);
                      i_fsm_arb <= S_CH_WORK;

                  else

                      i_obuf_sel <= (others => '0');

                      if (i_sel = TO_UNSIGNED((G_OBUF_COUNT - 1), i_sel'length) then
                        i_sel <= (others => '0');
                      else
                        i_sel <= i_sel + 1;
                      end if;

                      i_fsm_arb <= S_CH_CHK;

                  end if;

              end if;
            end loop;

          end if;

        when S_CH_WORK =>

          for i in 0 to G_OBUF_COUNT - 1 loop
            if (i = i_sel) then

                if (p_in_obuf_axi_tvalid(i) = '1' and p_in_obuf_axi_tlast(i) = '1') then

                    i_obuf_sel <= (others => '0');

                    if (i_sel = TO_UNSIGNED((G_OBUF_COUNT - 1), i_sel'length) then
                      i_sel <= (others => '0');
                    else
                      i_sel <= i_sel + 1;
                    end if;

                    i_fsm_arb <= S_CH_CHK;

                end if;

            end if;
          end loop;

      end case;

  end if;
end if;
end process;

--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--  if (p_in_rst = '1') then
--
--    i_obuf_sel <= (others => '0');
--    i_fsm_arb <= S_CH0_CHK;
--
--  else
--
--      case i_fsm_arb is
--
--        --------------------------------------
--        --
--        --------------------------------------
--        when S_CH0_CHK =>
--
--          if (p_in_obuf_axi_tvalid(0) = '1') then
--            i_obuf_sel <= TO_UNSIGNED(1, i_obuf_sel'length);
--            i_fsm_arb <= S_CH0_WORK;
--          else
--            i_obuf_sel <= TO_UNSIGNED(0, i_obuf_sel'length);
--            i_fsm_arb <= S_CH1_CHK;
--          end if;
--
--        when S_CH0_WORK =>
--
--          if (p_in_obuf_axi_tvalid(0) = '1' and p_in_obuf_axi_tlast(0) = '1') then
--            i_obuf_sel <= (others => '0');
--            i_fsm_arb <= S_CH1_CHK;
--          end if;
--
--        --------------------------------------
--        --
--        --------------------------------------
--        when S_CH1_CHK =>
--
--          if (p_in_obuf_axi_tvalid(1) = '1' then
--            i_obuf_sel <= TO_UNSIGNED(2, i_obuf_sel'length);
--            i_fsm_arb <= S_CH1_WORK;
--          else
--            i_obuf_sel <= TO_UNSIGNED(0, i_obuf_sel'length);
--            i_fsm_arb <= S_CH2_CHK;
--          end if;
--
--        when S_CH1_WORK =>
--
--          if (p_in_obuf_axi_tvalid(1) = '1' and p_in_obuf_axi_tlast(1) = '1') then
--            i_obuf_sel <= (others => '0');
--            i_fsm_arb <= S_CH2_CHK;
--          end if;
--
--        --------------------------------------
--        --
--        --------------------------------------
--        when S_CH2_CHK =>
--
--          if (p_in_obuf_axi_tvalid(1) = '1' then
--            i_obuf_sel <= TO_UNSIGNED(3, i_obuf_sel'length);
--            i_fsm_arb <= S_CH2_WORK;
--          else
--            i_obuf_sel <= TO_UNSIGNED(0, i_obuf_sel'length);
--            i_fsm_arb <= S_CH0_CHK;
--          end if;
--
--        when S_CH2_WORK =>
--
--          if (p_in_obuf_axi_tvalid(2) = '1' and p_in_obuf_axi_tlast(2) = '1') then
--            i_obuf_sel <= (others => '0');
--            i_fsm_arb <= S_CH0_CHK;
--          end if;
--
--      end case;
--  end if;
--end if;
--end process;

end architecture behavioral;
