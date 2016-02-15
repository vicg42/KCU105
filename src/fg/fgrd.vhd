-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.02.2015 13:39:07
-- Module Name : fgrd (frame grabber - reader)
--
-- Description : (HOST <- MEM(VBUF))
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

entity fgrd is
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
p_in_usrprm          : in    TFG_VCHPrms;
p_in_memtrn          : in    std_logic_vector((C_HREG_MEM_CTRL_TRNRD_M_BIT - C_HREG_MEM_CTRL_TRNRD_L_BIT) downto 0);

p_in_hrd_chsel       : in    std_logic_vector(2 downto 0);--Host: Channel number for read
p_in_hrd_start       : in    std_logic;                   --Host: Start read data
p_in_hrd_done        : in    std_logic;                   --Host: ACK read done

p_in_frbuf           : in    TFG_FrBufs;                  --number framebuffer(vbuf) for read
p_in_frline_nxt      : in    std_logic;                   --Enable read next line

p_out_vchnum         : out   std_logic_vector(2 downto 0);
p_out_pixcount       : out   std_logic_vector(15 downto 0);
p_out_linecount      : out   std_logic_vector(15 downto 0);
p_out_mirx           : out   std_logic;
p_out_fr_rddone      : out   std_logic; --Read of frame is done

----------------------------
--Upstream Port
----------------------------
p_out_upp_data       : out   std_logic_vector(G_MEM_DWIDTH - 1 downto 0);
p_out_upp_data_wd    : out   std_logic;
p_in_upp_buf_empty   : in    std_logic;
p_in_upp_buf_full    : in    std_logic;

---------------------------------
--Port MEM_CTRL
---------------------------------
p_out_mem            : out   TMemIN;
p_in_mem             : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst             : in    std_logic_vector(31 downto 0);
p_out_tst            : out   std_logic_vector(127 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk             : in    std_logic;
p_in_rst             : in    std_logic
);
end entity fgrd;

architecture behavioral of fgrd is

type fsm_state is (
S_IDLE,
S_SET_PRMS,
S_MEM_SET_ADR,
S_MEM_START,
S_MEM_RD,
S_ROW_NXT,
S_WAIT_HOST_ACK
);
signal i_fsm_fgrd: fsm_state;

signal i_mem_adr              : unsigned(G_MEM_AWIDTH - 1 downto 0);
signal i_mem_trnlen           : unsigned(15 downto 0);
signal i_mem_rqlen            : unsigned(15 downto 0);
signal i_mem_start            : std_logic;
signal i_mem_dir              : std_logic;
signal i_mem_done             : std_logic;

