-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 10:45:04
-- Module Name : pcie_ctrl.vhd
--
-- Description : CTRL core PCI-Express
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.pcie_unit_pkg.all;
use work.pcie_pkg.all;
use work.prj_def.all;
use work.prj_cfg.all;

entity pcie_ctrl is
generic(
G_DBGCS : string := "OFF";
G_DATA_WIDTH                     : integer := 64;
G_KEEP_WIDTH                     : integer := 1;
G_AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
G_AXISTEN_IF_RQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_CC_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG   : integer := 1;
G_AXISTEN_IF_RQ_PARITY_CHECK     : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK     : integer := 0;
G_AXISTEN_IF_MC_RX_STRADDLE      : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1')
);
port(
--------------------------------------
--USR Port
--------------------------------------
p_out_hclk      : out   std_logic;
p_out_gctrl     : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

--CTRL user devices
p_out_dev_ctrl  : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din   : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout   : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr    : out   std_logic;
p_out_dev_rd    : out   std_logic;
p_in_dev_status : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq    : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt    : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt   : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--DBG
p_out_tst       : out   std_logic_vector(127 downto 0);
p_in_tst        : in    std_logic_vector(127 downto 0);

------------------------------------
--AXI Interface
------------------------------------
p_out_s_axis_rq_tlast  : out  std_logic                                  ;
p_out_s_axis_rq_tdata  : out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tuser  : out  std_logic_vector(59 downto 0)              ;
p_out_s_axis_rq_tkeep  : out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_s_axis_rq_tready  : in   std_logic_vector(3 downto 0)               ;
p_out_s_axis_rq_tvalid : out  std_logic                                  ;

p_in_m_axis_rc_tdata   : in   std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser   : in   std_logic_vector(74 downto 0)              ;
p_in_m_axis_rc_tlast   : in   std_logic                                  ;
p_in_m_axis_rc_tkeep   : in   std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tvalid  : in   std_logic                                  ;
p_out_m_axis_rc_tready : out  std_logic_vector(21 downto 0)              ;

p_in_m_axis_cq_tdata   : in   std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tuser   : in   std_logic_vector(84 downto 0)              ;
p_in_m_axis_cq_tlast   : in   std_logic                                  ;
p_in_m_axis_cq_tkeep   : in   std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_cq_tvalid  : in   std_logic                                  ;
p_out_m_axis_cq_tready : out  std_logic_vector(21 downto 0)              ;

p_out_s_axis_cc_tdata  : out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tuser  : out  std_logic_vector(32 downto 0)              ;
p_out_s_axis_cc_tlast  : out  std_logic                                  ;
p_out_s_axis_cc_tkeep  : out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tvalid : out  std_logic                                  ;
p_in_s_axis_cc_tready  : in   std_logic_vector(3 downto 0)               ;

p_in_pcie_tfc_nph_av  : in   std_logic_vector(1 downto 0)                ;
p_in_pcie_tfc_npd_av  : in   std_logic_vector(1 downto 0)                ;

------------------------------------
--Configuration (CFG) Interface
------------------------------------
p_in_pcie_rq_seq_num      : in   std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in   std_logic                   ;
p_in_pcie_rq_tag          : in   std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in   std_logic                   ;
p_out_pcie_cq_np_req      : out  std_logic                   ;
p_in_pcie_cq_np_req_count : in   std_logic_vector(5 downto 0);
p_in_pcie_tfc_np_pl_empty : in   std_logic                   ;
--p_in_pcie_rq_tag_av       : in   std_logic_vector(1 downto 0);

------------------------------------
--Management Interface
------------------------------------
p_in_cfg_msg_received         : in  std_logic;
p_in_cfg_msg_received_data    : in  std_logic_vector(7 downto 0);
p_in_cfg_msg_received_type    : in  std_logic_vector(4 downto 0);
p_out_cfg_msg_transmit        : out std_logic;
p_out_cfg_msg_transmit_type   : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data   : out std_logic_vector(31 downto 0);
p_in_cfg_msg_transmit_done    : in  std_logic;

------------------------------------
-- EP and RP
------------------------------------
p_in_cfg_phy_link_status  : in   std_logic_vector(1 downto 0);
p_in_cfg_negotiated_width : in   std_logic_vector(3 downto 0); -- valid when cfg_phy_link_status[1:0] == 11b
p_in_cfg_current_speed    : in   std_logic_vector(2 downto 0);
p_in_cfg_max_payload      : in   std_logic_vector(2 downto 0);
p_in_cfg_max_read_req     : in   std_logic_vector(2 downto 0);
p_in_cfg_function_status  : in   std_logic_vector(7 downto 0);

-- Error Reporting Interface
p_in_cfg_err_cor_out      : in   std_logic;
p_in_cfg_err_nonfatal_out : in   std_logic;
p_in_cfg_err_fatal_out    : in   std_logic;

p_in_cfg_fc_ph            : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_pd            : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_nph           : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_npd           : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_cplh          : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_cpld          : in   std_logic_vector(11 downto 0);
p_out_cfg_fc_sel          : out  std_logic_vector( 2 downto 0);

p_out_cfg_dsn                         : out  std_logic_vector(63 downto 0);
p_out_cfg_power_state_change_ack      : out  std_logic;
p_in_cfg_power_state_change_interrupt : in   std_logic;
p_out_cfg_err_cor_in                  : out  std_logic;
p_out_cfg_err_uncor_in                : out  std_logic;

p_in_cfg_flr_in_process       : in   std_logic_vector(3 downto 0);
p_out_cfg_flr_done            : out  std_logic_vector(3 downto 0);
p_in_cfg_vf_flr_in_process    : in   std_logic_vector(7 downto 0);
p_out_cfg_vf_flr_done         : out  std_logic_vector(7 downto 0);

p_out_cfg_ds_port_number      : out  std_logic_vector(7 downto 0);
p_out_cfg_ds_bus_number       : out  std_logic_vector(7 downto 0);
p_out_cfg_ds_device_number    : out  std_logic_vector(4 downto 0);
p_out_cfg_ds_function_number  : out  std_logic_vector(2 downto 0);

------------------------------------
-- EP Only
------------------------------------
-- Interrupt Interface Signals
p_out_cfg_interrupt_int                 : out  std_logic_vector(3 downto 0) ;
p_out_cfg_interrupt_pending             : out  std_logic_vector(3 downto 0) ;
p_in_cfg_interrupt_sent                 : in   std_logic                    ;

p_in_cfg_interrupt_msi_enable           : in   std_logic_vector(1 downto 0) ;
p_in_cfg_interrupt_msi_vf_enable        : in   std_logic_vector(5 downto 0) ;
p_in_cfg_interrupt_msi_mmenable         : in   std_logic_vector(5 downto 0) ;
p_in_cfg_interrupt_msi_mask_update      : in   std_logic                    ;
p_in_cfg_interrupt_msi_data             : in   std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_select          : out  std_logic_vector( 3 downto 0);
p_out_cfg_interrupt_msi_int             : out  std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_pending_status  : out  std_logic_vector(31 downto 0);
p_in_cfg_interrupt_msi_sent             : in   std_logic                    ;
p_in_cfg_interrupt_msi_fail             : in   std_logic                    ;
p_out_cfg_interrupt_msi_attr            : out  std_logic_vector(2 downto 0) ;
p_out_cfg_interrupt_msi_tph_present     : out  std_logic                    ;
p_out_cfg_interrupt_msi_tph_type        : out  std_logic_vector(1 downto 0) ;
p_out_cfg_interrupt_msi_tph_st_tag      : out  std_logic_vector(8 downto 0) ;
p_out_cfg_interrupt_msi_function_number : out  std_logic_vector(3 downto 0) ;
p_out_cfg_interrupt_msi_pending_status_data_enable  : out  std_logic;
p_out_cfg_interrupt_msi_pending_status_function_num : out  std_logic_vector(3 downto 0);

p_in_cfg_interrupt_msix_enable          : in  std_logic;
p_in_cfg_interrupt_msix_sent            : in  std_logic;
p_in_cfg_interrupt_msix_fail            : in  std_logic;
p_out_cfg_interrupt_msix_int            : out std_logic;
p_out_cfg_interrupt_msix_address        : out std_logic_vector(63 downto 0);
p_out_cfg_interrupt_msix_data           : out std_logic_vector(31 downto 0);

-- EP only
p_in_cfg_hot_reset_in   : in   std_logic;

-- RP only
p_out_cfg_hot_reset_out : out  std_logic;

p_in_user_clk    : in   std_logic;
p_in_user_reset  : in   std_logic;
p_in_user_lnk_up : in   std_logic
);
end entity pcie_ctrl;

