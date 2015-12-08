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
   output                              coreclk_out,
   output                              rxrecclk_out,

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

   input       [G_GTCH_COUNT - 1 : 0]                        tx_axis_mac_aresetn,
   input       [G_GTCH_COUNT - 1 : 0]                        tx_axis_fifo_aresetn,
   input       [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]       tx_axis_fifo_tdata,
   input       [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0] tx_axis_fifo_tkeep,
   input       [G_GTCH_COUNT - 1 : 0]                        tx_axis_fifo_tvalid,
   input       [G_GTCH_COUNT - 1 : 0]                        tx_axis_fifo_tlast,
   output      [G_GTCH_COUNT - 1 : 0]                        tx_axis_fifo_tready,

   input       [G_GTCH_COUNT - 1 : 0]                        rx_axis_mac_aresetn,
   input       [G_GTCH_COUNT - 1 : 0]                        rx_axis_fifo_aresetn,
   output      [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]       rx_axis_fifo_tdata,
   output      [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0] rx_axis_fifo_tkeep,
   output      [G_GTCH_COUNT - 1 : 0]                        rx_axis_fifo_tvalid,
   output      [G_GTCH_COUNT - 1 : 0]                        rx_axis_fifo_tlast,
   input       [G_GTCH_COUNT - 1 : 0]                        rx_axis_fifo_tready,


   output      [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]         dbg_rx_axis_mac_tdata ,
   output      [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   dbg_rx_axis_mac_tkeep ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_rx_axis_mac_tvalid,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_rx_axis_mac_tlast ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_rx_axis_mac_tuser ,

   output      [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]         dbg_tx_axis_mac_tdata ,
   output      [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   dbg_tx_axis_mac_tkeep ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_mac_tvalid,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_mac_tlast ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_mac_tready,

   output      [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]         dbg_tx_axis_fifo_tdata ,
   output      [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0]   dbg_tx_axis_fifo_tkeep ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_fifo_tvalid,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_fifo_tlast ,
   output      [G_GTCH_COUNT - 1 : 0]                          dbg_tx_axis_fifo_tready,


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
   output      [G_GTCH_COUNT - 1 : 0]         tx_disable,
   output      [(8 * G_GTCH_COUNT) - 1 : 0]   pcspma_status
   );

/*-------------------------------------------------------------------------*/

   // Signal declarations

   wire  [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]       tx_axis_mac_tdata;
   wire  [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0] tx_axis_mac_tkeep;
   wire  [G_GTCH_COUNT - 1 : 0]                        tx_axis_mac_tvalid;
   wire  [G_GTCH_COUNT - 1 : 0]                        tx_axis_mac_tlast;
   wire  [G_GTCH_COUNT - 1 : 0]                        tx_axis_mac_tready;

   wire  [(G_AXI_DWIDTH * G_GTCH_COUNT) - 1 : 0]       rx_axis_mac_tdata;
   wire  [((G_AXI_DWIDTH / 8) * G_GTCH_COUNT) - 1 : 0] rx_axis_mac_tkeep;
   wire  [G_GTCH_COUNT - 1 : 0]                        rx_axis_mac_tvalid;
   wire  [G_GTCH_COUNT - 1 : 0]                        rx_axis_mac_tuser;
   wire  [G_GTCH_COUNT - 1 : 0]                        rx_axis_mac_tlast;

   wire                                 txusrclk2;

   wire                                 reset_counter_done;
   wire                                 qpll0lock;
   wire                                 qpll0outclk;
   wire                                 qpll0outrefclk;
   wire                                 txusrclk;
   wire                                 gttxreset;
   wire                                 gtrxreset;
   wire                                 txuserrdy;
   wire                                 coreclk;
   wire                                 areset_coreclk;

   wire  [G_GTCH_COUNT - 1 : 0]   rx_axis_mac_aresetn_i ;
   wire  [G_GTCH_COUNT - 1 : 0]   rx_axis_fifo_aresetn_i;
   wire  [G_GTCH_COUNT - 1 : 0]   tx_axis_mac_aresetn_i ;
   wire  [G_GTCH_COUNT - 1 : 0]   tx_axis_fifo_aresetn_i;

   assign coreclk_out = txusrclk2;
   assign qplllock_out = qpll0lock;


   //----------------------------------------------------------------------------
   // Instantiate the Ethernet core
   //----------------------------------------------------------------------------
   eth_core ethernet_core_i (
      .coreclk_out                     (coreclk),
      .areset_datapathclk_out          (),
      .refclk_p                        (refclk_p),
      .refclk_n                        (refclk_n),
      .dclk                            (dclk),
      .reset                           (reset),
      .resetdone_out                   (resetdone_out),
      .reset_counter_done_out          (reset_counter_done),
      .qpll0lock_out                   (qpll0lock),
      .qpll0outclk_out                 (qpll0outclk),
      .qpll0outrefclk_out              (qpll0outrefclk),
      .areset_coreclk_out              (areset_coreclk),
      .txusrclk_out                    (txusrclk),
      .txusrclk2_out                   (txusrclk2),
      .gttxreset_out                   (gttxreset),
      .gtrxreset_out                   (gtrxreset),
      .txuserrdy_out                   (txuserrdy),
      .rxrecclk_out                    (rxrecclk_out),
      .tx_ifg_delay                    (tx_ifg_delay),
      .tx_statistics_vector            (tx_statistics_vector[(26 * (0 + 1)) - 1 : (26 * 0)]),
      .tx_statistics_valid             (tx_statistics_valid[0]),
      .rx_statistics_vector            (rx_statistics_vector[(30 * (0 + 1)) - 1 : (30 * 0)]),
      .rx_statistics_valid             (rx_statistics_valid[0]),
      .s_axis_pause_tdata              (pause_val),
      .s_axis_pause_tvalid             (pause_req),

      .tx_axis_aresetn                 (tx_axis_mac_aresetn[0]),
      .s_axis_tx_tdata                 (tx_axis_mac_tdata[(G_AXI_DWIDTH * (0 + 1)) - 1 : (G_AXI_DWIDTH * 0)]),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid[0]),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast[0]),
      .s_axis_tx_tuser                 (1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (0 + 1)) - 1 : ((G_AXI_DWIDTH / 8) * 0)]),
      .s_axis_tx_tready                (tx_axis_mac_tready[0]),

      .rx_axis_aresetn                 (rx_axis_mac_aresetn[0]),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata[(G_AXI_DWIDTH * (0 + 1)) - 1 : (G_AXI_DWIDTH * 0)]),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (0 + 1)) - 1 : ((G_AXI_DWIDTH / 8) * 0)]),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid[0]),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser[0]),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast[0]),
      .mac_tx_configuration_vector     (mac_tx_configuration_vector[(80 * (0 + 1)) - 1 : (80 * 0)]),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector[(80 * (0 + 1)) - 1 : (80 * 0)]),
      .mac_status_vector               (mac_status_vector[(2 * (0 + 1)) - 1 : (2 * 0)]),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector[(536 * (0 + 1)) - 1 : (536 * 0)]),
      .pcs_pma_status_vector           (pcs_pma_status_vector[(448 * (0 + 1)) - 1 : (448 * 0)]),

      // Serial links
      .txp                             (txp[0]),
      .txn                             (txn[0]),
      .rxp                             (rxp[0]),
      .rxn                             (rxn[0]),
      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (signal_detect[0]),
      .tx_fault                        (tx_fault[0]),
      .tx_disable                      (tx_disable[0]),
      .pcspma_status                   (pcspma_status[(8 * (0 + 1)) - 1 : (8 * 0)])
   );


