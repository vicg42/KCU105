open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308957412]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308957412]
open_hw_target
set_property PROGRAM.FILE {../firmware/kcu105_main.bit} [lindex [get_hw_devices] 0]
#set_property PROBES.FILE {../vv/debug_nets.ltx} [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
disconnect_hw_server localhost:3121