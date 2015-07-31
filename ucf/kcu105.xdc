###################################
#USR Port
###################################
#------ Clock ------
#set_property PACKAGE_PIN AK17 [get_ports {pin_in_refclk[M300_p]}]
#set_property IOSTANDARD LVDS [get_ports {pin_in_refclk[M300_p]}]
#create_clock -period 3.333 -name {pin_in_refclk[M300_p]} -waveform {0.000 1.667} [get_ports {pin_in_refclk[M300_p]}]
#
set_property PACKAGE_PIN G10 [get_ports {pin_in_refclk[M125_p]}]
set_property IOSTANDARD LVDS [get_ports {pin_in_refclk[M125_p]}]
create_clock -period 8.000 -name {pin_in_refclk[M125_p]} -waveform {0.000 4.000} [get_ports {pin_in_refclk[M125_p]}]
#
#set_property PACKAGE_PIN K20 [get_ports {pin_in_refclk[M90]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_refclk[M90]}]
#create_clock -period 11.111 -name {pin_in_refclk[M90]} -waveform {0.000 5.556} [get_ports {pin_in_refclk[M90]}]


#------ Pin Location ------
#CPU_RESET
set_property PACKAGE_PIN AN8 [get_ports {pin_in_btn[0]}]
#SW_N
set_property PACKAGE_PIN AD10 [get_ports {pin_in_btn[1]}]
#SW_C
set_property PACKAGE_PIN AE10 [get_ports {pin_in_btn[2]}]
#SW_E
set_property PACKAGE_PIN AF8 [get_ports {pin_in_btn[3]}]
#SW_W
set_property PACKAGE_PIN AF9 [get_ports {pin_in_btn[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[4]}]


set_property PACKAGE_PIN AP8 [get_ports {pin_out_led[0]}]
set_property PACKAGE_PIN H23 [get_ports {pin_out_led[1]}]
set_property PACKAGE_PIN P20 [get_ports {pin_out_led[2]}]
set_property PACKAGE_PIN P21 [get_ports {pin_out_led[3]}]
set_property PACKAGE_PIN N22 [get_ports {pin_out_led[4]}]
set_property PACKAGE_PIN M22 [get_ports {pin_out_led[5]}]
set_property PACKAGE_PIN R23 [get_ports {pin_out_led[6]}]
set_property PACKAGE_PIN P23 [get_ports {pin_out_led[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[7]}]


#FMC HPC (Board FMC CAMERALINK)
set_property PACKAGE_PIN D20 [get_ports {pin_out_led_hpc[0]}]
set_property PACKAGE_PIN G20 [get_ports {pin_out_led_hpc[1]}]
set_property PACKAGE_PIN H21 [get_ports {pin_out_led_hpc[2]}]
set_property PACKAGE_PIN B21 [get_ports {pin_out_led_hpc[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_hpc[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_hpc[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_hpc[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_hpc[3]}]


#FMC LPC (Board FMC 105)
set_property PACKAGE_PIN W30 [get_ports {pin_out_led_lpc[0]}]
set_property PACKAGE_PIN Y30 [get_ports {pin_out_led_lpc[1]}]
set_property PACKAGE_PIN W33 [get_ports {pin_out_led_lpc[2]}]
set_property PACKAGE_PIN Y33 [get_ports {pin_out_led_lpc[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_lpc[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_lpc[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_lpc[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_lpc[3]}]


###############################################################################
#PCI-Express
###############################################################################
# User Time Names / User Time Groups / Time Specs
create_clock -period 10.000 -name i_sys_clk [get_ports {pin_in_pcie_phy[clk_p]}]

set_false_path -from [get_ports {pin_in_pcie_phy[rst_n]}]


# User Physical Constraints
set_property LOC PCIE_3_1_X0Y0 [get_cells m_host/m_core/U0/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst]

# Pinout and Related I/O Constraints
set_property PACKAGE_PIN K22 [get_ports {pin_in_pcie_phy[rst_n]}]
set_property PULLUP true [get_ports {pin_in_pcie_phy[rst_n]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_pcie_phy[rst_n]}]

set_property LOC AB6 [get_cells m_host/m_refclk_ibuf]


###############################################################################
#Configutarion params
###############################################################################
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 115 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design ]


###############################################################################
#Debug
###############################################################################
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]