genvar i;
generate
for (i = 0; i < G_GTCH_COUNT; i = i + 1)
begin : ch

//   assign rx_axis_mac_aresetn_i[i]  = ~reset;// | rx_axis_mac_aresetn[i];
//   assign rx_axis_fifo_aresetn_i[i] = ~reset;// | rx_axis_fifo_aresetn[i];
//   assign tx_axis_mac_aresetn_i[i]  = ~reset;// | tx_axis_mac_aresetn[i];
//   assign tx_axis_fifo_aresetn_i[i] = ~reset;// | tx_axis_fifo_aresetn[i];

    assign rx_axis_mac_aresetn_i[i]  = ~reset;
    assign rx_axis_fifo_aresetn_i[i] = ~reset;
    assign tx_axis_mac_aresetn_i[i]  = ~reset;
    assign tx_axis_fifo_aresetn_i[i] = ~reset;

   //----------------------------------------------------------------------------
   // Instantiate the example design FIFO
   //----------------------------------------------------------------------------
  eth_core_xgmac_fifo #(
      .TX_FIFO_SIZE                    (FIFO_SIZE),
      .RX_FIFO_SIZE                    (FIFO_SIZE)
   ) ethernet_mac_fifo_i  (
      .tx_axis_fifo_aresetn            (tx_axis_fifo_aresetn_i[i]),
      .tx_axis_fifo_aclk               (txusrclk2),
      .tx_axis_fifo_tdata              (tx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .tx_axis_fifo_tkeep              (tx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .tx_axis_fifo_tvalid             (tx_axis_fifo_tvalid[i]),
      .tx_axis_fifo_tlast              (tx_axis_fifo_tlast[i]),
      .tx_axis_fifo_tready             (tx_axis_fifo_tready[i]),
      .tx_fifo_full                    (),
      .tx_fifo_status                  (),
      .rx_axis_fifo_aresetn            (rx_axis_fifo_aresetn_i[i]),
      .rx_axis_fifo_aclk               (txusrclk2),
      .rx_axis_fifo_tdata              (rx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .rx_axis_fifo_tkeep              (rx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .rx_axis_fifo_tvalid             (rx_axis_fifo_tvalid[i]),
      .rx_axis_fifo_tlast              (rx_axis_fifo_tlast[i]),
      .rx_axis_fifo_tready             (rx_axis_fifo_tready[i]),
      .rx_fifo_status                  (),
      .tx_axis_mac_aresetn             (tx_axis_mac_aresetn_i[i]),
      .tx_axis_mac_aclk                (txusrclk2),
      .tx_axis_mac_tdata               (tx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .tx_axis_mac_tkeep               (tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .tx_axis_mac_tvalid              (tx_axis_mac_tvalid[i]),
      .tx_axis_mac_tlast               (tx_axis_mac_tlast[i]),
      .tx_axis_mac_tready              (tx_axis_mac_tready[i]),
      .rx_axis_mac_aresetn             (rx_axis_mac_aresetn_i[i]),
      .rx_axis_mac_aclk                (txusrclk2),
      .rx_axis_mac_tdata               (rx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]),
      .rx_axis_mac_tkeep               (rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]),
      .rx_axis_mac_tvalid              (rx_axis_mac_tvalid[i]),
      .rx_axis_mac_tlast               (rx_axis_mac_tlast[i]),
      .rx_axis_mac_tuser               (rx_axis_mac_tuser[i]),
      .rx_fifo_full                    ()
   );

   assign dbg_rx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]              = rx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]            ;
   assign dbg_rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]  = rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)];
   assign dbg_rx_axis_mac_tvalid[i]                                                             = rx_axis_mac_tvalid[i]                                                           ;
   assign dbg_rx_axis_mac_tlast[i]                                                              = rx_axis_mac_tlast[i]                                                            ;
   assign dbg_rx_axis_mac_tuser[i]                                                              = rx_axis_mac_tuser[i]                                                            ;

   assign dbg_tx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]              = tx_axis_mac_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]            ;
   assign dbg_tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]  = tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)];
   assign dbg_tx_axis_mac_tvalid[i]                                                             = tx_axis_mac_tvalid[i]                                                           ;
   assign dbg_tx_axis_mac_tlast[i]                                                              = tx_axis_mac_tlast[i]                                                            ;
   assign dbg_tx_axis_mac_tready[i]                                                             = tx_axis_mac_tready[i]                                                           ;

   assign dbg_tx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]              = tx_axis_fifo_tdata[(G_AXI_DWIDTH * (i + 1)) - 1 : (G_AXI_DWIDTH * i)]            ;
   assign dbg_tx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)]  = tx_axis_fifo_tkeep[((G_AXI_DWIDTH / 8) * (i + 1)) - 1 : ((G_AXI_DWIDTH / 8) * i)];
   assign dbg_tx_axis_fifo_tvalid[i]                                                             = tx_axis_fifo_tvalid[i]                                                           ;
   assign dbg_tx_axis_fifo_tlast[i]                                                              = tx_axis_fifo_tlast[i]                                                            ;
   assign dbg_tx_axis_fifo_tready[i]                                                             = tx_axis_fifo_tready[i]                                                           ;

