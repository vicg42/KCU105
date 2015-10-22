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
use work.prj_def.all;

entity fgwr is
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
end entity fgwr;

architecture behavioral of fgwr is

-- Small delay for simulation purposes.
constant dly : time := 1 ps;

type fsm_state is (
S_IDLE,
S_PKTH_RD,
S_MEM_START,
S_MEM_WR
);
signal i_fsm_cs: fsm_state;

signal i_pkth_cnt         : unsigned(3 downto 0);
signal i_pkt_hd_rd        : std_logic;
signal i_pkt_vd_rd        : std_logic;

signal i_fr_rdy           : std_logic_vector(G_FG_VCH_COUNT - 1 downto 0);
signal i_fr_bufnum        : unsigned(G_MEM_VFR_M_BIT - G_MEM_VFR_L_BIT downto 0);
signal i_fr_pixnum        : unsigned(15 downto 0);
signal i_fr_rownum        : unsigned(15 downto 0);
signal i_fr_pixcount      : unsigned(15 downto 0);
signal i_fr_rowcount      : unsigned(15 downto 0);
signal i_fr_rowmrk        : std_logic_vector(31 downto 0);
signal i_fr_rowmrk_l      : std_logic_vector(15 downto 0);
Type TVfrNum is array (0 to G_FG_VCH_COUNT - 1) of std_logic_vector(3 downto 0);
signal i_fr_num           : TVfrNum;
signal i_ch_num           : unsigned(3 downto 0);

