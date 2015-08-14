-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 17.02.2015 14:02:10
-- Module Name : fgwr (frame grabber - writer)
--
-- Description : Video source -> MEM(VBUF)
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.fg_pkg.all;
use work.mem_wr_pkg.all;

entity fgwr is
generic(
G_PIXBIT : integer := 8;
G_USR_OPT : std_logic_vector(3 downto 0) := (others => '0');
G_DBGCS   : string := "OFF";
G_VCH_NUM : integer := 0;
G_VSYN_ACTIVE : std_logic := '1';
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
p_in_usrprm_ld : in    std_logic;
p_in_usrprm    : in    TFGWR_Prm;
p_in_work_en   : in    std_logic;

p_in_frbuf     : in    std_logic_vector(G_MEM_VFR_M_BIT - G_MEM_VFR_L_BIT downto 0);
p_out_frrdy    : out   std_logic;
p_out_frmrk    : out   std_logic_vector(31 downto 0);

-------------------------------
--DataIN
-------------------------------
p_in_vbufi     : in    TFGWR_VBUFI;

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
end entity fgwr;

architecture behavioral of fgwr is

constant CI_PIXBIT : integer := G_PIXBIT;
constant CI_VDWIDTH : integer := CI_PIXBIT * 2;

component vbufi_tst is
port (
din       : in  std_logic_vector((8 * 2) - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

full      : out std_logic;
empty     : out std_logic;
prog_full : out std_logic;

rst       : in  std_logic
);
end component vbufi_tst;

component vbufi is
port (
din       : in  std_logic_vector((16 * 2) - 1 downto 0);
wr_en     : in  std_logic;
wr_clk    : in  std_logic;

dout      : out std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
rd_en     : in  std_logic;
rd_clk    : in  std_logic;

full      : out std_logic;
empty     : out std_logic;
prog_full : out std_logic;

rst       : in  std_logic
);
end component vbufi;

signal i_ibuf_do,i_ibuf_dtmp       : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_ibuf_rd                   : std_logic;
signal i_ibuf_empty                : std_logic;
signal i_buf_empty                 : std_logic;

Type TBUFdi is array (0 to 1) of unsigned(CI_VDWIDTH - 1 downto 0);
signal i_ibuf2_di                  : TBUFdi;
signal i_ibuf_wr                   : std_logic;

signal sr_vd_en                    : std_logic;

signal i_pix_00                    : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal i_pix_01                    : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal i_pix_10                    : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal i_pix_11                    : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');

--signal sr_pix_00                   : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal sr_pix_01                   : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal sr_pix_10                   : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal sr_pix_11                   : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');

signal i_colorB_swap,sr_colorB_swap: unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');
signal i_colorR_swap               : unsigned(CI_PIXBIT - 1 downto 0) := (others => '0');

Type TBUF2d is array (0 to 1) of std_logic_vector(i_ibuf_dtmp'range);
signal i_ibuf2_dtmp                : TBUF2d;
signal i_ibuf2_do                  : TBUF2d;

signal i_ibuf2_rd                  : std_logic_vector(1 downto 0);
signal i_ibuf2_full                : std_logic_vector(1 downto 0);
signal i_ibuf2_empty               : std_logic_vector(1 downto 0);

type TFsm_state is (
S_IDLE,
S_MEM_START,
S_MEM_WR
);
signal i_fsm_state_cs              : TFsm_state;

signal i_prm                       : TFGWR_Prm; --current param

signal i_mem_adr_out               : unsigned(31 downto 0) := (others => '0');
signal i_mem_adr                   : unsigned(31 downto 0) := (others => '0');
signal i_mem_rqlen                 : unsigned(15 downto 0) := (others => '0');
signal i_mem_start                 : std_logic;
signal i_mem_dir                   : std_logic;
signal i_mem_done                  : std_logic;
signal i_fr_rowcnt                 : unsigned(15 downto 0) := (others => '0');
signal i_padding                   : std_logic;
signal i_frrdy                     : std_logic;
signal i_frmrk                     : unsigned(31 downto 0) := (others => '0');
signal i_pix_sel                   : std_logic := '0';
signal i_hs_vden                   : std_logic;
signal i_vs_vden                   : std_logic;
signal i_vd_en                     : std_logic;
signal i_vwr_en                    : std_logic := '0';
signal sr_vwr_en                   : std_logic := '0';
signal i_ibuf_rst                  : std_logic;

signal tst_mem_wr_out              : std_logic_vector(31 downto 0);
signal tst_fsmstate,tst_fsm_cs_dly : unsigned(3 downto 0) := (others => '0');
signal tst_upp_data                : std_logic_vector(i_ibuf_do'range);
signal tst_upp_data_rd             : std_logic;
signal tst_ibuf_empty              : std_logic;
signal tst_ibuf_full               : std_logic;


begin --architecture behavioral



p_out_frrdy <= i_frrdy; --Frame ready
p_out_frmrk <= std_logic_vector(i_frmrk);

------------------------------------------------
--
------------------------------------------------
--detect SOF (Start of Frame)
process(p_in_vbufi.video.pixclk)
begin
if rising_edge(p_in_vbufi.video.pixclk) then
  if p_in_vbufi.video.pixclken = '1' then
    if p_in_work_en = '1' then
      if p_in_vbufi.video.vs = G_VSYN_ACTIVE then
        i_vwr_en <= '1';
      end if;
    else
      i_vwr_en <= '0';
    end if;
  end if;
end if;
end process;

gen_vsyn_1 : if G_VSYN_ACTIVE = '1' generate begin
i_hs_vden <= not p_in_vbufi.video.hs;
i_vs_vden <= not p_in_vbufi.video.vs;
end generate gen_vsyn_1;

gen_vsyn_0 : if G_VSYN_ACTIVE = '0' generate begin
i_hs_vden <= p_in_vbufi.video.hs;
i_vs_vden <= p_in_vbufi.video.vs;
end generate gen_vsyn_0;

i_vd_en <= (i_hs_vden and i_vs_vden) and i_vwr_en;

i_ibuf_rst <= p_in_rst or not sr_vwr_en;


------------------------------------------------
--
------------------------------------------------
--Camera Cannon EOS C500: 3G-SDI output (RAW format):
--line0: pix00, pix01
--line1: pix10, pix11
gen_din_8bit : if CI_PIXBIT = 8 generate
begin
--for video data set MSB part of sdi data out
i_pix_00 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 2) - 1 downto (10 * 1) + 2)), CI_PIXBIT); --B1,R1,B3,R3
i_pix_01 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 1) - 1 downto (10 * 0) + 2)), CI_PIXBIT); --Gr,Gr,Gr,Gr

