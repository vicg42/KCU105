------------------------------------------------------------------------------
-- Copyright (c) 2012 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: gearbox_4_to_7.vhd
--  /   /        Date Last Modified:  May 30th 2012
-- /___/   /\    Date Created: September 2 2011
-- \   \  /  \
--  \___\/\___\
--
--Device:   7 Series
--Purpose:    multiple 4 bit to 7 bit gearbox
--
--Reference:  XAPP585.pdf
--
--Revision History:
--    Rev 1.0 - First created (nicks)
------------------------------------------------------------------------------
--
--  Disclaimer:
--
--    This disclaimer is not a license and does not grant any rights to the materials
--              distributed herewith. Except as otherwise provided in a valid license issued to you
--              by Xilinx, and to the maximum extent permitted by applicable law:
--              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS,
--              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
--              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR
--              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract
--              or tort, including negligence, or under any other theory of liability) for any loss or damage
--              of any kind or nature related to, arising under or in connection with these materials,
--              including for any direct, or any indirect, special, incidental, or consequential loss
--              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered
--              as a result of any action brought by a third party) even if such damage or loss was
--              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
--  Critical Applications:
--
--    Xilinx products are not designed or intended to be fail-safe, or for use in any application
--    requiring fail-safe performance, such as life-support or safety devices or systems,
--    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
--    or any other applications that could lead to death, personal injury, or severe property or
--    environmental damage (individually and collectively, "Critical Applications"). Customer assumes
--    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only
--    to applicable laws and regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;

library unisim ;
use unisim.vcomponents.all ;

entity gearbox_4_to_7 is generic (
  D       : integer := 8) ;       -- Set the number of inputs
port (
  input_clock   :  in std_logic ;       -- high speed clock input
  output_clock    :  in std_logic ;       -- low speed clock input
  datain      :  in std_logic_vector(D*4-1 downto 0) ;  -- data inputs
  reset     :  in std_logic ;       -- Reset line
  jog     :  in std_logic ;       -- jog input, slips by 4 bits
  dataout     : out std_logic_vector(D*7-1 downto 0)) ;   -- data outputs

end gearbox_4_to_7 ;

architecture arch_gearbox_4_to_7 of gearbox_4_to_7 is

signal  read_addra    : std_logic_vector(3 downto 0) ;
signal  read_addrb    : std_logic_vector(3 downto 0) ;
signal  read_addrc    : std_logic_vector(3 downto 0) ;
signal  write_addr    : std_logic_vector(3 downto 0) ;
signal  read_enable   : std_logic ;
signal  read_enable_dom_ch  : std_logic ;
signal  ramouta     : std_logic_vector(D*4-1 downto 0) ;
signal  ramoutb     : std_logic_vector(D*4-1 downto 0) ;
signal  ramoutc     : std_logic_vector(D*4-1 downto 0) ;
signal  local_reset   : std_logic ;
signal  local_reset_dom_ch  : std_logic ;
signal  mux     : std_logic_vector(1 downto 0) ;
signal  jog_int     : std_logic ;
signal  dummy     : std_logic_vector(D*4-1 downto 0) ;
signal  addra       : std_logic_vector(4 downto 0) ;
signal  addrb       : std_logic_vector(4 downto 0) ;
signal  addrc       : std_logic_vector(4 downto 0) ;
signal  addrd       : std_logic_vector(4 downto 0) ;

begin

process (input_clock) begin       -- generate local sync reset
if input_clock'event and input_clock = '1' then
  if reset = '1' then
    local_reset <= '1' ;
  else
    local_reset <= '0' ;
  end if ;
end if ;
end process ;

process (input_clock) begin
if input_clock'event and input_clock = '1' then     -- Gearbox input - 4 bit data at input clock frequency
  if local_reset = '1' then
    write_addr <= "0000" ;
    read_enable <= '0' ;
  elsif write_addr = "1101" then
    write_addr <= "0000" ;
  else
    write_addr <= write_addr + 1 ;
  end if ;
  if write_addr = "0001" then
    read_enable <= '1' ;
  end if ;
end if ;
end process ;

