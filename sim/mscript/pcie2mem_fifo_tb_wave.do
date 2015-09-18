onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pcie2mem_fifo_tb/i_rst
add wave -noupdate -divider TX
add wave -noupdate -radix hexadecimal /pcie2mem_fifo_tb/fifo/wr_clk
add wave -noupdate -radix unsigned /pcie2mem_fifo_tb/fifo/din
add wave -noupdate -radix hexadecimal /pcie2mem_fifo_tb/fifo/wr_en
add wave -noupdate -radix unsigned /pcie2mem_fifo_tb/i_fifo_wr_cnt
add wave -noupdate /pcie2mem_fifo_tb/fifo/prog_full
add wave -noupdate /pcie2mem_fifo_tb/fifo/full
add wave -noupdate -divider RX
add wave -noupdate -radix hexadecimal /pcie2mem_fifo_tb/fifo/rd_clk
add wave -noupdate /pcie2mem_fifo_tb/fifo/empty
add wave -noupdate -radix unsigned /pcie2mem_fifo_tb/fifo/dout
add wave -noupdate -radix hexadecimal /pcie2mem_fifo_tb/fifo/rd_en
add wave -noupdate -radix unsigned /pcie2mem_fifo_tb/i_fifo_rd_cnt
add wave -noupdate -radix unsigned /pcie2mem_fifo_tb/p_out_dout
add wave -noupdate -divider STATUS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2194600 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {1685229 ps} {3188301 ps}
