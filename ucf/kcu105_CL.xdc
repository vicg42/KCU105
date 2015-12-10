###################################
#USR Port
###################################
#------ Clock ------
#set_property PACKAGE_PIN AK17 [get_ports {pin_in_refclk[M300_p]}]
#set_property IOSTANDARD LVDS [get_ports {pin_in_refclk[M300_p]}]
#create_clock -period 3.333 -name {pin_in_refclk[M300_p]} -waveform {0.000 1.667} [get_ports {pin_in_refclk[M300_p]}]
#
set_property PACKAGE_PIN   G10    [get_ports {pin_in_refclk[M125_p]}]
set_property IOSTANDARD    LVDS   [get_ports {pin_in_refclk[M125_p]}]
create_clock -period 8.000 -name {pin_in_refclk[M125_p]} -waveform {0.000 4.000} [get_ports {pin_in_refclk[M125_p]}]
#
#set_property PACKAGE_PIN K20 [get_ports {pin_in_refclk[M90]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_refclk[M90]}]
#create_clock -period 11.111 -name {pin_in_refclk[M90]} -waveform {0.000 5.556} [get_ports {pin_in_refclk[M90]}]

#set_property PACKAGE_PIN     F12  [get_ports {pin_out_refclk_sel}];
#set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_refclk_sel}];

#------ Pin Location ------
#set_property PACKAGE_PIN     AD10  [get_ports {pin_in_btn[0]}]; #SW_N
#set_property PACKAGE_PIN     AE10  [get_ports {pin_in_btn[1]}]; #SW_C
#set_property PACKAGE_PIN     AF8   [get_ports {pin_in_btn[2]}]; #SW_E
#set_property PACKAGE_PIN     AF9   [get_ports {pin_in_btn[3]}]; #SW_W
#set_property PACKAGE_PIN     AN8   [get_ports {pin_in_btn[4]}]; #CPU_RESET
#set_property IOSTANDARD   LVCMOS18 [get_ports {pin_in_btn[*]}];


set_property PACKAGE_PIN     AP8   [get_ports {pin_out_led[0]}];
#set_property PACKAGE_PIN     H23   [get_ports {pin_out_led[1]}];
#set_property PACKAGE_PIN     P20   [get_ports {pin_out_led[2]}];
#set_property PACKAGE_PIN     P21   [get_ports {pin_out_led[3]}];
#set_property PACKAGE_PIN     N22   [get_ports {pin_out_led[4]}];
#set_property PACKAGE_PIN     M22   [get_ports {pin_out_led[5]}];
#set_property PACKAGE_PIN     R23   [get_ports {pin_out_led[6]}];
#set_property PACKAGE_PIN     P23   [get_ports {pin_out_led[7]}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_led[*]}];


#RS232(PC)
set_property PACKAGE_PIN     G25  [get_ports {pin_in_rs232_rx}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_in_rs232_rx}];
set_property PACKAGE_PIN     K26  [get_ports {pin_out_rs232_tx}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_rs232_tx}];

#FMC HPC (Board FMC CAMERALINK)
set_property PACKAGE_PIN    D20    [get_ports {pin_out_led_hpc[0]}];
#set_property PACKAGE_PIN    G20    [get_ports {pin_out_led_hpc[1]}];
#set_property PACKAGE_PIN    H21    [get_ports {pin_out_led_hpc[2]}];
#set_property PACKAGE_PIN    B21    [get_ports {pin_out_led_hpc[3]}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_led_hpc[*]}];


