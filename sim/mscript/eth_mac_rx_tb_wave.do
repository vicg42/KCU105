onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /eth_mac_rx_tb/i_rx_mac_tdata
add wave -noupdate /eth_mac_rx_tb/i_rx_mac_tkeep
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_aresetn
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_aclk
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tdata
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tkeep
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tvalid
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tlast
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tready
add wave -noupdate /eth_mac_rx_tb/m_macbuf/wr_axis_tuser
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_aresetn
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_aclk
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_tdata
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_tkeep
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_tvalid
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_tlast
add wave -noupdate /eth_mac_rx_tb/m_macbuf/rd_axis_tready
add wave -noupdate /eth_mac_rx_tb/m_macbuf/fifo_status
add wave -noupdate /eth_mac_rx_tb/m_macbuf/fifo_full
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_cfg
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_eth_axi_tready
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_eth_axi_tdata
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_eth_axi_tkeep
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_eth_axi_tvalid
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_eth_axi_tlast
add wave -noupdate -color {Slate Blue} -itemcolor Gold /eth_mac_rx_tb/m_eth_rx/i_fsm_eth_rx
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_ethrx_mac_valid
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/i_rx_wr
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_in_usr_axi_tready
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_usr_axi_tdata
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_usr_axi_tkeep
add wave -noupdate /eth_mac_rx_tb/m_eth_rx/p_out_usr_axi_tvalid
add wave -noupdate -expand /eth_mac_rx_tb/m_eth_rx/p_out_usr_axi_tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {1744903 ps} {2595433 ps}
