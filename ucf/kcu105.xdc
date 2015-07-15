###################################
#
###################################
set_property PACKAGE_PIN AK17 [get_ports {pin_in_refclk[M300_p]}]
set_property IOSTANDARD LVDS [get_ports {pin_in_refclk[M300_p]}]
create_clock -period 3.333 -name {pin_in_refclk[M300_p]} -waveform {0.000 1.667} [get_ports {pin_in_refclk[M300_p]}]

set_property PACKAGE_PIN G10 [get_ports {pin_in_refclk[M125_p]}]
set_property IOSTANDARD LVDS [get_ports {pin_in_refclk[M125_p]}]
create_clock -period 8.000 -name {pin_in_refclk[M125_p]} -waveform {0.000 4.000} [get_ports {pin_in_refclk[M125_p]}]

set_property PACKAGE_PIN AA32 [get_ports {pin_in_refclk[M90]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_refclk[M90]}]
create_clock -period 11.111 -name {pin_in_refclk[M90]} -waveform {0.000 5.556} [get_ports {pin_in_refclk[M90]}]


###################################
#
###################################
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
