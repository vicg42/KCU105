-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 07.07.2015 10:45:04
-- Module Name : pcie_ctrl.vhd
--
-- Description : CTRL core PCI-Express
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pcie_unit_pkg.all;
use work.prj_def.all;
use work.prj_cfg.all;

entity pcie_ctrl is
generic(
G_DATA_WIDTH                     : integer := 64;
G_KEEP_WIDTH                     : integer := 1;
G_AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
G_AXISTEN_IF_RQ_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_CC_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : boolean := FALSE;
G_AXISTEN_IF_ENABLE_CLIENT_TAG   : integer := 1;
G_AXISTEN_IF_RQ_PARITY_CHECK     : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK     : integer := 0;
G_AXISTEN_IF_MC_RX_STRADDLE      : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1')
);
port(
--------------------------------------
--USR Port
--------------------------------------
p_out_hclk      : out   std_logic;
p_out_gctrl     : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);

--CTRL user devices
p_out_dev_ctrl  : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din   : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_in_dev_dout   : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);
p_out_dev_wr    : out   std_logic;
p_out_dev_rd    : out   std_logic;
p_in_dev_status : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq    : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt    : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt   : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--DBG
p_out_tst       : out   std_logic_vector(127 downto 0);
p_in_tst        : in    std_logic_vector(127 downto 0);

------------------------------------
--AXI Interface
------------------------------------
p_out_s_axis_rq_tlast  : out  std_logic                                  ;
p_out_s_axis_rq_tdata  : out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tuser  : out  std_logic_vector(59 downto 0)              ;
p_out_s_axis_rq_tkeep  : out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_s_axis_rq_tready  : in   std_logic_vector(3 downto 0)               ;
p_out_s_axis_rq_tvalid : out  std_logic                                  ;

p_in_m_axis_rc_tdata   : in   std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser   : in   std_logic_vector(74 downto 0)              ;
p_in_m_axis_rc_tlast   : in   std_logic                                  ;
p_in_m_axis_rc_tkeep   : in   std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tvalid  : in   std_logic                                  ;
p_out_m_axis_rc_tready : out  std_logic_vector(21 downto 0)              ;

p_in_m_axis_cq_tdata   : in   std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tuser   : in   std_logic_vector(84 downto 0)              ;
p_in_m_axis_cq_tlast   : in   std_logic                                  ;
p_in_m_axis_cq_tkeep   : in   std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_cq_tvalid  : in   std_logic                                  ;
p_out_m_axis_cq_tready : out  std_logic_vector(21 downto 0)              ;

p_out_s_axis_cc_tdata  : out  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tuser  : out  std_logic_vector(32 downto 0)              ;
p_out_s_axis_cc_tlast  : out  std_logic                                  ;
p_out_s_axis_cc_tkeep  : out  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tvalid : out  std_logic                                  ;
p_in_s_axis_cc_tready  : in   std_logic_vector(3 downto 0)               ;

p_in_pcie_tfc_nph_av  : in   std_logic_vector(1 downto 0)                ;
p_in_pcie_tfc_npd_av  : in   std_logic_vector(1 downto 0)                ;

------------------------------------
--Configuration (CFG) Interface
------------------------------------
p_in_pcie_rq_seq_num      : in   std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in   std_logic                   ;
p_in_pcie_rq_tag          : in   std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in   std_logic                   ;
p_out_pcie_cq_np_req      : out  std_logic                   ;
p_in_pcie_cq_np_req_count : in   std_logic_vector(5 downto 0);
p_in_pcie_tfc_np_pl_empty : in   std_logic                   ;
--p_in_pcie_rq_tag_av       : in   std_logic_vector(1 downto 0);

------------------------------------
--Management Interface
------------------------------------
p_in_cfg_msg_received         : in  std_logic;
p_in_cfg_msg_received_data    : in  std_logic_vector(7 downto 0);
p_in_cfg_msg_received_type    : in  std_logic_vector(4 downto 0);
p_out_cfg_msg_transmit        : out std_logic;
p_out_cfg_msg_transmit_type   : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data   : out std_logic_vector(31 downto 0);
p_in_cfg_msg_transmit_done    : in  std_logic;

