@echo off
call adm %~f0
start rundll32 sysdm.cpl,EditEnvironmentVariables
