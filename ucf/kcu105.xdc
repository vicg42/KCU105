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

set_property PACKAGE_PIN     F12  [get_ports {pin_out_refclk_sel}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_refclk_sel}];

#------ Pin Location ------
set_property PACKAGE_PIN     AD10  [get_ports {pin_in_btn[0]}]; #SW_N
set_property PACKAGE_PIN     AE10  [get_ports {pin_in_btn[1]}]; #SW_C
set_property PACKAGE_PIN     AF8   [get_ports {pin_in_btn[2]}]; #SW_E
set_property PACKAGE_PIN     AF9   [get_ports {pin_in_btn[3]}]; #SW_W
set_property PACKAGE_PIN     AN8   [get_ports {pin_in_btn[4]}]; #CPU_RESET
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_in_btn[*]}];


set_property PACKAGE_PIN     AP8   [get_ports {pin_out_led[0]}];
set_property PACKAGE_PIN     H23   [get_ports {pin_out_led[1]}];
set_property PACKAGE_PIN     P20   [get_ports {pin_out_led[2]}];
set_property PACKAGE_PIN     P21   [get_ports {pin_out_led[3]}];
set_property PACKAGE_PIN     N22   [get_ports {pin_out_led[4]}];
set_property PACKAGE_PIN     M22   [get_ports {pin_out_led[5]}];
set_property PACKAGE_PIN     R23   [get_ports {pin_out_led[6]}];
set_property PACKAGE_PIN     P23   [get_ports {pin_out_led[7]}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_led[*]}];


#FMC HPC (Board FMC CAMERALINK)
set_property PACKAGE_PIN    D20    [get_ports {pin_out_led_hpc[0]}];
set_property PACKAGE_PIN    G20    [get_ports {pin_out_led_hpc[1]}];
set_property PACKAGE_PIN    H21    [get_ports {pin_out_led_hpc[2]}];
set_property PACKAGE_PIN    B21    [get_ports {pin_out_led_hpc[3]}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_led_hpc[*]}];


#FMC LPC (Board FMC 105)
set_property PACKAGE_PIN    W30    [get_ports {pin_out_led_lpc[0]}];
set_property PACKAGE_PIN    Y30    [get_ports {pin_out_led_lpc[1]}];
set_property PACKAGE_PIN    W33    [get_ports {pin_out_led_lpc[2]}];
set_property PACKAGE_PIN    Y33    [get_ports {pin_out_led_lpc[3]}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_led_lpc[*]}];



###############################################################################
#PCI-Express
###############################################################################
# User Time Names / User Time Groups / Time Specs
create_clock -period 10.000 -name i_sys_clk [get_ports {pin_in_pcie_phy[clk_p]}]

set_false_path -from [get_ports {pin_in_pcie_phy[rst_n]}]


# User Physical Constraints
set_property LOC PCIE_3_1_X0Y0 [get_cells m_host/m_core/U0/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst]

# Pinout and Related I/O Constraints
set_property PACKAGE_PIN      K22     [get_ports {pin_in_pcie_phy[rst_n]}]
set_property PULLUP           true    [get_ports {pin_in_pcie_phy[rst_n]}]
set_property IOSTANDARD    LVCMOS18   [get_ports {pin_in_pcie_phy[rst_n]}]

set_property LOC   AB6   [get_cells m_host/m_refclk_ibuf]


###############################################################################
#MEMCTRL
###############################################################################
#set_property PACKAGE_PIN AN8 [get_ports {pin_in_phymem[0][rst]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_phymem[0][rst]}]
#set_property DRIVE 8 [ get_ports {pin_in_phymem[0][rst]}]

set_property PACKAGE_PIN     AK17      [get_ports {pin_in_phymem[0][clk_p]}]
set_property PACKAGE_PIN     AK16      [get_ports {pin_in_phymem[0][clk_n]}]
set_property IOSTANDARD   DIFF_SSTL12  [get_ports {pin_in_phymem[0][clk_p]}]
set_property IOSTANDARD   DIFF_SSTL12  [get_ports {pin_in_phymem[0][clk_n]}]

