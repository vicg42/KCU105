-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 29.03.2012 13:12:29
-- Module Name : mem_ctrl_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_cfg.all;
use work.mem_wr_pkg.all;
use work.mem_glob_pkg.all;

package mem_ctrl_pkg is

constant C_AXIS_IDWIDTH    : integer := 4;
constant C_AXIM_IDWIDTH    : integer := 8;

constant C_AXI_AWIDTH      : integer := 31;
constant C_AXIM_DWIDTH     : integer := C_PCFG_PCIE_DWIDTH;

type TAXIS_DWIDTH is array (0 to C_MEMCH_COUNT_MAX - 1) of integer;
------------------------------------------------------------------------------------------------------------
--                              slave num   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10| 11| 12| 13| 14| 15|
------------------------------------------------------------------------------------------------------------
constant C_AXIS_DWIDTH     : TAXIS_DWIDTH := (
C_PCFG_PCIE_DWIDTH,--CH video read
C_PCFG_FG_BUFI_DWIDTH, --CH video write
C_PCFG_PCIE_DWIDTH,
C_PCFG_PCIE_DWIDTH,
C_PCFG_PCIE_DWIDTH,
C_PCFG_PCIE_DWIDTH,
C_PCFG_PCIE_DWIDTH,
C_PCFG_PCIE_DWIDTH);

constant C_MEM_ARB_CH_COUNT  : integer := C_PCFG_MEMARB_CH_COUNT;

constant CI_CK_WIDTH      : integer := 1 ;-- # of CK/CK# outputs to memory.
constant CI_CKE_WIDTH     : integer := 1 ;-- # of CKE outputs to memory.
constant CI_CS_WIDTH      : integer := 1 ;-- # of unique CS outputs to memory.
constant CI_DM_WIDTH      : integer := 8 ;-- # of Data Mask bits.
constant CI_DQ_WIDTH      : integer := 64;-- # of Data (DQ) bits.
constant CI_DQS_WIDTH     : integer := 8 ;-- # of DQS/DQS# bits.
constant CI_ODT_WIDTH     : integer := 1 ;

--Memory interface types
type TMEMCTRL_pinout is record
act_n   : std_logic;
addr    : std_logic_vector(16 downto 0);
ba      : std_logic_vector(1  downto 0);
bg      : std_logic_vector(0 to 0);
cke     : std_logic_vector(CI_CKE_WIDTH - 1 to 0);
odt     : std_logic_vector(CI_ODT_WIDTH - 1 to 0);
cs_n    : std_logic_vector(CI_CS_WIDTH - 1 to 0);
ck_t    : std_logic_vector(CI_CK_WIDTH - 1 to 0);
ck_c    : std_logic_vector(CI_CK_WIDTH - 1 to 0);
reset_n : std_logic;
end record;

type TMEMCTRL_pininout is record
dm_dbi_n : std_logic_vector(CI_DM_WIDTH - 1  downto 0);
dq       : std_logic_vector(CI_DQ_WIDTH - 1 downto 0);
dqs_c    : std_logic_vector(CI_DQS_WIDTH - 1 downto 0);
dqs_t    : std_logic_vector(CI_DQS_WIDTH - 1  downto 0);
end record;

type TMEMCTRL_status is record
rdy   : std_logic;
end record;

type TMEMCTRL_pinin is record
clk_p : std_logic;
clk_n : std_logic;
--rst   : std_logic;
end record;

type TMEMCTRL_sysout is record
clk   : std_logic;
end record;

-- Types for memory interface
Type TMemINCh is array (0 to C_MEM_ARB_CH_COUNT - 1) of TMemIN;
Type TMemOUTCh is array (0 to C_MEM_ARB_CH_COUNT - 1) of TMemOUT;

Type TMemINChVD is array (0 to C_PCFG_FG_VCH_COUNT - 1) of TMemIN;
Type TMemOUTChVD is array (0 to C_PCFG_FG_VCH_COUNT - 1) of TMemOUT;

component mem_ctrl
generic(
G_SIM : string:="OFF"
);
port(
------------------------------------
--USER Port
------------------------------------
p_in_mem       : in    TMemIN;
p_out_mem      : out   TMemOUT;

p_out_status   : out   TMEMCTRL_status;

------------------------------------
--Memory physical interface
------------------------------------
p_out_phymem   : out   TMEMCTRL_pinout;
p_inout_phymem : inout TMEMCTRL_pininout;

------------------------------------
--System
------------------------------------
p_out_sys      : out   TMEMCTRL_sysout;
p_in_sys       : in    TMEMCTRL_pinin;
p_in_rst       : in    std_logic
);
end component mem_ctrl;

