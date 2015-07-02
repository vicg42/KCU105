-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 02.07.2015 10:07:56
-- Module Name : pcie_main.vhd
--
-- Description : core PCI-Express (from core_gen) + manage of core
--               (PCI-experss core AXI bus contert to TRN bus)
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.prj_def.all;
use work.prj_cfg.all;
use work.vicg_common_pkg.all;

entity pcie_main is
generic(
G_PCIE_LINK_WIDTH : integer := 1;
G_PCIE_RST_SEL    : integer := 1;
G_DBG : string := "OFF"
);
port(
--------------------------------------------------------
--USR Port
--------------------------------------------------------
p_out_hclk           : out   std_logic;
p_out_gctrl          : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

p_out_dev_ctrl       : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din        : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout        : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr         : out   std_logic;
p_out_dev_rd         : out   std_logic;
p_in_dev_status      : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq         : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt         : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt        : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--------------------------------------------------------
--DBG
--------------------------------------------------------
p_out_usr_tst        : out   std_logic_vector(127 downto 0);
p_in_usr_tst         : in    std_logic_vector(127 downto 0);
p_in_tst             : in    std_logic_vector(31 downto 0);
p_out_tst            : out   std_logic_vector(255 downto 0);

---------------------------------------------------------
--System Port
---------------------------------------------------------
p_in_fast_simulation : in    std_logic;

p_out_pciexp_txp     : out   std_logic_vector(G_PCIE_LINK_WIDTH - 1 downto 0);
p_out_pciexp_txn     : out   std_logic_vector(G_PCIE_LINK_WIDTH - 1 downto 0);
p_in_pciexp_rxp      : in    std_logic_vector(G_PCIE_LINK_WIDTH - 1 downto 0);
p_in_pciexp_rxn      : in    std_logic_vector(G_PCIE_LINK_WIDTH - 1 downto 0);

p_in_pciexp_rst      : in    std_logic;--Active level - 0!!!

p_out_module_rdy     : out   std_logic;
p_in_gtp_refclkin    : in    std_logic;
p_out_gtp_refclkout  : out   std_logic
);
end entity pcie_main;

architecture behavioral of pcie_main is

