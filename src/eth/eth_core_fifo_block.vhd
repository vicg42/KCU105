-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 03.05.2011 16:39:38
-- Module Name : eth_core_fifo_block
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_core_fifo_block is
port(

-------------------------------
--System
-------------------------------
p_in_rst          : in    std_logic
);
end entity eth_core_fifo_block;

architecture behavioral of eth_core_fifo_block is

module eth_core_xgmac_fifo #(
    parameter  TX_FIFO_SIZE = 512,
    parameter  RX_FIFO_SIZE = 512)
  (
    //--------------------------------------------------------------
    // client interface                                           --
    //--------------------------------------------------------------
    // tx_wr_clk domain
    input         tx_axis_fifo_aresetn,
    input         tx_axis_fifo_aclk,
    input [63:0]  tx_axis_fifo_tdata,
    input [7:0]   tx_axis_fifo_tkeep,
    input         tx_axis_fifo_tvalid,
    input         tx_axis_fifo_tlast,
    output        tx_axis_fifo_tready,
    output        tx_fifo_full,
    output [3:0]  tx_fifo_status,
    //rx_rd_clk domain
    input         rx_axis_fifo_aresetn,
    input         rx_axis_fifo_aclk,
    output [63:0] rx_axis_fifo_tdata,
    output [7:0]  rx_axis_fifo_tkeep,
    output        rx_axis_fifo_tvalid,
    output        rx_axis_fifo_tlast,
    input         rx_axis_fifo_tready,
    output [3:0]  rx_fifo_status,
    //--------------------------------------------------------------
    // mac transmitter interface                                  --
    //--------------------------------------------------------------
    input         tx_axis_mac_aresetn,
    input         tx_axis_mac_aclk,
    output [63:0] tx_axis_mac_tdata,
    output [7:0]  tx_axis_mac_tkeep,
    output        tx_axis_mac_tvalid,
    output        tx_axis_mac_tlast,
    input         tx_axis_mac_tready,
    //--------------------------------------------------------------
    // mac receiver interface                                     --
    //--------------------------------------------------------------
    input         rx_axis_mac_aresetn,
    input         rx_axis_mac_aclk,
    input [63:0]  rx_axis_mac_tdata,
    input [7:0]   rx_axis_mac_tkeep,
    input         rx_axis_mac_tvalid,
    input         rx_axis_mac_tlast,
    input         rx_axis_mac_tuser,
    output        rx_fifo_full);



begin --architecture behavioral of eth_core_fifo_block is



end architecture behavioral;
