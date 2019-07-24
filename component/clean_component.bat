@echo off

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _JAR_FILE=%_ROOT_DIR%sl-component.jar

rem ##########################################################################
rem ## Main

if exist "%_JAR_FILE%" (
    if %_DEBUG%==1 echo [%_BASENAME%] del "%_JAR_FILE%"
    del "%_JAR_FILE%"
) else (
    echo %_JAR_FILE% not found
)

goto end

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
