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
constant C_TPKT_D2H   : natural := 0;--fpga -> host (read)
constant C_TPKT_VIDEO : natural := 1;--video data
constant C_TPKT_H2D   : natural := 2;--host -> fpga (write)

--Packet Header size (byte)
constant C_TPKT_D2H_HDR_BCOUNT : natural := 4; --Count byte into header of packet type (Host <- FPGA)
constant C_TPKT_H2D_HDR_BCOUNT : natural := 4; --Count byte into header of packet type (Host -> FPGA)
constant C_TPKT_VIDEO_HDR_BCOUNT : natural := 16; --Count byte into header of packet type (Video)

--Device Header size (byte)
constant C_DEV_HDR_BCOUNT : natural := 4;--Length + Header

--Type Device
constant C_TDEV_NULL   : natural := 0;
constant C_TDEV_REG    : natural := 1;
constant C_TDEV_CAM    : natural := 2;
constant C_TDEV_SAU    : natural := 3;
constant C_TDEV_GPS    : natural := 4;
constant C_TDEV_LASER  : natural := 5;
constant C_TDEV_RAM    : natural := 6;
constant C_TDEV_PROM   : natural := 7;
constant C_TDEV_TEMP   : natural := 8;
constant C_TDEV_LAST   : natural := C_TDEV_TEMP;
--SubType Device
constant C_SDEV_STATUS : natural := 0;
constant C_SDEV_CTRL   : natural := 1;
constant C_SDEV_H2D    : natural := 2;
constant C_SDEV_D2H    : natural := 3;
constant C_SDEV_LAST   : natural := C_SDEV_D2H;

constant C_SDEV_COUNT_MAX : natural := C_SDEV_LAST + 1;
constant C_TDEV_COUNT_MAX : natural := C_TDEV_LAST + 1;
constant C_NDEV_COUNT_MAX : natural := 2; --Max Count Device from all device type/subtype

type TDevB_t is array (0 to (C_TDEV_COUNT_MAX - 1)) of std_logic_vector((C_NDEV_COUNT_MAX - 1) downto 0);
type TDevB is array (0 to (C_SDEV_COUNT_MAX - 1)) of TDevB_t;

type TDevDATA_t is array (0 to (C_NDEV_COUNT_MAX - 1)) of std_logic_vector(7 downto 0);
type TDevDATA is array (0 to (C_TDEV_COUNT_MAX - 1)) of TDevDATA_t;
type TDevD is array (0 to (C_SDEV_COUNT_MAX - 1)) of TDevDATA;

--              TypeDevice(value): NULL   ,  REG   ,  CAM   ,  SAU   , GPS    , LASER  ,  RAM   ,  ROM   ,  TEMP
--              NumberDevice(bit): ..1,0  , ..1,0  , ..1,0  , ..1,0  , ..1,0  , ..1,0  , ..1,0  , ..1,0  , ..1,0
constant C_RDEV_VALID : TDevB :=( ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: STATUS
                                  ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: CTRL
                                  ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: H2D
                                  ( "00"  ,  "00"  ,  "01"  , "00"   , "10"   , "00"   , "00"   , "00"   , "00"  )   --SubTypeDevice: D2H
                                );

constant C_WDEV_VALID : TDevB :=( ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: STATUS
                                  ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: CTRL
                                  ( "00"  ,  "00"  ,  "01"  , "00"   , "10"   , "00"   , "00"   , "00"   , "00"  ),  --SubTypeDevice: H2D
                                  ( "00"  ,  "00"  ,  "00"  , "00"   , "00"   , "00"   , "00"   , "00"   , "00"  )   --SubTypeDevice: D2H
                                );
end package ust_def;

