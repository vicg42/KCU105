-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.11.2011 10:48:05
-- Module Name : pcie_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.prj_cfg.all;

package pcie_pkg is

type TPce2Mem_Ctrl is record
dir       : std_logic; --C_MEMWR_WRITE/READ from mem_wr_pkg.vhd
start     : std_logic;
adr       : std_logic_vector(31 downto 0);--Adress(BYTE)
req_len   : std_logic_vector(17 downto 0);--Size(BYTE) max=128KB
trnwr_len : std_logic_vector(7 downto 0); --
trnrd_len : std_logic_vector(7 downto 0); --
end record;

type TPce2Mem_Status is record
done    : std_logic;
end record;

type TPCIE_pinin is record
clk_p    : std_logic;
clk_n    : std_logic;
rst_n    : std_logic;
rxp      : std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
rxn      : std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
end record;

type TPCIE_pinout is record
txp      : std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
txn      : std_logic_vector(C_PCGF_PCIE_LINK_WIDTH - 1 downto 0);
end record;

type TPCIE_cfgprm is record
link_width  : std_logic_vector(5 downto 0);--Count link PCI-Express negotiation with PC
max_payload : std_logic_vector(2 downto 0);--max_payload_size negotiation with PC
max_rd_req  : std_logic_vector(2 downto 0);--Max read request size for the device when acting as the Requester
end record;


--Buffer of core PCI-Express:
constant C_PCIE_BUF_NON_POSTED_QUEUE    : integer:=0;
constant C_PCIE_BUF_POSTED_QUEUE        : integer:=1;
constant C_PCIE_BUF_COMPLETION_QUEUE    : integer:=2;
constant C_PCIE_BUF_LOOK_AHEAD          : integer:=3;

--Header MEM pkt:
--(field FMT)
constant C_PCIE_FMT_MSG_4DW             : std_logic_vector(1 downto 0):="10";     --Msg  - 4DW, no data
constant C_PCIE_FMT_MSGD_4DW            : std_logic_vector(1 downto 0):="11";     --MsgD - 4DW, w/ data

--(field FMT + field TYPE)
constant C_PCIE_PKT_TYPE_IORD_3DW_ND    : std_logic_vector(6 downto 0):="0000010"; --(0x02) IORd   - 3DW, no data
constant C_PCIE_PKT_TYPE_IOWR_3DW_WD    : std_logic_vector(6 downto 0):="1000010"; --(0x42) IOWr   - 3DW, w/data
constant C_PCIE_PKT_TYPE_MWR_3DW_WD     : std_logic_vector(6 downto 0):="1000000"; --(0x40) MWr    - 3DW, w/data
constant C_PCIE_PKT_TYPE_MWR_4DW_WD     : std_logic_vector(6 downto 0):="1100000"; --(0x60) MWr    - 4DW, w/data
constant C_PCIE_PKT_TYPE_MRD_3DW_ND     : std_logic_vector(6 downto 0):="0000000"; --(0x00) MRd    - 3DW, no data
constant C_PCIE_PKT_TYPE_MRD_4DW_ND     : std_logic_vector(6 downto 0):="0100000"; --(0x20) MRd    - 4DW, no data
constant C_PCIE_PKT_TYPE_MRDLK_3DW_ND   : std_logic_vector(6 downto 0):="0000001"; --(0x01) MRdLk  - 3DW, no data
constant C_PCIE_PKT_TYPE_MRDLK_4DW_ND   : std_logic_vector(6 downto 0):="0100001"; --(0x21) MRdLk  - 4DW, no data
constant C_PCIE_PKT_TYPE_CPLLK_3DW_ND   : std_logic_vector(6 downto 0):="0001011"; --(0x0B) CplLk  - 3DW, no data
constant C_PCIE_PKT_TYPE_CPLDLK_3DW_WD  : std_logic_vector(6 downto 0):="1001011"; --(0x4B) CplDLk - 3DW, w/ data
constant C_PCIE_PKT_TYPE_CPL_3DW_ND     : std_logic_vector(6 downto 0):="0001010"; --(0x0A) Cpl    - 3DW, no data
constant C_PCIE_PKT_TYPE_CPLD_3DW_WD    : std_logic_vector(6 downto 0):="1001010"; --(0x4A) CplD   - 3DW, w/ data
constant C_PCIE_PKT_TYPE_CFGRD0_3DW_ND  : std_logic_vector(6 downto 0):="0000100"; --(0x04) CfgRd0 - 3DW, no data
constant C_PCIE_PKT_TYPE_CFGWR0_3DW_WD  : std_logic_vector(6 downto 0):="1000100"; --(0x44) CfgwR0 - 3DW, w/ data
constant C_PCIE_PKT_TYPE_CFGRD1_3DW_ND  : std_logic_vector(6 downto 0):="0000101"; --(0x05) CfgRd1 - 3DW, no data
constant C_PCIE_PKT_TYPE_CFGWR1_3DW_WD  : std_logic_vector(6 downto 0):="1000101"; --(0x45) CfgwR1 - 3DW, w/ data