process (output_clock) begin
if output_clock'event and output_clock = '1' then     -- Gearbox output - 10 bit data at output clock frequency
  read_enable_dom_ch <= read_enable ;
  local_reset_dom_ch <= local_reset ;
  if local_reset_dom_ch = '1' or read_enable_dom_ch = '0' then
    read_addra <= "0000" ;
    read_addrb <= "0001" ;
    read_addrc <= "0010" ;
    jog_int <= jog ;
  else
    case jog_int is
    when '0' =>
      case (read_addra) is
        when X"0"   => read_addra <= X"1" ; read_addrb <= X"2" ; read_addrc <= X"3" ; mux <= "01" ;
        when X"1"   => read_addra <= X"3" ; read_addrb <= X"4" ; read_addrc <= X"5" ; mux <= "10" ;
        when X"3"   => read_addra <= X"5" ; read_addrb <= X"6" ; read_addrc <= X"7" ; mux <= "11" ;
        when X"5"   => read_addra <= X"7" ; read_addrb <= X"8" ; read_addrc <= X"9" ; mux <= "00" ;
        when X"7"   => read_addra <= X"8" ; read_addrb <= X"9" ; read_addrc <= X"A" ; mux <= "01" ;
        when X"8"   => read_addra <= X"A" ; read_addrb <= X"B" ; read_addrc <= X"C" ; mux <= "10" ;
        when X"A"   => read_addra <= X"C" ; read_addrb <= X"D" ; read_addrc <= X"D" ; mux <= "11" ; jog_int <= jog ;
        when others => read_addra <= X"0" ; read_addrb <= X"1" ; read_addrc <= X"2" ; mux <= "00" ;
        end case ;
    when others =>
      case (read_addra) is
        when X"1"   => read_addra <= X"2" ; read_addrb <= X"3" ; read_addrc <= X"4" ; mux <= "01" ;
        when X"2"   => read_addra <= X"4" ; read_addrb <= X"5" ; read_addrc <= X"6" ; mux <= "10" ;
        when X"4"   => read_addra <= X"6" ; read_addrb <= X"7" ; read_addrc <= X"8" ; mux <= "11" ;
        when X"6"   => read_addra <= X"8" ; read_addrb <= X"9" ; read_addrc <= X"A" ; mux <= "00" ;
        when X"8"   => read_addra <= X"9" ; read_addrb <= X"A" ; read_addrc <= X"B" ; mux <= "01" ;
        when X"9"   => read_addra <= X"B" ; read_addrb <= X"C" ; read_addrc <= X"D" ; mux <= "10" ;
        when X"B"   => read_addra <= X"D" ; read_addrb <= X"0" ; read_addrc <= X"1" ; mux <= "11" ; jog_int <= jog ;
        when others => read_addra <= X"1" ; read_addrb <= X"2" ; read_addrc <= X"3" ; mux <= "00" ;
      end case ;
    end case ;
  end if ;
end if ;
end process ;

loop0 : for i in 0 to D-1 generate

process (output_clock) begin
if output_clock'event and output_clock = '1' then
  case mux is
  when "00"   =>  dataout(7*i+6 downto 7*i) <=                               ramoutb(4*i+2 downto 4*i+0) & ramouta(4*i+3 downto 4*i+0) ;
  when "01"   =>  dataout(7*i+6 downto 7*i) <= ramoutc(4*i+1 downto 4*i+0) & ramoutb(4*i+3 downto 4*i+0) & ramouta(4*i+3) ;
  when "10"   =>  dataout(7*i+6 downto 7*i) <= ramoutc(4*i+0)              & ramoutb(4*i+3 downto 4*i+0) & ramouta(4*i+3 downto 4*i+2) ;
  when others =>  dataout(7*i+6 downto 7*i) <=                               ramoutb(4*i+3 downto 4*i+0) & ramouta(4*i+3 downto 4*i+1) ;
  end case ;
end if ;
end process ;

end generate ;

-- Data gearboxes

loop1 : for i in 0 to D*2-1 generate

ram_inst : RAM32M port map (
  DOA => ramouta(2*i+1 downto 2*i),
  DOB => ramoutb(2*i+1 downto 2*i),
  DOC     => ramoutc(2*i+1 downto 2*i),
  DOD     => dummy(2*i+1 downto 2*i),
  ADDRA => addra,
  ADDRB => addrb,
  ADDRC   => addrc,
  ADDRD   => addrd,
  DIA => datain(2*i+1 downto 2*i),
  DIB => datain(2*i+1 downto 2*i),
  DIC     => datain(2*i+1 downto 2*i),
  DID     => dummy(2*i+1 downto 2*i),
  WE  => '1',
  WCLK  => input_clock);

end generate ;

addra <= '0' & read_addra ;
addrb <= '0' & read_addrb ;
addrc <= '0' & read_addrc ;
addrd <= '0' & write_addr ;

end arch_gearbox_4_to_7 ;
