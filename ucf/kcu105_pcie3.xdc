# User Configuration
# Link Width   - x1
# Link Speed   - Gen1
# Family       - kintexu
# Part         - xcku040
# Package      - fbva900
# Speed grade  - -2
# PCIe Block   - X0Y0

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]



set_false_path -from [get_ports sys_rst_n]




###############################################################################
# User Physical Constraints
###############################################################################

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property LOC [get_package_pins -filter {PIN_FUNC == IO_T3U_N12_PERSTN0_65}] [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]

##### REFCLK_IBUF###########
set_property LOC AB6 [get_cells refclk_ibuf]

###############################################################################
# Flash Programming Settings: Uncomment as required by your design
# Items below between < > must be updated with correct values to work properly.
###############################################################################
# BPI Flash Programming
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE <disable | Type1 | Type2> [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 9 [current_design]
#set_property CONFIG_VOLTAGE <voltage> [current_design]
#set_property CFGBVS GND [current_design]
# Example PROM Generation command that should be executed from the Tcl Console
#write_cfgmem -format mcs -interface bpix16 -size 128 -loadbit "up 0x0 <inputBitfile.bit>" <outputBitfile.bit>

# SPI Flash Programming
#set_property CONFIG_MODE SPIx4 [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 \[current_design\]"
#set_property CONFIG_VOLTAGE <voltage> [current_design]
#set_property CFGBVS <GND | VCC> [current_design]
# Example PROM Generation command that should be executed from the Tcl Console
#write_cfgmem -format mcs -interface spix4 -size 128 -loadbit "up 0x0 <inputBitfile.bit>" <outputBitfile.bit>