constant C_PCIE_MAX_PAYLOAD_128_BYTE    : std_logic_vector(2 downto 0):="000";
constant C_PCIE_MAX_PAYLOAD_256_BYTE    : std_logic_vector(2 downto 0):="001";
constant C_PCIE_MAX_PAYLOAD_512_BYTE    : std_logic_vector(2 downto 0):="010";
constant C_PCIE_MAX_PAYLOAD_1024_BYTE   : std_logic_vector(2 downto 0):="011";
constant C_PCIE_MAX_PAYLOAD_2048_BYTE   : std_logic_vector(2 downto 0):="100";
constant C_PCIE_MAX_PAYLOAD_4096_BYTE   : std_logic_vector(2 downto 0):="101";

constant C_PCIE_MAX_RD_REQ_128_BYTE     : std_logic_vector(2 downto 0):="000";
constant C_PCIE_MAX_RD_REQ_256_BYTE     : std_logic_vector(2 downto 0):="001";
constant C_PCIE_MAX_RD_REQ_512_BYTE     : std_logic_vector(2 downto 0):="010";
constant C_PCIE_MAX_RD_REQ_1024_BYTE    : std_logic_vector(2 downto 0):="011";
constant C_PCIE_MAX_RD_REQ_2048_BYTE    : std_logic_vector(2 downto 0):="100";
constant C_PCIE_MAX_RD_REQ_4096_BYTE    : std_logic_vector(2 downto 0):="101";

constant C_PCIE_COMPL_STATUS_SC         : std_logic_vector(2 downto 0):="000";
constant C_PCIE_COMPL_STATUS_UR         : std_logic_vector(2 downto 0):="001";
constant C_PCIE_COMPL_STATUS_CRS        : std_logic_vector(2 downto 0):="010";
constant C_PCIE_COMPL_STATUS_CA         : std_logic_vector(2 downto 0):="011";


constant C_PCIE3_PKT_TYPE_MEM_RD_ND    : std_logic_vector(3 downto 0) := "0000"; --Memory Read
constant C_PCIE3_PKT_TYPE_MEM_WR_D     : std_logic_vector(3 downto 0) := "0001"; --Memory Write
constant C_PCIE3_PKT_TYPE_IO_RD_ND     : std_logic_vector(3 downto 0) := "0010"; --IO Read
constant C_PCIE3_PKT_TYPE_IO_WR_D      : std_logic_vector(3 downto 0) := "0011"; --IO Write
constant C_PCIE3_PKT_TYPE_ATOP_FAA     : std_logic_vector(3 downto 0) := "0100"; --Fetch and ADD
constant C_PCIE3_PKT_TYPE_ATOP_UCS     : std_logic_vector(3 downto 0) := "0101"; --Unconditional SWAP
constant C_PCIE3_PKT_TYPE_ATOP_CAS     : std_logic_vector(3 downto 0) := "0110"; --Compare and SWAP
constant C_PCIE3_PKT_TYPE_MEM_LK_RD_ND : std_logic_vector(3 downto 0) := "0111"; --Locked Read Request
constant C_PCIE3_PKT_TYPE_MSG          : std_logic_vector(3 downto 0) := "1100"; --MSG Transaction apart from Vendor Defined and ATS
constant C_PCIE3_PKT_TYPE_MSG_VD       : std_logic_vector(3 downto 0) := "1101"; --MSG Transaction apart from Vendor Defined and ATS
constant C_PCIE3_PKT_TYPE_MSG_ATS      : std_logic_vector(3 downto 0) := "1110"; --MSG Transaction apart from Vendor Defined and ATS


end package pcie_pkg;
