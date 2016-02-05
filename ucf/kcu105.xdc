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

#create_clock -period 11.765 -name camera_link_clk -waveform {0.000 5.882} [get_ports {{pin_in_cl_clk_p[0]} {pin_in_cl_clk_p[1]} {pin_in_cl_clk_p[2]}}]

set_property PACKAGE_PIN     F12  [get_ports {pin_out_refclk_sel}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_refclk_sel}];

#------ Pin Location ------
#set_property PACKAGE_PIN     AD10  [get_ports {pin_in_btn[4]}]; #SW_N
set_property PACKAGE_PIN     AE10  [get_ports {pin_in_btn[1]}]; #SW_C (SW7)
#set_property PACKAGE_PIN     AF8   [get_ports {pin_in_btn[2]}]; #SW_E
#set_property PACKAGE_PIN     AF9   [get_ports {pin_in_btn[3]}]; #SW_W
set_property PACKAGE_PIN     AN8   [get_ports {pin_in_btn[0]}]; #CPU_RESET
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
#Eth10G
###############################################################################
set_property PACKAGE_PIN P6 [get_ports pin_in_ethphy_refclk_p]
set_property PACKAGE_PIN K21 [get_ports {pin_in_sfp_los[0]}]
set_property PACKAGE_PIN AM9 [get_ports {pin_in_sfp_los[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_sfp_los[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_sfp_los[1]}]

set_property PACKAGE_PIN AL8 [get_ports {pin_out_sfp_tx_dis[0]}]
set_property PACKAGE_PIN D28 [get_ports {pin_out_sfp_tx_dis[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_sfp_tx_dis[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_sfp_tx_dis[1]}]


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


################################################################################
##RS232(PC)
################################################################################
#set_property PACKAGE_PIN     G25  [get_ports {pin_in_rs232_rx}];
#set_property IOSTANDARD   LVCMOS18 [get_ports {pin_in_rs232_rx}];
#set_property PACKAGE_PIN     K26  [get_ports {pin_out_rs232_tx}];
#set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_rs232_tx}];
#
################################################################################
##CameraLink
################################################################################
#set_property PACKAGE_PIN G11 [get_ports {pin_in_cl_clk_n[0]}];#[get_ports {pin_in_cl_xclk_n}];#"FMC_HPC_LA00_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_n[0]}];#[get_ports {pin_in_cl_xclk_n}];#"FMC_HPC_LA00_CC_N"]
#set_property PACKAGE_PIN H11 [get_ports {pin_in_cl_clk_p[0]}];#[get_ports {pin_in_cl_xclk_p}];#"FMC_HPC_LA00_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_p[0]}];#[get_ports {pin_in_cl_xclk_p}];#"FMC_HPC_LA00_CC_P"]
#set_property PACKAGE_PIN F9  [get_ports {pin_in_cl_clk_n[1]}];#[get_ports {pin_in_cl_yclk_n}];#"FMC_HPC_LA01_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_n[1]}];#[get_ports {pin_in_cl_yclk_n}];#"FMC_HPC_LA01_CC_N"]
#set_property PACKAGE_PIN G9  [get_ports {pin_in_cl_clk_p[1]}];#[get_ports {pin_in_cl_yclk_p}];#"FMC_HPC_LA01_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_p[1]}];#[get_ports {pin_in_cl_yclk_p}];#"FMC_HPC_LA01_CC_P"]
#set_property PACKAGE_PIN J10 [get_ports {pin_in_cl_di_n[0]}];#[get_ports {pin_in_cl_x_n[0]}];#"FMC_HPC_LA02_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[0]}];#[get_ports {pin_in_cl_x_n[0]}];#"FMC_HPC_LA02_N"]
#set_property PACKAGE_PIN K10 [get_ports {pin_in_cl_di_p[0]}];#[get_ports {pin_in_cl_x_p[0]}];#"FMC_HPC_LA02_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[0]}];#[get_ports {pin_in_cl_x_p[0]}];#"FMC_HPC_LA02_P"]
#set_property PACKAGE_PIN A12 [get_ports {pin_in_cl_di_n[1]}];#[get_ports {pin_in_cl_x_n[1]}];#"FMC_HPC_LA03_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[1]}];#[get_ports {pin_in_cl_x_n[1]}];#"FMC_HPC_LA03_N"]
#set_property PACKAGE_PIN A13 [get_ports {pin_in_cl_di_p[1]}];#[get_ports {pin_in_cl_x_p[1]}];#"FMC_HPC_LA03_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[1]}];#[get_ports {pin_in_cl_x_p[1]}];#"FMC_HPC_LA03_P"]
#set_property PACKAGE_PIN K12 [get_ports {pin_in_cl_di_n[2]}];#[get_ports {pin_in_cl_x_n[2]}];#"FMC_HPC_LA04_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[2]}];#[get_ports {pin_in_cl_x_n[2]}];#"FMC_HPC_LA04_N"]
#set_property PACKAGE_PIN L12 [get_ports {pin_in_cl_di_p[2]}];#[get_ports {pin_in_cl_x_p[2]}];#"FMC_HPC_LA04_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[2]}];#[get_ports {pin_in_cl_x_p[2]}];#"FMC_HPC_LA04_P"]
#set_property PACKAGE_PIN K13 [get_ports {pin_in_cl_di_n[3]}];#[get_ports {pin_in_cl_x_n[3]}];#"FMC_HPC_LA05_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[3]}];#[get_ports {pin_in_cl_x_n[3]}];#"FMC_HPC_LA05_N"]
#set_property PACKAGE_PIN L13 [get_ports {pin_in_cl_di_p[3]}];#[get_ports {pin_in_cl_x_p[3]}];#"FMC_HPC_LA05_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[3]}];#[get_ports {pin_in_cl_x_p[3]}];#"FMC_HPC_LA05_P"]
#set_property PACKAGE_PIN C13 [get_ports {pin_in_cl_di_n[4]}];#[get_ports {pin_in_cl_y_n[0]}];#"FMC_HPC_LA06_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[4]}];#[get_ports {pin_in_cl_y_n[0]}];#"FMC_HPC_LA06_N"]
#set_property PACKAGE_PIN D13 [get_ports {pin_in_cl_di_p[4]}];#[get_ports {pin_in_cl_y_p[0]}];#"FMC_HPC_LA06_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[4]}];#[get_ports {pin_in_cl_y_p[0]}];#"FMC_HPC_LA06_P"]
#set_property PACKAGE_PIN E8  [get_ports {pin_in_cl_di_n[5]}];#[get_ports {pin_in_cl_y_n[1]}];#"FMC_HPC_LA07_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[5]}];#[get_ports {pin_in_cl_y_n[1]}];#"FMC_HPC_LA07_N"]
#set_property PACKAGE_PIN F8  [get_ports {pin_in_cl_di_p[5]}];#[get_ports {pin_in_cl_y_p[1]}];#"FMC_HPC_LA07_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[5]}];#[get_ports {pin_in_cl_y_p[1]}];#"FMC_HPC_LA07_P"]
#set_property PACKAGE_PIN H8  [get_ports {pin_in_cl_di_n[6]}];#[get_ports {pin_in_cl_y_n[2]}];#"FMC_HPC_LA08_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[6]}];#[get_ports {pin_in_cl_y_n[2]}];#"FMC_HPC_LA08_N"]
#set_property PACKAGE_PIN J8  [get_ports {pin_in_cl_di_p[6]}];#[get_ports {pin_in_cl_y_p[2]}];#"FMC_HPC_LA08_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[6]}];#[get_ports {pin_in_cl_y_p[2]}];#"FMC_HPC_LA08_P"]
#set_property PACKAGE_PIN H9  [get_ports {pin_in_cl_di_n[7]}];#[get_ports {pin_in_cl_y_n[3]}];#"FMC_HPC_LA09_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[7]}];#[get_ports {pin_in_cl_y_n[3]}];#"FMC_HPC_LA09_N"]
#set_property PACKAGE_PIN J9  [get_ports {pin_in_cl_di_p[7]}];#[get_ports {pin_in_cl_y_p[3]}];#"FMC_HPC_LA09_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[7]}];#[get_ports {pin_in_cl_y_p[3]}];#"FMC_HPC_LA09_P"]
#set_property PACKAGE_PIN K8  [get_ports {pin_in_cl_di_n[8]}];#[get_ports {pin_in_cl_z_n[0]}];#"FMC_HPC_LA10_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[8]}];#[get_ports {pin_in_cl_z_n[0]}];#"FMC_HPC_LA10_N"]
#set_property PACKAGE_PIN L8  [get_ports {pin_in_cl_di_p[8]}];#[get_ports {pin_in_cl_z_p[0]}];#"FMC_HPC_LA10_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[8]}];#[get_ports {pin_in_cl_z_p[0]}];#"FMC_HPC_LA10_P"]
#set_property PACKAGE_PIN J11 [get_ports {pin_in_cl_di_n[9]}];#[get_ports {pin_in_cl_z_n[1]}];#"FMC_HPC_LA11_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[9]}];#[get_ports {pin_in_cl_z_n[1]}];#"FMC_HPC_LA11_N"]
#set_property PACKAGE_PIN K11 [get_ports {pin_in_cl_di_p[9]}];#[get_ports {pin_in_cl_z_p[1]}];#"FMC_HPC_LA11_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[9]}];#[get_ports {pin_in_cl_z_p[1]}];#"FMC_HPC_LA11_P"]
#set_property PACKAGE_PIN D10 [get_ports {pin_in_cl_di_n[10]}];#[get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA12_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[10]}];#[get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA12_N"]
#set_property PACKAGE_PIN E10 [get_ports {pin_in_cl_di_p[10]}];#[get_ports {pin_in_cl_z_p[2]}];#"FMC_HPC_LA12_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[10]}];#[get_ports {pin_in_cl_z_p[2]}];#"FMC_HPC_LA12_P"]
#set_property PACKAGE_PIN C9  [get_ports {pin_in_cl_di_n[11]}];#[get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA13_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_n[11]}];#[get_ports {pin_in_cl_z_n[2]}];#"FMC_HPC_LA13_N"]
#set_property PACKAGE_PIN D9  [get_ports {pin_in_cl_di_p[11]}];#[get_ports {pin_in_cl_z_p[3]}];#"FMC_HPC_LA13_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_di_p[11]}];#[get_ports {pin_in_cl_z_p[3]}];#"FMC_HPC_LA13_P"]
#set_property PACKAGE_PIN A10 [get_ports {pin_in_cl_tfg_n}];#"FMC_HPC_LA14_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_tfg_n}];#"FMC_HPC_LA14_N"]
#set_property PACKAGE_PIN B10 [get_ports {pin_in_cl_tfg_p}];#"FMC_HPC_LA14_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_tfg_p}];#"FMC_HPC_LA14_P"]
#set_property PACKAGE_PIN C8  [get_ports {pin_out_cl_tc_n}];#"FMC_HPC_LA15_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_out_cl_tc_n}];#"FMC_HPC_LA15_N"]
#set_property PACKAGE_PIN D8  [get_ports {pin_out_cl_tc_p}];#"FMC_HPC_LA15_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_out_cl_tc_p}];#"FMC_HPC_LA15_P"]
#
#set_property PACKAGE_PIN C24 [get_ports {pin_in_cl_clk_n[2]}];#[get_ports {pin_in_cl_zclk_n}];#"FMC_HPC_LA17_CC_N"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_n[2]}];#[get_ports {pin_in_cl_zclk_n}];#"FMC_HPC_LA17_CC_N"]
#set_property PACKAGE_PIN D24 [get_ports {pin_in_cl_clk_p[2]}];#[get_ports {pin_in_cl_zclk_p}];#"FMC_HPC_LA17_CC_P"]
#set_property IOSTANDARD LVDS [get_ports {pin_in_cl_clk_p[2]}];#[get_ports {pin_in_cl_zclk_p}];#"FMC_HPC_LA17_CC_P"]
##set_property PACKAGE_PIN E23 [get_ports {pin_in_cl_cc_n[1]}];#"FMC_HPC_LA18_CC_N"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[1]}];#"FMC_HPC_LA18_CC_N"]
##set_property PACKAGE_PIN E22 [get_ports {pin_in_cl_cc_p[1]}];#"FMC_HPC_LA18_CC_P"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[1]}];#"FMC_HPC_LA18_CC_P"]
##set_property PACKAGE_PIN C22 [get_ports {pin_in_cl_cc_n[2]}];#"FMC_HPC_LA19_N"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[2]}];#"FMC_HPC_LA19_N"]
##set_property PACKAGE_PIN C21 [get_ports {pin_in_cl_cc_p[2]}];#"FMC_HPC_LA19_P"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[2]}];#"FMC_HPC_LA19_P"]
##set_property PACKAGE_PIN A24 [get_ports {pin_in_cl_cc_n[3]}];#"FMC_HPC_LA20_N"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[3]}];#"FMC_HPC_LA20_N"]
##set_property PACKAGE_PIN B24 [get_ports {pin_in_cl_cc_p[3]}];#"FMC_HPC_LA20_P"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[3]}];#"FMC_HPC_LA20_P"]
##set_property PACKAGE_PIN F24 [get_ports {pin_in_cl_cc_n[4]}];#"FMC_HPC_LA21_N"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_n[4]}];#"FMC_HPC_LA21_N"]
##set_property PACKAGE_PIN F23 [get_ports {pin_in_cl_cc_p[4]}];#"FMC_HPC_LA21_P"]
##set_property IOSTANDARD LVDS [get_ports {pin_in_cl_cc_p[4]}];#"FMC_HPC_LA21_P"]


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

