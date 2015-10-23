-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 22.07.2012 11:10:51
-- Module Name : fgwr_tb
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


entity fgwr_tb is
generic(
G_FG_VCH_COUNT : integer := 1;
G_MEM_AWIDTH : integer := 31;
G_MEM_DWIDTH : integer := 128
);
port(
p_in_ram_rd : in  std_logic := '0';
p_out_ram_do : out  std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_out_mem : out TMemIN
);
end entity fgwr_tb;

architecture behavior of fgwr_tb is

constant CI_VBUFI_WRCLK_PERIOD : TIME := 6.6 ns; --150MHz
constant CI_VBUFI_RDCLK_PERIOD : TIME := 2.5 ns; --400MHz

constant CI_FR_PIXCOUNT : integer := 128;
constant CI_FR_ROWCOUNT : integer := 8;
constant CI_FR_PIXNUM   : integer := 0;
constant CI_FR_ROWNUM   : integer := 0;

constant CI_RAM_DEPTH   : integer := 1024;

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

component fgwr
generic(
G_DBGCS : string := "OFF";

G_FG_VCH_COUNT : integer := 1;

G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;
G_MEM_VLINE_L_BIT : integer := 0;

G_MEM_AWIDTH : integer := 32;
G_MEM_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
--p_in_usrprm_ld : in    std_logic;
--p_in_usrprm    : in    TFGWR_Prms;
p_in_memtrn    : in    std_logic_vector(7 downto 0);
--p_in_work_en   : in    std_logic;

p_in_frbuf     : in    TFG_FrBufs;
p_out_frrdy    : out   std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);
p_out_frmrk    : out   std_logic_vector(31 downto 0);

-------------------------------
--DataIN
-------------------------------
p_in_vbufi_do     : in    std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_out_vbufi_rd    : out   std_logic;
p_in_vbufi_empty  : in    std_logic;
p_in_vbufi_full   : in    std_logic;
p_in_vbufi_pfull  : in    std_logic;

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem      : out   TMemIN;
p_in_mem       : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst       : in    std_logic_vector(31 downto 0);
p_out_tst      : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk       : in    std_logic;
p_in_rst       : in    std_logic
);
end component;

signal p_in_rst           : std_logic;
signal p_in_clk           : std_logic;

signal i_mem_trn_len  : unsigned(7 downto 0);

type THeader is array (0 to (C_FG_PKT_HD_SIZE_BYTE / 2) - 1) of unsigned(15 downto 0);
signal i_header           : THeader;
signal i_vbuf_wr          : TFG_FrBufs;
signal i_fgwr_frrdy       : std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);


