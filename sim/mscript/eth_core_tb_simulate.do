######################################################################
#
# File name : eth_core_demo_tb_simulate.do
# Created on: Wed Nov 04 11:57:58 +0300 2015
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver \
-L secureip -L ten_gig_eth_mac_v15_0 -L gtwizard_ultrascale_v1_5 -L ten_gig_eth_pcs_pma_v6_0 -L xil_defaultlib \
-lib xil_defaultlib xil_defaultlib.eth_core_demo_tb xil_defaultlib.glbl


do {eth_core_demo_tb_wave.do}

view wave
view structure
view signals

do {eth_core_demo_tb.udo}

run 1000ns
