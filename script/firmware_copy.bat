call C:\\Xilinx\\Vivado\\2015.1\\.\\bin\\vivado.bat -mode batch -source jtag_download.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log