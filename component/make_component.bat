@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0..") do set _ROOT_DIR=%%~sf\

set _LANGUAGE_DIR=%_ROOT_DIR%language
set _LAUNCHER_DIR=%_ROOT_DIR%launcher
set _NATIVE_DIR=%_ROOT_DIR%native

set _GRAALVM_VERSION=19.1.1

for %%f in ("%~dp0") do set _COMPONENT_DIR=%%~sf

set _TARGET_DIR=%_COMPONENT_DIR%target
set _TEMP_DIR=%_COMPONENT_DIR%temp
set _META_INF_DIR=%_TEMP_DIR%\META-INF
set _LANGUAGE_PATH=%_TEMP_DIR%\jre\languages\sl

set _INCLUDE_SLNATIVE=
if exist "%_NATIVE_DIR%\slnative.exe" (
    set _INCLUDE_SLNATIVE=1
)

if defined JAVA_HOME (
    set _JAR_CMD=%JAVA_HOME%\bin\jar.exe
) else if exist "c:\opt\graalvm-ce-%_GRAALVM_VERSION%\" (
    set _JAR_CMD=c:\opt\graalvm-ce-%_GRAALVM_VERSION%\bin\jar.exe
) else (
    set _JAR_CMD=jar.exe
)
if not exist "%_JAR_CMD%" (
    echo Error: jar executable not found ^(%_JAR_CMD%^) 1>&2
    set _EXITCODE=1
    goto end
)

rem ##########################################################################
rem ## Main

call :rm_temp
if not %_EXITCODE%==0 goto end

mkdir "%_LANGUAGE_PATH%"
copy /y %_LANGUAGE_DIR%\target\simplelanguage.jar "%_LANGUAGE_PATH%\" 1>NUL

mkdir "%_LANGUAGE_PATH%\launcher"
copy /y %_LAUNCHER_DIR%\target\sl-launcher.jar "%_LANGUAGE_PATH%\launcher\" 1>NUL

mkdir "%_LANGUAGE_PATH%\bin"
copy /y %_ROOT_DIR%sl.bat "%_LANGUAGE_PATH%\bin\" 1>NUL

if defined _INCLUDE_SLNATIVE (
    copy /y %_NATIVE_DIR%\slnative.exe "%_LANGUAGE_PATH%\bin\" 1>NUL
)

mkdir "%_TARGET_DIR%" "%_META_INF_DIR%"
(
    echo Bundle-Name: Simple Language
    echo Bundle-Symbolic-Name: com.oracle.truffle.sl
    echo Bundle-Version: %_GRAALVM_VERSION%
    echo Bundle-RequireCapability: org.graalvm; filter:="(&(graalvm_version=%_GRAALVM_VERSION%)(os_arch=amd64))"
    echo x-GraalVM-Polyglot-Part: True
) > "%_META_INF_DIR%\MANIFEST.MF"

pushd "%_TEMP_DIR%"
call %_JAR_CMD% cfm %_TARGET_DIR%\sl-component.jar %_META_INF_DIR%\MANIFEST.MF .
popd

call :rm_temp

goto :end

rem ##########################################################################
rem ## Subroutines

:rm_temp
if not exist "%_TEMP_DIR%" goto :eof
rmdir /s /q "%_TEMP_DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