component mem_arb
generic(
G_CH_COUNT   : integer := 4;
G_MEM_AWIDTH : integer := 32;
G_MEM_DWIDTH : integer := 32
);
port(
-------------------------------
--USR Port
-------------------------------
p_in_memch  : in   TMemINCh;
p_out_memch : out  TMemOUTCh;

-------------------------------
--MEM_CTRL Port
-------------------------------
p_out_mem   : out   TMemIN;
p_in_mem    : in    TMemOUT;

-------------------------------
--DBG
-------------------------------
p_in_tst    : in    std_logic_vector(31 downto 0);
p_out_tst   : out   std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_clk    : in    std_logic;
p_in_rst    : in    std_logic
);
end component mem_arb;

component mem_ctrl_core_axi
--generic(
--c_s_axi_id_width   : integer := 8;
--c_s_axi_addr_width : integer := 32;
--c_s_axi_data_width : integer := 32
--);
port(
-- axi slave interface:
-- write address ports
c0_ddr4_s_axi_awid    : in std_logic_vector(C_AXIM_IDWIDTH - 1 downto 0);
c0_ddr4_s_axi_awaddr  : in std_logic_vector(C_AXI_AWIDTH - 1 downto 0);
c0_ddr4_s_axi_awlen   : in std_logic_vector(7 downto 0);
c0_ddr4_s_axi_awsize  : in std_logic_vector(2 downto 0);
c0_ddr4_s_axi_awburst : in std_logic_vector(1 downto 0);
c0_ddr4_s_axi_awlock  : in std_logic_vector(0 to 0);
c0_ddr4_s_axi_awcache : in std_logic_vector(3 downto 0);
c0_ddr4_s_axi_awprot  : in std_logic_vector(2 downto 0);
c0_ddr4_s_axi_awqos   : in std_logic_vector(3 downto 0);
c0_ddr4_s_axi_awvalid : in std_logic;
c0_ddr4_s_axi_awready : out std_logic;
-- write data ports
c0_ddr4_s_axi_wdata   : in std_logic_vector(C_AXIM_DWIDTH - 1 downto 0);
c0_ddr4_s_axi_wstrb   : in std_logic_vector(C_AXIM_DWIDTH/8 - 1 downto 0);
c0_ddr4_s_axi_wlast   : in std_logic;
c0_ddr4_s_axi_wvalid  : in std_logic;
c0_ddr4_s_axi_wready  : out std_logic;
-- write response ports
c0_ddr4_s_axi_bid     : out std_logic_vector(C_AXIM_IDWIDTH - 1 downto 0);
c0_ddr4_s_axi_bresp   : out std_logic_vector(1 downto 0);
c0_ddr4_s_axi_bvalid  : out std_logic;
c0_ddr4_s_axi_bready  : in std_logic;
-- read address ports
c0_ddr4_s_axi_arid    : in std_logic_vector(C_AXIM_IDWIDTH - 1 downto 0);
c0_ddr4_s_axi_araddr  : in std_logic_vector(C_AXI_AWIDTH - 1 downto 0);
c0_ddr4_s_axi_arlen   : in std_logic_vector(7 downto 0);
c0_ddr4_s_axi_arsize  : in std_logic_vector(2 downto 0);
c0_ddr4_s_axi_arburst : in std_logic_vector(1 downto 0);
c0_ddr4_s_axi_arlock  : in std_logic_vector(0 to 0);
c0_ddr4_s_axi_arcache : in std_logic_vector(3 downto 0);
c0_ddr4_s_axi_arprot  : in std_logic_vector(2 downto 0);
c0_ddr4_s_axi_arqos   : in std_logic_vector(3 downto 0);
c0_ddr4_s_axi_arvalid : in std_logic;
c0_ddr4_s_axi_arready : out std_logic;
-- read data ports
c0_ddr4_s_axi_rid     : out std_logic_vector(C_AXIM_IDWIDTH - 1 downto 0);
c0_ddr4_s_axi_rdata   : out std_logic_vector(C_AXIM_DWIDTH - 1 downto 0);
c0_ddr4_s_axi_rresp   : out std_logic_vector(1 downto 0);
c0_ddr4_s_axi_rlast   : out std_logic;
c0_ddr4_s_axi_rvalid  : out std_logic;
c0_ddr4_s_axi_rready  : in std_logic;

-- ddr4 physical interface
c0_ddr4_act_n    : out std_logic;
c0_ddr4_adr      : out std_logic_vector(16 downto 0);
c0_ddr4_ba       : out std_logic_vector(1 downto 0);
c0_ddr4_bg       : out std_logic_vector(0 to 0);
c0_ddr4_cke      : out std_logic_vector(0 to 0);
c0_ddr4_odt      : out std_logic_vector(0 to 0);
c0_ddr4_cs_n     : out std_logic_vector(0 to 0);
c0_ddr4_ck_t     : out std_logic_vector(0 to 0);
c0_ddr4_ck_c     : out std_logic_vector(0 to 0);
c0_ddr4_reset_n  : out std_logic;
c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);