i_pix_10 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 3) - 1 downto (10 * 2) + 2)), CI_PIXBIT); --Gb,Gb,Gb,Gb
i_pix_11 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 4) - 1 downto (10 * 3) + 2)), CI_PIXBIT); --B2,R2,B4,R4
end generate gen_din_8bit;

gen_din_16bit : if CI_PIXBIT = 16 generate
begin
i_pix_00 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 2) - 1 downto (10 * 1))), CI_PIXBIT); --B1,R1,B3,R3
i_pix_01 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 1) - 1 downto (10 * 0))), CI_PIXBIT); --Gr,Gr,Gr,Gr

i_pix_10 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 3) - 1 downto (10 * 2))), CI_PIXBIT); --Gb,Gb,Gb,Gb
i_pix_11 <= RESIZE(UNSIGNED(p_in_vbufi.video.d((10 * 4) - 1 downto (10 * 3))), CI_PIXBIT); --B2,R2,B4,R4
end generate gen_din_16bit;

process(p_in_vbufi.video.pixclk)
begin
if rising_edge(p_in_vbufi.video.pixclk) then
  if p_in_vbufi.video.pixclken = '1' then

    if i_vd_en = '1' then
      i_pix_sel <= not i_pix_sel;
    else
      i_pix_sel <= '0';
    end if;

    sr_vd_en <= i_vd_en;
