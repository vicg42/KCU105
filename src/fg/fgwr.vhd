-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 17.02.2015 14:02:10
-- Module Name : fgwr (frame grabber - writer)
--
-- Description : Video source -> MEM(VBUF)
--
-- Video Packet Header:
-------------------------------------------------------------------------
-- |31....28|27....24|23....20|19....16 | 15....12|11....8|7....4|3....0|
-------------------------------------------------------------------------
-- |        | Fr.Num |   VCH  | PktType |         Length                |
-------------------------------------------------------------------------
-- |         Fr. LineCount              |         Fr. PixCount          |
-------------------------------------------------------------------------
-- |         Fr. LineNum                |         Fr. PixNum            |
-------------------------------------------------------------------------
-- |         TimeStump_MSB              |         TimeStump_LSB         |
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.mem_wr_pkg.all;
use work.prj_def.all;

entity fgwr is
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
p_in_memtrn : in  std_logic_vector((C_HREG_MEM_CTRL_TRNWR_M_BIT - C_HREG_MEM_CTRL_TRNWR_L_BIT) downto 0);
--p_in_work_en : in  std_logic;

p_in_frbuf  : in  TFG_FrBufs;
p_out_frrdy : out std_logic_vector(G_VCH_COUNT - 1 downto 0);
p_out_frmrk : out std_logic_vector(31 downto 0);

-------------------------------
--DataIN
-------------------------------
p_in_vbufi_do    : in  std_logic_vector((G_MEM_DWIDTH * G_VBUFI_COUNT_MAX) - 1 downto 0);
p_out_vbufi_rd   : out std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_empty : in  std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_full  : in  std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);
p_in_vbufi_pfull : in  std_logic_vector(G_VBUFI_COUNT_MAX - 1 downto 0);

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem : out TMemIN;
p_in_mem  : in  TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst  : in  std_logic_vector(31 downto 0);
p_out_tst : out std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk : in  std_logic;
p_in_rst : in  std_logic
);
end entity fgwr;

architecture behavioral of fgwr is

-- Small delay for simulation purposes.
constant dly : time := 1 ps;

constant CI_PKT_TYPE : integer := 1;
constant CI_ADD      : integer := 2;--Field Length: byte count

type TFsm_state is (
S_IDLE,
S_PKTH_RD,
S_PKTH_RD1,
S_MEM_START,
S_MEM_WR,
S_PKTSKIP
);
signal i_fsm_fgwr         : TFsm_state;

signal i_pkt_size_byte    : unsigned(15 downto 0);

signal i_vbufi_sel        : std_logic;
signal i_vbufi_rden       : std_logic;
signal i_vbufi_rd         : std_logic;
signal i_vbufi_do         : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
signal i_vbufi_empty      : std_logic;

signal i_fr_rdy           : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_fr_bufnum        : unsigned(G_MEM_VFR_M_BIT - G_MEM_VFR_L_BIT downto 0);
signal i_fr_pixnum        : unsigned(15 downto 0);
signal i_fr_rownum        : unsigned(15 downto 0);
signal i_fr_pixcount      : unsigned(15 downto 0);
signal i_fr_rowcount      : unsigned(15 downto 0);
signal i_fr_rowmrk        : std_logic_vector(31 downto 0);
Type TVfrNum is array (0 to G_VCH_COUNT - 1) of std_logic_vector(3 downto 0);
signal i_fr_num           : TVfrNum;
signal i_vch_num          : unsigned(3 downto 0);

signal i_mem_adr          : unsigned(G_MEM_AWIDTH - 1 downto 0);
signal i_mem_trnlen       : unsigned(15 downto 0);
signal i_mem_rqlen        : unsigned(15 downto 0);
signal i_mem_start        : std_logic;
signal i_mem_dir          : std_logic;
signal i_mem_done         : std_logic;
signal i_memwr_rden       : std_logic;
signal i_memwr_rd         : std_logic;

signal i_pixcount_byte    : unsigned(15 downto 0);

