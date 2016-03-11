-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 11.01.2016 13:17:39
-- Module Name : pktvd_create
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;

entity pktvd_create is
generic(
G_BUFI_DWIDTH : natural := 64;
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTECOUNT : natural := 16;
G_PKT_PIXCHUNK_BYTECOUNT : natural := 1024;
G_CL_TAP : natural := 8  --Amount pixel per 1 clk
);
port(
----------------------------
--Ctrl
----------------------------
p_in_det_frprm     : in std_logic;
p_in_det_pixcount  : in std_logic_vector(15 downto 0);--pixcount(byte)
p_in_det_linecount : in std_logic_vector(15 downto 0);
p_in_time          : in std_logic_vector(31 downto 0);

----------------------------
--VBUF (source of video data)
----------------------------
p_out_bufi_rd   : out  std_logic;
p_in_bufi_do    : in   std_logic_vector(G_BUFI_DWIDTH - 1 downto 0);
p_in_bufi_empty : in   std_logic;
p_in_vsync      : in   std_logic;
p_in_hsync      : in   std_logic;

----------------------------
--VideoPacket output
----------------------------
p_out_pkt_do   : out  std_logic_vector(G_BUFI_DWIDTH - 1 downto 0);
p_out_pkt_wr   : out  std_logic;
p_in_pkt_wrclk : in   std_logic;

----------------------------
--DBG
----------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

----------------------------
--SYS
----------------------------
p_in_rst : in std_logic
);
end entity pktvd_create;

architecture behavioral of pktvd_create is


type TFsm_vpkt is (
S_IDLE       ,
S_WAIT_VSYNC ,
S_WAIT_HSYNC ,
S_REMAIN_CALC,
S_PKT_HWR0   ,
S_PKT_HWR1   ,
S_PKT_DWR
);
signal i_fsm_vpkt        : TFsm_vpkt;

signal i_rdy             : std_logic;
signal i_time            : unsigned(31 downto 0);

signal i_fr_pixcount: unsigned(15 downto 0);
signal i_fr_linecount    : unsigned(15 downto 0);
signal i_fr_cnt          : unsigned(3 downto 0);

signal i_remain_pixcount : unsigned(15 downto 0);
signal i_tx_pixcount     : unsigned(15 downto 0);
signal i_pkt_pixcnt      : unsigned(15 downto 0);

signal i_line_cnt        : unsigned(15 downto 0);

signal i_pkt_d           : unsigned(63 downto 0);
signal i_pkt_wr          : std_logic;
signal i_pkt_den         : std_logic;

signal i_padding         : std_logic;
signal i_vsync           : std_logic;
signal i_hsync           : std_logic;

signal i_err             : std_logic;
signal tst_cnt           : unsigned(7 downto 0);

signal tst_fsm_vpkt      : unsigned(2 downto 0);


begin --architecture behavioral


process(p_in_pkt_wrclk)
begin
if rising_edge(p_in_pkt_wrclk) then
i_rdy <= p_in_det_frprm;
i_time <= UNSIGNED(p_in_time);
i_vsync <= p_in_vsync;
i_hsync <= p_in_hsync;
end if;
end process;

p_out_bufi_rd <= i_pkt_den and (not p_in_bufi_empty);

p_out_pkt_do <= std_logic_vector(i_pkt_d);
p_out_pkt_wr <= i_pkt_wr;


process(p_in_pkt_wrclk)
variable pkt_pixcount : unsigned(15 downto 0);
begin
if rising_edge(p_in_pkt_wrclk) then
if (p_in_rst = '1') then
  i_fsm_vpkt <= S_IDLE;

  i_fr_pixcount <= (others => '0');
  i_fr_linecount <= (others => '0');
  i_fr_cnt <= (others => '0');

  i_remain_pixcount <= (others => '0');
  i_tx_pixcount <= (others => '0');
    pkt_pixcount := (others => '0');
  i_pkt_pixcnt <= (others => '0');

  i_line_cnt <= (others => '0');

  i_pkt_d <= (others => '0');
  i_pkt_wr <= '0';
  i_pkt_den <= '0';

  i_padding <= '0';

  i_err <= '0'; tst_cnt <= (others => '0');

