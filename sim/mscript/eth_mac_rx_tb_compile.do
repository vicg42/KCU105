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

vcom -64 -93 -work xil_defaultlib "../../../../../lib/common/hw/lib/vicg/vicg_common_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../../../../lib/common/hw/lib/vicg/reduce_pack.vhd"

vcom -64 -93 -work xil_defaultlib "../../src/prj_cfg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/prj_def.vhd"

vcom -64 -93 -work xil_defaultlib "../../src/mem_ctrl/mem_glob_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/mem_ctrl/mem_wr_axi_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/mem_ctrl/mem_ctrl_axi_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/mem_ctrl/mem_wr_axi.vhd"

vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_phypin_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_mac_rx_64.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_mac_tx_64.vhd"

vlog -64 -work xil_defaultlib "../../src/eth/eth_core_sync_reset.v"
vlog -64 -work xil_defaultlib "../../src/eth/eth_core_sync_block.v"
vlog -64 -work xil_defaultlib "../../src/eth/fifo/eth_core_fifo_ram.v"
vlog -64 -work xil_defaultlib "../../src/eth/fifo/eth_core_axi_fifo.v"
vlog -64 -work xil_defaultlib "../../src/eth/fifo/eth_core_xgmac_fifo.v"

vcom -64 -93 -work xil_defaultlib "../testbanch/eth_mac_rx_tb.vhd"

vsim -t 1ps -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.eth_mac_rx_tb


do eth_mac_rx_tb_wave.do
view wave
view structure
view signals
run 4000ns

#quit -force
