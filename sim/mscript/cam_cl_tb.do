######################################################################
#
# File name : eth_core_tb_compile.do
# Created on: Wed Nov 04 11:57:38 +0300 2015
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
file delete -force -- work
file delete -force -- msim

vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/fifo_generator_v13_0_0

vmap xil_defaultlib msim/xil_defaultlib
vmap fifo_generator_v13_0_0 msim/fifo_generator_v13_0_0


vcom -64 -93 -work fifo_generator_v13_0_0  \
"../testbanch/cl_fifo_line_example/cl_fifo_line_example.ip_user_files/ipstatic/fifo_generator_v13_0_0/simulation/fifo_generator_vhdl_beh.vhd" \
"../testbanch/cl_fifo_line_example/cl_fifo_line_example.ip_user_files/ipstatic/fifo_generator_v13_0_0/hdl/fifo_generator_v13_0_rfs.vhd" \

vcom -64 -93 -64 -93 -work xil_defaultlib  \
"../testbanch/cl_fifo_line_example/cl_fifo_line_example.srcs/sources_1/ip/cl_fifo_line/sim/cl_fifo_line.vhd" \

vcom -64 -93 -64 -93 -work xil_defaultlib  \
"../testbanch/cam_fifo_vpkt_example/cam_fifo_vpkt_example.srcs/sources_1/ip/cam_fifo_vpkt/sim/cam_fifo_vpkt.vhd" \


vcom -64 -93 -work xil_defaultlib "../../src/lib/reduce_pack.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/lib/vicg_common_pkg.vhd" ;
vcom -64 -93 -work xil_defaultlib "../../src/prj_cfg.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/prj_def.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_pkg.vhd";
#vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_mmcm.vhd";
#vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_core.vhd";
#vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_main.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_bufline.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cl/cl_frprm_detector.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cl/gearbox_4_to_7.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/pktvd_create.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/pkt_arb.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cam_cl_pkg.vhd";
vcom -64 -93 -work xil_defaultlib "../../src/cam_cl_main.vhd";

vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_pkg.vhd"
vcom -64 -93 -work xil_defaultlib "../../src/eth/eth_mac_tx_64.vhd"

vcom -64 -93 -work xil_defaultlib "../testbanch/cam_core_tb.vhd";
vcom -64 -93 -work xil_defaultlib "../testbanch/cam_cl_tb.vhd";

## compile glbl module
#vlog -64 -93 -work xil_defaultlib "glbl.v";



vsim -t 1ps -L xil_defaultlib -L fifo_generator_v13_0_0 -lib xil_defaultlib xil_defaultlib.cam_cl_tb

do cam_cl_tb_wave.do
view wave
view structure
view signals
run 2500ns

#quit -force

