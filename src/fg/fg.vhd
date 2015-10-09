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
use work.fg_pkg.all;
use work.mem_wr_pkg.all;
use work.mem_ctrl_pkg.all;
use work.prj_cfg.all;

entity fg is
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
p_out_hirq        : out   std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);--IRQ
p_out_hdrdy       : out   std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);--Frame ready
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
);
end component;

component fgwr
generic(
G_PIXBIT : integer := 8;
G_DBGCS : string := "OFF";
G_VCH_NUM : integer := 0;
G_VCH_COUNT : integer := 0;
G_VSYN_ACTIVE : std_logic := '1';
G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;

G_MEM_AWIDTH : integer := 32;
G_MEM_DWIDTH : integer := 32
);
port(
-------------------------------
--CFG
-------------------------------
p_in_usrprm_ld : in    std_logic;
p_in_usrprm    : in    TFGWR_Prms;
p_in_memtrn    : in    std_logic_vector(7 downto 0);
p_in_work_en   : in    std_logic;

p_in_frbuf     : in    TFG_FrBufs;
p_out_frrdy    : out   std_logic_vector(G_VCH_COUNT - 1 downto 0);
p_out_frmrk    : out   std_logic_vector(31 downto 0);

----------------------------
--
----------------------------
p_in_vbufi_do     : in    std_logic_vector(G_MEMWR_DWIDTH - 1 downto 0);
p_out_vbufi_rd    : out   std_logic;
p_in_vbufi_empty  : in    std_logic;
p_in_vbufi_full   : in    std_logic;
p_in_vbufi_pfull  : in    std_logic;

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
end component;

component fgrd
generic(
G_DBGCS : string:="OFF";

G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;

G_MEM_AWIDTH : integer := 32;
G_MEM_DWIDTH : integer := 32;

G_VCH_COUNT : integer := 1
);
port(
-------------------------------
--CFG
-------------------------------
p_in_usrprm        : in    TFGRD_Prms;
p_in_memtrn        : in    std_logic_vector(7 downto 0);
--p_in_work_en       : in    std_logic;

p_in_hrd_chsel     : in    std_logic_vector(2 downto 0);
p_in_hrd_start     : in    std_logic;
p_in_hrd_done      : in    std_logic;

p_in_frbuf         : in    TFG_FrBufs;
p_in_frline_n      : in    std_logic;

p_out_chnum        : out   std_logic_vector(2 downto 0);
p_out_pixcount     : out   std_logic_vector(15 downto 0);
p_out_linecount    : out   std_logic_vector(15 downto 0);
p_out_mirx         : out   std_logic;
p_out_sof          : out   std_logic;
p_out_eof          : out   std_logic;
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
p_out_tst          : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk           : in    std_logic;
p_in_rst           : in    std_logic
);
end component;


signal i_reg_adr               : unsigned(p_in_cfg_adr'range);

signal i_reg_ctrl              : std_logic_vector(C_FG_REG_CTRL_LAST_BIT downto 0);
signal i_reg_data              : std_logic_vector(31 downto 0);
signal i_reg_tst0              : std_logic_vector(C_FG_REG_TST0_LAST_BIT downto 0);
signal i_reg_mem_trnlen        : std_logic_vector(15 downto 0);

signal sr_set_prm              : unsigned(3 downto 0);
signal i_set_prm_width         : std_logic;
signal h_set_prm               : std_logic;
signal i_set_prm               : std_logic;

type TSRsetidle is array(0 to C_FG_VCH_COUNT - 1) of  unsigned(3 downto 0);
signal sr_set_idle             : TSRsetidle;
signal i_set_idle_width        : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal h_set_idle              : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_set_idle              : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);

signal i_prm                   : TFG_Prm;
signal i_prm_fgwr              : TFGWR_Prms;
signal i_prm_fgrd              : TFGRD_Prms;

Type TFG_FrMrks_Bufs is array (0 to C_FG_VBUF_COUNT - 1) of std_logic_vector(31 downto 0);
Type TFG_FrMrks_Bufs_VCH is array (0 to C_FG_VCH_COUNT - 1) of TFG_FrMrks_Bufs;

type TFG_CntWidth is array (0 to C_FG_VCH_COUNT - 1) of unsigned(15 downto 0);
signal sr_irq                  : TFG_CntWidth;
signal i_irq_width             : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_irq                   : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_vbuf_hold             : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);

