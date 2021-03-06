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

constant C_PCFG_FIRMWARE_VERSION       : integer := 16#007C#;

constant C_PCFG_BOARD                  : string := "KCU105";
constant C_PCFG_MAIN_DBGCS             : string := "ON";

--PCI-Express
constant C_PCFG_PCIE_LINK_WIDTH        : integer := 8; --if change count link than need regenerat core PCI-Express
constant C_PCFG_PCIE_DWIDTH            : integer := 256;

--Memory Controller
constant C_PCFG_MEMCTRL_BANK_SIZE      : integer := 7; --max 7: 0-8MB, 1-16MB, 2-32MB, 3-64MB, 4-128MB, ..., 7-1GB
constant C_PCFG_MEMARB_CH_COUNT        : integer := 3; --CH0(FG_RD) +
                                                       --CH1(FG_WR(0)) + CH2(FG_WR(1))

--ETH
constant C_PCFG_ETH_DBG                : string := "LOOPBACK";
constant C_PCFG_ETH_CH_COUNT           : integer := 2;
constant C_PCFG_ETH_CH_COUNT_MAX       : integer := 2;
constant C_PCFG_ETH_DWIDTH             : integer := 64;

--FG(frame grabber)
constant C_PCFG_FG_FR_PIX_COUNT_MAX    : integer := 8192; --Max frame resolution. Must be pwr(2, n)
constant C_PCFG_FG_FR_ROW_COUNT_MAX    : integer := 8192;
constant C_PCFG_FG_VBUF_COUNT          : integer := 8; --Count Frame Buffers. Must be pwr(2, n)
constant C_PCFG_FG_VCH_COUNT           : integer := 2; --Count Video channels. Must be pwr(2, n)
constant C_PCFG_FG_BUFI_DWIDTH         : natural := 128;

--UST
constant C_PCFG_UST_DBGCS              : string := "OFF";

end package prj_cfg;

