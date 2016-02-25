-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 04.06.2015 16:44:21
-- Module Name : cam_cl_main
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.reduce_pack.all;
use work.cl_pkg.all;
use work.cam_cl_pkg.all;

entity cam_cl_main is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTECOUNT : natural := 16;
G_PKT_PIXCHUNK_BYTECOUNT : natural := 1024;
G_CL_PIXBIT : natural := 1; --Number of bit per 1 pix
G_CL_TAP : natural := 8; --Number of pixel per 1 clk
G_CL_CHCOUNT : natural := 1;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--
--------------------------------------------------
--p_in_cam_ctrl_rx  : in  std_logic;
--p_out_cam_ctrl_tx : out std_logic;
p_in_time         : in  std_logic_vector(31 downto 0);

--------------------------------------------------
--CameraLink Interface
--------------------------------------------------
p_in_tfg_n : in  std_logic; --Camera -> FG
p_in_tfg_p : in  std_logic;
p_out_tc_n : out std_logic; --Camera <- FG
p_out_tc_p : out std_logic;

--X,Y,Z : 0,1,2
p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--VideoPkt Output
--------------------------------------------------
p_out_bufpkt_d     : out  std_logic_vector(63 downto 0);
p_in_bufpkt_rd     : in   std_logic;
p_in_bufpkt_rdclk  : in   std_logic;
p_out_bufpkt_empty : out  std_logic;

