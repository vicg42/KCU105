onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ust_rd_tb/i_rst
add wave -noupdate /ust_rd_tb/i_clk
add wave -noupdate -expand -subitemconfig {/ust_rd_tb/i_dev_drdy(0)(0) -expand /ust_rd_tb/i_dev_drdy(3) -expand} /ust_rd_tb/i_dev_drdy
add wave -noupdate /ust_rd_tb/i_dev_di
add wave -noupdate /ust_rd_tb/i_dev_rd
add wave -noupdate -subitemconfig {/ust_rd_tb/i_dev_d(0) -expand /ust_rd_tb/i_dev_d(0)(8) -expand} /ust_rd_tb/i_dev_d
add wave -noupdate -expand -subitemconfig {/ust_rd_tb/i_dev_wr(3) -expand /ust_rd_tb/i_dev_wr(3)(4) -expand} /ust_rd_tb/i_dev_wr
add wave -noupdate /ust_rd_tb/i_rqrd_di
add wave -noupdate -divider PKT_RCV
add wave -noupdate /ust_rd_tb/m_ibuf/s_axis_tready
add wave -noupdate /ust_rd_tb/m_ibuf/s_axis_tdata
add wave -noupdate /ust_rd_tb/m_ibuf/s_axis_tvalid
add wave -noupdate /ust_rd_tb/m_ibuf/s_axis_tlast
add wave -noupdate /ust_rd_tb/m_ibuf/m_axis_tdata
add wave -noupdate /ust_rd_tb/m_ibuf/m_axis_tready
add wave -noupdate /ust_rd_tb/m_ibuf/m_axis_tvalid
add wave -noupdate /ust_rd_tb/m_ibuf/m_axis_tlast
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_rx/i_fsm_pkt_rx
add wave -noupdate -radix unsigned /ust_rd_tb/m_rx/i_pkt_dcnt
add wave -noupdate /ust_rd_tb/m_rx/i_pkt_type
add wave -noupdate /ust_rd_tb/m_rx/i_pkt_den
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqrd_di
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqrd_wr
add wave -noupdate /ust_rd_tb/m_rx/p_in_rqrd_rdy_n
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqwr_di
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqwr_wr
add wave -noupdate /ust_rd_tb/m_rx/p_in_rqwr_rdy_n
add wave -noupdate -divider DEV_WR
add wave -noupdate /ust_rd_tb/m_dev_wr/i_rqfifo_empty
add wave -noupdate /ust_rd_tb/m_dev_wr/i_rqfifo_rd
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_dev_wr/i_fsm_rq
add wave -noupdate /ust_rd_tb/m_dev_wr/i_bcnt
add wave -noupdate /ust_rd_tb/m_dev_wr/i_rq_len
add wave -noupdate /ust_rd_tb/m_dev_wr/i_rq_id
add wave -noupdate -expand /ust_rd_tb/m_dev_wr/i_dev
add wave -noupdate /ust_rd_tb/m_dev_wr/i_dcnt
add wave -noupdate -radix hexadecimal -childformat {{/ust_rd_tb/m_dev_wr/i_dev_rdy(71) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(70) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(69) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(68) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(67) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(66) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(65) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(64) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(63) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(62) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(61) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(60) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(59) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(58) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(57) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(56) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(55) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(54) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(53) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(52) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(51) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(50) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(49) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(48) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(47) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(46) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(45) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(44) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(43) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(42) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(41) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(40) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(39) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(38) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(37) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(36) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(35) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(34) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(33) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(32) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(31) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(30) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(29) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(28) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(27) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(26) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(25) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(24) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(23) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(22) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(21) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(20) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(19) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(18) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(17) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(16) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(15) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(14) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(13) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(12) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(11) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(10) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(9) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(8) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(7) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(6) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(5) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(4) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(3) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(2) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(1) -radix hexadecimal} {/ust_rd_tb/m_dev_wr/i_dev_rdy(0) -radix hexadecimal}} -subitemconfig {/ust_rd_tb/m_dev_wr/i_dev_rdy(71) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(70) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(69) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(68) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(67) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(66) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(65) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(64) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(63) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(62) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(61) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(60) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(59) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(58) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(57) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(56) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(55) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(54) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(53) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(52) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(51) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(50) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(49) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(48) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(47) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(46) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(45) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(44) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(43) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(42) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(41) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(40) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(39) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(38) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(37) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(36) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(35) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(34) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(33) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(32) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(31) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(30) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(29) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(28) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(27) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(26) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(25) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(24) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(23) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(22) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(21) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(20) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(19) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(18) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(17) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(16) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(15) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(14) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(13) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(12) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(11) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(10) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(9) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(8) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(7) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(6) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(5) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(4) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(3) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(2) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(1) {-radix hexadecimal} /ust_rd_tb/m_dev_wr/i_dev_rdy(0) {-radix hexadecimal}} /ust_rd_tb/m_dev_wr/i_dev_rdy
add wave -noupdate -expand -subitemconfig {/ust_rd_tb/m_dev_wr/p_in_dev_rdy(3) -expand /ust_rd_tb/m_dev_wr/p_in_dev_rdy(3)(2) -expand /ust_rd_tb/m_dev_wr/p_in_dev_rdy(3)(3) -expand} /ust_rd_tb/m_dev_wr/p_in_dev_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /ust_rd_tb/i_rqrd_wr
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_dev_rd/i_fsm_rq
add wave -noupdate /ust_rd_tb/m_dev_rd/i_rq
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dev
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_dev_rd/i_fsm_pkt
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dcnt
add wave -noupdate -radix unsigned /ust_rd_tb/m_dev_rd/i_pkt_dcnt
add wave -noupdate /ust_rd_tb/m_dev_rd/i_bufo_adr
add wave -noupdate /ust_rd_tb/m_dev_rd/i_bufo_di
add wave -noupdate /ust_rd_tb/m_dev_rd/i_bufo_do
add wave -noupdate /ust_rd_tb/m_dev_rd/i_bufo_rd
add wave -noupdate /ust_rd_tb/m_dev_rd/i_bufo_wr
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dev_hdr
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dev_hdr_wr
add wave -noupdate -radix hexadecimal -childformat {{/ust_rd_tb/m_dev_rd/p_out_dev_rd(0) -radix hexadecimal} {/ust_rd_tb/m_dev_rd/p_out_dev_rd(1) -radix hexadecimal} {/ust_rd_tb/m_dev_rd/p_out_dev_rd(2) -radix hexadecimal} {/ust_rd_tb/m_dev_rd/p_out_dev_rd(3) -radix hexadecimal}} -subitemconfig {/ust_rd_tb/m_dev_rd/p_out_dev_rd(0) {-height 15 -radix hexadecimal} /ust_rd_tb/m_dev_rd/p_out_dev_rd(1) {-height 15 -radix hexadecimal} /ust_rd_tb/m_dev_rd/p_out_dev_rd(2) {-height 15 -radix hexadecimal} /ust_rd_tb/m_dev_rd/p_out_dev_rd(3) {-height 15 -radix hexadecimal}} /ust_rd_tb/m_dev_rd/p_out_dev_rd
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dev_d
add wave -noupdate /ust_rd_tb/m_dev_rd/i_dev_dwr
add wave -noupdate /ust_rd_tb/m_dev_rd/i_pkt_rdcnt
add wave -noupdate /ust_rd_tb/m_dev_rd/p_in_obuf_axi_tready
add wave -noupdate /ust_rd_tb/m_dev_rd/p_out_obuf_axi_tdata
add wave -noupdate /ust_rd_tb/m_dev_rd/p_out_obuf_axi_tvalid
add wave -noupdate /ust_rd_tb/m_dev_rd/p_out_obuf_axi_tlast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3078900 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
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
WaveRestoreZoom {3058159 ps} {3094569 ps}
