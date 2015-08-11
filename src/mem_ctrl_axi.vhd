-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 13.02.2015 14:50:12
-- Module Name : mem_ctrl
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.mem_ctrl_pkg.all;
use work.mem_wr_pkg.all;

entity mem_ctrl is
generic(
G_SIM : string:= "OFF"
);
port(
------------------------------------
--USER Port
------------------------------------
p_in_mem       : in    TMemINBank;
p_out_mem      : out   TMemOUTBank;

p_out_status   : out   TMEMCTRL_status;

------------------------------------
--Memory physical interface
------------------------------------
p_out_phymem   : out   TMEMCTRL_pinouts;
p_inout_phymem : inout TMEMCTRL_pininouts;

------------------------------------
--System
------------------------------------
p_out_sys      : out   TMEMCTRL_sysout;
p_in_sys       : in    TMEMCTRL_pinins;
p_in_rst       : in    std_logic
);
end entity mem_ctrl;

architecture synth of mem_ctrl is

type TSAXI_ID_t is array (0 to C_MEM_BANK_COUNT - 1)
                            of std_logic_vector(C_AXIM_IDWIDTH - 1 downto 0);
signal i_saxi_bid : TSAXI_ID_t;
signal i_saxi_rid : TSAXI_ID_t;
signal i_clk      : std_logic_vector(C_MEM_BANK_COUNT - 1 downto 0);
signal i_rst      : std_logic_vector(C_MEM_BANK_COUNT - 1 downto 0);
signal i_aresetn  : std_logic_vector(C_MEM_BANK_COUNT - 1 downto 0) := (others => '1');
signal i_mmcm_locked : std_logic_vector(C_MEM_BANK_COUNT - 1 downto 0);


begin --architecture synth

p_out_sys.clk <= i_clk(0);

gen_bank : for i in 0 to C_MEM_BANK_COUNT - 1 generate