--status
c0_init_calib_complete : out std_logic;


c0_ddr4_aresetn         : in std_logic;
c0_ddr4_ui_clk_sync_rst : out std_logic;
c0_ddr4_ui_clk          : out std_logic;
--addn_ui_clkout1         : out std_logic;
--addn_ui_clkout2         : out std_logic;
dbg_clk                 : out std_logic;
dbg_bus                 : out std_logic_vector(511 downto 0);

--system
c0_sys_clk_p : in std_logic;
c0_sys_clk_n : in std_logic;
sys_rst      : in std_logic
);
end component mem_ctrl_core_axi;


COMPONENT mem_achcount1
  PORT (
    INTERCONNECT_ACLK : IN STD_LOGIC;
    INTERCONNECT_ARESETN : IN STD_LOGIC;

    S00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S00_AXI_ACLK : IN STD_LOGIC;
    S00_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_AWLOCK : IN STD_LOGIC;
    S00_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWVALID : IN STD_LOGIC;
    S00_AXI_AWREADY : OUT STD_LOGIC;
    S00_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0)/8 - 1 DOWNTO 0);
    S00_AXI_WLAST : IN STD_LOGIC;
    S00_AXI_WVALID : IN STD_LOGIC;
    S00_AXI_WREADY : OUT STD_LOGIC;
    S00_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_BVALID : OUT STD_LOGIC;
    S00_AXI_BREADY : IN STD_LOGIC;
    S00_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_ARLOCK : IN STD_LOGIC;
    S00_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARVALID : IN STD_LOGIC;
    S00_AXI_ARREADY : OUT STD_LOGIC;
    S00_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_RLAST : OUT STD_LOGIC;
    S00_AXI_RVALID : OUT STD_LOGIC;
    S00_AXI_RREADY : IN STD_LOGIC;

    M00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    M00_AXI_ACLK : IN STD_LOGIC;
    M00_AXI_AWID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_AWADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_AWLOCK : OUT STD_LOGIC;
    M00_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWVALID : OUT STD_LOGIC;
    M00_AXI_AWREADY : IN STD_LOGIC;
    M00_AXI_WDATA : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_WSTRB : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH/8 - 1 DOWNTO 0);
    M00_AXI_WLAST : OUT STD_LOGIC;
    M00_AXI_WVALID : OUT STD_LOGIC;
    M00_AXI_WREADY : IN STD_LOGIC;
    M00_AXI_BID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_BVALID : IN STD_LOGIC;
    M00_AXI_BREADY : OUT STD_LOGIC;
    M00_AXI_ARID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_ARADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_ARLOCK : OUT STD_LOGIC;
    M00_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARVALID : OUT STD_LOGIC;
    M00_AXI_ARREADY : IN STD_LOGIC;
    M00_AXI_RID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_RDATA : IN STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_RLAST : IN STD_LOGIC;
    M00_AXI_RVALID : IN STD_LOGIC;
    M00_AXI_RREADY : OUT STD_LOGIC
  );
END COMPONENT mem_achcount1;


