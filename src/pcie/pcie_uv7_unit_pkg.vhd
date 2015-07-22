-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 10:29:01
-- Module Name : pcie_unit_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.prj_def.all;
use work.pcie_pkg.all;

package pcie_unit_pkg is

component pio_to_ctrl
port (
clk        : in  std_logic;
rst_n      : in  std_logic;

req_compl  : in  std_logic;
compl_done : in  std_logic;

cfg_power_state_change_interrupt : in  std_logic;
cfg_power_state_change_ack       : out std_logic
);
end component pio_to_ctrl;

component pcie_rx
generic(
--AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
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
port (
-- Completer Request Interface
p_in_m_axis_cq_tdata      : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tlast      : in  std_logic;
p_in_m_axis_cq_tvalid     : in  std_logic;
p_in_m_axis_cq_tuser      : in  std_logic_vector(84 downto 0);
p_in_m_axis_cq_tkeep      : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_pcie_cq_np_req_count : in  std_logic_vector(5 downto 0);
p_out_m_axis_cq_tready    : out std_logic;
p_out_pcie_cq_np_req      : out std_logic;

-- Requester Completion Interface
p_in_m_axis_rc_tdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tlast    : in  std_logic;
p_in_m_axis_rc_tvalid   : in  std_logic;
p_in_m_axis_rc_tkeep    : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser    : in  std_logic_vector(74 downto 0);
p_out_m_axis_rc_tready  : out std_logic;

--RX Message Interface
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

-- Memory Read data handshake with Completion
-- transmit unit. Transmit unit reponds to
-- req_compl assertion and responds with compl_done
-- assertion when a Completion w/ data is transmitted.
p_out_req_compl    : out std_logic := '0';
--p_out_req_compl_wd : out std_logic := '0';
p_out_req_compl_ur : out std_logic := '0';
p_in_compl_done    : in  std_logic;

p_out_req_prm      : out TPCIE_reqprm;

--usr app
p_out_ureg_di  : out std_logic_vector(31 downto 0);
p_out_ureg_wrbe: out std_logic_vector(3 downto 0);
p_out_ureg_wr  : out std_logic;
p_out_ureg_rd  : out std_logic;

--DBG
p_out_tst : out std_logic_vector(31 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end component pcie_rx;


component pcie_tx
generic (
--parameter [1 downto 0);AXISTEN_IF_WIDTH = 00,
G_AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_CC_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK   : integer := 0;

--Do not modify the parameters below this line
G_DATA_WIDTH : integer := 64; --(AXISTEN_IF_WIDTH[1]) ? 256 : (AXISTEN_IF_WIDTH[0])? 128 : 64,
G_PARITY_WIDTH : integer := 64 /8 ;
G_KEEP_WIDTH   : integer := 64 /32;
G_STRB_WIDTH   : integer := 64 / 8
);
port (
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tlast  : out std_logic;
p_out_s_axis_cc_tvalid : out std_logic;
p_out_s_axis_cc_tuser  : out std_logic_vector(32 downto 0);
p_in_s_axis_cc_tready  : in  std_logic;

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_rq_tlast  : out std_logic;
p_out_s_axis_rq_tvalid : out std_logic;
p_out_s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
p_in_s_axis_rq_tready  : in  std_logic;

--TX Message Interface
p_in_cfg_msg_transmit_done  : in  std_logic;
p_out_cfg_msg_transmit      : out std_logic;
p_out_cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

--Cfg Flow Control Information
p_in_cfg_fc_ph   : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_nph  : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_cplh : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_pd   : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_npd  : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_cpld : in  std_logic_vector(11 downto 0);
p_out_cfg_fc_sel : out std_logic_vector(2 downto 0);

--Completion
p_in_req_compl    : in  std_logic;
p_in_req_compl_ur : in  std_logic;
p_out_compl_done  : out std_logic;

p_in_req_prm      : in TPCIE_reqprm;

p_in_completer_id : in  std_logic_vector(15 downto 0);

--usr app
p_in_ureg_do   : in  std_logic_vector(31 downto 0);

--DBG
p_out_tst : out std_logic_vector(279 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end component pcie_tx;

component pcie_irq
generic (
TCQ : integer := 1
);
port (
user_clk : in  std_logic; --User Clock
reset_n  : in  std_logic; --User Reset

--Trigger to generate interrupts (to / from Mem access Block)
gen_leg_intr   : in  std_logic; --Generate Legacy Interrupts
gen_msi_intr   : in  std_logic; --Generate MSI Interrupts
gen_msix_intr  : in  std_logic; --Generate MSI-X Interrupts
interrupt_done : out std_logic; --Indicates whether interrupt is done or in process

--Legacy Interrupt Interface
cfg_interrupt_sent : in  std_logic; --Core asserts this signal when it sends out a Legacy interrupt
cfg_interrupt_int  : out std_logic_vector(3 downto 0); --4 Bits for INTA, INTB, INTC, INTD (assert or deassert)

--MSI Interrupt Interface
cfg_interrupt_msi_enable : in  std_logic;
cfg_interrupt_msi_sent   : in  std_logic;
cfg_interrupt_msi_fail   : in  std_logic;

cfg_interrupt_msi_int    : out std_logic_vector(31 downto 0);

--MSI-X Interrupt Interface
cfg_interrupt_msix_enable : in  std_logic;
cfg_interrupt_msix_sent   : in  std_logic;
cfg_interrupt_msix_fail   : in  std_logic;

cfg_interrupt_msix_int    : out std_logic;
cfg_interrupt_msix_address: out std_logic_vector(63 downto 0);
cfg_interrupt_msix_data   : out std_logic_vector(31 downto 0)
);
end component pcie_irq;


component pcie_usr_app is
generic(
G_DBG : string := "OFF"
);
port(
-------------------------------------------------------
--USR Port
-------------------------------------------------------
p_out_hclk      : out   std_logic;
p_out_gctrl     : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);--global ctrl

--CTRL user devices
p_out_dev_ctrl  : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din   : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);--DEV<-HOST
p_in_dev_dout   : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);--DEV->HOST
p_out_dev_wr    : out   std_logic;
p_out_dev_rd    : out   std_logic;
p_in_dev_status : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq    : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt    : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt   : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--DBG
p_out_tst       : out   std_logic_vector(127 downto 0);
p_in_tst        : in    std_logic_vector(127 downto 0);

--------------------------------------
--PCIE_Rx/Tx  Port
--------------------------------------
p_in_pcie_prm  : in  TPCIE_cfgprm;

--Target mode
p_in_reg_adr   : in    std_logic_vector(7 downto 0);
p_out_reg_dout : out   std_logic_vector(31 downto 0);
p_in_reg_din   : in    std_logic_vector(31 downto 0);
p_in_reg_wr    : in    std_logic;
p_in_reg_rd    : in    std_logic;

p_in_clk   : in    std_logic;
p_in_rst_n : in    std_logic
);
end component pcie_usr_app;


component dbgcs_ila_pcie is
port (
clk : in std_logic;
probe0 : in std_logic_vector(33 downto 0)
);
end component dbgcs_ila_pcie;

end package pcie_unit_pkg;

