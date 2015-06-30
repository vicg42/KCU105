onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /board/i
add wave -noupdate /board/sys_rst_n
add wave -noupdate /board/ep_sys_clk
add wave -noupdate /board/rp_sys_clk
add wave -noupdate /board/ep_pci_exp_txn
add wave -noupdate /board/ep_pci_exp_txp
add wave -noupdate /board/rp_pci_exp_txn
add wave -noupdate /board/rp_pci_exp_txp
add wave -noupdate /board/rp_txn
add wave -noupdate /board/rp_txp
add wave -noupdate /board/rp_sys_clk_n
add wave -noupdate /board/rp_sys_clk_p
add wave -noupdate /board/ep_sys_clk_n
add wave -noupdate /board/ep_sys_clk_p
add wave -noupdate /glbl/GSR
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/user_clk
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/reset_n
add wave -noupdate -divider USR_APP
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/state_ascii
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_addr
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_be
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/trn_sent
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_addr
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_be
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_data
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_en
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_busy
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/payload_len
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/gen_transaction
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/gen_leg_intr
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/gen_msi_intr
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/gen_msix_intr
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data_raw_o
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/dword_count
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_addr_inc
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data0_o
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data1_o
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data2_o
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data3_o
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/write_en
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/post_wr_data
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/wr_mem_state
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/pre_wr_data
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data0
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data1
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data2
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data3
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data_b3
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data_b2
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data_b1
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_pre_wr_data_b0
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_wr_data_b3
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_wr_data_b2
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_wr_data_b1
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_wr_data_b0
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/w_wr_be
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data0_en
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data1_en
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data2_en
add wave -noupdate -radix hexadecimal /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_mem/rd_data3_en
add wave -noupdate -divider RX_ENGENE
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/state_ascii
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tdata
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tlast
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tvalid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tuser
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tkeep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/pcie_cq_np_req_count
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tready
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/pcie_cq_np_req
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tdata
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tlast
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tvalid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tkeep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tuser
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_rc_tready
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/cfg_msg_received
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/cfg_msg_received_type
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/cfg_msg_data
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_compl
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_compl_wd
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_compl_ur
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/compl_done
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_tc
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_attr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_len
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_rid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_tag
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_be
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_addr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_at
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_des_qword0
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_des_qword1
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_des_tph_present
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_des_tph_type
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_des_tph_st_tag
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_mem_lock
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_mem
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/wr_addr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/wr_be
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/wr_data
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/wr_en
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/payload_len
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/wr_busy
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/state
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/trn_type
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/region_select
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/sop
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/in_packet_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/data_start_loc
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/io_bar_hit_n
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/mem32_bar_hit_n
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/mem64_bar_hit_n
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/erom_bar_hit_n
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_snoop_latency
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_no_snoop_latency
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_obff_code
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_msg_code
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_msg_route
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_dst_id
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_vend_id
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_vend_hdr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/req_tl_hdr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_rx/m_axis_cq_tdata_q
add wave -noupdate -divider TX_ENGENE
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/state_ascii
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tdata
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tkeep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tlast
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tvalid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tuser
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tready
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tdata
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tkeep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tlast
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tvalid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tuser
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tready
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_msg_transmit_done
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_msg_transmit
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_msg_transmit_type
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_msg_transmit_data
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_rq_tag
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_rq_tag_vld
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_tfc_nph_av
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_tfc_npd_av
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_tfc_np_pl_empty
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_rq_seq_num
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/pcie_rq_seq_num_vld
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_ph
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_nph
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_cplh
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_pd
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_npd
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_cpld
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/cfg_fc_sel
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_wd
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_ur
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/payload_len
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/compl_done
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_tc
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_td
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_ep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_attr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_len
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_rid
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_tag
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_be
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_addr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_at
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/completer_id
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_des_qword0
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_des_qword1
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_des_tph_present
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_des_tph_type
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_des_tph_st_tag
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_mem_lock
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_mem
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/rd_addr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/rd_be
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/trn_sent
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/rd_data
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/gen_transaction
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/byte_count_fbe
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/byte_count_lbe
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/lower_addr
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/lower_addr_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/lower_addr_qq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/tkeep
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/tkeep_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/tkeep_qq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_qq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_wd_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_wd_qq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_wd_qqq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_ur_q
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/req_compl_ur_qq
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/state
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_cc_tparity
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/s_axis_rq_tparity
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/dword_count
add wave -noupdate /board/EP/pcie_app_uscale_i/PIO_i/pio_ep/ep_tx/rd_data_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {179936894 ps} {185467336 ps}
