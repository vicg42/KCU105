onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/p_out_link
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/p_out_rxbyte
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/i_fsm
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/i_rst
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/i_clk
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/i_cnt
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/i_linecnt
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/p_out_fval
add wave -noupdate /cam_cl_tb/m_cam/m_cl_if/p_out_lval
add wave -noupdate -divider {New Divider}
add wave -noupdate /cam_cl_tb/m_cam/m_frprm_detector/i_fsm_vprm
add wave -noupdate /cam_cl_tb/m_cam/m_frprm_detector/i_cnt
add wave -noupdate /cam_cl_tb/m_cam/m_frprm_detector/i_det_done
add wave -noupdate /cam_cl_tb/m_cam/m_frprm_detector/i_pixcount
add wave -noupdate /cam_cl_tb/m_cam/m_frprm_detector/i_linecount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_frprm_detector/p_out_pixcount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_frprm_detector/p_out_linecount
add wave -noupdate -divider {New Divider}
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/p_in_fval
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/p_in_lval
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/p_in_lval(0)
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/p_in_dval
add wave -noupdate -radix unsigned -childformat {{/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(63) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(62) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(61) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(60) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(59) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(58) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(57) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(56) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(55) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(54) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(53) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(52) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(51) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(50) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(49) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(48) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(47) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(46) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(45) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(44) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(43) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(42) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(41) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(40) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(39) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(38) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(37) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(36) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(35) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(34) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(33) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(32) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(31) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(30) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(29) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(28) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(27) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(26) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(25) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(24) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(23) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(22) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(21) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(20) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(19) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(18) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(17) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(16) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(15) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(14) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(13) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(12) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(11) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(10) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(9) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(8) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(7) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(6) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(5) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(4) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(3) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(2) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(1) -radix unsigned} {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(0) -radix unsigned}} -subitemconfig {/cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(63) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(62) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(61) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(60) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(59) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(58) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(57) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(56) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(55) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(54) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(53) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(52) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(51) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(50) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(49) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(48) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(47) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(46) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(45) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(44) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(43) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(42) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(41) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(40) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(39) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(38) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(37) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(36) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(35) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(34) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(33) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(32) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(31) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(30) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(29) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(28) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(27) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(26) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(25) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(24) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(23) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(22) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(21) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(20) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(19) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(18) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(17) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(16) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(15) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(14) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(13) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(12) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(11) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(10) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(9) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(8) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(7) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(6) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(5) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(4) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(3) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(2) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(1) {-height 15 -radix unsigned} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte(0) {-height 15 -radix unsigned}} /cam_cl_tb/m_cam/m_cl_bufline/p_in_rxbyte
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/i_buf_wr
add wave -noupdate /cam_cl_tb/m_cam/i_rxclk(0)
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/i_buf_empty
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/p_out_buf_do
add wave -noupdate /cam_cl_tb/m_cam/p_in_bufpkt_rdclk
add wave -noupdate /cam_cl_tb/m_cam/m_cl_bufline/i_buf_rst
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/p_in_det_pixcount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/p_in_det_linecount
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_err
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_in_vsync
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_in_hsync
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_in_bufi_empty
add wave -noupdate -color {Slate Blue} -itemcolor Gold /cam_cl_tb/m_cam/m_vpkt/i_fsm_vpkt
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_rdy
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_time
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_fr_pixcount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_fr_linecount
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_fr_cnt
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_remain_pixcount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_tx_pixcount
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_pkt_pixcnt
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/i_line_cnt
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_pkt_d
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_pkt_wr
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_pkt_den
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_padding
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/i_bufi_rst
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_in_bufi_do
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_in_bufi_empty
add wave -noupdate -radix hexadecimal /cam_cl_tb/m_cam/m_vpkt/p_out_pkt_do
add wave -noupdate /cam_cl_tb/m_cam/m_vpkt/p_out_pkt_wr
add wave -noupdate -radix unsigned /cam_cl_tb/m_cam/m_vpkt/tst_cnt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /cam_cl_tb/m_cam/p_out_bufpkt_d
add wave -noupdate /cam_cl_tb/m_cam/p_in_bufpkt_rd
add wave -noupdate /cam_cl_tb/m_cam/p_in_bufpkt_rdclk
add wave -noupdate /cam_cl_tb/m_cam/p_out_bufpkt_empty
add wave -noupdate -color {Slate Blue} -itemcolor Gold /cam_cl_tb/m_eth_tx/i_fsm_eth_tx
add wave -noupdate /cam_cl_tb/m_eth_tx/i_total_count_byte
add wave -noupdate /cam_cl_tb/m_eth_tx/i_rd_chunk_cnt
add wave -noupdate /cam_cl_tb/m_eth_tx/i_rd_chunk_count
add wave -noupdate /cam_cl_tb/m_eth_tx/i_rd_chunk_rem
add wave -noupdate /cam_cl_tb/m_eth_tx/p_out_eth_axi_tdata
add wave -noupdate /cam_cl_tb/m_eth_tx/p_out_eth_axi_tkeep
add wave -noupdate /cam_cl_tb/m_eth_tx/p_out_eth_axi_tvalid
add wave -noupdate /cam_cl_tb/m_eth_tx/p_out_eth_axi_tlast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {178448000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 177
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
WaveRestoreZoom {178381057 ps} {178670233 ps}
