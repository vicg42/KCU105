-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 21.02.2015 15:26:23
-- Module Name : fg (frame grabber)
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.prj_def.all;
use work.mem_wr_pkg.all;
use work.mem_ctrl_pkg.all;
use work.prj_cfg.all;

entity fg is
generic(
G_DBGCS : string := "OFF";

G_VBUFI_COUNT : integer := 1;
G_VBUFI_COUNT_MAX : integer := 1;
G_VCH_COUNT : integer := 1;

G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;
G_MEM_VLINE_L_BIT : integer := 0;

G_MEM_AWIDTH : integer := 32;
G_MEMWR_DWIDTH : integer := 32;
G_MEMRD_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_reg : TFGCtrl;

-------------------------------
--HOST
-------------------------------
p_in_hrdchsel     : in    std_logic_vector(2 downto 0);   --Host: Channel number for read
p_in_hrdstart     : in    std_logic;                      --Host: Start read data
p_in_hrddone      : in    std_logic;                      --Host: ACK read done
p_out_hirq        : out   std_logic_vector(G_VCH_COUNT - 1 downto 0);--IRQ
p_out_hdrdy       : out   std_logic_vector(G_VCH_COUNT - 1 downto 0);--Frame ready
p_out_hfrmrk      : out   std_logic_vector(31 downto 0);

--HOST <- MEM(VBUF)
p_in_vbufo_rdclk  : in    std_logic;
p_out_vbufo_do    : out   std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
p_in_vbufo_rd     : in    std_logic;
p_out_vbufo_empty : out   std_logic;

-------------------------------
--VBUFI -> MEM(VBUF)
-------------------------------
p_in_vbufi_do     : in    std_logic_vector((G_MEMWR_DWIDTH * G_VBUFI_COUNT_MAX) - 1 downto 0);
p_out_vbufi_rd    : out   std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_empty  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_full   : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_pfull  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);

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
p_out_tst         : out   std_logic_vector(255 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk          : in    std_logic;
p_in_rst          : in    std_logic
);
end entity fg;

architecture behavioral of fg is

component fg_bufo
port(
din         : IN  std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
wr_en       : IN  std_logic;
wr_clk      : IN  std_logic;

dout        : OUT std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
rd_en       : IN  std_logic;
rd_clk      : IN  std_logic;

empty       : OUT std_logic;
full        : OUT std_logic;
prog_full   : OUT std_logic;

rst         : IN  std_logic

--wr_rst_busy : out std_logic;
--rd_rst_busy : out std_logic;
--
----clk       : in  std_logic;
--srst      : in  std_logic
);
end component fg_bufo;

component fgwr
generic(
G_DBGCS : string := "OFF";

G_VBUFI_COUNT : integer := 1;
G_VBUFI_COUNT_MAX : integer := 1;
G_VCH_COUNT : integer := 1;

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
p_in_memtrn    : in    std_logic_vector((C_HREG_MEM_CTRL_TRNWR_M_BIT - C_HREG_MEM_CTRL_TRNWR_L_BIT) downto 0);
--p_in_work_en   : in    std_logic;

p_in_frbuf     : in    TFG_FrBufs;
p_out_frrdy    : out   std_logic_vector(G_VCH_COUNT - 1 downto 0);
p_out_frmrk    : out   std_logic_vector(31 downto 0);

----------------------------
--
----------------------------
p_in_vbufi_do     : in    std_logic_vector((G_MEMWR_DWIDTH * G_VBUFI_COUNT_MAX) - 1 downto 0);
p_out_vbufi_rd    : out   std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_empty  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_full   : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_pfull  : in    std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);

---------------------------------
--Port MEM_CTRL
---------------------------------
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
end component fgwr;

