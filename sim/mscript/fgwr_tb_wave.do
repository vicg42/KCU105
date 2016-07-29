onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fgwr_tb/i_header
add wave -noupdate /fgwr_tb/i_vbufi_wrclk
add wave -noupdate /fgwr_tb/i_vbufi_wr
add wave -noupdate -expand /fgwr_tb/i_vbufi_di_tsim
add wave -noupdate /fgwr_tb/i_vbufi_empty
add wave -noupdate /fgwr_tb/p_in_rst
add wave -noupdate /fgwr_tb/p_in_clk
add wave -noupdate -radix hexadecimal -childformat {{/fgwr_tb/m_fgwr/p_in_vbufi_do(63) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(62) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(61) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(60) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(59) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(58) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(57) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(56) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(55) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(54) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(53) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(52) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(51) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(50) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(49) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(48) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(47) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(46) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(45) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(44) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(43) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(42) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(41) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(40) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(39) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(38) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(37) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(36) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(35) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(34) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(33) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(32) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(31) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(30) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(29) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(28) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(27) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(26) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(25) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(24) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(23) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(22) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(21) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(20) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(19) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(18) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(17) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(16) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(15) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(14) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(13) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(12) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(11) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(10) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(9) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(8) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(7) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(6) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(5) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(4) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(3) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(2) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(1) -radix hexadecimal} {/fgwr_tb/m_fgwr/p_in_vbufi_do(0) -radix hexadecimal}} -subitemconfig {/fgwr_tb/m_fgwr/p_in_vbufi_do(63) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(62) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(61) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(60) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(59) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(58) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(57) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(56) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(55) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(54) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(53) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(52) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(51) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(50) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(49) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(48) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(47) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(46) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(45) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(44) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(43) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(42) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(41) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(40) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(39) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(38) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(37) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(36) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(35) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(34) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(33) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(32) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(31) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(30) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(29) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(28) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(27) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(26) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(25) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(24) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(23) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(22) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(21) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(20) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(19) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(18) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(17) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(16) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(15) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(14) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(13) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(12) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(11) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(10) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(9) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(8) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(7) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(6) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(5) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(4) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(3) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(2) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(1) {-height 15 -radix hexadecimal} /fgwr_tb/m_fgwr/p_in_vbufi_do(0) {-height 15 -radix hexadecimal}} /fgwr_tb/m_fgwr/p_in_vbufi_do
add wave -noupdate -expand /fgwr_tb/m_fgwr/p_out_vbufi_rd
add wave -noupdate -color {Slate Blue} -itemcolor Gold /fgwr_tb/m_fgwr/i_fsm_fgwr
add wave -noupdate /fgwr_tb/m_fgwr/i_vbufi_rden
add wave -noupdate /fgwr_tb/m_fgwr/i_err
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_bufnum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_pixnum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rownum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_pixcount
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rowcount
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rowmrk
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_mem_adr_base
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_pkt_size_byte
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_pixcount_byte
add wave -noupdate /fgwr_tb/m_fgwr/p_out_frrdy
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_cfg_mem_adr
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_cfg_mem_trn_len
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_cfg_mem_dlen_rq
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_cfg_mem_wr
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_cfg_mem_start
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_out_cfg_mem_done
add wave -noupdate -color {Slate Blue} -itemcolor Gold /fgwr_tb/m_fgwr/m_mem_wr/i_fsm_memwr
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/i_mem_dlen_remain
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/i_mem_dlen_used
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/i_mem_trn_work
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/i_mem_trn_len
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/i_mem_adr
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_usr_txbuf_dout
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_out_usr_txbuf_rd
add wave -noupdate /fgwr_tb/m_fgwr/m_mem_wr/p_in_usr_txbuf_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2017031 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 215
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
WaveRestoreZoom {1726723 ps} {4824667 ps}
