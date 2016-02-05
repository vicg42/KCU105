-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 2010.07
-- Module Name : vmirx_main
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.reduce_pack.all;

entity vmirx_main is
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
--p_in_upp_clk        : in    std_logic;
p_in_upp_data       : in    std_logic_vector(G_DWIDTH - 1 downto 0);
p_in_upp_wr         : in    std_logic;
p_out_upp_rdy_n     : out   std_logic;

----------------------------
--Downstream Port (OUT)
----------------------------
--p_in_dwnp_clk       : in    std_logic;
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
end entity vmirx_main;

architecture behavioral of vmirx_main is


component vmirx_bram
port(
addra: in  std_logic_vector(G_BRAM_AWIDTH - 1 downto 0);
dina : in  std_logic_vector(G_DWIDTH - 1 downto 0);
douta: out std_logic_vector(G_DWIDTH - 1 downto 0);
ena  : in  std_logic;
wea  : in  std_logic_vector(0 downto 0);
clka : in  std_logic;

addrb: in  std_logic_vector(G_BRAM_AWIDTH - 1 downto 0);
dinb : in  std_logic_vector(G_DWIDTH - 1 downto 0);
doutb: out std_logic_vector(G_DWIDTH - 1 downto 0);
enb  : in  std_logic;
web  : in  std_logic_vector(0 downto 0);
clkb : in  std_logic
);
end component vmirx_bram;

signal i_upp_data_swap   : std_logic_vector(G_DWIDTH - 1 downto 0);

type TFsm_state is (
S_BUF_WR,
S_BUF_RD_SOF,
S_BUF_RD,
S_BUF_RD_EOF
);
signal i_fsm_mir         : TFsm_state;

