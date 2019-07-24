@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _LANGUAGE_DIR=%_ROOT_DIR%language
set _LAUNCHER_DIR=%_ROOT_DIR%launcher
set _NATIVE_DIR=%_ROOT_DIR%native

set _SOURCE_DIR=%_LAUNCHER_DIR%\src\main\scripts

set _TARGET_DIR=%_ROOT_DIR%target
set _TARGET_BIN_DIR=%_TARGET_DIR%\sl\bin
set _TARGET_LIB_DIR=%_TARGET_DIR%\sl\lib

call :args %*
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem ## Main

call :init
if not %_EXITCODE%==0 goto end

if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :dist
    if not !_EXITCODE!==0 goto end
)
if %_PARSER%==1 (
    call :parser
    if not !_EXITCODE!==0 goto end
)
goto :end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output parameter(s): _CLEAN, _DIST, _PARSER, _DEBUG, _NATIVE, _VERBOSE
:args
set _CLEAN=0
set _DIST=0
set _PARSER=0
set _DEBUG=0
set _NATIVE=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 call :help
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( call :help & goto :eof
) else if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="dist" ( set _DIST=1
) else if /i "%__ARG%"=="parser" ( set _PARSER=1
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-native" ( set _NATIVE=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _DIST=%_DIST% _PARSER=%_PARSER% _NATIVE=%_NATIVE% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo Options:
echo   -debug      show commands executed by this script
echo   -native     generate executable ^(native-image^)
echo   -verbose    display progress messages
echo Subcommands:
echo   clean       delete generated files
echo   dist        generate binary distribution
echo   help        display this help message
echo   parser      generate ANTLR parser for SL
goto :eof

rem output parameter(s): _MVN_CMD, MVN_OPTS
:init
if not exist "%MAVEN_HOME%" (
    echo Error: Could not find installation directory for Maven 3 1>&2
    set _EXITCODE=1
    goto :eof
)
set _MVN_CMD=%MAVEN_HOME%\bin\mvn.cmd
set _MVN_OPTS=
goto :eof

:clean
for %%f in ("%_LANGUAGE_DIR%\target" "%_LAUNCHER_DIR%\target" "%_NATIVE_DIR%\target" "%_TARGET_DIR%") do (
    set __DIR=%%~f
    if exist "!__DIR!\" (
        if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "!__DIR!"
        ) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR!"
        )
        rmdir /s /q "!__DIR!"
        if not !ERRORLEVEL!==0 (
            set _EXITCODE=1
            rem let's try removal with next directory
            rem goto :eof
        )
    )
)
goto :eof

:dist
if %_DEBUG%==1 ( set __MVN_OPTS=%_MVN_OPTS%
) else if %_VERBOSE%==1 ( set __MVN_OPTS=%_MVN_OPTS%
) else ( set __MVN_OPTS=--quiet %_MVN_OPTS%
)
call :dist_setenv
if %_DEBUG%==1 echo [%_BASENAME%] call %_MVN_CMD% %__MVN_OPTS% package
call %_MVN_CMD% %__MVN_OPTS% package
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
call :dist_unsetenv
set __LANGUAGE_JAR_FILE=
for %%f in (%_LANGUAGE_DIR%\target\*language*SNAPSHOT.jar) do set __LANGUAGE_JAR_FILE=%%~f
if exist "%__LANGUAGE_JAR_FILE%" (
    if not exist "%_TARGET_LIB_DIR%\" mkdir "%_TARGET_LIB_DIR%\"
    if %_DEBUG%==1 ( echo [%_BASENAME%] copy /y "%__LANGUAGE_JAR_FILE%" "%_TARGET_LIB_DIR%\"
    ) else if %_VERBOSE%== ( echo Copy file %__LANGUAGE_JAR_FILE% to directory %_TARGET_LIB_DIR%
    )
    copy /y "%__LANGUAGE_JAR_FILE%" "%_TARGET_LIB_DIR%\" 1>NUL
) else (
    rem echo Error: Launcher JAR file not found in directory %_LAUNCHER_DIR%\target 1>&2
    rem set _EXITCODE=1
    rem goto :eof
)
set __LAUNCHER_JAR_FILE=
for %%f in (%_LAUNCHER_DIR%\target\launcher*SNAPSHOT.jar) do set __LAUNCHER_JAR_FILE=%%~f
if exist "%__LAUNCHER_JAR_FILE%" (
    if not exist "%_TARGET_LIB_DIR%\" mkdir "%_TARGET_LIB_DIR%\"
    if %_DEBUG%==1 echo [%_BASENAME%] copy /y "%__LAUNCHER_JAR_FILE%" "%_TARGET_LIB_DIR%\"
    copy /y "%__LAUNCHER_JAR_FILE%" "%_TARGET_LIB_DIR%\" 1>NUL
) else (
    echo Error: Launcher JAR file not found in directory %_LAUNCHER_DIR%\target 1>&2
    set _EXITCODE=1
    rem goto :eof
)
set __ANTLR4_JAR_FILE=
for /f "delims=" %%f in ('where /r "%USERPROFILE%\.m2\repository\org\antlr" *.jar') do set __ANTLR4_JAR_FILE=%%~f
if exist "%__ANTLR4_JAR_FILE%" (
    if not exist "%_TARGET_LIB_DIR%\" mkdir "%_TARGET_LIB_DIR%\"
    if %_DEBUG%==1 echo [%_BASENAME%] copy /y "%__ANTLR4_JAR_FILE%" "%_TARGET_LIB_DIR%\"
    copy /y "%__ANTLR4_JAR_FILE%" "%_TARGET_LIB_DIR%\" 1>NUL
) else (
    echo Error: Antlr4 JAR file not found in directory %USERPROFILE%\.m2\repository 1>&2
    set _EXITCODE=1
    rem goto :eof
)
set __SL_CMD=%_SOURCE_DIR%\sl.bat
if exist "%__SL_CMD%" (
    if not exist "%_TARGET_BIN_DIR%\" mkdir "%_TARGET_BIN_DIR%\"
    if %_DEBUG%==1 echo [%_BASENAME%] copy /y "%__SL_CMD%" "%_TARGET_BIN_DIR%\"
    copy /y "%__SL_CMD%" "%_TARGET_BIN_DIR%\" 1>NUL
) else (
    echo Error: SL batch file not found in directory %_SOURCE_DIR% 1>&2
    set _EXITCODE=1
    rem goto :eof
)
if not %_NATIVE%==1 goto dist_done
set __SLNATIVE_CMD=%_NATIVE_DIR%\target\slnative.exe
if exist "%__SLNATIVE_CMD%" (
    if not exist "%_TARGET_BIN_DIR%\" mkdir "%_TARGET_BIN_DIR%\"
    if %_DEBUG%==1 ( echo [%_BASENAME%] copy /y "%__SLNATIVE_CMD%" "%_TARGET_BIN_DIR%\"
    ) else if %_VERBOSE%==1 ( echo Copy executable %__SLNATIVE_CMD% to directory %_TARGET_BIN_DIR%
    )
    copy /y "%__SLNATIVE_CMD%" "%_TARGET_BIN_DIR%\" 1>NUL
) else (
    echo Error: SL executable not found in directory %_NATIVE_DIR%\target 1>&2
    set _EXITCODE=1
    rem goto :eof
)
:dist_done
rem tree /f "%_TARGET_DIR%"
goto :eof

