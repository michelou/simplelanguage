@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for /f "tokens=1,* delims=:" %%i in ('chcp') do set _CODE_PAGE_DEFAULT=%%j
rem make sure we use UTF-8 encoding for console outputs
chcp 65001 1>NUL

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

set _GRAAL_PATH=
set _MVN_PATH=
set _GIT_PATH=

call :graal
if not %_EXITCODE%==0 goto end

call :mvn
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :msvs
rem call :msvs_2019
if not %_EXITCODE%==0 goto end

call :sdk
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
:args
set _HELP=0
set _USE_SDK=1
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    rem if !__N!==0 set _HELP=1
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1
) else if /i "%__ARG%"=="-help" ( set _HELP=1
) else if /i "%__ARG%"=="-nosdk" ( set _USE_SDK=0
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto args_done
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _HELP=%_HELP% _USE_SDK=%_USE_SDK% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -nosdk           don't setup Windows SDK environment ^(SetEnv.cmd^)
echo     -verbose         display environment settings
echo   Subcommands:
echo     help             display this help message
goto :eof

:graal
where /q javac.exe
if %ERRORLEVEL%==0 goto :eof

if defined GRAAL_HOME (
    set _GRAAL_HOME=%GRAAL_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GRAAL_HOME
) else (
    where /q javac.exe
    if !ERRORLEVEL!==0 (
        for /f "delims=" %%i in ('where /f javac.exe') do set _GRAAL_BIN_DIR=%%~dpsi
        for %%f in ("!_GRAAL_BIN_DIR!..") do set _GRAAL_HOME=%%~sf
    ) else (
        set _PATH=C:\opt
        for /f %%f in ('dir /ad /b "!_PATH!\graalvm-ce*" 2^>NUL') do set _GRAAL_HOME=!_PATH!\%%f
    )
    if defined _GRAAL_HOME (
        if %_DEBUG%==1 echo [%_BASENAME%] Using default Graal SDK installation directory !_JDK_HOME!
    )
)
if not exist "%_GRAAL_HOME%\bin\javac.exe" (
    echo Error: javac executable not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem Here we use trailing separator because it will be prepended to PATH
set "_GRAAL_PATH=%_GRAAL_HOME%\bin;"
goto :eof

:mvn
where /q mvn.cmd
if %ERRORLEVEL%==0 goto :eof

if defined MAVEN_HOME (
    set _MVN_HOME=%MAVEN_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable MAVEN_HOME
) else (
    where /q mvn.cmd
    if !ERRORLEVEL!==0 (
        for /f "delims=" %%i in ('where /f mvn.cmd') do set _MVN_BIN_DIR=%%~dpsi
        for %%f in ("!_MVN_BIN_DIR!..") do set _MVN_HOME=%%~sf
    ) else (
        set _PATH=C:\opt
        for /f %%f in ('dir /ad /b "!_PATH!\apache-maven-*" 2^>NUL') do set _MVN_HOME=!_PATH!\%%f
        if defined _MVN_HOME (
            if %_DEBUG%==1 echo [%_BASENAME%] Using default Maven installation directory !_MVN_HOME!
        )
    )
)
if not exist "%_MVN_HOME%\bin\mvn.cmd" (
    echo Error: Maven executable not found ^(%_MVN_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MVN_PATH=;%_MVN_HOME%\bin"
goto :eof

:git
where /q git.exe
if %ERRORLEVEL%==0 goto :eof

if defined GIT_HOME (
    set _GIT_HOME=%GIT_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GIT_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set _GIT_HOME=!__PATH!\%%f
        if not defined _GIT_HOME (
            set __PATH=C:\Progra~1
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set _GIT_HOME=!__PATH!\%%f
        )
    )
    if defined _GIT_HOME (
        if %_DEBUG%==1 echo [%_BASENAME%] Using default Git installation directory !_GIT_HOME!
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo Error: Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\usr\bin"
goto :eof

rem native-image dependency
:msvs
set "_MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio 10.0"
if not exist "%_MSVS_HOME%" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf
set _MSVC_HOME=%_MSVS_HOME%\VC
set __MSVC_ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __MSVC_ARCH=\amd64
set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%"
goto :eof

rem native-image dependency
:msvs_2019
set "_MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"
if not exist "%_MSVS_HOME%" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 2019 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf
set _MSVC_HOME=%_MSVS_HOME%\VC\Tools\MSVC\14.21.27702
set __MSVC_ARCH=\Hostx86\x86
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __MSVC_ARCH=\Hostx64\x64
set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%"
goto :eof

rem native-image dependency
:sdk
set "_SDK_HOME=C:\Program Files\Microsoft SDKs\Windows\v7.1"
if not exist "%_SDK_HOME%" (
    echo Error: Could not find installation directory for Microsoft Windows SDK 7.1 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of WinSDK installation path
for %%f in ("%_SDK_HOME%") do set _SDK_HOME=%%~sf
set __SDK_ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __SDK_ARCH=\x64
set "_SDK_PATH=;%_SDK_HOME%\bin%__SDK_ARCH%"
goto :eof

:clean
for %%f in ("%~dp0") do set __ROOT_DIR=%%~sf
for /f %%i in ('dir /ad /b "%__ROOT_DIR%\" 2^>NUL') do (
    for /f %%j in ('dir /ad /b "%%i\target\scala-*" 2^>NUL') do (
        if %_DEBUG%==1 echo [%_BASENAME%] rmdir /s /q %__ROOT_DIR%%%i\target\%%j\classes 1^>NUL 2^>^&1
        rmdir /s /q %__ROOT_DIR%%%i\target\%%j\classes 1>NUL 2>&1
    )
)
goto :eof

:print_env
set __VERBOSE=%1
set __VERSIONS_LINE1=
set __VERSIONS_LINE2=
set __WHERE_ARGS=
where /q javac.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('javac.exe -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% javac.exe
)
where /q mvn.cmd
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('mvn.cmd -version ^| findstr Apache') do set __VERSIONS_LINE1=%__VERSIONS_LINE1% mvn %%k,
    set __WHERE_ARGS=%__WHERE_ARGS% mvn.cmd
)
where /q git.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1,2,*" %%i in ('git.exe --version') do set __VERSIONS_LINE1=%__VERSIONS_LINE1% git %%k,
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
where /q diff.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,*" %%i in ('diff.exe --version ^| findstr /B diff') do set __VERSIONS_LINE1=%__VERSIONS_LINE1% diff %%l
    set __WHERE_ARGS=%__WHERE_ARGS% diff.exe
)
rem Microsoft Visual Studio 10
where /q cl.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-6,*" %%i in ('cl.exe 2^>^&1 ^| findstr Version') do set __VERSIONS_LINE2=%__VERSIONS_LINE2% cl %%o,
    set __WHERE_ARGS=%__WHERE_ARGS% cl.exe
)
rem Microsoft Windows SDK v7.1
where /q uuidgen.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%f in ('uuidgen.exe /v') do set __VERSIONS_LINE2=%__VERSIONS_LINE2% uuidgen %%i
    set __WHERE_ARGS=%__WHERE_ARGS% uuidgen.exe
)
echo Tool versions:
echo   %__VERSIONS_LINE1%
echo   %__VERSIONS_LINE2%
if %__VERBOSE%==1 (
    rem if %_DEBUG%==1 echo [%_BASENAME%] where %__WHERE_ARGS%
    echo Tool paths:
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if not defined GRAAL_HOME set GRAAL_HOME=%_GRAAL_HOME%
    rem http://www.graalvm.org/docs/graalvm-as-a-platform/implement-language/
    if not defined JAVA_HOME set JAVA_HOME=%_GRAAL_HOME%
    if not defined MAVEN_HOME set MAVEN_HOME=%_MVN_HOME%
    if not %_USE_SDK%==1 (
        if not defined MSVS_HOME set MSVS_HOME=%_MSVS_HOME%
        if not defined MSVC_HOME set MSVC_HOME=%_MSVC_HOME%
        if not defined SDK_HOME set SDK_HOME=%_SDK_HOME%
    )
    set "PATH=%_GRAAL_PATH%%PATH%%_MVN_PATH%%_GIT_PATH%%_MSVS_PATH%%_SDK_PATH%"
    call :print_env %_VERBOSE%
    if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
    rem must be called last
    if %_USE_SDK%==1 (
        timeout /t 2 1>NUL
        cmd.exe /E:ON /V:ON /T:0E /K %_SDK_HOME%\bin\setEnv.cmd
    )
)
