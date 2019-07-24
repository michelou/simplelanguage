@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0..") do set _ROOT_DIR=%%~sf

set _LIBS_DIR=%_ROOT_DIR%\lib

if defined JAVACMD ( set _JAVACMD=%JAVACMD%
) else if defined JAVA_HOME ( set _JAVACMD=%JAVA_HOME%\bin\java.exe
) else (
    set _PATH=c:\opt
    for /f %%f in ('dir /ad /b "!_PATH!\graalvm-ce*"') do (
        set _JAVACMD=!_PATH!\%%f\bin\java.exe
    )
    if not defined _JAVACMD (
        set _PATH=c:\Progra~1
        for /f %%f in ('dir /ad /b "!_PATH!\graalvm-ce*"') do (
            set _JAVACMD=!_PATH!\%%f\bin\java.exe
        )
        if not defined _JAVACMD set _JAVACMD=java.exe
    )
)
if %_DEBUG%==1 echo [%_BASENAME%] _JAVACMD=%_JAVACMD%

set _MAIN_CLASS=com.oracle.truffle.sl.launcher.SLMain

set _PROGRAM_ARGS=
set _JAVA_ARGS=

rem ##########################################################################
rem ## Main

for %%i in (%*) do (
    set _ARG=%%i
    if "!_ARG!"=="-debug" (
        set _JAVA_ARGS=!_JAVA_ARGS! -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=y
    ) else if "!_ARG!"=="-dump" (
        set _JAVA_ARGS=!_JAVA_ARGS! -Dgraal.Dump=Truffle:1 -Dgraal.TruffleBackgroundCompilation=false -Dgraal.TraceTruffleCompilation=true -Dgraal.TraceTruffleCompilationDetails=true
    ) else if "!_ARG!"=="-disassemble" (
        set _JAVA_ARGS=!_JAVA_ARGS! -XX:CompileCommand=print,*OptimizedCallTarget.callRoot -XX:CompileCommand=exclude,*OptimizedCallTarget.callRoot -Dgraal.TruffleBackgroundCompilation=false -Dgraal.TraceTruffleCompilation=true -Dgraal.TraceTruffleCompilationDetails=true
    ) else if "!_ARG:~0,2!"=="-J" (
        set _JAVA_ARGS=!_JAVA_ARGS! !_ARG:~2!
    ) else (
        set _PROGRAM_ARGS=!_PROGRAM_ARGS! !_ARG!
    )
)
if not defined _PROGRAM_ARGS (
    echo Error: Program argument expected 1>&2
    set _EXITCODE=1
    goto end
)
set _TRUFFLE_CPATH=
for %%i in (%_LIBS_DIR%\*.jar) do (
    set _JAR_FILE=%%~nxi
    if not "!_JAR_FILE:~0,8!"=="launcher" (
        set _TRUFFLE_CPATH=!_TRUFFLE_CPATH!%%i;
    )
)
set _JAVA_CPATH=
for %%i in (%_LIBS_DIR%\launcher*.jar) do (
    set _JAVA_CPATH=!_JAVA_CPATH!%%i;
)
if not defined _JAVA_CPATH (
    echo Error: Launcher JAR file not found
    set _EXITCODE=1
    goto end
)
if %_DEBUG%==1 echo [%_BASENAME%] %_JAVACMD% !_JAVA_ARGS! -Dtruffle.class.path.append=!_TRUFFLE_CPATH! -cp %_JAVA_CPATH% %_MAIN_CLASS% !_PROGRAM_ARGS!
call %_JAVACMD% !_JAVA_ARGS! -Dtruffle.class.path.append=!_TRUFFLE_CPATH! -cp %_JAVA_CPATH% %_MAIN_CLASS% !_PROGRAM_ARGS!
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto end
)
goto end

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
