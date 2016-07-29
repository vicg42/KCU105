create_project kcu105 ../vv/prj -part xcku040-ffva1156-2-e -force -verbose
set_property BOARD_PART xilinx.com:kcu105:part0:1.0 [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]
#set_property TARGET_SIMULATOR

add_files ../src/lib/debounce.vhd
add_files ../src/lib/fpga_test_01.vhd
add_files ../src/lib/reduce_pack.vhd
add_files ../src/lib/time_gen.vhd
add_files ../src/lib/vicg_common_pkg.vhd

add_files ../src/kcu105_main.vhd
set_property top kcu105_main [current_fileset]
add_files ../src/kcu105_main_unit_pkg.vhd
add_files ../src/prj_cfg.vhd
add_files ../src/prj_def.vhd
add_files ../src/timers.vhd
add_files ../src/switch_data.vhd
add_files ../src/pkt_filter.vhd
#XCI
add_files ../vv/core_gen/fifo_host2eth/fifo_host2eth.xci
add_files ../vv/core_gen/fifo_eth2host/fifo_eth2host.xci
add_files ../vv/core_gen/fifo_eth2fg/fifo_eth2fg.xci
#DBG
add_files ../vv/core_gen/dbgcs_ila_hostclk/dbgcs_ila_hostclk.xci
add_files ../vv/core_gen/dbgcs_ila_usr_highclk/dbgcs_ila_usr_highclk.xci

add_files ../src/clock/clocks.vhd
add_files ../src/clock/clocks_pkg.vhd

add_files ../src/eth/eth_main.vhd
add_files ../src/eth/eth_pkg.vhd
add_files ../src/eth/eth_mac_rx_64.vhd
add_files ../src/eth/eth_mac_tx_64.vhd
add_files ../src/eth/eth_app.v
add_files ../src/eth/eth_core_fifo_block.v
add_files ../src/eth/eth_core_sync_block.v
add_files ../src/eth/eth_core_sync_reset.v
add_files ../src/eth/fifo/eth_core_axi_fifo.v
add_files ../src/eth/fifo/eth_core_fifo_ram.v
add_files ../src/eth/fifo/eth_core_xgmac_fifo.v
#XCI
add_files ../vv/core_gen/eth_core/eth_core.xci
add_files ../vv/core_gen/eth_core_s/eth_core_s.xci

add_files ../src/fg/fg.vhd
add_files ../src/fg/fgrd.vhd
add_files ../src/fg/fgwr.vhd
add_files ../src/fg/vmirx_main.vhd
#XCI
add_files ../vv/core_gen/vmirx_bram/vmirx_bram.xci
add_files ../vv/core_gen/fg_bufo/fg_bufo.xci

add_files ../src/mem_ctrl/mem_ctrl_axi.vhd
add_files ../src/mem_ctrl/mem_ctrl_axi_pkg.vhd
add_files ../src/mem_ctrl/mem_glob_pkg.vhd
add_files ../src/mem_ctrl/mem_wr_axi.vhd
add_files ../src/mem_ctrl/mem_wr_axi_pkg.vhd
add_files ../src/mem_ctrl/mem_arb.vhd
#XCI
add_files ../vv/core_gen/mem_ctrl_core_axi/mem_ctrl_core_axi.xci
add_files ../vv/core_gen/mem_achcount2/mem_achcount2.xci
add_files ../vv/core_gen/mem_achcount3/mem_achcount3.xci

add_files ../src/pcie/pcie_pkg.vhd
add_files ../src/pcie/pcie_uv7_unit_pkg.vhd
add_files ../src/pcie/pcie_uv7_main.vhd
add_files ../src/pcie/pcie_uv7_ctrl.vhd
add_files ../src/pcie/pcie_uv7_to_ctrl.v
add_files ../src/pcie/pcie_uv7_irq.vhd
add_files ../src/pcie/pcie_uv7_rx.vhd
add_files ../src/pcie/pcie_uv7_rxcq_256.vhd
add_files ../src/pcie/pcie_uv7_rxrc_256.vhd
add_files ../src/pcie/pcie_uv7_tx.vhd
add_files ../src/pcie/pcie_uv7_txcc_256.vhd
add_files ../src/pcie/pcie_uv7_txrq_256.vhd
add_files ../src/pcie/pcie_uv7_usr_app.vhd
#XCI
add_files ../vv/core_gen/bram_dma_params/bram_dma_params.xci
add_files ../vv/core_gen/pcie3_core/pcie3_core.xci

add_files ../src/ust/ust_main.vhd
add_files ../src/ust/ust_def.vhd
add_files ../src/ust/ust_cfg.vhd
add_files ../src/ust/sync.vhd
add_files ../src/pktvd_create.vhd
add_files ../src/cam_cl_main.vhd
add_files ../src/cam_cl_pkg.vhd
#XCI
add_files ../vv/core_gen/dbgcs_ila_cam/dbgcs_ila_cam.xci

add_files ../src/cl/cl_main.vhd
add_files ../src/cl/cl_pkg.vhd
add_files ../src/cl/cl_core.vhd
add_files ../src/cl/cl_mmcm.vhd
add_files ../src/cl/cl_frprm_detector.vhd
add_files ../src/cl/cl_bufline.vhd
add_files ../src/cl/gearbox_4_to_7.vhd
#XCI
add_files ../vv/core_gen/cam_fifo_vpkt/cam_fifo_vpkt.xci
add_files ../vv/core_gen/cl_fifo_line/cl_fifo_line.xci

add_files -fileset constrs_1 ../ucf/kcu105.xdc

#generate_target all [get_files D:/Work/Yansar/prj/kcu105/vv/core_gen/cl_fifo_line/cl_fifo_line.xci]
