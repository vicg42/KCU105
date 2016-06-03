onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ust_rd_tb/i_rst
add wave -noupdate /ust_rd_tb/i_clk
add wave -noupdate /ust_rd_tb/i_dev_drdy
add wave -noupdate /ust_rd_tb/i_dev_di
add wave -noupdate /ust_rd_tb/i_dev_rd
add wave -noupdate /ust_rd_tb/i_dev_d
add wave -noupdate /ust_rd_tb/i_dev_wr
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
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_rx/i_fsm_rqwr
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqrd_wr
add wave -noupdate /ust_rd_tb/m_rx/p_in_rqrd_rdy_n
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqwr_adr
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqwr_di
add wave -noupdate /ust_rd_tb/m_rx/p_out_rqwr_wr
add wave -noupdate /ust_rd_tb/m_rx/p_in_rqwr_rdy_n
add wave -noupdate -divider {New Divider}
add wave -noupdate /ust_rd_tb/i_rqrd_wr
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ust_rd_tb/m_dev_rd/i_fsm_rq
add wave -noupdate /ust_rd_tb/m_dev_rd/i_rqbuf_rden
add wave -noupdate /ust_rd_tb/m_dev_rd/i_rqbuf_rd
add wave -noupdate /ust_rd_tb/m_dev_rd/i_rqbuf_d
add wave -noupdate /ust_rd_tb/m_dev_rd/i_rqbuf_empty
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
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {2752389 ps} {3716005 ps}
