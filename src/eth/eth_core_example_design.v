// ----------------------------------------------------------------------------
// (c) Copyright 2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// ----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Title      : Example Design top level
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : eth_core_example_design.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// Description: This is the example design top level code for the 10G
//              Gigabit Ethernet IP.  It contains the FIFO block of the example
//              design along with a frame pattern generator and checker.
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module eth_core_example_design #(
parameter   G_GTCH_COUNT = 1
)
  (
   // Clock inputs
   input             clk_in,       // Freerunning clock source

   input             refclk_p,       // Transceiver reference clock source
   input             refclk_n,
   output            coreclk_out,

   // Example design control inputs
   input             reset,

   input             sim_speedup_control,

   // Example design status outputs
   output            frame_error,

   output            core_ready,
   output            qplllock_out,

   // Serial I/O from/to transceiver
   output            txp,
   output            txn,
   input             rxp,
   input             rxn
   );
/*-------------------------------------------------------------------------*/


   // Set FIFO memory size
   localparam        FIFO_SIZE  = 1024;


   // Signal declarations
   wire              coreclk;
   wire              block_lock;

   wire              no_remote_and_local_faults;
   wire    [79 : 0]  mac_tx_configuration_vector;
   wire    [79 : 0]  mac_rx_configuration_vector;
   wire   [1 : 0]    mac_status_vector;
   wire   [535 : 0]  pcs_pma_configuration_vector;
   wire   [447 : 0]  pcs_pma_status_vector;

   wire     [63:0]   tx_axis_tdata;
   wire     [7:0]    tx_axis_tkeep;
   wire     [0:0]    tx_axis_tvalid;
   wire     [0:0]    tx_axis_tlast;
   wire     [0:0]    tx_axis_tready;
   wire     [63:0]   rx_axis_tdata;
   wire     [7:0]    rx_axis_tkeep;
   wire     [0:0]    rx_axis_tvalid;
   wire     [0:0]    rx_axis_tlast;
   wire     [0:0]    rx_axis_tready;

   wire     [G_GTCH_COUNT - 1 : 0]    tx_axis_aresetn;
   wire     [G_GTCH_COUNT - 1 : 0]    rx_axis_aresetn;

   wire      [7:0]   pcspma_status;


   assign coreclk_out = coreclk;

   // Assign the configuration settings to the configuration vectors
   assign mac_rx_configuration_vector = {72'd0,6'd0,2'b10};
   assign mac_tx_configuration_vector = {72'd0,6'd0,2'b10};

   assign pcs_pma_configuration_vector = {425'd0,111'd0};

   assign block_lock = pcspma_status[0];
   assign no_remote_and_local_faults = !mac_status_vector[0] && !mac_status_vector[1] ;
   assign core_ready = block_lock && no_remote_and_local_faults;

   // Combine reset sources
   assign tx_axis_aresetn[0]  = ~reset;
   assign rx_axis_aresetn[0]  = ~reset;


   wire [G_GTCH_COUNT - 1 : 0]       coreclk_i;
   wire [G_GTCH_COUNT - 1 : 0]       qplllock_i;
   wire [G_GTCH_COUNT - 1 : 0]       txp_i;
   wire [G_GTCH_COUNT - 1 : 0]       txn_i;
   wire [G_GTCH_COUNT - 1 : 0]       rxp_i;
   wire [G_GTCH_COUNT - 1 : 0]       rxn_i;

assign coreclk = coreclk_i[0];
assign qplllock_out = qplllock_i[0];
assign txp = txp_i[0];
assign txn = txn_i[0];
assign rxp_i[0] = rxp;
assign rxn_i[0] = rxn;


    //--------------------------------------------------------------------------
    // Instantiate a module containing the Ethernet core and an example FIFO
    //--------------------------------------------------------------------------
      assign tx_axis_tdata  = rx_axis_tdata ;
      assign tx_axis_tkeep  = rx_axis_tkeep ;
      assign tx_axis_tvalid = rx_axis_tvalid;
      assign tx_axis_tlast  = rx_axis_tlast ;

      assign rx_axis_tready = tx_axis_tready ;



    eth_core_fifo_block #(
      .G_GTCH_COUNT (G_GTCH_COUNT),
      .FIFO_SIZE                       (FIFO_SIZE)
    ) fifo_block_i (
      .refclk_p                        (refclk_p),
      .refclk_n                        (refclk_n),
      .coreclk_out                     (coreclk_i),
      .rxrecclk_out                    (),
      .dclk                            (clk_in),

      .reset                           (reset),

      .tx_ifg_delay                    (8'd0),

      .tx_statistics_vector            (),
      .tx_statistics_valid             (),
      .rx_statistics_vector            (),
      .rx_statistics_valid             (),

      .pause_val                       (16'b0),
      .pause_req                       (1'b0),

      .rx_axis_fifo_aresetn            (rx_axis_aresetn),
      .rx_axis_mac_aresetn             (rx_axis_aresetn),
      .rx_axis_fifo_tdata              (rx_axis_tdata),
      .rx_axis_fifo_tkeep              (rx_axis_tkeep),
      .rx_axis_fifo_tvalid             (rx_axis_tvalid),
      .rx_axis_fifo_tlast              (rx_axis_tlast),
      .rx_axis_fifo_tready             (rx_axis_tready),

      .tx_axis_mac_aresetn             (tx_axis_aresetn),
      .tx_axis_fifo_aresetn            (tx_axis_aresetn),
      .tx_axis_fifo_tdata              (tx_axis_tdata),
      .tx_axis_fifo_tkeep              (tx_axis_tkeep),
      .tx_axis_fifo_tvalid             (tx_axis_tvalid),
      .tx_axis_fifo_tlast              (tx_axis_tlast),
      .tx_axis_fifo_tready             (tx_axis_tready),

      .mac_tx_configuration_vector     (mac_tx_configuration_vector),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector),
      .mac_status_vector               (mac_status_vector),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
      .pcs_pma_status_vector           (pcs_pma_status_vector),

      .txp                             (txp_i),
      .txn                             (txn_i),
      .rxp                             (rxp_i),
      .rxn                             (rxn_i),

      .signal_detect                   (1'b1),
      .tx_fault                        (1'b0),
      .sim_speedup_control             (sim_speedup_control),
      .pcspma_status                   (pcspma_status),
      .resetdone_out                   (),
      .qplllock_out                    (qplllock_i)
      );

assign frame_error = 0;


endmodule
