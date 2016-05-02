onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dev_rd_tb/i_rst
add wave -noupdate /dev_rd_tb/i_clk
add wave -noupdate /dev_rd_tb/i_rqrd_di
add wave -noupdate /dev_rd_tb/i_rqrd_wr
add wave -noupdate -color {Slate Blue} -itemcolor Gold /dev_rd_tb/m_dev_rd/i_fsm_rq
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_rden
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_rd
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_d
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_empty
add wave -noupdate -expand /dev_rd_tb/m_dev_rd/i_rq
add wave -noupdate -expand /dev_rd_tb/m_dev_rd/i_dev
add wave -noupdate -color {Slate Blue} -itemcolor Gold /dev_rd_tb/m_dev_rd/i_fsm_pkt
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dcnt
add wave -noupdate -radix unsigned /dev_rd_tb/m_dev_rd/i_pkt_dcnt
add wave -noupdate /dev_rd_tb/m_dev_rd/i_bufo_adr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_bufo_di
add wave -noupdate /dev_rd_tb/m_dev_rd/i_bufo_wr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_hdr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_hdr_wr
add wave -noupdate -radix hexadecimal -childformat {{/dev_rd_tb/m_dev_rd/p_out_dev_rd(0) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(1) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(2) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(3) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(4) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(5) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(6) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(7) -radix hexadecimal} {/dev_rd_tb/m_dev_rd/p_out_dev_rd(8) -radix hexadecimal}} -subitemconfig {/dev_rd_tb/m_dev_rd/p_out_dev_rd(0) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(1) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(2) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(3) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(4) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(5) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(6) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(7) {-height 15 -radix hexadecimal} /dev_rd_tb/m_dev_rd/p_out_dev_rd(8) {-height 15 -radix hexadecimal}} /dev_rd_tb/m_dev_rd/p_out_dev_rd
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_d
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_dwr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_pkt_rdcnt
add wave -noupdate /dev_rd_tb/m_dev_rd/p_in_obuf_axi_tready
add wave -noupdate /dev_rd_tb/m_dev_rd/p_out_obuf_axi_tdata
add wave -noupdate /dev_rd_tb/m_dev_rd/p_out_obuf_axi_tvalid
add wave -noupdate /dev_rd_tb/m_dev_rd/p_out_obuf_axi_tlast
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
WaveRestoreZoom {3313858 ps} {3340812 ps}