component pcie3_core
PORT (
pci_exp_txn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_txp : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxn : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxp : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
user_clk : OUT STD_LOGIC;
user_reset : OUT STD_LOGIC;
user_lnk_up : OUT STD_LOGIC;
s_axis_rq_tdata : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_rq_tkeep : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_rq_tlast : IN  STD_LOGIC;
s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_rq_tuser : IN  STD_LOGIC_VECTOR(59 DOWNTO 0);
s_axis_rq_tvalid : IN  STD_LOGIC;
m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_rc_tlast : OUT STD_LOGIC;
m_axis_rc_tready : IN  STD_LOGIC;
m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
m_axis_rc_tvalid : OUT STD_LOGIC;
m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_cq_tlast : OUT STD_LOGIC;
m_axis_cq_tready : IN  STD_LOGIC;
m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
m_axis_cq_tvalid : OUT STD_LOGIC;
s_axis_cc_tdata : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_cc_tkeep : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_cc_tlast : IN  STD_LOGIC;
s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_cc_tuser : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
s_axis_cc_tvalid : IN  STD_LOGIC;
pcie_rq_seq_num : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
pcie_rq_seq_num_vld : OUT STD_LOGIC;
pcie_rq_tag : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
pcie_rq_tag_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_rq_tag_vld : OUT STD_LOGIC;
pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_cq_np_req : IN  STD_LOGIC;
pcie_cq_np_req_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
cfg_phy_link_down : OUT STD_LOGIC;
cfg_phy_link_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_negotiated_width : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_current_speed : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_max_payload : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_max_read_req : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_function_status : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_function_power_state : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_vf_status : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_vf_power_state : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
cfg_link_power_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_mgmt_addr : IN  STD_LOGIC_VECTOR(18 DOWNTO 0);
cfg_mgmt_write : IN  STD_LOGIC;
cfg_mgmt_write_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_mgmt_byte_enable : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_mgmt_read : IN  STD_LOGIC;
cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_mgmt_read_write_done : OUT STD_LOGIC;
cfg_mgmt_type1_cfg_reg_access : IN  STD_LOGIC;
cfg_err_cor_out : OUT STD_LOGIC;
cfg_err_nonfatal_out : OUT STD_LOGIC;
cfg_err_fatal_out : OUT STD_LOGIC;
cfg_local_error : OUT STD_LOGIC;
cfg_ltr_enable : OUT STD_LOGIC;
cfg_ltssm_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
cfg_rcb_status : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_dpa_substate_change : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_obff_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_pl_status_change : OUT STD_LOGIC;
cfg_tph_requester_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_tph_st_mode : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_vf_tph_requester_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_vf_tph_st_mode : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
cfg_msg_received : OUT STD_LOGIC;
cfg_msg_received_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_msg_received_type : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
cfg_msg_transmit : IN  STD_LOGIC;
cfg_msg_transmit_type : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_msg_transmit_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_msg_transmit_done : OUT STD_LOGIC;
cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_sel : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_per_func_status_control : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_per_func_status_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_per_function_number : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_per_function_output_request : IN  STD_LOGIC;
cfg_per_function_update_done : OUT STD_LOGIC;
cfg_dsn : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
cfg_power_state_change_ack : IN  STD_LOGIC;
cfg_power_state_change_interrupt : OUT STD_LOGIC;
cfg_err_cor_in : IN  STD_LOGIC;
cfg_err_uncor_in : IN  STD_LOGIC;
cfg_flr_in_process : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_flr_done : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_vf_flr_done : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_link_training_enable : IN  STD_LOGIC;
cfg_ext_read_received : OUT STD_LOGIC;
cfg_ext_write_received : OUT STD_LOGIC;
cfg_ext_register_number : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
cfg_ext_function_number : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ext_write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_ext_write_byte_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_ext_read_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_ext_read_data_valid : IN  STD_LOGIC;
cfg_interrupt_int : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_pending : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_sent : OUT STD_LOGIC;
cfg_interrupt_msi_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_vf_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_interrupt_msi_mmenable : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_interrupt_msi_mask_update : OUT STD_LOGIC;
cfg_interrupt_msi_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_select : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_int : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_pending_status : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_pending_status_data_enable : IN  STD_LOGIC;
cfg_interrupt_msi_pending_status_function_num : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_sent : OUT STD_LOGIC;
cfg_interrupt_msi_fail : OUT STD_LOGIC;
cfg_interrupt_msi_attr : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_interrupt_msi_tph_present : IN  STD_LOGIC;
cfg_interrupt_msi_tph_type : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_interrupt_msi_tph_st_tag : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
cfg_interrupt_msi_function_number : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_hot_reset_out : OUT STD_LOGIC;
cfg_config_space_enable : IN  STD_LOGIC;
cfg_req_pm_transition_l23_ready : IN  STD_LOGIC;
cfg_hot_reset_in : IN  STD_LOGIC;
cfg_ds_port_number : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_bus_number : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_device_number : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
cfg_ds_function_number : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_subsys_vend_id : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
sys_clk : IN  STD_LOGIC;
sys_clk_gt : IN  STD_LOGIC;
sys_reset : IN  STD_LOGIC;
pcie_perstn1_in : IN  STD_LOGIC;
pcie_perstn0_out : OUT STD_LOGIC;
pcie_perstn1_out : OUT STD_LOGIC
);
END component pcie3_core;


