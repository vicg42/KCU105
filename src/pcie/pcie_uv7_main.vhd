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

begin --architecture behavioral


m_core : pcie3_core
port map(
pci_exp_txn      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_txp      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxn      : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
pci_exp_rxp      : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);

user_clk         : OUT STD_LOGIC;
user_reset       : OUT STD_LOGIC;
user_lnk_up      : OUT STD_LOGIC;

s_axis_rq_tdata  : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_rq_tkeep  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_rq_tlast  : IN  STD_LOGIC;
s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_rq_tuser  : IN  STD_LOGIC_VECTOR(59 DOWNTO 0);
s_axis_rq_tvalid : IN  STD_LOGIC;

m_axis_rc_tdata  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_rc_tkeep  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_rc_tlast  : OUT STD_LOGIC;
m_axis_rc_tready : IN  STD_LOGIC;
m_axis_rc_tuser  : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
m_axis_rc_tvalid : OUT STD_LOGIC;

m_axis_cq_tdata  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
m_axis_cq_tkeep  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
m_axis_cq_tlast  : OUT STD_LOGIC;
m_axis_cq_tready : IN  STD_LOGIC;
m_axis_cq_tuser  : OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
m_axis_cq_tvalid : OUT STD_LOGIC;

s_axis_cc_tdata  : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
s_axis_cc_tkeep  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
s_axis_cc_tlast  : IN  STD_LOGIC;
s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
s_axis_cc_tuser  : IN  STD_LOGIC_VECTOR(32 DOWNTO 0);
s_axis_cc_tvalid : IN  STD_LOGIC;

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

cfg_hot_reset_out               : OUT STD_LOGIC;
cfg_config_space_enable         : IN  STD_LOGIC;
cfg_req_pm_transition_l23_ready : IN  STD_LOGIC;
cfg_hot_reset_in                : IN  STD_LOGIC;

cfg_ds_port_number     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_bus_number      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
cfg_ds_device_number   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
cfg_ds_function_number : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
cfg_subsys_vend_id     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

sys_clk    : IN  STD_LOGIC;
sys_clk_gt : IN  STD_LOGIC;
sys_reset  : IN  STD_LOGIC;

pcie_perstn1_in  : IN  STD_LOGIC;
pcie_perstn0_out : OUT STD_LOGIC;
pcie_perstn1_out : OUT STD_LOGIC
);



--#############################################
--DBG
--#############################################
p_out_tst(0) <= tst_cfg_interrupt_n;
p_out_tst(1) <= tst_cfg_interrupt_rdy_n;
p_out_tst(2) <= tst_cfg_interrupt_assert_n;
p_out_tst(3) <= cfg_interrupt_msienable;


end architecture behavioral;
