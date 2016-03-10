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
set_property DIFF_TERM  TRUE [get_ports {pin_in_refclk[M125_p]}]
create_clock -period 8.000 -name {pin_in_refclk[M125_p]} -waveform {0.000 4.000} [get_ports {pin_in_refclk[M125_p]}]
#
#set_property PACKAGE_PIN K20 [get_ports {pin_in_refclk[M90]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_refclk[M90]}]
#create_clock -period 11.111 -name {pin_in_refclk[M90]} -waveform {0.000 5.556} [get_ports {pin_in_refclk[M90]}]

create_clock -period 11.765 -name camera_link_clk0 -waveform {0.000 5.882} [get_ports {pin_in_cl_clk_p[0]}]
create_clock -period 11.765 -name camera_link_clk1 -waveform {0.000 5.882} [get_ports {pin_in_cl_clk_p[1]}]
create_clock -period 11.765 -name camera_link_clk2 -waveform {0.000 5.882} [get_ports {pin_in_cl_clk_p[2]}]

set_property PACKAGE_PIN F12 [get_ports pin_out_refclk_sel]
set_property IOSTANDARD LVCMOS18 [get_ports pin_out_refclk_sel]

#------ Pin Location ------
#set_property PACKAGE_PIN     AD10  [get_ports {pin_in_btn[4]}]; #SW_N
set_property PACKAGE_PIN AE10 [get_ports {pin_in_btn[1]}]
#set_property PACKAGE_PIN     AF8   [get_ports {pin_in_btn[2]}]; #SW_E
#set_property PACKAGE_PIN     AF9   [get_ports {pin_in_btn[3]}]; #SW_W
set_property PACKAGE_PIN AN8 [get_ports {pin_in_btn[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_btn[*]}]


set_property PACKAGE_PIN AP8 [get_ports {pin_out_led[0]}]
set_property PACKAGE_PIN H23 [get_ports {pin_out_led[1]}]
set_property PACKAGE_PIN P20 [get_ports {pin_out_led[2]}]
set_property PACKAGE_PIN P21 [get_ports {pin_out_led[3]}]
set_property PACKAGE_PIN N22 [get_ports {pin_out_led[4]}]
set_property PACKAGE_PIN M22 [get_ports {pin_out_led[5]}]
set_property PACKAGE_PIN R23 [get_ports {pin_out_led[6]}]
set_property PACKAGE_PIN P23 [get_ports {pin_out_led[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led[*]}]
set_property OFFCHIP_TERM NONE [get_ports pin_out_led[*]]

#FMC HPC (Board FMC CAMERALINK)
set_property PACKAGE_PIN D20 [get_ports {pin_out_led_hpc[0]}]
set_property PACKAGE_PIN G20 [get_ports {pin_out_led_hpc[1]}]
set_property PACKAGE_PIN H21 [get_ports {pin_out_led_hpc[2]}]
set_property PACKAGE_PIN B21 [get_ports {pin_out_led_hpc[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_hpc[*]}]
set_property OFFCHIP_TERM NONE [get_ports pin_out_led_hpc[*]]

#FMC LPC (Board FMC 105)
set_property PACKAGE_PIN W30 [get_ports {pin_out_led_lpc[0]}]
set_property PACKAGE_PIN Y30 [get_ports {pin_out_led_lpc[1]}]
set_property PACKAGE_PIN W33 [get_ports {pin_out_led_lpc[2]}]
set_property PACKAGE_PIN Y33 [get_ports {pin_out_led_lpc[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_out_led_lpc[*]}]
set_property OFFCHIP_TERM NONE [get_ports pin_out_led_lpc[*]]


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

# Pinout and Related I/O Constraints
set_property LOC PCIE_3_1_X0Y0 [get_cells m_host/m_core/U0/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst]
set_property PACKAGE_PIN K22 [get_ports {pin_in_pcie_phy[rst_n]}]
set_property PULLUP true [get_ports {pin_in_pcie_phy[rst_n]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_pcie_phy[rst_n]}]

set_property LOC GTHE3_COMMON_X0Y1 [get_cells m_host/m_refclk_ibuf]


###############################################################################
#MEMCTRL
###############################################################################
set_property PACKAGE_PIN AK17 [get_ports {pin_in_phymem[clk_p]}]
set_property PACKAGE_PIN AK16 [get_ports {pin_in_phymem[clk_n]}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {pin_in_phymem[clk_p]}]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {pin_in_phymem[clk_n]}]
set_property ODT        RTT_48      [get_ports {pin_in_phymem[clk_p]}]
set_property ODT        RTT_48      [get_ports {pin_in_phymem[clk_n]}]

set_property PACKAGE_PIN AE17 [get_ports {pin_out_phymem[addr][0]}]
set_property PACKAGE_PIN AH17 [get_ports {pin_out_phymem[addr][1]}]
set_property PACKAGE_PIN AE18 [get_ports {pin_out_phymem[addr][2]}]
set_property PACKAGE_PIN AJ15 [get_ports {pin_out_phymem[addr][3]}]
set_property PACKAGE_PIN AG16 [get_ports {pin_out_phymem[addr][4]}]
set_property PACKAGE_PIN AL17 [get_ports {pin_out_phymem[addr][5]}]
set_property PACKAGE_PIN AK18 [get_ports {pin_out_phymem[addr][6]}]
set_property PACKAGE_PIN AG17 [get_ports {pin_out_phymem[addr][7]}]
set_property PACKAGE_PIN AF18 [get_ports {pin_out_phymem[addr][8]}]
set_property PACKAGE_PIN AH19 [get_ports {pin_out_phymem[addr][9]}]
set_property PACKAGE_PIN AF15 [get_ports {pin_out_phymem[addr][10]}]
set_property PACKAGE_PIN AD19 [get_ports {pin_out_phymem[addr][11]}]
set_property PACKAGE_PIN AJ14 [get_ports {pin_out_phymem[addr][12]}]
set_property PACKAGE_PIN AG19 [get_ports {pin_out_phymem[addr][13]}]
set_property PACKAGE_PIN AD16 [get_ports {pin_out_phymem[addr][14]}]
set_property PACKAGE_PIN AG14 [get_ports {pin_out_phymem[addr][15]}]
set_property PACKAGE_PIN AF14 [get_ports {pin_out_phymem[addr][16]}]
set_property PACKAGE_PIN AE23 [get_ports {pin_inout_phymem[dq][0]}]
set_property PACKAGE_PIN AG20 [get_ports {pin_inout_phymem[dq][1]}]
set_property PACKAGE_PIN AF22 [get_ports {pin_inout_phymem[dq][2]}]
set_property PACKAGE_PIN AF20 [get_ports {pin_inout_phymem[dq][3]}]
set_property PACKAGE_PIN AE22 [get_ports {pin_inout_phymem[dq][4]}]
set_property PACKAGE_PIN AD20 [get_ports {pin_inout_phymem[dq][5]}]
set_property PACKAGE_PIN AG22 [get_ports {pin_inout_phymem[dq][6]}]
set_property PACKAGE_PIN AE20 [get_ports {pin_inout_phymem[dq][7]}]
set_property PACKAGE_PIN AJ24 [get_ports {pin_inout_phymem[dq][8]}]
set_property PACKAGE_PIN AG24 [get_ports {pin_inout_phymem[dq][9]}]
set_property PACKAGE_PIN AJ23 [get_ports {pin_inout_phymem[dq][10]}]
set_property PACKAGE_PIN AF23 [get_ports {pin_inout_phymem[dq][11]}]
set_property PACKAGE_PIN AH23 [get_ports {pin_inout_phymem[dq][12]}]
set_property PACKAGE_PIN AF24 [get_ports {pin_inout_phymem[dq][13]}]
set_property PACKAGE_PIN AH22 [get_ports {pin_inout_phymem[dq][14]}]
set_property PACKAGE_PIN AG25 [get_ports {pin_inout_phymem[dq][15]}]
set_property PACKAGE_PIN AL22 [get_ports {pin_inout_phymem[dq][16]}]
set_property PACKAGE_PIN AL25 [get_ports {pin_inout_phymem[dq][17]}]
set_property PACKAGE_PIN AM20 [get_ports {pin_inout_phymem[dq][18]}]
set_property PACKAGE_PIN AK23 [get_ports {pin_inout_phymem[dq][19]}]
set_property PACKAGE_PIN AK22 [get_ports {pin_inout_phymem[dq][20]}]
set_property PACKAGE_PIN AL24 [get_ports {pin_inout_phymem[dq][21]}]
set_property PACKAGE_PIN AL20 [get_ports {pin_inout_phymem[dq][22]}]
set_property PACKAGE_PIN AL23 [get_ports {pin_inout_phymem[dq][23]}]
set_property PACKAGE_PIN AM24 [get_ports {pin_inout_phymem[dq][24]}]
set_property PACKAGE_PIN AN23 [get_ports {pin_inout_phymem[dq][25]}]
set_property PACKAGE_PIN AN24 [get_ports {pin_inout_phymem[dq][26]}]
set_property PACKAGE_PIN AP23 [get_ports {pin_inout_phymem[dq][27]}]
set_property PACKAGE_PIN AP25 [get_ports {pin_inout_phymem[dq][28]}]
set_property PACKAGE_PIN AN22 [get_ports {pin_inout_phymem[dq][29]}]
set_property PACKAGE_PIN AP24 [get_ports {pin_inout_phymem[dq][30]}]
set_property PACKAGE_PIN AM22 [get_ports {pin_inout_phymem[dq][31]}]
set_property PACKAGE_PIN AH28 [get_ports {pin_inout_phymem[dq][32]}]
set_property PACKAGE_PIN AK26 [get_ports {pin_inout_phymem[dq][33]}]
set_property PACKAGE_PIN AK28 [get_ports {pin_inout_phymem[dq][34]}]
set_property PACKAGE_PIN AM27 [get_ports {pin_inout_phymem[dq][35]}]
set_property PACKAGE_PIN AJ28 [get_ports {pin_inout_phymem[dq][36]}]
set_property PACKAGE_PIN AH27 [get_ports {pin_inout_phymem[dq][37]}]
set_property PACKAGE_PIN AK27 [get_ports {pin_inout_phymem[dq][38]}]
set_property PACKAGE_PIN AM26 [get_ports {pin_inout_phymem[dq][39]}]
set_property PACKAGE_PIN AL30 [get_ports {pin_inout_phymem[dq][40]}]
set_property PACKAGE_PIN AP29 [get_ports {pin_inout_phymem[dq][41]}]
set_property PACKAGE_PIN AM30 [get_ports {pin_inout_phymem[dq][42]}]
set_property PACKAGE_PIN AN28 [get_ports {pin_inout_phymem[dq][43]}]
set_property PACKAGE_PIN AL29 [get_ports {pin_inout_phymem[dq][44]}]
set_property PACKAGE_PIN AP28 [get_ports {pin_inout_phymem[dq][45]}]
set_property PACKAGE_PIN AM29 [get_ports {pin_inout_phymem[dq][46]}]
set_property PACKAGE_PIN AN27 [get_ports {pin_inout_phymem[dq][47]}]
set_property PACKAGE_PIN AH31 [get_ports {pin_inout_phymem[dq][48]}]
set_property PACKAGE_PIN AH32 [get_ports {pin_inout_phymem[dq][49]}]
set_property PACKAGE_PIN AJ34 [get_ports {pin_inout_phymem[dq][50]}]
set_property PACKAGE_PIN AK31 [get_ports {pin_inout_phymem[dq][51]}]
set_property PACKAGE_PIN AJ31 [get_ports {pin_inout_phymem[dq][52]}]
set_property PACKAGE_PIN AJ30 [get_ports {pin_inout_phymem[dq][53]}]
set_property PACKAGE_PIN AH34 [get_ports {pin_inout_phymem[dq][54]}]
set_property PACKAGE_PIN AK32 [get_ports {pin_inout_phymem[dq][55]}]
set_property PACKAGE_PIN AN33 [get_ports {pin_inout_phymem[dq][56]}]
set_property PACKAGE_PIN AP33 [get_ports {pin_inout_phymem[dq][57]}]
set_property PACKAGE_PIN AM34 [get_ports {pin_inout_phymem[dq][58]}]
set_property PACKAGE_PIN AP31 [get_ports {pin_inout_phymem[dq][59]}]
set_property PACKAGE_PIN AM32 [get_ports {pin_inout_phymem[dq][60]}]
set_property PACKAGE_PIN AN31 [get_ports {pin_inout_phymem[dq][61]}]
set_property PACKAGE_PIN AL34 [get_ports {pin_inout_phymem[dq][62]}]
set_property PACKAGE_PIN AN32 [get_ports {pin_inout_phymem[dq][63]}]
set_property PACKAGE_PIN AD21 [get_ports {pin_inout_phymem[dm_dbi_n][0]}]
set_property PACKAGE_PIN AE25 [get_ports {pin_inout_phymem[dm_dbi_n][1]}]
set_property PACKAGE_PIN AJ21 [get_ports {pin_inout_phymem[dm_dbi_n][2]}]
set_property PACKAGE_PIN AM21 [get_ports {pin_inout_phymem[dm_dbi_n][3]}]
set_property PACKAGE_PIN AH26 [get_ports {pin_inout_phymem[dm_dbi_n][4]}]
set_property PACKAGE_PIN AN26 [get_ports {pin_inout_phymem[dm_dbi_n][5]}]
set_property PACKAGE_PIN AJ29 [get_ports {pin_inout_phymem[dm_dbi_n][6]}]
set_property PACKAGE_PIN AL32 [get_ports {pin_inout_phymem[dm_dbi_n][7]}]
set_property PACKAGE_PIN AG21 [get_ports {pin_inout_phymem[dqs_t][0]}]
set_property PACKAGE_PIN AH21 [get_ports {pin_inout_phymem[dqs_c][0]}]
set_property PACKAGE_PIN AH24 [get_ports {pin_inout_phymem[dqs_t][1]}]
set_property PACKAGE_PIN AJ25 [get_ports {pin_inout_phymem[dqs_c][1]}]
set_property PACKAGE_PIN AJ20 [get_ports {pin_inout_phymem[dqs_t][2]}]
set_property PACKAGE_PIN AK20 [get_ports {pin_inout_phymem[dqs_c][2]}]
set_property PACKAGE_PIN AP20 [get_ports {pin_inout_phymem[dqs_t][3]}]
set_property PACKAGE_PIN AP21 [get_ports {pin_inout_phymem[dqs_c][3]}]
set_property PACKAGE_PIN AL27 [get_ports {pin_inout_phymem[dqs_t][4]}]
set_property PACKAGE_PIN AL28 [get_ports {pin_inout_phymem[dqs_c][4]}]
set_property PACKAGE_PIN AN29 [get_ports {pin_inout_phymem[dqs_t][5]}]
set_property PACKAGE_PIN AP30 [get_ports {pin_inout_phymem[dqs_c][5]}]
set_property PACKAGE_PIN AH33 [get_ports {pin_inout_phymem[dqs_t][6]}]
set_property PACKAGE_PIN AJ33 [get_ports {pin_inout_phymem[dqs_c][6]}]
set_property PACKAGE_PIN AN34 [get_ports {pin_inout_phymem[dqs_t][7]}]
set_property PACKAGE_PIN AP34 [get_ports {pin_inout_phymem[dqs_c][7]}]
set_property PACKAGE_PIN AF17 [get_ports {pin_out_phymem[ba][0]}]
set_property PACKAGE_PIN AL15 [get_ports {pin_out_phymem[ba][1]}]
set_property PACKAGE_PIN AG15 [get_ports {pin_out_phymem[bg][0]}]
set_property PACKAGE_PIN AD15 [get_ports {pin_out_phymem[cke][0]}]
set_property PACKAGE_PIN AL19 [get_ports {pin_out_phymem[cs_n][0]}]
set_property PACKAGE_PIN AJ18 [get_ports {pin_out_phymem[odt][0]}]
set_property PACKAGE_PIN AL18 [get_ports {pin_out_phymem[reset_n]}]
set_property PACKAGE_PIN AH14 [get_ports {pin_out_phymem[act_n]}]
set_property PACKAGE_PIN AE15 [get_ports {pin_out_phymem[ck_c][0]}]
set_property PACKAGE_PIN AE16 [get_ports {pin_out_phymem[ck_t][0]}]


###############################################################################
#RS232(PC)
###############################################################################
set_property PACKAGE_PIN     G25  [get_ports {pin_in_rs232_rx}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_in_rs232_rx}];
set_property PACKAGE_PIN     K26  [get_ports {pin_out_rs232_tx}];
set_property IOSTANDARD   LVCMOS18 [get_ports {pin_out_rs232_tx}];

###############################################################################
#CameraLink
###############################################################################
#FMC HPC (Board FMC CAMERALINK : CL(X))
set_property PACKAGE_PIN G11        [get_ports {pin_in_cl_clk_n[0]}]
set_property PACKAGE_PIN H11        [get_ports {pin_in_cl_clk_p[0]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_clk_p[0]}]
set_property PACKAGE_PIN J10        [get_ports {pin_in_cl_di_n[0]}]
set_property PACKAGE_PIN K10        [get_ports {pin_in_cl_di_p[0]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[0]}]
set_property PACKAGE_PIN A12        [get_ports {pin_in_cl_di_n[1]}]
set_property PACKAGE_PIN A13        [get_ports {pin_in_cl_di_p[1]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[1]}]
set_property PACKAGE_PIN K12        [get_ports {pin_in_cl_di_n[2]}]
set_property PACKAGE_PIN L12        [get_ports {pin_in_cl_di_p[2]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[2]}]
set_property PACKAGE_PIN K13        [get_ports {pin_in_cl_di_n[3]}]
set_property PACKAGE_PIN L13        [get_ports {pin_in_cl_di_p[3]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[3]}]

#FMC HPC (Board FMC CAMERALINK : CL(Y))
set_property PACKAGE_PIN F9         [get_ports {pin_in_cl_clk_n[1]}]
set_property PACKAGE_PIN G9         [get_ports {pin_in_cl_clk_p[1]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_clk_p[1]}]
set_property PACKAGE_PIN C13        [get_ports {pin_in_cl_di_n[4]}]
set_property PACKAGE_PIN D13        [get_ports {pin_in_cl_di_p[4]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[4]}]
set_property PACKAGE_PIN E8         [get_ports {pin_in_cl_di_n[5]}]
set_property PACKAGE_PIN F8         [get_ports {pin_in_cl_di_p[5]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[5]}]
set_property PACKAGE_PIN H8         [get_ports {pin_in_cl_di_n[6]}]
set_property PACKAGE_PIN J8         [get_ports {pin_in_cl_di_p[6]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[6]}]
set_property PACKAGE_PIN H9         [get_ports {pin_in_cl_di_n[7]}]
set_property PACKAGE_PIN J9         [get_ports {pin_in_cl_di_p[7]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[7]}]

#FMC HPC (Board FMC CAMERALINK : CL(Z))
set_property PACKAGE_PIN C24        [get_ports {pin_in_cl_clk_n[2]}]
set_property PACKAGE_PIN D24        [get_ports {pin_in_cl_clk_p[2]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_clk_p[2]}]
set_property PACKAGE_PIN K8         [get_ports {pin_in_cl_di_n[8]}]
set_property PACKAGE_PIN L8         [get_ports {pin_in_cl_di_p[8]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[8]}]
set_property PACKAGE_PIN J11        [get_ports {pin_in_cl_di_n[9]}]
set_property PACKAGE_PIN K11        [get_ports {pin_in_cl_di_p[9]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[9]}]
set_property PACKAGE_PIN D10        [get_ports {pin_in_cl_di_n[10]}]
set_property PACKAGE_PIN E10        [get_ports {pin_in_cl_di_p[10]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[10]}]
set_property PACKAGE_PIN C9         [get_ports {pin_in_cl_di_n[11]}]
set_property PACKAGE_PIN D9         [get_ports {pin_in_cl_di_p[11]}]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_di_p[11]}]

