@echo off
:: Check if running with admin rights
set command=%1
if not defined command set command=cmd
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Relaunch this script with PowerShell elevation
    powershell -Command "Start-Process '%command%' -Verb runAs"
    exit
)