architecture struct of pcie_ctrl is

constant CI_STRB_WIDTH   : integer := G_DATA_WIDTH / 8 ; -- TSTRB width
constant CI_KEEP_WIDTH   : integer := G_DATA_WIDTH / 32;
constant CI_PARITY_WIDTH : integer := G_DATA_WIDTH / 8 ;  -- TPARITY width

signal i_pcie_prm              : TPCIE_cfgprm;

type TSR_flr_bus2 is array (0 to 1) of std_logic_vector(1 downto 0);
type TSR_flr_bus6 is array (0 to 1) of std_logic_vector(5 downto 0);
signal sr_cfg_flr_done         : TSR_flr_bus2;
signal sr_cfg_vf_flr_done      : TSR_flr_bus6;

signal i_req_completion        : std_logic;
signal i_completion_done       : std_logic;
signal i_rst_n                 : std_logic;
signal i_pio_rst_n             : std_logic;

signal i_req_compl             : std_logic;
signal i_req_compl_ur          : std_logic;
signal i_compl_done            : std_logic;

signal i_req_prm               : TPCIE_reqprm;

--signal i_req_type              : std_logic_vector(3 downto 0) ;
--signal i_req_tc                : std_logic_vector(2 downto 0) ;
--signal i_req_attr              : std_logic_vector(2 downto 0) ;
--signal i_req_len               : std_logic_vector(10 downto 0);
--signal i_req_rid               : std_logic_vector(15 downto 0);
--signal i_req_tag               : std_logic_vector(7 downto 0) ;
--signal i_req_be                : std_logic_vector(7 downto 0) ;
--signal i_req_addr              : std_logic_vector(12 downto 0);
--signal i_req_at                : std_logic_vector(1 downto 0) ;
--
--signal i_req_des_qword0        : std_logic_vector(63 downto 0);
--signal i_req_des_qword1        : std_logic_vector(63 downto 0);
--signal i_req_des_tph_present   : std_logic;
--signal i_req_des_tph_type      : std_logic_vector(1 downto 0) ;
--signal i_req_des_tph_st_tag    : std_logic_vector(7 downto 0) ;