------------------------------------
-- EP and RP
------------------------------------
p_in_cfg_negotiated_width : in   std_logic_vector(3 downto 0);
--p_in_cfg_current_speed    : in   std_logic_vector(2 downto 0);
p_in_cfg_max_payload      : in   std_logic_vector(2 downto 0);
p_in_cfg_max_read_req     : in   std_logic_vector(2 downto 0);
p_in_cfg_function_status  : in   std_logic_vector(7 downto 0);

-- Error Reporting Interface
p_in_cfg_err_cor_out      : in   std_logic;
p_in_cfg_err_nonfatal_out : in   std_logic;
p_in_cfg_err_fatal_out    : in   std_logic;


p_in_cfg_fc_ph            : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_pd            : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_nph           : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_npd           : in   std_logic_vector(11 downto 0);
p_in_cfg_fc_cplh          : in   std_logic_vector( 7 downto 0);
p_in_cfg_fc_cpld          : in   std_logic_vector(11 downto 0);
p_out_cfg_fc_sel          : out  std_logic_vector( 2 downto 0);

p_out_cfg_dsn                         : out  std_logic_vector(63 downto 0);
p_out_cfg_power_state_change_ack      : out  std_logic;
p_in_cfg_power_state_change_interrupt : in   std_logic;
p_out_cfg_err_cor_in                  : out  std_logic;
p_out_cfg_err_uncor_in                : out  std_logic;

p_in_cfg_flr_in_process       : in   std_logic_vector(3 downto 0);
p_out_cfg_flr_done            : out  std_logic_vector(3 downto 0);
p_in_cfg_vf_flr_in_process    : in   std_logic_vector(7 downto 0);
p_out_cfg_vf_flr_done         : out  std_logic_vector(7 downto 0);

p_out_cfg_ds_port_number      : out  std_logic_vector(7 downto 0);
p_out_cfg_ds_bus_number       : out  std_logic_vector(7 downto 0);
p_out_cfg_ds_device_number    : out  std_logic_vector(4 downto 0);
p_out_cfg_ds_function_number  : out  std_logic_vector(2 downto 0);

------------------------------------
-- EP Only
------------------------------------
-- Interrupt Interface Signals
p_out_cfg_interrupt_int                 : out  std_logic_vector(3 downto 0) ;
p_out_cfg_interrupt_pending             : out  std_logic_vector(3 downto 0) ;
p_in_cfg_interrupt_sent                 : in   std_logic                    ;

p_in_cfg_interrupt_msi_enable           : in   std_logic_vector(1 downto 0) ;
p_in_cfg_interrupt_msi_vf_enable        : in   std_logic_vector(5 downto 0) ;
p_in_cfg_interrupt_msi_mmenable         : in   std_logic_vector(5 downto 0) ;
p_in_cfg_interrupt_msi_mask_update      : in   std_logic                    ;
p_in_cfg_interrupt_msi_data             : in   std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_select          : out  std_logic_vector( 3 downto 0);
p_out_cfg_interrupt_msi_int             : out  std_logic_vector(31 downto 0);
p_out_cfg_interrupt_msi_pending_status  : out  std_logic_vector(31 downto 0);
p_in_cfg_interrupt_msi_sent             : in   std_logic                    ;
p_in_cfg_interrupt_msi_fail             : in   std_logic                    ;
p_out_cfg_interrupt_msi_attr            : out  std_logic_vector(2 downto 0) ;
p_out_cfg_interrupt_msi_tph_present     : out  std_logic                    ;
p_out_cfg_interrupt_msi_tph_type        : out  std_logic_vector(1 downto 0) ;
p_out_cfg_interrupt_msi_tph_st_tag      : out  std_logic_vector(8 downto 0) ;
p_out_cfg_interrupt_msi_function_number : out  std_logic_vector(3 downto 0) ;
p_in_cfg_interrupt_msi_pending_status_data_enable  : in  std_logic;
p_in_cfg_interrupt_msi_pending_status_function_num : in  std_logic_vector(3 downto 0);

