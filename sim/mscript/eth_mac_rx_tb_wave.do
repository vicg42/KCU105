onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /eth_mac_rx_tb/i_rx_mac_tdata
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_mac_tvalid
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_mac_tlast
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_mac_tuser
add wave -noupdate /eth_mac_rx_tb/i_rx_mac_tkeep
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_fifo_tdata
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_fifo_tvalid
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_fifo_tlast
add wave -noupdate /eth_mac_rx_tb/i_rx_axis_fifo_tready
add wave -noupdate -expand /eth_mac_rx_tb/m_eth_rx/i_ethrx_d
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_cfg
add wave -noupdate -color {Slate Blue} -itemcolor Gold /eth_mac_rx_tb/m_eth_rx/i_fsm_eth_rx
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_ethrx_mac_valid
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rx_dv
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rx_wr
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rx_sof
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rx_eof
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_chunk_cnt
add wave -noupdate -expand /eth_mac_rx_tb/m_eth_rx/i_rxbuf_di
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_rxbuf_di
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_rxbuf_wr
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_rxbuf_full
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_rxbuf_sof
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_rxbuf_eof
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rxbuf_sof_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors
quietly wave cursor active 0
configure wave -namecolwidth 172
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
WaveRestoreZoom {2040967 ps} {2064891 ps}