signal i_err              : std_logic;
signal i_skp_dcnt         : unsigned(i_mem_rqlen'range);
signal i_skp_en           : std_logic;

signal tst_fgwr_fsm       : unsigned(2 downto 0);
signal tst_timestump_cnt  : unsigned(31 downto 0);
signal tst_vbufi_full_detect     : std_logic;
signal tst_vbufi_rd       : std_logic_vector(1 downto 0);
signal tst_vbufi_full     : std_logic_vector(1 downto 0);
signal tst_vbufi_empty    : std_logic_vector(1 downto 0);


begin --architecture behavioral


-----------------------------------------------
--
------------------------------------------------
p_out_frrdy <= i_fr_rdy;
p_out_frmrk <= i_fr_rowmrk when p_in_tst(C_FG_REG_DBG_TIMESTUMP_BIT) = '0'
                    else std_logic_vector(tst_timestump_cnt);


------------------------------------------------
--Select Count VBUFI
------------------------------------------------
gen_vbuf_count_1 : if (G_VBUFI_COUNT = 1) generate
begin
p_out_vbufi_rd(0) <= i_vbufi_rd;

p_out_vbufi_rd(p_out_vbufi_rd'high downto 1) <= (others => '0');

i_vbufi_do <= p_in_vbufi_do((G_MEM_DWIDTH * (0 + 1)) - 1 downto (G_MEM_DWIDTH * 0));

i_vbufi_empty <= p_in_vbufi_empty(0);

tst_vbufi_rd(0) <= i_vbufi_rd;
tst_vbufi_rd(1) <= '0';

tst_vbufi_full(0) <= p_in_vbufi_pfull(0);
tst_vbufi_full(1) <= '0';

tst_vbufi_empty(0) <= p_in_vbufi_empty(0);
tst_vbufi_empty(1) <= '1';

end generate gen_vbuf_count_1;


gen_vbuf_count_2 : if (G_VBUFI_COUNT = 2) generate
begin
p_out_vbufi_rd(0) <= i_vbufi_rd when i_vbufi_sel = '0' else '0';
p_out_vbufi_rd(1) <= i_vbufi_rd when i_vbufi_sel = '1' else '0';

i_vbufi_do <= p_in_vbufi_do((G_MEM_DWIDTH * (0 + 1)) - 1 downto (G_MEM_DWIDTH * 0)) when i_vbufi_sel = '0' else
              p_in_vbufi_do((G_MEM_DWIDTH * (1 + 1)) - 1 downto (G_MEM_DWIDTH * 1));

i_vbufi_empty <= p_in_vbufi_empty(0) when i_vbufi_sel = '0' else p_in_vbufi_empty(1);

tst_vbufi_rd(0) <= i_vbufi_rd when i_vbufi_sel = '0' else '0';
tst_vbufi_rd(1) <= i_vbufi_rd when i_vbufi_sel = '1' else '0';

tst_vbufi_full <= p_in_vbufi_pfull;
tst_vbufi_empty <= p_in_vbufi_empty;

end generate gen_vbuf_count_2;


------------------------------------------------
--Read VPKT
------------------------------------------------
i_vbufi_rd <= ((i_vbufi_rden or i_skp_en) and (not i_vbufi_empty))
            or (i_memwr_rden and i_memwr_rd);


------------------------------------------------
--FSM
------------------------------------------------
process(p_in_clk)
Type TTimestump_test is array (0 to G_VCH_COUNT - 1) of unsigned(31 downto 0);
variable timestump_cnt : TTimestump_test;
variable fr_rownum : unsigned(i_fr_rownum'range);
variable fr_pixnum : unsigned(i_fr_pixnum'range);
variable vch_num : unsigned(3 downto 0);
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then

    i_fsm_fgwr <= S_IDLE;

    i_vbufi_rden <= '0';
    i_vbufi_sel <= '0';
    i_memwr_rden <= '0';
    i_pkt_size_byte <= (others => '0');

    i_err <= '0';
    i_skp_en <= '0';
    i_skp_dcnt <= (others => '0');

    i_vch_num <= (others => '0');
    for i in 0 to G_VCH_COUNT - 1 loop
      i_fr_num(i) <= (others => '0');
      timestump_cnt(i) := (others => '0');
    end loop;

    fr_rownum   := (others => '0');
    fr_pixnum   := (others => '0');

    i_fr_bufnum <= (others => '0');
    i_fr_pixnum <= (others => '0');
    i_fr_rownum <= (others => '0');
    i_fr_pixcount <= (others => '0');
    i_fr_rowcount <= (others => '0');
    i_fr_rowmrk <= (others => '0');
    i_fr_rdy <= (others => '0');

    i_mem_adr <= (others => '0');
    i_mem_rqlen <= (others => '0');
    i_mem_dir <= C_MEMWR_WRITE;
    i_mem_start <= '0';

    i_pixcount_byte <= (others => '0');
    tst_timestump_cnt <= (others => '0');

  else

    case i_fsm_fgwr is

      --------------------------------------
      --
      --------------------------------------
      when S_IDLE =>

        i_fr_rdy <= (others => '0');
        i_skp_dcnt <= (others => '0');

        --wait data
        if (i_vbufi_empty = '0') then

          if (UNSIGNED(i_vbufi_do(15 downto 0)) /= TO_UNSIGNED(0, 16)) then

            i_pkt_size_byte <= UNSIGNED(i_vbufi_do(15 downto 0)) + CI_ADD;

            i_vbufi_rden <= '1';

            i_fsm_fgwr <= S_PKTH_RD;

          end if;

        else

          i_vbufi_sel <= not i_vbufi_sel;

        end if;

      --------------------------------------
      --Pkt Header
      --------------------------------------
      when S_PKTH_RD =>

        --Calculate pixcount
        i_pixcount_byte <= i_pkt_size_byte
                            - TO_UNSIGNED(C_FG_PKT_HD_SIZE_BYTE, i_pixcount_byte'length);

        if UNSIGNED(i_vbufi_do((32 * 0) + 19 downto (32 * 0) + 16)) = TO_UNSIGNED(CI_PKT_TYPE, 4)
            and UNSIGNED(i_vbufi_do((32 * 0) + 23 downto (32 * 0) + 20)) < TO_UNSIGNED(G_VCH_COUNT, 4) then

          --video channel number:
          vch_num := UNSIGNED(i_vbufi_do((32 * 0) + 23 downto (32 * 0) + 20));
          i_vch_num <= vch_num;

          for i in 0 to G_VCH_COUNT - 1 loop
            if (vch_num = i) then
              --frame number :
              i_fr_num(i) <= i_vbufi_do((32 * 0) + 27 downto (32 * 0) + 24);
              i_fr_bufnum <= p_in_frbuf(i);
             end if;
          end loop;

          --frame resolution:
          i_fr_pixcount <= UNSIGNED(i_vbufi_do((32 * 1) + 15 downto (32 * 1) +  0));
          i_fr_rowcount <= UNSIGNED(i_vbufi_do((32 * 1) + 31 downto (32 * 1) + 16));

          i_err <= '0';

        else

          i_err <= '1';

        end if;

        i_fsm_fgwr <= S_PKTH_RD1;


      when S_PKTH_RD1 =>

        if (i_vbufi_empty = '0') then

          i_vbufi_rden <= '0';

          --current number of row and pixel
          i_fr_pixnum <= UNSIGNED(i_vbufi_do((32 * 0) + 15 downto (32 * 0) +  0));
          i_fr_rownum <= UNSIGNED(i_vbufi_do((32 * 0) + 31 downto (32 * 0) + 16));

          --timestump:
          i_fr_rowmrk <= i_vbufi_do((32 * 1) + 31 downto (32 * 1) + 0);

          i_fsm_fgwr <= S_MEM_START;

        end if;

      --------------------------------------
      --MEM_WR
      --------------------------------------
      when S_MEM_START =>

        i_vbufi_rden <= '0';

        i_mem_adr(G_MEM_VCH_M_BIT downto G_MEM_VCH_L_BIT) <= i_vch_num(G_MEM_VCH_M_BIT - G_MEM_VCH_L_BIT
                                                                                                   downto 0);
        i_mem_adr(G_MEM_VFR_M_BIT downto G_MEM_VFR_L_BIT) <= i_fr_bufnum;
        i_mem_adr(G_MEM_VLINE_M_BIT downto G_MEM_VLINE_L_BIT) <= i_fr_rownum(G_MEM_VLINE_M_BIT - G_MEM_VLINE_L_BIT
                                                                                                            downto 0);
        i_mem_adr(G_MEM_VLINE_L_BIT - 1 downto 0) <= i_fr_pixnum(G_MEM_VLINE_L_BIT - 1 downto 0);

        i_mem_rqlen <= RESIZE(i_pixcount_byte(i_pixcount_byte'high downto log2(G_MEM_DWIDTH / 8))
                                                                              , i_mem_rqlen'length)
                         + (TO_UNSIGNED(0, i_mem_rqlen'length - 2)
                            & OR_reduce(i_pixcount_byte(log2(G_MEM_DWIDTH / 8) - 1 downto 0)));

        i_mem_dir <= C_MEMWR_WRITE;

        if (i_err = '0') then

          i_memwr_rden <= '1';
          i_mem_start <= '1';

          i_fsm_fgwr <= S_MEM_WR;

        else

          i_skp_en <= '1';
          i_fsm_fgwr <= S_PKTSKIP;

        end if;


      when S_MEM_WR =>

        i_mem_start <= '0';

        if (i_mem_done = '1') then

          i_memwr_rden <= '0';

          if (i_fr_rownum = (i_fr_rowcount - 1)) then
          --Frame complete
            if (i_fr_pixcount = (i_pixcount_byte + i_fr_pixnum)) then
              for i in 0 to G_VCH_COUNT - 1 loop
                if (i_vch_num = i) then
                  i_fr_rdy(i) <= '1';
                  timestump_cnt(i) := timestump_cnt(i) + 1;
                  tst_timestump_cnt <= timestump_cnt(i);
                end if;
              end loop;
            end if;
          end if;

          i_vbufi_sel <= not i_vbufi_sel;

          i_fsm_fgwr <= S_IDLE;
        end if;

      --------------------------------------
      --SKIP
      --------------------------------------
      when S_PKTSKIP =>

        if (i_vbufi_empty = '0') then

          i_skp_dcnt <= i_skp_dcnt + 1;

          if (i_skp_dcnt = (i_mem_rqlen - 1)) then
            i_skp_en <= '0';
            i_vbufi_sel <= not i_vbufi_sel;
            i_fsm_fgwr <= S_IDLE;
          end if;

        end if;

    end case;

  end if;
end if;
end process;


i_mem_trnlen <= RESIZE(UNSIGNED(p_in_memtrn), i_mem_trnlen'length);

m_mem_wr : mem_wr
generic map(
--G_USR_OPT => G_USR_OPT,
G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEM_DWIDTH => G_MEM_DWIDTH
)
port map(
-------------------------------
--CFG
-------------------------------
p_in_cfg_mem_adr     => std_logic_vector(i_mem_adr),
p_in_cfg_mem_trn_len => std_logic_vector(i_mem_trnlen),
p_in_cfg_mem_dlen_rq => std_logic_vector(i_mem_rqlen),
p_in_cfg_mem_wr      => i_mem_dir,
p_in_cfg_mem_start   => i_mem_start,
p_out_cfg_mem_done   => i_mem_done,

-------------------------------
--USER Port
-------------------------------
p_in_usr_txbuf_dout  => i_vbufi_do,
p_out_usr_txbuf_rd   => i_memwr_rd,
p_in_usr_txbuf_empty => i_vbufi_empty,

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
p_out_tst            => open,

p_in_clk             => p_in_clk,
p_in_rst             => p_in_rst
);


------------------------------------
--DBG
------------------------------------
gen_dbgcs_off : if strcmp(G_DBGCS,"OFF") generate
p_out_tst(22 downto 0) <= (others => '0');
p_out_tst(23) <= i_err;
p_out_tst(31 downto 24) <= (others => '0');
end generate gen_dbgcs_off;

gen_dbgcs_on : if strcmp(G_DBGCS,"ON") generate
p_out_tst(2  downto 0) <= std_logic_vector(tst_fgwr_fsm);
p_out_tst(15 downto 3) <= std_logic_vector(i_fr_rownum(12 downto 0));
p_out_tst(16) <= i_mem_start;
p_out_tst(17) <= i_mem_done;
p_out_tst(18) <= i_err;
p_out_tst(19) <= i_vbufi_sel;
p_out_tst(20) <= i_vbufi_empty;
p_out_tst(21) <= i_fr_rdy(0);
p_out_tst(22) <= tst_vbufi_full_detect;
p_out_tst(23) <= tst_vbufi_rd(0);
p_out_tst(24) <= tst_vbufi_empty(0);
p_out_tst(25) <= tst_vbufi_full(0);
p_out_tst(26) <= tst_vbufi_rd(1);
p_out_tst(27) <= tst_vbufi_empty(1);
p_out_tst(28) <= tst_vbufi_full(1);
p_out_tst(31 downto 29) <= (others => '0');

process(p_in_clk)
begin
  if rising_edge(p_in_clk) then

    if p_in_vbufi_full(0) = '1' then
      tst_vbufi_full_detect <= '1';
    elsif i_fsm_fgwr = S_IDLE then
      tst_vbufi_full_detect <= '0';
    end if;

  end if;
end process;

tst_fgwr_fsm <= TO_UNSIGNED(16#01#, tst_fgwr_fsm'length) when i_fsm_fgwr = S_PKTH_RD   else
                TO_UNSIGNED(16#02#, tst_fgwr_fsm'length) when i_fsm_fgwr = S_PKTH_RD1  else
                TO_UNSIGNED(16#03#, tst_fgwr_fsm'length) when i_fsm_fgwr = S_MEM_START else
                TO_UNSIGNED(16#04#, tst_fgwr_fsm'length) when i_fsm_fgwr = S_MEM_WR    else
                TO_UNSIGNED(16#05#, tst_fgwr_fsm'length) when i_fsm_fgwr = S_PKTSKIP   else
                TO_UNSIGNED(16#00#, tst_fgwr_fsm'length); --i_fsm_fgwr = S_IDLE        else
end generate gen_dbgcs_on;

end architecture behavioral;