p_in_cfg_interrupt_msix_enable          : in  std_logic;
p_in_cfg_interrupt_msix_sent            : in  std_logic;
p_in_cfg_interrupt_msix_fail            : in  std_logic;
p_out_cfg_interrupt_msix_int            : out std_logic;
p_out_cfg_interrupt_msix_address        : out std_logic_vector(63 downto 0);
p_out_cfg_interrupt_msix_data           : out std_logic_vector(31 downto 0);

-- EP only
p_in_cfg_hot_reset_in   : in   std_logic;

-- RP only
p_out_cfg_hot_reset_out : out  std_logic;

p_in_user_clk           : in   std_logic;
p_in_user_reset_n       : in   std_logic;
p_in_user_lnk_up        : in   std_logic
);
end entity pcie_ctrl;

architecture struct of pcie_ctrl is

--C_DATA_WIDTH                   : integer := 64     ;
constant CI_STRB_WIDTH   : integer := G_DATA_WIDTH / 8 ; -- TSTRB width
constant CI_KEEP_WIDTH   : integer := G_DATA_WIDTH / 32;
constant CI_PARITY_WIDTH : integer := G_DATA_WIDTH / 8 ;  -- TPARITY width


type TSR_flr_bus2 is array (0 to 1) of std_logic_vector(1 downto 0);
type TSR_flr_bus6 is array (0 to 1) of std_logic_vector(5 downto 0);
signal sr_cfg_flr_done         : TSR_flr_bus2;
signal sr_cfg_vf_flr_done      : TSR_flr_bus6;

signal i_req_completion        : std_logic;
signal i_completion_done       : std_logic;
signal i_rst_n                 : std_logic;

signal i_req_compl             : std_logic;
signal i_req_compl_wd          : std_logic;
signal i_req_compl_ur          : std_logic;
signal i_compl_done            : std_logic;

signal i_req_tc                : std_logic_vector(2 downto 0) ;
signal i_req_attr              : std_logic_vector(2 downto 0) ;
signal i_req_len               : std_logic_vector(10 downto 0);
signal i_req_rid               : std_logic_vector(15 downto 0);
signal i_req_tag               : std_logic_vector(7 downto 0) ;
signal i_req_be                : std_logic_vector(7 downto 0) ;
signal i_req_addr              : std_logic_vector(12 downto 0);
signal i_req_at                : std_logic_vector(1 downto 0) ;

signal i_req_des_qword0        : std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
signal i_req_des_qword1        : std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
signal i_req_des_tph_present   : std_logic;                    -- TPH Present in the request
signal i_req_des_tph_type      : std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
signal i_req_des_tph_st_tag    : std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

signal i_req_mem_lock          : std_logic;
signal i_req_mem               : std_logic;

signal i_wr_addr               : std_logic_vector(10 downto 0);-- Memory Write Address
signal i_wr_be                 : std_logic_vector(7 downto 0); -- Memory Write Byte Enable
signal i_wr_data               : std_logic_vector(63 downto 0);-- Memory Write Data
signal i_wr_en                 : std_logic;                    -- Memory Write Enable
signal i_payload_len           : std_logic;                    -- Transaction Payload Length
signal i_wr_busy               : std_logic;                    -- Memory Write Busy

signal i_rd_addr               : std_logic_vector(10 downto 0);
signal i_rd_be                 : std_logic_vector(3 downto 0);
signal i_trn_sent              : std_logic;
signal i_rd_data               : std_logic_vector(31 downto 0);

signal i_m_axis_cq_tready      : std_logic;
signal i_m_axis_rc_tready      : std_logic;

signal i_interrupt_done        : std_logic;

signal i_gen_transaction       : std_logic;
signal i_gen_leg_intr          : std_logic;
signal i_gen_msi_intr          : std_logic;
signal i_gen_msix_intr         : std_logic;


begin --architecture struct of pcie_ctrl