--------------------------------------------------
--
--------------------------------------------------
p_out_status   : out  std_logic_vector(C_CAM_STATUS_LASTBIT downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_tst : out  std_logic_vector(2 downto 0);
p_in_tst  : in   std_logic_vector(2 downto 0);
p_out_dbg : out  TCAM_dbg;

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity cam_cl_main;

architecture struct of cam_cl_main is

component cl_main is
generic(
G_DCM_TYPE : TCL_DCM_TYPE_ARRAY := (C_CL_PLL, --type dcm for chanal 3
                                    C_CL_PLL, --type dcm for chanal 2
                                    C_CL_MMCM --type dcm for chanal 1
                                   );
G_DCM_CLKIN_PERIOD : real := 11.764000; --85MHz => clkx7 = ((85/1)*14)/2 = 1190/2 = 595MHz
G_DCM_DIVCLK_DIVIDE : natural := 1;
G_DCM_CLKFBOUT_MULT : natural := 14;
G_DCM_CLKOUT0_DIVIDE : natural := 2;
G_CL_PIXBIT : natural := 8; --Number of bit per 1 pix
G_CL_TAP : natural := 8; --Number of pixel per 1 clk
G_CL_CHCOUNT : natural := 1 --Number of channel: Base/Medium/Full Configuration = 1/2/3
);
port(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_clk_n : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_in_cl_di_p  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);
p_in_cl_di_n  : in  std_logic_vector((4 * G_CL_CHCOUNT) - 1 downto 0);

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_plllock: out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_link   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
p_out_fval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_out_lval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_out_dval   : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_out_rxbyte : out  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_out_rxclk  : out  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_cl_clk_synval : out std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

--p_in_refclk : in std_logic;
--p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end component cl_main;

component cl_frprm_detector is
generic (
G_CL_TAP : natural := 8;
G_SIM : string := "OFF"
);
port(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart : in std_logic;

--------------------------------------------------
--video
--------------------------------------------------
p_in_link   : in std_logic;
p_in_fval   : in std_logic;
p_in_lval   : in std_logic;
p_in_dval   : in std_logic;
p_in_rxclk  : in std_logic;

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  : out std_logic_vector(15 downto 0);
p_out_linecount : out std_logic_vector(15 downto 0);
p_out_det_rdy   : out std_logic
);
end component cl_frprm_detector;

component cl_bufline is
generic(
G_CL_PIXBIT : natural := 8; --Number of bit per 1 pix
G_CL_TAP : natural := 8; --Number of pixel per 1 clk
G_CL_CHCOUNT : natural := 1
);
port(
--------------------------------------------------
--Input
--------------------------------------------------
p_in_fval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
p_in_lval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
p_in_dval   : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
p_in_rxbyte : in  std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
p_in_rxclk  : in  std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

--------------------------------------------------
--Output
--------------------------------------------------
p_out_buf_empty : out  std_logic;
p_out_buf_do    : out  std_logic_vector(63 downto 0);
p_in_buf_rd     : in   std_logic;
p_in_buf_rdclk  : in   std_logic;
p_in_buf_rstn   : in   std_logic
);
end component cl_bufline;

component pktvd_create is
generic(
G_VCH_NUM : natural := 0;
G_PKT_TYPE : natural := 1;
G_PKT_HEADER_BYTECOUNT : natural := 16;
G_PKT_PIXCHUNK_BYTECOUNT : natural := 1024;
G_CL_TAP : natural := 8  --Number of pixel per 1 clk
);
port(
----------------------------
--Ctrl
----------------------------
p_in_det_frprm     : in std_logic;
p_in_det_pixcount  : in std_logic_vector(15 downto 0);
p_in_det_linecount : in std_logic_vector(15 downto 0);
p_in_time          : in std_logic_vector(31 downto 0);

----------------------------
--VBUF (source of video data)
----------------------------
p_out_bufi_rd   : out  std_logic;
p_in_bufi_do    : in   std_logic_vector(63 downto 0);
p_in_bufi_empty : in   std_logic;
p_in_vsync      : in   std_logic;
p_in_hsync      : in   std_logic;

----------------------------
--VideoPacket output
----------------------------
p_out_pkt_do   : out  std_logic_vector(63 downto 0);
p_out_pkt_wr   : out  std_logic;
p_in_pkt_wrclk : in   std_logic;

----------------------------
--DBG
----------------------------
p_out_tst : out  std_logic_vector(31 downto 0);
p_in_tst  : in   std_logic_vector(31 downto 0);

----------------------------
--SYS
----------------------------
p_in_rst : in std_logic
);
end component pktvd_create;

component cam_fifo_vpkt
port (
din       : in  std_logic_vector(63 downto 0);
wr_en     : in  std_logic;
--wr_clk    : in  std_logic;

dout      : out std_logic_vector(63 downto 0);
rd_en     : in  std_logic;
--rd_clk    : in  std_logic;

empty     : out std_logic;
full      : out std_logic;
--prog_full : out std_logic;

--rst       : in  std_logic

wr_rst_busy : out std_logic;
rd_rst_busy : out std_logic;

clk       : in  std_logic;
srst      : in  std_logic
);
end component cam_fifo_vpkt;

signal i_plllock           : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_link              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal i_fval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --frame valid
signal i_lval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --line valid
signal i_dval              : std_logic_vector(G_CL_CHCOUNT - 1 downto 0); --data valid
signal i_rxbyte            : std_logic_vector((G_CL_PIXBIT * G_CL_TAP) - 1 downto 0);
signal i_rxclk             : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);

signal i_link_total        : std_logic;
signal i_pixcount_detect   : std_logic_vector(15 downto 0);
signal i_linecount_detect  : std_logic_vector(15 downto 0);
signal i_frprm_detect      : std_logic;

signal i_bufi_do           : std_logic_vector(63 downto 0);
signal i_bufi_rd           : std_logic;
signal i_bufi_rst          : std_logic;
signal i_bufi_empty        : std_logic;

signal i_bufpkt_di         : std_logic_vector(63 downto 0);
signal i_bufpkt_do         : std_logic_vector(63 downto 0);
signal i_bufpkt_wr         : std_logic;
signal i_bufpkt_rd         : std_logic;
signal i_bufpkt_empty      : std_logic;

