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
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_STRADDLE         : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1');

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; -- TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   -- TPARITY width
);
port(
-- Requester Completion Interface
p_in_m_axis_rc_tdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tlast    : in  std_logic;
p_in_m_axis_rc_tvalid   : in  std_logic;
p_in_m_axis_rc_tkeep    : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser    : in  std_logic_vector(74 downto 0);
p_out_m_axis_rc_tready  : out std_logic;

--Completion
p_in_dma_init      : in  std_logic;
p_in_dma_prm       : in  TPCIE_dmaprm;
p_in_dma_mrd_en    : in  std_logic;
p_out_dma_mrd_done : out std_logic;

--usr app
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
S_RX_IDLE,
S_RX_DH,
S_RX_DN,
S_RX_DE
);
signal i_fsm_rx              : TFsmRx_state;

signal i_sof                 : std_logic_vector(1 downto 0);

type TRxCPLH is array (0 to 1) of std_logic_vector(31 downto 0);
type TRxCPLD is record
h_rxdone : std_logic;
h : TRxCPLH;
end record;

signal i_dma_init            : std_logic;
signal i_mrd_done            : std_logic;

signal i_cpld_tlp_work       : std_logic;
signal i_cpld_byte_cnt       : unsigned(31 downto 0);
signal i_cpld_byte_t         : unsigned(12 downto 0);
signal i_cpld_byte           : unsigned(12 downto 0);
signal i_cpld_dw_t           : unsigned(10 downto 0);
signal i_cpld_dw             : unsigned(10 downto 0);
signal i_cpld_dw_rem         : unsigned(10 downto 0);
signal i_cpld_len            : unsigned(10 downto 0);
signal i_cpld_len_t          : unsigned(10 downto 0);
signal i_m_axis_rc_tready    : std_logic;

type TData is array (0 to 7) of std_logic_vector(31 downto 0);
signal sr_axi_data           : TData; --std_logic_vector(p_in_m_axis_rc_tdata'range);
signal i_axi_data            : TData; --std_logic_vector(p_in_m_axis_rc_tdata'range);
signal i_utxbuf_di           : TData; --std_logic_vector(p_in_m_axis_rc_tdata'range);

signal tst_err               : std_logic_vector(1 downto 0);
signal tst_fsm_rx            : std_logic;


begin --architecture behavioral of pcie_rx_rc


gen : for i in 0 to 7 generate begin
i_axi_data(i) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
end generate;


i_utxbuf_di(0) <= sr_axi_data(3);
i_utxbuf_di(1) <= sr_axi_data(4);
i_utxbuf_di(2) <= sr_axi_data(5);
i_utxbuf_di(3) <= sr_axi_data(6);
i_utxbuf_di(4) <= sr_axi_data(7);
i_utxbuf_di(5) <= i_axi_data(0);--p_in_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0));
i_utxbuf_di(6) <= i_axi_data(1);--p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
i_utxbuf_di(7) <= i_axi_data(2);--p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));

p_out_utxbuf_di((32 * 1) - 1 downto (32 * 0)) <= i_utxbuf_di(0);
p_out_utxbuf_di((32 * 2) - 1 downto (32 * 1)) <= i_utxbuf_di(1);
p_out_utxbuf_di((32 * 3) - 1 downto (32 * 2)) <= i_utxbuf_di(2);
p_out_utxbuf_di((32 * 4) - 1 downto (32 * 3)) <= i_utxbuf_di(3);
p_out_utxbuf_di((32 * 5) - 1 downto (32 * 4)) <= i_utxbuf_di(4);
p_out_utxbuf_di((32 * 6) - 1 downto (32 * 5)) <= i_utxbuf_di(5);
p_out_utxbuf_di((32 * 7) - 1 downto (32 * 6)) <= i_utxbuf_di(6);
p_out_utxbuf_di((32 * 8) - 1 downto (32 * 7)) <= i_utxbuf_di(7);

p_out_utxbuf_wr   <= i_cpld_tlp_work;--: out  std_logic;
p_out_utxbuf_last <= '0';--: out  std_logic;

p_out_dma_mrd_done <= i_mrd_done;

p_out_m_axis_rc_tready <= i_m_axis_rc_tready and not p_in_utxbuf_full;

