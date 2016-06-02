onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rx_if_tb/i_rst_n
add wave -noupdate /rx_if_tb/i_bufi_di
add wave -noupdate /rx_if_tb/i_bufi_wr
add wave -noupdate /rx_if_tb/i_bufi_wr_last
add wave -noupdate /rx_if_tb/m_rx/p_in_ibuf_axi_tdata
add wave -noupdate /rx_if_tb/m_rx/p_in_ibuf_axi_tvalid
add wave -noupdate /rx_if_tb/m_rx/p_out_ibuf_axi_tready
add wave -noupdate /rx_if_tb/m_rx/p_in_ibuf_axi_tlast
add wave -noupdate /rx_if_tb/m_rx/i_ibuf_rden
add wave -noupdate -color {Slate Blue} -itemcolor Gold /rx_if_tb/m_rx/i_fsm_pkt_rx
add wave -noupdate /rx_if_tb/m_rx/i_pkt_type
add wave -noupdate /rx_if_tb/m_rx/i_bcnt_a
add wave -noupdate /rx_if_tb/m_rx/i_pkt_dcnt
add wave -noupdate /rx_if_tb/m_rx/i_pkt_den
add wave -noupdate /rx_if_tb/m_rx/i_pkt_d
add wave -noupdate -color {Slate Blue} -itemcolor Gold /rx_if_tb/m_rx/i_fsm_rqwr
add wave -noupdate /rx_if_tb/m_rx/i_bcnt_b
add wave -noupdate /rx_if_tb/m_rx/i_dev_dcnt
add wave -noupdate /rx_if_tb/m_rx/p_out_rqwr_di
add wave -noupdate /rx_if_tb/m_rx/p_out_rqwr_adr
add wave -noupdate /rx_if_tb/m_rx/p_out_rqwr_wr
add wave -noupdate /rx_if_tb/m_rx/p_out_rqrd_di
add wave -noupdate /rx_if_tb/m_rx/p_out_rqrd_wr
add wave -noupdate /rx_if_tb/m_rx/p_in_rqrd_rdy_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 270
configure wave -valuecolwidth 71
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {4200 ns}
