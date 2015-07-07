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
--use work.pcie_unit_pkg.all;
use work.prj_def.all;
use work.prj_cfg.all;

entity pcie_ctrl is
generic(
G_DATA_WIDTH                     : integer := 64;
G_KEEP_WIDTH                     : integer := 1;
G_AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
G_AXISTEN_IF_RQ_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_CC_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : boolean := FALSE;
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
p_in_pcie_rq_seq_num      : in   std_logic_vector(3 downto 0)            ;
p_in_pcie_rq_seq_num_vld  : in   std_logic                               ;
p_in_pcie_rq_tag          : in   std_logic_vector(5 downto 0)            ;
p_in_pcie_rq_tag_vld      : in   std_logic                               ;
p_out_pcie_cq_np_req      : out  std_logic                               ;
p_in_pcie_cq_np_req_count : in   std_logic_vector(5 downto 0)            ;
--p_in_pcie_rq_tag_av       : in   std_logic_vector(1 DOWNTO 0);

------------------------------------
-- EP and RP
------------------------------------
--p_in_cfg_phy_link_down        : in   std_logic                           ;
p_in_cfg_negotiated_width     : in   std_logic_vector(3 downto 0)        ;
--p_in_cfg_current_speed        : in   std_logic_vector(2 downto 0)        ;
p_in_cfg_max_payload          : in   std_logic_vector(2 downto 0)        ;
p_in_cfg_max_read_req         : in   std_logic_vector(2 downto 0)        ;
p_in_cfg_function_status      : in   std_logic_vector(7 downto 0)        ;
--p_in_cfg_function_power_state : in   std_logic_vector(5 downto 0)        ;
--p_in_cfg_vf_status            : in   std_logic_vector(11 downto 0)       ;
--p_in_cfg_vf_power_state       : in   std_logic_vector(17 downto 0)       ;
--p_in_cfg_link_power_state     : in   std_logic_vector( 1 downto 0)       ;

-- Error Reporting Interface
p_in_cfg_err_cor_out       : in   std_logic                              ;
p_in_cfg_err_nonfatal_out  : in   std_logic                              ;
p_in_cfg_err_fatal_out     : in   std_logic                              ;
--p_in_cfg_local_error       : in   std_logic                            ;

--p_in_cfg_ltr_enable              : in   std_logic                        ;
--p_in_cfg_ltssm_state             : in   std_logic_vector(5 downto 0)     ;
--p_in_cfg_rcb_status              : in   std_logic_vector(1 downto 0)     ;
--p_in_cfg_dpa_substate_change     : in   std_logic_vector(1 downto 0)     ;
--p_in_cfg_obff_enable             : in   std_logic_vector(1 downto 0)     ;
--p_in_cfg_pl_status_change        : in   std_logic                        ;

--p_in_cfg_tph_requester_enable    : in   std_logic_vector(1 downto 0)     ;
--p_in_cfg_tph_st_mode             : in   std_logic_vector(5 downto 0)     ;
--p_in_cfg_vf_tph_requester_enable : in   std_logic_vector(5 downto 0)     ;
--p_in_cfg_vf_tph_st_mode          : in   std_logic_vector(17 downto 0)    ;

---- Management Interface
--p_out_cfg_mgmt_addr                  : out  std_logic_vector(18 downto 0);
--p_out_cfg_mgmt_write                 : out  std_logic                    ;
--p_out_cfg_mgmt_write_data            : out  std_logic_vector(31 downto 0);
--p_out_cfg_mgmt_byte_enable           : out  std_logic_vector( 3 downto 0);
--p_out_cfg_mgmt_read                  : out  std_logic                    ;
--p_in_cfg_mgmt_read_data              : in   std_logic_vector(31 downto 0);
--p_in_cfg_mgmt_read_write_done        : in   std_logic                    ;
--p_out_cfg_mgmt_type1_cfg_reg_access  : out  std_logic                    ;
--p_in_cfg_msg_received                : in   std_logic                    ;
--p_in_cfg_msg_received_data           : in   std_logic_vector(7 downto 0) ;
--p_in_cfg_msg_received_type           : in   std_logic_vector(4 downto 0) ;
--p_out_cfg_msg_transmit               : out  std_logic                    ;
--p_out_cfg_msg_transmit_type          : out  std_logic_vector( 2 downto 0);
--p_out_cfg_msg_transmit_data          : out  std_logic_vector(31 downto 0);
--p_in_cfg_msg_transmit_done           : in   std_logic                    ;
p_in_cfg_fc_ph                        : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_pd                        : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_nph                       : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_npd                       : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_cplh                      : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_cpld                      : in   std_logic_vector(11 downto 0);
p_out_cfg_fc_sel                      : out  std_logic_vector( 2 downto 0);
--p_out_cfg_per_func_status_control     : out  std_logic_vector( 2 downto 0);
--p_in_cfg_per_func_status_data         : in   std_logic_vector(15 downto 0);
--p_out_cfg_per_function_number         : out  std_logic_vector( 3 downto 0);
--p_out_cfg_per_function_output_request : out  std_logic
--p_in_cfg_per_function_update_done     : in   std_logic

p_out_cfg_dsn                          : out  std_logic_vector(63 downto 0) ;
p_out_cfg_power_state_change_ack       : out  std_logic                     ;
p_in_cfg_power_state_change_interrupt  : in   std_logic                     ;
p_out_cfg_err_cor_in                   : out  std_logic                     ;
p_out_cfg_err_uncor_in                 : out  std_logic                     ;

p_in_cfg_flr_in_process               : in   std_logic_vector(1 downto 0)  ;
p_out_cfg_flr_done                    : out  std_logic_vector(1 downto 0)  ;
p_in_cfg_vf_flr_in_process            : in   std_logic_vector(5 downto 0)  ;
p_out_cfg_vf_flr_done                 : out  std_logic_vector(5 downto 0)  ;

--p_out_cfg_link_training_enable         : out  std_logic                     ;
--p_in_cfg_ext_read_received             : in   std_logic                     ;
--p_in_cfg_ext_write_received            : in   std_logic                     ;
--p_in_cfg_ext_register_number           : in   std_logic_vector( 9 downto 0) ;
--p_in_cfg_ext_function_number           : in   std_logic_vector( 7 downto 0) ;
--p_in_cfg_ext_write_data                : in   std_logic_vector(31 downto 0) ;
--p_in_cfg_ext_write_byte_enable         : in   std_logic_vector( 3 downto 0) ;
--p_out_cfg_ext_read_data                : out  std_logic_vector(31 downto 0) ;
--p_out_cfg_ext_read_data_valid          : out  std_logic                     ;

p_out_cfg_ds_port_number               : out  std_logic_vector(7 downto 0)  ;
p_out_cfg_ds_bus_number                : out  std_logic_vector(7 downto 0)  ;
p_out_cfg_ds_device_number             : out  std_logic_vector(4 downto 0)  ;
p_out_cfg_ds_function_number           : out  std_logic_vector(2 downto 0)  ;

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
p_in_cfg_interrupt_msi_pending_status_data_enable  : in  std_logic;
p_in_cfg_interrupt_msi_pending_status_function_num : in  std_logic_vector(3 downto 0);

-- EP only
p_in_cfg_hot_reset_in                 : in   std_logic                    ;
--p_out_cfg_config_space_enable         : out  std_logic                    ;
--p_out_cfg_req_pm_transition_l23_ready : out  std_logic                    ;

-- RP only
p_out_cfg_hot_reset_out               : out  std_logic                    ;

--led_out                               : out  std_logic_vector(7 downto 0) ;

p_in_user_clk                         : in   std_logic                    ;
p_in_user_reset_n                     : in   std_logic                    ;
p_in_user_lnk_up                      : in   std_logic

);
end entity pcie_ctrl;

