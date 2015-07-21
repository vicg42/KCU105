-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 09.07.2015 13:42:09
-- Module Name : pcie_usr_app.vhd
--
-- Description : pci-express user application
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.vicg_common_pkg.all;
use work.pcie_pkg.all;
use work.prj_def.all;
use work.prj_cfg.all;

entity pcie_usr_app is
generic(
G_DBG : string := "OFF"
);
port(
-------------------------------------------------------
--USR Port
-------------------------------------------------------
p_out_hclk      : out   std_logic;
p_out_gctrl     : out   std_logic_vector(C_HREG_CTRL_LAST_BIT downto 0);--global ctrl

--CTRL user devices
p_out_dev_ctrl  : out   std_logic_vector(C_HREG_DEV_CTRL_LAST_BIT downto 0);
p_out_dev_din   : out   std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);--DEV<-HOST
p_in_dev_dout   : in    std_logic_vector(C_HDEV_DWIDTH - 1 downto 0);--DEV->HOST
p_out_dev_wr    : out   std_logic;
p_out_dev_rd    : out   std_logic;
p_in_dev_status : in    std_logic_vector(C_HREG_DEV_STATUS_LAST_BIT downto 0);
p_in_dev_irq    : in    std_logic_vector(C_HIRQ_COUNT_MAX - 1 downto 0);
p_in_dev_opt    : in    std_logic_vector(C_HDEV_OPTIN_LAST_BIT downto 0);
p_out_dev_opt   : out   std_logic_vector(C_HDEV_OPTOUT_LAST_BIT downto 0);

--DBG
p_out_tst       : out   std_logic_vector(127 downto 0);
p_in_tst        : in    std_logic_vector(127 downto 0);

--------------------------------------
--PCIE_Rx/Tx  Port
--------------------------------------
p_in_pcie_prm  : in  TPCIE_cfgprm;

--Target mode
p_in_reg_adr   : in  std_logic_vector(7 downto 0);
p_out_reg_dout : out std_logic_vector(31 downto 0);
p_in_reg_din   : in  std_logic_vector(31 downto 0);
p_in_reg_wr    : in  std_logic;
p_in_reg_rd    : in  std_logic;

p_in_clk   : in    std_logic;
p_in_rst_n : in    std_logic
);
end entity pcie_usr_app;

architecture behavioral of pcie_usr_app is

signal i_reg_rd           : std_logic;
signal i_reg_bar          : std_logic;
signal i_reg_adr          : unsigned(4 downto 0);

signal v_reg_firmware     : std_logic_vector(C_HREG_FRMWARE_LAST_BIT downto 0);
type TReg is array (1 to 15) of std_logic_vector(31 downto 0);
signal v_reg              : TReg;



begin --architecture behavioral


----------------------------------------------------------------------------------------------
--User registor:
----------------------------------------------------------------------------------------------
v_reg_firmware <= std_logic_vector(TO_UNSIGNED(C_FPGA_FIRMWARE_VERSION, v_reg_firmware'length));

--BAR detector
i_reg_bar <= p_in_reg_adr(7);--x80 - Register Space
i_reg_adr <= UNSIGNED(p_in_reg_adr(6 downto 2));

--Reg Write:
wr : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then
    for i in 1 to (v_reg'length - 1) loop
    v_reg(i) <= (others => '0');
    end loop;

  else

    if p_in_reg_wr = '1' then
      if i_reg_bar = '1' then
          if    i_reg_adr = TO_UNSIGNED(C_HREG_CTRL      , 5) then v_reg(1) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_DMAPRM_ADR, 5) then v_reg(2) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_DMAPRM_LEN, 5) then v_reg(3) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_DEV_CTRL  , 5) then v_reg(4) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_DEV_STATUS, 5) then v_reg(5) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_IRQ       , 5) then v_reg(6) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_MEM_ADR   , 5) then v_reg(7) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_MEM_CTRL  , 5) then v_reg(8) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_FG_FRMRK  , 5) then v_reg(9) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_PCIE      , 5) then v_reg(10) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_FUNC      , 5) then v_reg(11) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_FUNCPRM   , 5) then v_reg(12) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST0      , 5) then v_reg(13) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST1      , 5) then v_reg(14) <= p_in_reg_din;
          elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST2      , 5) then v_reg(15) <= p_in_reg_din;
          end if;
      end if;
    end if;

  end if;
end if;
end process;

--Reg Read:
rd : process(p_in_clk)
  variable txd : std_logic_vector(p_out_reg_dout'range);
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then
    txd := (others => '0');
    p_out_reg_dout <= (others => '0');
    i_reg_rd <= '0';

  else

    txd := (others => '0');

    i_reg_rd <= p_in_reg_rd;

    if i_reg_rd = '1' then
      if i_reg_bar = '1' then
      ----------------------------------------------
      --Register Space:
      ----------------------------------------------
        if i_reg_adr = TO_UNSIGNED(C_HREG_FIRMWARE, 5) then txd := std_logic_vector(RESIZE(UNSIGNED(v_reg_firmware), txd'length));

        elsif i_reg_adr = TO_UNSIGNED(C_HREG_PCIE, 5) then
            txd(C_HREG_PCIE_NEG_LINK_M_RBIT downto C_HREG_PCIE_NEG_LINK_L_RBIT)
                := p_in_pcie_prm.link_width(5 downto 0);

            txd(C_HREG_PCIE_NEG_MAX_PAYLOAD_M_BIT downto C_HREG_PCIE_NEG_MAX_PAYLOAD_L_BIT)
                := p_in_pcie_prm.max_payload(2 downto 0);

            txd(C_HREG_PCIE_NEG_MAX_RD_REQ_M_BIT downto C_HREG_PCIE_NEG_MAX_RD_REQ_L_BIT)
                := p_in_pcie_prm.max_rd_req(2 downto 0);

        elsif i_reg_adr = TO_UNSIGNED(C_HREG_CTRL      , 5) then txd := v_reg(1);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_DMAPRM_ADR, 5) then txd := v_reg(2);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_DMAPRM_LEN, 5) then txd := v_reg(3);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_DEV_CTRL  , 5) then txd := v_reg(4);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_DEV_STATUS, 5) then txd := v_reg(5);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_IRQ       , 5) then txd := v_reg(6);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_MEM_ADR   , 5) then txd := v_reg(7);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_MEM_CTRL  , 5) then txd := v_reg(8);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_FG_FRMRK  , 5) then txd := v_reg(9);

        elsif i_reg_adr = TO_UNSIGNED(C_HREG_FUNC      , 5) then txd := v_reg(11);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_FUNCPRM   , 5) then txd := v_reg(12);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST0      , 5) then txd := v_reg(13);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST1      , 5) then txd := v_reg(14);
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST2      , 5) then txd := v_reg(15);
        end if;

      end if;

      p_out_reg_dout <= txd;

    end if;

  end if;
end if;
end process;




---------------------------------------------------------------------
--DBG
---------------------------------------------------------------------
p_out_hclk      <= '0';
p_out_gctrl     <= (others => '0');

p_out_dev_ctrl  <= (others => '0');
p_out_dev_din   <= (others => '0');
p_out_dev_wr    <= '0';
p_out_dev_rd    <= '0';
p_out_dev_opt   <= (others => '0');

p_out_tst <= (others => '0');


end architecture behavioral;

