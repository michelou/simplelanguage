@echo off

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _TARGET_DIR=%_ROOT_DIR%target

rem ##########################################################################
rem ## Main

if exist "%_TARGET_DIR%\" ( rmdir /s /q "%_TARGET_DIR%"
) else ( echo %_TARGET_DIR% not found.
)

goto end

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