signal i_ureg_di               : std_logic_vector(31 downto 0);
signal i_ureg_do               : std_logic_vector(31 downto 0);
signal i_ureg_wrbe             : std_logic_vector(3 downto 0);
signal i_ureg_wr               : std_logic;
signal i_ureg_rd               : std_logic;

signal i_m_axis_cq_tready      : std_logic;
signal i_m_axis_rc_tready      : std_logic;

signal i_interrupt_done        : std_logic;

signal i_gen_transaction       : std_logic;
signal i_gen_leg_intr          : std_logic;
signal i_gen_msi_intr          : std_logic;
signal i_gen_msix_intr         : std_logic;

--signal tst_in                  : std_logic_vector(127 downto 0);

signal tst_rx_out              : std_logic_vector(31 downto 0);
signal tst_tx_out              : std_logic_vector(69 downto 0);
signal i_dbg_pcie              : std_logic_vector(199 downto 0);

attribute mark_debug : string;
attribute mark_debug of i_dbg_pcie         : signal is "true";

begin --architecture struct of pcie_ctrl


i_rst_n <= not p_in_user_reset;

i_pio_rst_n <= p_in_user_lnk_up and i_rst_n;

----------------------------------------
--Function level reset (FLR)
----------------------------------------
process(p_in_user_clk, p_in_user_reset)
begin
if p_in_user_reset = '1' then
  for i in 0 to sr_cfg_flr_done'length - 1 loop
  sr_cfg_flr_done(i) <= (others => '0');
  end loop;

  for i in 0 to sr_cfg_vf_flr_done'length - 1 loop
  sr_cfg_vf_flr_done(i) <= (others => '0');
  end loop;