set_property IOSTANDARD LVDS        [get_ports {pin_in_cl_clk_n[*]}]
set_property IOSTANDARD LVDS        [get_ports {pin_in_cl_clk_p[*]}]
set_property IOSTANDARD LVDS        [get_ports {pin_in_cl_di_n[*]}]
set_property IOSTANDARD LVDS        [get_ports {pin_in_cl_di_p[*]}]

#FMC HPC (Board FMC CAMERALINK : CL(CTRL))
set_property IOSTANDARD LVDS [get_ports pin_in_cl_tfg_n]
set_property PACKAGE_PIN A10 [get_ports pin_in_cl_tfg_n]
set_property PACKAGE_PIN B10 [get_ports pin_in_cl_tfg_p]
set_property IOSTANDARD LVDS [get_ports pin_in_cl_tfg_p]
set_property DIFF_TERM         TRUE [get_ports {pin_in_cl_tfg_p}]
set_property IOSTANDARD LVDS [get_ports pin_out_cl_tc_n]
set_property PACKAGE_PIN C8 [get_ports pin_out_cl_tc_n]
set_property PACKAGE_PIN D8 [get_ports pin_out_cl_tc_p]
set_property IOSTANDARD LVDS [get_ports pin_out_cl_tc_p]

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


#set_clock_groups -name memclk_pcieclk -asynchronous -group [get_clocks -of_objects [get_pins {m_mem_ctrl/gen_bank[0].m_mem_core/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]] -group [get_clocks -of_objects [get_pins {m_host/m_core/U0/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_core_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_core_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[1].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]]
#set_clock_groups -name pcieclk_memclk -asynchronous -group [get_clocks -of_objects [get_pins {m_host/m_core/U0/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_core_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_core_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[1].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins {m_mem_ctrl/gen_bank[0].m_mem_core/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]]
#
#set_clock_groups -name ethclk_memclk -asynchronous -group [get_clocks -of_objects [get_pins m_eth/m_eth_app/fifo_block_i/ethernet_core_i/U0/ten_gig_eth_pcs_pma/U0/ten_gig_eth_pcs_pma_shared_clock_reset_block/txusrclk2_bufg_gt_i/O]] -group [get_clocks -of_objects [get_pins {m_host/m_core/U0/gt_top_i/gt_wizard.gtwizard_top_i/pcie3_core_gt_i/inst/gen_gtwizard_gthe3_top.pcie3_core_gt_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[1].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[3].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]]
#set_clock_groups -name tmrclk_ethclk -asynchronous -group [get_clocks {pin_in_refclk[M125_p]}] -group [get_clocks -of_objects [get_pins m_eth/m_eth_app/fifo_block_i/ethernet_core_i/U0/ten_gig_eth_pcs_pma/U0/ten_gig_eth_pcs_pma_shared_clock_reset_block/txusrclk2_bufg_gt_i/O]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