else
  case i_fsm_vpkt is

  when S_IDLE =>

    i_remain_pixcount <= (others => '0');
    i_tx_pixcount <= (others => '0');
      pkt_pixcount := (others => '0');
    i_pkt_pixcnt <= (others => '0');
    i_line_cnt <= (others => '0');
    i_padding <= '0';
    i_pkt_wr <= '0';
    i_err <= '0';

    if (i_rdy = '1') then
      i_fsm_vpkt <= S_WAIT_VSYNC;
    end if;

  when S_WAIT_VSYNC =>

    i_padding <= '0';
    i_pkt_wr <= '0';

    if (i_rdy = '1') then
      if (p_in_vsync = '0') then
        i_fr_pixcount <= UNSIGNED(p_in_det_pixcount);
        i_fr_linecount <= UNSIGNED(p_in_det_linecount);

        if (p_in_bufi_empty = '0') then
        i_err <= '1';
        end if;

        i_fsm_vpkt <= S_REMAIN_CALC;
      end if;

    else
      i_fsm_vpkt <= S_IDLE;
    end if;

  when S_WAIT_HSYNC =>

    i_pkt_wr <= '0'; tst_cnt <= (others => '0');

    if (i_rdy = '1') then
      if (p_in_hsync = '0') then

        if (p_in_bufi_empty = '0') then
        i_err <= '1';
        end if;

        i_fsm_vpkt <= S_REMAIN_CALC;
      end if;
    else
      i_fsm_vpkt <= S_IDLE;
    end if;

  when S_REMAIN_CALC =>

    i_pkt_wr <= '0';

    if (i_rdy = '1') then
      i_remain_pixcount <= i_fr_pixcount - i_tx_pixcount;
      i_fsm_vpkt <= S_PKT_HWR0;
    else
      i_fsm_vpkt <= S_IDLE;
    end if;

  --###########################
  --PKT HEADER
  --###########################
  when S_PKT_HWR0 =>

    if (i_rdy = '0') then
      i_padding <= '1';
      i_fsm_vpkt <= S_IDLE;

    elsif (p_in_bufi_empty = '0' and p_in_hsync = '1') then

      if (i_remain_pixcount > TO_UNSIGNED(G_PKT_PIXCHUNK_BYTECOUNT, i_remain_pixcount'length)) then
        pkt_pixcount := TO_UNSIGNED(G_PKT_PIXCHUNK_BYTECOUNT, pkt_pixcount'length);
      else
        pkt_pixcount := i_remain_pixcount;
      end if;

      --(G_PKT_HEADER_BYTECOUNT - 2) becouse pkt_length set without size of field length(field length = 2byte)
      i_pkt_d((32 * 0) + 15 downto (32 * 0) +  0) <= pkt_pixcount + TO_UNSIGNED(G_PKT_HEADER_BYTECOUNT - 2, pkt_pixcount'length);
      i_pkt_d((32 * 0) + 19 downto (32 * 0) + 16) <= (TO_UNSIGNED(G_PKT_TYPE, 4));
      i_pkt_d((32 * 0) + 23 downto (32 * 0) + 20) <= (TO_UNSIGNED(G_VCH_NUM, 4));
      i_pkt_d((32 * 0) + 27 downto (32 * 0) + 24) <= i_fr_cnt;
      i_pkt_d((32 * 0) + 31 downto (32 * 0) + 28) <= (others => '0');--Reserv

      --frame resolution
      i_pkt_d((32 * 1) + 15 downto (32 * 1) +  0) <= i_fr_pixcount;
      i_pkt_d((32 * 1) + 31 downto (32 * 1) + 16) <= i_fr_linecount;

      i_pkt_wr <= '1';

      i_fsm_vpkt <= S_PKT_HWR1;

    end if;

  when S_PKT_HWR1 =>

    if (i_rdy = '0') then
      i_padding <= '1';
    end if;

    --current position of line & pixel  +  timestamp
    i_pkt_d((32 * 0) + 15 downto (32 * 0) +  0) <= i_tx_pixcount(15 downto 0);
    i_pkt_d((32 * 0) + 31 downto (32 * 0) + 16) <= i_line_cnt;
    i_pkt_d((32 * 1) + 15 downto (32 * 1) +  0) <= i_time((16 * 1) - 1 downto (16 * 0));
    i_pkt_d((32 * 1) + 31 downto (32 * 1) + 16) <= i_time((16 * 2) - 1 downto (16 * 1));
    i_pkt_wr <= '1';
    i_pkt_den <= '1';

    i_fsm_vpkt <= S_PKT_DWR;


  --###########################
  --PKT DATA
  --###########################
  when S_PKT_DWR =>

    if (i_rdy = '0') then
      i_padding <= '1';
    end if;

    if (p_in_bufi_empty = '0' or i_padding = '1') then

      if (p_in_tst(0) = '0') then
      i_pkt_d((32 * 2) - 1 downto (32 * 0)) <= UNSIGNED(p_in_bufi_do);

      else
        for i in 0 to (G_BUFI_DWIDTH / 8) - 1 loop
        i_pkt_d((8 * (i + 1)) - 1 downto (8 * i)) <= tst_cnt + i;
        end loop;
        tst_cnt <= tst_cnt + (G_BUFI_DWIDTH / 8);

      end if;

      i_pkt_wr <= '1';

      if (i_pkt_pixcnt >= (pkt_pixcount - TO_UNSIGNED((G_BUFI_DWIDTH / 8), i_pkt_pixcnt'length))) then
        i_pkt_pixcnt <= (others => '0');
        i_pkt_den <= '0';

        if (i_padding = '1') then
          i_fsm_vpkt <= S_IDLE;

        elsif ((i_tx_pixcount + pkt_pixcount) >= i_fr_pixcount) then
          i_tx_pixcount <= (others => '0');

          if (i_line_cnt = (i_fr_linecount - 1)) then
            i_line_cnt <= (others => '0');
            i_fr_cnt <= i_fr_cnt + 1;
            i_fsm_vpkt <= S_WAIT_VSYNC;
          else
            i_line_cnt <= i_line_cnt + 1;
            i_fsm_vpkt <= S_WAIT_HSYNC;
          end if;

        else
          i_tx_pixcount <= i_tx_pixcount + pkt_pixcount;
          i_fsm_vpkt <= S_REMAIN_CALC;
        end if;

      else
        i_pkt_pixcnt <= i_pkt_pixcnt + TO_UNSIGNED((G_BUFI_DWIDTH / 8), i_pkt_pixcnt'length);
      end if;

    else
      i_pkt_wr <= '0';
    end if;

  end case;
end if;
end if;
end process;


--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_err;
p_out_tst(1) <= i_rdy;
p_out_tst(2) <= i_padding;
p_out_tst(5 downto 3) <= std_logic_vector(tst_fsm_vpkt);


tst_fsm_vpkt <= TO_UNSIGNED(16#01#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_WAIT_VSYNC  else
                TO_UNSIGNED(16#02#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_WAIT_HSYNC  else
                TO_UNSIGNED(16#03#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_REMAIN_CALC else
                TO_UNSIGNED(16#04#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_PKT_HWR0    else
                TO_UNSIGNED(16#05#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_PKT_HWR1    else
                TO_UNSIGNED(16#06#, tst_fsm_vpkt'length) when i_fsm_vpkt = S_PKT_DWR     else
                TO_UNSIGNED(16#00#, tst_fsm_vpkt'length); --i_fsm_fgwr = S_IDLE      else


end architecture behavioral;