component  pcie_app_uscale
--generic(
--  parameter C_DATA_WIDTH = 64,          -- RX/TX interface data width
--
---- Do not override parameters below this line
--  parameter KEEP_WIDTH                                 = C_DATA_WIDTH / 32,
--  parameter TCQ                                        = 1,
--  parameter [1:0]  AXISTEN_IF_WIDTH               = (C_DATA_WIDTH == 256) ? 2'b10 : (C_DATA_WIDTH == 128) ? 2'b01 : 2'b00,
--  parameter        AXISTEN_IF_RQ_ALIGNMENT_MODE   = "FALSE",
--  parameter        AXISTEN_IF_CC_ALIGNMENT_MODE   = "FALSE",
--  parameter        AXISTEN_IF_CQ_ALIGNMENT_MODE   = "FALSE",
--  parameter        AXISTEN_IF_RC_ALIGNMENT_MODE   = "FALSE",
--  parameter        AXISTEN_IF_ENABLE_CLIENT_TAG   = 1,
--  parameter        AXISTEN_IF_RQ_PARITY_CHECK     = 0,
--  parameter        AXISTEN_IF_CC_PARITY_CHECK     = 0,
--  parameter        AXISTEN_IF_MC_RX_STRADDLE      = 0,
--  parameter        AXISTEN_IF_ENABLE_RX_MSG_INTFC = 0,
--  parameter [17:0] AXISTEN_IF_ENABLE_MSG_ROUTE    = 18'h2FFFF
--)
port (
------------------------------------
--AXI Interface
------------------------------------
s_axis_rq_tlast  : out  std_logic                                   ;
s_axis_rq_tdata  : out  std_logic_vector(C_DATA_WIDTH - 1 downto 0) ;
s_axis_rq_tuser  : out  std_logic_vector(59 downto 0)               ;
s_axis_rq_tkeep  : out  std_logic_vector(KEEP_WIDTH - 1 downto 0)   ;
s_axis_rq_tready : in   std_logic_vector(3 downto 0)                ;
s_axis_rq_tvalid : out  std_logic                                   ;

m_axis_rc_tdata  : in   std_logic_vector(C_DATA_WIDTH - 1 downto 0) ;
m_axis_rc_tuser  : in   std_logic_vector(74 downto 0)               ;
m_axis_rc_tlast  : in   std_logic                                   ;
m_axis_rc_tkeep  : in   std_logic_vector(KEEP_WIDTH - 1 downto 0)   ;
m_axis_rc_tvalid : in   std_logic                                   ;
m_axis_rc_tready : out  std_logic_vector(21 downto 0)               ;

m_axis_cq_tdata  : in   std_logic_vector(C_DATA_WIDTH - 1 downto 0) ;
m_axis_cq_tuser  : in   std_logic_vector(84 downto 0)               ;
m_axis_cq_tlast  : in   std_logic                                   ;
m_axis_cq_tkeep  : in   std_logic_vector(KEEP_WIDTH - 1 downto 0)   ;
m_axis_cq_tvalid : in   std_logic                                   ;
m_axis_cq_tready : out  std_logic_vector(21 downto 0)               ;

s_axis_cc_tdata  : out  std_logic_vector(C_DATA_WIDTH - 1 downto 0) ;
s_axis_cc_tuser  : out  std_logic_vector(32 downto 0)               ;
s_axis_cc_tlast  : out  std_logic                                   ;
s_axis_cc_tkeep  : out  std_logic_vector(KEEP_WIDTH - 1 downto 0)   ;
s_axis_cc_tvalid : out  std_logic                                   ;
s_axis_cc_tready : in   std_logic_vector(3 downto 0)                ;

pcie_tfc_nph_av  : in   std_logic_vector(1 downto 0)                ;
pcie_tfc_npd_av  : in   std_logic_vector(1 downto 0)                ;

------------------------------------
--Configuration (CFG) Interface
------------------------------------
pcie_rq_seq_num      : in   std_logic_vector(3 downto 0)            ;
pcie_rq_seq_num_vld  : in   std_logic                               ;
pcie_rq_tag          : in   std_logic_vector(5 downto 0)            ;
pcie_rq_tag_vld      : in   std_logic                               ;
pcie_cq_np_req       : out  std_logic                               ;
pcie_cq_np_req_count : in   std_logic_vector(5 downto 0)            ;

------------------------------------
-- EP and RP
------------------------------------
cfg_phy_link_down        : in   std_logic                           ;
cfg_negotiated_width     : in   std_logic_vector(3 downto 0)        ;
cfg_current_speed        : in   std_logic_vector(2 downto 0)        ;
cfg_max_payload          : in   std_logic_vector(2 downto 0)        ;
cfg_max_read_req         : in   std_logic_vector(2 downto 0)        ;
cfg_function_status      : in   std_logic_vector(7 downto 0)        ;
cfg_function_power_state : in   std_logic_vector(5 downto 0)        ;
cfg_vf_status            : in   std_logic_vector(11 downto 0)       ;
cfg_vf_power_state       : in   std_logic_vector(17 downto 0)       ;
cfg_link_power_state     : in   std_logic_vector( 1 downto 0)       ;

-- Error Reporting Interface
cfg_err_cor_out       : in   std_logic                              ;
cfg_err_nonfatal_out  : in   std_logic                              ;
cfg_err_fatal_out     : in   std_logic                              ;
--cfg_local_error       : in   std_logic                            ;

cfg_ltr_enable              : in   std_logic                        ;
cfg_ltssm_state             : in   std_logic_vector(5 downto 0)     ;
cfg_rcb_status              : in   std_logic_vector(1 downto 0)     ;
cfg_dpa_substate_change     : in   std_logic_vector(1 downto 0)     ;
cfg_obff_enable             : in   std_logic_vector(1 downto 0)     ;
cfg_pl_status_change        : in   std_logic                        ;
                                                                    ;
cfg_tph_requester_enable    : in   std_logic_vector(1 downto 0)     ;
cfg_tph_st_mode             : in   std_logic_vector(5 downto 0)     ;
cfg_vf_tph_requester_enable : in   std_logic_vector(5 downto 0)     ;
cfg_vf_tph_st_mode          : in   std_logic_vector(17 downto 0)    ;

-- Management Interface
cfg_mgmt_addr                   : out  std_logic_vector(18 downto 0);
cfg_mgmt_write                  : out  std_logic                    ;
cfg_mgmt_write_data             : out  std_logic_vector(31 downto 0);
cfg_mgmt_byte_enable            : out  std_logic_vector( 3 downto 0);
cfg_mgmt_read                   : out  std_logic                    ;
cfg_mgmt_read_data              : in   std_logic_vector(31 downto 0);
cfg_mgmt_read_write_done        : in   std_logic                    ;
cfg_mgmt_type1_cfg_reg_access   : out  std_logic                    ;
cfg_msg_received                : in   std_logic                    ;
cfg_msg_received_data           : in   std_logic_vector(7 downto 0) ;
cfg_msg_received_type           : in   std_logic_vector(4 downto 0) ;
cfg_msg_transmit                : out  std_logic                    ;
cfg_msg_transmit_type           : out  std_logic_vector( 2 downto 0);
cfg_msg_transmit_data           : out  std_logic_vector(31 downto 0);
cfg_msg_transmit_done           : in   std_logic                    ;
cfg_fc_ph                       : in   std_logic_vector( 7 downto 0);
cfg_fc_pd                       : in   std_logic_vector(11 downto 0);
cfg_fc_nph                      : in   std_logic_vector( 7 downto 0);
cfg_fc_npd                      : in   std_logic_vector(11 downto 0);
cfg_fc_cplh                     : in   std_logic_vector( 7 downto 0);
cfg_fc_cpld                     : in   std_logic_vector(11 downto 0);
cfg_fc_sel                      : out  std_logic_vector( 2 downto 0);
cfg_per_func_status_control     : out  std_logic_vector( 2 downto 0);
cfg_per_func_status_data        : in   std_logic_vector(15 downto 0);
cfg_per_function_number         : out  std_logic_vector( 3 downto 0);
cfg_per_function_output_request : out  std_logic
cfg_per_function_update_done    : in   std_logic

cfg_dsn                          : out  std_logic_vector(63 downto 0) ;
cfg_power_state_change_ack       : out  std_logic                     ;
cfg_power_state_change_interrupt : in   std_logic                     ;
cfg_err_cor_in                   : out  std_logic                     ;
cfg_err_uncor_in                 : out  std_logic                     ;

cfg_flr_in_process               : in   std_logic_vector(1 downto 0)  ;
cfg_flr_done                     : out  std_logic_vector(1 downto 0)  ;
cfg_vf_flr_in_process            : in   std_logic_vector(5 downto 0)  ;
cfg_vf_flr_done                  : out  std_logic_vector(5 downto 0)  ;

cfg_link_training_enable         : out  std_logic                     ;
cfg_ext_read_received            : in   std_logic                     ;
cfg_ext_write_received           : in   std_logic                     ;
cfg_ext_register_number          : in   std_logic_vector( 9 downto 0) ;
cfg_ext_function_number          : in   std_logic_vector( 7 downto 0) ;
cfg_ext_write_data               : in   std_logic_vector(31 downto 0) ;
cfg_ext_write_byte_enable        : in   std_logic_vector( 3 downto 0) ;
cfg_ext_read_data                : out  std_logic_vector(31 downto 0) ;
cfg_ext_read_data_valid          : out  std_logic                     ;

cfg_ds_port_number               : out  std_logic_vector(7 downto 0)  ;
cfg_ds_bus_number                : out  std_logic_vector(7 downto 0)  ;
cfg_ds_device_number             : out  std_logic_vector(4 downto 0)  ;
cfg_ds_function_number           : out  std_logic_vector(2 downto 0)  ;

------------------------------------
-- EP Only
------------------------------------
-- Interrupt Interface Signals
cfg_interrupt_int                 : out  std_logic_vector(3 downto 0) ;
cfg_interrupt_pending             : out  std_logic_vector(1 downto 0) ;
cfg_interrupt_sent                : in   std_logic                    ;

cfg_interrupt_msi_enable          : in   std_logic_vector(1 downto 0) ;
cfg_interrupt_msi_vf_enable       : in   std_logic_vector(5 downto 0) ;
cfg_interrupt_msi_mmenable        : in   std_logic_vector(5 downto 0) ;
cfg_interrupt_msi_mask_update     : in   std_logic                    ;
cfg_interrupt_msi_data            : in   std_logic_vector(31 downto 0);
cfg_interrupt_msi_select          : out  std_logic_vector( 3 downto 0);
cfg_interrupt_msi_int             : out  std_logic_vector(31 downto 0);
cfg_interrupt_msi_pending_status  : out  std_logic_vector(31 downto 0);
cfg_interrupt_msi_sent            : in   std_logic                    ;
cfg_interrupt_msi_fail            : in   std_logic                    ;
cfg_interrupt_msi_attr            : out  std_logic_vector(2 downto 0) ;
cfg_interrupt_msi_tph_present     : out  std_logic                    ;
cfg_interrupt_msi_tph_type        : out  std_logic_vector(1 downto 0) ;
cfg_interrupt_msi_tph_st_tag      : out  std_logic_vector(8 downto 0) ;
cfg_interrupt_msi_function_number : out  std_logic_vector(2 downto 0) ;

-- EP only
cfg_hot_reset_in                  : in   std_logic                    ;
cfg_config_space_enable           : out  std_logic                    ;
cfg_req_pm_transition_l23_ready   : out  std_logic                    ;

-- RP only
cfg_hot_reset_out                 : out  std_logic                    ;

led_out                           : out  std_logic_vector(7 downto 0) ;

user_clk                          : in   std_logic                    ;
user_reset                        : in   std_logic                    ;
user_lnk_up                       : in   std_logic                    ;
sys_rst_n                         : in   std_logic
);
end component pcie_app_uscale;



