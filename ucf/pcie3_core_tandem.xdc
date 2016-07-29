##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : Ultrascale FPGA Gen3 Integrated Block for PCI Express
## File       : pcie3_core_tandem.xdc
## Version    : 4.0 
##-----------------------------------------------------------------------------
#
###############################################################################
# Enable Tandem PCIE Bitstream Generation 
###############################################################################
# Uncomment the following two constraints to generate Tandem PCIe Bitstreams. 
# Without these constraints Tandem PROM bitstreams will be generated.
#set_property HD.OVERRIDE_PERSIST FALSE [current_design]
#set_property HD.TANDEM_BITSTREAMS Separate [current_design]

###############################################################################
# Tandem Pblocks for the Example Design:
# All Stage1 primitives must be in a PBlock that is aligned to a Programmable
# Unit boundary. This PBlock must have exclude placement to prevent other 
# primitives from being included in the region boundary.
###############################################################################
# Since the reset pin is within the config IO Bank, add the Reset IOB to the
# config IO Bank pblock that is already created by the solution IP
add_cells_to_pblock [get_pblocks -filter {NAME =~ *Stage1_cfgiob}] [get_cells sys_reset_n_ibuf]
set_property HD.TANDEM 1 [get_cells sys_reset_n_ibuf]

# Since the refclk is within the range of the main pblock, add the refclk IBUF and its BUFG_GT to the
# main pblock.
add_cells_to_pblock [get_pblocks -filter {NAME =~ *pcie3_core_Stage1_main}] [get_cells refclk_ibuf]
set_property HD.TANDEM 1 [get_cells refclk_ibuf]

