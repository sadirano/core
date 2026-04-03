@echo off
powershell -command "(Get-FileHash '%~1').hash | clip"
