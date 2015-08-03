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
p_in_rq_prm : in  TRQParam;

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
S_RX_WAIT
);
signal i_fsm_rx              : TFsmRx_state;

signal i_sof                 : std_logic_vector(1 downto 0);

signal i_m_axis_cq_tready    : std_logic := '0';
signal i_m_axis_rc_tready    : std_logic := '1';

signal i_req_pkt             : std_logic_vector(3 downto 0);
signal i_trg_func            : std_logic_vector(7 downto 0);
signal i_bar_id              : std_logic_vector(2 downto 0);

signal i_req_des             : TPCIEDesc;
signal i_tph                 : TPCIEtph;
signal i_first_be            : std_logic_vector(3 downto 0);
signal i_last_be             : std_logic_vector(3 downto 0);

signal i_req_compl           : std_logic := '0';
signal i_req_compl_ur        : std_logic := '0';

signal i_reg_d               : std_logic_vector(31 downto 0);
signal i_reg_wrbe            : std_logic_vector(3 downto 0);
signal i_reg_wr              : std_logic;
signal i_reg_rd              : std_logic;
signal i_reg_cs              : std_logic;

signal tst_err               : std_logic_vector(1 downto 0);
signal tst_fsm_rx            : std_logic;


begin --architecture behavioral of pcie_rx_rc


p_out_utxbuf_di   <= (others => '0');--: out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_utxbuf_wr   <= '0';--: out  std_logic;
p_out_utxbuf_last <= '0';--: out  std_logic;

p_out_m_axis_rc_tready <= i_m_axis_rc_tready;

i_m_axis_rc_tready <= not p_in_utxbuf_full;


i_sof(0) <= p_in_m_axis_rc_tuser(32);
i_sof(1) <= p_in_m_axis_rc_tuser(33);
--i_eof_0 <= p_in_m_axis_rc_tuser(37 downto 34);
--i_eof_1 <= p_in_m_axis_rc_tuser(41 downto 38);

i_disc <= p_in_m_axis_rc_tuser(42);



i_cpld_tpl_byte <= UNSIGNED(pkt.h(0)(28 downto 16)); --Byte Count
i_cpld_tpl_dw <= UNSIGNED(pkt.h(1)(10 downto 0)); --Length data payload (DW)