set_property PACKAGE_PIN G11 [get_ports {pin_in_cl_xclk_n}];#"FMC_HPC_LA00_CC_N"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_xclk_n}];#"FMC_HPC_LA00_CC_N"]
set_property PACKAGE_PIN H11 [get_ports {pin_in_cl_xclk_p}];#"FMC_HPC_LA00_CC_P"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_xclk_p}];#"FMC_HPC_LA00_CC_P"]
#set_property PACKAGE_PIN F9  [get_ports {pin_in_cl_yclk_n}];#"FMC_HPC_LA01_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_yclk_n}];#"FMC_HPC_LA01_CC_N"]
#set_property PACKAGE_PIN G9  [get_ports {pin_in_cl_yclk_p}];#"FMC_HPC_LA01_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_yclk_p}];#"FMC_HPC_LA01_CC_P"]
set_property PACKAGE_PIN J10 [get_ports {pin_in_cl_x_n[0]}];#"FMC_HPC_LA02_N"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_n[0]}];#"FMC_HPC_LA02_N"]
set_property PACKAGE_PIN K10 [get_ports {pin_in_cl_x_p[0]}];#"FMC_HPC_LA02_P"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_p[0]}];#"FMC_HPC_LA02_P"]
#set_property PACKAGE_PIN A12 [get_ports {pin_in_cl_x_n[1]}];#"FMC_HPC_LA03_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_n[1]}];#"FMC_HPC_LA03_N"]
#set_property PACKAGE_PIN A13 [get_ports {pin_in_cl_x_p[1]}];#"FMC_HPC_LA03_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_p[1]}];#"FMC_HPC_LA03_P"]
#set_property PACKAGE_PIN K12 [get_ports {pin_in_cl_x_n[2]}];#"FMC_HPC_LA04_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_n[2]}];#"FMC_HPC_LA04_N"]
#set_property PACKAGE_PIN L12 [get_ports {pin_in_cl_x_p[2]}];#"FMC_HPC_LA04_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_p[2]}];#"FMC_HPC_LA04_P"]
#set_property PACKAGE_PIN K13 [get_ports {pin_in_cl_x_n[3]}];#"FMC_HPC_LA05_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_n[3]}];#"FMC_HPC_LA05_N"]
#set_property PACKAGE_PIN L13 [get_ports {pin_in_cl_x_p[3]}];#"FMC_HPC_LA05_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_x_p[3]}];#"FMC_HPC_LA05_P"]
#set_property PACKAGE_PIN C13 [get_ports {pin_in_cl_y_n[0]}];#"FMC_HPC_LA06_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_n[0]}];#"FMC_HPC_LA06_N"]
#set_property PACKAGE_PIN D13 [get_ports {pin_in_cl_y_p[0]}];#"FMC_HPC_LA06_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_p[0]}];#"FMC_HPC_LA06_P"]
#set_property PACKAGE_PIN E8  [get_ports {pin_in_cl_y_n[1]}];#"FMC_HPC_LA07_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_n[1]}];#"FMC_HPC_LA07_N"]
#set_property PACKAGE_PIN F8  [get_ports {pin_in_cl_y_p[1]}];#"FMC_HPC_LA07_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_p[1]}];#"FMC_HPC_LA07_P"]
#set_property PACKAGE_PIN H8  [get_ports {pin_in_cl_y_n[2]}];#"FMC_HPC_LA08_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_n[2]}];#"FMC_HPC_LA08_N"]
#set_property PACKAGE_PIN J8  [get_ports {pin_in_cl_y_p[2]}];#"FMC_HPC_LA08_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_p[2]}];#"FMC_HPC_LA08_P"]
#set_property PACKAGE_PIN H9  [get_ports {pin_in_cl_y_n[3]}];#"FMC_HPC_LA09_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_n[3]}];#"FMC_HPC_LA09_N"]
#set_property PACKAGE_PIN J9  [get_ports {pin_in_cl_y_p[3]}];#"FMC_HPC_LA09_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_y_p[3]}];#"FMC_HPC_LA09_P"]
#set_property PACKAGE_PIN K8  [get_ports {pin_in_cl_z_n[0]}];#"FMC_HPC_LA10_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_n[0]}];#"FMC_HPC_LA10_N"]
#set_property PACKAGE_PIN L8  [get_ports {pin_in_cl_z_p[0]}];#"FMC_HPC_LA10_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_p[0]}];#"FMC_HPC_LA10_P"]
#set_property PACKAGE_PIN J11 [get_ports {pin_in_cl_z_n[1]}];#"FMC_HPC_LA11_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_n[1]}];#"FMC_HPC_LA11_N"]
#set_property PACKAGE_PIN K11 [get_ports {pin_in_cl_z_p[1]}];#"FMC_HPC_LA11_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_p[1]}];#"FMC_HPC_LA11_P"]
#set_property PACKAGE_PIN D10 [get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA12_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA12_N"]
#set_property PACKAGE_PIN E10 [get_ports {pin_in_cl_z_p[2]}];#"FMC_HPC_LA12_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_p[2]}];#"FMC_HPC_LA12_P"]
#set_property PACKAGE_PIN C9  [get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA13_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA13_N"]
#set_property PACKAGE_PIN D9  [get_ports {pin_in_cl_z_p[3]}];#"FMC_HPC_LA13_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_z_p[3]}];#"FMC_HPC_LA13_P"]
set_property PACKAGE_PIN A10 [get_ports {pin_in_cl_tfg_n}];#"FMC_HPC_LA14_N"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_tfg_n}];#"FMC_HPC_LA14_N"]
set_property PACKAGE_PIN B10 [get_ports {pin_in_cl_tfg_p}];#"FMC_HPC_LA14_P"]
set_property IOSTANDARD LVDS [get_ports {pin_in_cl_tfg_p}];#"FMC_HPC_LA14_P"]
set_property PACKAGE_PIN C8  [get_ports {pin_out_cl_tc_n}];#"FMC_HPC_LA15_N"]
set_property IOSTANDARD LVDS [get_ports {pin_out_cl_tc_n}];#"FMC_HPC_LA15_N"]
set_property PACKAGE_PIN D8  [get_ports {pin_out_cl_tc_p}];#"FMC_HPC_LA15_P"]
set_property IOSTANDARD LVDS [get_ports {pin_out_cl_tc_p}];#"FMC_HPC_LA15_P"]

