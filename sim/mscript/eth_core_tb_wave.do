onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eth_core_tb/reset
add wave -noupdate /eth_core_tb/sysclk
add wave -noupdate /eth_core_tb/sim_speedup_control_pulse
add wave -noupdate /eth_core_tb/refclk
add wave -noupdate /eth_core_tb/coreclk_out
add wave -noupdate /eth_core_tb/sampleclk
add wave -noupdate /eth_core_tb/bitclk
add wave -noupdate /eth_core_tb/tx_monitor_finished
add wave -noupdate /eth_core_tb/tx_monitor_error
add wave -noupdate /eth_core_tb/simulation_finished
add wave -noupdate /eth_core_tb/simulation_error
add wave -noupdate /eth_core_tb/frame_error
add wave -noupdate /eth_core_tb/core_ready
add wave -noupdate /eth_core_tb/tx_monitor_block_lock
add wave -noupdate /eth_core_tb/reset_error
add wave -noupdate /eth_core_tb/txp
add wave -noupdate /eth_core_tb/txn
add wave -noupdate /eth_core_tb/rxp_dut
add wave -noupdate /eth_core_tb/rxn_dut
add wave -noupdate /eth_core_tb/enable_pat_gen
add wave -noupdate /eth_core_tb/enable_pat_check
add wave -noupdate /eth_core_tb/rxp
add wave -noupdate /eth_core_tb/rxn
add wave -noupdate /eth_core_tb/test_sh
add wave -noupdate /eth_core_tb/slip
add wave -noupdate /eth_core_tb/BLSTATE
add wave -noupdate /eth_core_tb/next_blstate
add wave -noupdate /eth_core_tb/RxD
add wave -noupdate /eth_core_tb/RxD_aligned
add wave -noupdate /eth_core_tb/nbits
add wave -noupdate /eth_core_tb/sh_cnt
add wave -noupdate /eth_core_tb/sh_invalid_cnt
add wave -noupdate /eth_core_tb/i
add wave -noupdate /eth_core_tb/in_a_frame
add wave -noupdate /eth_core_tb/TxEnc
add wave -noupdate /eth_core_tb/d0
add wave -noupdate /eth_core_tb/c0
add wave -noupdate /eth_core_tb/d
add wave -noupdate /eth_core_tb/c
add wave -noupdate /eth_core_tb/decided_clk_edge
add wave -noupdate /eth_core_tb/clk_edge
add wave -noupdate /eth_core_tb/TxEnc_Data
add wave -noupdate /eth_core_tb/TxEnc_clock
add wave -noupdate /eth_core_tb/TXD_Scr
add wave -noupdate /eth_core_tb/Scrambler_Register
add wave -noupdate /eth_core_tb/TXD_input
add wave -noupdate /eth_core_tb/Sync_header
add wave -noupdate /eth_core_tb/Scr_wire
add wave -noupdate /eth_core_tb/serial_word
add wave -noupdate /eth_core_tb/rxbitno
add wave -noupdate /eth_core_tb/DeScrambler_Register
add wave -noupdate /eth_core_tb/RXD_input
add wave -noupdate /eth_core_tb/RX_Sync_header
add wave -noupdate /eth_core_tb/DeScr_wire
add wave -noupdate /eth_core_tb/DeScr_RXD
add wave -noupdate /glbl/GSR
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_aresetn
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_aclk
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_tdata
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_tkeep
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_tvalid
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_tlast
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_fifo_tready
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_fifo_full
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_fifo_status
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_aresetn
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_aclk
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_tdata
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_tkeep
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_tvalid
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_tlast
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_fifo_tready
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_fifo_status
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_aresetn
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_aclk
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_tdata
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_tkeep
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_tvalid
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_tlast
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/tx_axis_mac_tready
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_aresetn
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_aclk
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_tdata
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_tkeep
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_tvalid
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_tlast
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_axis_mac_tuser
add wave -noupdate -radix hexadecimal /eth_core_tb/dut/fifo_block_i/ethernet_mac_fifo_i/rx_fifo_full
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
WaveRestoreZoom {999207 ps} {1000042 ps}
