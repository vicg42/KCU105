-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.02.2015 16:26:08
-- Module Name : ust_cfg
--
-- Description : project configuration
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.vicg_common_pkg.all;

package ust_cfg is

constant C_USTCFG_FIRMWARE_VERSION       : integer := 16#01#;

constant C_USTCFG_CAM0_VCH_NUM            : natural := 0;
constant C_USTCFG_CAM0_PIXCHUNK_BYTECOUNT : natural := 1024; --1280(max)
constant C_USTCFG_CAM0_CL_PIXBIT          : natural := 8; --Number of bit per 1 pix
constant C_USTCFG_CAM0_CL_TAP             : natural := 8; --Number of pixel per 1 clk
constant C_USTCFG_CAM0_CL_CHCOUNT         : natural := 3; --Number of channel: Base/Medium/Full Configuration = 1/2/3


end package ust_cfg;

