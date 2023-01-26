@Echo off
REM ==================================
set _PoSh=%systemroot%\System32\WindowsPowerShell\v1.0\Powershell.exe
set _Pdir=%~dp0

%_PoSh% -ExecutionPolicy Unrestricted -NoLogo -File %_Pdir%\PoShMediaNames.ps1 %1 %2 %3 %4 %5 %6 %7 %8 %9

set _PoSh=
set _Pdir=
