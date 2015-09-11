-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 23.07.2015 11:20:31
-- Module Name : pcie_rx_rc.vhd
--
-- Description : Requestor Completion
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_rx_rc is
generic (
G_DATA_WIDTH : integer := 64
);
port(
-- Requester Completion Interface
p_in_axi_rc_tdata   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_axi_rc_tlast   : in  std_logic;
p_in_axi_rc_tvalid  : in  std_logic;
p_in_axi_rc_tkeep   : in  std_logic_vector((G_DATA_WIDTH / 32) - 1 downto 0);
p_in_axi_rc_tuser   : in  std_logic_vector(74 downto 0);
p_out_axi_rc_tready : out std_logic;

--Completion
p_in_dma_init      : in  std_logic;
p_in_dma_prm       : in  TPCIE_dmaprm;
p_in_dma_mrd_en    : in  std_logic;
p_out_dma_mrd_done : out std_logic;
p_out_dma_mrd_rxdwcount : out std_logic_vector(31 downto 0);

--usr app
--p_out_utxbuf_be   : out  std_logic_vector((G_DATA_WIDTH / 32) - 1 downto 0);
p_out_utxbuf_di   : out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_utxbuf_wr   : out  std_logic;
p_out_utxbuf_last : out  std_logic;
p_in_utxbuf_full  : in   std_logic;

--DBG
p_out_tst : out std_logic_vector(31 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_rx_rc;

architecture behavioral of pcie_rx_rc is

type TFsmRx_state is (
S_RXRC_IDLE,
S_RXRC_DH,
S_RXRC_DH1,
S_RXRC_DN,
S_RXRC_DE
);
signal i_fsm_rxrc         : TFsmRx_state;

signal i_sof              : std_logic_vector(1 downto 0);

signal i_dma_init         : std_logic;
signal i_dma_dw_cnt       : unsigned(31 downto 0);
signal i_dma_dw_len       : unsigned(31 downto 0);

signal i_mrd_done         : std_logic;

signal i_cpld_tlp_work    : std_logic;
signal i_cpld_dw_cnt      : unsigned(31 downto 0);
signal i_cpld_byte_t      : unsigned(12 downto 0);
signal i_cpld_byte        : unsigned(12 downto 0);
signal i_cpld_dw          : unsigned(10 downto 0);
signal i_cpld_dw_t        : unsigned(10 downto 0);
signal i_cpld_dw_rem      : unsigned(10 downto 0);
signal i_cpld_len         : unsigned(10 downto 0);

signal i_axi_rc_tready    : std_logic;

type TByteEn is array (0 to (G_DATA_WIDTH / 8) - 1) of std_logic_vector(3 downto 0);
signal sr_axi_be          : TByteEn;
type TData is array (0 to (G_DATA_WIDTH / 32) - 1) of std_logic_vector(31 downto 0);
signal sr_axi_data        : TData;
signal i_axi_data         : TData;
signal i_utxbuf_di        : TData;

signal tst_err            : std_logic_vector(1 downto 0);
signal tst_fsm_rx         : std_logic;


begin --architecture behavioral of pcie_rx_rc

--gen : for i in 0 to (G_DATA_WIDTH / 32) - 1 generate begin
--i_axi_data_be(i) <= p_in_axi_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--end generate;

gen : for i in 0 to (G_DATA_WIDTH / 32) - 1 generate begin
i_axi_data(i) <= p_in_axi_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
end generate;

i_utxbuf_di(0) <= sr_axi_data(1);
i_utxbuf_di(1) <= i_axi_data(0);

gen_utxbuf : for i in 0 to i_utxbuf_di'length - 1 generate begin
p_out_utxbuf_di((32 * (i + 1)) - 1 downto (32 * i)) <= i_utxbuf_di(i);
end generate gen_utxbuf;

--p_out_utxbuf_be <=
p_out_utxbuf_wr   <= i_cpld_tlp_work and not p_in_utxbuf_full;
p_out_utxbuf_last <= '0';--: out  std_logic;

p_out_dma_mrd_done <= i_mrd_done;

p_out_dma_mrd_rxdwcount <= std_logic_vector(i_dma_dw_cnt);

p_out_axi_rc_tready <= i_axi_rc_tready and not p_in_utxbuf_full;

--i_axi_rc_tready <= not p_in_utxbuf_full;


i_sof(0) <= p_in_axi_rc_tuser(32);
i_sof(1) <= p_in_axi_rc_tuser(33);
--i_eof_0 <= p_in_axi_rc_tuser(37 downto 34);
--i_eof_1 <= p_in_axi_rc_tuser(41 downto 38);

--i_disc <= p_in_axi_rc_tuser(42);


--DMA initialization
init : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if (p_in_rst_n = '0') then
    i_dma_init <= '0';

  else
    if (p_in_dma_init = '1') then
        i_dma_init <= '1';
    else
        if (i_fsm_rxrc = S_RXRC_DH) then
          i_dma_init <= '0';
        end if;
    end if;
  end if;
end if;
end process;--init


i_cpld_byte_t <= UNSIGNED(i_axi_data(0)(28 downto 16)); --CPLD Byte Count
i_cpld_dw_t <= UNSIGNED(i_axi_data(1)(10 downto 0)); --CPLD Length data payload (DW)
i_cpld_len <= RESIZE(i_cpld_dw_t(10 downto log2(G_DATA_WIDTH / 32)), i_cpld_len'length)
            + (TO_UNSIGNED(0, i_cpld_len'length - 2)
                & OR_reduce(i_cpld_dw_t(log2(G_DATA_WIDTH / 32) - 1 downto 0)));

--Rx State Machine
fsm : process(p_in_clk)
variable err_out : std_logic_vector(tst_err'range);
begin
if rising_edge(p_in_clk) then
  if (p_in_rst_n = '0') then

    i_fsm_rxrc <= S_RXRC_IDLE;

    for i in 0 to sr_axi_data'length - 1 loop
    sr_axi_data(i) <= (others => '0');
    end loop;
    for i in 0 to sr_axi_be'length - 1 loop
    sr_axi_be(i) <= (others => '0');
    end loop;

    i_axi_rc_tready <= '0';

    i_cpld_tlp_work <= '0';

    i_cpld_byte <= (others => '0');

    i_cpld_dw_cnt <= (others => '0');
    i_cpld_dw <= (others => '0');
    i_cpld_dw_rem <= (others => '0');

    i_dma_dw_cnt <= (others => '0');
    i_dma_dw_len <= (others => '0');

    i_mrd_done <= '0';

    tst_err <= (others => '0'); err_out := (others => '0');

  else

    case i_fsm_rxrc is

        when S_RXRC_IDLE =>

            i_cpld_tlp_work <= '0';

            if (p_in_dma_mrd_en = '1' and i_mrd_done = '0' and p_in_utxbuf_full = '0') then

              if (i_dma_init = '1') then

              i_dma_dw_cnt <= (others => '0');
              i_dma_dw_len <= RESIZE(UNSIGNED(p_in_dma_prm.len(p_in_dma_prm.len'high downto log2(32 / 8))), i_cpld_dw_cnt'length)
                              + (TO_UNSIGNED(0, i_cpld_dw_cnt'length - 2)
                                  & OR_reduce(p_in_dma_prm.len(log2(32 / 8) - 1 downto 0)));

              end if;

              i_axi_rc_tready <= '1';
              i_fsm_rxrc <= S_RXRC_DH;

            else
              if (i_dma_init = '1') then
                i_mrd_done <= '0';
              end if;
            end if;

        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RXRC_DH =>

            err_out := (others => '0');

            if (i_sof(0) = '1' and i_sof(1) = '0' and p_in_dma_mrd_en = '1'
                and p_in_axi_rc_tvalid = '1' and p_in_utxbuf_full = '0') then

                if (p_in_axi_rc_tkeep(1 downto 0) = "11") then

                      --Check Completion Status
                      if (i_axi_data(1)(13 downto 11) = C_PCIE_COMPL_STATUS_SC) then

                          i_cpld_byte <= i_cpld_byte_t;
                          i_cpld_dw <= i_cpld_dw_t;

                          i_fsm_rxrc <= S_RXRC_DH1;

                      else
                        ----Check Error Code
                        --if pkt.h(1)(15 downto 12) = ""
                        --end if;
                        err_out(1) := '1';
                      end if;

                else
                  err_out(0) := '1';

                end if;

            end if;

        when S_RXRC_DH1 =>

            err_out := (others => '0');

            if (p_in_axi_rc_tvalid = '1' and p_in_utxbuf_full = '0') then

                if (p_in_axi_rc_tkeep(1 downto 0) = "11") then

                      for i in 1 to sr_axi_data'length - 1 loop
                      sr_axi_data(i) <= i_axi_data(i); --user data
                      sr_axi_be(i) <= p_in_axi_rc_tuser((i * 4) + 3 downto (i * 4)); --(15...12)
                      end loop;

                      --Check Completion Status
                      i_cpld_tlp_work <= '1';

                      --Check DW Count
                      if (i_cpld_dw > TO_UNSIGNED(1, i_cpld_dw_t'length)) then

                          i_cpld_dw_rem <= (i_cpld_len(i_cpld_len'high - (log2(G_DATA_WIDTH / 32)) downto 0)
                                            & TO_UNSIGNED(0, (log2(G_DATA_WIDTH / 32))))  - i_cpld_dw_t;

                          i_fsm_rxrc <= S_RXRC_DN;

                      else

                          if (p_in_axi_rc_tlast = '1') then

                              if ((i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length)) = i_dma_dw_len) then
                                i_mrd_done <= '1';
                              else
                                i_mrd_done <= '0';
                              end if;

                              i_dma_dw_cnt <= i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length);

                              i_axi_rc_tready <= '0';
                              i_fsm_rxrc <= S_RXRC_IDLE;
                          end if;

                      end if;

                else
                  err_out(0) := '1';

                end if;

            end if;

        --#######################################################################
        --
        --#######################################################################
        when S_RXRC_DN =>

            if (p_in_axi_rc_tvalid = '1' and p_in_utxbuf_full = '0') then

                for i in 0 to i_axi_data'length - 1 loop
                sr_axi_data(i) <= i_axi_data(i); --user data
                sr_axi_be(i) <= p_in_axi_rc_tuser((i * 4) + 3 downto (i * 4));
                end loop;

                if (p_in_axi_rc_tlast = '1') then

                    if (i_cpld_dw_rem(3 downto 0) = TO_UNSIGNED(0, 4)) then

                        i_cpld_tlp_work <= '0';

                        if ((i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length)) = i_dma_dw_len) then
                          i_mrd_done <= '1';
                        else
                          i_mrd_done <= '0';
                        end if;

                        i_dma_dw_cnt <= i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length);

                        i_fsm_rxrc <= S_RXRC_IDLE;

                    else

                      i_axi_rc_tready <= '0';
                      i_fsm_rxrc <= S_RXRC_DE;

                    end if;

                end if;

            end if;


        when S_RXRC_DE =>

            if (p_in_utxbuf_full = '0') then

                i_cpld_tlp_work <= '0';
                i_axi_rc_tready <= '0';

                if ((i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length)) = i_dma_dw_len) then
                  i_mrd_done <= '1';
                else
                  i_mrd_done <= '0';
                end if;

                i_dma_dw_cnt <= i_dma_dw_cnt + RESIZE(i_cpld_dw, i_cpld_dw_cnt'length);

                i_fsm_rxrc <= S_RXRC_IDLE;

            end if;

    end case; --case i_fsm_rxrc is


    tst_err <= err_out;
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm



--#######################################################################
--DBG
--#######################################################################
--tst_fsm_rx <= '1' when i_fsm_rxrc = S_RXRC_WAIT  else '0';

p_out_tst(0) <= '0';--tst_fsm_rx;
p_out_tst(3 downto 1) <= (others => '0');
p_out_tst(5 downto 4) <= tst_err;
p_out_tst(7 downto 6) <= (others => '0');
p_out_tst(31 downto 3) <= (others => '0');


end architecture behavioral;