component fgrd
generic(
G_DBGCS : string := "OFF";

G_VCH_COUNT : integer := 1;

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
p_in_usrprm        : in    TFG_VCHPrms;
p_in_memtrn        : in    std_logic_vector((C_HREG_MEM_CTRL_TRNRD_M_BIT - C_HREG_MEM_CTRL_TRNRD_L_BIT) downto 0);

p_in_hrd_chsel     : in    std_logic_vector(2 downto 0);
p_in_hrd_start     : in    std_logic;
p_in_hrd_done      : in    std_logic;

p_in_frbuf         : in    TFG_FrBufs;
p_in_frline_nxt    : in    std_logic;

p_out_vchnum       : out   std_logic_vector(2 downto 0);
p_out_pixcount     : out   std_logic_vector(15 downto 0);
p_out_linecount    : out   std_logic_vector(15 downto 0);
p_out_mirx         : out   std_logic;
p_out_fr_rddone    : out   std_logic;

----------------------------
--Upstream Port
----------------------------
p_out_upp_data     : out   std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_out_upp_data_wd  : out   std_logic;
p_in_upp_buf_empty : in    std_logic;
p_in_upp_buf_full  : in    std_logic;

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem          : out   TMemIN;
p_in_mem           : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst           : in    std_logic_vector(31 downto 0);
p_out_tst          : out   std_logic_vector(127 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk           : in    std_logic;
p_in_rst           : in    std_logic
);
end component;

component vmirx_main is
generic(
G_BRAM_AWIDTH : integer := 8;
G_DWIDTH : integer := 8
);
port(
-------------------------------
--CFG
-------------------------------
p_in_cfg_mirx       : in    std_logic;
p_in_cfg_pix_count  : in    std_logic_vector(15 downto 0);
p_out_cfg_mirx_done : out   std_logic;

----------------------------
--Upstream Port (IN)
----------------------------
p_in_upp_data       : in    std_logic_vector(G_DWIDTH - 1 downto 0);
p_in_upp_wr         : in    std_logic;
p_out_upp_rdy_n     : out   std_logic;

----------------------------
--Downstream Port (OUT)
----------------------------
p_out_dwnp_data     : out   std_logic_vector(G_DWIDTH - 1 downto 0);
p_out_dwnp_wd       : out   std_logic;
p_in_dwnp_rdy_n     : in    std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst            : in    std_logic_vector(31 downto 0);
p_out_tst           : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk            : in    std_logic;
p_in_rst            : in    std_logic
);
end component vmirx_main;


constant CI_EXP_VALUE : integer := 7;


signal i_idle                  : std_logic_vector(G_VCH_COUNT - 1 downto 0);

Type TFG_FrMrks_Bufs is array (0 to C_FG_VBUF_COUNT - 1) of std_logic_vector(31 downto 0);
Type TFG_FrMrks_Bufs_VCH is array (0 to G_VCH_COUNT - 1) of TFG_FrMrks_Bufs;

type TFG_SrIRQ is array (0 to G_VCH_COUNT - 1) of unsigned(0 to CI_EXP_VALUE);
signal sr_irq                  : TFG_SrIRQ;
signal i_irq_exp               : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_irq                   : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_vbuf_hold             : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_hdrdy_out             : std_logic_vector(G_VCH_COUNT - 1 downto 0);

signal i_vbuf_wr               : TFG_FrBufs;
signal i_vbuf_rd               : TFG_FrBufs;

signal i_fgwr_frrdy            : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_fgwr_mrk              : std_logic_vector(31 downto 0);

signal i_frmrk_save            : TFG_FrMrks_Bufs_VCH;
signal i_frmrk_out             : std_logic_vector(31 downto 0);
signal i_frmrk                 : std_logic_vector(31 downto 0);

signal i_fgrd_rddone           : std_logic;
signal i_fgrd_vch              : std_logic_vector(p_in_hrdchsel'range);
signal i_fgrd_do               : std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
signal i_fgrd_den              : std_logic;
signal i_fgrd_pixcount         : std_logic_vector(15 downto 0);

signal i_vbufo_full            : std_logic;
signal i_vbufo_rst             : std_logic;

signal sr_hrdstart             : unsigned(0 to CI_EXP_VALUE);
signal i_hrdstart_exp          : std_logic;
signal i_hrdstart              : std_logic;
signal i_hchsel                : std_logic_vector(p_in_hrdchsel'range);
signal sr_hrddone              : unsigned(0 to CI_EXP_VALUE);
signal i_hrddone_exp           : std_logic;
signal i_hrddone               : std_logic;

signal i_mirx                  : std_logic;
signal i_mirx_done             : std_logic;
signal i_mirx_rdy_n            : std_logic;
signal i_mirx_den              : std_logic;
signal i_mirx_do               : std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);

signal tst_ctrl                : std_logic_vector(31 downto 0);

type TFG_FrSkip is array (0 to G_VCH_COUNT - 1) of unsigned(i_vbuf_wr(0)'range);
signal i_frskip                : TFG_FrSkip;
signal i_fgrd_eof              : std_logic;

type TFG_TstOut is array (0 to G_VCH_COUNT - 1)
  of std_logic_vector(31 downto 0);
signal i_fgrd_tst_out          : std_logic_vector(127 downto 0);
signal i_fgwr_tst_out          : std_logic_vector(31 downto 0);--: TFG_TstOut;
signal i_fgwr_tst_outtmp       : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal tst_pkt_err             : std_logic := '0';
--signal tst_dbg_pictire         : std_logic;
--signal tst_dbg_rd_hold         : std_logic;


begin --architecture behavioral





tst_ctrl(31 downto 0) <= std_logic_vector(RESIZE(UNSIGNED(p_in_reg.dbg), 32));
--tst_dbg_pictire<=p_in_reg.dbg(C_FG_REG_DBG_PICTURE_BIT);
--tst_dbg_rd_hold<=p_in_reg.dbg(C_FG_REG_DBG_RDHOLD_BIT);



--Resynch strob: p_in_hrdstart, p_in_hrddone
process(p_in_vbufo_rdclk)
begin
if rising_edge(p_in_vbufo_rdclk) then
  if p_in_rst = '1' then
    sr_hrdstart <= (others => '0');
    i_hrdstart_exp <= '0';
    sr_hrddone <= (others => '0');
    i_hrddone_exp <= '0';

  else

      ---
      if p_in_hrdstart = '1' then
        i_hrdstart_exp <= '1';
      elsif sr_hrdstart(sr_hrdstart'high) = '1' then
        i_hrdstart_exp <= '0';
      end if;

      sr_hrdstart <= p_in_hrdstart & sr_hrdstart(0 to sr_hrdstart'high - 1);

      ----
      if p_in_hrddone = '1' then
        i_hrddone_exp <= '1';
      elsif sr_hrddone(sr_hrddone'high) = '1' then
        i_hrddone_exp <= '0';
      end if;

      sr_hrddone <= p_in_hrddone & sr_hrddone(0 to sr_hrddone'high - 1);

  end if;
end if;
end process;

process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    i_hrdstart <= i_hrdstart_exp;
    i_hrddone <= i_hrddone_exp;
    i_hchsel <= p_in_hrdchsel;

    i_idle <= p_in_reg.idle;
  end if;
end process;


----------------------------------------------------
--
----------------------------------------------------
gen_vch : for ch in 0 to G_VCH_COUNT - 1 generate
begin

--IRQ
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    sr_irq(ch) <= (others => '0');
    i_irq_exp(ch) <= '0';

  else

      if i_irq(ch) = '1' then
        i_irq_exp(ch) <= '1';
      elsif sr_irq(ch)(sr_irq(ch)'high) = '1' then
        i_irq_exp(ch) <= '0';
      end if;

      sr_irq(ch) <= i_irq(ch) & sr_irq(ch)(0 to sr_irq(ch)'high - 1);

  end if;
end if;
end process;


--FrameBuffer CTRL
--Video -> VBUF
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    i_vbuf_wr(ch) <= (others => '0');
    for buf in 0 to C_FG_VBUF_COUNT - 1 loop
    i_frmrk_save(ch)(buf) <= (others => '0');
    end loop;
    i_frskip(ch) <= (others => '0');

  else

        --Set vbuf for write
        if i_idle(ch) = '1' then
          i_vbuf_wr(ch) <= (others => '0');

        elsif i_fgwr_frrdy(ch) = '1' then
            if i_vbuf_hold(ch) = '1' then
                if i_vbuf_wr(ch) /= i_vbuf_rd(ch) then
                  i_vbuf_wr(ch) <= i_vbuf_wr(ch) + 1;
                end if;
            else
              i_vbuf_wr(ch) <= i_vbuf_wr(ch) + 1;
            end if;
        end if;

        --Hold marker current frame
        if i_fgwr_frrdy(ch) = '1' then
          for buf in 0 to C_FG_VBUF_COUNT - 1 loop
            if i_vbuf_wr(ch) = buf then
              i_frmrk_save(ch)(buf) <= i_fgwr_mrk;
            end if;
          end loop;
        end if;

        --Counting frame write while host read video data
        if i_vbuf_hold(ch) = '0' then
          i_frskip(ch) <= (others => '0');
        else
          if i_fgwr_frrdy(ch) = '1' and
             UNSIGNED(i_fgrd_vch) = ch and i_fgrd_rddone = '1' then

            i_frskip(ch) <= i_frskip(ch);

          elsif UNSIGNED(i_fgrd_vch) = ch and i_fgrd_rddone = '1' and
                i_frskip(ch) /= (i_frskip(ch)'range => '0') then

            i_frskip(ch) <= i_frskip(ch) - 1;

          elsif i_fgwr_frrdy(ch) = '1' and
                i_frskip(ch) /= (i_frskip(ch)'range => '1') then

            i_frskip(ch) <= i_frskip(ch) + 1;

          end if;
        end if;

  end if;
end if;
end process;

--Video <- VBUF
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then

    i_vbuf_rd(ch) <= (others => '0');
    i_vbuf_hold(ch) <= '0';
    i_irq(ch) <= '0';

  else

        --Set vbuf for read
        if i_idle(ch) = '1' then
          i_vbuf_rd(ch) <= (others => '0');

        elsif i_frskip(ch) /= (i_frskip(ch)'range => '0') and
              UNSIGNED(i_fgrd_vch) = ch and i_fgrd_rddone = '1' then

          i_vbuf_rd(ch) <= i_vbuf_rd(ch) + 1;

        elsif i_fgwr_frrdy(ch) = '1' and i_vbuf_hold(ch) = '0' then
          i_vbuf_rd(ch) <= i_vbuf_wr(ch);

        end if;

        --Hold vbuf for host read
        if i_fgwr_frrdy(ch) = '1' then
          i_vbuf_hold(ch) <= '1';

        elsif (i_frskip(ch) = (i_frskip(ch)'range => '0') and
              UNSIGNED(i_fgrd_vch) = ch and i_fgrd_rddone = '1') or
              i_idle(ch) = '1' then

          i_vbuf_hold(ch) <= '0';
        end if;

        --IRQ - frame ready
        if i_frskip(ch) = (i_frskip(ch)'range => '0') then
          i_irq(ch) <= i_fgwr_frrdy(ch) and not i_vbuf_hold(ch);

        elsif UNSIGNED(i_fgrd_vch) = ch then
          i_irq(ch) <= i_fgrd_rddone;

        end if;

  end if;
end if;
end process;

end generate gen_vch;


-------------------------------
--Video -> MEM(VBUF)
-------------------------------
m_fgwr : fgwr
generic map(
G_DBGCS => G_DBGCS,

G_VBUFI_COUNT => G_VBUFI_COUNT,
G_VBUFI_COUNT_MAX => G_VBUFI_COUNT_MAX,
G_VCH_COUNT => G_VCH_COUNT,

G_MEM_VCH_M_BIT   => G_MEM_VCH_M_BIT,
G_MEM_VCH_L_BIT   => G_MEM_VCH_L_BIT,
G_MEM_VFR_M_BIT   => G_MEM_VFR_M_BIT,
G_MEM_VFR_L_BIT   => G_MEM_VFR_L_BIT,
G_MEM_VLINE_M_BIT => G_MEM_VLINE_M_BIT,
G_MEM_VLINE_L_BIT => G_MEM_VLINE_L_BIT,

G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEM_DWIDTH => G_MEMWR_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_memtrn    => p_in_reg.prm.memwr_trnlen,

p_in_frbuf     => i_vbuf_wr,
p_out_frrdy    => i_fgwr_frrdy,
p_out_frmrk    => i_fgwr_mrk,

----------------------------
--DataIN
----------------------------
p_in_vbufi_do    => p_in_vbufi_do   ,
p_out_vbufi_rd   => p_out_vbufi_rd  ,
p_in_vbufi_empty => p_in_vbufi_empty,
p_in_vbufi_full  => p_in_vbufi_full ,
p_in_vbufi_pfull => p_in_vbufi_pfull,

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem      => p_out_memwr,
p_in_mem       => p_in_memwr,

-------------------------------
--DBG
-------------------------------
p_in_tst       => tst_ctrl(31 downto 0),
p_out_tst      => i_fgwr_tst_out,

-------------------------------
--System
-------------------------------
p_in_clk       => p_in_clk,
p_in_rst       => p_in_rst
);


-------------------------------
--HOST <- MEM(VBUF)
-------------------------------
m_fgrd : fgrd
generic map(
G_DBGCS => G_DBGCS,

G_VCH_COUNT => G_VCH_COUNT,

G_MEM_VCH_M_BIT   => G_MEM_VCH_M_BIT,
G_MEM_VCH_L_BIT   => G_MEM_VCH_L_BIT,
G_MEM_VFR_M_BIT   => G_MEM_VFR_M_BIT,
G_MEM_VFR_L_BIT   => G_MEM_VFR_L_BIT,
G_MEM_VLINE_M_BIT => G_MEM_VLINE_M_BIT,
G_MEM_VLINE_L_BIT => G_MEM_VLINE_L_BIT,

G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEM_DWIDTH => G_MEMRD_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_usrprm          => p_in_reg.prm.ch,
p_in_memtrn          => p_in_reg.prm.memrd_trnlen,

p_in_hrd_chsel       => i_hchsel,
p_in_hrd_start       => i_hrdstart,
p_in_hrd_done        => i_hrddone,

p_in_frbuf           => i_vbuf_rd,
p_in_frline_nxt      => i_mirx_done,

p_out_vchnum          => i_fgrd_vch,
p_out_pixcount       => i_fgrd_pixcount,
p_out_linecount      => open,
p_out_mirx           => i_mirx,
p_out_fr_rddone      => i_fgrd_rddone,

----------------------------
--Upstream Port
----------------------------
p_out_upp_data        => i_fgrd_do,
p_out_upp_data_wd     => i_fgrd_den,
p_in_upp_buf_empty    => '0',
p_in_upp_buf_full     => i_mirx_rdy_n,

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem             => p_out_memrd,
p_in_mem              => p_in_memrd,

-------------------------------
--DBG
-------------------------------
p_in_tst              => tst_ctrl(31 downto 0),--(others => '0'),
p_out_tst             => i_fgrd_tst_out,

-------------------------------
--System
-------------------------------
p_in_clk              => p_in_clk,
p_in_rst              => p_in_rst
);


m_mirx : vmirx_main
generic map(
G_BRAM_AWIDTH => log2(C_PCFG_FG_FR_PIX_COUNT_MAX / (G_MEMRD_DWIDTH/ 8)),
G_DWIDTH => G_MEMRD_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_mirx       => i_mirx,
p_in_cfg_pix_count  => i_fgrd_pixcount,
p_out_cfg_mirx_done => i_mirx_done,

----------------------------
--Upstream Port (IN)
----------------------------
p_in_upp_data       => i_fgrd_do,
p_in_upp_wr         => i_fgrd_den,
p_out_upp_rdy_n     => i_mirx_rdy_n,

----------------------------
--Downstream Port (OUT)
----------------------------
p_out_dwnp_data     => i_mirx_do,
p_out_dwnp_wd       => i_mirx_den,
p_in_dwnp_rdy_n     => i_vbufo_full,

-------------------------------
--DBG
-------------------------------
p_in_tst            => (others => '0'),
p_out_tst           => open,

-------------------------------
--System
-------------------------------
p_in_clk            => p_in_clk,
p_in_rst            => i_vbufo_rst
);


----------------------------------------------------
--Output VideoBuffer
----------------------------------------------------
m_buf_mem2host : fg_bufo
port map(
din       => i_mirx_do ,
wr_en     => i_mirx_den,
wr_clk    => p_in_clk,

dout      => p_out_vbufo_do,
rd_en     => p_in_vbufo_rd,
rd_clk    => p_in_vbufo_rdclk,

empty     => p_out_vbufo_empty,
full      => open,
prog_full => i_vbufo_full,

rst       => i_vbufo_rst

--wr_rst_busy => open,
--rd_rst_busy => open,
--
----clk       : in  std_logic;
--srst      => i_vbufo_rst
);

i_vbufo_rst <= p_in_rst or p_in_tst(0);

p_out_hirq <= i_irq_exp;
p_out_hdrdy <= i_hdrdy_out;
p_out_hfrmrk <= i_frmrk_out;

process(p_in_vbufo_rdclk)
begin
if rising_edge(p_in_vbufo_rdclk) then
i_hdrdy_out <= i_vbuf_hold;
i_frmrk_out <= i_frmrk;
end if;
end process;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then

  for ch in 0 to G_VCH_COUNT - 1 loop
      if UNSIGNED(i_fgrd_vch) = ch then
        for buf in 0 to C_FG_VBUF_COUNT - 1 loop
          if i_vbuf_rd(ch) = buf then
            i_frmrk <= i_frmrk_save(ch)(buf);
          end if;
        end loop;
      end if;
  end loop;

end if;
end process;


------------------------------------
--DBG
------------------------------------
gen_dbgcs_off : if strcmp(G_DBGCS,"OFF") generate
p_out_tst(22 downto 0) <= (others => '0');
p_out_tst(23) <= tst_pkt_err;
p_out_tst(p_out_tst'high downto 24) <= (others => '0');

end generate gen_dbgcs_off;

gen_dbgcs_on : if strcmp(G_DBGCS,"ON") generate
----gen : for i in 0 to G_VCH_COUNT - 1 generate
----i_fgwr_tst_outtmp(i) <= OR_reduce(i_fgwr_tst_out(i));
----end generate gen;
--p_out_tst(7 downto 0) <= i_fgwr_tst_out(7 downto 0);
--p_out_tst(8) <= i_irq_exp(0);
--p_out_tst(9) <= i_vbuf_hold(0);
--p_out_tst(20 downto 10) <= i_fgwr_tst_out(20 downto 10);
--p_out_tst(21) <= i_fgwr_tst_out(21);
--p_out_tst(22) <= i_fgwr_tst_out(22);
--p_out_tst(23) <= tst_pkt_err;
--p_out_tst(31 downto 24) <= (others => '0');
----p_out_tst(4 downto 1) <= tst_fgwr_out(3 downto 0);
----p_out_tst(8 downto 5) <= i_fgrd_tst_out(3 downto 0);
----p_out_tst(9)          <= tst_fgwr_out(4);
----p_out_tst(10)         <= i_fgrd_tst_out(4);
----p_out_tst(25 downto 11) <= (others => '0');
----p_out_tst(31 downto 26) <= tst_fgwr_out(31 downto 26);
p_out_tst(26 downto 0) <= i_fgwr_tst_out(26 downto 0);

p_out_tst(p_out_tst'high downto 128) <= i_fgrd_tst_out;
end generate gen_dbgcs_on;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then
    tst_pkt_err <= '0';
  else
    if (i_fgwr_tst_out(16) = '1') then --i_err
      tst_pkt_err <= '1';
    elsif (i_hrdstart = '1') then
      tst_pkt_err <= '0';
    end if;
  end if;
end if;
end process;

end architecture behavioral;

