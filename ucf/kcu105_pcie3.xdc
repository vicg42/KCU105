# Family       - kintexu
# Part         - xcku040
# Package      - fbva900
# Speed grade  - -2
# PCIe Block   - X0Y0

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 10.000 -name i_sys_clk [get_ports {pin_in_pcie_phy[clk_p]}]

set_false_path -from [get_ports {pin_in_pcie_phy[rst_n]}]


###############################################################################
# User Physical Constraints
###############################################################################
set_property LOC PCIE_3_1_X0Y0 [get_cells m_host/m_core/U0/pcie3_uscale_top_inst/pcie3_uscale_wrapper_inst/PCIE_3_1_inst]

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property PACKAGE_PIN K22 [get_ports {pin_in_pcie_phy[rst_n]}]
set_property PULLUP true [get_ports {pin_in_pcie_phy[rst_n]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_pcie_phy[rst_n]}]

##### REFCLK_IBUF###########
set_property LOC AB6 [get_cells m_host/m_refclk_ibuf]


set_property CONFIG_MODE SPIx8 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
