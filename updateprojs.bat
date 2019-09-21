@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0..") do set _ROOT_DIR=%%~sf

rem file build.sbt
set _GRAALVM_VERSION_OLD="19.2.0"
set _GRAALVM_VERSION_NEW="19.2.0.1"

set _POM_GRAALVM_VERSION_OLD="19.2.0-SNAPSHOT"
set _POM_GRAALVM_VERSION_NEW="19.2.0.1-SNAPSHOT"

rem ##########################################################################
rem ## Main

for %%i in (component language launcher native .) do (
    if %_DEBUG%==1 echo [%_BASENAME%] call :update_project "%_ROOT_DIR%%%i"
    call :update_project "%_ROOT_DIR%%%i"
)
goto end

rem ##########################################################################
rem ## Subroutines

:replace
set __FILE=%~1
set __PATTERN_FROM=%~2
set __PATTERN_TO=%~3

set __PS1_SCRIPT= ^
(Get-Content '%__FILE%') ^| ^
Foreach { $_.Replace('%__PATTERN_FROM%', '%__PATTERN_TO%') } ^| ^
Set-Content '%__FILE%'

if %_DEBUG%==1 echo [%_BASENAME%] powershell -C "%__PS1_SCRIPT%"
powershell -C "%__PS1_SCRIPT%"
if not %ERRORLEVEL%==0 (
    echo Error: Execution of ps1 cmdlet failed 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:update_project
set __PARENT_DIR=%~1
set __N1=0
set __N2=0
echo Parent directory: %__PARENT_DIR%
for %%f in (%__PARENT_DIR%\make_*) do (
    set __FILE=%%f
    if %_DEBUG%==1 echo [%_BASENAME%] call :replace "!__FILE!" "%_GRAALVM_VERSION_OLD%" "%_GRAALVM_VERSION_NEW%"
    call :replace "!__FILE!" "%_GRAALVM_VERSION_OLD%" "%_GRAALVM_VERSION_NEW%"
    set /a __N1+=1
)
for %%f in (%__PARENT_DIR%\pom.xml) do (
    set __FILE=%%f
    if %_DEBUG%==1 echo [%_BASENAME%] call :replace "!__FILE!" "%_POM_GRAALVM_VERSION_OLD%" "%_POM_GRAALVM_VERSION_NEW%"
    call :replace "!__FILE!" "%_POM_GRAALVM_VERSION_OLD%" "%_POM_GRAALVM_VERSION_NEW%"
    set /a __N2+=1
)
echo    Updated %__N1% script files in directory %__PARENT_DIR%
echo    Updated %__N2% POM files in directory %__PARENT_DIR%
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