architecture struct of pcie_ctrl is

type TSR_flr_bus2 array (0 to 1) of std_logic_vector(1 downto 0);
type TSR_flr_bus6 array (0 to 1) of std_logic_vector(5 downto 0);
signal sr_cfg_flr_done         : TSR_flr_bus2;
signal sr_cfg_vf_flr_done      : TSR_flr_bus6;

signal i_req_compl             : std_logic;
signal i_compl_done            : std_logic;
signal i_rst                   : std_logic;


begin --architecture struct of pcie_ctrl

----------------------------------------
--
----------------------------------------
i_rst <= p_in_user_lnk_up and not p_in_user_reset_n;


----------------------------------------
--Function level reset (FLR)
----------------------------------------
process(p_in_user_clk, p_in_user_reset_n)
begin
if p_in_user_reset_n = '0' begin
  for i in 0 to sr_cfg_flr_done'length - 1 loop
  sr_cfg_flr_done(i) <= (others => '0');
  end loop;

  for i in 0 to sr_cfg_vf_flr_done'length - 1 loop
  sr_cfg_vf_flr_done(i) <= (others => '0');
  end loop;

elsif rising_edge(p_in_user_clk) then
  sr_cfg_flr_done <= p_in_cfg_flr_in_process & sr_cfg_flr_done(0 to 0);
  sr_cfg_vf_flr_done <= p_in_cfg_vf_flr_in_process & sr_cfg_vf_flr_done(0 to 0);

end if;
end process;

--detect rising edge of p_in_cfg_flr_in_process
p_out_cfg_flr_done(0) <= not sr_cfg_flr_done(1)(0) and sr_cfg_flr_done(0)(0);
p_out_cfg_flr_done(1) <= not sr_cfg_flr_done(1)(1) and sr_cfg_flr_done(0)(1);

