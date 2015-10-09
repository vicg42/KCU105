-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : switch_data
--
-- Description :
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_def.all;
--use work.eth_pkg.all;

entity switch_data is
generic(
G_ETH_CH_COUNT : integer:=1;
G_ETH_DWIDTH : integer:=32;
G_VBUFI_OWIDTH : integer:=32;
G_HOST_DWIDTH : integer:=32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk     : in   std_logic;

p_in_cfg_adr     : in   std_logic_vector(5 downto 0);
p_in_cfg_adr_ld  : in   std_logic;

p_in_cfg_txdata  : in   std_logic_vector(15 downto 0);
p_in_cfg_wr      : in   std_logic;

p_out_cfg_rxdata : out  std_logic_vector(15 downto 0);
p_in_cfg_rd      : in   std_logic;

-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_eth_htxd_rdy      : in   std_logic;
p_in_eth_htxbuf_di     : in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_htxbuf_wr     : in   std_logic;
p_out_eth_htxbuf_full  : out  std_logic;
p_out_eth_htxbuf_empty : out  std_logic;

--host <- dev
p_out_eth_hrxbuf_do    : out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_eth_hrxbuf_rd     : in   std_logic;
p_out_eth_hrxbuf_full  : out  std_logic;
p_out_eth_hrxbuf_empty : out  std_logic;

p_out_eth_hirq         : out  std_logic;

p_in_hclk              : in   std_logic;

-------------------------------
--ETH
-------------------------------
p_in_eth_tmr_irq       : in   std_logic;
p_in_eth_tmr_en        : in   std_logic;
p_in_eth_clk           : in   std_logic;
----p_in_eth               : in   TEthOUTs;
----p_out_eth              : out  TEthINs;

-------------------------------
--FG_BUFI
-------------------------------
p_in_vbufi_rdclk       : in   std_logic;
p_out_vbufi_do         : out  std_logic_vector(G_VBUFI_OWIDTH - 1 downto 0);
p_in_vbufi_rd          : in   std_logic;
p_out_vbufi_empty      : out  std_logic;
p_out_vbufi_full       : out  std_logic;
p_out_vbufi_pfull      : out  std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst               : in   std_logic_vector(31 downto 0);
p_out_tst              : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst     : in    std_logic
);
end entity switch_data;

architecture behavioral of switch_data is

component fifo_host2eth
port (
din       : in  std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;

dout      : out std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk       : in  std_logic;
srst      : in  std_logic
);
end component;

component fifo_eth2host
port (
din       : in  std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;

dout      : out std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk       : in  std_logic;
srst      : in  std_logic
);
end component;

component fifo_eth2fg
port (
din       : in  std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_VBUFI_OWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

--wr_rst_busy : out std_logic;
--rd_rst_busy : out std_logic;
--
--clk       : in  std_logic;
--srst      : in  std_logic
rst       : in  std_logic
);
end component;

--component pkt_filter
--generic(
--G_DWIDTH : integer := 32;
--G_FRR_COUNT : integer := 3
--);
--port(
----------------------------------------
----CFG
----------------------------------------
--p_in_frr        : in    TEthFRR;
--
----------------------------------------
----Upstream Port
----------------------------------------
--p_in_upp_data   : in    std_logic_vector(G_DWIDTH - 1 downto 0);
--p_in_upp_wr     : in    std_logic;
--p_in_upp_eof    : in    std_logic;
--p_in_upp_sof    : in    std_logic;
--
----------------------------------------
----Downstream Port
----------------------------------------
--p_out_dwnp_data : out   std_logic_vector(G_DWIDTH - 1 downto 0);
--p_out_dwnp_wr   : out   std_logic;
--p_out_dwnp_eof  : out   std_logic;
--p_out_dwnp_sof  : out   std_logic;
--
---------------------------------
----DBG
---------------------------------
--p_in_tst        : in    std_logic_vector(31 downto 0);
--p_out_tst       : out   std_logic_vector(31 downto 0);
--
----------------------------------------
----SYSTEM
----------------------------------------
--p_in_clk        : in    std_logic;
--p_in_rst        : in    std_logic
--);
--end component pkt_filter;