signal i_pciecore_hot_reset_out : std_logic;

signal i_sys_clk          : std_logic;
signal i_sys_clk_gt       : std_logic;

signal i_user_clk         : std_logic;
signal i_user_reset_n     : std_logic;
signal i_user_lnk_up_n    : std_logic;

signal i_s_axis_rq_tdata  : std_logic_vector(63 downto 0);
signal i_s_axis_rq_tkeep  : std_logic_vector(1 downto 0);
signal i_s_axis_rq_tlast  : std_logic;
signal i_s_axis_rq_tready : std_logic_vector(3 downto 0);
signal i_s_axis_rq_tuser  : std_logic_vector(59 downto 0);
signal i_s_axis_rq_tvalid : std_logic;

signal i_m_axis_rc_tdata  : std_logic_vector(63 downto 0);
signal i_m_axis_rc_tkeep  : std_logic_vector(1 downto 0);
signal i_m_axis_rc_tlast  : std_logic;
signal i_m_axis_rc_tready : std_logic;
signal i_m_axis_rc_tuser  : std_logic_vector(74 downto 0);
signal i_m_axis_rc_tvalid : std_logic;

signal i_m_axis_cq_tdata  : std_logic_vector(63 downto 0);
signal i_m_axis_cq_tkeep  : std_logic_vector(1 downto 0);
signal i_m_axis_cq_tlast  : std_logic;
signal i_m_axis_cq_tready : std_logic;
signal i_m_axis_cq_tuser  : std_logic_vector(84 downto 0);
signal i_m_axis_cq_tvalid : std_logic;

