@echo off
powershell -command (Get-FileHash %*).hash | clip