signal i_reg_adr                     : unsigned(p_in_cfg_adr'range);

signal h_reg_ctrl                    : std_logic_vector(C_SWT_REG_CTRL_LAST_BIT downto 0);
signal h_reg_eth2h_frr               : TEthFRR;
signal h_reg_eth2fg_frr              : TEthFRR;

signal b_rst_eth_bufs                : std_logic;
signal b_rst_fg_bufs                 : std_logic;

signal syn_eth_rxd                   : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal syn_eth_rxd_wr                : std_logic;
signal syn_eth_rxd_sof               : std_logic;
signal syn_eth_rxd_eof               : std_logic;
signal syn_eth2h_frr                 : TEthFRR;
signal syn_eth2fg_frr                : TEthFRR;

signal i_eth_tmr_en                  : std_logic;
signal i_eth_tmr_irq                 : std_logic;
signal sr_eth_tx_start               : std_logic_vector(0 to 1);
signal i_eth_txbuf_full              : std_logic;
signal i_eth_txbuf_empty             : std_logic;
signal sr_eth_txbuf_empty            : std_logic;
signal i_eth_rxbuf_full              : std_logic;
signal i_eth_rxbuf_empty             : std_logic;
signal i_eth_rxbuf_fltr_dout         : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal i_eth_rxbuf_fltr_den          : std_logic;
signal i_eth_rxbuf_fltr_eof          : std_logic;
signal i_eth_rx_irq                  : std_logic;
signal sr_eth_rxd_rdy                : std_logic_vector(0 to 1);
signal i_eth_rx_irq_out              : std_logic;
signal i_eth_htxd_rdy                : std_logic;
signal sr_eth_htxd_rdy               : std_logic;
signal i_eth_txbuf_empty_en          : std_logic;
signal sr_eth_rxbuf_fltr_den         : std_logic_vector(0 to 1);

signal tst_txbuf_empty               : std_logic;
signal tst_eth_rxbuf_den             : std_logic;
signal tst_eth_rxbuf_dout            : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);

signal i_vbufi_fltr_dout             : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal i_vbufi_fltr_dout_swap        : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal i_vbufi_fltr_den              : std_logic;
signal i_vbufi_pfull                 : std_logic;
signal i_vbufi_rdclk                 : std_logic;

signal tst_eth_txbuf_do              : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal tst_eth_txbuf_rd              : std_logic;


begin --architecture behavioral of switch_data


----------------------------------------------------
--Register
----------------------------------------------------
--Address counter
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    i_reg_adr <= (others => '0');
  else
    if p_in_cfg_adr_ld = '1' then
      i_reg_adr <= UNSIGNED(p_in_cfg_adr);
    else
      if (p_in_cfg_wr = '1' or p_in_cfg_rd = '1') then
        i_reg_adr <= i_reg_adr + 1;
      end if;
    end if;
  end if;
end if;
end process;