--Rx State Machine
fsm : process(p_in_clk)
variable err_out : std_logic_vector(tst_err'range);
variable pkt : TRxCPLD;
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_rx <= S_RX_IDLE;

    i_m_axis_cq_tready <= '0';

    pkt.h_rxdone := '0';

    for i in 0 to pkt.h'length - 1 loop
    pkt.h(i) := (others => '0');
    end loop;
    for i in 0 to pkt.d'length - 1 loop
    pkt.d(i) := (others => '0');
    end loop;

    tst_err <= (others => '0'); err_out := (others => '0');

  else

    case i_fsm_rx is
        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RX_IDLE =>

            i_reg_wr <= '0';

            err_out := (others => '0');

            cpld_tlp_work := '0';
            cpld_tlp_dlast := '0';

            pkt.h_rxdone := '0';

            if i_sof(0) = '1' and i_sof(1) = '0' and i_m_axis_rc_tready = '1' then

                  if p_in_m_axis_rc_tkeep(2 downto 0) = "111" then

                        pkt.h_rxdone := '1';
                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0));
                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));

                        if i_cpld_tpl_dw = TO_UNSIGNED(1, i_cpld_tpl_dw'length) then

                              for i in 3 to p_in_m_axis_rc_tkeep'length - 1 loop
                              if p_in_m_axis_rc_tkeep(i) = '1' then
                              sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end if;
                              end loop;

                        elsif i_cpld_tpl_dw = TO_UNSIGNED(2, i_cpld_tpl_dw'length) then

                              case (p_in_m_axis_rc_tkeep(7 downto 3)) is
                              when "00011" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));

                              when "00101" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));

                              when "01001" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "10001" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when "00110" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));

                              when "01010" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "10010" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when "01100" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "10100" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when "11000" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when others => null;
                              end case;

                        else

                              for i in 3 to p_in_m_axis_rc_tkeep'length - 1 loop
                              sr_m_axis_rc_tdata((32 * (i - (3 - 1))) - 1 downto (32 * (i - 3))) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end loop;
                              sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7)) <= (others => '0');

                        end if;


                  elsif p_in_m_axis_rc_tkeep(3 downto 1) = "111" then

                        pkt.h_rxdone := '1';
                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));
                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));

                        if i_cpld_tpl_dw = TO_UNSIGNED(1, i_cpld_tpl_dw'length) then

                              for i in 4 to p_in_m_axis_rc_tkeep'length - 1 loop
                              if p_in_m_axis_rc_tkeep(i) = '1' then
                              sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end if;
                              end loop;

                        elsif i_cpld_tpl_dw = TO_UNSIGNED(2, i_cpld_tpl_dw'length) then

                              case (p_in_m_axis_rc_tkeep(7 downto 4)) is
                              when "0011" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));

                              when "0101" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "1001" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when "0110" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "1010" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when "1100" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when others => null;
                              end case;

                        else

                              for i in 4 to p_in_m_axis_rc_tkeep'length - 1 loop
                              sr_m_axis_rc_tdata((32 * (i - (4 - 1))) - 1 downto (32 * (i - 4))) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end loop;
                              sr_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7)) <= (others => '0');

                        end if;



                  elsif p_in_m_axis_rc_tkeep(4 downto 2) = "111" then

                        pkt.h_rxdone := '1';
                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));
                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));

                        if i_cpld_tpl_dw = TO_UNSIGNED(1, i_cpld_tpl_dw'length) then

                              for i in 5 to p_in_m_axis_rc_tkeep'length - 1 loop
                              if p_in_m_axis_rc_tkeep(i) = '1' then
                              sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end if;
                              end loop;

                        elsif i_cpld_tpl_dw = TO_UNSIGNED(2, i_cpld_tpl_dw'length) then

                              case (p_in_m_axis_rc_tkeep(7 downto 5) is
                              when "011" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                              when "101" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 7));

                              when "110" =>
                                sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                                sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                              when others => null;
                              end case;

                        else

                              for i in 5 to p_in_m_axis_rc_tkeep'length - 1 loop
                              sr_m_axis_rc_tdata((32 * (i - (5 - 1))) - 1 downto (32 * (i - 5))) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end loop;
                              sr_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7)) <= (others => '0');

                        end if;



                  elsif p_in_m_axis_rc_tkeep(5 downto 3) = "111" then
                        pkt.h_rxdone := '1';
                        pkt.h(0) := p_in_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                        pkt.h(1) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                        pkt.h(2) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));

                        if i_cpld_tpl_dw = TO_UNSIGNED(1, i_cpld_tpl_dw'length) then

                              for i in 6 to p_in_m_axis_rc_tkeep'length - 1 loop
                              if p_in_m_axis_rc_tkeep(i) = '1' then
                              sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i));
                              end if;
                              end loop;

                        else

                              sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                              sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
                              sr_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
                              sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7)) <= (others => '0');

                        end if;



                  elsif p_in_m_axis_rc_tkeep(6 downto 4) = "111" then
                      pkt.h_rxdone := '1';
                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                      pkt.h(2) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                      sr_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));
                      sr_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6)) <= (others => '0');
                      sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7)) <= (others => '0');


                  elsif p_in_m_axis_rc_tkeep(7 downto 5) = "111" then
                      pkt.h_rxdone := '1';
                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                      pkt.h(2) := p_in_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                      sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 0)) <= (others => '0');


                  elsif p_in_m_axis_rc_tkeep(7 downto 6) = "11" then
                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                      pkt.h(1) := p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));

                      sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 0)) <= (others => '0');


                  elsif p_in_m_axis_rc_tkeep(7) = '1' then
                      pkt.h(0) := p_in_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));

                      sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 0)) <= (others => '0');

                  end if;





                if pkt.h_rxdone = '1' then

                    --Check Completion Status
                    if pkt.h(1)(13 downto 11) = "000" then

                        i_cpld_tpl_byte_count <= i_cpld_tpl_byte; --Byte Count
                        i_cpld_tpl_dw_count <= i_cpld_tpl_dw;

                        i_cpld_tpl_len <= RESIZE(i_cpld_tpl_byte(i_cpld_tpl_byte'high downto log2(G_DATA_WIDTH / 8)), i_cpld_tpl_len'length)
                                        + (TO_UNSIGNED(0, i_cpld_tpl_len'length - 2)
                                            & OR_reduce(i_cpld_tpl_byte(log2(G_DATA_WIDTH / 8) - 1 downto 0)));

                        i_cpld_tlp_cnt <= (others => '0');
                          cpld_tlp_work := '1';

--                        if pkt.h_lastpos = TO_UNSIGNED(7, pkt.h_lastpos'length - 1) then
--
--                          i_fsm_rx <= S_RX_D0;
--
--                        else
                            --Check DW Count
                            if i_cpld_tpl_dw > TO_UNSIGNED(5, 11) then
                              i_fsm_rx <= S_RX_DN;

                            else
                                if p_in_m_axis_rc_tlast = '1' then
                                    cpld_tlp_dlast := '1';

                                  if p_in_dma_prm.len = (i_cpld_total_size_byte + i_cpld_tpl_byte) then
                                    i_mrd_done <= '1';
                                  else
                                    i_mrd_done <= '0';
                                    i_cpld_total_size_byte <= i_cpld_total_size_byte + i_cpld_tpl_byte;
                                  end if;

                                end if;









                            end if;

                    else
                      ----Check Error Code
                      --if pkt.h(1)(15 downto 12) = ""
                      --end if;
                    end if;

                end if;

            end if;

            i_cpld_tlp_work := cpld_tlp_work;
            i_cpld_tlp_dlast <= cpld_tlp_dlast;

            i_pkt.h <= pkt.h;
            i_pkt.d <= pkt.d;

            sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 0));


        --#######################################################################
        --
        --#######################################################################
        when S_RX_DN =>

            if i_m_axis_rc_tready = '1' then

                if dwe_calc_done = '1' then;
                  dwe_cnt := 0;
                end if;

                  dwe_calc_done := '0';

                i_pkt.d(0) <= sr_m_axis_rc_tdata((32 * 4) - 1 downto (32 * 3));
                i_pkt.d(1) <= sr_m_axis_rc_tdata((32 * 5) - 1 downto (32 * 4));
                i_pkt.d(2) <= sr_m_axis_rc_tdata((32 * 6) - 1 downto (32 * 5));
                i_pkt.d(3) <= sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 6));
                i_pkt.d(4) <= sr_m_axis_rc_tdata((32 * 8) - 1 downto (32 * 7));

                i_pkt.d(5) <= p_in_m_axis_rc_tdata((32 * 1) - 1 downto (32 * 0));
                i_pkt.d(6) <= p_in_m_axis_rc_tdata((32 * 2) - 1 downto (32 * 1));
                i_pkt.d(7) <= p_in_m_axis_rc_tdata((32 * 3) - 1 downto (32 * 2));

                sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 0)) <= p_in_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 0));

                for
                i_m_axis_rc_tdata((32 * (i + 1)) - 1 downto (32 * i)) <= sr_m_axis_rc_tdata((32 * 7) - 1 downto (32 * 0));


                for i in 0 to p_in_m_axis_rc_tkeep'length - 1 loop
                  if p_in_m_axis_rc_tkeep(i) = '1' then
                      dwe_cnt := dwe_cnt + 1;
                      if (i = p_in_m_axis_rc_tkeep'length - 1) then
                        dwe_calc_done := '1';
                      end if;
                  end if;
                end loop;

                if p_in_m_axis_rc_tlast = '1' then
                    cpld_tlp_dlast := '1';

                    if dwe_cnt


                  if p_in_dma_prm.len = (i_cpld_total_size_byte + i_cpld_tpl_byte) then
                    i_mrd_done <= '1';
                  else
                    i_mrd_done <= '0';
                    i_cpld_total_size_byte <= i_cpld_total_size_byte + i_cpld_tpl_byte;
                  end if;

                end if;

            end if;

    end case; --case i_fsm_rx is


    tst_err <= err_out;
  end if;--p_in_rst_n
end if;--p_in_clk
end process; --fsm



--#######################################################################
--DBG
--#######################################################################
tst_fsm_rx <= '1' when i_fsm_rx = S_RX_WAIT  else '0';

p_out_tst(0) <= tst_fsm_rx;
p_out_tst(3 downto 1) <= (others => '0');
p_out_tst(5 downto 4) <= tst_err;
p_out_tst(7 downto 6) <= (others => '0');
p_out_tst(31 downto 3) <= (others => '0');


end architecture behavioral;


