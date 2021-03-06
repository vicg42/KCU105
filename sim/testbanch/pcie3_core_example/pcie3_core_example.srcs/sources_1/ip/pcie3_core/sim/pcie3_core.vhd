-- (c) Copyright 1995-2015 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:pcie3_ultrascale:4.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pcie3_core IS
  PORT (
    pci_exp_txn : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    pci_exp_txp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    pci_exp_rxn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    pci_exp_rxp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    user_clk : OUT STD_LOGIC;
    user_reset : OUT STD_LOGIC;
    user_lnk_up : OUT STD_LOGIC;
    s_axis_rq_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s_axis_rq_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_rq_tlast : IN STD_LOGIC;
    s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axis_rq_tuser : IN STD_LOGIC_VECTOR(59 DOWNTO 0);
    s_axis_rq_tvalid : IN STD_LOGIC;
    m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_rc_tlast : OUT STD_LOGIC;
    m_axis_rc_tready : IN STD_LOGIC;
    m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
    m_axis_rc_tvalid : OUT STD_LOGIC;
    m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_cq_tlast : OUT STD_LOGIC;
    m_axis_cq_tready : IN STD_LOGIC;
    m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
    m_axis_cq_tvalid : OUT STD_LOGIC;
    s_axis_cc_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s_axis_cc_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_cc_tlast : IN STD_LOGIC;
    s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axis_cc_tuser : IN STD_LOGIC_VECTOR(32 DOWNTO 0);
    s_axis_cc_tvalid : IN STD_LOGIC;
    pcie_rq_seq_num : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    pcie_rq_seq_num_vld : OUT STD_LOGIC;
    pcie_rq_tag : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    pcie_rq_tag_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    pcie_rq_tag_vld : OUT STD_LOGIC;
    pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    pcie_cq_np_req : IN STD_LOGIC;
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
    cfg_mgmt_addr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    cfg_mgmt_write : IN STD_LOGIC;
    cfg_mgmt_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_mgmt_byte_enable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_mgmt_read : IN STD_LOGIC;
    cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_mgmt_read_write_done : OUT STD_LOGIC;
    cfg_mgmt_type1_cfg_reg_access : IN STD_LOGIC;
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
    cfg_msg_transmit : IN STD_LOGIC;
    cfg_msg_transmit_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_msg_transmit_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_msg_transmit_done : OUT STD_LOGIC;
    cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    cfg_fc_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_per_func_status_control : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_per_func_status_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    cfg_per_function_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_per_function_output_request : IN STD_LOGIC;
    cfg_per_function_update_done : OUT STD_LOGIC;
    cfg_dsn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    cfg_power_state_change_ack : IN STD_LOGIC;
    cfg_power_state_change_interrupt : OUT STD_LOGIC;
    cfg_err_cor_in : IN STD_LOGIC;
    cfg_err_uncor_in : IN STD_LOGIC;
    cfg_flr_in_process : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_flr_done : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_vf_flr_done : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_link_training_enable : IN STD_LOGIC;
    cfg_ext_read_received : OUT STD_LOGIC;
    cfg_ext_write_received : OUT STD_LOGIC;
    cfg_ext_register_number : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    cfg_ext_function_number : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_ext_write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_ext_write_byte_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_ext_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_ext_read_data_valid : IN STD_LOGIC;
    cfg_interrupt_int : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_interrupt_pending : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_interrupt_sent : OUT STD_LOGIC;
    cfg_interrupt_msi_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_interrupt_msi_vf_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_interrupt_msi_mmenable : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    cfg_interrupt_msi_mask_update : OUT STD_LOGIC;
    cfg_interrupt_msi_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_interrupt_msi_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_interrupt_msi_int : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_interrupt_msi_pending_status : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_interrupt_msi_pending_status_data_enable : IN STD_LOGIC;
    cfg_interrupt_msi_pending_status_function_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_interrupt_msi_sent : OUT STD_LOGIC;
    cfg_interrupt_msi_fail : OUT STD_LOGIC;
    cfg_interrupt_msi_attr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_interrupt_msi_tph_present : IN STD_LOGIC;
    cfg_interrupt_msi_tph_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_interrupt_msi_tph_st_tag : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    cfg_interrupt_msi_function_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_hot_reset_out : OUT STD_LOGIC;
    cfg_config_space_enable : IN STD_LOGIC;
    cfg_req_pm_transition_l23_ready : IN STD_LOGIC;
    cfg_hot_reset_in : IN STD_LOGIC;
    cfg_ds_port_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_ds_bus_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_ds_device_number : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    cfg_ds_function_number : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_subsys_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    sys_clk : IN STD_LOGIC;
    sys_clk_gt : IN STD_LOGIC;
    sys_reset : IN STD_LOGIC;
    pcie_perstn1_in : IN STD_LOGIC;
    pcie_perstn0_out : OUT STD_LOGIC;
    pcie_perstn1_out : OUT STD_LOGIC;
    int_qpll1lock_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    int_qpll1outrefclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    int_qpll1outclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END pcie3_core;

ARCHITECTURE pcie3_core_arch OF pcie3_core IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF pcie3_core_arch: ARCHITECTURE IS "yes";

  COMPONENT pcie3_core_pcie3_uscale_core_top IS
    GENERIC (
      PL_LINK_CAP_MAX_LINK_SPEED : INTEGER;
      PL_LINK_CAP_MAX_LINK_WIDTH : INTEGER;
      USER_CLK_FREQ : INTEGER;
      CORE_CLK_FREQ : INTEGER;
      PLL_TYPE : INTEGER;
      PF0_LINK_CAP_ASPM_SUPPORT : INTEGER;
      C_DATA_WIDTH : INTEGER;
      REF_CLK_FREQ : INTEGER;
      PCIE_LINK_SPEED : INTEGER;
      KEEP_WIDTH : INTEGER;
      ARI_CAP_ENABLE : STRING;
      PF0_ARI_CAP_NEXT_FUNC : STD_LOGIC_VECTOR;
      AXISTEN_IF_CC_ALIGNMENT_MODE : STRING;
      AXISTEN_IF_CQ_ALIGNMENT_MODE : STRING;
      AXISTEN_IF_RC_ALIGNMENT_MODE : STRING;
      AXISTEN_IF_RC_STRADDLE : STRING;
      AXISTEN_IF_RQ_ALIGNMENT_MODE : STRING;
      PF0_AER_CAP_ECRC_CHECK_CAPABLE : STRING;
      PF0_AER_CAP_ECRC_GEN_CAPABLE : STRING;
      PF0_AER_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF0_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF1_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF2_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF3_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF4_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF5_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_BAR0_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR0_CONTROL : STD_LOGIC_VECTOR;
      PF0_BAR1_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR1_CONTROL : STD_LOGIC_VECTOR;
      PF0_BAR2_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR2_CONTROL : STD_LOGIC_VECTOR;
      PF0_BAR3_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR3_CONTROL : STD_LOGIC_VECTOR;
      PF0_BAR4_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR4_CONTROL : STD_LOGIC_VECTOR;
      PF0_BAR5_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_BAR5_CONTROL : STD_LOGIC_VECTOR;
      PF0_CAPABILITY_POINTER : STD_LOGIC_VECTOR;
      PF0_CLASS_CODE : STD_LOGIC_VECTOR;
      PF0_VENDOR_ID : STD_LOGIC_VECTOR;
      PF0_DEVICE_ID : STD_LOGIC_VECTOR;
      PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT : STRING;
      PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT : STRING;
      PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT : STRING;
      PF0_DEV_CAP2_LTR_SUPPORT : STRING;
      PF0_DEV_CAP2_OBFF_SUPPORT : STD_LOGIC_VECTOR;
      PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT : STRING;
      PF0_DEV_CAP_EXT_TAG_SUPPORTED : STRING;
      PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : STRING;
      PF0_DEV_CAP_MAX_PAYLOAD_SIZE : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : STD_LOGIC_VECTOR;
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : STD_LOGIC_VECTOR;
      PF0_DSN_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_EXPANSION_ROM_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_EXPANSION_ROM_ENABLE : STRING;
      PF0_INTERRUPT_PIN : STD_LOGIC_VECTOR;
      PF0_LINK_STATUS_SLOT_CLOCK_CONFIG : STRING;
      PF0_LTR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_MSIX_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_MSIX_CAP_PBA_BIR : INTEGER;
      PF0_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      PF0_MSIX_CAP_TABLE_BIR : INTEGER;
      PF0_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      PF0_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      PF0_MSI_CAP_MULTIMSGCAP : INTEGER;
      PF0_MSI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_PB_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_PM_CAP_PMESUPPORT_D0 : STRING;
      PF0_PM_CAP_PMESUPPORT_D1 : STRING;
      PF0_PM_CAP_PMESUPPORT_D3HOT : STRING;
      PF0_PM_CAP_SUPP_D1_STATE : STRING;
      PF0_RBAR_CAP_ENABLE : STRING;
      PF0_RBAR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_RBAR_CAP_SIZE0 : STD_LOGIC_VECTOR;
      PF0_RBAR_CAP_SIZE1 : STD_LOGIC_VECTOR;
      PF0_RBAR_CAP_SIZE2 : STD_LOGIC_VECTOR;
      PF1_RBAR_CAP_SIZE0 : STD_LOGIC_VECTOR;
      PF1_RBAR_CAP_SIZE1 : STD_LOGIC_VECTOR;
      PF1_RBAR_CAP_SIZE2 : STD_LOGIC_VECTOR;
      PF0_REVISION_ID : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR0_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR0_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR1_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR1_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR2_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR2_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR3_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR3_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR4_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR4_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR5_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_BAR5_CONTROL : STD_LOGIC_VECTOR;
      PF0_SRIOV_CAP_INITIAL_VF : STD_LOGIC_VECTOR;
      PF0_SRIOV_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_SRIOV_CAP_TOTAL_VF : STD_LOGIC_VECTOR;
      PF0_SRIOV_CAP_VER : STD_LOGIC_VECTOR;
      PF0_SRIOV_FIRST_VF_OFFSET : STD_LOGIC_VECTOR;
      PF0_SRIOV_FUNC_DEP_LINK : STD_LOGIC_VECTOR;
      PF0_SRIOV_SUPPORTED_PAGE_SIZE : STD_LOGIC_VECTOR;
      PF0_SRIOV_VF_DEVICE_ID : STD_LOGIC_VECTOR;
      PF0_SUBSYSTEM_VENDOR_ID : STD_LOGIC_VECTOR;
      PF0_SUBSYSTEM_ID : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_ENABLE : STRING;
      PF0_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF0_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF1_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF2_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF3_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF4_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF5_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      PF1_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      PF1_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      PF1_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      PF1_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF0_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF0_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF0_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF0_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF1_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF1_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF1_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF1_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF2_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF2_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF2_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF2_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF3_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF3_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF3_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF3_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF4_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF4_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF4_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF4_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      VF5_TPHR_CAP_ST_MODE_SEL : STD_LOGIC_VECTOR;
      VF5_TPHR_CAP_ST_TABLE_LOC : STD_LOGIC_VECTOR;
      VF5_TPHR_CAP_ST_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF5_TPHR_CAP_VER : STD_LOGIC_VECTOR;
      PF0_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      PF0_TPHR_CAP_INT_VEC_MODE : STRING;
      PF1_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      PF1_TPHR_CAP_INT_VEC_MODE : STRING;
      VF0_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF0_TPHR_CAP_INT_VEC_MODE : STRING;
      VF1_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF1_TPHR_CAP_INT_VEC_MODE : STRING;
      VF2_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF2_TPHR_CAP_INT_VEC_MODE : STRING;
      VF3_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF3_TPHR_CAP_INT_VEC_MODE : STRING;
      VF4_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF4_TPHR_CAP_INT_VEC_MODE : STRING;
      VF5_TPHR_CAP_DEV_SPECIFIC_MODE : STRING;
      VF5_TPHR_CAP_INT_VEC_MODE : STRING;
      PF0_SECONDARY_PCIE_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      MCAP_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF0_VC_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      SPARE_WORD1 : STD_LOGIC_VECTOR;
      PF1_AER_CAP_ECRC_CHECK_CAPABLE : STRING;
      PF1_AER_CAP_ECRC_GEN_CAPABLE : STRING;
      PF1_AER_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_ARI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_BAR0_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR0_CONTROL : STD_LOGIC_VECTOR;
      PF1_BAR1_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR1_CONTROL : STD_LOGIC_VECTOR;
      PF1_BAR2_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR2_CONTROL : STD_LOGIC_VECTOR;
      PF1_BAR3_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR3_CONTROL : STD_LOGIC_VECTOR;
      PF1_BAR4_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR4_CONTROL : STD_LOGIC_VECTOR;
      PF1_BAR5_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_BAR5_CONTROL : STD_LOGIC_VECTOR;
      PF1_CAPABILITY_POINTER : STD_LOGIC_VECTOR;
      PF1_CLASS_CODE : STD_LOGIC_VECTOR;
      PF1_DEVICE_ID : STD_LOGIC_VECTOR;
      PF1_DEV_CAP_MAX_PAYLOAD_SIZE : STD_LOGIC_VECTOR;
      PF1_DPA_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_DSN_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_EXPANSION_ROM_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_EXPANSION_ROM_ENABLE : STRING;
      PF1_INTERRUPT_PIN : STD_LOGIC_VECTOR;
      PF1_MSIX_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_MSIX_CAP_PBA_BIR : INTEGER;
      PF1_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      PF1_MSIX_CAP_TABLE_BIR : INTEGER;
      PF1_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      PF1_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      PF1_MSI_CAP_MULTIMSGCAP : INTEGER;
      PF1_MSI_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_PB_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_RBAR_CAP_ENABLE : STRING;
      PF1_RBAR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_REVISION_ID : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR0_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR0_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR1_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR1_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR2_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR2_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR3_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR3_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR4_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR4_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR5_APERTURE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_BAR5_CONTROL : STD_LOGIC_VECTOR;
      PF1_SRIOV_CAP_INITIAL_VF : STD_LOGIC_VECTOR;
      PF1_SRIOV_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PF1_SRIOV_CAP_TOTAL_VF : STD_LOGIC_VECTOR;
      PF1_SRIOV_CAP_VER : STD_LOGIC_VECTOR;
      PF1_SRIOV_FIRST_VF_OFFSET : STD_LOGIC_VECTOR;
      PF1_SRIOV_FUNC_DEP_LINK : STD_LOGIC_VECTOR;
      PF1_SRIOV_SUPPORTED_PAGE_SIZE : STD_LOGIC_VECTOR;
      PF1_SRIOV_VF_DEVICE_ID : STD_LOGIC_VECTOR;
      PF1_SUBSYSTEM_ID : STD_LOGIC_VECTOR;
      PF1_TPHR_CAP_ENABLE : STRING;
      PF1_TPHR_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      PL_UPSTREAM_FACING : STRING;
      en_msi_per_vec_masking : STRING;
      SRIOV_CAP_ENABLE : STRING;
      TL_CREDITS_CD : STD_LOGIC_VECTOR;
      TL_CREDITS_CH : STD_LOGIC_VECTOR;
      TL_CREDITS_NPD : STD_LOGIC_VECTOR;
      TL_CREDITS_NPH : STD_LOGIC_VECTOR;
      TL_CREDITS_PD : STD_LOGIC_VECTOR;
      TL_CREDITS_PH : STD_LOGIC_VECTOR;
      TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE : STRING;
      TL_LEGACY_MODE_ENABLE : STRING;
      TL_PF_ENABLE_REG : STD_LOGIC_VECTOR;
      VF0_CAPABILITY_POINTER : STD_LOGIC_VECTOR;
      VF0_MSIX_CAP_PBA_BIR : INTEGER;
      VF0_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF0_MSIX_CAP_TABLE_BIR : INTEGER;
      VF0_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF0_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF0_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF0_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF1_MSIX_CAP_PBA_BIR : INTEGER;
      VF1_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF1_MSIX_CAP_TABLE_BIR : INTEGER;
      VF1_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF1_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF1_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF1_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF2_MSIX_CAP_PBA_BIR : INTEGER;
      VF2_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF2_MSIX_CAP_TABLE_BIR : INTEGER;
      VF2_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF2_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF2_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF2_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF3_MSIX_CAP_PBA_BIR : INTEGER;
      VF3_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF3_MSIX_CAP_TABLE_BIR : INTEGER;
      VF3_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF3_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF3_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF3_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF4_MSIX_CAP_PBA_BIR : INTEGER;
      VF4_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF4_MSIX_CAP_TABLE_BIR : INTEGER;
      VF4_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF4_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF4_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF4_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      VF5_MSIX_CAP_PBA_BIR : INTEGER;
      VF5_MSIX_CAP_PBA_OFFSET : STD_LOGIC_VECTOR;
      VF5_MSIX_CAP_TABLE_BIR : INTEGER;
      VF5_MSIX_CAP_TABLE_OFFSET : STD_LOGIC_VECTOR;
      VF5_MSIX_CAP_TABLE_SIZE : STD_LOGIC_VECTOR;
      VF5_MSI_CAP_MULTIMSGCAP : INTEGER;
      VF5_PM_CAP_NEXTPTR : STD_LOGIC_VECTOR;
      COMPLETION_SPACE : STRING;
      gen_x0y0_xdc : INTEGER;
      gen_x0y1_xdc : INTEGER;
      gen_x0y2_xdc : INTEGER;
      gen_x0y3_xdc : INTEGER;
      gen_x0y4_xdc : INTEGER;
      gen_x0y5_xdc : INTEGER;
      xlnx_ref_board : INTEGER;
      pcie_blk_locn : INTEGER;
      PIPE_SIM : STRING;
      AXISTEN_IF_ENABLE_CLIENT_TAG : STRING;
      PCIE_USE_MODE : STRING;
      PCIE_FAST_CONFIG : STRING;
      EXT_STARTUP_PRIMITIVE : STRING;
      PL_INTERFACE : STRING;
      PCIE_CONFIGURATION : STRING;
      CFG_STATUS_IF : STRING;
      TX_FC_IF : STRING;
      CFG_EXT_IF : STRING;
      CFG_FC_IF : STRING;
      PER_FUNC_STATUS_IF : STRING;
      CFG_MGMT_IF : STRING;
      RCV_MSG_IF : STRING;
      CFG_TX_MSG_IF : STRING;
      CFG_CTL_IF : STRING;
      MSI_EN : STRING;
      MSIX_EN : STRING;
      PCIE3_DRP : STRING;
      DIS_GT_WIZARD : STRING;
      TRANSCEIVER_CTRL_STATUS_PORTS : STRING;
      SHARED_LOGIC : INTEGER;
      DEDICATE_PERST : STRING;
      SYS_RESET_POLARITY : INTEGER;
      MCAP_ENABLEMENT : STRING;
      PHY_LP_TXPRESET : INTEGER;
      EXT_CH_GT_DRP : STRING;
      EN_GT_SELECTION : STRING;
      SELECT_QUAD : STRING;
      silicon_revision : STRING;
      DEV_PORT_TYPE : INTEGER
    );
    PORT (
      pci_exp_txn : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      pci_exp_txp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      pci_exp_rxn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      pci_exp_rxp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      user_clk : OUT STD_LOGIC;
      user_reset : OUT STD_LOGIC;
      user_lnk_up : OUT STD_LOGIC;
      s_axis_rq_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
      s_axis_rq_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axis_rq_tlast : IN STD_LOGIC;
      s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axis_rq_tuser : IN STD_LOGIC_VECTOR(59 DOWNTO 0);
      s_axis_rq_tvalid : IN STD_LOGIC;
      m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
      m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axis_rc_tlast : OUT STD_LOGIC;
      m_axis_rc_tready : IN STD_LOGIC;
      m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
      m_axis_rc_tvalid : OUT STD_LOGIC;
      m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
      m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axis_cq_tlast : OUT STD_LOGIC;
      m_axis_cq_tready : IN STD_LOGIC;
      m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
      m_axis_cq_tvalid : OUT STD_LOGIC;
      s_axis_cc_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
      s_axis_cc_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axis_cc_tlast : IN STD_LOGIC;
      s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axis_cc_tuser : IN STD_LOGIC_VECTOR(32 DOWNTO 0);
      s_axis_cc_tvalid : IN STD_LOGIC;
      pcie_rq_seq_num : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      pcie_rq_seq_num_vld : OUT STD_LOGIC;
      pcie_rq_tag : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      pcie_rq_tag_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      pcie_rq_tag_vld : OUT STD_LOGIC;
      pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      pcie_cq_np_req : IN STD_LOGIC;
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
      cfg_mgmt_addr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
      cfg_mgmt_write : IN STD_LOGIC;
      cfg_mgmt_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_mgmt_byte_enable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_mgmt_read : IN STD_LOGIC;
      cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_mgmt_read_write_done : OUT STD_LOGIC;
      cfg_mgmt_type1_cfg_reg_access : IN STD_LOGIC;
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
      cfg_msg_transmit : IN STD_LOGIC;
      cfg_msg_transmit_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_msg_transmit_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msg_transmit_done : OUT STD_LOGIC;
      cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_fc_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_per_func_status_control : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_per_func_status_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_per_function_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_per_function_output_request : IN STD_LOGIC;
      cfg_per_function_update_done : OUT STD_LOGIC;
      cfg_dsn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      cfg_power_state_change_ack : IN STD_LOGIC;
      cfg_power_state_change_interrupt : OUT STD_LOGIC;
      cfg_err_cor_in : IN STD_LOGIC;
      cfg_err_uncor_in : IN STD_LOGIC;
      cfg_flr_in_process : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_flr_done : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_vf_flr_done : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_link_training_enable : IN STD_LOGIC;
      cfg_ext_read_received : OUT STD_LOGIC;
      cfg_ext_write_received : OUT STD_LOGIC;
      cfg_ext_register_number : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
      cfg_ext_function_number : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_ext_write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_ext_write_byte_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_ext_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_ext_read_data_valid : IN STD_LOGIC;
      cfg_interrupt_int : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_pending : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_sent : OUT STD_LOGIC;
      cfg_interrupt_msi_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msi_vf_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_interrupt_msi_mmenable : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_interrupt_msi_mask_update : OUT STD_LOGIC;
      cfg_interrupt_msi_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_interrupt_msi_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msi_int : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_interrupt_msi_pending_status : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_interrupt_msi_pending_status_data_enable : IN STD_LOGIC;
      cfg_interrupt_msi_pending_status_function_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msi_sent : OUT STD_LOGIC;
      cfg_interrupt_msi_fail : OUT STD_LOGIC;
      cfg_interrupt_msi_attr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_interrupt_msi_tph_present : IN STD_LOGIC;
      cfg_interrupt_msi_tph_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      cfg_interrupt_msi_tph_st_tag : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
      cfg_interrupt_msi_function_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msix_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msix_mask : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cfg_interrupt_msix_vf_enable : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_interrupt_msix_vf_mask : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_interrupt_msix_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_interrupt_msix_address : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      cfg_interrupt_msix_int : IN STD_LOGIC;
      cfg_interrupt_msix_sent : OUT STD_LOGIC;
      cfg_interrupt_msix_fail : OUT STD_LOGIC;
      cfg_hot_reset_out : OUT STD_LOGIC;
      cfg_config_space_enable : IN STD_LOGIC;
      cfg_req_pm_transition_l23_ready : IN STD_LOGIC;
      cfg_hot_reset_in : IN STD_LOGIC;
      cfg_ds_port_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_ds_bus_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      cfg_ds_device_number : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      cfg_ds_function_number : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_subsys_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      drp_rdy : OUT STD_LOGIC;
      drp_do : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      drp_clk : IN STD_LOGIC;
      drp_en : IN STD_LOGIC;
      drp_we : IN STD_LOGIC;
      drp_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      drp_di : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      user_tph_stt_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      user_tph_function_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      user_tph_stt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      user_tph_stt_read_data_valid : OUT STD_LOGIC;
      user_tph_stt_read_enable : IN STD_LOGIC;
      sys_clk : IN STD_LOGIC;
      sys_clk_gt : IN STD_LOGIC;
      sys_reset : IN STD_LOGIC;
      conf_req_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      conf_req_reg_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      conf_req_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      conf_req_valid : IN STD_LOGIC;
      conf_req_ready : OUT STD_LOGIC;
      conf_resp_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      conf_resp_valid : OUT STD_LOGIC;
      mcap_design_switch : OUT STD_LOGIC;
      mcap_eos_in : IN STD_LOGIC;
      startup_cfgclk : OUT STD_LOGIC;
      startup_cfgmclk : OUT STD_LOGIC;
      startup_di : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      startup_eos : OUT STD_LOGIC;
      startup_preq : OUT STD_LOGIC;
      startup_do : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      startup_dts : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      startup_fcsbo : IN STD_LOGIC;
      startup_fcsbts : IN STD_LOGIC;
      startup_gsr : IN STD_LOGIC;
      startup_gts : IN STD_LOGIC;
      startup_keyclearb : IN STD_LOGIC;
      startup_pack : IN STD_LOGIC;
      startup_usrcclko : IN STD_LOGIC;
      startup_usrcclkts : IN STD_LOGIC;
      startup_usrdoneo : IN STD_LOGIC;
      startup_usrdonets : IN STD_LOGIC;
      cap_req : OUT STD_LOGIC;
      cap_gnt : IN STD_LOGIC;
      cap_rel : IN STD_LOGIC;
      pl_eq_reset_eieos_count : IN STD_LOGIC;
      pl_gen2_upstream_prefer_deemph : IN STD_LOGIC;
      pl_eq_in_progress : OUT STD_LOGIC;
      pl_eq_phase : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      pcie_perstn1_in : IN STD_LOGIC;
      pcie_perstn0_out : OUT STD_LOGIC;
      pcie_perstn1_out : OUT STD_LOGIC;
      ext_qpll1refclk : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      ext_qpll1rate : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      ext_qpll1pd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      ext_qpll1reset : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      ext_qpll1lock_out : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      ext_qpll1outclk_out : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      ext_qpll1outrefclk_out : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      int_qpll1lock_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      int_qpll1outrefclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      int_qpll1outclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      common_commands_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
      pipe_rx_0_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_1_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_2_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_3_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_4_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_5_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_6_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      pipe_rx_7_sigs : IN STD_LOGIC_VECTOR(83 DOWNTO 0);
      common_commands_out : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
      pipe_tx_0_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_1_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_2_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_3_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_4_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_5_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_6_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      pipe_tx_7_sigs : OUT STD_LOGIC_VECTOR(69 DOWNTO 0);
      gt_pcieuserratedone : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_loopback : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      gt_txprbsforceerr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txinhibit : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txprbssel : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      gt_rxprbssel : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      gt_rxprbscntreset : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txelecidle : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txresetdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxresetdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxpmaresetdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txphaligndone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txphinitdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_txdlysresetdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxphaligndone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxdlysresetdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxsyncdone : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_eyescandataerror : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxprbserr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_dmonitorout : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
      gt_rxcommadet : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_phystatus : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxvalid : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxcdrlock : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_pcierateidle : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_pcieuserratestart : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_gtpowergood : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_cplllock : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxoutclk : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_rxrecclkout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      gt_qpll1lock : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      gt_rxstatus : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      gt_rxbufstatus : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      gt_bufgtdiv : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
      phy_txeq_ctrl : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      phy_txeq_preset : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      phy_rst_fsm : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      phy_txeq_fsm : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      phy_rxeq_fsm : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      phy_rst_idle : OUT STD_LOGIC;
      phy_rrst_n : OUT STD_LOGIC;
      phy_prst_n : OUT STD_LOGIC;
      ext_ch_gt_drpclk : OUT STD_LOGIC;
      ext_ch_gt_drpaddr : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
      ext_ch_gt_drpen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      ext_ch_gt_drpdi : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      ext_ch_gt_drpwe : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      ext_ch_gt_drpdo : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      ext_ch_gt_drprdy : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT pcie3_core_pcie3_uscale_core_top;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF pci_exp_txn: SIGNAL IS "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt txn";
  ATTRIBUTE X_INTERFACE_INFO OF pci_exp_txp: SIGNAL IS "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt txp";
  ATTRIBUTE X_INTERFACE_INFO OF pci_exp_rxn: SIGNAL IS "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt rxn";
  ATTRIBUTE X_INTERFACE_INFO OF pci_exp_rxp: SIGNAL IS "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt rxp";
  ATTRIBUTE X_INTERFACE_INFO OF user_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 CLK.user_clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF user_reset: SIGNAL IS "xilinx.com:signal:reset:1.0 RST.user_reset RST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tkeep: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TUSER";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_rq_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_rq TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tkeep: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TUSER";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_rc_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_rc TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tkeep: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TUSER";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_cq_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis_cq TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tkeep: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tuser: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TUSER";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_cc_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 s_axis_cc TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_rq_seq_num: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_seq_num";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_rq_seq_num_vld: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_seq_num_vld";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_rq_tag: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_tag";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_rq_tag_av: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_tag_av";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_rq_tag_vld: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_tag_vld";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_tfc_nph_av: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tfc_nph_av, xilinx.com:interface:pcie3_transmit_fc:1.0 pcie3_transmit_fc nph_av";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_tfc_npd_av: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tfc_npd_av, xilinx.com:interface:pcie3_transmit_fc:1.0 pcie3_transmit_fc npd_av";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_cq_np_req: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status cq_np_req";
  ATTRIBUTE X_INTERFACE_INFO OF pcie_cq_np_req_count: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status cq_np_req_count";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_phy_link_down: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status phy_link_down";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_phy_link_status: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status phy_link_status";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_negotiated_width: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status negotiated_width";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_current_speed: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status current_speed";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_max_payload: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status max_payload";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_max_read_req: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status max_read_req";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_function_status: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status function_status";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_function_power_state: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status function_power_state";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_status: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_status";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_power_state: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_power_state";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_link_power_state: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status link_power_state";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_addr: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt ADDR";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_write: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt WRITE_EN";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_write_data: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt WRITE_DATA";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_byte_enable: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt BYTE_EN";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_read: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt READ_EN";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_read_data: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt READ_DATA";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_read_write_done: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt READ_WRITE_DONE";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_mgmt_type1_cfg_reg_access: SIGNAL IS "xilinx.com:interface:pcie_cfg_mgmt:1.0 pcie_cfg_mgmt TYPE1_CFG_REG_ACCESS";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_err_cor_out: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_cor_out";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_err_nonfatal_out: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_nonfatal_out";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_err_fatal_out: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_fatal_out";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_local_error: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control local_error";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ltr_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status ltr_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ltssm_state: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status ltssm_state";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_rcb_status: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rcb_status";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_dpa_substate_change: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status dpa_substate_change";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_obff_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status obff_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_pl_status_change: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status pl_status_change";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_tph_requester_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tph_requester_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_tph_st_mode: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tph_st_mode";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_tph_requester_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_tph_requester_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_tph_st_mode: SIGNAL IS "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_tph_st_mode";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_received: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_received_data: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd_data";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_received_type: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd_type";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_transmit: SIGNAL IS "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_transmit_type: SIGNAL IS "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_TYPE";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_transmit_data: SIGNAL IS "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_DATA";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_msg_transmit_done: SIGNAL IS "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_DONE";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_ph: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc PH";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_pd: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc PD";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_nph: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc NPH";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_npd: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc NPD";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_cplh: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc CPLH";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_cpld: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc CPLD";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_fc_sel: SIGNAL IS "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc SEL";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_per_func_status_control: SIGNAL IS "xilinx.com:interface:pcie3_per_func_status:1.0 pcie3_per_func_status STATUS_CONTROL";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_per_func_status_data: SIGNAL IS "xilinx.com:interface:pcie3_per_func_status:1.0 pcie3_per_func_status STATUS_DATA";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_per_function_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_per_function_output_request: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_output_request";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_per_function_update_done: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_update_done";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_dsn: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control dsn";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_power_state_change_ack: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control power_state_change_ack";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_power_state_change_interrupt: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control power_state_change_interrupt";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_err_cor_in: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control err_cor_in";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_err_uncor_in: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control err_uncor_in";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_flr_in_process: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control flr_in_process";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_flr_done: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control flr_done";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_flr_in_process: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control vf_flr_in_process";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_vf_flr_done: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control vf_flr_done";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_link_training_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control link_training_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_read_received: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext read_received";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_write_received: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext write_received";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_register_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext register_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_function_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext function_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_write_data: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext write_data";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_write_byte_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext write_byte_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_read_data: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext read_data";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ext_read_data_valid: SIGNAL IS "xilinx.com:interface:pcie3_cfg_ext:1.0 pcie3_cfg_ext read_data_valid";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_int: SIGNAL IS "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt INTx_VECTOR";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_pending: SIGNAL IS "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt PENDING";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_sent: SIGNAL IS "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt SENT";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_vf_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi vf_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_mmenable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi mmenable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_mask_update: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi mask_update";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_data: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi data";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_select: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi select";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_int: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi int_vector";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_pending_status: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi pending_status";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_pending_status_data_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi pending_status_data_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_pending_status_function_num: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi pending_status_function_num";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_sent: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi sent";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_fail: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi fail";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_attr: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi attr";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_tph_present: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi tph_present";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_tph_type: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi tph_type";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_tph_st_tag: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi tph_st_tag";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_interrupt_msi_function_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_msi:1.0 pcie3_cfg_msi function_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_hot_reset_out: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control hot_reset_out";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_config_space_enable: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control config_space_enable";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_req_pm_transition_l23_ready: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control req_pm_transition_l23_ready";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_hot_reset_in: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control hot_reset_in";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ds_port_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_port_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ds_bus_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_bus_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ds_device_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_device_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_ds_function_number: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_function_number";
  ATTRIBUTE X_INTERFACE_INFO OF cfg_subsys_vend_id: SIGNAL IS "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control subsys_vend_id";
  ATTRIBUTE X_INTERFACE_INFO OF sys_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 CLK.sys_clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF sys_clk_gt: SIGNAL IS "xilinx.com:signal:clock:1.0 CLK.sys_clk_gt CLK";
  ATTRIBUTE X_INTERFACE_INFO OF sys_reset: SIGNAL IS "xilinx.com:signal:reset:1.0 RST.sys_rst RST";
  ATTRIBUTE X_INTERFACE_INFO OF int_qpll1lock_out: SIGNAL IS "xilinx.com:display_pcie3_ultrascale:int_shared_logic:1.0 pcie3_us_int_shared_logic ints_qpll1lock_out";
  ATTRIBUTE X_INTERFACE_INFO OF int_qpll1outrefclk_out: SIGNAL IS "xilinx.com:display_pcie3_ultrascale:int_shared_logic:1.0 pcie3_us_int_shared_logic ints_qpll1outrefclk_ou";
  ATTRIBUTE X_INTERFACE_INFO OF int_qpll1outclk_out: SIGNAL IS "xilinx.com:display_pcie3_ultrascale:int_shared_logic:1.0 pcie3_us_int_shared_logic ints_qpll1outclk_out";
BEGIN
  U0 : pcie3_core_pcie3_uscale_core_top
    GENERIC MAP (
      PL_LINK_CAP_MAX_LINK_SPEED => 4,
      PL_LINK_CAP_MAX_LINK_WIDTH => 8,
      USER_CLK_FREQ => 3,
      CORE_CLK_FREQ => 2,
      PLL_TYPE => 2,
      PF0_LINK_CAP_ASPM_SUPPORT => 0,
      C_DATA_WIDTH => 256,
      REF_CLK_FREQ => 0,
      PCIE_LINK_SPEED => 3,
      KEEP_WIDTH => 8,
      ARI_CAP_ENABLE => "FALSE",
      PF0_ARI_CAP_NEXT_FUNC => X"00",
      AXISTEN_IF_CC_ALIGNMENT_MODE => "FALSE",
      AXISTEN_IF_CQ_ALIGNMENT_MODE => "FALSE",
      AXISTEN_IF_RC_ALIGNMENT_MODE => "FALSE",
      AXISTEN_IF_RC_STRADDLE => "FALSE",
      AXISTEN_IF_RQ_ALIGNMENT_MODE => "FALSE",
      PF0_AER_CAP_ECRC_CHECK_CAPABLE => "FALSE",
      PF0_AER_CAP_ECRC_GEN_CAPABLE => "FALSE",
      PF0_AER_CAP_NEXTPTR => X"150",
      PF0_ARI_CAP_NEXTPTR => X"000",
      VF0_ARI_CAP_NEXTPTR => X"000",
      VF1_ARI_CAP_NEXTPTR => X"000",
      VF2_ARI_CAP_NEXTPTR => X"000",
      VF3_ARI_CAP_NEXTPTR => X"000",
      VF4_ARI_CAP_NEXTPTR => X"000",
      VF5_ARI_CAP_NEXTPTR => X"000",
      PF0_BAR0_APERTURE_SIZE => X"01",
      PF0_BAR0_CONTROL => X"4",
      PF0_BAR1_APERTURE_SIZE => X"01",
      PF0_BAR1_CONTROL => X"1",
      PF0_BAR2_APERTURE_SIZE => X"00",
      PF0_BAR2_CONTROL => X"0",
      PF0_BAR3_APERTURE_SIZE => X"00",
      PF0_BAR3_CONTROL => X"0",
      PF0_BAR4_APERTURE_SIZE => X"00",
      PF0_BAR4_CONTROL => X"0",
      PF0_BAR5_APERTURE_SIZE => X"00",
      PF0_BAR5_CONTROL => X"0",
      PF0_CAPABILITY_POINTER => X"80",
      PF0_CLASS_CODE => X"058000",
      PF0_VENDOR_ID => X"0777",
      PF0_DEVICE_ID => X"8005",
      PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT => "FALSE",
      PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT => "FALSE",
      PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT => "FALSE",
      PF0_DEV_CAP2_LTR_SUPPORT => "FALSE",
      PF0_DEV_CAP2_OBFF_SUPPORT => X"0",
      PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT => "FALSE",
      PF0_DEV_CAP_EXT_TAG_SUPPORTED => "FALSE",
      PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE => "FALSE",
      PF0_DEV_CAP_MAX_PAYLOAD_SIZE => X"3",
      PF0_DPA_CAP_NEXTPTR => X"300",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 => X"00",
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 => X"00",
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 => X"00",
      PF0_DSN_CAP_NEXTPTR => X"300",
      PF0_EXPANSION_ROM_APERTURE_SIZE => X"00",
      PF0_EXPANSION_ROM_ENABLE => "FALSE",
      PF0_INTERRUPT_PIN => X"1",
      PF0_LINK_STATUS_SLOT_CLOCK_CONFIG => "TRUE",
      PF0_LTR_CAP_NEXTPTR => X"300",
      PF0_MSIX_CAP_NEXTPTR => X"00",
      PF0_MSIX_CAP_PBA_BIR => 0,
      PF0_MSIX_CAP_PBA_OFFSET => X"00000000",
      PF0_MSIX_CAP_TABLE_BIR => 0,
      PF0_MSIX_CAP_TABLE_OFFSET => X"00000000",
      PF0_MSIX_CAP_TABLE_SIZE => X"000",
      PF0_MSI_CAP_MULTIMSGCAP => 0,
      PF0_MSI_CAP_NEXTPTR => X"C0",
      PF0_PB_CAP_NEXTPTR => X"274",
      PF0_PM_CAP_NEXTPTR => X"90",
      PF0_PM_CAP_PMESUPPORT_D0 => "FALSE",
      PF0_PM_CAP_PMESUPPORT_D1 => "FALSE",
      PF0_PM_CAP_PMESUPPORT_D3HOT => "FALSE",
      PF0_PM_CAP_SUPP_D1_STATE => "FALSE",
      PF0_RBAR_CAP_ENABLE => "FALSE",
      PF0_RBAR_CAP_NEXTPTR => X"300",
      PF0_RBAR_CAP_SIZE0 => X"00000",
      PF0_RBAR_CAP_SIZE1 => X"00000",
      PF0_RBAR_CAP_SIZE2 => X"00000",
      PF1_RBAR_CAP_SIZE0 => X"00000",
      PF1_RBAR_CAP_SIZE1 => X"00000",
      PF1_RBAR_CAP_SIZE2 => X"00000",
      PF0_REVISION_ID => X"02",
      PF0_SRIOV_BAR0_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR0_CONTROL => X"0",
      PF0_SRIOV_BAR1_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR1_CONTROL => X"0",
      PF0_SRIOV_BAR2_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR2_CONTROL => X"0",
      PF0_SRIOV_BAR3_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR3_CONTROL => X"0",
      PF0_SRIOV_BAR4_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR4_CONTROL => X"0",
      PF0_SRIOV_BAR5_APERTURE_SIZE => X"00",
      PF0_SRIOV_BAR5_CONTROL => X"0",
      PF0_SRIOV_CAP_INITIAL_VF => X"0000",
      PF0_SRIOV_CAP_NEXTPTR => X"300",
      PF0_SRIOV_CAP_TOTAL_VF => X"0000",
      PF0_SRIOV_CAP_VER => X"0",
      PF0_SRIOV_FIRST_VF_OFFSET => X"0000",
      PF0_SRIOV_FUNC_DEP_LINK => X"0000",
      PF0_SRIOV_SUPPORTED_PAGE_SIZE => X"00000553",
      PF0_SRIOV_VF_DEVICE_ID => X"0000",
      PF0_SUBSYSTEM_VENDOR_ID => X"0777",
      PF0_SUBSYSTEM_ID => X"8005",
      PF0_TPHR_CAP_ENABLE => "FALSE",
      PF0_TPHR_CAP_NEXTPTR => X"300",
      VF0_TPHR_CAP_NEXTPTR => X"000",
      VF1_TPHR_CAP_NEXTPTR => X"000",
      VF2_TPHR_CAP_NEXTPTR => X"000",
      VF3_TPHR_CAP_NEXTPTR => X"000",
      VF4_TPHR_CAP_NEXTPTR => X"000",
      VF5_TPHR_CAP_NEXTPTR => X"000",
      PF0_TPHR_CAP_ST_MODE_SEL => X"0",
      PF0_TPHR_CAP_ST_TABLE_LOC => X"0",
      PF0_TPHR_CAP_ST_TABLE_SIZE => X"000",
      PF0_TPHR_CAP_VER => X"1",
      PF1_TPHR_CAP_ST_MODE_SEL => X"0",
      PF1_TPHR_CAP_ST_TABLE_LOC => X"0",
      PF1_TPHR_CAP_ST_TABLE_SIZE => X"000",
      PF1_TPHR_CAP_VER => X"1",
      VF0_TPHR_CAP_ST_MODE_SEL => X"0",
      VF0_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF0_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF0_TPHR_CAP_VER => X"1",
      VF1_TPHR_CAP_ST_MODE_SEL => X"0",
      VF1_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF1_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF1_TPHR_CAP_VER => X"1",
      VF2_TPHR_CAP_ST_MODE_SEL => X"0",
      VF2_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF2_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF2_TPHR_CAP_VER => X"1",
      VF3_TPHR_CAP_ST_MODE_SEL => X"0",
      VF3_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF3_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF3_TPHR_CAP_VER => X"1",
      VF4_TPHR_CAP_ST_MODE_SEL => X"0",
      VF4_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF4_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF4_TPHR_CAP_VER => X"1",
      VF5_TPHR_CAP_ST_MODE_SEL => X"0",
      VF5_TPHR_CAP_ST_TABLE_LOC => X"0",
      VF5_TPHR_CAP_ST_TABLE_SIZE => X"000",
      VF5_TPHR_CAP_VER => X"1",
      PF0_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      PF0_TPHR_CAP_INT_VEC_MODE => "FALSE",
      PF1_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      PF1_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF0_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF0_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF1_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF1_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF2_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF2_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF3_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF3_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF4_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF4_TPHR_CAP_INT_VEC_MODE => "FALSE",
      VF5_TPHR_CAP_DEV_SPECIFIC_MODE => "TRUE",
      VF5_TPHR_CAP_INT_VEC_MODE => "FALSE",
      PF0_SECONDARY_PCIE_CAP_NEXTPTR => X"000",
      MCAP_CAP_NEXTPTR => X"000",
      PF0_VC_CAP_NEXTPTR => X"000",
      SPARE_WORD1 => X"00000000",
      PF1_AER_CAP_ECRC_CHECK_CAPABLE => "FALSE",
      PF1_AER_CAP_ECRC_GEN_CAPABLE => "FALSE",
      PF1_AER_CAP_NEXTPTR => X"000",
      PF1_ARI_CAP_NEXTPTR => X"000",
      PF1_BAR0_APERTURE_SIZE => X"00",
      PF1_BAR0_CONTROL => X"0",
      PF1_BAR1_APERTURE_SIZE => X"00",
      PF1_BAR1_CONTROL => X"0",
      PF1_BAR2_APERTURE_SIZE => X"00",
      PF1_BAR2_CONTROL => X"0",
      PF1_BAR3_APERTURE_SIZE => X"00",
      PF1_BAR3_CONTROL => X"0",
      PF1_BAR4_APERTURE_SIZE => X"00",
      PF1_BAR4_CONTROL => X"0",
      PF1_BAR5_APERTURE_SIZE => X"00",
      PF1_BAR5_CONTROL => X"0",
      PF1_CAPABILITY_POINTER => X"80",
      PF1_CLASS_CODE => X"058000",
      PF1_DEVICE_ID => X"8011",
      PF1_DEV_CAP_MAX_PAYLOAD_SIZE => X"2",
      PF1_DPA_CAP_NEXTPTR => X"000",
      PF1_DSN_CAP_NEXTPTR => X"000",
      PF1_EXPANSION_ROM_APERTURE_SIZE => X"00",
      PF1_EXPANSION_ROM_ENABLE => "FALSE",
      PF1_INTERRUPT_PIN => X"0",
      PF1_MSIX_CAP_NEXTPTR => X"00",
      PF1_MSIX_CAP_PBA_BIR => 0,
      PF1_MSIX_CAP_PBA_OFFSET => X"00000000",
      PF1_MSIX_CAP_TABLE_BIR => 0,
      PF1_MSIX_CAP_TABLE_OFFSET => X"00000000",
      PF1_MSIX_CAP_TABLE_SIZE => X"000",
      PF1_MSI_CAP_MULTIMSGCAP => 0,
      PF1_MSI_CAP_NEXTPTR => X"00",
      PF1_PB_CAP_NEXTPTR => X"000",
      PF1_PM_CAP_NEXTPTR => X"00",
      PF1_RBAR_CAP_ENABLE => "FALSE",
      PF1_RBAR_CAP_NEXTPTR => X"000",
      PF1_REVISION_ID => X"00",
      PF1_SRIOV_BAR0_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR0_CONTROL => X"0",
      PF1_SRIOV_BAR1_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR1_CONTROL => X"0",
      PF1_SRIOV_BAR2_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR2_CONTROL => X"0",
      PF1_SRIOV_BAR3_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR3_CONTROL => X"0",
      PF1_SRIOV_BAR4_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR4_CONTROL => X"0",
      PF1_SRIOV_BAR5_APERTURE_SIZE => X"00",
      PF1_SRIOV_BAR5_CONTROL => X"0",
      PF1_SRIOV_CAP_INITIAL_VF => X"0000",
      PF1_SRIOV_CAP_NEXTPTR => X"000",
      PF1_SRIOV_CAP_TOTAL_VF => X"0000",
      PF1_SRIOV_CAP_VER => X"0",
      PF1_SRIOV_FIRST_VF_OFFSET => X"0000",
      PF1_SRIOV_FUNC_DEP_LINK => X"0001",
      PF1_SRIOV_SUPPORTED_PAGE_SIZE => X"00000553",
      PF1_SRIOV_VF_DEVICE_ID => X"0000",
      PF1_SUBSYSTEM_ID => X"0007",
      PF1_TPHR_CAP_ENABLE => "FALSE",
      PF1_TPHR_CAP_NEXTPTR => X"000",
      PL_UPSTREAM_FACING => "TRUE",
      en_msi_per_vec_masking => "FALSE",
      SRIOV_CAP_ENABLE => "FALSE",
      TL_CREDITS_CD => X"000",
      TL_CREDITS_CH => X"00",
      TL_CREDITS_NPD => X"028",
      TL_CREDITS_NPH => X"20",
      TL_CREDITS_PD => X"198",
      TL_CREDITS_PH => X"20",
      TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE => "FALSE",
      TL_LEGACY_MODE_ENABLE => "TRUE",
      TL_PF_ENABLE_REG => X"0",
      VF0_CAPABILITY_POINTER => X"80",
      VF0_MSIX_CAP_PBA_BIR => 0,
      VF0_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF0_MSIX_CAP_TABLE_BIR => 0,
      VF0_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF0_MSIX_CAP_TABLE_SIZE => X"000",
      VF0_MSI_CAP_MULTIMSGCAP => 0,
      VF0_PM_CAP_NEXTPTR => X"00",
      VF1_MSIX_CAP_PBA_BIR => 0,
      VF1_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF1_MSIX_CAP_TABLE_BIR => 0,
      VF1_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF1_MSIX_CAP_TABLE_SIZE => X"000",
      VF1_MSI_CAP_MULTIMSGCAP => 0,
      VF1_PM_CAP_NEXTPTR => X"00",
      VF2_MSIX_CAP_PBA_BIR => 0,
      VF2_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF2_MSIX_CAP_TABLE_BIR => 0,
      VF2_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF2_MSIX_CAP_TABLE_SIZE => X"000",
      VF2_MSI_CAP_MULTIMSGCAP => 0,
      VF2_PM_CAP_NEXTPTR => X"00",
      VF3_MSIX_CAP_PBA_BIR => 0,
      VF3_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF3_MSIX_CAP_TABLE_BIR => 0,
      VF3_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF3_MSIX_CAP_TABLE_SIZE => X"000",
      VF3_MSI_CAP_MULTIMSGCAP => 0,
      VF3_PM_CAP_NEXTPTR => X"00",
      VF4_MSIX_CAP_PBA_BIR => 0,
      VF4_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF4_MSIX_CAP_TABLE_BIR => 0,
      VF4_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF4_MSIX_CAP_TABLE_SIZE => X"000",
      VF4_MSI_CAP_MULTIMSGCAP => 0,
      VF4_PM_CAP_NEXTPTR => X"00",
      VF5_MSIX_CAP_PBA_BIR => 0,
      VF5_MSIX_CAP_PBA_OFFSET => X"00000000",
      VF5_MSIX_CAP_TABLE_BIR => 0,
      VF5_MSIX_CAP_TABLE_OFFSET => X"00000000",
      VF5_MSIX_CAP_TABLE_SIZE => X"000",
      VF5_MSI_CAP_MULTIMSGCAP => 0,
      VF5_PM_CAP_NEXTPTR => X"00",
      COMPLETION_SPACE => "16KB",
      gen_x0y0_xdc => 1,
      gen_x0y1_xdc => 0,
      gen_x0y2_xdc => 0,
      gen_x0y3_xdc => 0,
      gen_x0y4_xdc => 0,
      gen_x0y5_xdc => 0,
      xlnx_ref_board => 1,
      pcie_blk_locn => 0,
      PIPE_SIM => "FALSE",
      AXISTEN_IF_ENABLE_CLIENT_TAG => "FALSE",
      PCIE_USE_MODE => "2.0",
      PCIE_FAST_CONFIG => "NONE",
      EXT_STARTUP_PRIMITIVE => "FALSE",
      PL_INTERFACE => "FALSE",
      PCIE_CONFIGURATION => "FALSE",
      CFG_STATUS_IF => "TRUE",
      TX_FC_IF => "TRUE",
      CFG_EXT_IF => "TRUE",
      CFG_FC_IF => "TRUE",
      PER_FUNC_STATUS_IF => "TRUE",
      CFG_MGMT_IF => "TRUE",
      RCV_MSG_IF => "TRUE",
      CFG_TX_MSG_IF => "TRUE",
      CFG_CTL_IF => "TRUE",
      MSI_EN => "TRUE",
      MSIX_EN => "FALSE",
      PCIE3_DRP => "FALSE",
      DIS_GT_WIZARD => "FALSE",
      TRANSCEIVER_CTRL_STATUS_PORTS => "FALSE",
      SHARED_LOGIC => 1,
      DEDICATE_PERST => "TRUE",
      SYS_RESET_POLARITY => 0,
      MCAP_ENABLEMENT => "NONE",
      PHY_LP_TXPRESET => 4,
      EXT_CH_GT_DRP => "FALSE",
      EN_GT_SELECTION => "FALSE",
      SELECT_QUAD => "GTH_Quad_224",
      silicon_revision => "Production",
      DEV_PORT_TYPE => 1
    )
    PORT MAP (
      pci_exp_txn => pci_exp_txn,
      pci_exp_txp => pci_exp_txp,
      pci_exp_rxn => pci_exp_rxn,
      pci_exp_rxp => pci_exp_rxp,
      user_clk => user_clk,
      user_reset => user_reset,
      user_lnk_up => user_lnk_up,
      s_axis_rq_tdata => s_axis_rq_tdata,
      s_axis_rq_tkeep => s_axis_rq_tkeep,
      s_axis_rq_tlast => s_axis_rq_tlast,
      s_axis_rq_tready => s_axis_rq_tready,
      s_axis_rq_tuser => s_axis_rq_tuser,
      s_axis_rq_tvalid => s_axis_rq_tvalid,
      m_axis_rc_tdata => m_axis_rc_tdata,
      m_axis_rc_tkeep => m_axis_rc_tkeep,
      m_axis_rc_tlast => m_axis_rc_tlast,
      m_axis_rc_tready => m_axis_rc_tready,
      m_axis_rc_tuser => m_axis_rc_tuser,
      m_axis_rc_tvalid => m_axis_rc_tvalid,
      m_axis_cq_tdata => m_axis_cq_tdata,
      m_axis_cq_tkeep => m_axis_cq_tkeep,
      m_axis_cq_tlast => m_axis_cq_tlast,
      m_axis_cq_tready => m_axis_cq_tready,
      m_axis_cq_tuser => m_axis_cq_tuser,
      m_axis_cq_tvalid => m_axis_cq_tvalid,
      s_axis_cc_tdata => s_axis_cc_tdata,
      s_axis_cc_tkeep => s_axis_cc_tkeep,
      s_axis_cc_tlast => s_axis_cc_tlast,
      s_axis_cc_tready => s_axis_cc_tready,
      s_axis_cc_tuser => s_axis_cc_tuser,
      s_axis_cc_tvalid => s_axis_cc_tvalid,
      pcie_rq_seq_num => pcie_rq_seq_num,
      pcie_rq_seq_num_vld => pcie_rq_seq_num_vld,
      pcie_rq_tag => pcie_rq_tag,
      pcie_rq_tag_av => pcie_rq_tag_av,
      pcie_rq_tag_vld => pcie_rq_tag_vld,
      pcie_tfc_nph_av => pcie_tfc_nph_av,
      pcie_tfc_npd_av => pcie_tfc_npd_av,
      pcie_cq_np_req => pcie_cq_np_req,
      pcie_cq_np_req_count => pcie_cq_np_req_count,
      cfg_phy_link_down => cfg_phy_link_down,
      cfg_phy_link_status => cfg_phy_link_status,
      cfg_negotiated_width => cfg_negotiated_width,
      cfg_current_speed => cfg_current_speed,
      cfg_max_payload => cfg_max_payload,
      cfg_max_read_req => cfg_max_read_req,
      cfg_function_status => cfg_function_status,
      cfg_function_power_state => cfg_function_power_state,
      cfg_vf_status => cfg_vf_status,
      cfg_vf_power_state => cfg_vf_power_state,
      cfg_link_power_state => cfg_link_power_state,
      cfg_mgmt_addr => cfg_mgmt_addr,
      cfg_mgmt_write => cfg_mgmt_write,
      cfg_mgmt_write_data => cfg_mgmt_write_data,
      cfg_mgmt_byte_enable => cfg_mgmt_byte_enable,
      cfg_mgmt_read => cfg_mgmt_read,
      cfg_mgmt_read_data => cfg_mgmt_read_data,
      cfg_mgmt_read_write_done => cfg_mgmt_read_write_done,
      cfg_mgmt_type1_cfg_reg_access => cfg_mgmt_type1_cfg_reg_access,
      cfg_err_cor_out => cfg_err_cor_out,
      cfg_err_nonfatal_out => cfg_err_nonfatal_out,
      cfg_err_fatal_out => cfg_err_fatal_out,
      cfg_local_error => cfg_local_error,
      cfg_ltr_enable => cfg_ltr_enable,
      cfg_ltssm_state => cfg_ltssm_state,
      cfg_rcb_status => cfg_rcb_status,
      cfg_dpa_substate_change => cfg_dpa_substate_change,
      cfg_obff_enable => cfg_obff_enable,
      cfg_pl_status_change => cfg_pl_status_change,
      cfg_tph_requester_enable => cfg_tph_requester_enable,
      cfg_tph_st_mode => cfg_tph_st_mode,
      cfg_vf_tph_requester_enable => cfg_vf_tph_requester_enable,
      cfg_vf_tph_st_mode => cfg_vf_tph_st_mode,
      cfg_msg_received => cfg_msg_received,
      cfg_msg_received_data => cfg_msg_received_data,
      cfg_msg_received_type => cfg_msg_received_type,
      cfg_msg_transmit => cfg_msg_transmit,
      cfg_msg_transmit_type => cfg_msg_transmit_type,
      cfg_msg_transmit_data => cfg_msg_transmit_data,
      cfg_msg_transmit_done => cfg_msg_transmit_done,
      cfg_fc_ph => cfg_fc_ph,
      cfg_fc_pd => cfg_fc_pd,
      cfg_fc_nph => cfg_fc_nph,
      cfg_fc_npd => cfg_fc_npd,
      cfg_fc_cplh => cfg_fc_cplh,
      cfg_fc_cpld => cfg_fc_cpld,
      cfg_fc_sel => cfg_fc_sel,
      cfg_per_func_status_control => cfg_per_func_status_control,
      cfg_per_func_status_data => cfg_per_func_status_data,
      cfg_per_function_number => cfg_per_function_number,
      cfg_per_function_output_request => cfg_per_function_output_request,
      cfg_per_function_update_done => cfg_per_function_update_done,
      cfg_dsn => cfg_dsn,
      cfg_power_state_change_ack => cfg_power_state_change_ack,
      cfg_power_state_change_interrupt => cfg_power_state_change_interrupt,
      cfg_err_cor_in => cfg_err_cor_in,
      cfg_err_uncor_in => cfg_err_uncor_in,
      cfg_flr_in_process => cfg_flr_in_process,
      cfg_flr_done => cfg_flr_done,
      cfg_vf_flr_in_process => cfg_vf_flr_in_process,
      cfg_vf_flr_done => cfg_vf_flr_done,
      cfg_link_training_enable => cfg_link_training_enable,
      cfg_ext_read_received => cfg_ext_read_received,
      cfg_ext_write_received => cfg_ext_write_received,
      cfg_ext_register_number => cfg_ext_register_number,
      cfg_ext_function_number => cfg_ext_function_number,
      cfg_ext_write_data => cfg_ext_write_data,
      cfg_ext_write_byte_enable => cfg_ext_write_byte_enable,
      cfg_ext_read_data => cfg_ext_read_data,
      cfg_ext_read_data_valid => cfg_ext_read_data_valid,
      cfg_interrupt_int => cfg_interrupt_int,
      cfg_interrupt_pending => cfg_interrupt_pending,
      cfg_interrupt_sent => cfg_interrupt_sent,
      cfg_interrupt_msi_enable => cfg_interrupt_msi_enable,
      cfg_interrupt_msi_vf_enable => cfg_interrupt_msi_vf_enable,
      cfg_interrupt_msi_mmenable => cfg_interrupt_msi_mmenable,
      cfg_interrupt_msi_mask_update => cfg_interrupt_msi_mask_update,
      cfg_interrupt_msi_data => cfg_interrupt_msi_data,
      cfg_interrupt_msi_select => cfg_interrupt_msi_select,
      cfg_interrupt_msi_int => cfg_interrupt_msi_int,
      cfg_interrupt_msi_pending_status => cfg_interrupt_msi_pending_status,
      cfg_interrupt_msi_pending_status_data_enable => cfg_interrupt_msi_pending_status_data_enable,
      cfg_interrupt_msi_pending_status_function_num => cfg_interrupt_msi_pending_status_function_num,
      cfg_interrupt_msi_sent => cfg_interrupt_msi_sent,
      cfg_interrupt_msi_fail => cfg_interrupt_msi_fail,
      cfg_interrupt_msi_attr => cfg_interrupt_msi_attr,
      cfg_interrupt_msi_tph_present => cfg_interrupt_msi_tph_present,
      cfg_interrupt_msi_tph_type => cfg_interrupt_msi_tph_type,
      cfg_interrupt_msi_tph_st_tag => cfg_interrupt_msi_tph_st_tag,
      cfg_interrupt_msi_function_number => cfg_interrupt_msi_function_number,
      cfg_interrupt_msix_data => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      cfg_interrupt_msix_address => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 64)),
      cfg_interrupt_msix_int => '0',
      cfg_hot_reset_out => cfg_hot_reset_out,
      cfg_config_space_enable => cfg_config_space_enable,
      cfg_req_pm_transition_l23_ready => cfg_req_pm_transition_l23_ready,
      cfg_hot_reset_in => cfg_hot_reset_in,
      cfg_ds_port_number => cfg_ds_port_number,
      cfg_ds_bus_number => cfg_ds_bus_number,
      cfg_ds_device_number => cfg_ds_device_number,
      cfg_ds_function_number => cfg_ds_function_number,
      cfg_subsys_vend_id => cfg_subsys_vend_id,
      drp_clk => '1',
      drp_en => '0',
      drp_we => '0',
      drp_addr => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 10)),
      drp_di => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16)),
      user_tph_stt_address => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 5)),
      user_tph_function_num => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      user_tph_stt_read_enable => '0',
      sys_clk => sys_clk,
      sys_clk_gt => sys_clk_gt,
      sys_reset => sys_reset,
      conf_req_type => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      conf_req_reg_num => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      conf_req_data => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      conf_req_valid => '0',
      mcap_eos_in => '0',
      startup_do => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      startup_dts => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      startup_fcsbo => '0',
      startup_fcsbts => '0',
      startup_gsr => '0',
      startup_gts => '0',
      startup_keyclearb => '1',
      startup_pack => '0',
      startup_usrcclko => '0',
      startup_usrcclkts => '1',
      startup_usrdoneo => '0',
      startup_usrdonets => '1',
      cap_gnt => '1',
      cap_rel => '0',
      pl_eq_reset_eieos_count => '0',
      pl_gen2_upstream_prefer_deemph => '0',
      pcie_perstn1_in => pcie_perstn1_in,
      pcie_perstn0_out => pcie_perstn0_out,
      pcie_perstn1_out => pcie_perstn1_out,
      ext_qpll1lock_out => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      ext_qpll1outclk_out => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      ext_qpll1outrefclk_out => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 2)),
      int_qpll1lock_out => int_qpll1lock_out,
      int_qpll1outrefclk_out => int_qpll1outrefclk_out,
      int_qpll1outclk_out => int_qpll1outclk_out,
      common_commands_in => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 26)),
      pipe_rx_0_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_1_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_2_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_3_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_4_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_5_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_6_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      pipe_rx_7_sigs => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 84)),
      gt_pcieuserratedone => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      gt_loopback => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 24)),
      gt_txprbsforceerr => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      gt_txinhibit => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      gt_txprbssel => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      gt_rxprbssel => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      gt_rxprbscntreset => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      ext_ch_gt_drpaddr => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 72)),
      ext_ch_gt_drpen => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      ext_ch_gt_drpdi => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 128)),
      ext_ch_gt_drpwe => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8))
    );
END pcie3_core_arch;
