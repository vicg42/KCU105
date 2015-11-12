onerror {resume}
quietly virtual signal -install {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i} { /eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tdata[15:0]} rx_axis_mac_15_0
quietly virtual signal -install {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i} { /eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tdata[31:16]} rx_axis_mac_31_16
quietly virtual signal -install {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i} { /eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tdata[47:32]} rx_axis_mac_47_32
quietly virtual signal -install {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i} { /eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tdata[63:48]} rx_axis_mac_63_48
quietly virtual signal -install /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx { /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_ethrx_len(7 downto 0)} i_rxlen_7_0
quietly virtual signal -install /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx { /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_ethrx_len(15 downto 8)} i_rxlen_15_8
quietly virtual signal -install /eth_core_tb/dut/m_fifo_loop { /eth_core_tb/dut/m_fifo_loop/din(31 downto 0)} fifo_loop_di_31_0
quietly virtual signal -install /eth_core_tb/dut/m_fifo_loop { /eth_core_tb/dut/m_fifo_loop/din(63 downto 32)} fifo_loop_di_63_32
quietly virtual signal -install /eth_core_tb/dut/m_fifo_loop { /eth_core_tb/dut/m_fifo_loop/dout(31 downto 0)} fifo_loop_do_31_0
quietly virtual signal -install /eth_core_tb/dut/m_fifo_loop { /eth_core_tb/dut/m_fifo_loop/dout(63 downto 32)} fifo_loop_do_63_32
quietly WaveActivateNextPane {} 0
add wave -noupdate /eth_core_tb/reset
add wave -noupdate /eth_core_tb/dut/refclk_p
add wave -noupdate /eth_core_tb/dut/refclk_n
add wave -noupdate /eth_core_tb/dut/core_ready
add wave -noupdate /glbl/GSR
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_aresetn}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_aclk}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tuser}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tkeep}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tlast}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tvalid}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_63_48}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_47_32}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_31_16}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_15_0}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_mac_tdata}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_aresetn}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_aclk}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_tdata}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_tkeep}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_tvalid}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_tlast}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/rx_axis_fifo_tready}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_aresetn}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_aclk}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_tdata}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_tkeep}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_tvalid}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_tlast}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_fifo_tready}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_aresetn}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_aclk}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_tdata}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_tkeep}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_tvalid}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_tlast}
add wave -noupdate {/eth_core_tb/dut/m_eth/m_eth_app/fifo_block_i/ch[0]/ethernet_mac_fifo_i/tx_axis_mac_tready}
add wave -noupdate -divider MAC_RX
add wave -noupdate -expand /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_cfg.mac
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_rst
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_ethrx_mac_valid
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_eth_axi_tvalid
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_eth_axi_tlast
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_eth_axi_tkeep
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_eth_axi_data
add wave -noupdate -color {Slate Blue} -itemcolor Gold /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_fsm_eth_rx
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_rxlen_15_8
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_rxlen_7_0
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_ethrx_len
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/sr_eth_axi_data
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/i_rx_d
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_in_usr_axi_tready
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_out_usr_axi_tdata
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_out_usr_axi_tkeep
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_out_usr_axi_tvalid
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_rx/p_out_usr_axi_tuser
add wave -noupdate /eth_core_tb/dut/m_eth/i_txuserrdy_out
add wave -noupdate -divider FIFO_LOOP
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/fifo_loop_di_31_0
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/fifo_loop_di_63_32
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/din
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/wr_en
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/rd_en
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/fifo_loop_do_31_0
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/fifo_loop_do_63_32
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/dout
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/full
add wave -noupdate /eth_core_tb/dut/m_fifo_loop/empty
add wave -noupdate -divider MAC_TX
add wave -noupdate -color {Slate Blue} -itemcolor Gold /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/i_fsm_eth_tx
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_in_usr_axi_tdata
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_out_usr_axi_tready
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_in_usr_axi_tvalid
add wave -noupdate -radix unsigned /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/i_total_count_byte
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/i_rd_chunk_cnt
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/i_rd_chunk_count
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/i_rd_chunk_rem
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_in_eth_axi_tready
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_out_eth_axi_tdata
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_out_eth_axi_tkeep
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_out_eth_axi_tvalid
add wave -noupdate /eth_core_tb/dut/m_eth/gen_mac_ch(0)/m_mac_tx/p_out_eth_axi_tlast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8002120 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
configure wave -valuecolwidth 87
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {6547032 ps} {10352984 ps}
