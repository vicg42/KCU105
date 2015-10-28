onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fgwr_tb/i_header
add wave -noupdate /fgwr_tb/i_vbufi_wrclk
add wave -noupdate /fgwr_tb/i_vbufi_wr
add wave -noupdate -expand /fgwr_tb/i_vbufi_di_tsim
add wave -noupdate /fgwr_tb/i_vbufi_empty
add wave -noupdate /fgwr_tb/p_in_rst
add wave -noupdate /fgwr_tb/p_in_clk
add wave -noupdate -radix hexadecimal /fgwr_tb/m_fgwr/p_in_vbufi_do
add wave -noupdate /fgwr_tb/m_fgwr/p_out_vbufi_rd
add wave -noupdate -color {Slate Blue} -itemcolor Gold /fgwr_tb/m_fgwr/i_fsm_fgwr
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_bufnum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_pixnum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rownum
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_pixcount
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rowcount
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_fr_rowmrk
add wave -noupdate -radix unsigned /fgwr_tb/m_fgwr/i_ch_num
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
WaveRestoreZoom {0 ps} {5250 ns}