----------------------------------------
--Function level reset (FLR)
----------------------------------------
process(p_in_user_clk, p_in_user_reset_n)
begin
if p_in_user_reset_n = '0' then
  for i in 0 to sr_cfg_flr_done'length - 1 loop
  sr_cfg_flr_done(i) <= (others => '0');
  end loop;

  for i in 0 to sr_cfg_vf_flr_done'length - 1 loop
  sr_cfg_vf_flr_done(i) <= (others => '0');
  end loop;

elsif rising_edge(p_in_user_clk) then
  sr_cfg_flr_done <= p_in_cfg_flr_in_process(1 downto 0) & sr_cfg_flr_done(0 to 0);
  sr_cfg_vf_flr_done <= p_in_cfg_vf_flr_in_process(5 downto 0) & sr_cfg_vf_flr_done(0 to 0);

end if;
end process;

--detect rising edge of p_in_cfg_flr_in_process
p_out_cfg_flr_done(0) <= not sr_cfg_flr_done(1)(0) and sr_cfg_flr_done(0)(0);
p_out_cfg_flr_done(1) <= not sr_cfg_flr_done(1)(1) and sr_cfg_flr_done(0)(1);
p_out_cfg_flr_done(p_out_cfg_flr_done'high downto 2) <= (others => '0');

--detect rising edge of p_in_cfg_vf_flr_in_process
p_out_cfg_vf_flr_done(0) <= not sr_cfg_vf_flr_done(1)(0) and sr_cfg_vf_flr_done(0)(0);
p_out_cfg_vf_flr_done(1) <= not sr_cfg_vf_flr_done(1)(1) and sr_cfg_vf_flr_done(0)(1);
p_out_cfg_vf_flr_done(2) <= not sr_cfg_vf_flr_done(1)(2) and sr_cfg_vf_flr_done(0)(2);
p_out_cfg_vf_flr_done(3) <= not sr_cfg_vf_flr_done(1)(3) and sr_cfg_vf_flr_done(0)(3);
p_out_cfg_vf_flr_done(4) <= not sr_cfg_vf_flr_done(1)(4) and sr_cfg_vf_flr_done(0)(4);
p_out_cfg_vf_flr_done(5) <= not sr_cfg_vf_flr_done(1)(5) and sr_cfg_vf_flr_done(0)(5);
p_out_cfg_vf_flr_done(p_out_cfg_vf_flr_done'high downto 6) <= (others => '0');


----------------------------------------
--
----------------------------------------
p_out_cfg_ds_port_number     <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_port_number'length));
p_out_cfg_ds_bus_number      <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_bus_number'length));
p_out_cfg_ds_device_number   <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_device_number'length));
p_out_cfg_ds_function_number <= std_logic_vector(TO_UNSIGNED(16#00#, p_out_cfg_ds_function_number'length));

p_out_cfg_dsn <= std_logic_vector(TO_UNSIGNED(16#123#, p_out_cfg_dsn'length));

p_out_cfg_err_cor_in   <= '0';
p_out_cfg_err_uncor_in <= '0';

-- Interrupt Interface Signals
p_out_cfg_interrupt_pending             <= (others => '0');
p_out_cfg_interrupt_msi_select          <= (others => '0');
p_out_cfg_interrupt_msi_pending_status  <= (others => '0');
p_out_cfg_interrupt_msi_attr            <= (others => '0');
p_out_cfg_interrupt_msi_tph_present     <= '0';
p_out_cfg_interrupt_msi_tph_type        <= (others => '0');
p_out_cfg_interrupt_msi_tph_st_tag      <= (others => '0');
p_out_cfg_interrupt_msi_function_number <= (others => '0');


-- RP only
p_out_cfg_hot_reset_out <= '0';



----------------------------------------
--
----------------------------------------
m_usr_app : pcie_usr_app
port map (
user_clk => p_in_user_clk,
reset_n  => p_in_user_reset_n,

--Read Port
rd_addr  => i_rd_addr ,--: in  std_logic_vector(10 downto 0);
rd_be    => i_rd_be   ,--: in  std_logic_vector(3 downto 0);
trn_sent => i_trn_sent,--: in  std_logic;
rd_data  => i_rd_data ,--: out std_logic_vector(31 downto 0);

--Write Port
wr_addr  => i_wr_addr, --: in  std_logic_vector(10 downto 0);
wr_be    => i_wr_be  , --: in  std_logic_vector(7 downto 0);
wr_data  => i_wr_data, --: in  std_logic_vector(63 downto 0);
wr_en    => i_wr_en  , --: in  std_logic;
wr_busy  => i_wr_busy, --: out std_logic;

--Payload info
payload_len => i_payload_len,--: in  std_logic;

--Trigger to TX and Interrupt Handler Block to generate
--Transactions and Interrupts
gen_transaction => i_gen_transaction,--: out std_logic;
gen_leg_intr    => i_gen_leg_intr   ,--: out std_logic;
gen_msi_intr    => i_gen_msi_intr   ,--: out std_logic;
gen_msix_intr   => i_gen_msix_intr   --: out std_logic
);



----------------------------------------
--
----------------------------------------
gen_cq_trdy : for i in 0 to p_out_m_axis_cq_tready'length - 1 generate begin
p_out_m_axis_cq_tready(i) <= i_m_axis_cq_tready;
end generate gen_cq_trdy;

gen_rc_trdy : for i in 0 to p_out_m_axis_rc_tready'length - 1 generate begin
p_out_m_axis_rc_tready(i) <= i_m_axis_rc_tready;
end generate gen_rc_trdy;

m_rx : pcie_rx
generic map(
--AXISTEN_IF_WIDTH               => G_AXISTEN_IF_WIDTH,
AXISTEN_IF_CQ_ALIGNMENT_MODE   => G_AXISTEN_IF_CQ_ALIGNMENT_MODE,
AXISTEN_IF_RC_ALIGNMENT_MODE   => G_AXISTEN_IF_RC_ALIGNMENT_MODE,
--AXISTEN_IF_RC_STRADDLE         : integer := 0;
AXISTEN_IF_ENABLE_RX_MSG_INTFC => G_AXISTEN_IF_ENABLE_RX_MSG_INTFC,
AXISTEN_IF_ENABLE_MSG_ROUTE    => G_AXISTEN_IF_ENABLE_MSG_ROUTE,

C_DATA_WIDTH => G_DATA_WIDTH   ,
STRB_WIDTH   => CI_STRB_WIDTH  ,
KEEP_WIDTH   => CI_KEEP_WIDTH  ,
PARITY_WIDTH => CI_PARITY_WIDTH
)
port map (
user_clk => p_in_user_clk,
reset_n  => p_in_user_reset_n,

-- Completer Request Interface
m_axis_cq_tdata       => p_in_m_axis_cq_tdata     ,
m_axis_cq_tlast       => p_in_m_axis_cq_tlast     ,
m_axis_cq_tvalid      => p_in_m_axis_cq_tvalid    ,
m_axis_cq_tuser       => p_in_m_axis_cq_tuser     ,
m_axis_cq_tkeep       => p_in_m_axis_cq_tkeep     ,
pcie_cq_np_req_count  => p_in_pcie_cq_np_req_count,
m_axis_cq_tready      => i_m_axis_cq_tready       ,
pcie_cq_np_req        => p_out_pcie_cq_np_req     ,

-- Requester Completion Interface
m_axis_rc_tdata       => p_in_m_axis_rc_tdata ,
m_axis_rc_tlast       => p_in_m_axis_rc_tlast ,
m_axis_rc_tvalid      => p_in_m_axis_rc_tvalid,
m_axis_rc_tkeep       => p_in_m_axis_rc_tkeep ,
m_axis_rc_tuser       => p_in_m_axis_rc_tuser ,
m_axis_rc_tready      => i_m_axis_rc_tready   ,

--RX Message Interface
cfg_msg_received      => p_in_cfg_msg_received     ,
cfg_msg_received_type => p_in_cfg_msg_received_type,
cfg_msg_data          => p_in_cfg_msg_received_data,

-- Memory Read data handshake with Completion
-- transmit unit. Transmit unit reponds to
-- req_compl assertion and responds with compl_done
-- assertion when a Completion w/ data is transmitted.
req_compl    => i_req_compl    ,--: out std_logic;
req_compl_wd => i_req_compl_wd ,--: out std_logic;
req_compl_ur => i_req_compl_ur ,--: out std_logic;
compl_done   => i_compl_done   ,--: in  std_logic;

req_tc       => i_req_tc  ,--: out std_logic_vector(2 downto 0) ;-- Memory Read TC
req_attr     => i_req_attr,--: out std_logic_vector(2 downto 0) ;-- Memory Read Attribute
req_len      => i_req_len ,--: out std_logic_vector(10 downto 0);-- Memory Read Length
req_rid      => i_req_rid ,--: out std_logic_vector(15 downto 0);-- Memory Read Requestor ID { 8'b0 (Bus no),
                                                                 --                            3'b0 (Dev no),
                                                                 --                            5'b0 (Func no)}
req_tag      => i_req_tag ,--: out std_logic_vector(7 downto 0) ;-- Memory Read Tag
req_be       => i_req_be  ,--: out std_logic_vector(7 downto 0) ;-- Memory Read Byte Enables
req_addr     => i_req_addr,--: out std_logic_vector(12 downto 0);-- Memory Read Address
req_at       => i_req_at  ,--: out std_logic_vector(1 downto 0) ;-- Address Translation

-- Outputs to the TX Block in case of an UR
-- Required to form the completions
req_des_qword0      => i_req_des_qword0     ,--: out std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
req_des_qword1      => i_req_des_qword1     ,--: out std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
req_des_tph_present => i_req_des_tph_present,--: out std_logic;                    -- TPH Present in the request
req_des_tph_type    => i_req_des_tph_type   ,--: out std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
req_des_tph_st_tag  => i_req_des_tph_st_tag ,--: out std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

--Output to Indicate that the Request was a Mem lock Read Req
req_mem_lock        => i_req_mem_lock,--: out std_logic;
req_mem             => i_req_mem     ,--: out std_logic;

--Memory interface used to save 2 DW data received
--on Memory Write 32 TLP. Data extracted from
--inbound TLP is presented to the Endpoint memory
--unit. Endpoint memory unit reacts to wr_en
--assertion and asserts wr_busy when it is
--processing written information.
wr_addr     => i_wr_addr    ,--: out std_logic_vector(10 downto 0);-- Memory Write Address
wr_be       => i_wr_be      ,--: out std_logic_vector(7 downto 0); -- Memory Write Byte Enable
wr_data     => i_wr_data    ,--: out std_logic_vector(63 downto 0);-- Memory Write Data
wr_en       => i_wr_en      ,--: out std_logic;                    -- Memory Write Enable
payload_len => i_payload_len,--: out std_logic;                    -- Transaction Payload Length
wr_busy     => i_wr_busy     --: in  std_logic                     -- Memory Write Busy
);



----------------------------------------
--
----------------------------------------
m_tx : pcie_tx
generic map (
--parameter [1:0] AXISTEN_IF_WIDTH = 00,
AXISTEN_IF_RQ_ALIGNMENT_MODE => G_AXISTEN_IF_RQ_ALIGNMENT_MODE,
AXISTEN_IF_CC_ALIGNMENT_MODE => G_AXISTEN_IF_CC_ALIGNMENT_MODE,
AXISTEN_IF_ENABLE_CLIENT_TAG => G_AXISTEN_IF_ENABLE_CLIENT_TAG,
AXISTEN_IF_RQ_PARITY_CHECK   => G_AXISTEN_IF_RQ_PARITY_CHECK  ,
AXISTEN_IF_CC_PARITY_CHECK   => G_AXISTEN_IF_CC_PARITY_CHECK  ,

C_DATA_WIDTH => G_DATA_WIDTH   ,
STRB_WIDTH   => CI_STRB_WIDTH  ,
KEEP_WIDTH   => CI_KEEP_WIDTH  ,
PARITY_WIDTH => CI_PARITY_WIDTH
)
port map(
user_clk => p_in_user_clk,
reset_n  => p_in_user_reset_n,

--AXI-S Completer Competion Interface
s_axis_cc_tdata  => p_out_s_axis_cc_tdata   ,
s_axis_cc_tkeep  => p_out_s_axis_cc_tkeep   ,
s_axis_cc_tlast  => p_out_s_axis_cc_tlast   ,
s_axis_cc_tvalid => p_out_s_axis_cc_tvalid  ,
s_axis_cc_tuser  => p_out_s_axis_cc_tuser   ,
s_axis_cc_tready => p_in_s_axis_cc_tready(0),

--AXI-S Requester Request Interface
s_axis_rq_tdata  => p_out_s_axis_rq_tdata   ,
s_axis_rq_tkeep  => p_out_s_axis_rq_tkeep   ,
s_axis_rq_tlast  => p_out_s_axis_rq_tlast   ,
s_axis_rq_tvalid => p_out_s_axis_rq_tvalid  ,
s_axis_rq_tuser  => p_out_s_axis_rq_tuser   ,
s_axis_rq_tready => p_in_s_axis_rq_tready(0),

--TX Message Interface
cfg_msg_transmit_done => p_in_cfg_msg_transmit_done ,
cfg_msg_transmit      => p_out_cfg_msg_transmit     ,
cfg_msg_transmit_type => p_out_cfg_msg_transmit_type,
cfg_msg_transmit_data => p_out_cfg_msg_transmit_data,

--Tag availability and Flow control Information
pcie_rq_tag          => p_in_pcie_rq_tag         ,
pcie_rq_tag_vld      => p_in_pcie_rq_tag_vld     ,
pcie_tfc_nph_av      => p_in_pcie_tfc_nph_av     ,
pcie_tfc_npd_av      => p_in_pcie_tfc_npd_av     ,
pcie_tfc_np_pl_empty => p_in_pcie_tfc_np_pl_empty,
pcie_rq_seq_num      => p_in_pcie_rq_seq_num     ,
pcie_rq_seq_num_vld  => p_in_pcie_rq_seq_num_vld ,

--Cfg Flow Control Information
cfg_fc_ph   => p_in_cfg_fc_ph  ,
cfg_fc_nph  => p_in_cfg_fc_nph ,
cfg_fc_cplh => p_in_cfg_fc_cplh,
cfg_fc_pd   => p_in_cfg_fc_pd  ,
cfg_fc_npd  => p_in_cfg_fc_npd ,
cfg_fc_cpld => p_in_cfg_fc_cpld,
cfg_fc_sel  => p_out_cfg_fc_sel,

--PIO RX Engine Interface
req_compl    => i_req_compl   ,--: in  std_logic;
req_compl_wd => i_req_compl_wd,--: in  std_logic;
req_compl_ur => i_req_compl_ur,--: in  std_logic;
payload_len  => i_payload_len ,--: in  std_logic;
compl_done   => i_compl_done  ,--: out std_logic;

req_tc   => i_req_tc  ,--: in  std_logic_vector(2 downto 0);
req_td   => '0',--i_req_td  ,--: in  std_logic;
req_ep   => '0',--i_req_ep  ,--: in  std_logic;
req_attr => i_req_attr(1 downto 0),--: in  std_logic_vector(1 downto 0);
req_len  => i_req_len ,--: in  std_logic_vector(10 downto 0);
req_rid  => i_req_rid ,--: in  std_logic_vector(15 downto 0);
req_tag  => i_req_tag ,--: in  std_logic_vector(7 downto 0);
req_be   => i_req_be  ,--: in  std_logic_vector(7 downto 0);
req_addr => i_req_addr,--: in  std_logic_vector(12 downto 0);
req_at   => i_req_at  ,--: in  std_logic_vector(1 downto 0);

completer_id => (others => '0'),--: in  std_logic_vector(15 downto 0);

--Inputs to the TX Block in case of an UR
--Required to form the completions
req_des_qword0      => i_req_des_qword0     ,-- : in  std_logic_vector(63 downto 0);
req_des_qword1      => i_req_des_qword1     ,-- : in  std_logic_vector(63 downto 0);
req_des_tph_present => i_req_des_tph_present,-- : in  std_logic;
req_des_tph_type    => i_req_des_tph_type   ,-- : in  std_logic_vector(1 downto 0);
req_des_tph_st_tag  => i_req_des_tph_st_tag ,-- : in  std_logic_vector(7 downto 0);

--Indicate that the Request was a Mem lock Read Req
req_mem_lock => i_req_mem_lock, --: in  std_logic;
req_mem      => i_req_mem     , --: in  std_logic;

--PIO Memory Access Control Interface
rd_addr         => i_rd_addr        ,--: out std_logic_vector(10 downto 0);
rd_be           => i_rd_be          ,--: out std_logic_vector(3 downto 0);
trn_sent        => i_trn_sent       ,--: out std_logic;
rd_data         => i_rd_data        ,--: in  std_logic_vector(31 downto 0);
gen_transaction => i_gen_transaction --: in  std_logic
);



----------------------------------------
--
----------------------------------------
m_irq : pcie_irq
port map(
user_clk => p_in_user_clk,
reset_n  => p_in_user_reset_n,

--Trigger to generate interrupts (to / from Mem access Block)
gen_leg_intr   => i_gen_leg_intr ,
gen_msi_intr   => i_gen_msi_intr ,
gen_msix_intr  => i_gen_msix_intr,
interrupt_done => i_interrupt_done, --: out std_logic; --Indicates whether interrupt is done or in process

--Legacy Interrupt Interface
cfg_interrupt_sent => p_in_cfg_interrupt_sent, --: in  std_logic; --Core asserts this signal when it sends out a Legacy interrupt
cfg_interrupt_int  => p_out_cfg_interrupt_int, --: out std_logic_vector(3 downto 0); --4 Bits for INTA, INTB, INTC, INTD (assert or deassert)

--MSI Interrupt Interface
cfg_interrupt_msi_enable => p_in_cfg_interrupt_msi_enable(0),
cfg_interrupt_msi_sent   => p_in_cfg_interrupt_msi_sent     ,
cfg_interrupt_msi_fail   => p_in_cfg_interrupt_msi_fail     ,
cfg_interrupt_msi_int    => p_out_cfg_interrupt_msi_int     ,

--MSI-X Interrupt Interface
cfg_interrupt_msix_enable  => p_in_cfg_interrupt_msix_enable  ,
cfg_interrupt_msix_sent    => p_in_cfg_interrupt_msix_sent    ,
cfg_interrupt_msix_fail    => p_in_cfg_interrupt_msix_fail    ,
cfg_interrupt_msix_int     => p_out_cfg_interrupt_msix_int    ,
cfg_interrupt_msix_address => p_out_cfg_interrupt_msix_address,
cfg_interrupt_msix_data    => p_out_cfg_interrupt_msix_data
);



----------------------------------------
--
----------------------------------------
i_rst_n <= p_in_user_lnk_up and p_in_user_reset_n;

i_req_completion <= i_req_compl or i_req_compl_wd or i_req_compl_ur;
i_completion_done <= i_compl_done or i_interrupt_done;

m_pio_to_ctrl : pio_to_ctrl
port map(
clk        => p_in_user_clk,
rst_n     => i_rst_n,

req_compl  => i_req_completion,
compl_done => i_completion_done,

cfg_power_state_change_interrupt => p_in_cfg_power_state_change_interrupt,
cfg_power_state_change_ack       => p_out_cfg_power_state_change_ack
);


--#############################################
--DBG
--#############################################
p_out_hclk <= '0';
p_out_gctrl <= (others => '0');

--CTRL user devices
p_out_dev_ctrl <= (others => '0');
p_out_dev_din <= (others => '0');
p_out_dev_wr <= '0';
p_out_dev_rd <= '0';

p_out_dev_opt <= (others => '0');

--DBG
p_out_tst <= (others => '0');




------------------------------------
-- EP Only
------------------------------------
-- Interrupt Interface Signals
p_out_cfg_interrupt_int                 <= (others => '0');--: out  std_logic_vector(3 downto 0) ;
p_out_cfg_interrupt_msi_int             <= (others => '0');--: out  std_logic_vector(31 downto 0);


end architecture struct;


