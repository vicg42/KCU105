-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.01.2016 17:12:50
-- Module Name : ust_def
--
-- Description :
-- _HDR_ - header
-- _BCOUNT - byte count
-- _Fxxx_ - field xxx
-- _D2H_ - dir Dev -> Host
-- _H2D_ - dir Dev <- Host
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package ust_def is

constant C_FLEN_BCOUNT : natural := 2; --field length
constant C_FPKT_TYPE_BCOUNT : natural := 2; --field length

--Type of packet
constant C_PKT_TYPE_D2H   : natural := 0;--dev -> host (read)
constant C_PKT_TYPE_VIDEO : natural := 1;--video data
constant C_PKT_TYPE_H2D   : natural := 2;--host -> dev (write)

--Packet Header size (byte)
--constant C_VIDEO_PKT_HDR_BCOUNT : natural := 16;
constant C_PKT_D2H_HDR_BCOUNT : natural := 4;
constant C_PKT_H2D_HDR_BCOUNT : natural := 4;
constant C_PKT_VIDEO_HDR_BCOUNT : natural := 16;

--Device Header size (byte)
constant C_UDEV_HDR_BCOUNT : natural := 4;

--Type Device
constant C_UDEV_NULL   : natural := 0;
constant C_UDEV_REG    : natural := 1;
constant C_UDEV_GPS    : natural := 2;
constant C_UDEV_LASER  : natural := 3;
constant C_UDEV_CAMERA : natural := 4;
constant C_UDEV_SAU    : natural := 5;
constant C_UDEV_RAM    : natural := 6;
constant C_UDEV_PROM   : natural := 7;
constant C_UDEV_TEMP   : natural := 8;

constant C_TDEV_COUNT_MAX : natural := 9;
constant C_NDEV_COUNT_MAX : natural := 2;

--type TUDevParam is record
--ctrl : std_logic_vector(C_SWT_REG_CTRL_LAST_BIT downto 0);
--dbg  : std_logic_vector(C_SWT_REG_DBG_LAST_BIT downto 0);
--frr  : TSwtFrr;
--end record;
--
--type TUDevParam is record
--tdev : std_logic_vector(C_SWT_REG_CTRL_LAST_BIT downto 0);
--dbg  : std_logic_vector(C_SWT_REG_DBG_LAST_BIT downto 0);
--frr  : TSwtFrr;
--end record;

type TUDevRDY is array (0 to (C_TDEV_COUNT_MAX - 1)) of std_logic_vector((C_NDEV_COUNT_MAX - 1) downto 0);
type TUDevRD is array (0 to (C_TDEV_COUNT_MAX - 1)) of std_logic_vector((C_NDEV_COUNT_MAX - 1) downto 0);

type TUDevD is array (0 to (C_NDEV_COUNT_MAX - 1)) of std_logic_vector(7 downto 0);
type TUDevDATA is array (0 to (C_TDEV_COUNT_MAX - 1)) of TUDevD;



end package ust_def;

