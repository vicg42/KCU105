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
// Title      : FIFO block level
// Project    : 10G/25G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : eth_core_fifo_block.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// Description: This is the FIFO block level code for the 10G/25G Gigabit
//              Ethernet IP. It contains example design AXI FIFOs connected to
//              the AXI-S transmit and receive interfaces of the Ethernet core.
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module eth_core_fifo_block  #(
parameter   G_AXI_DWIDTH = 64,
parameter   G_GTCH_COUNT = 1,
parameter                              FIFO_SIZE = 1024
) (
   // Port declarations
   input                               refclk_p,
   input                               refclk_n,
   input                               dclk,
   input                               reset,
   output                              resetdone_out,
   output                              qplllock_out,
   output      [G_GTCH_COUNT - 1 : 0]  coreclk_out,
   output      [G_GTCH_COUNT - 1 : 0]  rxrecclk_out,
   output      [G_GTCH_COUNT - 1 : 0]  txuserrdy_out,

   input       [(80 * G_GTCH_COUNT) - 1 : 0]    mac_tx_configuration_vector,
   input       [(80 * G_GTCH_COUNT) - 1 : 0]    mac_rx_configuration_vector,
   output      [(2 * G_GTCH_COUNT) - 1 : 0]     mac_status_vector,
   input       [(536 * G_GTCH_COUNT) - 1 : 0]   pcs_pma_configuration_vector,
   output      [(448 * G_GTCH_COUNT) - 1 : 0]   pcs_pma_status_vector,

   input       [7:0]                   tx_ifg_delay,
   output      [(26 * G_GTCH_COUNT) - 1 : 0]  tx_statistics_vector,
   output      [(30 * G_GTCH_COUNT) - 1 : 0]  rx_statistics_vector,
   output      [G_GTCH_COUNT - 1 : 0]         tx_statistics_valid,
   output      [G_GTCH_COUNT - 1 : 0]         rx_statistics_valid,
   input       [G_GTCH_COUNT - 1 : 0]         tx_axis_mac_aresetn,
   input       [G_GTCH_COUNT - 1 : 0]         tx_axis_fifo_aresetn,
   input       [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]         tx_axis_fifo_tdata,
   input       [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   tx_axis_fifo_tkeep,
   input       [G_GTCH_COUNT - 1 : 0]         tx_axis_fifo_tvalid,
   input       [G_GTCH_COUNT - 1 : 0]         tx_axis_fifo_tlast,
   output      [G_GTCH_COUNT - 1 : 0]         tx_axis_fifo_tready,

   input       [G_GTCH_COUNT - 1 : 0]         rx_axis_mac_aresetn,
   input       [G_GTCH_COUNT - 1 : 0]         rx_axis_fifo_aresetn,
   output      [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]         rx_axis_fifo_tdata,
   output      [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   rx_axis_fifo_tkeep,
   output      [G_GTCH_COUNT - 1 : 0]         rx_axis_fifo_tvalid,
   output      [G_GTCH_COUNT - 1 : 0]         rx_axis_fifo_tlast,
   input       [G_GTCH_COUNT - 1 : 0]         rx_axis_fifo_tready,

   //Pause axis
   input      [15:0]                   pause_val,
   input                               pause_req,

   output      [G_GTCH_COUNT - 1 : 0]         txp,
   output      [G_GTCH_COUNT - 1 : 0]         txn,
   input       [G_GTCH_COUNT - 1 : 0]         rxp,
   input       [G_GTCH_COUNT - 1 : 0]         rxn,

   input       [G_GTCH_COUNT - 1 : 0]         signal_detect,
   input                                      sim_speedup_control,
   input       [G_GTCH_COUNT - 1 : 0]         tx_fault,
   output      [(8 * G_GTCH_COUNT) - 1 : 0]   pcspma_status
   );

/*-------------------------------------------------------------------------*/

   // Signal declarations

   reg [G_GTCH_COUNT - 1 : 0]         rx_axis_mac_aresetn_i;
   reg [G_GTCH_COUNT - 1 : 0]         rx_axis_fifo_aresetn_i;
   reg [G_GTCH_COUNT - 1 : 0]         tx_axis_mac_aresetn_i;
   reg [G_GTCH_COUNT - 1 : 0]         tx_axis_fifo_aresetn_i;

   wire         [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]  tx_axis_mac_tdata;
   wire         [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   tx_axis_mac_tkeep;
   wire         [G_GTCH_COUNT - 1 : 0]         tx_axis_mac_tvalid;
   wire         [G_GTCH_COUNT - 1 : 0]         tx_axis_mac_tlast;
   wire         [G_GTCH_COUNT - 1 : 0]         tx_axis_mac_tready;

   wire         [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]  rx_axis_mac_tdata;
   wire         [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   rx_axis_mac_tkeep;
   wire         [G_GTCH_COUNT - 1 : 0]         rx_axis_mac_tvalid;
   wire         [G_GTCH_COUNT - 1 : 0]         rx_axis_mac_tuser;
   wire         [G_GTCH_COUNT - 1 : 0]         rx_axis_mac_tlast;

   wire         [G_GTCH_COUNT - 1 : 0]         coreclk;
   wire         [G_GTCH_COUNT - 1 : 0]         tx_disable;

   wire         [127:0]  zero_i;
   assign zero_i = 128'b0;

   assign coreclk_out = coreclk;


   //----------------------------------------------------------------------------
   // Instantiate the Ethernet Core Support level
   //----------------------------------------------------------------------------
   eth_core_support #(
      .G_AXI_DWIDTH (G_AXI_DWIDTH),
      .G_GTCH_COUNT (G_GTCH_COUNT)
   )  support_layer_i(
      .coreclk_out                     (),
      .qpll0reset_out                  (),
      .refclk_p                        (refclk_p),
      .refclk_n                        (refclk_n),
      .dclk                            (dclk),
      .reset                           (reset),
      .resetdone_out                   (resetdone_out),
      .reset_counter_done_out          (),
      .qpll0lock_out                   (qplllock_out),
      .qpll0outclk_out                 (),
      .qpll0outrefclk_out              (),
      .txusrclk_out                    (),
      .txusrclk2_out                   (coreclk),
      .gttxreset_out                   (),
      .gtrxreset_out                   (),
      .txuserrdy_out                   (txuserrdy_out),
      .rxrecclk_out                    (rxrecclk_out),
      .tx_ifg_delay                    (tx_ifg_delay),
      .tx_statistics_vector            (tx_statistics_vector),
      .tx_statistics_valid             (tx_statistics_valid),
      .rx_statistics_vector            (rx_statistics_vector),
      .rx_statistics_valid             (rx_statistics_valid),
      .s_axis_pause_tdata              (pause_val),
      .s_axis_pause_tvalid             (pause_req),

      .tx_axis_aresetn                 (tx_axis_mac_aresetn),
      .s_axis_tx_tdata                 (tx_axis_mac_tdata),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast),
      .s_axis_tx_tuser                 (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep),
      .s_axis_tx_tready                (tx_axis_mac_tready),

      .rx_axis_aresetn                 (rx_axis_mac_aresetn),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast),
      .mac_tx_configuration_vector     (mac_tx_configuration_vector),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector),
      .mac_status_vector               (mac_status_vector),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector),
      .pcs_pma_status_vector           (pcs_pma_status_vector),

      // Serial links
      .txp                             (txp),
      .txn                             (txn),
      .rxp                             (rxp),
      .rxn                             (rxn),
      .transceiver_debug_gt_eyescanreset     (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_eyescantrigger   (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxcdrhold        (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_txprbsforceerr   (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_txpolarity       (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxpolarity       (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxrate           (zero_i[(3 * G_GTCH_COUNT) - 1 : 0]), //(3'b0),
      .transceiver_debug_gt_txpmareset       (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxpmareset       (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxdfelpmreset    (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_rxpmaresetdone   (),
      .transceiver_debug_gt_txresetdone      (),
      .transceiver_debug_gt_rxresetdone      (),
      .transceiver_debug_gt_txoutclksel      (3'b101),
      .transceiver_debug_gt_txpcsreset       (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_txprecursor      (zero_i[(5 * G_GTCH_COUNT) - 1 : 0]), //(5'b0),
      .transceiver_debug_gt_txpostcursor     (zero_i[(5 * G_GTCH_COUNT) - 1 : 0]), //(5'b0),
      .transceiver_debug_gt_txdiffctrl       (zero_i[(4 * G_GTCH_COUNT) - 1 : 0]), //(4'b0),
      .transceiver_debug_gt_rxlpmen          (zero_i[G_GTCH_COUNT - 1 : 0]), //(1'b0),
      .transceiver_debug_gt_eyescandataerror (),
      .transceiver_debug_gt_txbufstatus      (),
      .transceiver_debug_gt_rxbufstatus      (),
      .transceiver_debug_gt_rxprbserr        (),
      .transceiver_debug_gt_dmonitorout      (),
      .transceiver_debug_gt_pcsrsvdin        (zero_i[(16 * G_GTCH_COUNT) - 1 : 0]), //(16'b0),
      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (signal_detect),
      .tx_fault                        (tx_fault),
      .tx_disable                      (tx_disable),
      .pcspma_status                   (pcspma_status)
   );

genvar i;
generate
for (i = 0; i < G_GTCH_COUNT; i = i + 1)
begin : ch

//   assign rx_axis_mac_aresetn_i[i]  = ~reset;// | rx_axis_mac_aresetn[i];
//   assign rx_axis_fifo_aresetn_i[i] = ~reset;// | rx_axis_fifo_aresetn[i];
//   assign tx_axis_mac_aresetn_i[i]  = ~reset;// | tx_axis_mac_aresetn[i];
//   assign tx_axis_fifo_aresetn_i[i] = ~reset;// | tx_axis_fifo_aresetn[i];

   always @(coreclk[i], reset)
   begin
    rx_axis_mac_aresetn_i[i]  <= ~reset;
    rx_axis_fifo_aresetn_i[i] <= ~reset;
    tx_axis_mac_aresetn_i[i]  <= ~reset;
    tx_axis_fifo_aresetn_i[i] <= ~reset;
   end

   //----------------------------------------------------------------------------
   // Instantiate the example design FIFO
   //----------------------------------------------------------------------------
  eth_core_xgmac_fifo #(
      .TX_FIFO_SIZE                    (FIFO_SIZE),
      .RX_FIFO_SIZE                    (FIFO_SIZE)
   ) ethernet_mac_fifo_i  (
      .tx_axis_fifo_aresetn            (tx_axis_fifo_aresetn_i[i]),
      .tx_axis_fifo_aclk               (coreclk[i]),
      .tx_axis_fifo_tdata              (tx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .tx_axis_fifo_tkeep              (tx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .tx_axis_fifo_tvalid             (tx_axis_fifo_tvalid[i]),
      .tx_axis_fifo_tlast              (tx_axis_fifo_tlast[i]),
      .tx_axis_fifo_tready             (tx_axis_fifo_tready[i]),
      .tx_fifo_full                    (),
      .tx_fifo_status                  (),
      .rx_axis_fifo_aresetn            (rx_axis_fifo_aresetn_i[i]),
      .rx_axis_fifo_aclk               (coreclk[i]),
      .rx_axis_fifo_tdata              (rx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .rx_axis_fifo_tkeep              (rx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .rx_axis_fifo_tvalid             (rx_axis_fifo_tvalid[i]),
      .rx_axis_fifo_tlast              (rx_axis_fifo_tlast[i]),
      .rx_axis_fifo_tready             (rx_axis_fifo_tready[i]),
      .rx_fifo_status                  (),
      .tx_axis_mac_aresetn             (tx_axis_mac_aresetn_i[i]),
      .tx_axis_mac_aclk                (coreclk[i]),
      .tx_axis_mac_tdata               (tx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .tx_axis_mac_tkeep               (tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .tx_axis_mac_tvalid              (tx_axis_mac_tvalid[i]),
      .tx_axis_mac_tlast               (tx_axis_mac_tlast[i]),
      .tx_axis_mac_tready              (tx_axis_mac_tready[i]),
      .rx_axis_mac_aresetn             (rx_axis_mac_aresetn_i[i]),
      .rx_axis_mac_aclk                (rxrecclk_out[i]),
      .rx_axis_mac_tdata               (rx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .rx_axis_mac_tkeep               (rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .rx_axis_mac_tvalid              (rx_axis_mac_tvalid[i]),
      .rx_axis_mac_tlast               (rx_axis_mac_tlast[i]),
      .rx_axis_mac_tuser               (rx_axis_mac_tuser[i]),
      .rx_fifo_full                    ()
   );

end
endgenerate


endmodule
