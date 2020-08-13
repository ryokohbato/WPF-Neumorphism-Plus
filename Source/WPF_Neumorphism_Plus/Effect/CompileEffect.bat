@echo off
setlocal

set FXC_PATH="C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\fxc.exe"

%FXC_PATH% Effect.fx /T ps_3_0 /Fo Effect.ps

echo.
echo press any key to finish.
pause > nul
