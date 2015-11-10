-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 06.11.2015 17:10:40
-- Module Name : eth_pkg
--
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eth_phypin_pkg.all;

package eth_pkg is

type TEthMacAdr is array (0 to 5) of unsigned(7 downto 0);
type TEthMAC is record
dst : TEthMacAdr;
src : TEthMacAdr;
end record;

type TEthCfg is record
usrctrl  : std_logic_vector(15 downto 0);
mac      : TEthMAC;
end record;
type TEthCfgs is array (0 to 0) of TEthCfg;


-------------------------------------
--Eth<->USR
-------------------------------------
type TEthIO_OUT is record
rx_axi_tuser  : std_logic_vector(1 downto 0);
rx_axi_tvalid : std_logic;
rx_axi_tdata  : std_logic_vector(64 - 1 downto 0);
rx_axi_tkeep  : std_logic_vector((64 / 8) - 1 downto 0);

tx_axi_tready : std_logic;
end record;

type TEthIO_IN is record
tx_axi_tdata  : std_logic_vector(64 - 1 downto 0);
tx_axi_tvalid : std_logic;

rx_axi_tready : std_logic;
end record;

type TEthStatus_OUT is record
rdy    : std_logic;
carier : std_logic;
end record;


type TEthSIM_OUT is record
coreclk       : std_logic;

rx_axi_tuser  : std_logic_vector(1 downto 0);
rx_axi_tvalid : std_logic;
rx_axi_tdata  : std_logic_vector(64 - 1 downto 0);
rx_axi_tkeep  : std_logic_vector((64 / 8) - 1 downto 0);

end record;

type TEthSIM_IN is record
pcs_loopback           : std_logic;
reset                  : std_logic;
reset_error            : std_logic;
insert_error           : std_logic;
enable_pat_gen         : std_logic;
enable_pat_check       : std_logic;
sim_speedup_control    : std_logic;
enable_custom_preamble : std_logic;
end record;


type TEthIO_OUTs is array (0 to C_GTCH_COUNT - 1) of TEthIO_OUT;
type TEthIO_INs is array (0 to C_GTCH_COUNT - 1) of TEthIO_IN;

type TEthStatus_OUTs is array (0 to C_GTCH_COUNT - 1) of TEthStatus_OUT;

type TEthSIM_OUTs is array (0 to C_GTCH_COUNT - 1) of TEthSIM_OUT;
type TEthSIM_INs is array (0 to C_GTCH_COUNT - 1) of TEthSIM_IN;

end package eth_pkg;


