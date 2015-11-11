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
// Title      : Shared clocking and resets
// Project    : 10G Gigabit Ethernet
//-----------------------------------------------------------------------------
// File       : eth_core_shared_clock_and_reset.v
//-----------------------------------------------------------------------------
// Description: This file contains the
// 10GBASE-R/KR clocking and reset logic which can be shared between multiple cores
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

(* DowngradeIPIdentifiedWarnings="yes" *)
module  eth_core_shared_clock_and_reset   #(
  parameter   G_GTCH_COUNT = 1
  )
    (
     input  areset,
     input  refclk_p,
     input  refclk_n,
     input  [G_GTCH_COUNT - 1: 0]   qpll0reset,
     output refclk,
     input  [G_GTCH_COUNT - 1: 0]   txoutclk,
     output coreclk,
     input  qplllock,
     input  [G_GTCH_COUNT - 1: 0]   reset_tx_bufg_gt,
     output wire areset_coreclk,
     output wire [G_GTCH_COUNT - 1: 0]   areset_txusrclk2,
     output gttxreset,
     output gtrxreset,
     output reg [G_GTCH_COUNT - 1: 0]   txuserrdy,
     output [G_GTCH_COUNT - 1: 0]   txusrclk,
     output [G_GTCH_COUNT - 1: 0]   txusrclk2,
     output [G_GTCH_COUNT - 1: 0]   qpllreset,
     output reset_counter_done
    );

  wire coreclk_buf;
  wire [G_GTCH_COUNT - 1: 0]   qplllock_txusrclk2;
  reg [8:0] reset_counter = 9'h000;
  assign reset_counter_done = reset_counter[8];
  reg [3:0] reset_pulse = 4'b1110;
  wire [G_GTCH_COUNT - 1: 0]   gttxreset_txusrclk2;

  wire refclkcopy;

  IBUFDS_GTE3 ibufds_inst
  (
      .O       (refclk),
      .ODIV2   (refclkcopy),
      .CEB     (1'b0),
      .I     (refclk_p),
      .IB    (refclk_n)
  );

  BUFG_GT refclk_bufg_gt_i
  (
      .I       (refclkcopy),
      .CE      (1'b1),
      .CEMASK  (1'b1),
      .CLR     (1'b0),
      .CLRMASK (1'b1),
      .DIV     (3'b000),
      .O       (coreclk)
  );

genvar i0;
generate
for (i0 = 0; i0 < G_GTCH_COUNT; i0 = i0 + 1)
begin : txusrclk2_ch

  BUFG_GT txoutclk_bufg_gt_i
  (
      .I       (txoutclk[i0]),
      .CE      (1'b1),
      .CEMASK  (1'b1),
      .CLR     (reset_tx_bufg_gt[i0]),
      .CLRMASK (1'b0),
      .DIV     (3'b000),
      .O       (txusrclk[i0])
  );


  BUFG_GT txusrclk2_bufg_gt_i
  (
      .I       (txoutclk[i0]),
      .CE      (1'b1),
      .CEMASK  (1'b1),
      .CLR     (reset_tx_bufg_gt[i0]),
      .CLRMASK (1'b0),
      .DIV     (3'b001),
      .O       (txusrclk2[i0])
  );

end
endgenerate

  // Asynch reset synchronizers...

  eth_core_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b1))
  areset_coreclk_sync_i
    (
     .clk      (coreclk),
     .rst      (areset),
     .data_in  (1'b0),
     .data_out (areset_coreclk)
    );

genvar i1;
generate
for (i1 = 0; i1 < G_GTCH_COUNT; i1 = i1 + 1)
begin : qplllock_txusrclk2_ch

  eth_core_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL(1'b1))
  areset_txusrclk2_sync_i
    (
     .clk(txusrclk2[i1]),
     .rst(areset),
     .data_in(1'b0),
     .data_out(areset_txusrclk2[i1])
    );

  eth_core_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b0))
  qplllock_txusrclk2_sync_i
    (
     .clk      (txusrclk2[i1]),
     .rst      (!qplllock),
     .data_in  (1'b1),
     .data_out (qplllock_txusrclk2[i1])
    );

end
endgenerate

  // Hold off the GT resets until 500ns after configuration.
  // 128 ticks at 6.4ns period will be >> 500 ns.
  // 256 ticks at the minimum possible 2.56ns period (390MHz) will be >> 500 ns.

  always @(posedge coreclk)
  begin
    if (!reset_counter[8])
      reset_counter   <=   reset_counter + 1'b1;
    else
      reset_counter   <=   reset_counter;
  end

  always @(posedge coreclk)
  begin
    if (areset_coreclk == 1'b1)
      reset_pulse   <=   4'b1110;
    else if(reset_counter[8])
      reset_pulse   <=   {1'b0, reset_pulse[3:1]};
  end

  assign   qpllreset  =     qpll0reset;
  assign   gttxreset  =     reset_pulse[0];
  assign   gtrxreset  =     reset_pulse[0];

genvar i2;
generate
for (i2 = 0; i2 < G_GTCH_COUNT; i2 = i2 + 1)
begin : txuserrdy_ch

  eth_core_ff_synchronizer_rst2
    #(
      .C_NUM_SYNC_REGS(5),
      .C_RVAL  (1'b1))
  gttxreset_txusrclk2_sync_i
    (
     .clk      (txusrclk2[i2]),
     .rst      (gttxreset),
     .data_in  (1'b0),
     .data_out (gttxreset_txusrclk2[i2])
    );

  always @(posedge txusrclk2[i2] or posedge gttxreset_txusrclk2[i2])
  begin
     if(gttxreset_txusrclk2[i2])
       txuserrdy[i2] <= 1'b0;
     else
       txuserrdy[i2] <= qplllock_txusrclk2[i2];
  end

end
endgenerate

endmodule