signal i_s_axis_cc_tdata  : std_logic_vector(63 downto 0);
signal i_s_axis_cc_tkeep  : std_logic_vector(1 downto 0);
signal i_s_axis_cc_tlast  : std_logic;
signal i_s_axis_cc_tready : std_logic_vector(3 downto 0);
signal i_s_axis_cc_tuser  : std_logic_vector(32 downto 0);
signal i_s_axis_cc_tvalid : std_logic;




begin --architecture behavioral

m_refclk_ibuf : IBUFDS_GTE3
port map (
I     => sys_clk_p,
IB    => sys_clk_n,
ODIV2 => i_sys_clk,
CEB   => '0',
O     => i_sys_clk_gt
);


m_core : pcie3_core
port map(
pci_exp_txn => p_out_pciexp_txn,--: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_txp => p_out_pciexp_txp,--: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxn => p_in_pciexp_rxn ,--: IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxp => p_in_pciexp_rxp ,--: IN  STD_LOGIC_VECTOR(0 DOWNTO 0);

user_clk         => i_user_clk     ,--: OUT STD_LOGIC;
user_reset       => i_user_reset_n ,--: OUT STD_LOGIC;
user_lnk_up      => i_user_lnk_up_n,--: OUT STD_LOGIC;

s_axis_rq_tdata  => i_s_axis_rq_tdata ,--: IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_rq_tkeep  => i_s_axis_rq_tkeep ,--: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_rq_tlast  => i_s_axis_rq_tlast ,--: IN  STD_LOGIC;
s_axis_rq_tready => i_s_axis_rq_tready,--: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_rq_tuser  => i_s_axis_rq_tuser ,--: IN  STD_LOGIC_VECTOR(59 DOWNTO 0);
s_axis_rq_tvalid => i_s_axis_rq_tvalid,--: IN  STD_LOGIC;

m_axis_rc_tdata  => i_m_axis_rc_tdata ,--: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_rc_tkeep  => i_m_axis_rc_tkeep ,--: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_rc_tlast  => i_m_axis_rc_tlast ,--: OUT STD_LOGIC;
m_axis_rc_tready => i_m_axis_rc_tready,--: IN  STD_LOGIC;
m_axis_rc_tuser  => i_m_axis_rc_tuser ,--: OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
m_axis_rc_tvalid => i_m_axis_rc_tvalid,--: OUT STD_LOGIC;

m_axis_cq_tdata  => i_m_axis_cq_tdata ,--: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_cq_tkeep  => i_m_axis_cq_tkeep ,--: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_cq_tlast  => i_m_axis_cq_tlast ,--: OUT STD_LOGIC;
m_axis_cq_tready => i_m_axis_cq_tready,--: IN  STD_LOGIC;
m_axis_cq_tuser  => i_m_axis_cq_tuser ,--: OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
m_axis_cq_tvalid => i_m_axis_cq_tvalid,--: OUT STD_LOGIC;

s_axis_cc_tdata  => i_s_axis_cc_tdata ,--: IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_cc_tkeep  => i_s_axis_cc_tkeep ,--: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_cc_tlast  => i_s_axis_cc_tlast ,--: IN  STD_LOGIC;
s_axis_cc_tready => i_s_axis_cc_tready,--: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_cc_tuser  => i_s_axis_cc_tuser ,--: IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
s_axis_cc_tvalid => i_s_axis_cc_tvalid,--: IN  STD_LOGIC;

pcie_rq_seq_num      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
pcie_rq_seq_num_vld  : OUT STD_LOGIC;
pcie_rq_tag          : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
pcie_rq_tag_av       : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_rq_tag_vld      : OUT STD_LOGIC;
pcie_tfc_nph_av      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_tfc_npd_av      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
pcie_cq_np_req       : IN  STD_LOGIC;
pcie_cq_np_req_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);

