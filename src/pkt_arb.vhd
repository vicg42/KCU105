-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 12.01.2016 15:54:04
-- Module Name : pkt_arb
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
--library work;
--use work.reduce_pack.all;

entity pkt_arb is
generic(
G_AXI_DWIDTH : natural := 64;
G_CHCOUNT : natural := 0
);
port(
--------------------------------------
--ETH <- USR TXBUF
--------------------------------------
p_in_txusr_axi_tdata   : in   std_logic_vector((G_AXI_DWIDTH * G_CHCOUNT) - 1 downto 0);
p_out_txusr_axi_tready : out  std_logic_vector(G_CHCOUNT - 1 downto 0);
p_in_txusr_axi_tvalid  : in   std_logic_vector(G_CHCOUNT - 1 downto 0);
p_out_txusr_axi_done   : out  std_logic_vector(G_CHCOUNT - 1 downto 0);

----------------------------
--TO ETH_MAC
----------------------------
p_out_txeth_axi_tdata   : out  std_logic_vector(G_AXI_DWIDTH - 1 downto 0);
p_in_txeth_axi_tready   : in   std_logic;
p_out_txeth_axi_tvalid  : out  std_logic;
p_in_txeth_axi_done     : in   std_logic;

------------------------------
----DBG
------------------------------
--p_out_tst : out  std_logic_vector(31 downto 0);
--p_in_tst  : in   std_logic_vector(31 downto 0);

----------------------------
--SYS
----------------------------
p_in_clk : in std_logic;
p_in_rst : in std_logic
);
end entity pkt_arb;

architecture behavioral of pkt_arb is


type TFsm_txarb is (
S_TXCH0_CHK      ,
S_TXCH0_WAIT_DONE,
S_TXCH1_CHK      ,
S_TXCH1_WAIT_DONE,
S_TXCH2_CHK      ,
S_TXCH2_WAIT_DONE
);
signal i_fsm_txarb    : TFsm_txarb;
signal i_txnum        : unsigned(1 downto 0);

constant CI_NUM_NULL : natural := 3;



begin --architecture behavioral


----------------------------
--TO ETH_MAC
----------------------------
p_out_txeth_axi_tdata <= p_in_txusr_axi_tdata((G_AXI_DWIDTH * (0 + 1)) - 1 downto (G_AXI_DWIDTH * 0)) when (i_txnum = TO_UNSIGNED(0, i_txnum'length)) else
                         p_in_txusr_axi_tdata((G_AXI_DWIDTH * (1 + 1)) - 1 downto (G_AXI_DWIDTH * 1)) when (i_txnum = TO_UNSIGNED(1, i_txnum'length)) else
                         p_in_txusr_axi_tdata((G_AXI_DWIDTH * (2 + 1)) - 1 downto (G_AXI_DWIDTH * 2)) when (i_txnum = TO_UNSIGNED(2, i_txnum'length)) else
                         (others => '0');

p_out_txeth_axi_tvalid <= p_in_txusr_axi_tvalid(0) when (i_txnum = TO_UNSIGNED(0, i_txnum'length)) else
                          p_in_txusr_axi_tvalid(1) when (i_txnum = TO_UNSIGNED(1, i_txnum'length)) else
                          p_in_txusr_axi_tvalid(2) when (i_txnum = TO_UNSIGNED(2, i_txnum'length)) else
                          '0';

p_out_txusr_axi_tready(0) <= p_in_txeth_axi_tready when (i_txnum = TO_UNSIGNED(0, i_txnum'length)) else '0';
p_out_txusr_axi_tready(1) <= p_in_txeth_axi_tready when (i_txnum = TO_UNSIGNED(1, i_txnum'length)) else '0';
p_out_txusr_axi_tready(2) <= p_in_txeth_axi_tready when (i_txnum = TO_UNSIGNED(2, i_txnum'length)) else '0';

p_out_txusr_axi_done(0) <= p_in_txeth_axi_done when (i_txnum = TO_UNSIGNED(0, i_txnum'length)) else '0';
p_out_txusr_axi_done(1) <= p_in_txeth_axi_done when (i_txnum = TO_UNSIGNED(1, i_txnum'length)) else '0';
p_out_txusr_axi_done(2) <= p_in_txeth_axi_done when (i_txnum = TO_UNSIGNED(2, i_txnum'length)) else '0';


process(p_in_clk)
begin
if rising_edge(p_in_clk) then
if (p_in_rst = '1') then
  i_fsm_txarb <= S_TXCH0_CHK;
  i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);

else
  case i_fsm_txarb is

  when S_TXCH0_CHK =>

    if (p_in_txusr_axi_tvalid(0) = '1') then
      i_txnum <= TO_UNSIGNED(0, i_txnum'length);
      i_fsm_txarb <= S_TXCH0_WAIT_DONE;
    else
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH1_CHK;
    end if;

  when S_TXCH0_WAIT_DONE =>

    if (p_in_txeth_axi_done = '1') then
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH1_CHK;
    end if;


  when S_TXCH1_CHK =>

    if (p_in_txusr_axi_tvalid(1) = '1') then
      i_txnum <= TO_UNSIGNED(1, i_txnum'length);
      i_fsm_txarb <= S_TXCH1_WAIT_DONE;
    else
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH2_CHK;
    end if;

  when S_TXCH1_WAIT_DONE =>

    if (p_in_txeth_axi_done = '1') then
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH1_CHK;
    end if;


  when S_TXCH2_CHK =>

    if (p_in_txusr_axi_tvalid(2) = '1') then
      i_txnum <= TO_UNSIGNED(2, i_txnum'length);
      i_fsm_txarb <= S_TXCH2_WAIT_DONE;
    else
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH0_CHK;
    end if;

  when S_TXCH2_WAIT_DONE =>

    if (p_in_txeth_axi_done = '1') then
      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, i_txnum'length);
      i_fsm_txarb <= S_TXCH0_CHK;
    end if;

  end case;
end if;
end if;
end process;

--process(p_in_clk)
--begin
--if rising_edge(p_in_clk) then
--if (p_in_rst = '1') then
--  i_fsm_txarb <= S_IDLE;
--
--else
--  case i_fsm_txarb is
--
--  when S_TXCH_CHK =>
--
--    if (p_in_txusr_axi_tvalid(0) = '1') then
--      i_txnum <= TO_UNSIGNED(0, 3);
--      i_fsm_txarb <= S_WAIT_DONE;
--
--    elsif (p_in_txusr_axi_tvalid(1) = '1') then
--      i_txnum <= TO_UNSIGNED(1, 3);
--      i_fsm_txarb <= S_WAIT_DONE;
--
--    elsif (p_in_txusr_axi_tvalid(2) = '1') then
--      i_txnum <= TO_UNSIGNED(2, 3);
--      i_fsm_txarb <= S_WAIT_DONE;
--
--    else
--      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, 3);
--    end if;
--
--  when S_WAIT_DONE =>
--
--    if (p_in_txeth_axi_done = '1') then
--      i_txnum <= TO_UNSIGNED(CI_NUM_NULL, 3);
--      i_fsm_txarb <= S_TXCH_CHK;
--    end if;
--
--  end case;
--end if;
--end if;
--end process;

--
----#########################################
----DBG
----#########################################
--p_out_tst(0) <= i_err;



end architecture behavioral;
