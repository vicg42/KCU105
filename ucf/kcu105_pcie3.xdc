# Family       - kintexu
# Part         - xcku040
# Package      - fbva900
# Speed grade  - -2
# PCIe Block   - X0Y0

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -name i_sys_clk -period 10 [get_ports {pin_in_pcie_phy[clk_p]}]

set_false_path -from [get_ports {pin_in_pcie_phy[rst_n]}]


###############################################################################
# User Physical Constraints
###############################################################################

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property LOC [get_package_pins -filter {PIN_FUNC == IO_T3U_N12_PERSTN0_65}] [get_ports {pin_in_pcie_phy[rst_n]}]
set_property PULLUP true [get_ports {pin_in_pcie_phy[rst_n]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pin_in_pcie_phy[rst_n]}]

##### REFCLK_IBUF###########
set_property LOC AB6 [get_cells m_host/m_refclk_ibuf]