:dist_setenv
set __INCLUDE=
if defined INCLUDE set __INCLUDE=%INCLUDE%
set __LIB=
if defined LIB set __LIB=%LIB%
set __LIBPATH=
if defined LIBPATH set __LIBPATH=%LIBPATH%
set __PATH=
if defined PATH set __PATH=%PATH%
set __SL_BUILD_NATIVE=
if defined SL_BUILD_NATIVE set __SL_BUILD_NATIVE=%SL_BUILD_NATIVE%

set __MSVS_ARCH=
set __NET_ARCH=Framework\v4.0.30319
set __SDK_ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVS_ARCH=\amd64
    set __NET_ARCH=Framework64\v4.0.30319
    set __SDK_ARCH=\x64
)
rem Variables MSVS_HOME, SDK_HOME are defined by setenv.bat
set INCLUDE=%MSVS_HOME%\VC\INCLUDE;%SDK_HOME%\INCLUDE;%SDK_HOME%\INCLUDE\gl
set LIB=%MSVS_HOME%\VC\Lib%__MSVS_ARCH%;%SDK_HOME%\lib%__SDK_ARCH%
set LIBPATH=c:\WINDOWS\Microsoft.NET\%__NET_ARCH%;%MSVS_HOME%\VC\lib%_MSVS_ARCH%
set PATH=c:\WINDOWS\Microsoft.NET\%__NET_ARCH%;%MSVS_HOME%\Common7\IDE;%MSVS_HOME%\Common7\Tools;%MSVS_HOME%\VC\Bin%__MSVS_ARCH%;%SDK_HOME%\Bin%__SDK_ARCH%;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;%MAVEN_HOME%\bin
if %_NATIVE%==1 set SL_BUILD_NATIVE=true
) else ( set SL_BUILD_NATIVE=false
)
if %_DEBUG%==1 (
    echo [%_BASENAME%] -------------------------------------------------------
    echo [%_BASENAME%]  E N V I R O N M E N T   V A R I A B L E S
    echo [%_BASENAME%] -------------------------------------------------------
    echo [%_BASENAME%] INCLUDE=%INCLUDE%
    echo [%_BASENAME%] LIB=%LIB%
    echo [%_BASENAME%] LIBPATH=%LIBPATH%
    echo [%_BASENAME%] SL_BUILD_NATIVE=%SL_BUILD_NATIVE%
)
goto :eof

:dist_unsetenv
if defined __INCLUDE set INCLUDE=%__INCLUDE%
if defined __LIB set LIB=%__LIB%
if defined __LIBPATH set LIBPATH=%__LIBPATH%
if defined __PATH set PATH=%__PATH%
if defined __SL_BUILD_NATIVE set SL_BUILD_NATIVE=%__SL_BUILD_NATIVE%
goto :eof

:parser
set __BATCH_FILE=%_ROOT_DIR%generate_parser.bat
if not exist "%__BATCH_FILE%" (
    echo Error: Batch script 'generate_parser.bat' not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] call %__BATCH_FILE%
) else if %_VERBOSE%==1 ( echo Generate ANTLR parser for SL
)
call "%__BATCH_FILE%"
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
endlocal
