call %XILINX_VV%\bin\vivado.bat -mode batch -source make_prj.tcl
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log