--    sr_pix_00 <= i_pix_00;
    sr_pix_01 <= i_pix_01;
    sr_pix_10 <= i_pix_10;
    sr_pix_11 <= i_pix_11;

    sr_colorB_swap <= i_colorB_swap;

  end if;
end if;
end process;

i_colorB_swap <= i_pix_00 when i_pix_sel = '0' else sr_pix_11; --Swap color B:
i_colorR_swap <= i_pix_00 when i_pix_sel = '1' else sr_pix_11; --Swap color R:

i_ibuf2_di(0)((CI_PIXBIT * 1) - 1 downto CI_PIXBIT * 0) <= sr_colorB_swap; --pix_00: B1,B2,B3,B4
i_ibuf2_di(0)((CI_PIXBIT * 2) - 1 downto CI_PIXBIT * 1) <= sr_pix_10;      --pix_01: Gb,Gb,Gb,Gb

i_ibuf2_di(1)((CI_PIXBIT * 1) - 1 downto CI_PIXBIT * 0) <= sr_pix_01;      --pix_10: Gr,Gr,Gr,Gr
i_ibuf2_di(1)((CI_PIXBIT * 2) - 1 downto CI_PIXBIT * 1) <= i_colorR_swap;  --pix_11: R1,R2,R3,R4

i_ibuf_wr <= sr_vd_en and p_in_vbufi.video.pixclken;

--Output Bayer:
--B1 Gb B2 Gb B3 Gb ...
--Gr R1 Gr R2 Gr R3 ...

