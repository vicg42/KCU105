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
--Target mode
p_in_reg_adr   : in    std_logic_vector(7 downto 0);
p_out_reg_dout : out   std_logic_vector(31 downto 0);
p_in_reg_din   : in    std_logic_vector(31 downto 0);
p_in_reg_wr    : in    std_logic;
p_in_reg_rd    : in    std_logic;

p_in_clk   : in    std_logic;
p_in_rst_n : in    std_logic
);
end entity pcie_usr_app;

architecture behavioral of pcie_usr_app is

signal i_reg_rd           : std_logic;
signal i_reg_bar          : std_logic;
signal i_reg_adr          : unsigned(4 downto 0);

signal v_reg_firmware     : std_logic_vector(C_HREG_FRMWARE_LAST_BIT downto 0);
signal v_reg_ctrl         : std_logic_vector(31 downto 0);
signal v_reg_tst0         : std_logic_vector(31 downto 0);
signal v_reg_tst1         : std_logic_vector(31 downto 0);


begin --architecture behavioral


----------------------------------------------------------------------------------------------
--User registor:
----------------------------------------------------------------------------------------------
v_reg_firmware <= std_logic_vector(TO_UNSIGNED(C_FPGA_FIRMWARE_VERSION, v_reg_firmware'length));

--BAR detector
i_reg_bar <= p_in_reg_adr(5);--x80 - Register Space
i_reg_adr <= RESIZE(UNSIGNED(p_in_reg_adr(4 downto 2)), i_reg_adr'length);

--Reg Write:
wr : process(p_in_clk)
begin
if rising_edge(p_in_clk) then
  if p_in_rst_n = '0' then
    v_reg_ctrl <= (others => '0');
    v_reg_tst0 <= (others => '0');
    v_reg_tst1 <= (others => '0');

  else

    if p_in_reg_wr = '1' then
      if i_reg_bar = '1' then
      ----------------------------------------------
      --Register Space:
      ----------------------------------------------
        if i_reg_adr = TO_UNSIGNED(C_HREG_CTRL, 5)  then v_reg_ctrl <= p_in_reg_din;
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST0, 5) then v_reg_tst0 <= p_in_reg_din;
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST1, 5) then v_reg_tst1 <= p_in_reg_din;

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
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_CTRL, 5)  then txd := std_logic_vector(RESIZE(UNSIGNED(v_reg_ctrl), txd'length));
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST0, 5)  then txd := std_logic_vector(RESIZE(UNSIGNED(v_reg_tst0), txd'length));
        elsif i_reg_adr = TO_UNSIGNED(C_HREG_TST1, 5)  then txd := std_logic_vector(RESIZE(UNSIGNED(v_reg_tst1), txd'length));

        end if;

      end if;

      p_out_reg_dout <= txd;

    end if;--if i_reg_rd = '1' then
  end if;
end if;--p_in_rst_n,
end process;--rd




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

