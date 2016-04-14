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
add wave -noupdate /rx_if_tb/m_rx/i_ibuf_bcnt
add wave -noupdate -radix unsigned /rx_if_tb/m_rx/i_pkt_bcnt
add wave -noupdate /rx_if_tb/m_rx/i_pkt_bin_en
add wave -noupdate /rx_if_tb/m_rx/i_pkt_bin
add wave -noupdate /rx_if_tb/m_rx/i_fsm_pkt_rx
add wave -noupdate /rx_if_tb/m_rx/i_pkt_type
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {3009472 ps} {3202680 ps}
