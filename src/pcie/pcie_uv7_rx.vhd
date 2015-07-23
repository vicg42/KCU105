-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 08.07.2015 13:35:52
-- Module Name : pcie_rx.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_rx is
generic (
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_RC_STRADDLE         : integer := 0;
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1');

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; -- TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   -- TPARITY width
);
port(
-- Completer Request Interface
p_in_m_axis_cq_tdata      : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tlast      : in  std_logic;
p_in_m_axis_cq_tvalid     : in  std_logic;
p_in_m_axis_cq_tuser      : in  std_logic_vector(84 downto 0);
p_in_m_axis_cq_tkeep      : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_pcie_cq_np_req_count : in  std_logic_vector(5 downto 0);
p_out_m_axis_cq_tready    : out std_logic;
p_out_pcie_cq_np_req      : out std_logic;

-- Requester Completion Interface
p_in_m_axis_rc_tdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tlast    : in  std_logic;
p_in_m_axis_rc_tvalid   : in  std_logic;
p_in_m_axis_rc_tkeep    : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser    : in  std_logic_vector(74 downto 0);
p_out_m_axis_rc_tready  : out std_logic;

--RX Message Interface
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

--Completion
p_out_req_compl    : out std_logic;
p_out_req_compl_ur : out std_logic;--Unsupported Request
p_in_compl_done    : in  std_logic;

p_out_req_prm      : out TPCIE_reqprm;

--usr app
p_out_ureg_di  : out std_logic_vector(31 downto 0);
p_out_ureg_wrbe: out std_logic_vector(3 downto 0);
p_out_ureg_wr  : out std_logic;
p_out_ureg_rd  : out std_logic;

--DBG
p_out_tst : out std_logic_vector(31 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_rx;

architecture behavioral of pcie_rx is

component pcie_rx_cq is
generic (
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
G_AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := (others => '1');

G_DATA_WIDTH : integer := 64;
G_KEEP_WIDTH : integer := 64 / 32
);
port(
-- Completer Request Interface
p_in_m_axis_cq_tdata      : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tlast      : in  std_logic;
p_in_m_axis_cq_tvalid     : in  std_logic;
p_in_m_axis_cq_tuser      : in  std_logic_vector(84 downto 0);
p_in_m_axis_cq_tkeep      : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_m_axis_cq_tready    : out std_logic;

p_in_pcie_cq_np_req_count : in  std_logic_vector(5 downto 0);
p_out_pcie_cq_np_req      : out std_logic;

--RX Message Interface
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

--Completion
p_out_req_compl    : out std_logic;
p_out_req_compl_ur : out std_logic;--Unsupported Request
p_in_compl_done    : in  std_logic;

p_out_req_prm      : out TPCIE_reqprm;

--usr app
p_out_ureg_di  : out std_logic_vector(31 downto 0);
p_out_ureg_wrbe: out std_logic_vector(3 downto 0);
p_out_ureg_wr  : out std_logic;
p_out_ureg_rd  : out std_logic;

--DBG
p_out_tst : out std_logic_vector(31 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end component pcie_rx_cq;



begin --architecture behavioral of pcie_rx


m_rx_cq : pcie_rx_cq
generic map(
G_AXISTEN_IF_CQ_ALIGNMENT_MODE   => G_AXISTEN_IF_CQ_ALIGNMENT_MODE  ,
G_AXISTEN_IF_ENABLE_RX_MSG_INTFC => G_AXISTEN_IF_ENABLE_RX_MSG_INTFC,
G_AXISTEN_IF_ENABLE_MSG_ROUTE    => G_AXISTEN_IF_ENABLE_MSG_ROUTE   ,

G_DATA_WIDTH   => G_DATA_WIDTH,
G_KEEP_WIDTH   => G_KEEP_WIDTH
)
port map(
--Completer Request Interface
p_in_m_axis_cq_tdata   => p_in_m_axis_cq_tdata  ,
p_in_m_axis_cq_tlast   => p_in_m_axis_cq_tlast  ,
p_in_m_axis_cq_tvalid  => p_in_m_axis_cq_tvalid ,
p_in_m_axis_cq_tuser   => p_in_m_axis_cq_tuser  ,
p_in_m_axis_cq_tkeep   => p_in_m_axis_cq_tkeep  ,
p_out_m_axis_cq_tready => p_out_m_axis_cq_tready,

p_in_pcie_cq_np_req_count => p_in_pcie_cq_np_req_count,
p_out_pcie_cq_np_req      => p_out_pcie_cq_np_req     ,

--RX Message Interface
p_in_cfg_msg_received      => p_in_cfg_msg_received     ,
p_in_cfg_msg_received_type => p_in_cfg_msg_received_type,
p_in_cfg_msg_data          => p_in_cfg_msg_data         ,

--Completion
p_out_req_compl    => p_out_req_compl   ,
p_out_req_compl_ur => p_out_req_compl_ur,
p_in_compl_done    => p_in_compl_done   ,

p_out_req_prm      => p_out_req_prm,

--usr app
p_out_ureg_di   => p_out_ureg_di  ,
p_out_ureg_wrbe => p_out_ureg_wrbe,
p_out_ureg_wr   => p_out_ureg_wr  ,
p_out_ureg_rd   => p_out_ureg_rd  ,

--DBG
p_out_tst => p_out_tst,

--system
p_in_clk   => p_in_clk,
p_in_rst_n => p_in_rst_n
);


p_out_m_axis_rc_tready <= '0';

end architecture behavioral;

