-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 22.07.2012 11:10:51
-- Module Name : fg_tb
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_cfg.all;
use work.prj_def.all;
use work.mem_glob_pkg.all;
use work.mem_wr_pkg.all;
use work.fg_pkg.all;
use work.cfgdev_pkg.all;


entity fg_tb is
generic(
G_FG_VCH_COUNT : integer := C_PCFG_FG_VCH_COUNT;
G_MEM_AWIDTH : integer := 31;
G_MEM_DWIDTH : integer := 128
);
port(
p_in_ram_rd : in std_logic;

p_in_cfg_adr      : in   std_logic_vector(3 downto 0);
p_in_cfg_adr_ld   : in   std_logic;

p_in_cfg_txdata   : in   std_logic_vector(15 downto 0);
p_in_cfg_wr       : in   std_logic;

p_out_cfg_rxdata  : out  std_logic_vector(15 downto 0);
p_in_cfg_rd       : in   std_logic;

p_out_vbufo_do  : out   std_logic_vector(G_MEM_DWIDTH - 1 downto 0);

--p_in_hrdstart : in    std_logic;                      --Host: Start read data
p_in_hrddone  : in    std_logic;                      --Host: ACK read done
p_out_hdrdy : out   std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);--Frame ready
p_out_hirq : out   std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);--IRQ
p_out_memwr : out TMemIN
);
end entity fg_tb;

architecture behavior of fg_tb is

constant CI_VBUFI_WRCLK_PERIOD : TIME := 6.6 ns; --150MHz
constant CI_MEMCLK_PERIOD : TIME := 2.5 ns; --400MHz
constant Cg_host_clk_PERIOD : TIME := 3.3 ns;

constant CI_FR_PIXCOUNT : integer := 128;
constant CI_FR_PIX_CHUNK: integer := CI_FR_PIXCOUNT / 1;
constant CI_FR_ROWCOUNT : integer := 8;
constant CI_FR_PIXNUM   : integer := 0;
constant CI_FR_ROWNUM   : integer := 0;


constant CI_RAM_DEPTH : integer := 2048;



component fifo_eth2fg
port (
din       : in  std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
prog_full : out std_logic;
--
--wr_rst_busy : out std_logic;
--rd_rst_busy : out std_logic;
--
--clk       : in  std_logic;
--srst      : in  std_logic
rst       : in  std_logic
);
end component;

component fg is
generic(
G_VSYN_ACTIVE : std_logic := '1';
G_DBGCS  : string := "OFF";
G_MEM_AWIDTH : integer := 32;
G_MEMWR_DWIDTH : integer := 32;
G_MEMRD_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk      : in   std_logic;

p_in_cfg_adr      : in   std_logic_vector(3 downto 0);
p_in_cfg_adr_ld   : in   std_logic;

p_in_cfg_txdata   : in   std_logic_vector(15 downto 0);
p_in_cfg_wr       : in   std_logic;

p_out_cfg_rxdata  : out  std_logic_vector(15 downto 0);
p_in_cfg_rd       : in   std_logic;

-------------------------------
--HOST
-------------------------------
p_in_hrdchsel     : in    std_logic_vector(2 downto 0);   --Host: Channel number for read
p_in_hrdstart     : in    std_logic;                      --Host: Start read data
p_in_hrddone      : in    std_logic;                      --Host: ACK read done
p_out_hirq        : out   std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);--IRQ
p_out_hdrdy       : out   std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);--Frame ready
p_out_hfrmrk      : out   std_logic_vector(31 downto 0);

--HOST <- MEM(VBUF)
p_in_vbufo_rdclk  : in    std_logic;
p_out_vbufo_do    : out   std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
p_in_vbufo_rd     : in    std_logic;
p_out_vbufo_empty : out   std_logic;

-------------------------------
--VBUFI -> MEM(VBUF)
-------------------------------
p_in_vbufi_do     : in    std_logic_vector(G_MEMWR_DWIDTH - 1 downto 0);
p_out_vbufi_rd    : out   std_logic;
p_in_vbufi_empty  : in    std_logic;
p_in_vbufi_full   : in    std_logic;
p_in_vbufi_pfull  : in    std_logic;