cfg_phy_link_down        : OUT STD_LOGIC;
cfg_phy_link_status      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_negotiated_width     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_current_speed        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_max_payload          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_max_read_req         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_function_status      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_function_power_state : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_vf_status            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_vf_power_state       : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
cfg_link_power_state     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

cfg_mgmt_addr                 : IN  STD_LOGIC_VECTOR(18 DOWNTO 0);
cfg_mgmt_write                : IN  STD_LOGIC;
cfg_mgmt_write_data           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_mgmt_byte_enable          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_mgmt_read                 : IN  STD_LOGIC;
cfg_mgmt_read_data            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_mgmt_read_write_done      : OUT STD_LOGIC;
cfg_mgmt_type1_cfg_reg_access : IN  STD_LOGIC;

cfg_err_cor_out             : OUT STD_LOGIC;
cfg_err_nonfatal_out        : OUT STD_LOGIC;
cfg_err_fatal_out           : OUT STD_LOGIC;
cfg_local_error             : OUT STD_LOGIC;
cfg_ltr_enable              : OUT STD_LOGIC;
cfg_ltssm_state             : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
cfg_rcb_status              : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_dpa_substate_change     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_obff_enable             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_pl_status_change        : OUT STD_LOGIC;
cfg_tph_requester_enable    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_tph_st_mode             : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_vf_tph_requester_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_vf_tph_st_mode          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);

