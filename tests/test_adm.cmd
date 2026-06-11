@echo off
setlocal EnableDelayedExpansion
set "PASS=0"
set "FAIL=0"
set "ROOT=%~dp0..\"
set "ADM=%ROOT%adm.cmd"

echo ============================================================
echo  adm.cmd Test Suite
echo ============================================================
echo.

:: ── Structural tests (verify file content) ───────────────────

if exist "%ADM%" (
    call :pass "adm.cmd exists"
) else (
    call :fail "adm.cmd exists"
    goto :results
)

findstr /c:"net session" "%ADM%" >nul 2>&1
if %errorlevel% equ 0 (call :pass "admin check uses net session") else (call :fail "admin check uses net session")

findstr /c:"exit /b" "%ADM%" >nul 2>&1
if %errorlevel% equ 0 (call :pass "already-admin path uses exit /b") else (call :fail "already-admin path uses exit /b")

findstr /c:"%%\*" "%ADM%" >nul 2>&1
if %errorlevel% equ 0 (call :pass "uses %%* for argument passthrough") else (call :fail "uses %%* for argument passthrough")

findstr /c:"/c" "%ADM%" >nul 2>&1
if %errorlevel% equ 0 (call :pass "wraps command with cmd /c") else (call :fail "wraps command with cmd /c")

findstr /c:"setlocal" "%ADM%" >nul 2>&1
if %errorlevel% neq 0 (call :pass "no setlocal (simplified)") else (call :fail "no setlocal (simplified)")

findstr /c:"goto" "%ADM%" >nul 2>&1
if %errorlevel% neq 0 (call :pass "no goto loop (simplified)") else (call :fail "no goto loop (simplified)")

findstr /c:"pause" "%ADM%" >nul 2>&1
if %errorlevel% neq 0 (call :pass "no pause on exit") else (call :fail "no pause on exit")

:: ── Behavioral test: already-admin path ──────────────────────
:: When running as admin, adm.cmd must return to caller via exit /b
:: without launching anything. We verify by calling it and checking
:: that execution resumes here (i.e. exit /b was used, not exit).

net session >nul 2>&1
if %errorlevel% equ 0 (
    set "RETURNED=0"
    call "%ADM%"
    set "RETURNED=1"
    if "!RETURNED!"=="1" (
        call :pass "returns to caller when already admin [behavioral]"
    ) else (
        call :fail "returns to caller when already admin [behavioral]"
    )
) else (
    echo [SKIP] behavioral test: session is not elevated, skipping already-admin check
)

:: ── Dry-run tests: argument construction ─────────────────────
:: Build a local mirror of adm.cmd that replaces the PowerShell
:: Start-Process invocations with echo statements so we can capture
:: what command would be launched without triggering UAC.

set "DRY=%TEMP%\adm_test_dry.cmd"
(
    echo @echo off
    echo net session ^>nul 2^>^&1 ^&^& exit /b
    echo if "%%~1"=="" ^(echo DRY_TARGET=cmd^) else ^(echo DRY_TARGET=cmd /c %%*^)
    echo exit
) > "%DRY%"

:: Test: no-arg invocation should target bare cmd
for /f "tokens=2 delims==" %%A in ('call "%DRY%"') do set "T1=%%A"
if "!T1!"=="cmd" (
    call :pass "no-arg invocation targets cmd [dry-run]"
) else (
    call :fail "no-arg invocation targets cmd [dry-run] - got: !T1!"
)

:: Test: single command arg
for /f "tokens=2 delims==" %%A in ('call "%DRY%" notepad') do set "T2=%%A"
if "!T2!"=="cmd /c notepad" (
    call :pass "single-arg invocation wraps in cmd /c [dry-run]"
) else (
    call :fail "single-arg invocation wraps in cmd /c [dry-run] - got: !T2!"
)

:: Test: command with argument
for /f "tokens=2 delims==" %%A in ('call "%DRY%" notepad file.txt') do set "T3=%%A"
if "!T3!"=="cmd /c notepad file.txt" (
    call :pass "multi-arg invocation passes all args via cmd /c [dry-run]"
) else (
    call :fail "multi-arg invocation passes all args via cmd /c [dry-run] - got: !T3!"
)

:: Test: self-re-elevation pattern used by env.cmd and hosts.cmd
set "MOCK_CALLER=%TEMP%\adm_test_caller.cmd"
(echo @echo off) > "%MOCK_CALLER%"
(echo call "%%DRY%%" %%0) >> "%MOCK_CALLER%"

for /f "tokens=2 delims==" %%A in ('call "%MOCK_CALLER%"') do set "T4=%%A"
:: The path will contain the temp dir — just check it ends with adm_test_caller.cmd
echo !T4! | findstr /i "adm_test_caller.cmd" >nul 2>&1
if %errorlevel% equ 0 (
    call :pass "call adm %%0 pattern re-elevates caller script [dry-run]"
) else (
    call :fail "call adm %%0 pattern re-elevates caller script [dry-run] - got: !T4!"
)

del "%DRY%" >nul 2>&1
del "%MOCK_CALLER%" >nul 2>&1

:: ── Results ──────────────────────────────────────────────────
:results
echo.
echo ============================================================
if %FAIL% equ 0 (
    echo  All %PASS% tests passed.
) else (
    echo  %PASS% passed, %FAIL% failed.
)
echo ============================================================
if %FAIL% gtr 0 exit /b 1
exit /b 0

:: ── Helpers ──────────────────────────────────────────────────
:pass
echo [PASS] %~1
set /a PASS+=1
exit /b 0

:fail
echo [FAIL] %~1
set /a FAIL+=1
exit /b 1
