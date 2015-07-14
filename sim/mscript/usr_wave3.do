onerror {resume}
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tuser(3 downto 0)} m_axis_cq_tuser_first_be
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tuser(7 downto 4)} m_axis_cq_tuser_last_be
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tuser(39 downto 8)} m_axis_cq_tuser_byte_en
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(31 downto 0)} m_axis_cq_tdata_31_0
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(63 downto 32)} m_axis_cq_tdata_32_63
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(63 downto 32)} m_axis_tdata_63_32
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(31 downto 0)} m_axis_tdata_31_0
quietly WaveActivateNextPane {} 0
add wave -noupdate /board/i
add wave -noupdate /board/sys_rst_n
add wave -noupdate /board/ep_sys_clk
add wave -noupdate /board/rp_sys_clk
add wave -noupdate /board/ep_pci_exp_txn
add wave -noupdate /board/ep_pci_exp_txp
add wave -noupdate /board/rp_pci_exp_txn
add wave -noupdate /board/rp_pci_exp_txp
add wave -noupdate /board/rp_sys_clk_n
add wave -noupdate /board/rp_sys_clk_p
add wave -noupdate /board/ep_sys_clk_n
add wave -noupdate /board/ep_sys_clk_p
add wave -noupdate /glbl/GSR
add wave -noupdate /board/EP/pci_exp_txp
add wave -noupdate /board/EP/pci_exp_txn
add wave -noupdate /board/EP/pci_exp_rxp
add wave -noupdate /board/EP/pci_exp_rxn
add wave -noupdate /board/EP/sys_clk_p
add wave -noupdate /board/EP/sys_clk_n
add wave -noupdate /board/EP/sys_rst_n
add wave -noupdate /board/EP/m_main/i_user_clk
add wave -noupdate /board/EP/m_main/i_user_reset
add wave -noupdate /board/EP/m_main/i_user_lnk_up
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_flr_in_process
add wave -noupdate /board/EP/m_main/m_ctrl/p_out_cfg_flr_done
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_vf_flr_in_process
add wave -noupdate /board/EP/m_main/m_ctrl/p_out_cfg_vf_flr_done
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_current_speed
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_negotiated_width
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_max_payload
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_max_read_req
add wave -noupdate -expand /board/EP/m_main/m_ctrl/p_in_cfg_function_status
add wave -noupdate -divider USR_APP
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_rst_n
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_reg_adr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_out_reg_dout
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_reg_din
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_reg_wr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_reg_rd
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_reg_rd
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_reg_bar
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_reg_adr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/v_reg_firmware
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/v_reg_ctrl
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/v_reg_tst0
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/v_reg_tst1
add wave -noupdate -divider pio_to_ctrl
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/rst_n
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/req_compl
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/compl_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/cfg_power_state_change_interrupt
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/cfg_power_state_change_ack
add wave -noupdate /board/EP/m_main/m_ctrl/m_pio_to_ctrl/trn_pending
add wave -noupdate -divider RX_ENGENE
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_rst_n
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/i_sop
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_compl
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_compl_ur
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_compl_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/i_data_start_loc
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_addr
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_ureg_a
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_ureg_di
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_ureg_wrbe
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_ureg_wr
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_ureg_rd
add wave -noupdate -color {Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_rx/i_fsm_rx
add wave -noupdate -color {Medium Slate Blue} -itemcolor {Lime Green} -radix binary /board/EP/m_main/m_ctrl/m_rx/i_trn_type
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_first_be
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_last_be
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_byte_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tuser(40)
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_tdata_31_0
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_tdata_63_32
add wave -noupdate -radix hexadecimal -childformat {{/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(63) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(62) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(61) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(60) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(59) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(58) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(57) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(56) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(55) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(54) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(53) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(52) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(51) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(50) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(49) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(48) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(47) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(46) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(45) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(44) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(43) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(42) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(41) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(40) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(39) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(38) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(37) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(36) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(35) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(34) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(33) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(32) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(31) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(30) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(29) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(28) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(27) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(26) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(25) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(24) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(23) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(22) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(21) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(20) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(19) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(18) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(17) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(16) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(15) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(14) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(13) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(12) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(11) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(10) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(9) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(8) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(7) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(6) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(5) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(4) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(3) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(2) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(1) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(0) -radix hexadecimal}} -subitemconfig {/board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(63) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(62) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(61) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(60) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(59) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(58) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(57) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(56) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(55) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(54) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(53) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(52) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(51) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(50) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(49) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(48) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(47) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(46) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(45) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(44) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(43) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(42) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(41) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(40) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(39) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(38) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(37) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(36) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(35) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(34) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(33) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(32) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(31) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(30) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(29) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(28) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(27) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(26) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(25) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(24) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(23) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(22) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(21) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(20) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(19) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(18) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(17) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(16) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(15) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(14) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(13) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(12) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(11) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(10) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(9) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(8) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(7) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(6) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(5) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(4) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(3) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(2) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(1) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata(0) {-height 15 -radix hexadecimal}} /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_cq_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_m_axis_cq_tready
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_pcie_cq_np_req_count
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_pcie_cq_np_req
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_rc_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_rc_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_rc_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_rc_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_m_axis_rc_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_m_axis_rc_tready
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_cfg_msg_received
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_cfg_msg_received_type
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_cfg_msg_data
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_tc
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_attr
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_len
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_rid
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_tag
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_be
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_at
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_des_qword0
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_des_qword1
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_des_tph_present
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_des_tph_type
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_des_tph_st_tag
add wave -noupdate -divider TX_ENGENE
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_req_compl
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_req_compl_ur
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_compl_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_ureg_do
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/i_lower_addr
add wave -noupdate -expand /board/EP/m_main/m_ctrl/m_tx/sr_req_compl
add wave -noupdate -color {Medium Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_tx/i_fsm_tx
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_cc_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_cc_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_cc_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_cc_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_cc_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_s_axis_cc_tready
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_rq_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_rq_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_rq_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_rq_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_s_axis_rq_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_s_axis_rq_tready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 232
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {42678454 ps} {178738715 ps}
