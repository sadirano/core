@echo off
setlocal EnableDelayedExpansion

set command=%~1
if not defined command set command=cmd
shift
:: Rebuild the argument list so that each argument is properly quoted.
set "args="
:buildArgs
if "%1"=="" goto doneArgs
set "args=%args% %1
shift
goto buildArgs
:doneArgs
if defined args set ArgumentList=-ArgumentList '%args%'

:: Check if running with admin rights by using a command that requires elevation.
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Relaunch this script with elevated rights and pass along the arguments.
    powershell -Command "Start-Process '%command%' %ArgumentList% -Verb RunAs"
    pause
    exit
)
