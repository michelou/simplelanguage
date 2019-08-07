@echo off
setlocal enabledelayedexpansion

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

call :rmdir "%_TEMP_DIR%"
if not %_EXITCODE%==0 goto end

call :mkdir "%_LANGUAGE_PATH%"
if not %_EXITCODE%==0 goto end

copy /y "%_LANGUAGE_DIR%\target\simplelanguage.jar" "%_LANGUAGE_PATH%\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Error: Missing file simplelanguage.jar 1>&2
    set _EXITCODE=1
    goto end
)
call :mkdir "%_LANGUAGE_PATH%\launcher"
if not %_EXITCODE%==0 goto end
copy /y "%_LAUNCHER_DIR%\target\sl-launcher.jar" "%_LANGUAGE_PATH%\launcher\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Error: Missing file sl-launcher.jar 1>&2
    set _EXITCODE=1
    goto end
)
call :mkdir "%_LANGUAGE_PATH%\bin"
if not %_EXITCODE%==0 goto end
copy /y "%_ROOT_DIR%sl.bat" "%_LANGUAGE_PATH%\bin\" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Error: Missing file sl.bat 1>&2
    set _EXITCODE=1
    goto end
)
if defined _INCLUDE_SLNATIVE (
    copy /y "%_NATIVE_DIR%\slnative.exe" "%_LANGUAGE_PATH%\bin\" 1>NUL
    if not !ERRORLEVEL!==0 (
        echo Error: Missing file slnative.exe 1>&2
        set _EXITCODE=1
        goto end
    )
)

call :mkdir "%_TARGET_DIR%"
if not %_EXITCODE%==0 goto end

rem touch (empty) file
copy /y nul "%_LANGUAGE_PATH%\native-image.properties" 1>NUL
if not %ERRORLEVEL%==0 (
    echo Error: Failed to create file native-image.properties 1>&2
    set _EXITCODE=1
    goto end
)
call :mkdir "%_META_INF_DIR%"
if not %_EXITCODE%==0 goto end
(
    echo Bundle-Name: Simple Language
    echo Bundle-Symbolic-Name: com.oracle.truffle.sl
    echo Bundle-Version: %_GRAALVM_VERSION%
    echo Bundle-RequireCapability: org.graalvm; filter:="(&(graalvm_version=%_GRAALVM_VERSION%)(os_arch=amd64))"
    echo x-GraalVM-Polyglot-Part: True
) > "%_META_INF_DIR%\MANIFEST.MF"

pushd "%_TEMP_DIR%"
call %_JAR_CMD% cfm %_TARGET_DIR%\sl-component.jar %_META_INF_DIR%\MANIFEST.MF .
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto end
)
popd

call :rmdir "%_TEMP_DIR%"
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: 1=directory path
:mkdir
set __DIR=%~1
if exist "%__DIR%" rmdir /s /q "%__DIR%"
mkdir "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem input parameter: 1=directory path
:rmdir
set __DIR=%~1
if not exist "%__DIR%" goto :eof
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
exit /b %_EXITCODE%
endlocal
