######################################################################
#
# File name : board_compile.do
# Created on: Tue Jun 30 14:52:18 +0300 2015
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
file delete -force -- work
file delete -force -- msim

vlib work

#### Vivado ####
vlib msim
vlib msim/xil_defaultlib
vlib msim/blk_mem_gen_v8_2
vmap blk_mem_gen_v8_2 msim/blk_mem_gen_v8_2

vcom -64 -93 -work blk_mem_gen_v8_2 "../../vv/prj/kcu105.srcs/sources_1/ip/bram_dma_params/blk_mem_gen_v8_2/simulation/blk_mem_gen_v8_2.vhd"
vcom -64 -93 -work xil_defaultlib "../../vv/prj/kcu105.srcs/sources_1/ip/bram_dma_params/sim/bram_dma_params.vhd"
#vcom -64 -93 -work xil_defaultlib "../testbanch/bram_dma_params.vhd"
vcom -64 -93 -work xil_defaultlib "../testbanch/bram_sim.vhd"
vlog -work xil_defaultlib "glbl.v"

vsim -t 1ps -L xil_defaultlib -L blk_mem_gen_v8_2 -lib xil_defaultlib xil_defaultlib.bram_sim xil_defaultlib.glbl


##### ISE ####
#vcom -64 -93 "../../ise/core_gen/bram_dma_params.vhd"
#vcom -64 -93 "../testbanch/bram_sim.vhd"
#vlog "glbl.v"
#
#vsim -t 1ps  -lib work bram_sim


do bram_wave.do
view wave
view structure
view signals
run 2500ns

#quit -force
