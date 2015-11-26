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


package eth_pkg is

type TEthMacAdr is array (0 to 5) of std_logic_vector(7 downto 0);
type TEthMAC is record
dst : TEthMacAdr;
src : TEthMacAdr;
end record;

type TEthCfg is record
--usrctrl  : std_logic_vector(15 downto 0);
mac      : TEthMAC;
end record;
type TEthCfgs is array (0 to 0) of TEthCfg;


type TEthDBG_MacTx is record
usr_axi_tready : std_logic;
usr_axi_tvalid : std_logic;
usr_axi_done   : std_logic;
usr_axi_tdata  : std_logic_vector(63 downto 0);

eth_axi_tready : std_logic;
eth_axi_tdata : std_logic_vector(63 downto 0);
eth_axi_tkeep : std_logic_vector(7 downto 0);
eth_axi_tvalid : std_logic;
eth_axi_tlast : std_logic;

fsm : std_logic_vector(2 downto 0);
end record;

type TEthDBG_MacRx is record
eth_axi_tdata : std_logic_vector(63 downto 0);
eth_axi_tkeep : std_logic_vector(7 downto 0);

eth_axi_tvalid : std_logic;
eth_axi_tlast  : std_logic;

usr_axi_tvalid : std_logic;
usr_axi_tuser  : std_logic_vector(1 downto 0);

fsm : std_logic_vector(2 downto 0);
end record;

type TEthDBG_MacTxs is array (0 to 1) of TEthDBG_MacTx;
type TEthDBG_MacRxs is array (0 to 1) of TEthDBG_MacRx;

type TEthDBG is record
tx : TEthDBG_MacTxs;
rx : TEthDBG_MacRxs;
end record;



end package eth_pkg;