signal i_pix_count       : unsigned(p_in_cfg_pix_count'range);
signal i_mirx_done       : std_logic;

signal i_buf_adr         : unsigned(G_BRAM_AWIDTH - 1 downto 0);
signal i_buf_di          : std_logic_vector(G_DWIDTH - 1 downto 0);
signal i_buf_do          : std_logic_vector(G_DWIDTH - 1 downto 0);
signal i_buf_dir         : std_logic;
signal i_buf_ena         : std_logic;
signal i_buf_enb         : std_logic;
signal i_read_en         : std_logic;

signal i_gnd             : std_logic_vector(G_DWIDTH - 1 downto 0);

signal tst_fsm,tst_fsm_out : unsigned(1 downto 0);
signal tst_buf_enb     : std_logic;
signal tst_hbufo_pfull : std_logic;


begin --architecture behavioral of vmirx_main is

--assert ( not (CONV_STD_LOGIC_VECTOR((pwr(2, (p_in_cfg_pix_count'length / (G_DWIDTH / 8))) - 1), p_in_cfg_pix_count'length)) >
--         CONV_STD_LOGIC_VECTOR((pwr(2, G_BRAM_AWIDTH) - 1), p_in_cfg_pix_count'length) )
--report "ERROR: BRAM Mirror DEPTH is small"
--severity error;


i_gnd <= (others => '0');

------------------------------------------------
--
------------------------------------------------
p_out_upp_rdy_n <= i_buf_dir;


p_out_dwnp_data <= i_buf_do;
p_out_dwnp_wd <= not p_in_dwnp_rdy_n and i_buf_dir;


p_out_cfg_mirx_done <= i_mirx_done;

-------------------------------
--
-------------------------------
i_pix_count <= RESIZE(UNSIGNED(p_in_cfg_pix_count(p_in_cfg_pix_count'high downto log2(G_DWIDTH / 8)))
                                                                                   , i_pix_count'length)
                 + (TO_UNSIGNED(0, i_pix_count'length - 2)
                    & OR_reduce(p_in_cfg_pix_count(log2(G_DWIDTH / 8) - 1 downto 0)));

--------------------------------------
--FSM
--------------------------------------
process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst = '1') then

    i_fsm_mir <= S_BUF_WR;

    i_buf_dir <= '0';
    i_buf_adr <= (others => '0');
    i_mirx_done <= '1';
    i_read_en <= '0';

  else

    case i_fsm_mir is

      --------------------------------------
      --Write Line to buffer
      --------------------------------------
      when S_BUF_WR =>

        i_mirx_done <= '0';

        if (p_in_upp_wr = '1') then
          if (RESIZE(i_buf_adr, i_pix_count'length) = (i_pix_count - 1)) then

            if (p_in_cfg_mirx = '0') then
              i_buf_adr <= (others => '0');
            end if;
            i_read_en <= '1';

            i_fsm_mir <= S_BUF_RD_SOF;

          else

            i_buf_adr <= i_buf_adr + 1;

          end if;
        end if;

      --------------------------------------
      --
      --------------------------------------
      when S_BUF_RD_SOF =>

        i_buf_dir <= '1';

        if (p_in_cfg_mirx = '0') then
          i_buf_adr <= i_buf_adr + 1;
        else
          i_buf_adr <= i_buf_adr - 1;
        end if;

        i_fsm_mir <= S_BUF_RD;

      --------------------------------------
      --Read Line from buffer
      --------------------------------------
      when S_BUF_RD =>

        if (p_in_dwnp_rdy_n = '0') then

            if (p_in_cfg_mirx = '0' and RESIZE(i_buf_adr, i_pix_count'length) = (i_pix_count - 1)) or
               (p_in_cfg_mirx = '1' and i_buf_adr = (i_buf_adr'range => '0')) then

              i_fsm_mir <= S_BUF_RD_EOF;

            else

              if (p_in_cfg_mirx = '0') then
                i_buf_adr <= i_buf_adr + 1;
              else
                i_buf_adr <= i_buf_adr - 1;
              end if;

            end if;

        end if;

      --------------------------------------
      --
      --------------------------------------
      when S_BUF_RD_EOF =>

        if (p_in_dwnp_rdy_n = '0') then

          i_mirx_done <= '1';
          i_buf_dir <= '0';
          i_read_en <= '0';

          if (p_in_cfg_mirx = '0') then
            i_buf_adr <= (others => '0');
          end if;

          i_fsm_mir <= S_BUF_WR;
        end if;
    end case;

  end if;
end if;
end process;


--For mirror valid (1Pix = 8Bit)
gen_swap : for i in 0 to (p_in_upp_data'length / 8) - 1 generate
i_upp_data_swap((i_upp_data_swap'length - (8 * i)) - 1 downto
                (i_upp_data_swap'length - (8 * (i + 1)))) <= p_in_upp_data(8 * (i + 1) - 1 downto (8 * i));
end generate gen_swap;

--Write
i_buf_di <= i_upp_data_swap when p_in_cfg_mirx = '1' else p_in_upp_data;
i_buf_ena <= not i_buf_dir and p_in_upp_wr;

--Read
i_buf_enb <= (not p_in_dwnp_rdy_n or not i_buf_dir) and i_read_en;

m_bufline : vmirx_bram
port map(
addra => std_logic_vector(i_buf_adr),
dina  => i_buf_di,
douta => open,
ena   => i_buf_ena,
wea   => "1",
clka  => p_in_clk,

addrb => std_logic_vector(i_buf_adr),
dinb  => i_gnd,
doutb => i_buf_do,
enb   => i_buf_enb,
web   => "0",
clkb  => p_in_clk
);


------------------------------------
--DBG
------------------------------------
p_out_tst <= (others => '0');
--p_out_tst(0) <= OR_reduce(tst_fsm_out) or tst_buf_enb or tst_hbufo_pfull;
--p_out_tst(31 downto 1) <= (others => '0');
--
--process(p_in_clk)
--begin
--  if rising_edge(p_in_clk) then
--    tst_fsm_out <= tst_fsm;
--    tst_buf_enb <= i_buf_enb;
--    tst_hbufo_pfull <= p_in_dwnp_rdy_n;
--  end if;
--end process;
--
--tst_fsm <= TO_UNSIGNED(16#01#, tst_fsm'length) when i_fsm_mir = S_BUF_RD_SOF  else
--           TO_UNSIGNED(16#02#, tst_fsm'length) when i_fsm_mir = S_BUF_RD      else
--           TO_UNSIGNED(16#03#, tst_fsm'length) when i_fsm_mir = S_BUF_RD_EOF  else
--           TO_UNSIGNED(16#00#, tst_fsm'length); --i_fsm_mir = S_BUF_WR          else


end architecture behavioral;

