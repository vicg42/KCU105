file copy -force ../vv/prj/kcu105.runs/kcu105_impl_1/kcu105_main.bit .
write_cfgmem -force -format MCS -size 32 -interface SPIx8 -loadbit "up 0x00000000 kcu105_main.bit" kcu105_main.mcs
