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
use work.fg_pkg.all;
use work.mem_wr_pkg.all;

entity fgrd is
generic(
G_USR_OPT : std_logic_vector(3 downto 0) := (others => '0');
G_DBGCS   : string := "OFF";

G_MEM_VCH_M_BIT   : integer := 25;
G_MEM_VCH_L_BIT   : integer := 24;
G_MEM_VFR_M_BIT   : integer := 23;
G_MEM_VFR_L_BIT   : integer := 23;
G_MEM_VLINE_M_BIT : integer := 22;
G_MEM_VLINE_L_BIT : integer := 0;

G_MEM_AWIDTH : integer := 32;
G_MEM_DWIDTH : integer := 32;

G_VCH_COUNT : integer := 1
);
port(
-------------------------------
--CFG
-------------------------------
p_in_usrprm          : in    TFGRD_Prms;
--p_in_work_en         : in    std_logic;

p_in_hrd_chsel       : in    std_logic_vector(2 downto 0);--Host: Channel number for read
p_in_hrd_start       : in    std_logic;                   --Host: Start read data
p_in_hrd_done        : in    std_logic;                   --Host: ACK read done

p_in_frbuf           : in    TFG_FrBufs;                  --number framebuffer(vbuf) for read
p_in_frline_n        : in    std_logic;                   --Enable read next line (acitve '0')

p_out_chnum          : out   std_logic_vector(2 downto 0);
p_out_pixcount       : out   std_logic_vector(15 downto 0);
p_out_linecount      : out   std_logic_vector(15 downto 0);
p_out_mirx           : out   std_logic;
p_out_sof            : out   std_logic;
p_out_eof            : out   std_logic;
p_out_fr_rddone      : out   std_logic;

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
p_out_tst            : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk             : in    std_logic;
p_in_rst             : in    std_logic
);
end entity fgrd;

architecture behavioral of fgrd is

--Small delay for simulation purposes.
constant dly : time := 1 ps;

type TFsm_state is (
S_IDLE,
S_MEM_START,
S_MEM_RD,
S_HOST_ACK
);
signal i_fsm_state_cs              : TFsm_state;

signal i_data_null                 : std_logic_vector(G_MEM_DWIDTH - 1 downto 0);

signal i_prm                       : TFGRD_Prm;