signal i_vpkt_tst_out      : std_logic_vector(31 downto 0);
signal i_restart           : std_logic;
signal sr_btn              : std_logic_vector(0 to 2);

type TCL_Tst0 is array (0 to G_CL_CHCOUNT - 1) of std_logic_vector(0 to 1);
signal sr_fval             : TCL_Tst0;
signal sr_lval             : TCL_Tst0;
signal tst_fval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal tst_fval_edge1      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--signal tst_lval_edge0      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
--signal tst_lval_edge1      : std_logic_vector(G_CL_CHCOUNT - 1 downto 0);
signal sr_fval_t           : std_logic_vector(0 to 1);
signal sr_lval_t           : std_logic_vector(0 to 1);
signal tst_fval_t_edge0    : std_logic;
signal tst_fval_t_edge1    : std_logic;
--signal tst_lval_t_edge0    : std_logic;
--signal tst_lval_t_edge1    : std_logic;

signal tst_cl_clk_synval   : std_logic_vector((7 * G_CL_CHCOUNT) - 1 downto 0);

signal i_dbg : TCAM_dbg;





begin --architecture struct

gen_status0 : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
p_out_status(C_CAM_STATUS_CLX_PLLLOCK_BIT + i) <= i_plllock(i);
p_out_status(C_CAM_STATUS_CLX_LINK_BIT + i) <= i_link(i);
end generate gen_status0;

gen_status1 : if (G_CL_CHCOUNT < C_CL_CHCOUNT_MAX) generate begin
gen : for i in G_CL_CHCOUNT to (C_CL_CHCOUNT_MAX - 1) generate begin
p_out_status(C_CAM_STATUS_CLX_PLLLOCK_BIT + i) <= '0';
p_out_status(C_CAM_STATUS_CLX_LINK_BIT + i) <= '0';
end generate gen;
end generate gen_status1;

p_out_status(C_CAM_STATUS_CL_LINKTOTAL_BIT) <= i_link_total;




--m_IDELAYCTRL : IDELAYCTRL
--generic map (
--SIM_DEVICE => "ULTRASCALE"  -- Set the device version (7SERIES, ULTRASCALE)
--)
--port map (
--RDY    => i_idelayctrl_rdy, -- 1-bit output: Ready output
--REFCLK => p_in_refclk     , -- 1-bit input: Reference clock input
--RST    => i_idelayctrl_rst  -- 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
--                            -- REFCLK.
--);

m_cam_core : cl_main
generic map(
G_DCM_TYPE => (C_CL_PLL, C_CL_PLL, C_CL_MMCM),
G_DCM_CLKIN_PERIOD   => 11.764000, --85MHz => clkx7 = ((85/1)*14)/2 = 1190/2 = 595MHz
G_DCM_DIVCLK_DIVIDE  => 1,
G_DCM_CLKFBOUT_MULT  => 14,
G_DCM_CLKOUT0_DIVIDE => 2,
G_CL_PIXBIT => G_CL_PIXBIT,
G_CL_TAP => G_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--CameraLink
--------------------------------------------------
--X,Y,Z : 0,1,2
p_in_cl_clk_p => p_in_cl_clk_p,
p_in_cl_clk_n => p_in_cl_clk_n,
p_in_cl_di_p  => p_in_cl_di_p ,
p_in_cl_di_n  => p_in_cl_di_n ,

--------------------------------------------------
--VideoOut
--------------------------------------------------
p_out_plllock => i_plllock,
p_out_link   => i_link  ,
p_out_fval   => i_fval  ,
p_out_lval   => i_lval  ,
p_out_dval   => i_dval  ,
p_out_rxbyte => i_rxbyte,
p_out_rxclk  => i_rxclk ,

--------------------------------------------------
--DBG
--------------------------------------------------
p_out_cl_clk_synval => tst_cl_clk_synval,
--p_out_tst => open,
--p_in_tst  => (others => '0'),

--p_in_refclk => p_in_refclk,
--p_in_clk => p_in_clk,
p_in_rst => p_in_rst
);


