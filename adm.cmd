@echo off
net session >nul 2>&1 && exit /b
if "%~1"=="" (powershell -Command "Start-Process cmd -Verb RunAs") else (powershell -Command "Start-Process cmd -ArgumentList '/c %*' -Verb RunAs")
exit
