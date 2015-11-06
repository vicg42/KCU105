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
// Title      : Support level for 10G Gigabit Ethernet
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : eth_core_support.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// Description: This is the Support level code for 10G Gigabit Ethernet.
//              It contains the block level instance and shareable clocking and
//              reset circuitry.
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module eth_core_support    #(
  parameter   G_GT_CHANNEL_COUNT = 1
  )
  (
   // Port declarations
   input                               refclk_p,
   input                               refclk_n,
   input                               dclk,
   output                              coreclk_out,
   input                               reset,
   output                              qpll0outclk_out,
   output                              qpll0outrefclk_out,
   output                              qpll0lock_out,
   output [G_GT_CHANNEL_COUNT - 1: 0]  qpll0reset_out,
   output                              resetdone_out,
   output [G_GT_CHANNEL_COUNT - 1: 0]  txusrclk_out,
   output [G_GT_CHANNEL_COUNT - 1: 0]  txusrclk2_out,
   output                              gttxreset_out,
   output                              gtrxreset_out,
   output [G_GT_CHANNEL_COUNT - 1: 0]  txuserrdy_out,
   output                              reset_counter_done_out,

   input       [(80 * G_GT_CHANNEL_COUNT) - 1 : 0]    mac_tx_configuration_vector,
   input       [(80 * G_GT_CHANNEL_COUNT) - 1 : 0]    mac_rx_configuration_vector,
   output      [(2 * G_GT_CHANNEL_COUNT) - 1 : 0]     mac_status_vector,
   input       [(536 * G_GT_CHANNEL_COUNT) - 1 : 0]   pcs_pma_configuration_vector,
   output      [(448 * G_GT_CHANNEL_COUNT) - 1 : 0]   pcs_pma_status_vector,

   input       [7:0]                   tx_ifg_delay,

   output      [(26 * G_GT_CHANNEL_COUNT) - 1 : 0]  tx_statistics_vector,
   output      [(30 * G_GT_CHANNEL_COUNT) - 1 : 0]   rx_statistics_vector,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         tx_statistics_valid,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         rx_statistics_valid,

   input       [G_GT_CHANNEL_COUNT - 1 : 0]         tx_axis_aresetn,
   input       [(64 * G_GT_CHANNEL_COUNT) - 1 : 0]  s_axis_tx_tdata,
   input       [(8 * G_GT_CHANNEL_COUNT) - 1 : 0]   s_axis_tx_tkeep,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         s_axis_tx_tvalid,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         s_axis_tx_tlast,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         s_axis_tx_tuser,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         s_axis_tx_tready,

   input       [G_GT_CHANNEL_COUNT - 1 : 0]         rx_axis_aresetn,
   output      [(64 * G_GT_CHANNEL_COUNT) - 1 : 0]  m_axis_rx_tdata,
   output      [(8 * G_GT_CHANNEL_COUNT) - 1 : 0]   m_axis_rx_tkeep,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         m_axis_rx_tvalid,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         m_axis_rx_tuser,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         m_axis_rx_tlast,

   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_eyescanreset,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_eyescantrigger,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxcdrhold,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_txprbsforceerr,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_txpolarity,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxpolarity,
   input   [(3 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_rxrate,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_txpmareset,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxpmareset,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxdfelpmreset,
   input   [(5 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_txprecursor,
   input   [(5 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_txpostcursor,
   input   [(4 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_txdiffctrl,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxlpmen,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_eyescandataerror,
   output  [(2 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_txbufstatus,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_txresetdone,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxpmaresetdone,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxresetdone,
   output  [(3 * G_GT_CHANNEL_COUNT) - 1 : 0]       transceiver_debug_gt_rxbufstatus,
   output      [G_GT_CHANNEL_COUNT - 1 : 0]         transceiver_debug_gt_rxprbserr,
   output  [(17 * G_GT_CHANNEL_COUNT) - 1: 0]       transceiver_debug_gt_dmonitorout,
   input   [(16 * G_GT_CHANNEL_COUNT) - 1: 0]       transceiver_debug_gt_pcsrsvdin,


   //Pause axis
   input      [15:0]                   s_axis_pause_tdata,
   input                               s_axis_pause_tvalid,

   output [G_GT_CHANNEL_COUNT - 1 : 0]   txp,
   output [G_GT_CHANNEL_COUNT - 1 : 0]   txn,
   input  [G_GT_CHANNEL_COUNT - 1 : 0]   rxp,
   input  [G_GT_CHANNEL_COUNT - 1 : 0]   rxn,

   output      [G_GT_CHANNEL_COUNT - 1 : 0]         tx_disable,
   output wire [G_GT_CHANNEL_COUNT - 1 : 0]         rxrecclk_out,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         signal_detect,
   input                               sim_speedup_control,
   input       [G_GT_CHANNEL_COUNT - 1 : 0]         tx_fault,
   output      [(8 * G_GT_CHANNEL_COUNT) - 1 : 0]   pcspma_status
   );

/*-------------------------------------------------------------------------*/

  // Signal declarations

  wire coreclk;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   txoutclk;
  wire qpll0outclk;
  wire qpll0outrefclk;
  wire qpll0lock;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   qpll0reset;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   reset_tx_bufg_gt;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   tx_resetdone_int;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   rx_resetdone_int;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   areset_txusrclk2;
  wire areset_coreclk;
  wire gttxreset;
  wire gtrxreset;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   txuserrdy;
  wire reset_counter_done;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   txusrclk;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   txusrclk2;
  wire txoutclk_in;
  wire [G_GT_CHANNEL_COUNT - 1 : 0]   resetdone_i;

  assign coreclk_out            = coreclk;

  assign resetdone_out          = (|resetdone_i);

  assign qpll0outclk_out        = qpll0outclk;
  assign qpll0outrefclk_out     = qpll0outrefclk;
  assign qpll0lock_out          = qpll0lock;
  assign qpll0reset_out         = qpll0reset;
  assign txusrclk_out           = txusrclk;
  assign txusrclk2_out          = txusrclk2;
  assign gttxreset_out          = gttxreset;
  assign gtrxreset_out          = gtrxreset;
  assign txuserrdy_out          = txuserrdy;
  assign reset_counter_done_out = reset_counter_done;

  //---------------------------------------------------------------------------
  // Instantiate the shared clock/reset block that also contains the gt_common
  //---------------------------------------------------------------------------

  eth_core_shared_clocking_wrapper  #(
      .G_GT_CHANNEL_COUNT (G_GT_CHANNEL_COUNT)
      )
  shared_clocking_wrapper_i
    (
     .reset                            (reset),
     .refclk_p                         (refclk_p),
     .refclk_n                         (refclk_n),
     .qpll0reset                       (qpll0reset),
     .dclk                             (dclk),
     .coreclk                          (coreclk),
     .txoutclk                         (txoutclk),
     .txoutclk_out                     (txoutclk_in),
     .areset_coreclk                   (areset_coreclk),
     .areset_txusrclk2                 (areset_txusrclk2),
     .gttxreset                        (gttxreset),
     .gtrxreset                        (gtrxreset),
     .txuserrdy                        (txuserrdy),
     .txusrclk                         (txusrclk),
     .txusrclk2                        (txusrclk2),
     .qpll0lock_out                    (qpll0lock),
     .qpll0outclk                      (qpll0outclk),
     .qpll0outrefclk                   (qpll0outrefclk),
     .reset_counter_done               (reset_counter_done),
     .reset_tx_bufg_gt                 (reset_tx_bufg_gt),
      // DRP ports
     .gt_common_drpaddr                (9'h000),
     .gt_common_drpclk                 (1'b0),
     .gt_common_drpdi                  (16'h0000),
     .gt_common_drpdo                  (),
     .gt_common_drpen                  (1'b0),
     .gt_common_drprdy                 (),
     .gt_common_drpwe                  (1'b0)
    );

genvar i;
generate
for (i = 0; i < G_GT_CHANNEL_COUNT; i = i + 1)
begin : ch
  assign resetdone_i[i] = tx_resetdone_int[i] && rx_resetdone_int[i];

  //---------------------------------------------------------------------------
  // Instantiate the AXI 10G Ethernet core
  //---------------------------------------------------------------------------
  eth_core ethernet_core_i (
      .dclk                            (dclk),
      .coreclk                         (coreclk),
      .txoutclk                        (txoutclk[i]),
      .txusrclk                        (txusrclk[i]),
      .txusrclk2                       (txusrclk2[i]),
      .areset_coreclk                  (areset_coreclk),
      .txuserrdy                       (txuserrdy[i]),
      .rxrecclk_out                    (rxrecclk_out[i]),
      .areset                          (reset),
      .tx_resetdone                    (tx_resetdone_int[i]),
      .rx_resetdone                    (rx_resetdone_int[i]),
      .reset_counter_done              (reset_counter_done),
      .gttxreset                       (gttxreset),
      .gtrxreset                       (gtrxreset),
      .qpll0lock                       (qpll0lock),
      .qpll0outclk                     (qpll0outclk),
      .qpll0outrefclk                  (qpll0outrefclk),
      .qpll0reset                      (qpll0reset[i]),
      .reset_tx_bufg_gt                (reset_tx_bufg_gt[i]),
      .tx_ifg_delay                    (tx_ifg_delay),
      .tx_statistics_vector            (tx_statistics_vector[(26 * (i + 1)) - 1 : (26 * i)]),
      .tx_statistics_valid             (tx_statistics_valid[i]),
      .rx_statistics_vector            (rx_statistics_vector[(30 * (i + 1)) - 1 : (30 * i)]),
      .rx_statistics_valid             (rx_statistics_valid[i]),
      .s_axis_pause_tdata              (s_axis_pause_tdata),
      .s_axis_pause_tvalid             (s_axis_pause_tvalid),

      .tx_axis_aresetn                 (tx_axis_aresetn[i]),
      .s_axis_tx_tdata                 (s_axis_tx_tdata[(64 * (i + 1)) - 1 : (64 * i)]),
      .s_axis_tx_tvalid                (s_axis_tx_tvalid[i]),
      .s_axis_tx_tlast                 (s_axis_tx_tlast[i]),
      .s_axis_tx_tuser                 (s_axis_tx_tuser[i]),
      .s_axis_tx_tkeep                 (s_axis_tx_tkeep[(8 * (i + 1)) - 1 : (8 * i)]),
      .s_axis_tx_tready                (s_axis_tx_tready[i]),

      .rx_axis_aresetn                 (rx_axis_aresetn[i]),
      .m_axis_rx_tdata                 (m_axis_rx_tdata[(64 * (i + 1)) - 1 : (64 * i)]),
      .m_axis_rx_tkeep                 (m_axis_rx_tkeep[(8 * (i + 1)) - 1 : (8 * i)]),
      .m_axis_rx_tvalid                (m_axis_rx_tvalid[i]),
      .m_axis_rx_tuser                 (m_axis_rx_tuser[i]),
      .m_axis_rx_tlast                 (m_axis_rx_tlast[i]),
      .mac_tx_configuration_vector     (mac_tx_configuration_vector[(80 * (i + 1)) - 1 : (80 * i)]),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector[(80 * (i + 1)) - 1 : (80 * i)]),
      .mac_status_vector               (mac_status_vector[(2 * (i + 1)) - 1 : (2 * i)]),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector[(536 * (i + 1)) - 1 : (536 * i)]),
      .pcs_pma_status_vector           (pcs_pma_status_vector[(448 * (i + 1)) - 1 : (448 * i)]),


      // Serial links
      .txp                             (txp[i]),
      .txn                             (txn[i]),
      .rxp                             (rxp[i]),
      .rxn                             (rxn[i]),

      .transceiver_debug_gt_eyescanreset     (transceiver_debug_gt_eyescanreset[i]),
      .transceiver_debug_gt_eyescantrigger   (transceiver_debug_gt_eyescantrigger[i]),
      .transceiver_debug_gt_rxcdrhold        (transceiver_debug_gt_rxcdrhold[i]),
      .transceiver_debug_gt_txprbsforceerr   (transceiver_debug_gt_txprbsforceerr[i]),
      .transceiver_debug_gt_txpolarity       (transceiver_debug_gt_txpolarity[i]),
      .transceiver_debug_gt_rxpolarity       (transceiver_debug_gt_rxpolarity[i]),
      .transceiver_debug_gt_rxrate           (transceiver_debug_gt_rxrate[(3 * (i + 1)) - 1 : (3 * i)]),
      .transceiver_debug_gt_txpmareset       (transceiver_debug_gt_txpmareset[i]),
      .transceiver_debug_gt_rxpmareset       (transceiver_debug_gt_rxpmareset[i]),
      .transceiver_debug_gt_rxdfelpmreset    (transceiver_debug_gt_rxdfelpmreset[i]),
      .transceiver_debug_gt_rxpmaresetdone   (transceiver_debug_gt_rxpmaresetdone[i]),
      .transceiver_debug_gt_txresetdone      (transceiver_debug_gt_txresetdone[i]),
      .transceiver_debug_gt_rxresetdone      (transceiver_debug_gt_rxresetdone[i]),
      .transceiver_debug_gt_txprecursor      (transceiver_debug_gt_txprecursor[(5 * (i + 1)) - 1 : (5 * i)]),
      .transceiver_debug_gt_txpostcursor     (transceiver_debug_gt_txpostcursor[(5 * (i + 1)) - 1 : (5 * i)]),
      .transceiver_debug_gt_txdiffctrl       (transceiver_debug_gt_txdiffctrl[(4 * (i + 1)) - 1 : (4 * i)]),
      .transceiver_debug_gt_rxlpmen          (transceiver_debug_gt_rxlpmen[i]),
      .transceiver_debug_gt_eyescandataerror (transceiver_debug_gt_eyescandataerror[i]),
      .transceiver_debug_gt_txbufstatus      (transceiver_debug_gt_txbufstatus[(2 * (i + 1)) - 1 : (2 * i)]),
      .transceiver_debug_gt_rxbufstatus      (transceiver_debug_gt_rxbufstatus[(3 * (i + 1)) - 1 : (3 * i)]),
      .transceiver_debug_gt_rxprbserr        (transceiver_debug_gt_rxprbserr[i]),
      .transceiver_debug_gt_dmonitorout      (transceiver_debug_gt_dmonitorout[(17 * (i + 1)) - 1 : (17 * i)]),
      .transceiver_debug_gt_pcsrsvdin        (transceiver_debug_gt_pcsrsvdin[(16 * (i + 1)) - 1 : (16 * i)]),
      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (signal_detect[i]),
      .tx_fault                        (tx_fault[i]),
      .tx_disable                      (tx_disable[i]),
      .pcspma_status                   (pcspma_status[(8 * (i + 1)) - 1 : (8 * i)])
   );

end
endgenerate

endmodule