signal i_vbuf_wr               : TFG_FrBufs;
signal i_vbuf_rd               : TFG_FrBufs;

signal i_fgwr_frrdy            : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
signal i_fgwr_mrk              : std_logic_vector(31 downto 0);

signal i_frmrk_save            : TFG_FrMrks_Bufs_VCH;
signal i_frmrk_out             : std_logic_vector(31 downto 0);

signal i_fgrd_rddone           : std_logic;
signal i_fgrd_vch              : std_logic_vector(p_in_hrdchsel'range);
signal i_fgrd_do               : std_logic_vector(G_MEMRD_DWIDTH - 1 downto 0);
signal i_fgrd_den              : std_logic;

signal i_vbufo_full            : std_logic;
signal i_vbufo_rst             : std_logic;

signal sr_hrdstart             : unsigned(15 downto 0);
signal i_hrdstart_width        : std_logic;
signal i_hrdstart              : std_logic;
signal i_hchsel                : std_logic_vector(p_in_hrdchsel'range);
signal sr_hrddone              : unsigned(15 downto 0);
signal i_hrddone_width         : std_logic;
signal i_hrddone               : std_logic;

signal tst_fgrd_out            : std_logic_vector(31 downto 0);
signal tst_ctrl                : std_logic_vector(31 downto 0);

type TFG_FrSkip is array (0 to C_FG_VCH_COUNT - 1) of unsigned(i_vbuf_wr(0)'range);
signal i_frskip                : TFG_FrSkip;
signal i_fgrd_eof              : std_logic;

type TFG_TstOut is array (0 to C_FG_VCH_COUNT - 1)
  of std_logic_vector(31 downto 0);
signal i_fgwr_tst_out          : std_logic_vector(31 downto 0);--: TFG_TstOut;
signal i_fgwr_tst_outtmp       : std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);

--signal tst_dbg_pictire         : std_logic;
--signal tst_dbg_rd_hold         : std_logic;


begin --architecture behavioral


----------------------------------------------------
--Configuration
----------------------------------------------------
--adress
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

--write registers
process(p_in_cfg_clk)
variable vch_num : unsigned(C_FG_REG_CTRL_VCH_M_BIT - C_FG_REG_CTRL_VCH_L_BIT downto 0);
variable prm     : unsigned(C_FG_REG_CTRL_PRM_M_BIT - C_FG_REG_CTRL_PRM_L_BIT downto 0);
variable set_prm : std_logic;
variable set_idle: std_logic_vector(C_FG_VCH_COUNT - 1 downto 0);
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    i_reg_ctrl <= (others => '0');
    i_reg_tst0 <= (others => '0');
    i_reg_data <= (others => '0');

    set_prm := '0';
    h_set_prm <= '0';

    vch_num := (others => '0');
    prm := (others => '0');

    for ch in 0 to C_FG_VCH_COUNT - 1 loop
--        i_prm.ch(ch).mem_addr_wr <= (others => '0');
--        i_prm.ch(ch).mem_addr_rd <= (others => '0');
        i_prm.ch(ch).fr.skp.pixcount <= (others => '0');
        i_prm.ch(ch).fr.skp.rowcount <= (others => '0');
        i_prm.ch(ch).fr.act.pixcount <= (others => '0');
        i_prm.ch(ch).fr.act.rowcount <= (others => '0');
        i_prm.ch(ch).mirror.x <= '0';
        i_prm.ch(ch).mirror.y <= '0';
        i_prm.ch(ch).steprd <= (others => '0');
    end loop;
    i_prm.mem_wd_trn_len <= (others => '0');
    i_prm.mem_rd_trn_len <= (others => '0');

    set_idle := (others => '0');
    h_set_idle <= (others => '0');

  else
    set_prm := '0';
    set_idle := (others => '0');

    if p_in_cfg_wr = '1' then
      if i_reg_adr = TO_UNSIGNED(C_FG_REG_CTRL, i_reg_adr'length) then

          i_reg_ctrl <= p_in_cfg_txdata(i_reg_ctrl'high downto 0);

          vch_num := UNSIGNED(p_in_cfg_txdata(C_FG_REG_CTRL_VCH_M_BIT downto C_FG_REG_CTRL_VCH_L_BIT));
          prm := UNSIGNED(p_in_cfg_txdata(C_FG_REG_CTRL_PRM_M_BIT downto C_FG_REG_CTRL_PRM_L_BIT));

            for ch in 0 to C_FG_VCH_COUNT - 1 loop
              if ch = vch_num then
                set_idle(ch) := p_in_cfg_txdata(C_FG_REG_CTRL_SET_IDLE_BIT);
              end if;
            end loop;

          if p_in_cfg_txdata(C_FG_REG_CTRL_WR_BIT) = '1' then

              set_prm := '1';

              for ch in 0 to C_FG_VCH_COUNT - 1 loop
                if ch = vch_num then

                  if prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_ACTIVE, prm'length) then
                    i_prm.ch(ch).fr.act.pixcount <= UNSIGNED(i_reg_data(15 downto  0));
                    i_prm.ch(ch).fr.act.rowcount <= UNSIGNED(i_reg_data(31 downto 16));

                  elsif prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_SKIP, prm'length) then
                    i_prm.ch(ch).fr.skp.pixcount <= UNSIGNED(i_reg_data(15 downto  0));
                    i_prm.ch(ch).fr.skp.rowcount <= UNSIGNED(i_reg_data(31 downto 16));

                  elsif prm = TO_UNSIGNED(C_FG_PRM_FR_OPTIONS, prm'length) then
                    i_prm.ch(ch).mirror.x <= i_reg_data(4);
                    i_prm.ch(ch).mirror.y <= i_reg_data(5);

                  elsif prm = TO_UNSIGNED(C_FG_PRM_FR_STEP_RD, prm'length) then
                    i_prm.ch(ch).steprd <= UNSIGNED(i_reg_data(15 downto 0));

--                  elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_WR, prm'length) then
--                    i_prm.ch(ch).mem_addr_wr <= i_reg_data(31 downto 0);

--                  elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_RD, prm'length) then
--                    i_prm.ch(ch).mem_addr_rd <= i_reg_data(31 downto 0);

                  end if;
                end if;
              end loop;

          end if;

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_TST0, i_reg_adr'length) then
        i_reg_tst0 <= p_in_cfg_txdata(i_reg_tst0'high downto 0);

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_DATA_L, i_reg_adr'length) then
        i_reg_data(15 downto 0) <= p_in_cfg_txdata;

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_DATA_M, i_reg_adr'length) then
        i_reg_data(31 downto 16) <= p_in_cfg_txdata;

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_MEM_CTRL, i_reg_adr'length) then
          set_prm := '1';
          i_prm.mem_wd_trn_len(7 downto 0) <= p_in_cfg_txdata(7 downto 0);
          i_prm.mem_rd_trn_len(7 downto 0) <= p_in_cfg_txdata(15 downto 8);

      end if;
    end if;

    h_set_idle <= set_idle;
    h_set_prm <= set_prm;

  end if;
end if;
end process;

--read registers
process(p_in_cfg_clk)
variable vch_num : unsigned(C_FG_REG_CTRL_VCH_M_BIT - C_FG_REG_CTRL_VCH_L_BIT downto 0);
variable prm     : unsigned(C_FG_REG_CTRL_PRM_M_BIT - C_FG_REG_CTRL_PRM_L_BIT downto 0);
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    p_out_cfg_rxdata <= (others => '0');

  else

    if p_in_cfg_rd = '1' then

      vch_num := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_VCH_M_BIT downto C_FG_REG_CTRL_VCH_L_BIT));
      prm := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_PRM_M_BIT downto C_FG_REG_CTRL_PRM_L_BIT));

      if i_reg_adr = TO_UNSIGNED(C_FG_REG_CTRL, i_reg_adr'length) then
        p_out_cfg_rxdata <= std_logic_vector(RESIZE(UNSIGNED(i_reg_ctrl), p_out_cfg_rxdata'length));

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_TST0, i_reg_adr'length) then
        p_out_cfg_rxdata <= std_logic_vector(RESIZE(UNSIGNED(i_reg_tst0), p_out_cfg_rxdata'length));

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_DATA_L, i_reg_adr'length) then

--          vch_num := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_VCH_M_BIT downto C_FG_REG_CTRL_VCH_L_BIT));
--          prm := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_PRM_M_BIT downto C_FG_REG_CTRL_PRM_L_BIT));

          for ch in 0 to C_FG_VCH_COUNT - 1 loop
            if ch = vch_num then

              if prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_ACTIVE, prm'length) then
                p_out_cfg_rxdata <= std_logic_vector(i_prm.ch(ch).fr.act.pixcount(15 downto 0));

              elsif prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_SKIP, prm'length) then
                p_out_cfg_rxdata <= std_logic_vector(i_prm.ch(ch).fr.skp.pixcount(15 downto 0));

              elsif prm = TO_UNSIGNED(C_FG_PRM_FR_OPTIONS, prm'length) then
                p_out_cfg_rxdata(4)           <= i_prm.ch(ch).mirror.x;
                p_out_cfg_rxdata(5)           <= i_prm.ch(ch).mirror.y;
                p_out_cfg_rxdata(15 downto 6) <= (others => '0');

              elsif prm = TO_UNSIGNED(C_FG_PRM_FR_STEP_RD, prm'length) then
                p_out_cfg_rxdata <= std_logic_vector(i_prm.ch(ch).steprd);

--              elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_WR, prm'length) then
--                p_out_cfg_rxdata <= i_prm.ch(ch).mem_addr_wr(15 downto 0);

--              elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_RD, prm'length) then
--                p_out_cfg_rxdata <= i_prm.ch(ch).mem_addr_rd(15 downto 0);

              end if;
            end if;
          end loop;

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_DATA_M, i_reg_adr'length) then

--          vch_num := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_VCH_M_BIT downto C_FG_REG_CTRL_VCH_L_BIT));
--          prm := UNSIGNED(i_reg_ctrl(C_FG_REG_CTRL_PRM_M_BIT downto C_FG_REG_CTRL_PRM_L_BIT));

          for ch in 0 to C_FG_VCH_COUNT - 1 loop
            if ch = vch_num then

              if prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_ACTIVE, prm'length) then
                p_out_cfg_rxdata <= std_logic_vector(i_prm.ch(ch).fr.act.rowcount(15 downto 0));

              elsif prm = TO_UNSIGNED(C_FG_PRM_FR_ZONE_SKIP, prm'length) then
                p_out_cfg_rxdata <= std_logic_vector(i_prm.ch(ch).fr.skp.rowcount(15 downto 0));

              elsif prm = TO_UNSIGNED(C_FG_PRM_FR_OPTIONS, prm'length) then
                p_out_cfg_rxdata(15 downto 0) <= (others => '0');

--              elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_WR, prm'length) then
--                p_out_cfg_rxdata <= i_prm.ch(ch).mem_addr_wr(31 downto 16);

--              elsif prm = TO_UNSIGNED(C_FG_PRM_MEM_ADR_RD, prm'length) then
--                p_out_cfg_rxdata <= i_prm.ch(ch).mem_addr_rd(31 downto 16);

              end if;
            end if;
          end loop;

      elsif i_reg_adr = TO_UNSIGNED(C_FG_REG_MEM_CTRL, i_reg_adr'length) then
          p_out_cfg_rxdata(7 downto 0) <= i_prm.mem_wd_trn_len(7 downto 0);
          p_out_cfg_rxdata(15 downto 8) <= i_prm.mem_rd_trn_len(7 downto 0);

      end if;
    end if;

  end if;
end if;
end process;


tst_ctrl(31 downto 0) <= std_logic_vector(RESIZE(UNSIGNED(i_reg_tst0), 32));
--tst_dbg_pictire<=tst_ctrl(C_FG_REG_TST0_DBG_PICTURE_BIT);
--tst_dbg_rd_hold<=tst_ctrl(C_FG_REG_TST0_DBG_RDHOLD_BIT);



--Resynch strob: p_in_hrdstart, p_in_hrddone
process(p_in_vbufo_rdclk)
begin
if rising_edge(p_in_vbufo_rdclk) then
  if p_in_rst = '1' then
    sr_hrdstart <= (others => '0');
    i_hrdstart_width <= '0';
    sr_hrddone <= (others => '0');
    i_hrddone_width <= '0';

  else

      ---
      if p_in_hrdstart = '1' then
        i_hrdstart_width <= '1';
      elsif sr_hrdstart(sr_hrdstart'high) = '1' then
        i_hrdstart_width <= '0';
      end if;

      sr_hrdstart <= p_in_hrdstart & sr_hrdstart(0 to sr_hrdstart'high - 1);

      ----
      if p_in_hrddone = '1' then
        i_hrddone_width <= '1';
      elsif sr_hrddone(sr_hrddone'high) = '1' then
        i_hrddone_width <= '0';
      end if;

      sr_hrddone <= p_in_hrddone & sr_hrddone(0 to sr_hrddone'high - 1);

  end if;
end if;
end process;

process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    i_hrdstart <= i_hrdstart_width;
    i_hrddone <= i_hrddone_width;
    i_hchsel <= p_in_hrdchsel;
  end if;
end process;

--Resynch strob: h_set_prm, h_set_idle
process(p_in_cfg_clk)
begin
if rising_edge(p_in_cfg_clk) then
  if p_in_rst = '1' then
    sr_set_prm <= (others => '0');
    i_set_prm_width <= '0';
    for i in 0 to C_FG_VCH_COUNT - 1 loop
    sr_set_idle(i) <= (others => '0');
    i_set_idle_width(i) <= '0';
    end loop;

  else

      ---
      if h_set_prm = '1' then
        i_set_prm_width <= '1';
      elsif sr_set_prm(sr_set_prm'high) = '1' then
        i_set_prm_width <= '0';
      end if;

      sr_set_prm <= h_set_prm & sr_set_prm(0 to sr_set_prm'high - 1);

      ----
      for i in 0 to C_FG_VCH_COUNT - 1 loop
      if h_set_idle(i) = '1' then
        i_set_idle_width(i) <= '1';
      elsif sr_set_idle(i)(sr_set_idle(i)'high) = '1' then
        i_set_idle_width(i) <= '0';
      end if;

      sr_set_idle(i) <= h_set_idle(i) & sr_set_idle(i)(0 to sr_set_idle'high - 1);
      end loop;

  end if;
end if;
end process;

process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    i_set_prm <= i_set_prm_width;
    i_set_idle <= i_set_idle_width;
  end if;
end process;


----------------------------------------------------
--
----------------------------------------------------
gen_vch : for ch in 0 to C_FG_VCH_COUNT - 1 generate
begin

--RD parametrs
--i_prm_fgrd(ch).frwr <= p_in_vbufi(ch).frprm;
i_prm_fgrd(ch).frrd <= i_prm.ch(ch).fr;
i_prm_fgrd(ch).mirror <= i_prm.ch(ch).mirror;
i_prm_fgrd(ch).steprd <= i_prm.ch(ch).steprd;

--WR parametrs
i_prm_fgwr(ch).fr <= p_in_vbufi(ch).frprm;


--IRQ
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    sr_irq(ch) <= (others => '0');
    i_irq_width(ch) <= '0';

  else

      if i_irq(ch) = '1' then
        i_irq_width(ch) <= '1';
      elsif sr_irq(ch)(sr_irq(ch)'high) = '1' then
        i_irq_width(ch) <= '0';
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
        if i_set_idle(ch) = '1' then
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
        if i_set_idle(ch) = '1' then
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
              i_set_idle(ch) = '1' then

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
G_PIXBIT => C_PCFG_FG_PIXBIT,
G_DBGCS  => G_DBGCS,
G_VCH_NUM => 0,
G_VCH_COUNT => C_FG_VCH_COUNT,
G_VSYN_ACTIVE => G_VSYN_ACTIVE,
G_MEM_VCH_M_BIT   => C_FG_MEM_VCH_M_BIT,
G_MEM_VCH_L_BIT   => C_FG_MEM_VCH_L_BIT,
G_MEM_VFR_M_BIT   => C_FG_MEM_VFR_M_BIT,
G_MEM_VFR_L_BIT   => C_FG_MEM_VFR_L_BIT,
G_MEM_VLINE_M_BIT => C_FG_MEM_VLINE_M_BIT,

G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEM_DWIDTH => G_MEMWR_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_usrprm_ld => i_set_prm,
p_in_usrprm    => i_prm_fgwr,
p_in_memtrn    => i_prm.mem_wd_trn_len(7 downto 0),
p_in_work_en   => p_in_tst(1),

p_in_frbuf     => i_vbuf_wr,
p_out_frrdy    => i_fgwr_frrdy,
p_out_frmrk    => i_fgwr_mrk,

----------------------------
--DataIN
----------------------------
p_in_vbufi     => p_in_vbufi(0),

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem      => p_out_memwr,
p_in_mem       => p_in_memwr,

-------------------------------
--DBG
-------------------------------
p_in_tst       => p_in_tst, --tst_ctrl(31 downto 0),--
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
G_DBGCS           => G_DBGCS,

G_MEM_VCH_M_BIT   => C_FG_MEM_VCH_M_BIT,
G_MEM_VCH_L_BIT   => C_FG_MEM_VCH_L_BIT,
G_MEM_VFR_M_BIT   => C_FG_MEM_VFR_M_BIT,
G_MEM_VFR_L_BIT   => C_FG_MEM_VFR_L_BIT,
G_MEM_VLINE_M_BIT => C_FG_MEM_VLINE_M_BIT,

G_MEM_AWIDTH      => G_MEM_AWIDTH,
G_MEM_DWIDTH      => G_MEMRD_DWIDTH,

G_VCH_COUNT => C_FG_VCH_COUNT
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_usrprm          => i_prm_fgrd,
p_in_memtrn          => i_prm.mem_rd_trn_len(7 downto 0),
--p_in_work_en         => p_in_tst(0),

p_in_hrd_chsel       => i_hchsel,
p_in_hrd_start       => i_hrdstart,
p_in_hrd_done        => i_hrddone,

p_in_frbuf           => i_vbuf_rd,
p_in_frline_n        => '0',

p_out_chnum          => i_fgrd_vch,
p_out_pixcount       => open,
p_out_linecount      => open,
p_out_mirx           => open,
p_out_sof            => open,
p_out_eof            => i_fgrd_eof,
p_out_fr_rddone      => i_fgrd_rddone,

----------------------------
--Upstream Port
----------------------------
p_out_upp_data        => i_fgrd_do,
p_out_upp_data_wd     => i_fgrd_den,
p_in_upp_buf_empty    => '0',
p_in_upp_buf_full     => i_vbufo_full,

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem             => p_out_memrd,
p_in_mem              => p_in_memrd,

-------------------------------
--DBG
-------------------------------
p_in_tst              => tst_ctrl(31 downto 0),--(others => '0'),
p_out_tst             => tst_fgrd_out,

-------------------------------
--System
-------------------------------
p_in_clk              => p_in_clk,
p_in_rst              => p_in_rst
);



----------------------------------------------------
--Output VideoBuffer
----------------------------------------------------
m_buf_mem2host : fg_bufo
port map(
din       => i_fgrd_do,
wr_en     => i_fgrd_den,
wr_clk    => p_in_clk,

dout      => p_out_vbufo_do,
rd_en     => p_in_vbufo_rd,
rd_clk    => p_in_vbufo_rdclk,

empty     => p_out_vbufo_empty,
full      => open,
prog_full => i_vbufo_full,

rst       => i_vbufo_rst
);

i_vbufo_rst <= p_in_rst or p_in_tst(0);

p_out_hirq <= i_irq_width;
p_out_hdrdy <= i_vbuf_hold;

--Marker of read video frame:
p_out_hfrmrk <= i_frmrk_out;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then

  for ch in 0 to C_FG_VCH_COUNT - 1 loop
      if UNSIGNED(i_fgrd_vch) = ch then
        for buf in 0 to C_FG_VBUF_COUNT - 1 loop
          if i_vbuf_rd(ch) = buf then
            i_frmrk_out <= i_frmrk_save(ch)(buf);
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
p_out_tst <= (others => '0');
--p_out_tst(0) <= '0';
--p_out_tst(4 downto 1) <= i_fgwr_tst_out(0)(4 downto 1);
--p_out_tst(8 downto 5) <= tst_fgrd_out(3 downto 0);
--p_out_tst(15 downto 9) <= (others => '0');
--p_out_tst(19 downto 16) <= (others => '0');
--p_out_tst(25 downto 20) <= (others => '0');
--p_out_tst(31 downto 26) <= i_fgwr_tst_out(0)(31 downto 26);
end generate gen_dbgcs_off;

gen_dbgcs_on : if strcmp(G_DBGCS,"ON") generate
--gen : for i in 0 to C_FG_VCH_COUNT - 1 generate
--i_fgwr_tst_outtmp(i) <= OR_reduce(i_fgwr_tst_out(i));
--end generate gen;
p_out_tst(0) <= OR_reduce(i_fgwr_tst_out) or i_fgrd_eof or OR_reduce(tst_fgrd_out);
p_out_tst(31 downto 1) <= (others => '0');
--p_out_tst(4 downto 1) <= tst_fgwr_out(3 downto 0);
--p_out_tst(8 downto 5) <= tst_fgrd_out(3 downto 0);
--p_out_tst(9)          <= tst_fgwr_out(4);
--p_out_tst(10)         <= tst_fgrd_out(4);
--p_out_tst(25 downto 11) <= (others => '0');
--p_out_tst(31 downto 26) <= tst_fgwr_out(31 downto 26);
end generate gen_dbgcs_on;


end architecture behavioral;

