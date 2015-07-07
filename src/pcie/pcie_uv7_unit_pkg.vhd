-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 10:29:01
-- Module Name : pcie_unit_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package pcie_unit_pkg is

component pio_to_ctrl
port (
clk        : in  std_logic;
rst_n      : in  std_logic;

req_compl  : in  std_logic;
compl_done : in  std_logic;

cfg_power_state_change_interrupt : in  std_logic;
cfg_power_state_change_ack       : out std_logic
);
end component pio_to_ctrl;

component pcie_rx
generic(
--AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
AXISTEN_IF_CQ_ALIGNMENT_MODE   : boolean := FALSE;
AXISTEN_IF_RC_ALIGNMENT_MODE   : boolean := FALSE;
AXISTEN_IF_RC_STRADDLE         : integer := 0;
AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1');

C_DATA_WIDTH                   : integer := 64     ;
STRB_WIDTH                     : integer := 64 / 8 ; -- TSTRB width
KEEP_WIDTH                     : integer := 64 / 32;
PARITY_WIDTH                   : integer := 64 / 8   -- TPARITY width
);
port (
user_clk              : in  std_logic;
reset_n               : in  std_logic;

-- Completer Request Interface
m_axis_cq_tdata       : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
m_axis_cq_tlast       : in  std_logic;
m_axis_cq_tvalid      : in  std_logic;
m_axis_cq_tuser       : in  std_logic_vector(84 downto 0);
m_axis_cq_tkeep       : in  std_logic_vector(KEEP_WIDTH - 1 downto 0);
pcie_cq_np_req_count  : in  std_logic_vector(5 downto 0);
m_axis_cq_tready      : out std_logic;
pcie_cq_np_req        : out std_logic;

-- Requester Completion Interface
m_axis_rc_tdata       : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
m_axis_rc_tlast       : in  std_logic;
m_axis_rc_tvalid      : in  std_logic;
m_axis_rc_tkeep       : in  std_logic_vector(KEEP_WIDTH - 1 downto 0);
m_axis_rc_tuser       : in  std_logic_vector(74 downto 0);
m_axis_rc_tready      : out std_logic;

--RX Message Interface
cfg_msg_received      : in  std_logic;
cfg_msg_received_type : in  std_logic_vector(4 downto 0);
cfg_msg_data          : in  std_logic_vector(7 downto 0);

-- Memory Read data handshake with Completion
-- transmit unit. Transmit unit reponds to
-- req_compl assertion and responds with compl_done
-- assertion when a Completion w/ data is transmitted.
req_compl             : out std_logic;
req_compl_wd          : out std_logic;
req_compl_ur          : out std_logic;
compl_done            : in  std_logic;

req_tc                : out std_logic_vector(2 downto 0) ;-- Memory Read TC
req_attr              : out std_logic_vector(2 downto 0) ;-- Memory Read Attribute
req_len               : out std_logic_vector(10 downto 0);-- Memory Read Length
req_rid               : out std_logic_vector(15 downto 0);-- Memory Read Requestor ID { 8'b0 (Bus no),
                                                          --                            3'b0 (Dev no),
                                                          --                            5'b0 (Func no)}
req_tag               : out std_logic_vector(7 downto 0) ;-- Memory Read Tag
req_be                : out std_logic_vector(7 downto 0) ;-- Memory Read Byte Enables
req_addr              : out std_logic_vector(12 downto 0);-- Memory Read Address
req_at                : out std_logic_vector(1 downto 0) ;-- Address Translation

-- Outputs to the TX Block in case of an UR
-- Required to form the completions
req_des_qword0        : out std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
req_des_qword1        : out std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
req_des_tph_present   : out std_logic;                    -- TPH Present in the request
req_des_tph_type      : out std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
req_des_tph_st_tag    : out std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

--Output to Indicate that the Request was a Mem lock Read Req
req_mem_lock          : out std_logic;
req_mem               : out std_logic;

--Memory interface used to save 2 DW data received
--on Memory Write 32 TLP. Data extracted from
--inbound TLP is presented to the Endpoint memory
--unit. Endpoint memory unit reacts to wr_en
--assertion and asserts wr_busy when it is
--processing written information.
wr_addr               : out std_logic_vector(10 downto 0);-- Memory Write Address
wr_be                 : out std_logic_vector(7 downto 0); -- Memory Write Byte Enable
wr_data               : out std_logic_vector(63 downto 0);-- Memory Write Data
wr_en                 : out std_logic;                    -- Memory Write Enable
payload_len           : out std_logic;                    -- Transaction Payload Length
wr_busy               : in  std_logic                     -- Memory Write Busy
);
end component pcie_rx;


component pcie_tx
generic (
--parameter [1:0] AXISTEN_IF_WIDTH = 00,
AXISTEN_IF_RQ_ALIGNMENT_MODE : boolean := FALSE;
AXISTEN_IF_CC_ALIGNMENT_MODE : boolean := FALSE;
AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;
AXISTEN_IF_CC_PARITY_CHECK   : integer := 0;

--Do not modify the parameters below this line
C_DATA_WIDTH : integer := 64; --(AXISTEN_IF_WIDTH[1]) ? 256 : (AXISTEN_IF_WIDTH[0])? 128 : 64,
PARITY_WIDTH : integer := 64 /8 ;
KEEP_WIDTH   : integer := 64 /32;
STRB_WIDTH   : integer := 64 / 8
);
port (
user_clk  : in  std_logic;
reset_n   : in  std_logic;

--AXI-S Completer Competion Interface
s_axis_cc_tdata  : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
s_axis_cc_tkeep  : out std_logic_vector(KEEP_WIDTH - 1 downto 0);
s_axis_cc_tlast  : out std_logic;
s_axis_cc_tvalid : out std_logic;
s_axis_cc_tuser  : out std_logic_vector(32 downto 0);
s_axis_cc_tready : in  std_logic;

--AXI-S Requester Request Interface
s_axis_rq_tdata  : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
s_axis_rq_tkeep  : out std_logic_vector(KEEP_WIDTH - 1 downto 0);
s_axis_rq_tlast  : out std_logic;
s_axis_rq_tvalid : out std_logic;
s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
s_axis_rq_tready : in  std_logic;

--TX Message Interface
cfg_msg_transmit_done : in  std_logic;
cfg_msg_transmit      : out std_logic;
cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
pcie_rq_tag          : in  std_logic_vector(5 downto 0);
pcie_rq_tag_vld      : in  std_logic;
pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
pcie_tfc_np_pl_empty : in  std_logic;
pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
pcie_rq_seq_num_vld  : in  std_logic;

--Cfg Flow Control Information
cfg_fc_ph   : in  std_logic_vector(7 downto 0);
cfg_fc_nph  : in  std_logic_vector(7 downto 0);
cfg_fc_cplh : in  std_logic_vector(7 downto 0);
cfg_fc_pd   : in  std_logic_vector(11 downto 0);
cfg_fc_npd  : in  std_logic_vector(11 downto 0);
cfg_fc_cpld : in  std_logic_vector(11 downto 0);
cfg_fc_sel  : out std_logic_vector(2 downto 0);

--PIO RX Engine Interface
req_compl    : in  std_logic;
req_compl_wd : in  std_logic;
req_compl_ur : in  std_logic;
payload_len  : in  std_logic;
compl_done   : out std_logic;

req_tc   : in  std_logic_vector(2 downto 0);
req_td   : in  std_logic;
req_ep   : in  std_logic;
req_attr : in  std_logic_vector(1 downto 0);
req_len  : in  std_logic_vector(10 downto 0);
req_rid  : in  std_logic_vector(15 downto 0);
req_tag  : in  std_logic_vector(7 downto 0);
req_be   : in  std_logic_vector(7 downto 0);
req_addr : in  std_logic_vector(12 downto 0);
req_at   : in  std_logic_vector(1 downto 0);

completer_id : in  std_logic_vector(15 downto 0);

--Inputs to the TX Block in case of an UR
--Required to form the completions
req_des_qword0      : in  std_logic_vector(63 downto 0);
req_des_qword1      : in  std_logic_vector(63 downto 0);
req_des_tph_present : in  std_logic;
req_des_tph_type    : in  std_logic_vector(1 downto 0);
req_des_tph_st_tag  : in  std_logic_vector(7 downto 0);

--Indicate that the Request was a Mem lock Read Req
req_mem_lock : in  std_logic;
req_mem      : in  std_logic;

--PIO Memory Access Control Interface
rd_addr         : out std_logic_vector(10 downto 0);
rd_be           : out std_logic_vector(3 downto 0);
trn_sent        : out std_logic;
rd_data         : in  std_logic_vector(31 downto 0);
gen_transaction : in  std_logic
);
end component pcie_tx;


component pcie_usr_app
generic (
TCQ : integer := 1
);
port (
user_clk : in  std_logic;
reset_n  : in  std_logic;

--Read Port
rd_addr  : in  std_logic_vector(10 downto 0);
rd_be    : in  std_logic_vector(3 downto 0);
trn_sent : in  std_logic;
rd_data  : out std_logic_vector(31 downto 0);

--Write Port
wr_addr  : in  std_logic_vector(10 downto 0);
wr_be    : in  std_logic_vector(7 downto 0);
wr_data  : in  std_logic_vector(63 downto 0);
wr_en    : in  std_logic;
wr_busy  : out std_logic;

--Payload info
payload_len : in  std_logic;

--Trigger to TX and Interrupt Handler Block to generate
--Transactions and Interrupts
gen_transaction : out std_logic;
gen_leg_intr    : out std_logic;
gen_msi_intr    : out std_logic;
gen_msix_intr   : out std_logic
);
end component pcie_usr_app;

end package pcie_unit_pkg;

