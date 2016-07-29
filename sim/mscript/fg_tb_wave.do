onerror {resume}
quietly virtual signal -install /fg_tb/m_fg { /fg_tb/m_fg/p_in_vbufi_do(31 downto 0)} vbufi_do_31_0
quietly virtual signal -install /fg_tb/m_fg { /fg_tb/m_fg/p_in_vbufi_do(63 downto 32)} vbufi_do_63_32
quietly virtual signal -install /fg_tb/m_fg { /fg_tb/m_fg/p_in_vbufi_do(95 downto 64)} vbufi_do_95_64
quietly virtual signal -install /fg_tb/m_fg { /fg_tb/m_fg/p_in_vbufi_do(127 downto 96)} vbufi_127_96
quietly WaveActivateNextPane {} 0
add wave -noupdate /fg_tb/i_header
add wave -noupdate /fg_tb/i_vbufi_wrclk
add wave -noupdate /fg_tb/i_vbufi_wr
add wave -noupdate /fg_tb/i_vbufi_di_tsim
add wave -noupdate /fg_tb/i_vbufi_empty
add wave -noupdate /fg_tb/p_in_rst
add wave -noupdate /fg_tb/p_in_clk
add wave -noupdate /fg_tb/m_fg/vbufi_127_96
add wave -noupdate /fg_tb/m_fg/vbufi_do_95_64
add wave -noupdate /fg_tb/m_fg/vbufi_do_63_32
add wave -noupdate /fg_tb/m_fg/vbufi_do_31_0
add wave -noupdate -radix hexadecimal -childformat {{/fg_tb/m_fg/p_in_vbufi_do(127) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(126) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(125) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(124) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(123) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(122) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(121) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(120) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(119) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(118) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(117) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(116) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(115) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(114) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(113) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(112) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(111) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(110) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(109) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(108) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(107) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(106) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(105) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(104) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(103) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(102) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(101) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(100) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(99) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(98) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(97) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(96) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(95) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(94) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(93) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(92) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(91) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(90) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(89) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(88) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(87) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(86) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(85) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(84) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(83) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(82) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(81) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(80) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(79) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(78) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(77) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(76) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(75) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(74) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(73) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(72) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(71) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(70) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(69) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(68) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(67) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(66) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(65) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(64) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(63) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(62) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(61) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(60) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(59) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(58) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(57) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(56) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(55) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(54) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(53) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(52) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(51) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(50) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(49) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(48) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(47) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(46) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(45) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(44) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(43) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(42) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(41) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(40) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(39) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(38) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(37) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(36) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(35) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(34) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(33) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(32) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(31) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(30) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(29) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(28) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(27) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(26) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(25) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(24) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(23) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(22) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(21) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(20) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(19) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(18) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(17) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(16) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(15) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(14) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(13) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(12) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(11) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(10) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(9) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(8) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(7) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(6) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(5) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(4) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(3) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(2) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(1) -radix hexadecimal} {/fg_tb/m_fg/p_in_vbufi_do(0) -radix hexadecimal}} -subitemconfig {/fg_tb/m_fg/p_in_vbufi_do(127) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(126) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(125) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(124) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(123) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(122) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(121) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(120) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(119) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(118) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(117) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(116) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(115) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(114) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(113) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(112) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(111) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(110) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(109) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(108) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(107) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(106) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(105) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(104) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(103) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(102) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(101) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(100) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(99) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(98) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(97) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(96) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(95) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(94) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(93) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(92) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(91) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(90) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(89) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(88) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(87) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(86) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(85) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(84) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(83) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(82) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(81) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(80) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(79) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(78) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(77) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(76) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(75) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(74) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(73) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(72) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(71) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(70) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(69) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(68) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(67) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(66) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(65) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(64) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(63) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(62) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(61) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(60) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(59) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(58) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(57) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(56) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(55) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(54) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(53) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(52) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(51) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(50) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(49) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(48) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(47) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(46) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(45) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(44) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(43) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(42) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(41) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(40) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(39) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(38) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(37) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(36) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(35) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(34) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(33) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(32) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(31) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(30) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(29) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(28) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(27) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(26) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(25) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(24) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(23) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(22) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(21) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(20) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(19) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(18) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(17) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(16) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(15) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(14) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(13) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(12) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(11) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(10) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(9) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(8) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(7) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(6) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(5) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(4) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(3) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(2) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(1) {-height 15 -radix hexadecimal} /fg_tb/m_fg/p_in_vbufi_do(0) {-height 15 -radix hexadecimal}} /fg_tb/m_fg/p_in_vbufi_do
add wave -noupdate /fg_tb/m_fg/p_out_vbufi_rd
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_skp_en
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_vbufi_rden
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_memwr_rden
add wave -noupdate /fg_tb/m_fg/p_in_cfg_adr
add wave -noupdate /fg_tb/m_fg/p_in_cfg_adr_ld
add wave -noupdate /fg_tb/m_fg/p_in_cfg_txdata
add wave -noupdate /fg_tb/m_fg/p_in_cfg_wr
add wave -noupdate /fg_tb/m_fg/i_prm
add wave -noupdate -color {Slate Blue} -itemcolor Gold /fg_tb/m_fg/m_fgwr/i_fsm_fgwr
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_err
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_skp_dcnt
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_pkt_size_byte
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_pixcount_byte
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_mem_start
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_mem_done
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_vch_num
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_pixnum
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_rownum
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_pixcount
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_fr_rowcount
add wave -noupdate /fg_tb/m_fg/m_fgwr/i_mem_adr_out
add wave -noupdate /fg_tb/m_fg/m_fgwr/p_out_frrdy
add wave -noupdate /fg_tb/m_fg/p_out_hdrdy
add wave -noupdate /fg_tb/m_fg/m_fgrd/p_in_hrd_start
add wave -noupdate -color {Slate Blue} -itemcolor Gold /fg_tb/m_fg/m_fgrd/i_fsm_fgrd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3089764 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 155
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {2180573 ps} {2213670 ps}