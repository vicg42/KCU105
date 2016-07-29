call %XILINX_VV%\bin\vivado.bat -mode batch -source prom_download.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
if exist webtalk_*.backup.jou del /F webtalk_*.backup.jou
if exist webtalk_*.backup.log del /F webtalk_*.backup.log