p_out_mem(i).axiw.rid <= std_logic_vector(RESIZE(UNSIGNED(i_saxi_bid(i)), p_out_mem(i).axiw.rid'length));
p_out_mem(i).axir.rid <= std_logic_vector(RESIZE(UNSIGNED(i_saxi_rid(i)), p_out_mem(i).axir.rid'length));
p_out_mem(i).clk <= i_clk(i);
p_out_mem(i).rstn <= i_aresetn(i);

m_mem_core : mem_ctrl_core_axi
port map(
-- AXI Slave Interface:
-- Write Address Ports
c0_ddr4_s_axi_awid    => p_in_mem (i).axiw.aid(C_AXIM_IDWIDTH - 1 downto 0),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_awaddr  => p_in_mem (i).axiw.adr(C_AXI_AWIDTH - 1 downto 0)  ,--: in STD_LOGIC_VECTOR ( 30 downto 0 );
c0_ddr4_s_axi_awlen   => p_in_mem (i).axiw.trnlen                          ,--: in STD_LOGIC_VECTOR ( 7 downto 0 );
c0_ddr4_s_axi_awsize  => p_in_mem (i).axiw.dbus                            ,--: in STD_LOGIC_VECTOR ( 2 downto 0 );
c0_ddr4_s_axi_awburst => p_in_mem (i).axiw.burst                           ,--: in STD_LOGIC_VECTOR ( 1 downto 0 );
c0_ddr4_s_axi_awlock  => p_in_mem (i).axiw.lock                            ,--: in STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_s_axi_awcache => p_in_mem (i).axiw.cache                           ,--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_awprot  => p_in_mem (i).axiw.prot                            ,--: in STD_LOGIC_VECTOR ( 2 downto 0 );
c0_ddr4_s_axi_awqos   => p_in_mem (i).axiw.qos                             ,--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_awvalid => p_in_mem (i).axiw.avalid                          ,--: in STD_LOGIC;
c0_ddr4_s_axi_awready => p_out_mem(i).axiw.aready                          ,--: out STD_LOGIC;
-- Write Data Ports
c0_ddr4_s_axi_wdata   => p_in_mem (i).axiw.data(C_AXIM_DWIDTH - 1 downto 0) ,--: in STD_LOGIC_VECTOR ( 511 downto 0 );
c0_ddr4_s_axi_wstrb   => p_in_mem (i).axiw.dbe(C_AXIM_DWIDTH/8 - 1 downto 0),--: in STD_LOGIC_VECTOR ( 63 downto 0 );
c0_ddr4_s_axi_wlast   => p_in_mem (i).axiw.dlast                            ,--: in STD_LOGIC;
c0_ddr4_s_axi_wvalid  => p_in_mem (i).axiw.dvalid                           ,--: in STD_LOGIC;
c0_ddr4_s_axi_wready  => p_out_mem(i).axiw.wready                           ,--: out STD_LOGIC;
-- Write Response Ports
c0_ddr4_s_axi_bid     => i_saxi_bid(i)(C_AXIM_IDWIDTH - 1 downto 0)      ,--: out STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_bresp   => p_out_mem(i).axiw.resp                          ,--: out STD_LOGIC_VECTOR ( 1 downto 0 );
c0_ddr4_s_axi_bvalid  => p_out_mem(i).axiw.rvalid                        ,--: out STD_LOGIC;
c0_ddr4_s_axi_bready  => p_in_mem (i).axiw.rready                        ,--: in STD_LOGIC;
-- Read Address Ports
c0_ddr4_s_axi_arid    => p_in_mem (i).axir.aid(C_AXIM_IDWIDTH - 1 downto 0),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_araddr  => p_in_mem (i).axir.adr(C_AXI_AWIDTH - 1 downto 0)  ,--: in STD_LOGIC_VECTOR ( 30 downto 0 );
c0_ddr4_s_axi_arlen   => p_in_mem (i).axir.trnlen                          ,--: in STD_LOGIC_VECTOR ( 7 downto 0 );
c0_ddr4_s_axi_arsize  => p_in_mem (i).axir.dbus                            ,--: in STD_LOGIC_VECTOR ( 2 downto 0 );
c0_ddr4_s_axi_arburst => p_in_mem (i).axir.burst                           ,--: in STD_LOGIC_VECTOR ( 1 downto 0 );
c0_ddr4_s_axi_arlock  => p_in_mem (i).axir.lock                            ,--: in STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_s_axi_arcache => p_in_mem (i).axir.cache                           ,--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_arprot  => p_in_mem (i).axir.prot                            ,--: in STD_LOGIC_VECTOR ( 2 downto 0 );
c0_ddr4_s_axi_arqos   => p_in_mem (i).axir.qos                             ,--: in STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_arvalid => p_in_mem (i).axir.avalid                          ,--: in STD_LOGIC;
c0_ddr4_s_axi_arready => p_out_mem(i).axir.aready                          ,--: out STD_LOGIC;
-- Read Data Ports
c0_ddr4_s_axi_rid     => i_saxi_rid(i)(C_AXIM_IDWIDTH - 1 downto 0)        ,--: out STD_LOGIC_VECTOR ( 3 downto 0 );
c0_ddr4_s_axi_rdata   => p_out_mem(i).axir.data(C_AXIM_DWIDTH - 1 downto 0),--: out STD_LOGIC_VECTOR ( 511 downto 0 );
c0_ddr4_s_axi_rresp   => p_out_mem(i).axir.resp                            ,--: out STD_LOGIC_VECTOR ( 1 downto 0 );
c0_ddr4_s_axi_rlast   => p_out_mem(i).axir.dlast                           ,--: out STD_LOGIC;
c0_ddr4_s_axi_rvalid  => p_out_mem(i).axir.dvalid                          ,--: out STD_LOGIC
c0_ddr4_s_axi_rready  => p_in_mem (i).axir.rready                          ,--: in STD_LOGIC;

-- DDR4 Physical Interface
c0_ddr4_act_n    => p_out_phymem  (i).act_n   ,--: out STD_LOGIC;
c0_ddr4_adr      => p_out_phymem  (i).addr    ,--: out STD_LOGIC_VECTOR ( 16 downto 0 );
c0_ddr4_ba       => p_out_phymem  (i).ba      ,--: out STD_LOGIC_VECTOR ( 1 downto 0 );
c0_ddr4_bg       => p_out_phymem  (i).bg      ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_cke      => p_out_phymem  (i).cke     ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_odt      => p_out_phymem  (i).odt     ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_cs_n     => p_out_phymem  (i).cs_n    ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_ck_t     => p_out_phymem  (i).ck_t    ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_ck_c     => p_out_phymem  (i).ck_c    ,--: out STD_LOGIC_VECTOR ( 0 to 0 );
c0_ddr4_reset_n  => p_out_phymem  (i).reset_n ,--: out STD_LOGIC;
c0_ddr4_dm_dbi_n => p_inout_phymem(i).dm_dbi_n,--: inout STD_LOGIC_VECTOR ( 7 downto 0 );
c0_ddr4_dq       => p_inout_phymem(i).dq      ,--: inout STD_LOGIC_VECTOR ( 63 downto 0 );
c0_ddr4_dqs_c    => p_inout_phymem(i).dqs_c   ,--: inout STD_LOGIC_VECTOR ( 7 downto 0 );
c0_ddr4_dqs_t    => p_inout_phymem(i).dqs_t   ,--: inout STD_LOGIC_VECTOR ( 7 downto 0 );

--Status
c0_init_calib_complete => p_out_status.rdy(i),--: out STD_LOGIC;


c0_ddr4_aresetn         => i_aresetn(i)      ,--: in STD_LOGIC;
c0_ddr4_ui_clk_sync_rst => i_rst(i)          ,--: out STD_LOGIC;
c0_ddr4_ui_clk          => i_clk(i)          ,--: out STD_LOGIC;
addn_ui_clkout1         => open              ,--: out STD_LOGIC; --200MHz
addn_ui_clkout2         => open              ,--: out STD_LOGIC; --150MHz
dbg_clk                 => open              ,--: out STD_LOGIC;

--System
c0_sys_clk_p => p_in_sys(i).clk_p ,--: in STD_LOGIC;
c0_sys_clk_n => p_in_sys(i).clk_n ,--: in STD_LOGIC;
sys_rst      => p_in_rst
);

process(i_clk(i))
begin
  if rising_edge(i_clk(i)) then
    i_aresetn(i) <= not i_rst(i);
  end if;
end process;

end generate gen_bank;


end architecture synth;
