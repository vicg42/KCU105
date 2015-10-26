onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fg_tb/i_header
add wave -noupdate /fg_tb/i_vbufi_wrclk
add wave -noupdate /fg_tb/i_vbufi_wr
add wave -noupdate -expand /fg_tb/i_vbufi_di_tsim
add wave -noupdate /fg_tb/i_vbufi_empty
add wave -noupdate /fg_tb/p_in_rst
add wave -noupdate /fg_tb/p_in_clk
add wave -noupdate -radix hexadecimal /fg_tb/m_fg/p_in_vbufi_do
add wave -noupdate /fg_tb/m_fg/p_out_vbufi_rd
add wave -noupdate /fg_tb/m_fg/p_in_cfg_adr
add wave -noupdate /fg_tb/m_fg/p_in_cfg_adr_ld
add wave -noupdate /fg_tb/m_fg/p_in_cfg_txdata
add wave -noupdate /fg_tb/m_fg/p_in_cfg_wr
add wave -noupdate -expand /fg_tb/m_fg/i_prm
add wave -noupdate /fg_tb/m_fg/m_fgwr/p_out_frrdy
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_rownum
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_pixcount
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_rowcount
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fsm_cs
add wave -noupdate /fg_tb/m_fg/m_fgwr/m_mem_wr/fsm_state_cs
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
WaveRestoreZoom {1975326 ps} {2283066 ps}
