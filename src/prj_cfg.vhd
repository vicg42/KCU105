-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.02.2015 16:26:08
-- Module Name : prj_cfg
--
-- Description : project configuration
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.vicg_common_pkg.all;

package prj_cfg is

constant C_PCFG_FIRMWARE_VERSION       : integer := 16#000E#;

constant C_PCFG_BOARD                  : string := "KCU105";
constant C_PCFG_MAIN_DBGCS             : string := "ON";

--PCI-Express
constant C_PCGF_PCIE_LINK_WIDTH        : integer := 8; --if change count link than need regenerat core PCI-Express
constant C_PCGF_PCIE_DWIDTH            : integer := 256;

--FG(frame grabber)
constant C_PCFG_FG_PIXBIT              : integer := 16; --Count bit/pix
constant C_PCFG_FG_MEM_VBUF_SIZE       : integer := C_1MB * 32; --Size One Frame Buffer(VBUF)
constant C_PCFG_FG_VBUF_COUNT          : integer := 4; --Count Frame Buffers
constant C_PCFG_FG_VCH_COUNT           : integer := 1; --Count Video channels
constant C_PCFG_VSYN_ACTIVE            : std_logic := '1'; --select active level of strobe video synhronization (HS,VS)

--Memory Controller
constant C_PCFG_MEMCTRL_BANK_SIZE      : integer := 6; --max 7: 0-8MB, 1-16MB, 2-32MB, 3-64MB, 4-128MB, ..., 7-1GB
constant C_PCFG_MEMARB_CH_COUNT        : integer := 1; --CH0(HOST2MEM) +
                                                       --CH1(FG_RD) +
                                                       --CH2(FG_WR)


end package prj_cfg;