signal i_mem_adr_base     : unsigned(31 downto 0);
signal i_mem_adr_out      : unsigned(31 downto 0);
signal i_mem_adr          : unsigned(31 downto 0);
signal i_mem_trnlen       : unsigned(p_in_memtrn'range);
signal i_mem_trnlen_out   : unsigned(15 downto 0);
signal i_mem_rqlen        : unsigned(15 downto 0);
signal i_mem_start        : std_logic;
signal i_mem_dir          : std_logic;
signal i_mem_done         : std_logic;

signal i_memwr_rd_out     : std_logic;
signal i_pkt_hd_rd_out    : std_logic;

signal i_pkt_skp_rd_out   : std_logic;
signal i_pkt_type_err     : std_logic_vector(3 downto 0);
signal i_pkt_size_byte    : unsigned(15 downto 0);
signal i_pkt_skp_data     : unsigned(15 downto 0);
signal i_pkt_skp_dcnt     : unsigned(15 downto 0);
signal i_pkt_skp_rd       : std_logic;

signal i_pixcount_byte    : unsigned(15 downto 0);

signal tst_fsmstate       : unsigned(3 downto 0);
signal tst_fsmstate_out   : std_logic_vector(3 downto 0);
signal tst_err_det        : std_logic;
signal tst_vbufi_full     : std_logic;
signal tst_vbufi_empty    : std_logic;
signal tst_timestump_cnt  : unsigned(31 downto 0);

signal tst_vbufi_do       : std_logic_vector(p_in_vbufi_do'range);
signal tst_vbufi_rd       : std_logic;


begin --architecture behavioral


-----------------------------------------------
--
------------------------------------------------
p_out_frrdy <= i_fr_rdy;
p_out_frmrk <= i_fr_rowmrk when p_in_tst(C_FG_REG_TST0_DBG_TIMESTUMP_BIT) = '0'
                    else std_logic_vector(tst_timestump_cnt);


------------------------------------------------
--Read VPKT
------------------------------------------------
p_out_vbufi_rd <= i_pkt_hd_rd_out or (i_pkt_vd_rd and i_memwr_rd_out) or i_pkt_skp_rd_out;

i_pkt_hd_rd_out <= (i_pkt_hd_rd  and not p_in_vbufi_empty);

i_pkt_skp_rd_out <= (i_pkt_skp_rd  and not p_in_vbufi_empty);


------------------------------------------------
--FSM
------------------------------------------------
process(p_in_clk)
Type TTimestump_test is array (0 to G_FG_VCH_COUNT - 1) of unsigned(31 downto 0);
variable timestump_cnt : TTimestump_test;
variable fr_pixcount : unsigned(i_fr_pixcount'range);
variable fr_rownum : unsigned(i_fr_rownum'range);
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then

    i_fsm_cs <= S_IDLE;

    i_pkth_cnt <= (others => '0');
    i_pkt_hd_rd <= '0';
    i_pkt_vd_rd <= '0';

    i_ch_num <= (others => '0');
    for i in 0 to G_FG_VCH_COUNT - 1 loop
      i_fr_num(i) <= (others => '0');
      timestump_cnt(i) := (others => '0');
    end loop;

    fr_pixcount := (others => '0');
    fr_rownum   := (others => '0');

    i_fr_bufnum <= (others => '0');
    i_fr_pixnum <= (others => '0');
    i_fr_rownum <= (others => '0');
    i_fr_pixcount <= (others => '0');
    i_fr_rowcount <= (others => '0');
    i_fr_rowmrk <= (others => '0');
    i_fr_rowmrk_l <= (others => '0');
    i_fr_rdy <= (others => '0');

    i_mem_adr_base <= (others => '0');
    i_mem_adr <= (others => '0');
    i_mem_rqlen <= (others => '0');
    i_mem_trnlen <= (others => '0');
    i_mem_dir <= '0';
    i_mem_start <= '0';

    i_pkt_skp_rd <= '0';
    i_pkt_size_byte <= (others => '0');
    i_pkt_skp_dcnt <= (others => '0'); i_pkt_type_err <= (others => '0');

    i_pkt_skp_data <= (others => '0');
    i_pixcount_byte <= (others => '0');
    tst_timestump_cnt <= (others => '0');

  else

    case i_fsm_cs is

      --------------------------------------
      --
      --------------------------------------
      when S_IDLE =>

        i_fr_rdy <= (others => '0');

        --wait data
        if p_in_vbufi_empty = '0' then

          if UNSIGNED(p_in_vbufi_do(15 downto 0)) /= TO_UNSIGNED(0, 16) then

            i_pkt_size_byte <= UNSIGNED(p_in_vbufi_do(15 downto 0)) + 2;

            i_pkt_hd_rd <= '0';

            i_pkt_type_err <= (others => '0');
            i_fsm_cs <= S_PKTH_RD;

          end if;

        end if;

      --------------------------------------
      --Pkt Header
      --------------------------------------
      when S_PKTH_RD =>

        i_pkt_hd_rd <= '1';

        --Calculate pixcount
        i_pixcount_byte <= i_pkt_size_byte
                            - TO_UNSIGNED(C_FG_PKT_HD_SIZE_BYTE, i_pixcount_byte'length);

        if p_in_vbufi_do(19 downto 16) = "0001"
            and UNSIGNED(p_in_vbufi_do(23 downto 20)) < TO_UNSIGNED(G_FG_VCH_COUNT, 4) then
        --PktType - VideoData + Chack number source

          --Save number current vch:
          i_ch_num <= UNSIGNED(p_in_vbufi_do(23 downto 20));

          for i in 0 to G_FG_VCH_COUNT - 1 loop
            if i_ch_num = i then
              --Save number current frame:
              i_fr_num(i) <= p_in_vbufi_do(27 downto 24);
              i_fr_bufnum <= p_in_frbuf(i);
             end if;
          end loop;

          --Frame resolution:
          fr_pixcount := UNSIGNED(p_in_vbufi_do((32 * 1) + 15 downto (32 * 1) +  0));
          i_fr_rowcount <= UNSIGNED(p_in_vbufi_do((32 * 1) + 31 downto (32 * 1) + 16));
          i_fr_pixcount <= fr_pixcount;

          --current number of row and pixel
          i_fr_pixnum <= UNSIGNED(p_in_vbufi_do((32 * 2) + 15 downto (32 * 2) +  0));
          fr_rownum := UNSIGNED(p_in_vbufi_do((32 * 2) + 31 downto (32 * 2) + 16));
          i_fr_rownum <= fr_rownum;

          --timestump:
          i_fr_rowmrk <= p_in_vbufi_do((32 * 3) + 31 downto (32 * 3) + 0);

        end if;

        i_mem_adr_base <= fr_pixcount * fr_rownum;

        i_fsm_cs <= S_MEM_START;


      --------------------------------------
      --MEM_WR
      --------------------------------------
      when S_MEM_START =>

        i_pkt_hd_rd <= '0';
        i_pkt_vd_rd <= '1';

        i_mem_adr <= i_mem_adr_base + RESIZE(i_fr_pixnum, i_mem_adr'length);

        i_mem_rqlen <= RESIZE(i_pixcount_byte(i_pixcount_byte'high downto log2(G_MEM_DWIDTH / 8))
                                                                              , i_mem_rqlen'length)
                         + (TO_UNSIGNED(0, i_mem_rqlen'length - 2)
                            & OR_reduce(i_pixcount_byte(log2(G_MEM_DWIDTH / 8) - 1 downto 0)));

        i_mem_trnlen <= UNSIGNED(p_in_memtrn);
        i_mem_dir <= C_MEMWR_WRITE;
        i_mem_start <= '1';
        i_fsm_cs <= S_MEM_WR;


      when S_MEM_WR =>

        i_mem_start <= '0';

        if i_mem_done = '1' then

          i_pkt_vd_rd <= '0';

          if i_fr_rownum = (i_fr_rowcount - 1) then
          --Frame complete
            if i_fr_pixcount = (i_pixcount_byte + i_fr_pixnum) then
              for i in 0 to G_FG_VCH_COUNT - 1 loop
                if i_ch_num = i then
                  i_fr_rdy(i) <= '1';
                  timestump_cnt(i) := timestump_cnt(i) + 1;
                  tst_timestump_cnt <= timestump_cnt(i);
                end if;
              end loop;
            end if;
          end if;

          i_fsm_cs <= S_IDLE;
        end if;

    end case;

  end if;
end if;
end process;


i_mem_adr_out(i_mem_adr_out'high downto G_MEM_VCH_M_BIT + 1) <= (others => '0');
i_mem_adr_out(G_MEM_VCH_M_BIT downto G_MEM_VCH_L_BIT) <= i_ch_num(G_MEM_VCH_M_BIT - G_MEM_VCH_L_BIT downto 0);
i_mem_adr_out(G_MEM_VFR_M_BIT downto G_MEM_VFR_L_BIT) <= i_fr_bufnum;
i_mem_adr_out(G_MEM_VLINE_M_BIT downto 0) <= i_mem_adr(G_MEM_VLINE_M_BIT downto 0);

i_mem_trnlen_out <= RESIZE(i_mem_trnlen, i_mem_trnlen_out'length);

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
p_in_cfg_mem_trn_len => std_logic_vector(i_mem_trnlen_out),
p_in_cfg_mem_dlen_rq => std_logic_vector(i_mem_rqlen),
p_in_cfg_mem_wr      => i_mem_dir,
p_in_cfg_mem_start   => i_mem_start,
p_out_cfg_mem_done   => i_mem_done,

-------------------------------
--USER Port
-------------------------------
p_in_usr_txbuf_dout  => p_in_vbufi_do,
p_out_usr_txbuf_rd   => i_memwr_rd_out,
p_in_usr_txbuf_empty => p_in_vbufi_empty,

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
p_out_tst(26 downto 0) <= (others => '0');
p_out_tst(31 downto 26) <= "00" & i_pkt_type_err(2 downto 0) & '0';
end generate gen_dbgcs_off;

gen_dbgcs_on : if strcmp(G_DBGCS,"ON") generate
p_out_tst(3  downto 0) <= tst_fsmstate_out;
p_out_tst(4) <= i_mem_start or tst_err_det or tst_vbufi_empty or OR_reduce(tst_vbufi_do) or tst_vbufi_rd;
p_out_tst(25 downto 5) <= (others => '0');
p_out_tst(31 downto 26) <= "00" & i_pkt_type_err(2 downto 0) & '0';

process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    tst_fsmstate_out <= std_logic_vector(tst_fsmstate);
    tst_vbufi_empty <= p_in_vbufi_empty;

    if p_in_vbufi_full = '1' then
      tst_vbufi_full <= '1';
    elsif i_fsm_cs = S_IDLE then
      tst_vbufi_full <= '0';
    end if;
    tst_err_det <= OR_reduce(i_pkt_type_err) or tst_vbufi_full;

    tst_vbufi_do <= p_in_vbufi_do;
    tst_vbufi_rd <= i_memwr_rd_out;

  end if;
end process;

tst_fsmstate <= TO_UNSIGNED(16#01#, tst_fsmstate'length) when i_fsm_cs = S_PKTH_RD   else
                TO_UNSIGNED(16#02#, tst_fsmstate'length) when i_fsm_cs = S_MEM_START else
                TO_UNSIGNED(16#03#, tst_fsmstate'length) when i_fsm_cs = S_MEM_WR    else
                TO_UNSIGNED(16#00#, tst_fsmstate'length); --i_fsm_cs = S_IDLE        else
end generate gen_dbgcs_on;

end architecture behavioral;