i_link_total <= AND_reduce(i_link);


--Detect resolution of video
m_frprm_detector : cl_frprm_detector
generic map(
G_CL_TAP => G_CL_TAP,
G_SIM => G_SIM
)
port map(
--------------------------------------------------
--usectrl
--------------------------------------------------
p_in_restart => i_restart,

--------------------------------------------------
--video
--------------------------------------------------
p_in_link  => i_link_total,
p_in_fval  => i_fval(0),
p_in_lval  => i_lval(0),
p_in_dval  => i_dval(0),
p_in_rxclk => i_rxclk(0),

--------------------------------------------------
--params video
--------------------------------------------------
p_out_pixcount  => i_pixcount_detect,
p_out_linecount => i_linecount_detect,
p_out_det_rdy   => i_frprm_detect
);


m_cl_bufline : cl_bufline
generic map(
G_CL_PIXBIT => G_CL_PIXBIT,
G_CL_TAP => G_CL_TAP,
G_CL_CHCOUNT => G_CL_CHCOUNT
)
port map(
--------------------------------------------------
--Input
--------------------------------------------------
p_in_fval   => i_fval  ,
p_in_lval   => i_lval  ,
p_in_dval   => i_dval  ,
p_in_rxbyte => i_rxbyte,
p_in_rxclk  => i_rxclk ,

--------------------------------------------------
--Output
--------------------------------------------------
p_out_buf_empty => i_bufi_empty,
p_out_buf_do    => i_bufi_do,
p_in_buf_rd     => i_bufi_rd,
p_in_buf_rdclk  => p_in_bufpkt_rdclk,
p_in_buf_rstn   => i_frprm_detect
);