cfg_msg_received      : OUT STD_LOGIC;
cfg_msg_received_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_msg_received_type : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
cfg_msg_transmit      : IN  STD_LOGIC;
cfg_msg_transmit_type : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_msg_transmit_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_msg_transmit_done : OUT STD_LOGIC;

cfg_fc_ph   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_pd   : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_nph  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_npd  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_fc_sel  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

cfg_per_func_status_control      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_per_func_status_data         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
cfg_per_function_number          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_per_function_output_request  : IN  STD_LOGIC;
cfg_per_function_update_done     : OUT STD_LOGIC;

cfg_dsn                          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
cfg_power_state_change_ack       : IN  STD_LOGIC;
cfg_power_state_change_interrupt : OUT STD_LOGIC;
cfg_err_cor_in                   : IN  STD_LOGIC;
cfg_err_uncor_in                 : IN  STD_LOGIC;
cfg_flr_in_process               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_flr_done                     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_vf_flr_in_process            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_vf_flr_done                  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_link_training_enable         : IN  STD_LOGIC;
cfg_ext_read_received            : OUT STD_LOGIC;
cfg_ext_write_received           : OUT STD_LOGIC;
cfg_ext_register_number          : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
cfg_ext_function_number          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ext_write_data               : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_ext_write_byte_enable        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_ext_read_data                : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_ext_read_data_valid          : IN  STD_LOGIC;

cfg_interrupt_int                : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_pending            : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_sent               : OUT STD_LOGIC;
cfg_interrupt_msi_enable         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_vf_enable      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_interrupt_msi_mmenable       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
cfg_interrupt_msi_mask_update    : OUT STD_LOGIC;
cfg_interrupt_msi_data           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_select         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_int            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_pending_status              : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
cfg_interrupt_msi_pending_status_data_enable  : IN  STD_LOGIC;
cfg_interrupt_msi_pending_status_function_num : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
cfg_interrupt_msi_sent            : OUT STD_LOGIC;
cfg_interrupt_msi_fail            : OUT STD_LOGIC;
cfg_interrupt_msi_attr            : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_interrupt_msi_tph_present     : IN  STD_LOGIC;
cfg_interrupt_msi_tph_type        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
cfg_interrupt_msi_tph_st_tag      : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
cfg_interrupt_msi_function_number : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);

cfg_hot_reset_out               => i_pciecore_hot_reset_out,--: OUT STD_LOGIC;
cfg_config_space_enable         : IN  STD_LOGIC;
cfg_req_pm_transition_l23_ready : IN  STD_LOGIC;
cfg_hot_reset_in                : IN  STD_LOGIC;

cfg_ds_port_number     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_bus_number      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_device_number   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
cfg_ds_function_number : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_subsys_vend_id     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

pcie_perstn1_in  => '0' ,--: IN  STD_LOGIC;
pcie_perstn0_out => open,--: OUT STD_LOGIC;
pcie_perstn1_out => open,--: OUT STD_LOGIC

sys_clk    => i_sys_clk      ,--: IN  STD_LOGIC;
sys_clk_gt => i_sys_clk_gt   ,--: IN  STD_LOGIC;
sys_reset  => p_in_pciexp_rst --: IN  STD_LOGIC; (Cold reset + Warm reset)
);



--#############################################
--DBG
--#############################################
p_out_tst(0) <= tst_cfg_interrupt_n;
p_out_tst(1) <= tst_cfg_interrupt_rdy_n;
p_out_tst(2) <= tst_cfg_interrupt_assert_n;
p_out_tst(3) <= cfg_interrupt_msienable;


end architecture behavioral;