signal i_mem_adr_out               : unsigned(31 downto 0) := (others => '0');
signal i_mem_adr_t                 : unsigned(31 downto 0) := (others => '0');
signal i_mem_adr                   : unsigned(31 downto 0) := (others => '0');
signal i_mem_rqlen                 : unsigned(15 downto 0) := (others => '0');
signal i_mem_start                 : std_logic;
signal i_mem_dir                   : std_logic;
signal i_mem_done                  : std_logic;
signal i_frbuf                     : unsigned(G_MEM_VFR_M_BIT - G_MEM_VFR_L_BIT downto 0);
signal i_chnum                     : unsigned(p_in_hrd_chsel'range);
signal i_fr_rowcnt                 : unsigned(15 downto 0) := (others => '0');
signal i_fr_rowcnt_t               : unsigned(15 downto 0) := (others => '0');
signal i_sof                       : std_logic;
signal i_eof                       : std_logic;

signal i_host_ack                  : std_logic;

signal i_steprd_count              : unsigned(15 downto 0);
signal i_steprd_cnt                : unsigned(15 downto 0);
signal i_fr_new                    : std_logic_vector(G_VCH_COUNT - 1 downto 0);
signal i_fr_new_c                  : std_logic;
Type TFGRD_linecnt is array (0 to G_VCH_COUNT - 1) of unsigned(i_fr_rowcnt'range);
signal i_fr_rowcnt_save           : TFGRD_linecnt;
signal i_fr_rowcnt_save_c         : unsigned(i_fr_rowcnt'range);

signal tst_mem_wr_out              : std_logic_vector(31 downto 0);
signal tst_fsmstate,tst_fsm_cs_dly : unsigned(3 downto 0) := (others => '0');


begin --architecture behavioral


i_data_null <= (others => '0');

p_out_chnum <= std_logic_vector(i_chnum);
p_out_pixcount <= std_logic_vector(i_prm.frrd.act.pixcount);
p_out_linecount <= std_logic_vector(i_prm.frrd.act.rowcount);
p_out_mirx <= i_prm.mirror.x;
p_out_sof <= i_sof;
p_out_eof <= i_eof;
p_out_fr_rddone <= i_host_ack;


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

    i_prm.mem_trnlen <= std_logic_vector(TO_UNSIGNED(16#4040#, i_prm.mem_trnlen'length));
    i_prm.frwr.pixcount <= (others => '0');
    i_prm.frwr.rowcount <= (others => '0');

    i_prm.frrd.skp.pixcount <= (others => '0');
    i_prm.frrd.skp.rowcount <= (others => '0');
    i_prm.frrd.act.pixcount <= (others => '0');
    i_prm.frrd.act.rowcount <= (others => '0');

    i_prm.mirror.x <= '0';
    i_prm.mirror.y <= '0';

    i_sof <= '0'; i_eof <= '0';

    i_frbuf <= (others => '0');
    i_chnum <= (others => '0');

    i_host_ack <= '0';

  else

    case i_fsm_state_cs is

      --------------------------------------
      --
      --------------------------------------
      when S_IDLE =>

        i_host_ack <= '0';
        i_fr_rowcnt <= (others => '0');

        if p_in_hrd_start = '1' then

          i_chnum <= UNSIGNED(p_in_hrd_chsel);

          --Load param channel
          for ch in 0 to G_VCH_COUNT - 1 loop
            if UNSIGNED(p_in_hrd_chsel) = ch then
              i_prm <= p_in_usrprm(ch);
              i_frbuf <= p_in_frbuf(ch);
            end if;
          end loop;

          i_fsm_state_cs <= S_MEM_START;

        end if;


      --------------------------------------
      --
      --------------------------------------
      when S_MEM_START =>

        i_mem_adr <= i_prm.frrd.act.pixcount * i_fr_rowcnt;

        i_mem_rqlen <= RESIZE(i_prm.frrd.act.pixcount(i_prm.frrd.act.pixcount'high downto log2(G_MEM_DWIDTH / 8))
                                                                              , i_mem_rqlen'length)
                         + (TO_UNSIGNED(0, i_mem_rqlen'length - 2)
                            & OR_reduce(i_prm.frrd.act.pixcount(log2(G_MEM_DWIDTH / 8) - 1 downto 0)));

        i_mem_dir <= C_MEMWR_READ;
        i_mem_start <= '1';
        i_fsm_state_cs <= S_MEM_RD; i_eof <= '0';

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_MEM_RD =>

        i_mem_start <= '0';

        if i_mem_done = '1' then
          if i_fr_rowcnt = (i_prm.frrd.act.rowcount - 1) then

            i_fsm_state_cs <= S_HOST_ACK;

          else
              i_fr_rowcnt <= i_fr_rowcnt + 1; i_eof <= '1';
              i_fsm_state_cs <= S_MEM_START;
          end if;
        end if;

      ------------------------------------------------
      --
      ------------------------------------------------
      when S_HOST_ACK =>

        if p_in_hrd_done = '1' then
          i_host_ack <= '1';
          i_fsm_state_cs <= S_IDLE;
        end if;

    end case;

  end if;
end if;
end process;


--------------------------------------------------------
--
--------------------------------------------------------
i_mem_adr_out(i_mem_adr_out'high downto G_MEM_VCH_M_BIT + 1) <= (others => '0');
i_mem_adr_out(G_MEM_VCH_M_BIT downto G_MEM_VCH_L_BIT) <= i_chnum(G_MEM_VCH_M_BIT - G_MEM_VCH_L_BIT downto 0);
i_mem_adr_out(G_MEM_VFR_M_BIT downto G_MEM_VFR_L_BIT) <= i_frbuf;
i_mem_adr_out(G_MEM_VLINE_M_BIT downto 0) <= i_mem_adr(G_MEM_VLINE_M_BIT downto 0);

m_mem_wr : mem_wr
generic map(
--G_USR_OPT        => G_USR_OPT,
G_MEM_BANK_M_BIT => 31,
G_MEM_BANK_L_BIT => 30,
G_MEM_AWIDTH     => G_MEM_AWIDTH,
G_MEM_DWIDTH     => G_MEM_DWIDTH
)
port map
(
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
p_out_tst(5 downto 0) <= tst_mem_wr_out(5 downto 0);
p_out_tst(7 downto 6) <= (others => '0');
p_out_tst(10 downto 8) <= std_logic_vector(tst_fsm_cs_dly(2 downto 0));
p_out_tst(31 downto 11) <= (others => '0');


process(p_in_clk)
begin
  if rising_edge(p_in_clk) then
    tst_fsm_cs_dly <= tst_fsmstate;
  end if;
end process;
tst_fsmstate <= TO_UNSIGNED(16#01#,tst_fsmstate'length) when i_fsm_state_cs = S_MEM_START       else
                TO_UNSIGNED(16#02#,tst_fsmstate'length) when i_fsm_state_cs = S_MEM_RD          else
                TO_UNSIGNED(16#00#,tst_fsmstate'length); --i_fsm_state_cs = S_IDLE              else


end architecture behavioral;