#set_property PACKAGE_PIN C24 [get_ports {pin_in_cl_zclk_n}];#"FMC_HPC_LA17_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_zclk_n}];#"FMC_HPC_LA17_CC_N"]
#set_property PACKAGE_PIN D24 [get_ports {pin_in_cl_zclk_p}];#"FMC_HPC_LA17_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_zclk_p}];#"FMC_HPC_LA17_CC_P"]
#set_property PACKAGE_PIN E23 [get_ports {pin_in_cl_cc_n[1]}];#"FMC_HPC_LA18_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[1]}];#"FMC_HPC_LA18_CC_N"]
#set_property PACKAGE_PIN E22 [get_ports {pin_in_cl_cc_p[1]}];#"FMC_HPC_LA18_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[1]}];#"FMC_HPC_LA18_CC_P"]
#set_property PACKAGE_PIN C22 [get_ports {pin_in_cl_cc_n[2]}];#"FMC_HPC_LA19_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[2]}];#"FMC_HPC_LA19_N"]
#set_property PACKAGE_PIN C21 [get_ports {pin_in_cl_cc_p[2]}];#"FMC_HPC_LA19_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[2]}];#"FMC_HPC_LA19_P"]
#set_property PACKAGE_PIN A24 [get_ports {pin_in_cl_cc_n[3]}];#"FMC_HPC_LA20_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[3]}];#"FMC_HPC_LA20_N"]
#set_property PACKAGE_PIN B24 [get_ports {pin_in_cl_cc_p[3]}];#"FMC_HPC_LA20_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[3]}];#"FMC_HPC_LA20_P"]
#set_property PACKAGE_PIN F24 [get_ports {pin_in_cl_cc_n[4]}];#"FMC_HPC_LA21_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[4]}];#"FMC_HPC_LA21_N"]
#set_property PACKAGE_PIN F23 [get_ports {pin_in_cl_cc_p[4]}];#"FMC_HPC_LA21_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[4]}];#"FMC_HPC_LA21_P"]






###############################################################################
#Configutarion params
###############################################################################
set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

