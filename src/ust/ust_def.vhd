-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.01.2016 17:12:50
-- Module Name : ust_def
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package ust_def is

constant C_PKT_TYPE_VIDEO : natural := 1;

constant C_VIDEO_PKT_HEADER_BYTECOUNT : natural := 16;

constant C_UST_LPKT_LSB_BIT : natural := 0;
constant C_UST_LPKT_MSB_BIT : natural := 7;
constant C_UST_TPKT_LSB_BIT : natural := 0 + 8;
constant C_UST_TPKT_MSB_BIT : natural := 7 + 8;

constant C_UST_TPKT_D2H : natural := 0;--dev -> host (read)
constant C_UST_TPKT_VD  : natural := 1;--video data
constant C_UST_TPKT_H2D : natural := 2;--host -> dev (write)


constant C_UST_TDEV_NULL     : natural := 0;
constant C_UST_TDEV_REG      : natural := 1;
constant C_UST_TDEV_GPS      : natural := 2;
constant C_UST_TDEV_DISTANCE : natural := 3;
constant C_UST_TDEV_CAMERA   : natural := 4;
constant C_UST_TDEV_SAU      : natural := 5;
constant C_UST_TDEV_RAM      : natural := 6;
constant C_UST_TDEV_PROM     : natural := 7;
constant C_UST_TDEV_COORD    : natural := 8;
constant C_UST_TDEV_TEMP     : natural := 9;

end package ust_def;