--i_pixcount_detect <= std_logic_vector(TO_UNSIGNED(2157, i_pixcount_detect'length));
m_vpkt : pktvd_create
generic map(
G_VCH_NUM => G_VCH_NUM,
G_PKT_TYPE => G_PKT_TYPE,
G_PKT_HEADER_BYTECOUNT => G_PKT_HEADER_BYTECOUNT,
G_PKT_PIXCHUNK_BYTECOUNT => G_PKT_PIXCHUNK_BYTECOUNT,
G_CL_TAP => G_CL_TAP  --Number of pixel per 1 clk
)
port map(
----------------------------
--Ctrl
----------------------------
p_in_det_frprm     => i_frprm_detect,
p_in_det_pixcount  => i_pixcount_detect ,
p_in_det_linecount => i_linecount_detect,
p_in_time          => p_in_time,

----------------------------
--VBUF (source of video data)
----------------------------
p_out_bufi_rd   => i_bufi_rd,
p_in_bufi_do    => i_bufi_do,
p_in_bufi_empty => i_bufi_empty,
p_in_vsync      => i_fval(0),
p_in_hsync      => i_lval(0),

----------------------------
--VideoPacket output
----------------------------
p_out_pkt_do   => i_bufpkt_di,
p_out_pkt_wr   => i_bufpkt_wr,
p_in_pkt_wrclk => p_in_bufpkt_rdclk,

----------------------------
--DBG
----------------------------
p_out_tst => i_vpkt_tst_out,
p_in_tst  => (others => '0'),

----------------------------
--SYS
----------------------------
p_in_rst => '0' --p_in_rst
);


m_buf_vpkt : cam_fifo_vpkt
port map(
din       => i_bufpkt_di,
wr_en     => i_bufpkt_wr,
--wr_clk    : in  std_logic;

dout      => i_bufpkt_do,--p_out_bufpkt_d,--
rd_en     => i_bufpkt_rd,--p_in_bufpkt_rd,--
--rd_clk    : in  std_logic;

empty     => i_bufpkt_empty,
full      => open,
--prog_full : out std_logic;

--rst       : in  std_logic

wr_rst_busy => open,
rd_rst_busy => open,

clk       => p_in_bufpkt_rdclk,
srst      => '0'
);


i_bufpkt_rd <= p_in_bufpkt_rd;
p_out_bufpkt_d <= i_bufpkt_do;
p_out_bufpkt_empty <= i_bufpkt_empty;


--#########################################
--DBG
--#########################################
p_out_tst(0) <= i_fval(0);
p_out_tst(1) <= i_lval(0);

--test ctrl camera VITA25K
m_ibufds_tfg : IBUFDS
--port map (I => p_in_tfg_p, IB => p_in_tfg_n, O => p_out_cam_ctrl_tx);
port map (I => p_in_tfg_p, IB => p_in_tfg_n, O => p_out_tst(2));

m_obufds_tc : OBUFDS
--port map (I => p_in_cam_ctrl_rx, O  => p_out_tc_p, OB => p_out_tc_n);
port map (I => p_in_tst(2), O  => p_out_tc_p, OB => p_out_tc_n);


p_out_dbg <= i_dbg;


i_dbg.det.pixcount  <= i_pixcount_detect;
i_dbg.det.linecount <= i_linecount_detect;
i_dbg.det.frprm_det <= i_frprm_detect;
i_dbg.det.restart <= i_restart;

i_dbg.cl(0).clk <= i_rxclk(0);
i_dbg.cl(0).link <= i_link(0);
i_dbg.cl(0).fval <= i_fval(0);
i_dbg.cl(0).lval <= i_lval(0);
i_dbg.cl(0).fval_edge0 <= tst_fval_edge0(0);
i_dbg.cl(0).fval_edge1 <= tst_fval_edge1(0);
--i_dbg.cl(0).lval_edge0 <= tst_lval_edge0(0);
--i_dbg.cl(0).lval_edge1 <= tst_lval_edge1(0);
i_dbg.cl(0).rxbyte(0) <= i_rxbyte((8 * (0 + 1)) - 1 downto (8 * 0));
i_dbg.cl(0).rxbyte(1) <= i_rxbyte((8 * (1 + 1)) - 1 downto (8 * 1));
i_dbg.cl(0).rxbyte(2) <= i_rxbyte((8 * (2 + 1)) - 1 downto (8 * 2));
i_dbg.cl(0).clk_synval <= tst_cl_clk_synval((7 * (0 + 1)) - 1 downto (7 * 0));

i_dbg.cl(1).clk <= i_rxclk(1);
i_dbg.cl(1).link <= i_link(1);
i_dbg.cl(1).fval <= i_fval(1);
i_dbg.cl(1).lval <= i_lval(1);
i_dbg.cl(1).fval_edge0 <= tst_fval_edge0(1);
i_dbg.cl(1).fval_edge1 <= tst_fval_edge1(1);
--i_dbg.cl(1).lval_edge0 <= tst_lval_edge0(1);
--i_dbg.cl(1).lval_edge1 <= tst_lval_edge1(1);
i_dbg.cl(1).rxbyte(0) <= i_rxbyte((8 * (3 + 1)) - 1 downto (8 * 3));
i_dbg.cl(1).rxbyte(1) <= i_rxbyte((8 * (4 + 1)) - 1 downto (8 * 4));
i_dbg.cl(1).rxbyte(2) <= i_rxbyte((8 * (5 + 1)) - 1 downto (8 * 5));
i_dbg.cl(1).clk_synval <= tst_cl_clk_synval((7 * (1 + 1)) - 1 downto (7 * 1));

i_dbg.cl(2).clk <= i_rxclk(2);
i_dbg.cl(2).link <= i_link(2);
i_dbg.cl(2).fval <= i_fval(2);
i_dbg.cl(2).lval <= i_lval(2);
i_dbg.cl(2).fval_edge0 <= tst_fval_edge0(2);
i_dbg.cl(2).fval_edge1 <= tst_fval_edge1(2);
--i_dbg.cl(2).lval_edge0 <= tst_lval_edge0(2);
--i_dbg.cl(2).lval_edge1 <= tst_lval_edge1(2);
i_dbg.cl(2).rxbyte(0) <= i_rxbyte((8 * (6 + 1)) - 1 downto (8 * 6));
i_dbg.cl(2).rxbyte(1) <= i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));
i_dbg.cl(2).rxbyte(2) <= i_rxbyte((8 * (7 + 1)) - 1 downto (8 * 7));
i_dbg.cl(2).clk_synval <= tst_cl_clk_synval((7 * (2 + 1)) - 1 downto (7 * 2));

