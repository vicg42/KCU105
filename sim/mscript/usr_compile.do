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

C:\\questa_sim64_10.2c\\win64\\vlib work
C:\\questa_sim64_10.2c\\win64\\vlib msim

C:\\questa_sim64_10.2c\\win64\\vlib msim/xil_defaultlib
C:\\questa_sim64_10.2c\\win64\\vlib msim/gtwizard_ultrascale_v1_5

C:\\questa_sim64_10.2c\\win64\\vmap xil_defaultlib msim/xil_defaultlib
C:\\questa_sim64_10.2c\\win64\\vmap gtwizard_ultrascale_v1_5 msim/gtwizard_ultrascale_v1_5

C:\\questa_sim64_10.2c\\win64\\vlog -64 -incr -work xil_defaultlib  +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/functional +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/tests +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/imports/example_design/ep_mem.v" \
"../../src/pcie/pcie_uv7_tx.v" \
"../../src/pcie/pcie_uv7_irq.v" \
"../../src/pcie/pcie_uv7_to_ctrl.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pcie3_uscale_rp_core_top.v" \


C:\\questa_sim64_10.2c\\win64\\vlog -64 -incr -work gtwizard_ultrascale_v1_5  +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/functional +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/tests +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_bit_synchronizer.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gthe3_cpll_cal.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gthe3_cpll_cal_freq_counter.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_buffbypass_rx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_buffbypass_tx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_reset.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_userclk_rx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_userclk_tx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_userdata_rx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_gtwiz_userdata_tx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/gtwizard_ultrascale_v1_5/hdl/verilog/gtwizard_ultrascale_v1_5_reset_synchronizer.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/sim/gtwizard_ultrascale_v1_5_gthe3_channel.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/sim/pcie3_core_gt_gthe3_channel_wrapper.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/sim/pcie3_core_gt_gtwizard_gthe3.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/sim/pcie3_core_gt_gtwizard_top.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/ip_0/sim/pcie3_core_gt.v" \

C:\\questa_sim64_10.2c\\win64\\vcom -64 -work xil_defaultlib   \
"../../../../../lib/common/hw/lib/vicg/vicg_common_pkg.vhd" \
"../../../../../lib/common/hw/lib/vicg/reduce_pack.vhd" \
"../../src/prj_cfg.vhd" \
"../../src/prj_def.vhd" \
"../../src/pcie/pcie_pkg.vhd" \
"../../src/pcie/pcie_uv7_unit_pkg.vhd" \
"../../src/pcie/pcie_uv7_rx.vhd" \
"../../src/pcie/pcie_uv7_usr_app.vhd" \
"../../src/pcie/pcie_uv7_ctrl.vhd" \
"../../src/pcie/pcie_uv7_main.vhd" \
"../testbanch/pcie_uv7_main_sim.vhd" \

C:\\questa_sim64_10.2c\\win64\\vcom -64 -work xil_defaultlib   \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/sim/pcie3_core.vhd" \

C:\\questa_sim64_10.2c\\win64\\vlog -64 -incr -work xil_defaultlib  +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/functional +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/tests +incdir+../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_tph_tbl.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pipe_lane.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_16k.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_rep_8k.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_req_8k.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_gt_channel.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pipe_pipeline.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pipe_misc.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_init_ctrl.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_gt_common.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_8k.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_rep.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_req.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_sync.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram_cpl.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_rst.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_txeq.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_clk.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_bram.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_rxeq.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_gtwizard_top.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_wrapper.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pcie3_uscale_wrapper.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pcie3_uscale_top.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_phy_sync_cell.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_rxcdrhold.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sources_1/ip/pcie3_core/source/pcie3_core_pcie3_uscale_core_top.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pci_exp_usrapp_cfg.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/functional/sys_clk_gen.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pci_exp_usrapp_rx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pcie3_uscale_rp_top.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pci_exp_usrapp_tx.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/pci_exp_usrapp_com.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/functional/sys_clk_gen_ds.v" \
"../testbanch/pcie3_core_example/pcie3_core_example.srcs/sim_1/imports/pcie3_core/pcie3_core/simulation/dsport/xilinx_pcie_uscale_rp.v" \
"../testbanch/usr_board.v" \

# compile glbl module
C:\\questa_sim64_10.2c\\win64\\vlog -work xil_defaultlib "glbl.v"

#quit -force

