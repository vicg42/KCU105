######################################################################
#
# File name : board_simulate.do
# Created on: Tue Jun 30 14:52:47 +0300 2015
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L gtwizard_ultrascale_v1_5 -lib xil_defaultlib xil_defaultlib.board xil_defaultlib.glbl

do {usr_wave4.do}

view wave
view structure
view signals

do {board.udo}

run 1000ns