COMPONENT mem_achcount2
  PORT (
    INTERCONNECT_ACLK : IN STD_LOGIC;
    INTERCONNECT_ARESETN : IN STD_LOGIC;

    S00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S00_AXI_ACLK : IN STD_LOGIC;
    S00_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_AWLOCK : IN STD_LOGIC;
    S00_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWVALID : IN STD_LOGIC;
    S00_AXI_AWREADY : OUT STD_LOGIC;
    S00_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0)/8 - 1 DOWNTO 0);
    S00_AXI_WLAST : IN STD_LOGIC;
    S00_AXI_WVALID : IN STD_LOGIC;
    S00_AXI_WREADY : OUT STD_LOGIC;
    S00_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_BVALID : OUT STD_LOGIC;
    S00_AXI_BREADY : IN STD_LOGIC;
    S00_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_ARLOCK : IN STD_LOGIC;
    S00_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARVALID : IN STD_LOGIC;
    S00_AXI_ARREADY : OUT STD_LOGIC;
    S00_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_RLAST : OUT STD_LOGIC;
    S00_AXI_RVALID : OUT STD_LOGIC;
    S00_AXI_RREADY : IN STD_LOGIC;

    S01_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S01_AXI_ACLK : IN STD_LOGIC;
    S01_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S01_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S01_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_AWLOCK : IN STD_LOGIC;
    S01_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_AWVALID : IN STD_LOGIC;
    S01_AXI_AWREADY : OUT STD_LOGIC;
    S01_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1) - 1 DOWNTO 0);
    S01_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1)/8 - 1 DOWNTO 0);
    S01_AXI_WLAST : IN STD_LOGIC;
    S01_AXI_WVALID : IN STD_LOGIC;
    S01_AXI_WREADY : OUT STD_LOGIC;
    S01_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_BVALID : OUT STD_LOGIC;
    S01_AXI_BREADY : IN STD_LOGIC;
    S01_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S01_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S01_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_ARLOCK : IN STD_LOGIC;
    S01_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_ARVALID : IN STD_LOGIC;
    S01_AXI_ARREADY : OUT STD_LOGIC;
    S01_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1) - 1 DOWNTO 0);
    S01_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_RLAST : OUT STD_LOGIC;
    S01_AXI_RVALID : OUT STD_LOGIC;
    S01_AXI_RREADY : IN STD_LOGIC;

    M00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    M00_AXI_ACLK : IN STD_LOGIC;
    M00_AXI_AWID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_AWADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_AWLOCK : OUT STD_LOGIC;
    M00_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWVALID : OUT STD_LOGIC;
    M00_AXI_AWREADY : IN STD_LOGIC;
    M00_AXI_WDATA : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_WSTRB : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH/8 - 1 DOWNTO 0);
    M00_AXI_WLAST : OUT STD_LOGIC;
    M00_AXI_WVALID : OUT STD_LOGIC;
    M00_AXI_WREADY : IN STD_LOGIC;
    M00_AXI_BID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_BVALID : IN STD_LOGIC;
    M00_AXI_BREADY : OUT STD_LOGIC;
    M00_AXI_ARID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_ARADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_ARLOCK : OUT STD_LOGIC;
    M00_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARVALID : OUT STD_LOGIC;
    M00_AXI_ARREADY : IN STD_LOGIC;
    M00_AXI_RID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_RDATA : IN STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_RLAST : IN STD_LOGIC;
    M00_AXI_RVALID : IN STD_LOGIC;
    M00_AXI_RREADY : OUT STD_LOGIC
  );
END COMPONENT mem_achcount2;

