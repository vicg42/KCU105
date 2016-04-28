onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dev_rd_tb/i_rst
add wave -noupdate /dev_rd_tb/i_clk
add wave -noupdate /dev_rd_tb/i_rqrd_di
add wave -noupdate /dev_rd_tb/i_rqrd_wr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_fsm_rq
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_rden
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_rd
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_d
add wave -noupdate /dev_rd_tb/m_dev_rd/i_rqbuf_empty
add wave -noupdate -expand /dev_rd_tb/m_dev_rd/i_rq
add wave -noupdate -expand /dev_rd_tb/m_dev_rd/i_dev
add wave -noupdate /dev_rd_tb/m_dev_rd/i_fsm_pkt
add wave -noupdate /dev_rd_tb/m_dev_rd/i_pkt_dcnt
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_dcnt
add wave -noupdate /dev_rd_tb/m_dev_rd/i_bufo_adr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_bufo_wr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_hdr
add wave -noupdate /dev_rd_tb/m_dev_rd/i_dev_hdr_wr
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
WaveRestoreZoom {3070589 ps} {3134254 ps}
