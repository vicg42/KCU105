onerror {resume}
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tuser(3 downto 0)} m_axis_cq_tuser_first_be
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tuser(7 downto 4)} m_axis_cq_tuser_last_be
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tuser(39 downto 8)} m_axis_cq_tuser_byte_en
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(31 downto 0)} m_axis_cq_tdata_31_0
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(63 downto 32)} m_axis_cq_tdata_32_63
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(63 downto 32)} m_axis_tdata_63_32
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_rx { /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(31 downto 0)} m_axis_tdata_31_0
quietly virtual signal -install /board/EP/m_main/m_ctrl/m_tx/m_tx_rq {/board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tdata  } p_out_axi_rq_tdata_63_0
quietly WaveActivateNextPane {} 0
add wave -noupdate /glbl/GSR
add wave -noupdate /board/sys_rst_n
add wave -noupdate /board/ep_sys_clk
add wave -noupdate /board/rp_sys_clk
add wave -noupdate -divider RP
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_err_cor_out
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_err_nonfatal_out
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_err_fatal_out
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_local_error
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_phy_link_down
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_phy_link_status
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_negotiated_width
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_current_speed
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_max_payload
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_max_read_req
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_function_power_state
add wave -noupdate /board/RP/pcie3_uscale_rp_top_i/cfg_function_status
add wave -noupdate /board/RP/cfg_msg_received
add wave -noupdate /board/RP/cfg_msg_received_type
add wave -noupdate /board/RP/cfg_msg_received_data
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_addr
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_write
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_write_data
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_byte_enable
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_read
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_read_data
add wave -noupdate /board/RP/cfg_usrapp/cfg_mgmt_read_write_done
add wave -noupdate /board/RP/m_axis_rc_tdata
add wave -noupdate /board/RP/m_axis_rc_tuser
add wave -noupdate /board/RP/m_axis_rc_tlast
add wave -noupdate /board/RP/m_axis_rc_tkeep
add wave -noupdate /board/RP/m_axis_rc_tvalid
add wave -noupdate /board/RP/m_axis_rc_tready
add wave -noupdate /board/RP/s_axis_rq_tlast
add wave -noupdate /board/RP/s_axis_rq_tdata
add wave -noupdate /board/RP/s_axis_rq_tuser
add wave -noupdate /board/RP/s_axis_rq_tkeep
add wave -noupdate /board/RP/s_axis_rq_tready
add wave -noupdate /board/RP/s_axis_rq_tvalid
add wave -noupdate /board/RP/m_axis_cq_tdata
add wave -noupdate /board/RP/m_axis_cq_tuser
add wave -noupdate /board/RP/m_axis_cq_tlast
add wave -noupdate /board/RP/m_axis_cq_tkeep
add wave -noupdate /board/RP/m_axis_cq_tvalid
add wave -noupdate /board/RP/m_axis_cq_tready
add wave -noupdate /board/RP/s_axis_cc_tdata
add wave -noupdate /board/RP/s_axis_cc_tuser
add wave -noupdate /board/RP/s_axis_cc_tlast
add wave -noupdate /board/RP/s_axis_cc_tkeep
add wave -noupdate /board/RP/s_axis_cc_tvalid
add wave -noupdate /board/RP/s_axis_cc_tready
add wave -noupdate -divider EP
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
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_function_status
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_rcb_status
add wave -noupdate -divider IRQ
add wave -noupdate /board/EP/m_main/m_ctrl/p_out_cfg_interrupt_int
add wave -noupdate /board/EP/m_main/m_ctrl/p_out_cfg_interrupt_pending
add wave -noupdate /board/EP/m_main/m_ctrl/p_in_cfg_interrupt_sent
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_in_cfg_msi
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_in_cfg_irq_rdy
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_out_cfg_irq
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_out_cfg_irq_assert
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_in_irq_clr
add wave -noupdate /board/EP/m_main/m_ctrl/m_irq/p_in_irq_set
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_irq_status_clr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_irq_clr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_irq_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_irq_set
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_irq_status
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
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_reg
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_mrd_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/sr_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/sr_dmatrn_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dmatrn_mem_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dma_start
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/sr_dma_start
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dmatrn_len
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dmatrn_adr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dma_work
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dmatrn_init
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_dmatrn_start
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_host_dmaprm_adr
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_host_dmaprm_din
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_host_dmaprm_dout
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_host_dmaprm_wr(0)
add wave -noupdate -radix binary /board/EP/m_main/m_ctrl/m_usr_app/i_hw_dmaprm_cnt
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_hw_dmaprm_adr
add wave -noupdate -radix hexadecimal /board/EP/m_main/m_ctrl/m_usr_app/i_hw_dmaprm_dout
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/i_hw_dmaprm_rd(0)
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/sr_hw_dmaprm_cnt
add wave -noupdate -childformat {{/board/EP/m_main/m_ctrl/m_usr_app/p_out_dma_prm.len -radix unsigned}} -expand -subitemconfig {/board/EP/m_main/m_ctrl/m_usr_app/p_out_dma_prm.len {-height 15 -radix unsigned}} /board/EP/m_main/m_ctrl/m_usr_app/p_out_dma_prm
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_out_dma_mwr_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/p_in_dma_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_usr_app/tst_mem_dcnt
add wave -noupdate -divider TXRQ
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_pcie_prm
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_dma_init
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_dma_prm
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_dma_mwr_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_dma_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_dma_mrd_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_dma_mrd_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_dma_mrd_rxdwcount
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_pcie_tfc_nph_av
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_pcie_tfc_npd_av
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_pcie_tfc_np_pl_empty
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tdata_63_0
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_axi_rq_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_axi_rq_tready
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/sr_usr_rxbuf_do
add wave -noupdate -color {Medium Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_fsm_txrq
add wave -noupdate -color {Medium Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_tx/m_tx_cc/i_fsm_txcc
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_dma_init
add wave -noupdate -radix decimal /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_adr_byte
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_byte
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_dw
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tx_byte
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tx_byte_remain
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_len
add wave -noupdate -radix decimal /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_cnt
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_tag
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_last
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mem_tpl_dw_rem
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mwr_work
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/i_mwr_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_urxbuf_do
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_urxbuf_rd
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_out_urxbuf_last
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/m_tx_rq/p_in_urxbuf_empty
add wave -noupdate -divider RX_ENGENE
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_rst_n
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_compl
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_compl_ur
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_compl_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_req_prm
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_first_be
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_last_be
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_cq_tuser_byte_en
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tuser(40)
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_tdata_31_0
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_axis_tdata_63_32
add wave -noupdate -radix hexadecimal -childformat {{/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(63) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(62) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(61) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(60) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(59) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(58) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(57) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(56) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(55) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(54) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(53) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(52) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(51) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(50) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(49) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(48) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(47) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(46) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(45) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(44) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(43) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(42) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(41) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(40) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(39) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(38) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(37) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(36) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(35) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(34) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(33) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(32) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(31) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(30) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(29) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(28) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(27) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(26) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(25) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(24) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(23) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(22) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(21) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(20) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(19) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(18) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(17) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(16) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(15) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(14) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(13) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(12) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(11) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(10) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(9) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(8) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(7) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(6) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(5) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(4) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(3) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(2) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(1) -radix hexadecimal} {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(0) -radix hexadecimal}} -subitemconfig {/board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(63) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(62) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(61) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(60) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(59) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(58) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(57) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(56) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(55) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(54) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(53) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(52) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(51) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(50) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(49) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(48) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(47) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(46) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(45) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(44) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(43) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(42) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(41) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(40) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(39) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(38) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(37) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(36) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(35) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(34) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(33) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(32) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(31) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(30) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(29) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(28) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(27) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(26) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(25) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(24) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(23) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(22) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(21) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(20) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(19) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(18) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(17) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(16) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(15) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(14) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(13) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(12) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(11) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(10) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(9) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(8) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(7) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(6) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(5) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(4) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(3) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(2) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(1) {-height 15 -radix hexadecimal} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata(0) {-height 15 -radix hexadecimal}} /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tdata
add wave -noupdate -radix binary /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_axi_cq_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_axi_cq_tready
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_in_pcie_cq_np_req_count
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/p_out_pcie_cq_np_req
add wave -noupdate -color {Medium Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_rx/m_rx_rc/i_fsm_rxrc
add wave -noupdate -color {Medium Slate Blue} -itemcolor Gold /board/EP/m_main/m_ctrl/m_rx/m_rx_cq/i_fsm_rxcq
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_rx_cq/i_reg_wr
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_rx_cq/i_reg_rd
add wave -noupdate /board/EP/m_main/m_ctrl/m_rx/m_rx_cq/i_reg_cs
add wave -noupdate -divider TX_ENGENE
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_clk
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_req_compl
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_req_compl_ur
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_compl_done
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_req_prm
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_axi_cc_tdata
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_axi_cc_tkeep
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_axi_cc_tlast
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_axi_cc_tvalid
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_out_axi_cc_tuser
add wave -noupdate /board/EP/m_main/m_ctrl/m_tx/p_in_axi_cc_tready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {218123630 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 201
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
WaveRestoreZoom {218098379 ps} {218150433 ps}