COMPONENT mem_achcount3
  PORT (
    INTERCONNECT_ACLK : IN STD_LOGIC;
    INTERCONNECT_ARESETN : IN STD_LOGIC;

    S00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S00_AXI_ACLK : IN STD_LOGIC;
    S00_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_AWLOCK : IN STD_LOGIC;
    S00_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_AWVALID : IN STD_LOGIC;
    S00_AXI_AWREADY : OUT STD_LOGIC;
    S00_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0)/8 - 1 DOWNTO 0);
    S00_AXI_WLAST : IN STD_LOGIC;
    S00_AXI_WVALID : IN STD_LOGIC;
    S00_AXI_WREADY : OUT STD_LOGIC;
    S00_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_BVALID : OUT STD_LOGIC;
    S00_AXI_BREADY : IN STD_LOGIC;
    S00_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S00_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_ARLOCK : IN STD_LOGIC;
    S00_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S00_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_AXI_ARVALID : IN STD_LOGIC;
    S00_AXI_ARREADY : OUT STD_LOGIC;
    S00_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S00_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(0) - 1 DOWNTO 0);
    S00_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S00_AXI_RLAST : OUT STD_LOGIC;
    S00_AXI_RVALID : OUT STD_LOGIC;
    S00_AXI_RREADY : IN STD_LOGIC;

    S01_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S01_AXI_ACLK : IN STD_LOGIC;
    S01_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S01_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S01_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_AWLOCK : IN STD_LOGIC;
    S01_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_AWVALID : IN STD_LOGIC;
    S01_AXI_AWREADY : OUT STD_LOGIC;
    S01_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1) - 1 DOWNTO 0);
    S01_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1)/8 - 1 DOWNTO 0);
    S01_AXI_WLAST : IN STD_LOGIC;
    S01_AXI_WVALID : IN STD_LOGIC;
    S01_AXI_WREADY : OUT STD_LOGIC;
    S01_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_BVALID : OUT STD_LOGIC;
    S01_AXI_BREADY : IN STD_LOGIC;
    S01_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S01_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S01_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_ARLOCK : IN STD_LOGIC;
    S01_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S01_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXI_ARVALID : IN STD_LOGIC;
    S01_AXI_ARREADY : OUT STD_LOGIC;
    S01_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S01_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(1) - 1 DOWNTO 0);
    S01_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S01_AXI_RLAST : OUT STD_LOGIC;
    S01_AXI_RVALID : OUT STD_LOGIC;
    S01_AXI_RREADY : IN STD_LOGIC;

    S02_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    S02_AXI_ACLK : IN STD_LOGIC;
    S02_AXI_AWID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S02_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S02_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S02_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S02_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S02_AXI_AWLOCK : IN STD_LOGIC;
    S02_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S02_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S02_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S02_AXI_AWVALID : IN STD_LOGIC;
    S02_AXI_AWREADY : OUT STD_LOGIC;
    S02_AXI_WDATA : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(2) - 1 DOWNTO 0);
    S02_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_AXIS_DWIDTH(2)/8 - 1 DOWNTO 0);
    S02_AXI_WLAST : IN STD_LOGIC;
    S02_AXI_WVALID : IN STD_LOGIC;
    S02_AXI_WREADY : OUT STD_LOGIC;
    S02_AXI_BID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S02_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S02_AXI_BVALID : OUT STD_LOGIC;
    S02_AXI_BREADY : IN STD_LOGIC;
    S02_AXI_ARID : IN STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S02_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    S02_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S02_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S02_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S02_AXI_ARLOCK : IN STD_LOGIC;
    S02_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S02_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S02_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S02_AXI_ARVALID : IN STD_LOGIC;
    S02_AXI_ARREADY : OUT STD_LOGIC;
    S02_AXI_RID : OUT STD_LOGIC_VECTOR(C_AXIS_IDWIDTH - 1 DOWNTO 0);
    S02_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_AXIS_DWIDTH(2) - 1 DOWNTO 0);
    S02_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S02_AXI_RLAST : OUT STD_LOGIC;
    S02_AXI_RVALID : OUT STD_LOGIC;
    S02_AXI_RREADY : IN STD_LOGIC;

    M00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
    M00_AXI_ACLK : IN STD_LOGIC;
    M00_AXI_AWID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_AWADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_AWLOCK : OUT STD_LOGIC;
    M00_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_AWVALID : OUT STD_LOGIC;
    M00_AXI_AWREADY : IN STD_LOGIC;
    M00_AXI_WDATA : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_WSTRB : OUT STD_LOGIC_VECTOR(C_AXIM_DWIDTH/8 - 1 DOWNTO 0);
    M00_AXI_WLAST : OUT STD_LOGIC;
    M00_AXI_WVALID : OUT STD_LOGIC;
    M00_AXI_WREADY : IN STD_LOGIC;
    M00_AXI_BID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_BVALID : IN STD_LOGIC;
    M00_AXI_BREADY : OUT STD_LOGIC;
    M00_AXI_ARID : OUT STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_ARADDR : OUT STD_LOGIC_VECTOR(C_AXI_AWIDTH - 1 DOWNTO 0);
    M00_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_ARLOCK : OUT STD_LOGIC;
    M00_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M00_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXI_ARVALID : OUT STD_LOGIC;
    M00_AXI_ARREADY : IN STD_LOGIC;
    M00_AXI_RID : IN STD_LOGIC_VECTOR(C_AXIM_IDWIDTH - 1 DOWNTO 0);
    M00_AXI_RDATA : IN STD_LOGIC_VECTOR(C_AXIM_DWIDTH - 1 DOWNTO 0);
    M00_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M00_AXI_RLAST : IN STD_LOGIC;
    M00_AXI_RVALID : IN STD_LOGIC;
    M00_AXI_RREADY : OUT STD_LOGIC
  );
END COMPONENT mem_achcount3;


end package mem_ctrl_pkg;
