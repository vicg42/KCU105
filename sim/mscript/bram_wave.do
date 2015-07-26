onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/addra
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/dina
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/douta
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/wea(0)
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/ena
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/clka
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/addrb
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/dinb
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/doutb
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/web(0)
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/enb
add wave -noupdate -radix hexadecimal /bram_sim/m_bram/clkb
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
WaveRestoreZoom {1458019 ps} {1689859 ps}