end //for (i = 0; i < G_GTCH_COUNT; i = i + 1)
endgenerate



//generate
//if (G_GTCH_COUNT == 1) begin
  //---------------------------------------------------------------------------
  // Instantiate the AXI 10G Ethernet core
  //---------------------------------------------------------------------------
  eth_core_s ethernet_core_2 (
      .dclk                            (dclk),
      .coreclk                         (coreclk),
      .txoutclk                        (txoutclk),
      .txusrclk                        (txusrclk),
      .txusrclk2                       (txusrclk2),
      .areset_coreclk                  (areset_coreclk),
      .txuserrdy                       (txuserrdy),
      .rxrecclk_out                    (), //(rxrecclk_out),
      .areset                          (reset),
      .tx_resetdone                    (), //(tx_resetdone_int),
      .rx_resetdone                    (), //(rx_resetdone_int),
      .reset_counter_done              (reset_counter_done),
      .gttxreset                       (gttxreset),
      .gtrxreset                       (gtrxreset),
      .qpll0lock                       (qpll0lock),
      .qpll0outclk                     (qpll0outclk),
      .qpll0outrefclk                  (qpll0outrefclk),
      .qpll0reset                      (), //(qpll0reset),
      .reset_tx_bufg_gt                (), //(reset_tx_bufg_gt),
      .tx_ifg_delay                    (tx_ifg_delay),
      .tx_statistics_vector            (tx_statistics_vector[(26 * (1 + 1)) - 1 : (26 * 1)]),
      .tx_statistics_valid             (tx_statistics_valid[1]),
      .rx_statistics_vector            (rx_statistics_vector[(30 * (1 + 1)) - 1 : (30 * 1)]),
      .rx_statistics_valid             (rx_statistics_valid[1]),
      .s_axis_pause_tdata              (pause_val),
      .s_axis_pause_tvalid             (pause_req),

      .tx_axis_aresetn                 (tx_axis_mac_aresetn[1]),
      .s_axis_tx_tdata                 (tx_axis_mac_tdata[(G_AXI_DWIDTH * (1 + 1)) - 1 : (G_AXI_DWIDTH * 1)]),
      .s_axis_tx_tvalid                (tx_axis_mac_tvalid[1]),
      .s_axis_tx_tlast                 (tx_axis_mac_tlast[1]),
      .s_axis_tx_tuser                 (1'b0),
      .s_axis_tx_tkeep                 (tx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (1 + 1)) - 1 : ((G_AXI_DWIDTH / 8) * 1)]),
      .s_axis_tx_tready                (tx_axis_mac_tready[1]),

      .rx_axis_aresetn                 (rx_axis_mac_aresetn[1]),
      .m_axis_rx_tdata                 (rx_axis_mac_tdata[(G_AXI_DWIDTH * (1 + 1)) - 1 : (G_AXI_DWIDTH * 1)]),
      .m_axis_rx_tkeep                 (rx_axis_mac_tkeep[((G_AXI_DWIDTH / 8) * (1 + 1)) - 1 : ((G_AXI_DWIDTH / 8) * 1)]),
      .m_axis_rx_tvalid                (rx_axis_mac_tvalid[1]),
      .m_axis_rx_tuser                 (rx_axis_mac_tuser[1]),
      .m_axis_rx_tlast                 (rx_axis_mac_tlast[1]),
      .mac_tx_configuration_vector     (mac_tx_configuration_vector[(80 * (1 + 1)) - 1 : (80 * 1)]),
      .mac_rx_configuration_vector     (mac_rx_configuration_vector[(80 * (1 + 1)) - 1 : (80 * 1)]),
      .mac_status_vector               (mac_status_vector[(2 * (1 + 1)) - 1 : (2 * 1)]),
      .pcs_pma_configuration_vector    (pcs_pma_configuration_vector[(536 * (1 + 1)) - 1 : (536 * 1)]),
      .pcs_pma_status_vector           (pcs_pma_status_vector[(448 * (1 + 1)) - 1 : (448 * 1)]),


      // Serial links
      .txp                             (txp[1]),
      .txn                             (txn[1]),
      .rxp                             (rxp[1]),
      .rxn                             (rxn[1]),

      .sim_speedup_control             (sim_speedup_control),
      .signal_detect                   (signal_detect[1]),
      .tx_fault                        (tx_fault[1]),
      .tx_disable                      (tx_disable[1]),
      .pcspma_status                   (pcspma_status[(8 * (1 + 1)) - 1 : (8 * 1)])
   );
//
//end //if (G_GTCH_COUNT = 1) begin
//endgenerate

endmodule