signal i_vbufi_di,i_vbufi_di_t : unsigned(G_MEM_DWIDTH - 1 downto 0);
type TDIsim is array (0 to (i_vbufi_di'length / 32) - 1) of unsigned(31 downto 0);
signal i_vbufi_di_tsim     : TDIsim;
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
signal i_ram_adr          : unsigned(31 downto 0);
signal i_ram_do           : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);


begin --architecture behavior of fgwr_tb is


gen_clk0 : process
begin
p_in_clk <= '0';
wait for (CI_VBUFI_RDCLK_PERIOD / 2);
p_in_clk <= '1';
wait for (CI_VBUFI_RDCLK_PERIOD / 2);
end process;

gen_clk1 : process
begin
i_vbufi_wrclk <= '0';
wait for (CI_VBUFI_WRCLK_PERIOD / 2);
i_vbufi_wrclk <= '1';
wait for (CI_VBUFI_WRCLK_PERIOD / 2);

end process;
p_in_rst <= '1','0' after 1 us;

gen0 : for ch in 0 to G_FG_VCH_COUNT - 1 generate
begin

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    i_vbuf_wr(ch) <= (others => '0');
  else
    if i_fgwr_frrdy(ch) = '1' then
      i_vbuf_wr(ch) <= i_vbuf_wr(ch) + 1;
    end if;
  end if;
end if;
end process;

end generate gen0;


m_fgwr : fgwr
generic map(
G_DBGCS => "ON",

G_FG_VCH_COUNT => G_FG_VCH_COUNT,

G_MEM_VCH_M_BIT   => C_FG_MEM_VCH_M_BIT,
G_MEM_VCH_L_BIT   => C_FG_MEM_VCH_L_BIT,
G_MEM_VFR_M_BIT   => C_FG_MEM_VFR_M_BIT,
G_MEM_VFR_L_BIT   => C_FG_MEM_VFR_L_BIT,
G_MEM_VLINE_M_BIT => C_FG_MEM_VLINE_M_BIT,
G_MEM_VLINE_L_BIT => 0 ,

G_MEM_AWIDTH      => G_MEM_AWIDTH,
G_MEM_DWIDTH      => G_MEM_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
--p_in_usrprm_ld : in    std_logic;
--p_in_usrprm    : in    TFGWR_Prms;
p_in_memtrn    => std_logic_vector(i_mem_trn_len),
--p_in_work_en   : in    std_logic;

p_in_frbuf  => i_vbuf_wr,
p_out_frrdy => i_fgwr_frrdy,
p_out_frmrk => open,

-------------------------------
--DataIN
-------------------------------
p_in_vbufi_do     => i_vbufi_do   ,
p_out_vbufi_rd    => i_vbufi_rd   ,
p_in_vbufi_empty  => i_vbufi_empty,
p_in_vbufi_full   => '0',
p_in_vbufi_pfull  => i_vbufi_pfull,

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem => i_out_memwr,--: out   TMemIN;
p_in_mem  => i_in_memwr ,--: in    TMemOUT;

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



process
begin

i_vbufi_wr <= '0';
i_vbufi_di <= (others => '0');

wait for 2 us;


vch : for ch in 0 to G_FG_VCH_COUNT - 1 loop

rownum : for rownum in 0 to CI_FR_ROWCOUNT - 1 loop

wait until rising_edge(i_vbufi_wrclk);
i_header(0) <= TO_UNSIGNED((CI_FR_PIXCOUNT + C_FG_PKT_HD_SIZE_BYTE - 2), 16);--Length
i_header(1) <= TO_UNSIGNED(0,  8) & TO_UNSIGNED(ch,  4) & TO_UNSIGNED(1,  4);--FrNum & VCH_NUM & PktType
i_header(2) <= TO_UNSIGNED(CI_FR_PIXCOUNT, 16);--Fr.PixCount
i_header(3) <= TO_UNSIGNED(CI_FR_ROWCOUNT, 16);--Fr.RowCount
i_header(4) <= TO_UNSIGNED(CI_FR_PIXNUM, 16);--Fr.PixNum
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

for i in 1 to ((CI_FR_PIXCOUNT + C_FG_PKT_HD_SIZE_BYTE) / (G_MEM_DWIDTH / 8)) - 2 loop
  wait until rising_edge(i_vbufi_wrclk);
  i_vbufi_di <= i_vbufi_di + 1;
end loop;

wait until rising_edge(i_vbufi_wrclk);
i_vbufi_wr <= '0';
i_vbufi_di <= i_vbufi_di + 1;

end loop rownum;
end loop vch;

wait;
end process;

gen_di_sim : for i in 0 to i_vbufi_di_tsim'length - 1 generate begin
i_vbufi_di_tsim(i) <= i_vbufi_di((32 * (i + 1)) - 1 downto (32 *i));
i_vbufi_di_t((32 * (i + 1)) - 1 downto (32 *i)) <= i_vbufi_di_tsim(i);
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



p_out_mem <= i_out_memwr;

--VIDEO_RAM
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (i_out_memwr.axiw.avalid = '1') then
    i_ram_adr <= RESIZE(UNSIGNED(i_out_memwr.axiw.adr(i_out_memwr.axiw.adr'high downto log2(G_MEM_DWIDTH / 8))), i_ram_adr'length);

  elsif (i_out_memwr.axiw.dvalid = '1') then
    i_ram_adr <= i_ram_adr + 1;
    i_ram(TO_INTEGER(i_ram_adr)) <= i_out_memwr.axiw.data(i_ram(0)'range);

  elsif p_in_ram_rd = '1' then
  p_out_ram_do <= i_ram(TO_INTEGER(i_ram_adr));

  end if;
end if;
end process;

p_out_ram_do <= i_ram_do;

end architecture behavior;