--i_m_axis_rc_tready <= not p_in_utxbuf_full;


i_sof(0) <= p_in_m_axis_rc_tuser(32);
i_sof(1) <= p_in_m_axis_rc_tuser(33);
--i_eof_0 <= p_in_m_axis_rc_tuser(37 downto 34);
--i_eof_1 <= p_in_m_axis_rc_tuser(41 downto 38);

--i_disc <= p_in_m_axis_rc_tuser(42);


--DMA initialization
init : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then
    i_dma_init <= '0';

  else
    if p_in_dma_init = '1' then
        i_dma_init <= '1';
    else
        if (i_fsm_rx = S_RX_DH) then
          i_dma_init <= '0';
        end if;
    end if;
  end if;
end if;
end process;--init


i_cpld_byte_t <= UNSIGNED(i_axi_data(0)(28 downto 16)); --Byte Count
i_cpld_dw_t <= UNSIGNED(i_axi_data(1)(10 downto 0)); --Length data payload (DW)
i_cpld_len <= RESIZE(i_cpld_dw_t(10 downto log2(G_DATA_WIDTH / 32)), i_cpld_len'length)
            + (TO_UNSIGNED(0, i_cpld_len'length - 2)
                & OR_reduce(i_cpld_dw_t(log2(G_DATA_WIDTH / 32) - 1 downto 0)));

--Rx State Machine
fsm : process(p_in_clk)
variable err_out : std_logic_vector(tst_err'range);
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_rx <= S_RX_IDLE;

    for i in 0 to p_in_m_axis_rc_tkeep'length - 1 loop
    sr_axi_data(i) <= (others => '0');
    end loop;

    i_m_axis_rc_tready <= '0';

    i_cpld_tlp_work <= '0';
    i_cpld_byte_cnt <= (others => '0');
    i_cpld_byte <= (others => '0');
    i_cpld_dw_rem <= (others => '0');

    i_mrd_done <= '0';

    tst_err <= (others => '0'); err_out := (others => '0');

  else

    case i_fsm_rx is

        when S_RX_IDLE =>

            i_cpld_tlp_work <= '0';

            if p_in_dma_mrd_en = '1' and p_in_utxbuf_full = '0' then

              if i_dma_init = '1' then
              i_cpld_byte_cnt <= UNSIGNED(p_in_dma_prm.len);
              end if;

              i_m_axis_rc_tready <= '1';
              i_fsm_rx <= S_RX_DH;

            end if;

        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RX_DH =>

            err_out := (others => '0');

            if i_sof(0) = '1' and i_sof(1) = '0' and p_in_dma_mrd_en = '1'
                and p_in_m_axis_rc_tvalid = '1' and p_in_utxbuf_full = '0' then

                if p_in_m_axis_rc_tkeep(2 downto 0) = "111" then

                      for i in 3 to p_in_m_axis_rc_tkeep'length - 1 loop
                      sr_axi_data(i) <= i_axi_data(i); --user data
                      end loop;

                      --Check Completion Status
                      if i_axi_data(1)(13 downto 11) = C_PCIE_COMPL_STATUS_SC then

                          i_cpld_byte <= i_cpld_byte_t;

                          i_cpld_tlp_work <= '1';

                          --Check DW Count
                          if i_cpld_dw_t > TO_UNSIGNED(5, i_cpld_dw_t'length) then

                              i_cpld_dw_rem <= (i_cpld_len(i_cpld_len'high - (log2(G_DATA_WIDTH / 32)) downto 0)
                                                & TO_UNSIGNED(0, (log2(G_DATA_WIDTH / 32))))  - i_cpld_dw_t;

                              i_fsm_rx <= S_RX_DN;

                          else

                              if p_in_m_axis_rc_tlast = '1' then

                                  if (i_cpld_byte_cnt - RESIZE(i_cpld_byte_t, p_in_dma_prm.len'length)) = TO_UNSIGNED(0, i_cpld_byte_cnt'length) then
                                    i_mrd_done <= '1';
                                  else
                                    i_mrd_done <= '0';
                                  end if;

                                  i_cpld_byte_cnt <= i_cpld_byte_cnt - RESIZE(i_cpld_byte_t, p_in_dma_prm.len'length);

                                  i_m_axis_rc_tready <= '0';
                                  i_fsm_rx <= S_RX_IDLE;
                              end if;

                          end if;

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


        --#######################################################################
        --
        --#######################################################################
        when S_RX_DN =>

            if p_in_m_axis_rc_tvalid = '1' and p_in_utxbuf_full = '0' then

                sr_axi_data <= i_axi_data;

                if p_in_m_axis_rc_tlast = '1' then

                    if i_cpld_dw_rem(3 downto 0) < TO_UNSIGNED(3, 4) then

                        i_cpld_tlp_work <= '0';

                        if (i_cpld_byte_cnt - RESIZE(i_cpld_byte_t, p_in_dma_prm.len'length)) = TO_UNSIGNED(0, i_cpld_byte_cnt'length) then
                          i_mrd_done <= '1';
                        else
                          i_mrd_done <= '0';
                        end if;

                        i_cpld_byte_cnt <= i_cpld_byte_cnt - RESIZE(i_cpld_byte, p_in_dma_prm.len'length);

                        i_fsm_rx <= S_RX_IDLE;

                    else

                      i_m_axis_rc_tready <= '0';
                      i_fsm_rx <= S_RX_DE;

                    end if;

                end if;

            end if;


        when S_RX_DE =>

            if p_in_utxbuf_full = '0' then

                i_cpld_tlp_work <= '0';
                i_m_axis_rc_tready <= '0';

                if (i_cpld_byte_cnt - RESIZE(i_cpld_byte_t, p_in_dma_prm.len'length)) = TO_UNSIGNED(0, i_cpld_byte_cnt'length) then
                  i_mrd_done <= '1';
                else
                  i_mrd_done <= '0';
                end if;

                i_cpld_byte_cnt <= i_cpld_byte_cnt - RESIZE(i_cpld_byte, p_in_dma_prm.len'length);

                i_fsm_rx <= S_RX_IDLE;

            end if;

    end case; --case i_fsm_rx is


    tst_err <= err_out;
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm



--#######################################################################
--DBG
--#######################################################################
--tst_fsm_rx <= '1' when i_fsm_rx = S_RX_WAIT  else '0';

p_out_tst(0) <= '0';--tst_fsm_rx;
p_out_tst(3 downto 1) <= (others => '0');
p_out_tst(5 downto 4) <= tst_err;
p_out_tst(7 downto 6) <= (others => '0');
p_out_tst(31 downto 3) <= (others => '0');


end architecture behavioral;


--                  elsif p_in_m_axis_rc_tkeep(3 downto 1) = "111" then
--
--                        pkt.h_rxdone := '1';
--                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
--                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));
--                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--
--                        if i_cpld_dw_t = TO_UNSIGNED(1, i_cpld_dw_t'length) then
--
--                              for i in 4 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              if p_in_m_axis_rc_tkeep(i) = '1' then
--                              sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end if;
--                              end loop;
--
--                        elsif i_cpld_dw_t = TO_UNSIGNED(2, i_cpld_dw_t'length) then
--
--                              case (p_in_m_axis_rc_tkeep(7 downto 4)) is
--                              when "0011" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--
--                              when "0101" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "1001" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when "0110" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "1010" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when "1100" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when others => null;
--                              end case;
--
--                        else
--
--                              for i in 4 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              sr_axi_data((32 * (i - (4 - 1))) - 1 downto (32 * (i - 4))) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end loop;
--                              sr_axi_data((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
--                              sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
--                              sr_axi_data((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
--                              sr_axi_data((32 * 8) - 1 downto (32 * 7)) <= (others => '0');
--
--                        end if;
--
--
--
--                  elsif p_in_m_axis_rc_tkeep(4 downto 2) = "111" then
--
--                        pkt.h_rxdone := '1';
--                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));
--                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--
--                        if i_cpld_dw_t = TO_UNSIGNED(1, i_cpld_dw_t'length) then
--
--                              for i in 5 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              if p_in_m_axis_rc_tkeep(i) = '1' then
--                              sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end if;
--                              end loop;
--
--                        elsif i_cpld_dw_t = TO_UNSIGNED(2, i_cpld_dw_t'length) then
--
--                              case (p_in_m_axis_rc_tkeep(7 downto 5) is
--                              when "011" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "101" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 7));
--
--                              when "110" =>
--                                sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--                                sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when others => null;
--                              end case;
--
--                        else
--
--                              for i in 5 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              sr_axi_data((32 * (i - (5 - 1))) - 1 downto (32 * (i - 5))) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end loop;
--                              sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
--                              sr_axi_data((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
--                              sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
--                              sr_axi_data((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
--                              sr_axi_data((32 * 8) - 1 downto (32 * 7)) <= (others => '0');
--
--                        end if;
--
--
--
--                  elsif p_in_m_axis_rc_tkeep(5 downto 3) = "111" then
--                        pkt.h_rxdone := '1';
--                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--
--                        if i_cpld_dw_t = TO_UNSIGNED(1, i_cpld_dw_t'length) then
--
--                              for i in 6 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              if p_in_m_axis_rc_tkeep(i) = '1' then
--                              sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end if;
--                              end loop;
--
--                        else
--
--                              sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--                              sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--                              sr_axi_data((32 * 3) - 1 downto (32 * 2)) <= (others => '0');
--                              sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
--                              sr_axi_data((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
--                              sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
--                              sr_axi_data((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
--                              sr_axi_data((32 * 8) - 1 downto (32 * 7)) <= (others => '0');
--
--                        end if;
--
--
--
--                  elsif p_in_m_axis_rc_tkeep(6 downto 4) = "111" then
--                      pkt.h_rxdone := '1';
--                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                      pkt.h(2) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                      sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--                      sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= (others => '0');
--                      sr_axi_data((32 * 3) - 1 downto (32 * 2)) <= (others => '0');
--                      sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
--                      sr_axi_data((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
--                      sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
--                      sr_axi_data((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
--                      sr_axi_data((32 * 8) - 1 downto (32 * 7)) <= (others => '0');
--
--
--                  elsif p_in_m_axis_rc_tkeep(7 downto 5) = "111" then
--                      pkt.h_rxdone := '1';
--                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--                      pkt.h(2) := p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                      sr_axi_data((32 * 8) - 1 downto (32 * 0)) <= (others => '0');
--
--
--                  elsif p_in_m_axis_rc_tkeep(7 downto 6) = "11" then
--                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                      sr_axi_data((32 * 8) - 1 downto (32 * 0)) <= (others => '0');
--
--
--                  elsif p_in_m_axis_rc_tkeep(7) = '1' then
--                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--
--                      sr_axi_data((32 * 8) - 1 downto (32 * 0)) <= (others => '0');
--
--
























--                  if p_in_m_axis_rc_tkeep(2 downto 0) /= "111" then
--                    err_out(0) := '1';
--
--                  else
--
--                        pkt.h_rxdone := '1';
--                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0));
--                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
--                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));
--
--                        if i_cpld_dw_t = TO_UNSIGNED(1, i_cpld_dw_t'length) then
--
--                              for i in 3 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              if p_in_m_axis_rc_tkeep(i) = '1' then
--                              sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end if;
--                              end loop;
--
--                        elsif i_cpld_dw_t = TO_UNSIGNED(2, i_cpld_dw_t'length) then
--
--                              case (p_in_m_axis_rc_tkeep(7 downto 3)) is
--                              when "00011" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--
--                              when "00101" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--
--                              when "01001" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "10001" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when "00110" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--
--                              when "01010" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "10010" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when "01100" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--
--                              when "10100" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when "11000" =>
--                                sr_axi_data((32 * 4) - 1 downto (32 * 3)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
--                                sr_axi_data((32 * 6) - 1 downto (32 * 5)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
--
--                              when others => null;
--                              end case;
--
--                        else
--
--                              sr_axi_data((32 * 1) - 1 downto (32 * 0)) <= (others => '0');
--                              sr_axi_data((32 * 2) - 1 downto (32 * 1)) <= (others => '0');
--                              sr_axi_data((32 * 3) - 1 downto (32 * 2)) <= (others => '0');
--                              for i in 3 to p_in_m_axis_rc_tkeep'length - 1 loop
--                              sr_axi_data((32 * (i + 1)) - 1 downto (32 * i)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
--                              end loop;
--
--                        end if;
--
--                  end if;