signal i_vch_prm              : TFG_VCHPrm;
signal i_vch_num              : unsigned(p_in_hrd_chsel'range);
signal i_vfr_row_cnt          : unsigned(G_MEM_VLINE_M_BIT - G_MEM_VLINE_L_BIT downto 0);
signal i_vfr_done             : std_logic;
signal i_vfr_new              : unsigned(G_VCH_COUNT - 1 downto 0) := (others => '1');
signal i_vfr_buf              : unsigned(G_MEM_VFR_M_BIT - G_MEM_VFR_L_BIT downto 0);

signal i_vfr_cur              : std_logic;
signal i_vfr_row_cnt_cur      : unsigned(i_vfr_row_cnt'range);
Type TVCH_row_cnt is array (0 to G_VCH_COUNT - 1) of unsigned(i_vfr_row_cnt'range);
signal sv_vfr_row_cnt         : TVCH_row_cnt;
signal i_steprd_count         : unsigned(15 downto 0);
signal i_steprd_cnt           : unsigned(15 downto 0);

signal i_data_null            : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);

signal tst_mem_wr_out         : std_logic_vector(31 downto 0);
signal tst_fsm_fgrd           : unsigned(3 downto 0) := (others => '0');


begin --architecture behavioral


i_data_null <= (others => '0');

p_out_vchnum <= std_logic_vector(i_vch_num);
p_out_pixcount <= std_logic_vector(i_vch_prm.fr.act.pixcount);
p_out_linecount <= std_logic_vector(i_vch_prm.fr.act.rowcount);
p_out_mirx <= i_vch_prm.mirror.pix;
p_out_fr_rddone <= i_vfr_done;


------------------------------------------------
--FSM
------------------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst = '1' then

    i_fsm_fgrd <= S_IDLE;

    i_mem_adr <= (others => '0');
    i_mem_rqlen <= (others => '0');
    i_mem_dir <= C_MEMWR_READ;
    i_mem_start <= '0';

    i_vfr_buf <= (others => '0');
    i_vfr_row_cnt <= (others => '0');

    i_vch_num <= (others => '0');
    i_vfr_done <= '0';
    i_vfr_new <= (others => '1');

    for ch in 0 to G_VCH_COUNT - 1 loop
    sv_vfr_row_cnt(ch) <= (others => '0');
    end loop;
    i_steprd_count <= (others => '0');
    i_steprd_cnt <= (others => '0');
    i_vfr_cur <= '0';
    i_vfr_row_cnt_cur <= (others => '0');

    i_vch_prm.fr.skp.pixcount <= (others => '0');
    i_vch_prm.fr.skp.rowcount <= (others => '0');
    i_vch_prm.fr.act.pixcount <= (others => '0');
    i_vch_prm.fr.act.rowcount <= (others => '0');
    i_vch_prm.mirror.pix <= '0';
    i_vch_prm.mirror.row <= '0';
    i_vch_prm.steprd <= (others => '0');

  else

    case i_fsm_fgrd is

      --------------------------------------
      --
      --------------------------------------
      when S_IDLE =>

        i_vfr_done <= '0';
        i_steprd_cnt <= (others => '0');

        if (p_in_hrd_start = '1') then

          i_vch_num <= UNSIGNED(p_in_hrd_chsel);

          for ch in 0 to G_VCH_COUNT - 1 loop
            if (UNSIGNED(p_in_hrd_chsel) = ch) then
              i_vch_prm <= p_in_usrprm(ch);
              i_vfr_buf <= p_in_frbuf(ch);

              if (i_vfr_new(ch) = '1') then
                i_vfr_new(ch) <= '0';
              end if;

              i_vfr_cur <= i_vfr_new(ch);
              i_vfr_row_cnt_cur <= sv_vfr_row_cnt(ch);
            end if;
          end loop;

          i_fsm_fgrd <= S_SET_PRMS;

        end if;

      --------------------------------------
      --
      --------------------------------------
      when S_SET_PRMS =>

        --Set step read line of frame
        if (i_vch_prm.steprd = (i_vch_prm.steprd'range => '0')) then
        i_steprd_count <= i_vch_prm.fr.act.rowcount;
        else
        i_steprd_count <= i_vch_prm.steprd;
        end if;

        --Set counter read line of frame
        if (i_vfr_cur = '1') then

            if (i_vch_prm.mirror.row = '0') then
              i_vfr_row_cnt <= (others => '0');
            else
              i_vfr_row_cnt <= i_vch_prm.fr.act.rowcount(i_vfr_row_cnt'range) - 1;
            end if;

        else

          i_vfr_row_cnt <= i_vfr_row_cnt_cur;

        end if;

        i_fsm_fgrd <= S_MEM_SET_ADR;

      --------------------------------------
      --
      --------------------------------------
      when S_MEM_SET_ADR =>

        i_mem_adr(G_MEM_VCH_M_BIT downto G_MEM_VCH_L_BIT) <= i_vch_num(G_MEM_VCH_M_BIT - G_MEM_VCH_L_BIT
                                                                                                  downto 0);
        i_mem_adr(G_MEM_VFR_M_BIT downto G_MEM_VFR_L_BIT) <= i_vfr_buf;
        i_mem_adr(G_MEM_VLINE_M_BIT downto G_MEM_VLINE_L_BIT) <= i_vch_prm.fr.skp.rowcount(i_vfr_row_cnt'range)
                                                                                                    + i_vfr_row_cnt;
        i_mem_adr(G_MEM_VLINE_L_BIT - 1 downto 0) <= i_vch_prm.fr.skp.pixcount(G_MEM_VLINE_L_BIT - 1 downto 0);

        i_fsm_fgrd <= S_MEM_START;

      --------------------------------------
      --
      --------------------------------------
      when S_MEM_START =>

--        i_mem_adr <= i_vch_prm.mem_base + i_mem_adr;

        i_mem_rqlen <= RESIZE(i_vch_prm.fr.act.pixcount(i_vch_prm.fr.act.pixcount'high downto log2(G_MEM_DWIDTH / 8))
                                                                                                   , i_mem_rqlen'length)
                         + (TO_UNSIGNED(0, i_mem_rqlen'length - 2)
                            & OR_reduce(i_vch_prm.fr.act.pixcount(log2(G_MEM_DWIDTH / 8) - 1 downto 0)));

        i_mem_dir <= C_MEMWR_READ;
        i_mem_start <= '1';
        i_fsm_fgrd <= S_MEM_RD;

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_MEM_RD =>

        i_mem_start <= '0';

        if (i_mem_done = '1') then
          i_fsm_fgrd <= S_ROW_NXT;
        end if;

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_ROW_NXT =>

        if (p_in_frline_nxt = '1') then

          if (i_vch_prm.mirror.row = '0' and i_vfr_row_cnt = (i_vch_prm.fr.act.rowcount(i_vfr_row_cnt'range) - 1)) or
             (i_vch_prm.mirror.row = '1' and i_vfr_row_cnt = (i_vfr_row_cnt'range => '0')) then

              for ch in 0 to G_VCH_COUNT - 1 loop
                if (i_vch_num = ch) then
                  i_vfr_new(ch) <= '1';
                end if;
              end loop;

              i_fsm_fgrd <= S_WAIT_HOST_ACK;

          else

              if (i_steprd_cnt = i_steprd_count - 1) then

                  for ch in 0 to G_VCH_COUNT - 1 loop
                    if (i_vch_num = ch) then
                      if (i_vch_prm.mirror.row = '1') then
                        sv_vfr_row_cnt(ch) <= i_vfr_row_cnt - 1;
                      else
                        sv_vfr_row_cnt(ch) <= i_vfr_row_cnt + 1;
                      end if;
                    end if;
                  end loop;

                  i_fsm_fgrd <= S_IDLE;

              else
                  if (i_vch_prm.mirror.row = '1') then
                    i_vfr_row_cnt <= i_vfr_row_cnt - 1;
                  else
                    i_vfr_row_cnt <= i_vfr_row_cnt + 1;
                  end if;

                  i_steprd_cnt <= i_steprd_cnt + 1;

                  i_fsm_fgrd <= S_MEM_SET_ADR;
              end if;

          end if;
        end if;

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_WAIT_HOST_ACK =>

        if (p_in_hrd_done = '1') then
          i_vfr_done <= '1';
          i_fsm_fgrd <= S_IDLE;
        end if;

    end case;
  end if;
end if;
end process;


--------------------------------------------------------
--
--------------------------------------------------------
i_mem_trnlen <= RESIZE(UNSIGNED(p_in_memtrn), i_mem_trnlen'length);

m_mem_wr : mem_wr
generic map(
--G_USR_OPT => G_USR_OPT,
G_MEM_AWIDTH => G_MEM_AWIDTH,
G_MEM_DWIDTH => G_MEM_DWIDTH
)
port map
(
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
--USR Port
-------------------------------
p_in_usr_txbuf_dout  => i_data_null,
p_out_usr_txbuf_rd   => open,
p_in_usr_txbuf_empty => '0',

p_out_usr_rxbuf_din  => p_out_upp_data,
p_out_usr_rxbuf_wd   => p_out_upp_data_wd,
p_in_usr_rxbuf_full  => p_in_upp_buf_full,

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
--p_out_tst(5 downto 0) <= tst_mem_wr_out(5 downto 0);
--p_out_tst(7 downto 6) <= (others => '0');
--p_out_tst(11 downto 8) <= std_logic_vector(tst_fsm_fgrd(3 downto 0));
--p_out_tst(31 downto 12) <= (others => '0');

p_out_tst(3 downto 0) <= std_logic_vector(tst_fsm_fgrd);
p_out_tst(6 downto 4) <= std_logic_vector(i_vch_num);
p_out_tst(7) <= p_in_hrd_start;

p_out_tst(23 downto 8)  <= std_logic_vector(i_vch_prm.fr.act.pixcount);
p_out_tst(39 downto 24) <= std_logic_vector(i_vch_prm.fr.act.rowcount);
p_out_tst(55 downto 40) <= std_logic_vector(i_vch_prm.steprd);
p_out_tst(71 downto 56) <= std_logic_vector(i_vch_prm.fr.skp.pixcount);
p_out_tst(87 downto 72) <= std_logic_vector(i_vch_prm.fr.skp.rowcount);
p_out_tst(88) <= i_vch_prm.mirror.pix;
p_out_tst(89) <= i_vch_prm.mirror.row;
p_out_tst(105 downto 90) <= std_logic_vector(RESIZE(i_vfr_row_cnt, 16));
p_out_tst(106) <= p_in_hrd_done;


tst_fsm_fgrd <= TO_UNSIGNED(16#01#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_SET_PRMS       else
                TO_UNSIGNED(16#02#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_MEM_SET_ADR    else
                TO_UNSIGNED(16#03#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_MEM_START      else
                TO_UNSIGNED(16#04#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_MEM_RD         else
                TO_UNSIGNED(16#05#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_ROW_NXT        else
                TO_UNSIGNED(16#06#,tst_fsm_fgrd'length) when i_fsm_fgrd = S_WAIT_HOST_ACK  else
                TO_UNSIGNED(16#00#,tst_fsm_fgrd'length); --i_fsm_fgrd = S_IDLE              else

end architecture behavioral;