i_dbg.cam.bufpkt_empty <= i_bufpkt_empty;
i_dbg.cam.bufpkt_rd <= i_bufpkt_rd;
i_dbg.cam.bufpkt_do <= i_bufpkt_do;
i_dbg.cam.vpkt_err <= i_vpkt_tst_out(0);
i_dbg.cam.fval_edge0 <= tst_fval_t_edge0;
i_dbg.cam.fval_edge1 <= tst_fval_t_edge1;
i_dbg.cam.fval <= i_fval(0);
i_dbg.cam.lval <= i_lval(0);


process(i_link_total, i_rxclk(0))
begin
if (i_link_total = '0') then
  sr_btn <= (others => '0');
  i_restart <= '0';
elsif rising_edge(i_rxclk(0)) then
  sr_btn <= p_in_tst(0) & sr_btn(0 to 1);
  i_restart <= sr_btn(1) and (not sr_btn(2));
end if;
end process;


gen_tst0 : for i in 0 to (G_CL_CHCOUNT - 1) generate begin
process(i_link_total, i_rxclk(i))
begin
if (i_link_total = '0') then
  sr_fval(i) <= (others => '0');
  sr_lval(i) <= (others => '0');

  tst_fval_edge0(i) <= '0';
  tst_fval_edge1(i) <= '0';
--  tst_lval_edge0(i) <= '0';
--  tst_lval_edge1(i) <= '0';

elsif rising_edge(i_rxclk(i)) then

  sr_fval(i) <= i_fval(i) & sr_fval(i)(0 to 0);
  sr_lval(i) <= i_lval(i) & sr_lval(i)(0 to 0);

  tst_fval_edge0(i) <= sr_fval(i)(0) and (not sr_fval(i)(1));
  tst_fval_edge1(i) <= (not sr_fval(i)(0)) and sr_fval(i)(1);

--  tst_lval_edge0(i) <= sr_lval(i)(0) and (not sr_lval(i)(1));
--  tst_lval_edge1(i) <= (not sr_lval(i)(0)) and sr_lval(i)(1);

end if;
end process;
end generate gen_tst0;

process(i_link_total, p_in_bufpkt_rdclk)
begin
if (i_link_total = '0') then
  sr_fval_t <= (others => '0');
  sr_lval_t <= (others => '0');

  tst_fval_t_edge0 <= '0';
  tst_fval_t_edge1 <= '0';
--  tst_lval_t_edge0 <= '0';
--  tst_lval_t_edge1 <= '0';

elsif rising_edge(p_in_bufpkt_rdclk) then

  sr_fval_t <= i_fval(0) & sr_fval_t(0 to 0);
  sr_lval_t <= i_lval(0) & sr_lval_t(0 to 0);

  tst_fval_t_edge0 <= sr_fval_t(0) and (not sr_fval_t(1));
  tst_fval_t_edge1 <= (not sr_fval_t(0)) and sr_fval_t(1);

--  tst_lval_t_edge0 <= sr_lval_t(0) and (not sr_lval_t(1));
--  tst_lval_t_edge1 <= (not sr_lval_t(0)) and sr_lval_t(1);

end if;
end process;


end architecture struct;
