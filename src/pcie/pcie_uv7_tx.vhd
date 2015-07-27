-------------------------------------------------------------------------
--Engineer    : Golovachenko Victor
--
--Create Date : 08.07.2015 13:35:52
--Module Name : pcie_tx.vhd
--
--Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;

entity pcie_tx is
generic (
G_AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_CC_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK   : integer := 0;

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; --TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   --TPARITY width
);
port(
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tlast  : out std_logic;
p_out_s_axis_cc_tvalid : out std_logic;
p_out_s_axis_cc_tuser  : out std_logic_vector(32 downto 0);
p_in_s_axis_cc_tready  : in  std_logic;

--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_rq_tlast  : out std_logic;
p_out_s_axis_rq_tvalid : out std_logic;
p_out_s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
p_in_s_axis_rq_tready  : in  std_logic;

--TX Message Interface
p_in_cfg_msg_transmit_done  : in  std_logic;
p_out_cfg_msg_transmit      : out std_logic;
p_out_cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

--Cfg Flow Control Information
p_in_cfg_fc_ph   : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_nph  : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_cplh : in  std_logic_vector(7 downto 0);
p_in_cfg_fc_pd   : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_npd  : in  std_logic_vector(11 downto 0);
p_in_cfg_fc_cpld : in  std_logic_vector(11 downto 0);
p_out_cfg_fc_sel : out std_logic_vector(2 downto 0);

--Completion
p_in_req_compl    : in  std_logic;
p_in_req_compl_ur : in  std_logic;
p_out_compl_done  : out std_logic;

p_in_req_prm      : in TPCIE_reqprm;

p_in_pcie_prm    : in  TPCIE_cfgprm;

p_in_completer_id : in  std_logic_vector(15 downto 0);

--usr app
p_in_ureg_do      : in  std_logic_vector(31 downto 0);

p_in_urxbuf_empty : in  std_logic;
p_in_urxbuf_do    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_urxbuf_rd   : out std_logic;
p_out_urxbuf_last : out std_logic;

--DMA
p_in_dma_init      : in  std_logic;
p_in_dma_prm       : in  TPCIE_dmaprm;
p_in_dma_mwr_en    : in  std_logic;
p_out_dma_mwr_done : out std_logic;
p_in_dma_mrd_en    : in  std_logic;

--DBG
p_out_tst : out std_logic_vector(279 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end entity pcie_tx;

architecture behavioral of pcie_tx is


component pcie_tx_cc is
generic (
G_AXISTEN_IF_CC_ALIGNMENT_MODE : string := "FALSE";
--G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_CC_PARITY_CHECK   : integer := 0;

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; --TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   --TPARITY width
);
port(
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_cc_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_cc_tlast  : out std_logic;
p_out_s_axis_cc_tvalid : out std_logic;
p_out_s_axis_cc_tuser  : out std_logic_vector(32 downto 0);
p_in_s_axis_cc_tready  : in  std_logic;

--TX Message Interface
p_in_cfg_msg_transmit_done  : in  std_logic;
p_out_cfg_msg_transmit      : out std_logic;
p_out_cfg_msg_transmit_type : out std_logic_vector(2 downto 0);
p_out_cfg_msg_transmit_data : out std_logic_vector(31 downto 0);

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

--Completion
p_in_req_compl    : in  std_logic;
p_in_req_compl_ur : in  std_logic;
p_out_compl_done  : out std_logic;

p_in_req_prm      : in TPCIE_reqprm;

p_in_completer_id : in  std_logic_vector(15 downto 0);

--usr app
p_in_ureg_do   : in  std_logic_vector(31 downto 0);

--DBG
p_out_tst : out std_logic_vector(279 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end component pcie_tx_cc;


component pcie_tx_rq is
generic (
G_AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
G_AXISTEN_IF_ENABLE_CLIENT_TAG : integer := 0;
G_AXISTEN_IF_RQ_PARITY_CHECK   : integer := 0;

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; --TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   --TPARITY width
);
port(
--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_s_axis_rq_tkeep  : out std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_out_s_axis_rq_tlast  : out std_logic;
p_out_s_axis_rq_tvalid : out std_logic;
p_out_s_axis_rq_tuser  : out std_logic_vector(59 downto 0);
p_in_s_axis_rq_tready  : in  std_logic;

--Tag availability and Flow control Information
p_in_pcie_rq_tag          : in  std_logic_vector(5 downto 0);
p_in_pcie_rq_tag_vld      : in  std_logic;
p_in_pcie_tfc_nph_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_npd_av      : in  std_logic_vector(1 downto 0);
p_in_pcie_tfc_np_pl_empty : in  std_logic;
p_in_pcie_rq_seq_num      : in  std_logic_vector(3 downto 0);
p_in_pcie_rq_seq_num_vld  : in  std_logic;

p_in_completer_id : in  std_logic_vector(15 downto 0);

p_in_pcie_prm    : in  TPCIE_cfgprm;

--usr app
p_in_urxbuf_empty : in  std_logic;
p_in_urxbuf_do    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_out_urxbuf_rd   : out std_logic;
p_out_urxbuf_last : out std_logic;

--DMA
p_in_dma_init      : in  std_logic;
p_in_dma_prm       : in  TPCIE_dmaprm;
p_in_dma_mwr_en    : in  std_logic;
p_out_dma_mwr_done : out std_logic;
p_in_dma_mrd_en    : in  std_logic;

--DBG
p_out_tst : out std_logic_vector(279 downto 0);

--system
p_in_clk   : in  std_logic;
p_in_rst_n : in  std_logic
);
end component pcie_tx_rq;


begin --architecture behavioral of pcie_tx


m_tx_cc : pcie_tx_cc
generic map(
G_AXISTEN_IF_CC_ALIGNMENT_MODE => G_AXISTEN_IF_CC_ALIGNMENT_MODE,
--G_AXISTEN_IF_ENABLE_CLIENT_TAG => G_AXISTEN_IF_ENABLE_CLIENT_TAG,
G_AXISTEN_IF_CC_PARITY_CHECK   => G_AXISTEN_IF_CC_PARITY_CHECK  ,

G_DATA_WIDTH   => G_DATA_WIDTH  ,
G_STRB_WIDTH   => G_STRB_WIDTH  ,
G_KEEP_WIDTH   => G_KEEP_WIDTH  ,
G_PARITY_WIDTH => G_PARITY_WIDTH
)
port map(
--AXI-S Completer Competion Interface
p_out_s_axis_cc_tdata  => p_out_s_axis_cc_tdata ,
p_out_s_axis_cc_tkeep  => p_out_s_axis_cc_tkeep ,
p_out_s_axis_cc_tlast  => p_out_s_axis_cc_tlast ,
p_out_s_axis_cc_tvalid => p_out_s_axis_cc_tvalid,
p_out_s_axis_cc_tuser  => p_out_s_axis_cc_tuser ,
p_in_s_axis_cc_tready  => p_in_s_axis_cc_tready ,

--TX Message Interface
p_in_cfg_msg_transmit_done  => p_in_cfg_msg_transmit_done ,
p_out_cfg_msg_transmit      => p_out_cfg_msg_transmit     ,
p_out_cfg_msg_transmit_type => p_out_cfg_msg_transmit_type,
p_out_cfg_msg_transmit_data => p_out_cfg_msg_transmit_data,

--Tag availability and Flow control Information
p_in_pcie_rq_tag          => p_in_pcie_rq_tag         ,
p_in_pcie_rq_tag_vld      => p_in_pcie_rq_tag_vld     ,
p_in_pcie_tfc_nph_av      => p_in_pcie_tfc_nph_av     ,
p_in_pcie_tfc_npd_av      => p_in_pcie_tfc_npd_av     ,
p_in_pcie_tfc_np_pl_empty => p_in_pcie_tfc_np_pl_empty,
p_in_pcie_rq_seq_num      => p_in_pcie_rq_seq_num     ,
p_in_pcie_rq_seq_num_vld  => p_in_pcie_rq_seq_num_vld ,

--Completion
p_in_req_compl    => p_in_req_compl   ,
p_in_req_compl_ur => p_in_req_compl_ur,
p_out_compl_done  => p_out_compl_done ,

p_in_req_prm      => p_in_req_prm,

p_in_completer_id => p_in_completer_id,

--usr app
p_in_ureg_do => p_in_ureg_do,

--DBG
p_out_tst => p_out_tst,

--system
p_in_clk   => p_in_clk,
p_in_rst_n => p_in_rst_n
);



m_tx_rq : pcie_tx_rq
generic map(
G_AXISTEN_IF_RQ_ALIGNMENT_MODE => G_AXISTEN_IF_RQ_ALIGNMENT_MODE,
G_AXISTEN_IF_ENABLE_CLIENT_TAG => G_AXISTEN_IF_ENABLE_CLIENT_TAG,
G_AXISTEN_IF_RQ_PARITY_CHECK   => G_AXISTEN_IF_RQ_PARITY_CHECK  ,

G_DATA_WIDTH   => G_DATA_WIDTH  ,
G_STRB_WIDTH   => G_STRB_WIDTH  ,
G_KEEP_WIDTH   => G_KEEP_WIDTH  ,
G_PARITY_WIDTH => G_PARITY_WIDTH
)
port map(
--AXI-S Requester Request Interface
p_out_s_axis_rq_tdata  => p_out_s_axis_rq_tdata ,
p_out_s_axis_rq_tkeep  => p_out_s_axis_rq_tkeep ,
p_out_s_axis_rq_tlast  => p_out_s_axis_rq_tlast ,
p_out_s_axis_rq_tvalid => p_out_s_axis_rq_tvalid,
p_out_s_axis_rq_tuser  => p_out_s_axis_rq_tuser ,
p_in_s_axis_rq_tready  => p_in_s_axis_rq_tready ,

--Tag availability and Flow control Information
p_in_pcie_rq_tag          => p_in_pcie_rq_tag         ,
p_in_pcie_rq_tag_vld      => p_in_pcie_rq_tag_vld     ,
p_in_pcie_tfc_nph_av      => p_in_pcie_tfc_nph_av     ,
p_in_pcie_tfc_npd_av      => p_in_pcie_tfc_npd_av     ,
p_in_pcie_tfc_np_pl_empty => p_in_pcie_tfc_np_pl_empty,
p_in_pcie_rq_seq_num      => p_in_pcie_rq_seq_num     ,
p_in_pcie_rq_seq_num_vld  => p_in_pcie_rq_seq_num_vld ,

p_in_completer_id => p_in_completer_id,

p_in_pcie_prm    => p_in_pcie_prm,

--usr app
p_in_urxbuf_empty => p_in_urxbuf_empty,
p_in_urxbuf_do    => p_in_urxbuf_do   ,
p_out_urxbuf_rd   => p_out_urxbuf_rd  ,
p_out_urxbuf_last => p_out_urxbuf_last,

--DMA
p_in_dma_init      => p_in_dma_init     ,
p_in_dma_prm       => p_in_dma_prm      ,
p_in_dma_mwr_en    => p_in_dma_mwr_en   ,
p_out_dma_mwr_done => p_out_dma_mwr_done,
p_in_dma_mrd_en    => p_in_dma_mrd_en   ,

--DBG
p_out_tst => open,

--system
p_in_clk   => p_in_clk,
p_in_rst_n => p_in_rst_n
);


p_out_cfg_fc_sel <= (others => '0');

end architecture behavioral;