elsif rising_edge(p_in_user_clk) then
  sr_cfg_flr_done <= p_in_cfg_flr_in_process(1 downto 0) & sr_cfg_flr_done(0 to 0);
  sr_cfg_vf_flr_done <= p_in_cfg_vf_flr_in_process(5 downto 0) & sr_cfg_vf_flr_done(0 to 0);

end if;
end process;

--detect rising edge of p_in_cfg_flr_in_process
p_out_cfg_flr_done(0) <= not sr_cfg_flr_done(1)(0) and sr_cfg_flr_done(0)(0);
p_out_cfg_flr_done(1) <= not sr_cfg_flr_done(1)(1) and sr_cfg_flr_done(0)(1);
p_out_cfg_flr_done(p_out_cfg_flr_done'high downto 2) <= (others => '0');

--detect rising edge of p_in_cfg_vf_flr_in_process
p_out_cfg_vf_flr_done(0) <= not sr_cfg_vf_flr_done(1)(0) and sr_cfg_vf_flr_done(0)(0);
p_out_cfg_vf_flr_done(1) <= not sr_cfg_vf_flr_done(1)(1) and sr_cfg_vf_flr_done(0)(1);
p_out_cfg_vf_flr_done(2) <= not sr_cfg_vf_flr_done(1)(2) and sr_cfg_vf_flr_done(0)(2);
p_out_cfg_vf_flr_done(3) <= not sr_cfg_vf_flr_done(1)(3) and sr_cfg_vf_flr_done(0)(3);
p_out_cfg_vf_flr_done(4) <= not sr_cfg_vf_flr_done(1)(4) and sr_cfg_vf_flr_done(0)(4);
p_out_cfg_vf_flr_done(5) <= not sr_cfg_vf_flr_done(1)(5) and sr_cfg_vf_flr_done(0)(5);
p_out_cfg_vf_flr_done(p_out_cfg_vf_flr_done'high downto 6) <= (others => '0');


----------------------------------------
--
----------------------------------------
p_out_cfg_ds_port_number     <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_port_number'length));
p_out_cfg_ds_bus_number      <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_bus_number'length));
p_out_cfg_ds_device_number   <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_device_number'length));
p_out_cfg_ds_function_number <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_function_number'length));

p_out_cfg_dsn <= std_logic_vector(TO_UNSIGNED(C_PCFG_FIRMWARE_VERSION, p_out_cfg_dsn'length));

p_out_cfg_err_cor_in   <= '0';
p_out_cfg_err_uncor_in <= '0';

-- RP only
p_out_cfg_hot_reset_out <= '0';


i_pcie_prm.link_width <= std_logic_vector(RESIZE(UNSIGNED(p_in_cfg_negotiated_width), i_pcie_prm.link_width'length));
i_pcie_prm.max_payload <= std_logic_vector(RESIZE(UNSIGNED(p_in_cfg_max_payload), i_pcie_prm.max_payload'length));
i_pcie_prm.max_rd_req <= std_logic_vector(RESIZE(UNSIGNED(p_in_cfg_max_read_req), i_pcie_prm.max_rd_req'length));


----------------------------------------
--
----------------------------------------
m_usr_app : pcie_usr_app
generic map(
G_DBG => "OFF"
)
port map (
----------------------------------------
--USR Port
----------------------------------------
p_out_hclk      => p_out_hclk ,
p_out_gctrl     => p_out_gctrl,

--CTRL user devices
p_out_dev_ctrl  => p_out_dev_ctrl ,
p_out_dev_din   => p_out_dev_din  ,
p_in_dev_dout   => p_in_dev_dout  ,
p_out_dev_wr    => p_out_dev_wr   ,
p_out_dev_rd    => p_out_dev_rd   ,
p_in_dev_status => p_in_dev_status,
p_in_dev_irq    => p_in_dev_irq   ,
p_in_dev_opt    => p_in_dev_opt   ,
p_out_dev_opt   => p_out_dev_opt  ,

--DBG
p_out_tst       => p_out_tst,
p_in_tst        => (others => '0'), --tst_in ,

--------------------------------------
--PCIE_Rx/Tx  Port
--------------------------------------
p_in_pcie_prm => i_pcie_prm,

--Target mode
p_in_reg_adr   => i_req_prm.desc(0)(7 downto 0),
p_out_reg_dout => i_ureg_do(31 downto 0),
p_in_reg_din   => i_ureg_di(31 downto 0),
p_in_reg_wr    => i_ureg_wr,
p_in_reg_rd    => i_ureg_rd,

p_in_clk   => p_in_user_clk,
p_in_rst_n => i_rst_n
);

----------------------------------------
--
----------------------------------------
gen_cq_trdy : for i in 0 to p_out_m_axis_cq_tready'length - 1 generate begin
p_out_m_axis_cq_tready(i) <= i_m_axis_cq_tready;
end generate gen_cq_trdy;

gen_rc_trdy : for i in 0 to p_out_m_axis_rc_tready'length - 1 generate begin
p_out_m_axis_rc_tready(i) <= i_m_axis_rc_tready;
end generate gen_rc_trdy;

m_rx : pcie_rx
generic map(
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   => G_AXISTEN_IF_CQ_ALIGNMENT_MODE,
G_AXISTEN_IF_RC_ALIGNMENT_MODE   => G_AXISTEN_IF_RC_ALIGNMENT_MODE,
--G_AXISTEN_IF_RC_STRADDLE         : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC => G_AXISTEN_IF_ENABLE_RX_MSG_INTFC,
G_AXISTEN_IF_ENABLE_MSG_ROUTE    => G_AXISTEN_IF_ENABLE_MSG_ROUTE,

G_DATA_WIDTH   => G_DATA_WIDTH   ,
G_STRB_WIDTH   => CI_STRB_WIDTH  ,
G_KEEP_WIDTH   => CI_KEEP_WIDTH  ,
G_PARITY_WIDTH => CI_PARITY_WIDTH
)
port map (
--Completer Request Interface
p_in_m_axis_cq_tdata      => p_in_m_axis_cq_tdata     ,
p_in_m_axis_cq_tlast      => p_in_m_axis_cq_tlast     ,
p_in_m_axis_cq_tvalid     => p_in_m_axis_cq_tvalid    ,
p_in_m_axis_cq_tuser      => p_in_m_axis_cq_tuser     ,
p_in_m_axis_cq_tkeep      => p_in_m_axis_cq_tkeep     ,
p_in_pcie_cq_np_req_count => p_in_pcie_cq_np_req_count,
p_out_m_axis_cq_tready    => i_m_axis_cq_tready       ,
p_out_pcie_cq_np_req      => p_out_pcie_cq_np_req     ,

--Requester Completion Interface
p_in_m_axis_rc_tdata    => p_in_m_axis_rc_tdata ,
p_in_m_axis_rc_tlast    => p_in_m_axis_rc_tlast ,
p_in_m_axis_rc_tvalid   => p_in_m_axis_rc_tvalid,
p_in_m_axis_rc_tkeep    => p_in_m_axis_rc_tkeep ,
p_in_m_axis_rc_tuser    => p_in_m_axis_rc_tuser ,
p_out_m_axis_rc_tready  => i_m_axis_rc_tready   ,

--RX Message Interface
p_in_cfg_msg_received      => p_in_cfg_msg_received     ,
p_in_cfg_msg_received_type => p_in_cfg_msg_received_type,
p_in_cfg_msg_data          => p_in_cfg_msg_received_data,

--Completion
p_out_req_compl    => i_req_compl    ,
p_out_req_compl_ur => i_req_compl_ur ,
p_in_compl_done    => i_compl_done   ,

p_out_req_prm      => i_req_prm,

--p_out_req_type     => i_req_type,
--p_out_req_tc       => i_req_tc  ,
--p_out_req_attr     => i_req_attr,
--p_out_req_len      => i_req_len ,
--p_out_req_rid      => i_req_rid ,
--p_out_req_tag      => i_req_tag ,
--p_out_req_be       => i_req_be  ,
--p_out_req_addr     => i_req_addr,
--p_out_req_at       => i_req_at  ,
--
--p_out_req_des_qword0      => i_req_des_qword0     ,
--p_out_req_des_qword1      => i_req_des_qword1     ,
--p_out_req_des_tph_present => i_req_des_tph_present,
--p_out_req_des_tph_type    => i_req_des_tph_type   ,
--p_out_req_des_tph_st_tag  => i_req_des_tph_st_tag ,

--usr app
p_out_ureg_di  => i_ureg_di  ,
p_out_ureg_wrbe=> i_ureg_wrbe,
p_out_ureg_wr  => i_ureg_wr  ,
p_out_ureg_rd  => i_ureg_rd  ,

--DBG
p_out_tst => tst_rx_out,

--system
p_in_clk   => p_in_user_clk,
p_in_rst_n => i_rst_n
);


----------------------------------------
--
----------------------------------------
m_tx : pcie_tx
generic map (
G_AXISTEN_IF_RQ_ALIGNMENT_MODE => G_AXISTEN_IF_RQ_ALIGNMENT_MODE,
G_AXISTEN_IF_CC_ALIGNMENT_MODE => G_AXISTEN_IF_CC_ALIGNMENT_MODE,
G_AXISTEN_IF_ENABLE_CLIENT_TAG => G_AXISTEN_IF_ENABLE_CLIENT_TAG,
G_AXISTEN_IF_RQ_PARITY_CHECK   => G_AXISTEN_IF_RQ_PARITY_CHECK  ,
G_AXISTEN_IF_CC_PARITY_CHECK   => G_AXISTEN_IF_CC_PARITY_CHECK  ,

G_DATA_WIDTH   => G_DATA_WIDTH   ,
G_STRB_WIDTH   => CI_STRB_WIDTH  ,
G_KEEP_WIDTH   => CI_KEEP_WIDTH  ,
G_PARITY_WIDTH => CI_PARITY_WIDTH
)
port map(
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  => p_out_s_axis_cc_tdata   ,
p_out_s_axis_cc_tkeep  => p_out_s_axis_cc_tkeep   ,
p_out_s_axis_cc_tlast  => p_out_s_axis_cc_tlast   ,
p_out_s_axis_cc_tvalid => p_out_s_axis_cc_tvalid  ,
p_out_s_axis_cc_tuser  => p_out_s_axis_cc_tuser   ,
p_in_s_axis_cc_tready  => p_in_s_axis_cc_tready(0),

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  => p_out_s_axis_rq_tdata   ,
p_out_s_axis_rq_tkeep  => p_out_s_axis_rq_tkeep   ,
p_out_s_axis_rq_tlast  => p_out_s_axis_rq_tlast   ,
p_out_s_axis_rq_tvalid => p_out_s_axis_rq_tvalid  ,
p_out_s_axis_rq_tuser  => p_out_s_axis_rq_tuser   ,
p_in_s_axis_rq_tready  => p_in_s_axis_rq_tready(0),

--TX Message Interface
p_in_cfg_msg_transmit_done  => p_in_cfg_msg_transmit_done ,
p_out_cfg_msg_transmit      => p_out_cfg_msg_transmit     ,
p_out_cfg_msg_transmit_type => p_out_cfg_msg_transmit_type,
p_out_cfg_msg_transmit_data => p_out_cfg_msg_transmit_data,

--Tag availability and Flow control Information
p_in_pcie_rq_tag          => p_in_pcie_rq_tag         ,
p_in_pcie_rq_tag_vld      => p_in_pcie_rq_tag_vld     ,
p_in_pcie_tfc_nph_av      => p_in_pcie_tfc_nph_av     ,
p_in_pcie_tfc_npd_av      => p_in_pcie_tfc_npd_av     ,
p_in_pcie_tfc_np_pl_empty => p_in_pcie_tfc_np_pl_empty,
p_in_pcie_rq_seq_num      => p_in_pcie_rq_seq_num     ,
p_in_pcie_rq_seq_num_vld  => p_in_pcie_rq_seq_num_vld ,

--Cfg Flow Control Information
p_in_cfg_fc_ph   => p_in_cfg_fc_ph  ,
p_in_cfg_fc_nph  => p_in_cfg_fc_nph ,
p_in_cfg_fc_cplh => p_in_cfg_fc_cplh,
p_in_cfg_fc_pd   => p_in_cfg_fc_pd  ,
p_in_cfg_fc_npd  => p_in_cfg_fc_npd ,
p_in_cfg_fc_cpld => p_in_cfg_fc_cpld,
p_out_cfg_fc_sel => p_out_cfg_fc_sel,

--Completion
p_in_req_compl    => i_req_compl   ,
p_in_req_compl_ur => i_req_compl_ur,
p_out_compl_done  => i_compl_done  ,

p_in_req_prm      => i_req_prm,

p_in_completer_id => (others => '0'),

--usr app
p_in_ureg_do => i_ureg_do,

--DBG
p_out_tst => tst_tx_out,

--system
p_in_clk   => p_in_user_clk,
p_in_rst_n => i_rst_n
);



------------------------------------------
----
------------------------------------------
--m_irq : pcie_irq
--port map(
--user_clk => p_in_user_clk,
--reset_n  => i_rst_n,
--
----Trigger to generate interrupts (to / from Mem access Block)
--gen_leg_intr   => i_gen_leg_intr ,
--gen_msi_intr   => i_gen_msi_intr ,
--gen_msix_intr  => i_gen_msix_intr,
--interrupt_done => i_interrupt_done, --: out std_logic; --Indicates whether interrupt is done or in process
--
----Legacy Interrupt Interface
--cfg_interrupt_sent => p_in_cfg_interrupt_sent, --: in  std_logic; --Core asserts this signal when it sends out a Legacy interrupt
--cfg_interrupt_int  => p_out_cfg_interrupt_int, --: out std_logic_vector(3 downto 0); --4 Bits for INTA, INTB, INTC, INTD (assert or deassert)
--
----MSI Interrupt Interface
--cfg_interrupt_msi_enable => p_in_cfg_interrupt_msi_enable(0),
--cfg_interrupt_msi_sent   => p_in_cfg_interrupt_msi_sent     ,
--cfg_interrupt_msi_fail   => p_in_cfg_interrupt_msi_fail     ,
--cfg_interrupt_msi_int    => p_out_cfg_interrupt_msi_int     ,
--
----MSI-X Interrupt Interface
--cfg_interrupt_msix_enable  => p_in_cfg_interrupt_msix_enable  ,
--cfg_interrupt_msix_sent    => p_in_cfg_interrupt_msix_sent    ,
--cfg_interrupt_msix_fail    => p_in_cfg_interrupt_msix_fail    ,
--cfg_interrupt_msix_int     => p_out_cfg_interrupt_msix_int    ,
--cfg_interrupt_msix_address => p_out_cfg_interrupt_msix_address,
--cfg_interrupt_msix_data    => p_out_cfg_interrupt_msix_data
--);


----------------------------------------
--
----------------------------------------
i_req_completion <= i_req_compl or i_req_compl_ur;
i_completion_done <= i_compl_done;-- or i_interrupt_done;

m_pio_to_ctrl : pio_to_ctrl
port map(
clk       => p_in_user_clk,
rst_n     => i_pio_rst_n,

req_compl  => i_req_completion,
compl_done => i_completion_done,

cfg_power_state_change_interrupt => p_in_cfg_power_state_change_interrupt,
cfg_power_state_change_ack       => p_out_cfg_power_state_change_ack
);


--#############################################
--DBG
--#############################################

-- Interrupt Interface Signals
p_out_cfg_interrupt_int                 <= (others => '0');
p_out_cfg_interrupt_pending             <= (others => '0');
p_out_cfg_interrupt_msi_select          <= (others => '0');
p_out_cfg_interrupt_msi_int             <= (others => '0');
p_out_cfg_interrupt_msi_pending_status  <= (others => '0');
p_out_cfg_interrupt_msi_attr            <= (others => '0');
p_out_cfg_interrupt_msi_tph_present     <= '0';
p_out_cfg_interrupt_msi_tph_type        <= (others => '0');
p_out_cfg_interrupt_msi_tph_st_tag      <= (others => '0');
p_out_cfg_interrupt_msi_function_number <= (others => '0');
p_out_cfg_interrupt_msi_pending_status_data_enable  <= '0';
p_out_cfg_interrupt_msi_pending_status_function_num <= (others => '0');
p_out_cfg_interrupt_msix_int            <= '0';
p_out_cfg_interrupt_msix_address        <= (others => '0');
p_out_cfg_interrupt_msix_data           <= (others => '0');


----#############################################
----DBGCS
----#############################################
--gen_dbgcs_on : if strcmp(G_DBGCS, "ON") generate
--begin
--
--m_dbg_pcie : dbgcs_ila_pcie
--port map (
--clk => p_in_user_clk,
--probe0 => i_dbg_pcie
--);
--
--i_m_axis_cq_tdata(63 downto 0) <= p_in_m_axis_cq_tdata(63 downto 0);
--i_m_axis_cq_tkeep(1 downto 0)  <= p_in_m_axis_cq_tkeep(1 downto 0) ;
--i_m_axis_cq_tvalid          <= p_in_m_axis_cq_tvalid;
--i_m_axis_cq_tlast           <= p_in_m_axis_cq_tlast;
--i_m_axis_cq_tuser           <= p_in_m_axis_cq_tuser;
--
--p_out_s_axis_cc_tdata  <= i_s_axis_cc_tdata   ;
--p_out_s_axis_cc_tkeep  <= i_s_axis_cc_tkeep   ;
--p_out_s_axis_cc_tlast  <= i_s_axis_cc_tlast   ;
--p_out_s_axis_cc_tvalid <= i_s_axis_cc_tvalid  ;
--i_s_axis_cc_tready  <= p_in_s_axis_cc_tready(0);
--
--i_dbg_pcie(63 downto 0) <= i_m_axis_cq_tdata(63 downto 0);
--i_dbg_pcie(65 downto 64) <= i_m_axis_cq_tkeep(1 downto 0);
--i_dbg_pcie(66) <= i_m_axis_cq_tvalid;
--i_dbg_pcie(67) <= i_m_axis_cq_tlast;
--i_dbg_pcie(68) <= i_m_axis_cq_tready;
--
--i_dbg_pcie(70 downto 69) <= tst_rx_out(1 downto 0);--i_rx_fsm;
--i_dbg_pcie(72 downto 71) <= tst_tx_out(1 downto 0);--i_tx_fsm;
--
--i_dbg_pcie(73)             <= i_s_axis_cc_tlast;          --s_axis_cc_tlast ;
--i_dbg_pcie(74)             <= i_s_axis_cc_tvalid;          --s_axis_cc_tvalid;
--i_dbg_pcie(138 downto 75)  <= i_s_axis_cc_tdata;--s_axis_cc_tdata
--i_dbg_pcie(140 downto 139) <= i_s_axis_cc_tkeep; --s_axis_cc_tkeep(1 downto 0);
--
--i_dbg_pcie(141) <= i_req_compl   ;
--i_dbg_pcie(142) <= i_req_compl_ur;
--i_dbg_pcie(143) <= i_compl_done  ;
--
--i_dbg_pcie(144) <= i_ureg_wr;
--i_dbg_pcie(145) <= i_ureg_rd;
--i_dbg_pcie(153 downto 146) <= i_req_addr(7 downto 0);
--
--i_dbg_pcie(161 downto 154) <= p_in_cfg_function_status(7 downto 0);
--i_dbg_pcie(162) <= p_in_user_lnk_up;
--
--i_dbg_pcie(163) <= i_s_axis_cc_tready;
--i_dbg_pcie(164) <= i_m_axis_cq_tready;
--i_dbg_pcie(165) <= i_m_axis_cq_tuser(40); --i_sop
--
--i_dbg_pcie(199 downto 166) <= (others => '0');
--
--end generate gen_dbgcs_on;


end architecture struct;