------------------------------------------------
--
------------------------------------------------
gen_bufi : for y in 0 to (i_ibuf2_di'length - 1) generate
begin

gen_8bit : if CI_PIXBIT = 8 generate
begin

m_bufi : vbufi_tst
port map(
din       => std_logic_vector(i_ibuf2_di(y)),
wr_en     => i_ibuf_wr,
wr_clk    => p_in_vbufi.video.pixclk,

dout      => i_ibuf2_dtmp(y),
rd_en     => i_ibuf2_rd(y),
rd_clk    => p_in_clk,

full      => i_ibuf2_full(y),
empty     => i_ibuf2_empty(y),
prog_full => open,

rst       => i_ibuf_rst
);

end generate gen_8bit;

gen_16bit : if CI_PIXBIT = 16 generate
begin

m_bufi : vbufi
port map(
din       => std_logic_vector(i_ibuf2_di(y)),
wr_en     => i_ibuf_wr,
wr_clk    => p_in_vbufi.video.pixclk,

dout      => i_ibuf2_dtmp(y),
rd_en     => i_ibuf2_rd(y),
rd_clk    => p_in_clk,

full      => i_ibuf2_full(y),
empty     => i_ibuf2_empty(y),
prog_full => open,

rst       => i_ibuf_rst
);

end generate gen_16bit;

gen_bufi_do_swap : for i in 0 to (G_MEM_DWIDTH / CI_VDWIDTH) - 1 generate begin
i_ibuf2_do(y)((i_ibuf2_do(i)'length - (CI_VDWIDTH * i)) - 1 downto
                              (i_ibuf2_do(y)'length - (CI_VDWIDTH * (i + 1)) ))
                                      <= i_ibuf2_dtmp(y)(CI_VDWIDTH * (i + 1) - 1 downto (CI_VDWIDTH * i));
end generate gen_bufi_do_swap;

end generate gen_bufi;


------------------------------------------------
--
------------------------------------------------
--Frame marker
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then
    i_frmrk <= (others => '0');
  else
    if p_in_usrprm_ld = '1' then
      i_frmrk <= (others => '0');
    else
      if i_fsm_state_cs = S_MEM_WR and i_mem_done = '1' then
        if (i_fr_rowcnt = (i_prm.fr.rowcount - 1)) then
            i_frmrk <= i_frmrk + 1;
        end if;
      end if;
    end if;
  end if;
end if;
end process;

process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then

    i_fsm_state_cs <= S_IDLE;
    i_mem_adr <= (others => '0');
    i_mem_rqlen <= (others => '0');
    i_mem_dir <= '0';
    i_mem_start <= '0';
    i_fr_rowcnt <= (others => '0');
    i_padding <= '0';
    i_prm.mem_trnlen <= std_logic_vector(TO_UNSIGNED(16#4040#, i_prm.mem_trnlen'length));
    i_prm.fr.pixcount <= (others => '0');
    i_prm.fr.rowcount <= (others => '0');
    i_frrdy <= '0'; sr_vwr_en <= '0';

  else
    sr_vwr_en <= i_vwr_en;

    case i_fsm_state_cs is

      --------------------------------------
      --
      --------------------------------------
      when S_IDLE =>

        i_padding <= '0';
        i_fr_rowcnt <= (others => '0');
        i_frrdy <= '0';

        if i_ibuf2_empty(0) = '0' and sr_vwr_en = '1' then
          i_prm.mem_trnlen <= p_in_usrprm.mem_trnlen;
          i_prm.fr.rowcount <= p_in_usrprm.fr.rowcount;
          if CI_PIXBIT = 8 then
          i_prm.fr.pixcount <= p_in_usrprm.fr.pixcount;
          else
          i_prm.fr.pixcount <= p_in_usrprm.fr.pixcount(p_in_usrprm.fr.pixcount'length - 2 downto 0) & '0'; --16bit/pix
          end if;

          i_fsm_state_cs <= S_MEM_START;
        end if;

      --------------------------------------
      --
      --------------------------------------
      when S_MEM_START =>

        if sr_vwr_en = '0' then
          i_fsm_state_cs <= S_IDLE;

        else

          i_mem_adr <= i_prm.fr.pixcount * i_fr_rowcnt;

          i_mem_rqlen <= RESIZE(i_prm.fr.pixcount(i_prm.fr.pixcount'high downto log2(G_MEM_DWIDTH / 8))
                                                                                , i_mem_rqlen'length)
                           + (TO_UNSIGNED(0, i_mem_rqlen'length - 2)
                              & OR_reduce(i_prm.fr.pixcount(log2(G_MEM_DWIDTH / 8) - 1 downto 0)));

          i_mem_dir <= C_MEMWR_WRITE;
          i_mem_start <= '1';
          i_fsm_state_cs <= S_MEM_WR;

        end if;

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_MEM_WR =>

        if sr_vwr_en = '0' then
          i_padding <= '1';
        end if;

        i_mem_start <= '0';
        if i_mem_done = '1' then
          if (i_fr_rowcnt = (i_prm.fr.rowcount - 1)) or i_padding = '1' then

            if i_padding = '1' then
              i_frrdy <= '0';
            else
              i_frrdy <= '1';
            end if;

            i_fsm_state_cs <= S_IDLE;
          else
            i_fr_rowcnt <= i_fr_rowcnt + 1;
            i_fsm_state_cs <= S_MEM_START;
          end if;
        end if;

    end case;

  end if;
end if;
end process;



--------------------------------------------------------
--
--------------------------------------------------------
i_mem_adr_out(i_mem_adr_out'high downto G_MEM_VCH_M_BIT + 1) <= (others => '0');
i_mem_adr_out(G_MEM_VCH_M_BIT downto G_MEM_VCH_L_BIT) <= TO_UNSIGNED(G_VCH_NUM, (G_MEM_VCH_M_BIT - G_MEM_VCH_L_BIT + 1));
i_mem_adr_out(G_MEM_VFR_M_BIT downto G_MEM_VFR_L_BIT) <= UNSIGNED(p_in_frbuf);
i_mem_adr_out(G_MEM_VLINE_M_BIT downto 0) <= i_mem_adr(G_MEM_VLINE_M_BIT downto 0);

i_buf_empty <= i_ibuf2_empty(0) and not i_padding when i_fr_rowcnt(0) = '0' else
               i_ibuf2_empty(1) and not i_padding;

i_ibuf_do <= i_ibuf2_do(0) when i_fr_rowcnt(0) = '0' else i_ibuf2_do(1);
i_ibuf2_rd(0) <= i_ibuf_rd and not i_fr_rowcnt(0);
i_ibuf2_rd(1) <= i_ibuf_rd and     i_fr_rowcnt(0);

m_mem_wr : mem_wr
generic map(
--G_USR_OPT        => G_USR_OPT,
G_MEM_BANK_M_BIT => 31,
G_MEM_BANK_L_BIT => 30,
G_MEM_AWIDTH     => G_MEM_AWIDTH,
G_MEM_DWIDTH     => G_MEM_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_mem_adr     => std_logic_vector(i_mem_adr_out),
p_in_cfg_mem_trn_len => std_logic_vector(RESIZE(UNSIGNED(i_prm.mem_trnlen), 16)),
p_in_cfg_mem_dlen_rq => std_logic_vector(i_mem_rqlen),
p_in_cfg_mem_wr      => i_mem_dir,
p_in_cfg_mem_start   => i_mem_start,
p_out_cfg_mem_done   => i_mem_done,

-------------------------------
--USER Port
-------------------------------
p_in_usr_txbuf_dout  => i_ibuf_do,
p_out_usr_txbuf_rd   => i_ibuf_rd,
p_in_usr_txbuf_empty => i_buf_empty,

p_out_usr_rxbuf_din  => open,
p_out_usr_rxbuf_wd   => open,
p_in_usr_rxbuf_full  => '0',

---------------------------------
--MEM_CTRL Port
---------------------------------
p_out_mem            => p_out_mem,
p_in_mem             => p_in_mem,

-------------------------------
--System
-------------------------------
p_in_tst             => p_in_tst,
p_out_tst            => tst_mem_wr_out,

p_in_clk             => p_in_clk,
p_in_rst             => p_in_rst
);


------------------------------------
--DBG
------------------------------------
--p_out_tst(31 downto 0) <= (others => '0');
p_out_tst(5 downto 0) <= tst_mem_wr_out(5 downto 0);
p_out_tst(7 downto 6) <= OR_reduce(tst_upp_data) & tst_upp_data_rd;
p_out_tst(10 downto 8 )<= std_logic_vector(tst_fsm_cs_dly(2 downto 0));
p_out_tst(11) <= tst_ibuf_empty or tst_ibuf_full;
p_out_tst(21 downto 16) <= tst_mem_wr_out(21 downto 16);--i_mem_trnlen(5 downto 0);
p_out_tst(31 downto 22) <= (others => '0');


process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    tst_ibuf_empty <= AND_reduce(i_ibuf2_empty);
    tst_fsm_cs_dly <= tst_fsmstate;
    tst_upp_data <= i_ibuf_do;
    tst_upp_data_rd <= OR_reduce(i_ibuf2_rd);
    tst_ibuf_full <= AND_reduce(i_ibuf2_full);
  end if;
end process;
tst_fsmstate <= TO_UNSIGNED(16#01#, tst_fsmstate'length) when i_fsm_state_cs = S_MEM_START else
                TO_UNSIGNED(16#02#, tst_fsmstate'length) when i_fsm_state_cs = S_MEM_WR    else
                TO_UNSIGNED(16#00#, tst_fsmstate'length); --i_fsm_state_cs = S_IDLE        else

end architecture behavioral;

