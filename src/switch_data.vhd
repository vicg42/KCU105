-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor (vicg42@gmail.com)
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : switch_data
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;
use work.prj_def.all;
use work.eth_pkg.all;

entity switch_data is
generic(
G_ETH_CH_COUNT : integer := 1;
G_ETH_DWIDTH : integer := 32;
G_FGBUFI_DWIDTH : integer := 32;
G_HOST_DWIDTH : integer := 32
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

--rxbuf <- eth
p_out_ethio_rx_axi_tready : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tdata   : in   std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tkeep   : in   std_logic_vector(((G_ETH_DWIDTH / 8) * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_rx_axi_tvalid  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rx_axi_tuser   : in   std_logic_vector((2 * G_ETH_CH_COUNT) - 1 downto 0);

--txbuf -> eth
p_out_ethio_tx_axi_tdata  : out  std_logic_vector((G_ETH_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_ethio_tx_axi_tready  : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_ethio_tx_axi_tvalid : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_tx_axi_done    : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

p_in_ethio_clk            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_ethio_rst            : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--FG_BUFI
-------------------------------
p_out_fgbufi_do    : out  std_logic_vector((G_FGBUFI_DWIDTH * G_ETH_CH_COUNT) - 1 downto 0);
p_in_fgbufi_rd     : in   std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_in_fgbufi_rdclk  : in   std_logic;
p_out_fgbufi_empty : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_full  : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
p_out_fgbufi_pfull : out  std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

-------------------------------
--DBG
-------------------------------
p_in_tst  : in   std_logic_vector(31 downto 0);
p_out_tst : out  std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst  : in    std_logic
);
end entity switch_data;

architecture behavioral of switch_data is

component fifo_host2eth
port (
din       : in  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

rst       : in  std_logic

--wr_rst_busy : out std_logic;
--rd_rst_busy : out std_logic;
--
--clk       : in  std_logic;
--srst      : in  std_logic
);
end component fifo_host2eth;

component fifo_eth2host
port (
din       : in  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

--rst       : in  std_logic

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

--clk       : in  std_logic;
srst      : in  std_logic
);
end component fifo_eth2host;

component fifo_eth2fg
port (
din       : in  std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_FGBUFI_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;

--rst       : in  std_logic

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

--clk       : in  std_logic;
srst      : in  std_logic
);
end component fifo_eth2fg;

component pkt_filter
generic(
G_DWIDTH : integer := 32;
G_FRR_COUNT : integer := 3
);
port(
--------------------------------------
--CFG
--------------------------------------
p_in_frr        : in    TEthFRR;

--------------------------------------
--Upstream Port
--------------------------------------
p_in_upp_data   : in    std_logic_vector(G_DWIDTH - 1 downto 0);
p_in_upp_wr     : in    std_logic;
p_in_upp_eof    : in    std_logic;
p_in_upp_sof    : in    std_logic;

--------------------------------------
--Downstream Port
--------------------------------------
p_out_dwnp_data : out   std_logic_vector(G_DWIDTH - 1 downto 0);
p_out_dwnp_wr   : out   std_logic;
p_out_dwnp_eof  : out   std_logic;
p_out_dwnp_sof  : out   std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst        : in    std_logic_vector(31 downto 0);
p_out_tst       : out   std_logic_vector(31 downto 0);

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk        : in    std_logic;
p_in_rst        : in    std_logic
);
end component pkt_filter;

signal i_reg_adr              : unsigned(p_in_cfg_adr'range);

signal h_reg_dbg              : std_logic_vector(C_SWT_REG_DBG_LAST_BIT downto 0);
signal h_reg_ctrl             : std_logic_vector(C_SWT_REG_CTRL_LAST_BIT downto 0);
signal h_reg_eth2h_frr        : TEthFRR;
signal h_reg_eth2fg_frr       : TEthFRR;

signal b_rst_eth_bufs         : std_logic;
signal b_rst_fg_bufs          : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

Type TEthCH_d is array (0 to G_ETH_CH_COUNT - 1) of std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
Type TEthCH_fgfrr is array (0 to G_ETH_CH_COUNT - 1) of TEthFRR;

signal syn_eth_rxd            : TEthCH_d;
signal syn_eth_rxd_wr         : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal syn_eth_rxd_sof        : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal syn_eth_rxd_eof        : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);
signal syn_eth2h_frr          : TEthCH_fgfrr;
signal syn_eth2fg_frr         : TEthCH_fgfrr;

signal i_eth_tmr_en           : std_logic;
signal i_eth_tmr_irq          : std_logic;
signal sr_eth_tx_start        : std_logic_vector(0 to 1);
signal i_eth_txbuf_full       : std_logic;
signal i_eth_txbuf_empty      : std_logic;
signal i_eth_rxbuf_full       : std_logic;
signal i_eth_rxbuf_empty      : std_logic;
signal i_eth_fltr_do          : std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal i_eth_fltr_den         : std_logic;
signal i_eth_fltr_eof         : std_logic;
signal sr_eth_fltr_eof        : std_logic_vector(0 to 3);
signal i_eth_rx_irq           : std_logic;
signal i_eth_rx_irq_out       : std_logic;
signal i_eth_htxd_rdy         : std_logic;
signal sr_eth_htxd_rdy        : std_logic;
signal i_eth_txbuf_empty_en   : std_logic;

type TEth2h_chunk is array (0 to (G_HOST_DWIDTH / G_ETH_DWIDTH) - 1)
                                               of std_logic_vector(G_ETH_DWIDTH - 1 downto 0);
signal i_eth2h_chunk          : TEth2h_chunk;
signal i_eth2h_chunk_cnt      : unsigned(selval(1, log2(i_eth2h_chunk'length), (i_eth2h_chunk'length = 1)) - 1 downto 0);
signal i_eth2h_wr             : std_logic;
signal i_eth2h_di             : std_logic_vector(G_HOST_DWIDTH - 1 downto 0);

signal i_fgbuf_fltr_do        : TEthCH_d;
signal i_fgbuf_fltr_den       : std_logic_vector(G_ETH_CH_COUNT - 1 downto 0);

signal i_h2eth_buf_rst        : std_logic;


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
    h_reg_dbg <= (others => '0');

    for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
      h_reg_eth2h_frr(2 * i) <= (others => '0');
      h_reg_eth2h_frr((2 * i) + 1) <= (others => '0');
    end loop;

    for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
      h_reg_eth2fg_frr(2 * i) <= (others => '0');
      h_reg_eth2fg_frr((2 * i) + 1) <= (others => '0');
    end loop;

  else
    if p_in_cfg_wr = '1' then
        if i_reg_adr = TO_UNSIGNED(C_SWT_REG_CTRL, i_reg_adr'length) then
          h_reg_ctrl <= p_in_cfg_txdata(h_reg_ctrl'high downto 0);

        elsif i_reg_adr = TO_UNSIGNED(C_SWT_REG_DBG, i_reg_adr'length) then
          h_reg_dbg <= p_in_cfg_txdata(h_reg_dbg'high downto 0);

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
            TO_UNSIGNED(C_SWT_REG_FRR_ETH2HOST/C_SWT_FRR_COUNT_MAX
                                    ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH<->HOST
          for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              h_reg_eth2h_frr(2 * i)  <= p_in_cfg_txdata(7 downto 0);
              h_reg_eth2h_frr((2 * i) + 1) <= p_in_cfg_txdata(15 downto 8);
            end if;
          end loop;

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH2FG/C_SWT_FRR_COUNT_MAX
                                  ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH->FG
          for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
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

        elsif i_reg_adr = TO_UNSIGNED(C_SWT_REG_DBG, i_reg_adr'length) then
          p_out_cfg_rxdata <= std_logic_vector(RESIZE(UNSIGNED(h_reg_dbg), p_out_cfg_rxdata'length));

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH2HOST/C_SWT_FRR_COUNT_MAX
                                    ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH<->HOST
          for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
            if i_reg_adr(log2(C_SWT_FRR_COUNT_MAX) - 1 downto 0) = i then
              p_out_cfg_rxdata(7 downto 0) <= h_reg_eth2h_frr(2 * i)  ;
              p_out_cfg_rxdata(15 downto 8) <= h_reg_eth2h_frr((2 * i) + 1);
            end if;
          end loop;

        elsif i_reg_adr(i_reg_adr'high downto log2(C_SWT_FRR_COUNT_MAX)) =
          TO_UNSIGNED(C_SWT_REG_FRR_ETH2FG/C_SWT_FRR_COUNT_MAX
                                  ,(i_reg_adr'high - log2(C_SWT_FRR_COUNT_MAX) + 1)) then
        --Mask pkt filter: ETH->FG
          for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
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


process(p_in_ethio_clk(0))
begin
if rising_edge(p_in_ethio_clk(0)) then
b_rst_eth_bufs <= p_in_rst or h_reg_ctrl(C_SWT_REG_CTRL_RST_ETH_BUFS_BIT);
end if;
end process;


--
gen_frr_syn : for eth_ch in 0 to (G_ETH_CH_COUNT - 1) generate
begin

process(p_in_ethio_clk(eth_ch))
begin
if rising_edge(p_in_ethio_clk(eth_ch)) then
  if (p_in_ethio_rst(eth_ch) = '1') then

    for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
      syn_eth2h_frr(eth_ch)(2 * i) <= (others => '0');
      syn_eth2h_frr(eth_ch)((2 * i) + 1) <= (others => '0');
    end loop;

    for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
      syn_eth2fg_frr(eth_ch)(2 * i) <= (others => '0');
      syn_eth2fg_frr(eth_ch)((2 * i) + 1) <= (others => '0');
    end loop;

    syn_eth_rxd(eth_ch) <= (others => '0');
    syn_eth_rxd_wr(eth_ch) <= '0';
    syn_eth_rxd_sof(eth_ch) <= '0';
    syn_eth_rxd_eof(eth_ch) <= '0';

  else

    if (p_in_ethio_rx_axi_tuser((2 * eth_ch) + 1) = '1') then
    --eof

      for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_HOST_FRR_COUNT) - 1 loop
        syn_eth2h_frr(eth_ch)(2 * i) <= h_reg_eth2h_frr(2 * i);
        syn_eth2h_frr(eth_ch)((2 * i) + 1) <= h_reg_eth2h_frr((2 * i) + 1);
      end loop;

      for i in 0 to C_SWT_GET_FRR_REG_COUNT(C_SWT_ETH_FG_FRR_COUNT) - 1 loop
        syn_eth2fg_frr(eth_ch)(2 * i) <= h_reg_eth2fg_frr(2 * i);
        syn_eth2fg_frr(eth_ch)((2 * i) + 1) <= h_reg_eth2fg_frr((2 * i) + 1);
      end loop;

    end if;

    syn_eth_rxd(eth_ch) <= p_in_ethio_rx_axi_tdata((G_ETH_DWIDTH * (eth_ch + 1)) - 1 downto (G_ETH_DWIDTH * eth_ch));
    syn_eth_rxd_wr(eth_ch) <= p_in_ethio_rx_axi_tvalid(eth_ch);
    syn_eth_rxd_sof(eth_ch) <= p_in_ethio_rx_axi_tuser((2 * eth_ch) + 0);
    syn_eth_rxd_eof(eth_ch) <= p_in_ethio_rx_axi_tuser((2 * eth_ch) + 1);

  end if;
end if;
end process;

end generate gen_frr_syn;



--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--Host -> ETHG
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
p_out_eth_htxbuf_empty <= not i_eth_htxd_rdy;
p_out_eth_htxbuf_full <= i_eth_txbuf_full;

process(p_in_ethio_tx_axi_done(0), p_in_hclk)
begin
if (p_in_ethio_tx_axi_done(0) = '1') then
  i_eth_htxd_rdy <= '0';

elsif rising_edge(p_in_hclk) then

  if (p_in_eth_htxd_rdy = '1') then
    i_eth_htxd_rdy <= '1';
  end if;

end if;
end process;

p_out_ethio_tx_axi_tvalid(0) <= not (not i_eth_txbuf_empty and i_eth_txbuf_empty_en)
                            when i_eth_tmr_en = '1' else i_eth_txbuf_empty;

process(p_in_ethio_clk(0))
begin
if rising_edge(p_in_ethio_clk(0)) then

  i_eth_tmr_en <= p_in_eth_tmr_en;
  i_eth_tmr_irq <= p_in_eth_tmr_irq;

  sr_eth_htxd_rdy <= i_eth_htxd_rdy;
  sr_eth_tx_start <= i_eth_tmr_irq & sr_eth_tx_start(0 to sr_eth_tx_start'high - 1);

  if (p_in_ethio_tx_axi_done(0) = '1') then
    i_eth_txbuf_empty_en <= '0';

  elsif (sr_eth_htxd_rdy = '1' and i_eth_tmr_en = '1'
    and sr_eth_tx_start(0) = '1' and sr_eth_tx_start(1) = '0') then

    i_eth_txbuf_empty_en <= '1';
  end if;

end if;
end process;

m_h2eth_buf : fifo_host2eth
port map(
din     => p_in_eth_htxbuf_di,
wr_en   => p_in_eth_htxbuf_wr,
wr_clk  => p_in_hclk,

dout    => p_out_ethio_tx_axi_tdata((G_ETH_DWIDTH * (0 + 1)) - 1 downto (G_ETH_DWIDTH * 0)),
rd_en   => p_in_ethio_tx_axi_tready(0),
rd_clk  => p_in_ethio_clk(0),

empty   => i_eth_txbuf_empty,
full    => open,
prog_full => i_eth_txbuf_full,

rst  => i_h2eth_buf_rst
);
--wr_rst_busy => open,
--rd_rst_busy => open,
--
--clk     => p_in_hclk,
--srst    => b_rst_eth_bufs
--);

i_h2eth_buf_rst <= b_rst_eth_bufs or p_in_ethio_tx_axi_done(0);


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--Host <- ETHG
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
m_eth2h_fltr: pkt_filter
generic map(
G_DWIDTH => G_ETH_DWIDTH,
G_FRR_COUNT => C_SWT_ETH_HOST_FRR_COUNT
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_frr        => syn_eth2h_frr(0),

--------------------------------------
--Upstream Port
--------------------------------------
p_in_upp_data   => syn_eth_rxd    (0),
p_in_upp_wr     => syn_eth_rxd_wr (0),
p_in_upp_eof    => syn_eth_rxd_eof(0),
p_in_upp_sof    => syn_eth_rxd_sof(0),

--------------------------------------
--Downstream Port
--------------------------------------
p_out_dwnp_data => i_eth_fltr_do ,
p_out_dwnp_wr   => i_eth_fltr_den,
p_out_dwnp_eof  => i_eth_fltr_eof,
p_out_dwnp_sof  => open,

-------------------------------
--DBG
-------------------------------
p_in_tst        => (others => '0'),
p_out_tst       => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk        => p_in_ethio_clk(0),
p_in_rst        => b_rst_eth_bufs
);

--Bus convertor for data Eth -> HOST
process(p_in_ethio_clk(0))
begin
if rising_edge(p_in_ethio_clk(0)) then
  if (b_rst_eth_bufs = '1') then

    for i in 0 to i_eth2h_chunk'length - 1 loop
    i_eth2h_chunk(i) <= (others => '0');
    end loop;
    i_eth2h_wr <= '0';

    i_eth2h_chunk_cnt <= (others => '0');

  else
    if (i_eth_fltr_den = '1') then

      if (i_eth_fltr_eof = '1') then
        i_eth2h_chunk_cnt <= (others => '0');
      else
        i_eth2h_chunk_cnt <= i_eth2h_chunk_cnt + 1;
      end if;

      for i in 0 to i_eth2h_chunk'length - 1 loop
        if (i_eth2h_chunk_cnt = i) then
          i_eth2h_chunk(i) <= i_eth_fltr_do;
        end if;
      end loop;

    end if;

    i_eth2h_wr <= AND_reduce(i_eth2h_chunk_cnt) or i_eth_fltr_eof;

  end if;
end if;
end process;

gen_eth2h_di : for i in 0 to i_eth2h_chunk'length - 1 generate begin
i_eth2h_di((i_eth2h_chunk(i)'length * (i + 1)) - 1
                                    downto (i_eth2h_chunk(i)'length * i)) <= i_eth2h_chunk(i);
end generate gen_eth2h_di;

m_eth2h_buf : fifo_eth2host
port map(
din     => i_eth2h_di     ,
wr_en   => i_eth2h_wr     ,
wr_clk  => p_in_ethio_clk(0),

dout    => p_out_eth_hrxbuf_do,
rd_en   => p_in_eth_hrxbuf_rd ,
rd_clk  => p_in_hclk,

empty   => i_eth_rxbuf_empty,
full    => open,
prog_full => i_eth_rxbuf_full,

--rst  => b_rst_eth_bufs
--);

wr_rst_busy => open,
rd_rst_busy => open,

--clk     => p_in_hclk,
srst    => b_rst_eth_bufs
);

p_out_eth_hrxbuf_empty <= i_eth_rxbuf_empty;
p_out_eth_hrxbuf_full <= i_eth_rxbuf_full;

p_out_ethio_rx_axi_tready(0) <= '1';

--expand IRQ strobe
process(p_in_ethio_clk(0))
begin
if rising_edge(p_in_ethio_clk(0)) then
  if b_rst_eth_bufs = '1' then
    i_eth_rx_irq <= '0';
    sr_eth_fltr_eof <= (others => '0');

  else

    sr_eth_fltr_eof <= i_eth_fltr_eof & sr_eth_fltr_eof(0 to sr_eth_fltr_eof'high - 1);

    if (i_eth_fltr_eof = '1') then
      i_eth_rx_irq <= '1';
    elsif (sr_eth_fltr_eof(sr_eth_fltr_eof'high) = '1') then
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



--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--EthG -> FG
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
gen_fgbuf : for eth_ch in 0 to (G_ETH_CH_COUNT - 1) generate
begin

process(p_in_ethio_clk(eth_ch))
begin
if rising_edge(p_in_ethio_clk(eth_ch)) then
b_rst_fg_bufs(eth_ch) <= p_in_rst or h_reg_ctrl(C_SWT_REG_CTRL_RST_FG_BUFS_BIT);
end if;
end process;

m_eth2fg_fltr: pkt_filter
generic map(
G_DWIDTH => G_ETH_DWIDTH,
G_FRR_COUNT => C_SWT_ETH_FG_FRR_COUNT
)
port map(
--------------------------------------
--CFG
--------------------------------------
p_in_frr        => syn_eth2fg_frr(eth_ch),

--------------------------------------
--Upstream Port
--------------------------------------
p_in_upp_data   => syn_eth_rxd    (eth_ch),
p_in_upp_wr     => syn_eth_rxd_wr (eth_ch),
p_in_upp_eof    => syn_eth_rxd_eof(eth_ch),
p_in_upp_sof    => syn_eth_rxd_sof(eth_ch),

--------------------------------------
--Downstream Port
--------------------------------------
p_out_dwnp_data => i_fgbuf_fltr_do (eth_ch),
p_out_dwnp_wr   => i_fgbuf_fltr_den(eth_ch),
p_out_dwnp_eof  => open,
p_out_dwnp_sof  => open,

-------------------------------
--DBG
-------------------------------
p_in_tst        => (others => '0'),
p_out_tst       => open,

--------------------------------------
--SYSTEM
--------------------------------------
p_in_clk        => p_in_ethio_clk(eth_ch),
p_in_rst        => b_rst_fg_bufs(eth_ch)
);


m_eth2fg_buf : fifo_eth2fg
port map(
din       => i_fgbuf_fltr_do (eth_ch),
wr_en     => i_fgbuf_fltr_den(eth_ch),
wr_clk    => p_in_ethio_clk(eth_ch),

dout      => p_out_fgbufi_do((G_FGBUFI_DWIDTH * (eth_ch + 1)) - 1 downto (G_FGBUFI_DWIDTH * eth_ch)),
rd_en     => p_in_fgbufi_rd(eth_ch),
rd_clk    => p_in_fgbufi_rdclk,

empty     => p_out_fgbufi_empty(eth_ch),
full      => p_out_fgbufi_full (eth_ch),
prog_full => p_out_fgbufi_pfull(eth_ch),

--rst  => b_rst_fg_bufs
--);
wr_rst_busy => open,
rd_rst_busy => open,

--clk  : in  std_logic;
srst => b_rst_fg_bufs(eth_ch)
);

end generate gen_fgbuf;


--##################################
--DBG
--##################################
p_out_tst(0) <= b_rst_eth_bufs;
p_out_tst(1) <= '0';
p_out_tst(2) <= '0';
p_out_tst(3) <= '0';
p_out_tst(4) <= OR_reduce(h_reg_eth2fg_frr(0));
p_out_tst(5) <= h_reg_dbg(C_SWT_REG_DBG_HOST2FG_BIT);
p_out_tst(6) <= '0';
p_out_tst(7) <= '0';
p_out_tst(31 downto 8) <= (others => '0');


end architecture behavioral;