---------------------------------
--MEM
---------------------------------
--CH WRITE
p_out_memwr       : out   TMemIN;
p_in_memwr        : in    TMemOUT;
--CH READ
p_out_memrd       : out   TMemIN;
p_in_memrd        : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst          : in    std_logic_vector(31 downto 0);
p_out_tst         : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk          : in    std_logic;
p_in_rst          : in    std_logic
);
end component fg;

component cfgdev_host is
generic(
G_DBG : string := "OFF";
G_HOST_DWIDTH : integer := 32;
G_CFG_DWIDTH  : integer := 16
);
port(
-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_htxbuf_di       : in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_htxbuf_wr       : in   std_logic;
p_out_htxbuf_full    : out  std_logic;
p_out_htxbuf_empty   : out  std_logic;

--host <- dev
p_out_hrxbuf_do      : out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_hrxbuf_rd       : in   std_logic;
p_out_hrxbuf_full    : out  std_logic;
p_out_hrxbuf_empty   : out  std_logic;

p_out_hirq           : out  std_logic;
p_out_herr           : out  std_logic;

p_in_hclk            : in   std_logic;

-------------------------------
--FPGA DEV
-------------------------------
p_out_cfg_dadr       : out    std_logic_vector(C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT downto 0); --dev number
p_out_cfg_radr       : out    std_logic_vector(C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT downto 0); --adr registr
p_out_cfg_radr_ld    : out    std_logic;
p_out_cfg_radr_fifo  : out    std_logic;

p_out_cfg_txdata     : out    std_logic_vector(G_CFG_DWIDTH - 1 downto 0);
p_out_cfg_wr         : out    std_logic;
p_in_cfg_txbuf_full  : in     std_logic;
p_in_cfg_txbuf_empty : in     std_logic;

p_in_cfg_rxdata      : in     std_logic_vector(G_CFG_DWIDTH - 1 downto 0);
p_out_cfg_rd         : out    std_logic;
p_in_cfg_rxbuf_full  : in     std_logic;
p_in_cfg_rxbuf_empty : in     std_logic;

p_out_cfg_done       : out    std_logic;
p_in_cfg_clk         : in     std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst             : in     std_logic_vector(31 downto 0);
p_out_tst            : out    std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst             : in     std_logic
);
end component cfgdev_host;

signal p_in_rst           : std_logic;
signal p_in_clk           : std_logic;
signal g_host_clk          : std_logic;

signal i_mem_trn_len  : unsigned(7 downto 0);

type THeader is array (0 to (C_FG_PKT_HD_SIZE_BYTE / 2) - 1) of unsigned(15 downto 0);
signal i_header           : THeader;
signal i_vbuf_wr          : TFG_FrBufs;
signal i_fgwr_frrdy       : std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);