--detect rising edge of p_in_cfg_vf_flr_in_process
p_out_cfg_vf_flr_done(0) <= not sr_cfg_vf_flr_done(1)(0) and sr_cfg_vf_flr_done(0)(0);
p_out_cfg_vf_flr_done(1) <= not sr_cfg_vf_flr_done(1)(1) and sr_cfg_vf_flr_done(0)(1);
p_out_cfg_vf_flr_done(2) <= not sr_cfg_vf_flr_done(1)(2) and sr_cfg_vf_flr_done(0)(2);
p_out_cfg_vf_flr_done(3) <= not sr_cfg_vf_flr_done(1)(3) and sr_cfg_vf_flr_done(0)(3);
p_out_cfg_vf_flr_done(4) <= not sr_cfg_vf_flr_done(1)(4) and sr_cfg_vf_flr_done(0)(4);
p_out_cfg_vf_flr_done(5) <= not sr_cfg_vf_flr_done(1)(5) and sr_cfg_vf_flr_done(0)(5);


----------------------------------------
--
----------------------------------------
p_out_cfg_ds_port_number     <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_port_number'length));
p_out_cfg_ds_bus_number      <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_bus_number'length));
p_out_cfg_ds_device_number   <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_device_number'length));
p_out_cfg_ds_function_number <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_function_number'length));

p_out_cfg_dsn <= std_logic_vector(TO_UNSIGNED(16#123#, p_out_cfg_dsn'length));

p_out_cfg_err_cor_in   <= '0';
p_out_cfg_err_uncor_in <= '0';

-- EP only
--p_out_cfg_config_space_enable <= '1';
--p_out_cfg_req_pm_transition_l23_ready <= '0';

-- RP only
p_out_cfg_hot_reset_out <= '0';


----------------------------------------
--
----------------------------------------
m_pio_to_ctrl : pio_to_ctrl
port map(
clk        => p_in_user_clk,
rst        => i_rst,

req_compl  => i_req_compl,
compl_done => i_compl_done,

cfg_power_state_change_interrupt => p_in_cfg_power_state_change_interrupt,
cfg_power_state_change_ack       => p_out_cfg_power_state_change_ack
);


--#############################################
--DBG
--#############################################
p_out_hclk <= '0';
p_out_gctrl <= (others => '0');

--CTRL user devices
p_out_dev_ctrl <= (others => '0');
p_out_dev_din <= (others => '0');
p_out_dev_wr <= '0';
p_out_dev_rd <= '0';

p_out_dev_opt <= (others => '0');

--DBG
p_out_tst <= (others => '0');


p_out_s_axis_rq_tlast  <= '0';--: out  std_logic                                   ;
p_out_s_axis_rq_tdata  <= (others => '0');--: out  std_logic_vector(G_DATA_WIDTH - 1 downto 0) ;
p_out_s_axis_rq_tuser  <= (others => '0');--: out  std_logic_vector(59 downto 0)               ;
p_out_s_axis_rq_tkeep  <= (others => '0');--: out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0)   ;
p_out_s_axis_rq_tvalid <= '0';--: out  std_logic                                   ;

p_out_m_axis_rc_tready <= (others => '0');--: out  std_logic_vector(21 downto 0)               ;


p_out_m_axis_cq_tready <= (others => '0');--: out  std_logic_vector(21 downto 0)               ;

p_out_s_axis_cc_tdata  <= (others => '0');--: out  std_logic_vector(G_DATA_WIDTH - 1 downto 0) ;
p_out_s_axis_cc_tuser  <= (others => '0');--: out  std_logic_vector(32 downto 0)               ;
p_out_s_axis_cc_tlast  <= '0';--: out  std_logic                                   ;
p_out_s_axis_cc_tkeep  <= (others => '0');--: out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0)   ;
p_out_s_axis_cc_tvalid <= '0';--: out  std_logic                                   ;

------------------------------------
--Configuration (CFG) Interface
------------------------------------
p_out_pcie_cq_np_req   <= '0';--   : out  std_logic                               ;



p_out_cfg_fc_sel                      <= (others => '0');--: out  std_logic_vector( 2 downto 0);








--p_out_cfg_link_training_enable <= '0';



------------------------------------
-- EP Only
------------------------------------
-- Interrupt Interface Signals
p_out_cfg_interrupt_int                 <= (others => '0');--: out  std_logic_vector(3 downto 0) ;
p_out_cfg_interrupt_pending             <= (others => '0');--: out  std_logic_vector(1 downto 0) ;
p_out_cfg_interrupt_msi_select          <= (others => '0');--: out  std_logic_vector( 3 downto 0);
p_out_cfg_interrupt_msi_int             <= (others => '0');--: out  std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_pending_status  <= (others => '0');--: out  std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_attr            <= (others => '0');--: out  std_logic_vector(2 downto 0) ;
p_out_cfg_interrupt_msi_tph_present     <= '0';--: out  std_logic                    ;
p_out_cfg_interrupt_msi_tph_type        <= (others => '0');--: out  std_logic_vector(1 downto 0) ;
p_out_cfg_interrupt_msi_tph_st_tag      <= (others => '0');--: out  std_logic_vector(8 downto 0) ;
p_out_cfg_interrupt_msi_function_number <= (others => '0');--: out  std_logic_vector(2 downto 0) ;





end architecture struct;


