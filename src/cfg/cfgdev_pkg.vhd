-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 28.08.2015 12:23:09
-- Module Name : cfgdev_pkg
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


package cfgdev_pkg is

constant C_CFGPKTH_CTRL_IDX   : integer := 0;
constant C_CFGPKTH_RADR_IDX   : integer := 1;
constant C_CFGPKTH_DLEN_IDX   : integer := 2;

constant C_CFGPKTH_DCOUNT     : integer := C_CFGPKTH_DLEN_IDX + 1;--packet header

--###########################
--C_CFGPKTH_CTRL_IDX / Bit map:
--###########################
--constant C_CFGPKT_RESERV_BIT    : integer:=0 .. 5;
constant C_CFGPKT_FIFO_BIT      : integer := 6;
constant C_CFGPKT_DIR_BIT       : integer := 7;
constant C_CFGPKT_DADR_L_BIT    : integer := 8;
constant C_CFGPKT_DADR_M_BIT    : integer := 15;

--C_CFGPKT_FIFO_BIT / bit map:
constant C_CFGPKT_FIFO_ON       : std_logic := '1';
constant C_CFGPKT_FIFO_OFF      : std_logic := '0';

--C_CFGPKT_DIR_BIT/ bit map:
constant C_CFGPKT_WR            : std_logic := '0'; --host -> dev
constant C_CFGPKT_RD            : std_logic := '1'; --host <- dev

--###########################
--C_CFGPKTH_RADR_IDX / Bit map:
--###########################
constant C_CFGPKT_RADR_L_BIT    : integer := 0; --Adress
constant C_CFGPKT_RADR_M_BIT    : integer := 15;

--###########################
--C_CFGPKTH_DLEN_IDX / Bit map:
--###########################
constant C_CFGPKT_DLEN_L_BIT    : integer := 0; --Size data write/read
constant C_CFGPKT_DLEN_M_BIT    : integer := 15;



component cfgdev_host is
generic(
G_DBG : string := "OFF";
G_HOST_DWIDTH : integer := 32;
G_CFG_DWIDTH  : integer := 16
);
port(
-------------------------------
--HOST
-------------------------------
--host -> dev
p_in_htxbuf_di       : in   std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_htxbuf_wr       : in   std_logic;
p_out_htxbuf_full    : out  std_logic;
p_out_htxbuf_empty   : out  std_logic;

--host <- dev
p_out_hrxbuf_do      : out  std_logic_vector(G_HOST_DWIDTH - 1 downto 0);
p_in_hrxbuf_rd       : in   std_logic;
p_out_hrxbuf_full    : out  std_logic;
p_out_hrxbuf_empty   : out  std_logic;

p_out_hirq           : out  std_logic;
p_out_herr           : out  std_logic;

p_in_hclk            : in   std_logic;

-------------------------------
--FPGA DEV
-------------------------------
p_out_cfg_dadr       : out    std_logic_vector(C_CFGPKT_DADR_M_BIT - C_CFGPKT_DADR_L_BIT downto 0); --dev number
p_out_cfg_radr       : out    std_logic_vector(C_CFGPKT_RADR_M_BIT - C_CFGPKT_RADR_L_BIT downto 0); --adr registr
p_out_cfg_radr_ld    : out    std_logic;
p_out_cfg_radr_fifo  : out    std_logic;

p_out_cfg_txdata     : out    std_logic_vector(G_CFG_DWIDTH - 1 downto 0);
p_out_cfg_wr         : out    std_logic;
p_in_cfg_txbuf_full  : in     std_logic;
p_in_cfg_txbuf_empty : in     std_logic;

p_in_cfg_rxdata      : in     std_logic_vector(G_CFG_DWIDTH - 1 downto 0);
p_out_cfg_rd         : out    std_logic;
p_in_cfg_rxbuf_full  : in     std_logic;
p_in_cfg_rxbuf_empty : in     std_logic;

p_out_cfg_done       : out    std_logic;
p_in_cfg_clk         : in     std_logic;

-------------------------------
--DBG
-------------------------------
p_in_tst             : in     std_logic_vector(31 downto 0);
p_out_tst            : out    std_logic_vector(31 downto 0);

-------------------------------
--System
-------------------------------
p_in_rst             : in     std_logic
);
end component cfgdev_host;

end package cfgdev_pkg;
