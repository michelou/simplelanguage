@echo off
setlocal enabledelayedexpansion

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _TARGET_DIR=%_ROOT_DIR%target

if exist "%_TARGET_DIR%\" ( rmdir /s /q "%_TARGET_DIR%"
) else ( echo %_TARGET_DIR% not found.
)

exit /b %_EXITCODE%
endlocal
