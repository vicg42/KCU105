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

signal i_sof_0               : std_logic;

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


i_sof_0 <= p_in_m_axis_rc_tuser(32);
--i_sof_1 <= p_in_m_axis_rc_tuser(33);
--i_eof_0 <= p_in_m_axis_rc_tuser(37 downto 34);
--i_eof_1 <= p_in_m_axis_rc_tuser(41 downto 38);

i_disc <= p_in_m_axis_rc_tuser(42);


--Rx State Machine
fsm : process(p_in_clk)
variable err_out : std_logic_vector(tst_err'range);
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then

    i_fsm_rx <= S_RX_IDLE;

    i_m_axis_cq_tready <= '0';


    i_first_be <= (others => '0');
    i_last_be <= (others => '0');

    tst_err <= (others => '0'); err_out := (others => '0');

  else

    case i_fsm_rx is
        --#######################################################################
        --Detect start of packet
        --#######################################################################
        when S_RX_IDLE =>

            i_reg_wr <= '0';

            err_out := (others => '0');

            if i_sof_0 = '1' and i_m_axis_rc_tready = '1' then

              i_first_be <= p_in_m_axis_cq_tuser(3 downto 0);
              i_last_be <= p_in_m_axis_cq_tuser(7 downto 4);

              --Check Completion Status
              if (p_in_m_axis_rc_tdata((32 * 1) + 13 downto (32 * 1) + 11) /= "000" ) then

                err_out(0) := '1';
                --p_in_m_axis_rc_tdata((32 * 0) + 15 downto (32 * 0) + 12);--Completion error code

              else

              --Check Dword count
              if (UNSIGNED(p_in_m_axis_rc_tdata((32 * 1) + 10 downto (32 * 1) + 0)) > TO_UNSIGNED(5, 11) ) then
              else
              end if;


            end if;

        --#######################################################################
        --
        --#######################################################################
        when S_RX_WAIT =>

            i_reg_wr <= '0';
            i_reg_rd <= '0';
            i_req_compl <= '0';
            i_req_compl_ur <= '0';

            if p_in_compl_done = '1' or i_req_compl = '0' then

              i_m_axis_cq_tready <= '1';
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
tst_fsm_rx <= '1' when i_fsm_rx = S_RX_WAIT  else '0';

p_out_tst(0) <= tst_fsm_rx;
p_out_tst(3 downto 1) <= (others => '0');
p_out_tst(5 downto 4) <= tst_err;
p_out_tst(7 downto 6) <= (others => '0');
p_out_tst(31 downto 3) <= (others => '0');


end architecture behavioral;