set_property PACKAGE_PIN     AE17    [get_ports {pin_out_phymem[0][addr][0]}]
set_property PACKAGE_PIN     AH17    [get_ports {pin_out_phymem[0][addr][1]}]
set_property PACKAGE_PIN     AE18    [get_ports {pin_out_phymem[0][addr][2]}]
set_property PACKAGE_PIN     AJ15    [get_ports {pin_out_phymem[0][addr][3]}]
set_property PACKAGE_PIN     AG16    [get_ports {pin_out_phymem[0][addr][4]}]
set_property PACKAGE_PIN     AL17    [get_ports {pin_out_phymem[0][addr][5]}]
set_property PACKAGE_PIN     AK18    [get_ports {pin_out_phymem[0][addr][6]}]
set_property PACKAGE_PIN     AG17    [get_ports {pin_out_phymem[0][addr][7]}]
set_property PACKAGE_PIN     AF18    [get_ports {pin_out_phymem[0][addr][8]}]
set_property PACKAGE_PIN     AH19    [get_ports {pin_out_phymem[0][addr][9]}]
set_property PACKAGE_PIN     AF15    [get_ports {pin_out_phymem[0][addr][10]}]
set_property PACKAGE_PIN     AD19    [get_ports {pin_out_phymem[0][addr][11]}]
set_property PACKAGE_PIN     AJ14    [get_ports {pin_out_phymem[0][addr][12]}]
set_property PACKAGE_PIN     AG19    [get_ports {pin_out_phymem[0][addr][13]}]
set_property PACKAGE_PIN     AD16    [get_ports {pin_out_phymem[0][addr][14]}]
set_property PACKAGE_PIN     AG14    [get_ports {pin_out_phymem[0][addr][15]}]
set_property PACKAGE_PIN     AF14    [get_ports {pin_out_phymem[0][addr][16]}]
set_property PACKAGE_PIN     AE23    [get_ports {pin_inout_phymem[0][dq][0]}]
set_property PACKAGE_PIN     AG20    [get_ports {pin_inout_phymem[0][dq][1]}]
set_property PACKAGE_PIN     AF22    [get_ports {pin_inout_phymem[0][dq][2]}]
set_property PACKAGE_PIN     AF20    [get_ports {pin_inout_phymem[0][dq][3]}]
set_property PACKAGE_PIN     AE22    [get_ports {pin_inout_phymem[0][dq][4]}]
set_property PACKAGE_PIN     AD20    [get_ports {pin_inout_phymem[0][dq][5]}]
set_property PACKAGE_PIN     AG22    [get_ports {pin_inout_phymem[0][dq][6]}]
set_property PACKAGE_PIN     AE20    [get_ports {pin_inout_phymem[0][dq][7]}]
set_property PACKAGE_PIN     AJ24    [get_ports {pin_inout_phymem[0][dq][8]}]
set_property PACKAGE_PIN     AG24    [get_ports {pin_inout_phymem[0][dq][9]}]
set_property PACKAGE_PIN     AJ23    [get_ports {pin_inout_phymem[0][dq][10]}]
set_property PACKAGE_PIN     AF23    [get_ports {pin_inout_phymem[0][dq][11]}]
set_property PACKAGE_PIN     AH23    [get_ports {pin_inout_phymem[0][dq][12]}]
set_property PACKAGE_PIN     AF24    [get_ports {pin_inout_phymem[0][dq][13]}]
set_property PACKAGE_PIN     AH22    [get_ports {pin_inout_phymem[0][dq][14]}]
set_property PACKAGE_PIN     AG25    [get_ports {pin_inout_phymem[0][dq][15]}]
set_property PACKAGE_PIN     AL22    [get_ports {pin_inout_phymem[0][dq][16]}]
set_property PACKAGE_PIN     AL25    [get_ports {pin_inout_phymem[0][dq][17]}]
set_property PACKAGE_PIN     AM20    [get_ports {pin_inout_phymem[0][dq][18]}]
set_property PACKAGE_PIN     AK23    [get_ports {pin_inout_phymem[0][dq][19]}]
set_property PACKAGE_PIN     AK22    [get_ports {pin_inout_phymem[0][dq][20]}]
set_property PACKAGE_PIN     AL24    [get_ports {pin_inout_phymem[0][dq][21]}]
set_property PACKAGE_PIN     AL20    [get_ports {pin_inout_phymem[0][dq][22]}]
set_property PACKAGE_PIN     AL23    [get_ports {pin_inout_phymem[0][dq][23]}]
set_property PACKAGE_PIN     AM24    [get_ports {pin_inout_phymem[0][dq][24]}]
set_property PACKAGE_PIN     AN23    [get_ports {pin_inout_phymem[0][dq][25]}]
set_property PACKAGE_PIN     AN24    [get_ports {pin_inout_phymem[0][dq][26]}]
set_property PACKAGE_PIN     AP23    [get_ports {pin_inout_phymem[0][dq][27]}]
set_property PACKAGE_PIN     AP25    [get_ports {pin_inout_phymem[0][dq][28]}]
set_property PACKAGE_PIN     AN22    [get_ports {pin_inout_phymem[0][dq][29]}]
set_property PACKAGE_PIN     AP24    [get_ports {pin_inout_phymem[0][dq][30]}]
set_property PACKAGE_PIN     AM22    [get_ports {pin_inout_phymem[0][dq][31]}]
set_property PACKAGE_PIN     AH28    [get_ports {pin_inout_phymem[0][dq][32]}]
set_property PACKAGE_PIN     AK26    [get_ports {pin_inout_phymem[0][dq][33]}]
set_property PACKAGE_PIN     AK28    [get_ports {pin_inout_phymem[0][dq][34]}]
set_property PACKAGE_PIN     AM27    [get_ports {pin_inout_phymem[0][dq][35]}]
set_property PACKAGE_PIN     AJ28    [get_ports {pin_inout_phymem[0][dq][36]}]
set_property PACKAGE_PIN     AH27    [get_ports {pin_inout_phymem[0][dq][37]}]
set_property PACKAGE_PIN     AK27    [get_ports {pin_inout_phymem[0][dq][38]}]
set_property PACKAGE_PIN     AM26    [get_ports {pin_inout_phymem[0][dq][39]}]
set_property PACKAGE_PIN     AL30    [get_ports {pin_inout_phymem[0][dq][40]}]
set_property PACKAGE_PIN     AP29    [get_ports {pin_inout_phymem[0][dq][41]}]
set_property PACKAGE_PIN     AM30    [get_ports {pin_inout_phymem[0][dq][42]}]
set_property PACKAGE_PIN     AN28    [get_ports {pin_inout_phymem[0][dq][43]}]
set_property PACKAGE_PIN     AL29    [get_ports {pin_inout_phymem[0][dq][44]}]
set_property PACKAGE_PIN     AP28    [get_ports {pin_inout_phymem[0][dq][45]}]
set_property PACKAGE_PIN     AM29    [get_ports {pin_inout_phymem[0][dq][46]}]
set_property PACKAGE_PIN     AN27    [get_ports {pin_inout_phymem[0][dq][47]}]
set_property PACKAGE_PIN     AH31    [get_ports {pin_inout_phymem[0][dq][48]}]
set_property PACKAGE_PIN     AH32    [get_ports {pin_inout_phymem[0][dq][49]}]
set_property PACKAGE_PIN     AJ34    [get_ports {pin_inout_phymem[0][dq][50]}]
set_property PACKAGE_PIN     AK31    [get_ports {pin_inout_phymem[0][dq][51]}]
set_property PACKAGE_PIN     AJ31    [get_ports {pin_inout_phymem[0][dq][52]}]
set_property PACKAGE_PIN     AJ30    [get_ports {pin_inout_phymem[0][dq][53]}]
set_property PACKAGE_PIN     AH34    [get_ports {pin_inout_phymem[0][dq][54]}]
set_property PACKAGE_PIN     AK32    [get_ports {pin_inout_phymem[0][dq][55]}]
set_property PACKAGE_PIN     AN33    [get_ports {pin_inout_phymem[0][dq][56]}]
set_property PACKAGE_PIN     AP33    [get_ports {pin_inout_phymem[0][dq][57]}]
set_property PACKAGE_PIN     AM34    [get_ports {pin_inout_phymem[0][dq][58]}]
set_property PACKAGE_PIN     AP31    [get_ports {pin_inout_phymem[0][dq][59]}]
set_property PACKAGE_PIN     AM32    [get_ports {pin_inout_phymem[0][dq][60]}]
set_property PACKAGE_PIN     AN31    [get_ports {pin_inout_phymem[0][dq][61]}]
set_property PACKAGE_PIN     AL34    [get_ports {pin_inout_phymem[0][dq][62]}]
set_property PACKAGE_PIN     AN32    [get_ports {pin_inout_phymem[0][dq][63]}]
set_property PACKAGE_PIN     AD21    [get_ports {pin_inout_phymem[0][dm_dbi_n][0]}]
set_property PACKAGE_PIN     AE25    [get_ports {pin_inout_phymem[0][dm_dbi_n][1]}]
set_property PACKAGE_PIN     AJ21    [get_ports {pin_inout_phymem[0][dm_dbi_n][2]}]
set_property PACKAGE_PIN     AM21    [get_ports {pin_inout_phymem[0][dm_dbi_n][3]}]
set_property PACKAGE_PIN     AH26    [get_ports {pin_inout_phymem[0][dm_dbi_n][4]}]
set_property PACKAGE_PIN     AN26    [get_ports {pin_inout_phymem[0][dm_dbi_n][5]}]
set_property PACKAGE_PIN     AJ29    [get_ports {pin_inout_phymem[0][dm_dbi_n][6]}]
set_property PACKAGE_PIN     AL32    [get_ports {pin_inout_phymem[0][dm_dbi_n][7]}]
set_property PACKAGE_PIN     AG21    [get_ports {pin_inout_phymem[0][dqs_t][0]}]
set_property PACKAGE_PIN     AH21    [get_ports {pin_inout_phymem[0][dqs_c][0]}]
set_property PACKAGE_PIN     AH24    [get_ports {pin_inout_phymem[0][dqs_t][1]}]
set_property PACKAGE_PIN     AJ25    [get_ports {pin_inout_phymem[0][dqs_c][1]}]
set_property PACKAGE_PIN     AJ20    [get_ports {pin_inout_phymem[0][dqs_t][2]}]
set_property PACKAGE_PIN     AK20    [get_ports {pin_inout_phymem[0][dqs_c][2]}]
set_property PACKAGE_PIN     AP20    [get_ports {pin_inout_phymem[0][dqs_t][3]}]
set_property PACKAGE_PIN     AP21    [get_ports {pin_inout_phymem[0][dqs_c][3]}]
set_property PACKAGE_PIN     AL27    [get_ports {pin_inout_phymem[0][dqs_t][4]}]
set_property PACKAGE_PIN     AL28    [get_ports {pin_inout_phymem[0][dqs_c][4]}]
set_property PACKAGE_PIN     AN29    [get_ports {pin_inout_phymem[0][dqs_t][5]}]
set_property PACKAGE_PIN     AP30    [get_ports {pin_inout_phymem[0][dqs_c][5]}]
set_property PACKAGE_PIN     AH33    [get_ports {pin_inout_phymem[0][dqs_t][6]}]
set_property PACKAGE_PIN     AJ33    [get_ports {pin_inout_phymem[0][dqs_c][6]}]
set_property PACKAGE_PIN     AN34    [get_ports {pin_inout_phymem[0][dqs_t][7]}]
set_property PACKAGE_PIN     AP34    [get_ports {pin_inout_phymem[0][dqs_c][7]}]
set_property PACKAGE_PIN     AF17    [get_ports {pin_out_phymem[0][ba][0]}]
set_property PACKAGE_PIN     AL15    [get_ports {pin_out_phymem[0][ba][1]}]
set_property PACKAGE_PIN     AG15    [get_ports {pin_out_phymem[0][bg][0]}]
set_property PACKAGE_PIN     AD15    [get_ports {pin_out_phymem[0][cke][0]}]
set_property PACKAGE_PIN     AL19    [get_ports {pin_out_phymem[0][cs_n][0]}]
set_property PACKAGE_PIN     AJ18    [get_ports {pin_out_phymem[0][odt][0]}]
set_property PACKAGE_PIN     AL18    [get_ports {pin_out_phymem[0][reset_n]}]
set_property PACKAGE_PIN     AH14    [get_ports {pin_out_phymem[0][act_n]}]
set_property PACKAGE_PIN     AE15    [get_ports {pin_out_phymem[0][ck_c][0]}]
set_property PACKAGE_PIN     AE16    [get_ports {pin_out_phymem[0][ck_t][0]}]



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