signal i_vbufi_di,i_vbufi_di_t : unsigned(G_MEM_DWIDTH - 1 downto 0);
type TDIsim is array (0 to (i_vbufi_di'length / 16) - 1) of unsigned(15 downto 0);
signal i_vbufi_di_tsim    : TDIsim;
signal i_vbufi_do         : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_vbufi_wr         : std_logic;
signal i_vbufi_rd         : std_logic;
signal i_vbufi_empty      : std_logic;
signal i_vbufi_pfull      : std_logic;
signal i_vbufi_wrclk      : std_logic;

signal i_out_memwr        : TMemIN;
signal i_in_memwr         : TMemOUT;

type TRAM is array (0 to CI_RAM_DEPTH - 1) of std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_ram              : TRAM;
signal i_ram_adr          : unsigned(31 downto 0) := (others => '0');
signal i_ram_do           : unsigned(G_MEM_DWIDTH - 1 downto 0);

signal i_out_memrd        : TMemIN;
signal i_in_memrd         : TMemOUT;

signal i_vbufo_do         : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_vbufo_rd         : std_logic;
signal i_vbufo_empty      : std_logic;


signal i_host_txd         : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_host_wr          : std_logic;

constant CI_CFG_DWIDTH     : integer := 16;--bit
type TCfgPkt is array (0 to (G_MEM_DWIDTH / CI_CFG_DWIDTH) - 1) of unsigned(CI_CFG_DWIDTH - 1 downto 0);
signal i_cfg_pkt              : TCfgPkt;

signal i_cfg_rst           : std_logic;
signal i_cfg_dadr          : std_logic_vector(C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT downto 0);
signal i_cfg_radr          : std_logic_vector(C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT downto 0);
signal i_cfg_radr_ld       : std_logic;
--signal i_cfg_radr_fifo     : std_logic;
signal i_cfg_wr            : std_logic;
signal i_cfg_rd            : std_logic;
signal i_cfg_txd           : std_logic_vector(CI_CFG_DWIDTH - 1 downto 0);
signal i_cfg_rxd           : std_logic_vector(CI_CFG_DWIDTH - 1 downto 0);
Type TCfgRxD is array (0 to C_CFGDEV_COUNT - 1) of std_logic_vector(i_cfg_rxd'range);
signal i_cfg_rxd_dev       : TCfgRxD;
signal i_cfg_wr_dev        : std_logic_vector(C_CFGDEV_COUNT - 1 downto 0);
signal i_cfg_rd_dev        : std_logic_vector(C_CFGDEV_COUNT - 1 downto 0);
signal i_cfg_tst_out       : std_logic_vector(31 downto 0);


signal i_hrdstart          : std_logic;
signal i_hrddone           : std_logic;
signal i_hdrdy             : std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);--Frame ready

begin --architecture behavior of fg_tb is


gen_clk0 : process
begin
p_in_clk <= '0';
wait for (CI_MEMCLK_PERIOD / 2);
p_in_clk <= '1';
wait for (CI_MEMCLK_PERIOD / 2);
end process;

gen_clk1 : process
begin
i_vbufi_wrclk <= '0';
wait for (CI_VBUFI_WRCLK_PERIOD / 2);
i_vbufi_wrclk <= '1';
wait for (CI_VBUFI_WRCLK_PERIOD / 2);
end process;

gen_clk2 : process
begin
g_host_clk <= '0';
wait for (Cg_host_clk_PERIOD / 2);
g_host_clk <= '1';
wait for (Cg_host_clk_PERIOD / 2);
end process;

p_in_rst <= '1','0' after 1 us;



--***********************************************************
--
--***********************************************************
m_cfg : cfgdev_host
generic map(
G_DBG => "OFF",
G_HOST_DWIDTH  => C_HDEV_DWIDTH,
G_CFG_DWIDTH => CI_CFG_DWIDTH
)
port map(
-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_htxbuf_di       => i_host_txd,
p_in_htxbuf_wr       => i_host_wr,
p_out_htxbuf_full    => open,
p_out_htxbuf_empty   => open,

--host <- dev
p_out_hrxbuf_do      => open,
p_in_hrxbuf_rd       => '0',
p_out_hrxbuf_full    => open,
p_out_hrxbuf_empty   => open,

p_out_hirq           => open,
p_in_hclk            => g_host_clk,

-------------------------------
--CFG
-------------------------------
p_out_cfg_dadr       => i_cfg_dadr,
p_out_cfg_radr       => i_cfg_radr,
p_out_cfg_radr_ld    => i_cfg_radr_ld,
p_out_cfg_radr_fifo  => open,--i_cfg_radr_fifo,

p_out_cfg_txdata     => i_cfg_txd,
p_out_cfg_wr         => i_cfg_wr,
p_in_cfg_txbuf_full  => '0',
p_in_cfg_txbuf_empty => '0',

p_in_cfg_rxdata      => i_cfg_rxd,
p_out_cfg_rd         => i_cfg_rd,
p_in_cfg_rxbuf_full  => '0',
p_in_cfg_rxbuf_empty => '0',

p_out_cfg_done       => open,
p_in_cfg_clk         => g_host_clk,

-------------------------------
--DBG
-------------------------------
p_in_tst             => (others => '0'),
p_out_tst            => open,

-------------------------------
--System
-------------------------------
p_in_rst             => p_in_rst
);

i_cfg_rxd <= i_cfg_rxd_dev(C_CFGDEV_SWT) when UNSIGNED(i_cfg_dadr) = TO_UNSIGNED(C_CFGDEV_SWT, i_cfg_dadr'length) else
             i_cfg_rxd_dev(C_CFGDEV_TMR) when UNSIGNED(i_cfg_dadr) = TO_UNSIGNED(C_CFGDEV_TMR, i_cfg_dadr'length) else
             i_cfg_rxd_dev(C_CFGDEV_FG);

gen_cfg_dev : for i in 0 to C_CFGDEV_COUNT - 1 generate
i_cfg_wr_dev(i) <= i_cfg_wr when UNSIGNED(i_cfg_dadr) = TO_UNSIGNED(i, i_cfg_dadr'length) else '0';
i_cfg_rd_dev(i) <= i_cfg_rd when UNSIGNED(i_cfg_dadr) = TO_UNSIGNED(i, i_cfg_dadr'length) else '0';
end generate gen_cfg_dev;


m_fg : fg
generic map(
G_DBGCS => "ON",
G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEMWR_DWIDTH => G_MEM_DWIDTH,
G_MEMRD_DWIDTH => G_MEM_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_clk      => g_host_clk,

p_in_cfg_adr      => i_cfg_radr(3 downto 0),
p_in_cfg_adr_ld   => i_cfg_radr_ld,

p_in_cfg_txdata   => i_cfg_txd,
p_in_cfg_wr       => i_cfg_wr_dev(C_CFGDEV_FG),

p_out_cfg_rxdata  => i_cfg_rxd_dev(C_CFGDEV_FG),
p_in_cfg_rd       => i_cfg_rd_dev(C_CFGDEV_FG),

-------------------------------
--HOST
-------------------------------
p_in_hrdchsel => "000",
p_in_hrdstart => i_hrdstart,--p_in_hrdstart,
p_in_hrddone  => i_hrddone ,--p_in_hrddone ,
p_out_hirq    => p_out_hirq,
p_out_hdrdy   => i_hdrdy,--p_out_hdrdy,
p_out_hfrmrk  => open,

--HOST <- MEM(VBUF)
p_in_vbufo_rdclk  => g_host_clk,
p_out_vbufo_do    => i_vbufo_do,
p_in_vbufo_rd     => i_vbufo_rd,
p_out_vbufo_empty => i_vbufo_empty,

-------------------------------
--VBUFI -> MEM(VBUF)
-------------------------------
p_in_vbufi_do     => i_vbufi_do   ,
p_out_vbufi_rd    => i_vbufi_rd   ,
p_in_vbufi_empty  => i_vbufi_empty,
p_in_vbufi_full   => '0',
p_in_vbufi_pfull  => i_vbufi_pfull,

---------------------------------
--MEM
---------------------------------
--CH WRITE
p_out_memwr => i_out_memwr,--p_out_memwr,--: out   TMemIN;
p_in_memwr  => i_in_memwr ,--: in    TMemOUT;
--CH READ
p_out_memrd => i_out_memrd,-- out   TMemIN;
p_in_memrd  => i_in_memrd ,-- in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst  => (others => '0'),
p_out_tst => open,

-------------------------------
--System
-------------------------------
p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);

i_in_memwr.axiw.aready <= '1';
i_in_memwr.axiw.wready <= '1';
i_in_memwr.axiw.rvalid <= '1';

i_in_memwr.axir.aready <= '1';
i_in_memwr.axir.dvalid <= '1';
i_in_memwr.axir.data <= (others => '0');


i_mem_trn_len <= TO_UNSIGNED(16#40#, i_mem_trn_len'length);

i_vbufo_rd <= not i_vbufo_empty;
p_out_vbufo_do <= i_vbufo_do;



--##########################################
--Send Video Packet
--##########################################
process
begin

for i in 0 to (i_header'length - 1) loop
i_header(i) <= (others => '0');
end loop;
i_vbufi_wr <= '0';
i_vbufi_di <= (others => '0');

i_host_wr <= '0';
i_host_txd <= (others => '0');
for i in 0 to (i_cfg_pkt'length - 1) loop
i_cfg_pkt(i) <= (others => '0');
end loop;

i_hrdstart <= '0';
i_hrddone <= '0';

wait for 2 us;



--@@@@@@@@@@@@ Config SWT @@@@@@@@@@@@
wait until rising_edge(g_host_clk);
i_cfg_pkt(0)(C_CFGPKT_FIFO_BIT) <= C_CFGPKT_FIFO_OFF;
i_cfg_pkt(0)(C_CFGPKT_DIR_BIT) <= C_CFGPKT_WR;
i_cfg_pkt(0)(C_CFGPKT_DADR_M_BIT downto C_CFGPKT_DADR_L_BIT) <= TO_UNSIGNED(C_CFGDEV_SWT, (C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT + 1));
i_cfg_pkt(1)(C_CFGPKT_RADR_M_BIT downto C_CFGPKT_RADR_L_BIT) <= TO_UNSIGNED(C_SWT_REG_FRR_ETH2FG, (C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT + 1));
i_cfg_pkt(2)(C_CFGPKT_DLEN_M_BIT downto C_CFGPKT_DLEN_L_BIT) <= TO_UNSIGNED(1, (C_CFGPKT_DLEN_M_BIT - C_CFGPKT_DLEN_L_BIT + 1));
i_cfg_pkt(3) <= TO_UNSIGNED(1, i_cfg_pkt(3)'length);

--Write CFG
wait until rising_edge(g_host_clk);
i_host_wr <= '1';
for i in 0 to (i_host_txd'length / i_cfg_pkt(0)'length) - 1 loop
i_host_txd((i_cfg_pkt(i)'length * (i + 1)) - 1 downto (i_cfg_pkt(i)'length * i)) <= std_logic_vector(i_cfg_pkt(i));
end loop;
wait until rising_edge(g_host_clk);
i_host_wr <= '0';

wait for 0.01 us;


--@@@@@@@@@@@@ Config FG @@@@@@@@@@@@
i_cfg_pkt(0)(C_CFGPKT_FIFO_BIT) <= C_CFGPKT_FIFO_OFF;
i_cfg_pkt(0)(C_CFGPKT_DIR_BIT) <= C_CFGPKT_WR;
i_cfg_pkt(0)(C_CFGPKT_DADR_M_BIT downto C_CFGPKT_DADR_L_BIT) <= TO_UNSIGNED(C_CFGDEV_FG, (C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT + 1));
i_cfg_pkt(1)(C_CFGPKT_RADR_M_BIT downto C_CFGPKT_RADR_L_BIT) <= TO_UNSIGNED(C_FG_REG_MEM_CTRL, (C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT + 1));
i_cfg_pkt(2)(C_CFGPKT_DLEN_M_BIT downto C_CFGPKT_DLEN_L_BIT) <= TO_UNSIGNED(1, (C_CFGPKT_DLEN_M_BIT - C_CFGPKT_DLEN_L_BIT + 1));
i_cfg_pkt(3) <= TO_UNSIGNED(16#4040#, i_cfg_pkt(3)'length);

--Write CFG
wait until rising_edge(g_host_clk);
i_host_wr <= '1';
for i in 0 to (i_host_txd'length / i_cfg_pkt(0)'length) - 1 loop
i_host_txd((i_cfg_pkt(i)'length * (i + 1)) - 1 downto (i_cfg_pkt(i)'length * i)) <= std_logic_vector(i_cfg_pkt(i));
end loop;
wait until rising_edge(g_host_clk);
i_host_wr <= '0';

wait for 0.01 us;

wait until rising_edge(g_host_clk);
i_cfg_pkt(0)(C_CFGPKT_FIFO_BIT) <= C_CFGPKT_FIFO_OFF;
i_cfg_pkt(0)(C_CFGPKT_DIR_BIT) <= C_CFGPKT_WR;
i_cfg_pkt(0)(C_CFGPKT_DADR_M_BIT downto C_CFGPKT_DADR_L_BIT) <= TO_UNSIGNED(C_CFGDEV_FG, (C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT + 1));
i_cfg_pkt(1)(C_CFGPKT_RADR_M_BIT downto C_CFGPKT_RADR_L_BIT) <= TO_UNSIGNED(C_FG_REG_DATA_L, (C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT + 1));
i_cfg_pkt(2)(C_CFGPKT_DLEN_M_BIT downto C_CFGPKT_DLEN_L_BIT) <= TO_UNSIGNED(2, (C_CFGPKT_DLEN_M_BIT - C_CFGPKT_DLEN_L_BIT + 1));
--Active Zone: 1024 x 1024
i_cfg_pkt(3) <= TO_UNSIGNED(1024, i_cfg_pkt(3)'length);--X
i_cfg_pkt(4) <= TO_UNSIGNED(1024, i_cfg_pkt(3)'length);--Y

--Write CFG
wait until rising_edge(g_host_clk);
i_host_wr <= '1';
for i in 0 to (i_host_txd'length / i_cfg_pkt(0)'length) - 1 loop
i_host_txd((i_cfg_pkt(i)'length * (i + 1)) - 1 downto (i_cfg_pkt(i)'length * i)) <= std_logic_vector(i_cfg_pkt(i));
end loop;
wait until rising_edge(g_host_clk);
i_host_wr <= '0';

wait for 0.01 us;

i_cfg_pkt(0)(C_CFGPKT_FIFO_BIT) <= C_CFGPKT_FIFO_OFF;
i_cfg_pkt(0)(C_CFGPKT_DIR_BIT) <= C_CFGPKT_WR;
i_cfg_pkt(0)(C_CFGPKT_DADR_M_BIT downto C_CFGPKT_DADR_L_BIT) <= TO_UNSIGNED(C_CFGDEV_FG, (C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT + 1));
i_cfg_pkt(1)(C_CFGPKT_RADR_M_BIT downto C_CFGPKT_RADR_L_BIT) <= TO_UNSIGNED(C_FG_REG_CTRL, (C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT + 1));
i_cfg_pkt(2)(C_CFGPKT_DLEN_M_BIT downto C_CFGPKT_DLEN_L_BIT) <= TO_UNSIGNED(1, (C_CFGPKT_DLEN_M_BIT - C_CFGPKT_DLEN_L_BIT + 1));
i_cfg_pkt(3)(C_FG_REG_CTRL_VCH_M_BIT downto C_FG_REG_CTRL_VCH_L_BIT) <= TO_UNSIGNED(0, (C_FG_REG_CTRL_VCH_M_BIT - C_FG_REG_CTRL_VCH_L_BIT+ 1));
i_cfg_pkt(3)(C_FG_REG_CTRL_PRM_M_BIT downto C_FG_REG_CTRL_PRM_L_BIT) <= TO_UNSIGNED(C_FG_PRM_FR_ZONE_ACTIVE, (C_FG_REG_CTRL_PRM_M_BIT - C_FG_REG_CTRL_PRM_L_BIT+ 1));
i_cfg_pkt(3)(C_FG_REG_CTRL_WR_BIT) <= C_FG_REG_CTRL_WR;

--Write CFG
wait until rising_edge(g_host_clk);
i_host_wr <= '1';
for i in 0 to (i_host_txd'length / i_cfg_pkt(0)'length) - 1 loop
i_host_txd((i_cfg_pkt(i)'length * (i + 1)) - 1 downto (i_cfg_pkt(i)'length * i)) <= std_logic_vector(i_cfg_pkt(i));
end loop;
wait until rising_edge(g_host_clk);
i_host_wr <= '0';

wait for 0.01 us;


--@@@@@@@@@@@@ Send Video @@@@@@@@@@@@
vch : for ch in 0 to G_FG_VCH_COUNT - 1 loop
  rownum : for rownum in 0 to CI_FR_ROWCOUNT - 1 loop
    pixchnk : for pixchunk in 0 to (CI_FR_PIXCOUNT / CI_FR_PIX_CHUNK) - 1 loop

      wait until rising_edge(i_vbufi_wrclk);
      i_header(0) <= TO_UNSIGNED((CI_FR_PIX_CHUNK + C_FG_PKT_HD_SIZE_BYTE - 2), 16);--Length
      i_header(1) <= "0000" & TO_UNSIGNED(0,  4) & TO_UNSIGNED(ch,  4) & TO_UNSIGNED(16#01#,  4);--FrNum & VCH_NUM & PktType
      i_header(2) <= TO_UNSIGNED(CI_FR_PIXCOUNT, 16);--Fr.PixCount
      i_header(3) <= TO_UNSIGNED(CI_FR_ROWCOUNT, 16);--Fr.RowCount
      i_header(4) <= TO_UNSIGNED((pixchunk * CI_FR_PIX_CHUNK), 16);--Fr.PixNum
      i_header(5) <= TO_UNSIGNED(rownum, 16);--Fr.RowNum
      i_header(6) <= TO_UNSIGNED(0, 16);--TimeStump_LSB
      i_header(7) <= TO_UNSIGNED(0, 16);--TimeStump_MSB

      --Write PktHeader
      wait until rising_edge(i_vbufi_wrclk);
      i_vbufi_wr <= '1';
      for i in 0 to (i_vbufi_di'length / i_header(0)'length) - 1 loop
      i_vbufi_di((i_header(0)'length * (i + 1)) - 1 downto (i_header(0)'length * i)) <= i_header(i);
      end loop;


      --Write Data
      wait until rising_edge(i_vbufi_wrclk);
      i_vbufi_wr <= '1';
      i_vbufi_di <= TO_UNSIGNED(1, i_vbufi_di'length);

      for i in 1 to ((CI_FR_PIX_CHUNK + C_FG_PKT_HD_SIZE_BYTE) / (G_MEM_DWIDTH / 8)) - 2 loop
        wait until rising_edge(i_vbufi_wrclk);
        i_vbufi_di <= i_vbufi_di + 1;
      end loop;

      wait until rising_edge(i_vbufi_wrclk);
      i_vbufi_wr <= '0';
      i_vbufi_di <= i_vbufi_di + 1;

    end loop pixchnk;
  end loop rownum;
end loop vch;


--@@@@@@@@@@@@ Start Read Video @@@@@@@@@@@@
wait until rising_edge(g_host_clk) and i_hdrdy(0) = '1';
i_hrdstart <= '1';
wait until rising_edge(g_host_clk);
i_hrdstart <= '0';

wait;
end process;

gen_di_sim : for i in 0 to i_vbufi_di_tsim'length - 1 generate begin
i_vbufi_di_tsim(i) <= i_vbufi_di((i_vbufi_di_tsim(i)'length * (i + 1)) - 1 downto (i_vbufi_di_tsim(i)'length *i));
i_vbufi_di_t((i_vbufi_di_tsim(i)'length * (i + 1)) - 1 downto (i_vbufi_di_tsim(i)'length *i)) <= i_vbufi_di_tsim(i);
end generate gen_di_sim;


m_vbufi : fifo_eth2fg
port map(
din       => std_logic_vector(i_vbufi_di_t),
wr_en     => i_vbufi_wr,
wr_clk    => i_vbufi_wrclk,

dout      => i_vbufi_do,
rd_en     => i_vbufi_rd,
rd_clk    => p_in_clk,

empty     => i_vbufi_empty,
full      => open,
prog_full => i_vbufi_pfull,
--
--wr_rst_busy : out std_logic;
--rd_rst_busy : out std_logic;
--
--clk       : in  std_logic;
--srst      : in  std_logic
rst => p_in_rst
);


--p_out_mem <= i_out_memwr;

--VIDEO_RAM
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (i_out_memwr.axiw.avalid = '1') then
    i_ram_adr <= RESIZE(UNSIGNED(i_out_memwr.axiw.adr(i_out_memwr.axiw.adr'high
                                                              downto log2(G_MEM_DWIDTH / 8))), i_ram_adr'length);

  elsif (i_out_memwr.axiw.dvalid = '1') then
    i_ram_adr <= i_ram_adr + 1;
    i_ram(TO_INTEGER(i_ram_adr)) <= i_out_memwr.axiw.data(i_ram(0)'range);

  elsif p_in_ram_rd = '1' then
  i_ram_adr <= i_ram_adr + 1;
  i_ram_do <= UNSIGNED(i_ram(TO_INTEGER(i_ram_adr)));

  end if;
end if;
end process;

i_in_memrd.axir.data <= std_logic_vector(RESIZE(i_ram_do, i_in_memrd.axir.data'length));


end architecture behavior;