--register wr
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    h_reg_ctrl <= (others => '0');

    for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
      h_reg_eth2h_frr(2 * i) <= (others => '0');
      h_reg_eth2h_frr((2 * i) + 1) <= (others => '0');
    end loop;

    for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
      h_reg_eth2fg_frr(2 * i) <= (others => '0');
      h_reg_eth2fg_frr((2 * i) + 1) <= (others => '0');
    end loop;

  else
    if p_in_cfg_wr = '1' then
        if i_reg_adr = TO_UNSIGNED(C_SWT_REG_CTRL, i_reg_adr'length) then
          h_reg_ctrl <= p_in_cfg_txdata(h_reg_ctrl'high downto 0);

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
            TO_UNSIGNED(C_SWT_REG_FRR_ETH_HOST/C_SWT_FRR_COUNT_MAX
                                    ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH<->HOST
          for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              h_reg_eth2h_frr(2 * i)  <= p_in_cfg_txdata(7 downto 0);
              h_reg_eth2h_frr((2 * i) + 1) <= p_in_cfg_txdata(15 downto 8);
            end if;
          end loop;

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH_FG/C_SWT_FRR_COUNT_MAX
                                  ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH->FG
          for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              h_reg_eth2fg_frr(2 * i)  <= p_in_cfg_txdata(7 downto 0);
              h_reg_eth2fg_frr((2 * i) + 1) <= p_in_cfg_txdata(15 downto 8);
            end if;
          end loop;

        end if;
    end if;
  end if;
end if;
end process;

--register rd
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    p_out_cfg_rxdata <= (others => '0');
  else
    if p_in_cfg_rd = '1' then
        if i_reg_adr = TO_UNSIGNED(C_SWT_REG_CTRL, i_reg_adr'length) then
          p_out_cfg_rxdata <= std_logic_vector(RESIZE(UNSIGNED(h_reg_ctrl), p_out_cfg_rxdata'length));

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH_HOST/C_SWT_FRR_COUNT_MAX
                                    ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH<->HOST
          for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              p_out_cfg_rxdata(7 downto 0) <= h_reg_eth2h_frr(2 * i)  ;
              p_out_cfg_rxdata(15 downto 8) <= h_reg_eth2h_frr((2 * i) + 1);
            end if;
          end loop;

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH_FG/C_SWT_FRR_COUNT_MAX
                                  ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH->FG
          for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              p_out_cfg_rxdata(7 downto 0) <= h_reg_eth2fg_frr(2 * i)  ;
              p_out_cfg_rxdata(15 downto 8) <= h_reg_eth2fg_frr((2 * i) + 1);
            end if;
          end loop;

        end if;
    end if;
  end if;
end if;
end process;


b_rst_eth_bufs <= p_in_rst or h_reg_ctrl(C_SWT_REG_CTRL_RST_ETH_BUFS_BIT);
b_rst_fg_bufs <= p_in_rst or h_reg_ctrl(C_SWT_REG_CTRL_RST_FG_BUFS_BIT);


------Подсинхриваем маски для FltrEthPkt началом прининятого пакета Eth
----process(p_in_eth_clk)
----begin
----if rising_edge(p_in_eth_clk) then
----  if p_in_rst = '1' then
----
----    for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
----      syn_eth2h_frr(2 * i) <= (others => '0');
----      syn_eth2h_frr((2 * i) + 1) <= (others => '0');
----    end loop;
----
----    for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
----      syn_eth2fg_frr(2 * i) <= (others => '0');
----      syn_eth2fg_frr((2 * i) + 1) <= (others => '0');
----    end loop;
----
----    syn_eth_rxd <= (others => '0');
----    syn_eth_rxd_wr <= '0';
----    syn_eth_rxd_sof <= '0';
----    syn_eth_rxd_eof <= '0';
----
----  else
----
----    if p_in_eth(0).rxsof = '1' then
----
----      for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
----        syn_eth2h_frr(2 * i) <= h_reg_eth2h_frr(2 * i);
----        syn_eth2h_frr((2 * i) + 1) <= h_reg_eth2h_frr((2 * i) + 1);
----      end loop;
----
----      for i in 0 to C_SWT_GET_FMASK_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
----        syn_eth2fg_frr(2 * i) <= h_reg_eth2fg_frr(2 * i);
----        syn_eth2fg_frr((2 * i) + 1) <= h_reg_eth2fg_frr((2 * i) + 1);
----      end loop;
----
----    end if;
----
----    syn_eth_rxd <= p_in_eth(0).rxbuf_di;
----    syn_eth_rxd_wr <= p_in_eth(0).rxbuf_wr;
----    syn_eth_rxd_sof <= p_in_eth(0).rxsof;
----    syn_eth_rxd_eof <= p_in_eth(0).rxeof;
----
----  end if;
----end if;
----end process;




--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--Host -> ETHG
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
p_out_eth_htxbuf_empty <= not i_eth_htxd_rdy;
p_out_eth_htxbuf_full <= i_eth_txbuf_full;

--p_out_eth(0).txbuf_full <= i_eth_txbuf_full;
--p_out_eth(0).txbuf_empty <= not (not i_eth_txbuf_empty and i_eth_txbuf_empty_en)
--                            when i_eth_tmr_en = '1' else i_eth_txbuf_empty;

tst_txbuf_empty <= not (not i_eth_txbuf_empty and i_eth_txbuf_empty_en)
                  when i_eth_tmr_en = '1'
                    else (not (not i_eth_txbuf_empty and sr_eth_htxd_rdy));

process(p_in_eth_clk)
begin
if rising_edge(p_in_eth_clk) then
  i_eth_tmr_en <= p_in_eth_tmr_en;
  i_eth_tmr_irq <= p_in_eth_tmr_irq;

  sr_eth_tx_start <= i_eth_tmr_irq & sr_eth_tx_start(0 to 0);
  sr_eth_htxd_rdy <= i_eth_htxd_rdy;

  if i_eth_txbuf_empty = '1' then
    i_eth_txbuf_empty_en <= '0';

  elsif i_eth_tmr_en = '1' and sr_eth_htxd_rdy = '1'
    and sr_eth_tx_start(0) = '1' and sr_eth_tx_start(1) = '0' then

    i_eth_txbuf_empty_en <= '1';
  end if;

end if;
end process;

m_buf_host2eth : fifo_host2eth
port map(
din     => p_in_eth_htxbuf_di,
wr_en   => p_in_eth_htxbuf_wr,
--wr_clk  => p_in_hclk,

dout    => tst_eth_rxbuf_dout,--p_out_eth(0).txbuf_do,
rd_en   => tst_eth_rxbuf_den ,--p_in_eth(0).txbuf_rd ,
--rd_clk  => p_in_eth_clk,

empty   => i_eth_txbuf_empty,
full    => open,
prog_full => i_eth_txbuf_full,

wr_rst_busy => open,
rd_rst_busy => open,

clk     => p_in_hclk,
srst    => b_rst_eth_bufs
);


process(p_in_hclk)
begin
if rising_edge(p_in_hclk) then
  sr_eth_txbuf_empty <= i_eth_txbuf_empty;

  if sr_eth_txbuf_empty = '1' then
    i_eth_htxd_rdy <= '0';

  elsif p_in_eth_htxd_rdy = '1' then
    i_eth_htxd_rdy <= '1';

  end if;
end if;
end process;

----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
----Host <- ETHG
----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--m_eth2host_pkt_fltr: pkt_filter
--generic map(
--G_DWIDTH => G_ETH_DWIDTH,
--G_FRR_COUNT => C_SWT_ETH_HOST_FRR_COUNT
--)
--port map(
----------------------------------------
----CFG
----------------------------------------
--p_in_frr        => syn_eth2h_frr,
--
----------------------------------------
----Upstream Port
----------------------------------------
--p_in_upp_data   => syn_eth_rxd,
--p_in_upp_wr     => syn_eth_rxd_wr,
--p_in_upp_eof    => syn_eth_rxd_eof,
--p_in_upp_sof    => syn_eth_rxd_sof,
--
----------------------------------------
----Downstream Port
----------------------------------------
--p_out_dwnp_data => i_eth_rxbuf_fltr_dout,
--p_out_dwnp_wr   => i_eth_rxbuf_fltr_den,
--p_out_dwnp_eof  => i_eth_rxbuf_fltr_eof,
--p_out_dwnp_sof  => open,
--
---------------------------------
----DBG
---------------------------------
--p_in_tst        => (others=>'0'),
--p_out_tst       => open,
--
----------------------------------------
----SYSTEM
----------------------------------------
--p_in_clk        => p_in_eth_clk,
--p_in_rst        => b_rst_eth_bufs
--);

i_eth_rxbuf_fltr_den  <= tst_eth_rxbuf_den and (not h_reg_ctrl(C_SWT_REG_CTRL_DBG_HOST2FG_BIT));

m_buf_eth2host : fifo_eth2host
port map(
din     => tst_eth_rxbuf_dout, --i_eth_rxbuf_fltr_dout,
wr_en   => i_eth_rxbuf_fltr_den,
--wr_clk  => p_in_eth_clk,

dout    => p_out_eth_hrxbuf_do,
rd_en   => p_in_eth_hrxbuf_rd,
--rd_clk  => p_in_hclk,

empty   => i_eth_rxbuf_empty,
full    => open,
prog_full => i_eth_rxbuf_full,

wr_rst_busy => open,
rd_rst_busy => open,

clk     => p_in_hclk,
srst    => b_rst_eth_bufs
);

p_out_eth_hrxbuf_empty <= i_eth_rxbuf_empty;
p_out_eth_hrxbuf_full <= i_eth_rxbuf_full;

--p_out_eth(0).rxbuf_empty <= i_eth_rxbuf_empty;
--p_out_eth(0).rxbuf_full <= i_vbufi_pfull;

--expand IRQ strobe
process(p_in_eth_clk)
begin
if rising_edge(p_in_eth_clk) then
  if p_in_rst = '1' then
    i_eth_rx_irq <= '0';
    sr_eth_rxd_rdy <= (others => '0');

  else

    sr_eth_rxd_rdy <= i_eth_rxbuf_fltr_eof & sr_eth_rxd_rdy(0 to sr_eth_rxd_rdy'high - 1);

    if (i_eth_rxbuf_fltr_eof = '1') then
      i_eth_rx_irq <= '1';
    elsif (sr_eth_rxd_rdy(sr_eth_rxd_rdy'high) = '1') then
      i_eth_rx_irq <= '0';
    end if;

  end if;
end if;
end process;

--oversample IRQ strobe
process(p_in_hclk)
begin
if rising_edge(p_in_hclk) then
  i_eth_rx_irq_out <= i_eth_rx_irq;
end if;
end process;

p_out_eth_hirq <= i_eth_rx_irq_out;

--for test loopback
process(p_in_eth_clk)
begin
if rising_edge(p_in_eth_clk) then
  if p_in_rst = '1' then
    tst_eth_rxbuf_den <= '0';
    sr_eth_rxbuf_fltr_den <= (others => '0');
    i_eth_rxbuf_fltr_eof <= '0';
  else
    tst_eth_rxbuf_den <= not (tst_txbuf_empty);
    sr_eth_rxbuf_fltr_den <= tst_eth_rxbuf_den & sr_eth_rxbuf_fltr_den(0 to 0);
    i_eth_rxbuf_fltr_eof <= (not sr_eth_rxbuf_fltr_den(0)) and sr_eth_rxbuf_fltr_den(1);
  end if;
end if;
end process;


----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
----EthG->VIDEO_CTRL
----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
----m_eth2fg_pkt_fltr: pkt_filter
----generic map(
----G_DWIDTH => G_ETH_DWIDTH,
----G_FRR_COUNT => C_SWT_ETH_FG_FRR_COUNT
----)
----port map(
------------------------------------------
------CFG
------------------------------------------
----p_in_frr        => syn_eth2fg_frr,
----
------------------------------------------
------Upstream Port
------------------------------------------
----p_in_upp_data   => syn_eth_rxd,
----p_in_upp_wr     => syn_eth_rxd_wr,
----p_in_upp_eof    => syn_eth_rxd_eof,
----p_in_upp_sof    => syn_eth_rxd_sof,
----
------------------------------------------
------Downstream Port
------------------------------------------
----p_out_dwnp_data => i_vbufi_fltr_dout,
----p_out_dwnp_wr   => i_vbufi_fltr_den,
----p_out_dwnp_eof  => open,
----p_out_dwnp_sof  => open,
----
-----------------------------------
------DBG
-----------------------------------
----p_in_tst        => (others=>'0'),
----p_out_tst       => open,
----
------------------------------------------
------SYSTEM
------------------------------------------
----p_in_clk        => p_in_eth_clk,
----p_in_rst        => b_rst_fg_bufs
----);
----
----gen_swap_d : for i in 0 to (i_vbufi_fltr_dout'length / 32) - 1 generate
----i_vbufi_fltr_dout_swap((i_vbufi_fltr_dout_swap'length - (32 * i)) - 1 downto
----                              (i_vbufi_fltr_dout_swap'length - (32 * (i + 1)) ))
----                          <= i_vbufi_fltr_dout((32 * (i + 1)) - 1 downto (32 * i));
----end generate;-- gen_swap_d;

i_vbufi_fltr_den  <= tst_eth_rxbuf_den and (h_reg_ctrl(C_SWT_REG_CTRL_DBG_HOST2FG_BIT)) ;

m_buf_eth2fg : fifo_eth2fg
port map(
din       => tst_eth_rxbuf_dout,--i_vbufi_fltr_dout,
wr_en     => i_vbufi_fltr_den ,
wr_clk    => p_in_eth_clk,

dout      => p_out_vbufi_do,
rd_en     => p_in_vbufi_rd,
rd_clk    => p_in_vbufi_rdclk,

empty     => p_out_vbufi_empty,
full      => p_out_vbufi_full,
prog_full => i_vbufi_pfull,

rst       => b_rst_fg_bufs
);

p_out_vbufi_pfull <= i_vbufi_pfull;


--##################################
--DBG
--##################################
p_out_tst(0) <= b_rst_fg_bufs;
p_out_tst(1) <= '0';
p_out_tst(31 downto 2) <= (others => '0');


end architecture behavioral;
