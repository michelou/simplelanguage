@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _LANGUAGE_DIR=%_ROOT_DIR%language
set _TARGET_DIR=%_ROOT_DIR%target

set _PARSER_DIR=%_TARGET_DIR%\parser
set _PARSER_CLASSES_DIR=%_PARSER_DIR%\classes
set _PARSER_LIBS_DIR=%_PARSER_DIR%\libs
set _PARSER_SOURCE_DIR=%_PARSER_DIR%\src

set _ANTLR_JAR_NAME=antlr-4.7.2-complete.jar
set _ANTLR_JAR_URL=https://www.antlr.org/download/%_ANTLR_JAR_NAME%
set _ANTLR_JAR_FILE=%_PARSER_LIBS_DIR%\%_ANTLR_JAR_NAME%

set _CURL_CMD=curl.exe
set _CURL_OPTS=
if not %_DEBUG%==1 set _CURL_OPTS=--silent

set _MVN_CMD=mvn.cmd
set _MVN_OPTS=
if not %_DEBUG%==1 set _MVN_OPTS=--quiet

set _JAVA_CMD=java.exe
set _JAVA_OPTS=

set _JAVAC_CMD=javac.exe
set _JAVAC_OPTS=

set _MAIN_CLASS_NAME=SimpleLanguageMainTest
set _G4_FILE=%_LANGUAGE_DIR%\src\main\java\com\oracle\truffle\sl\parser\SimpleLanguage.g4

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

call :init
if not %_EXITCODE%==0 goto end

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVA_CMD% -cp %_ANTLR_JAR_FILE% org.antlr.v4.Tool ... -o %_PARSER_SOURCE_DIR%
) else if %_VERBOSE%==1 ( echo Generate ANTLR parser files into directory %_PARSER_SOURCE_DIR%
)
call "%_JAVA_CMD%" -cp %_ANTLR_JAR_FILE% org.antlr.v4.Tool -package com.oracle.truffle.sl.parser -no-listener %_G4_FILE% -o %_PARSER_SOURCE_DIR%
if not %ERRORLEVEL%==0 (
    echo Error: Generation of ANTLR parser failed 1>&2
    set _EXITCODE=1
    goto end
)

if %_TEST%==1 (
    call :test
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output parameter(s): _DEBUG, _HELP, _TEST, _VERBOSE
:args
set _DEBUG=0
set _HELP=0
set _VERBOSE=0
set _TEST=0
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
) else if /i "%__ARG%"=="test" ( set _TEST=1
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-help" ( set _HELP=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto args_done
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _DEBUG=%_DEBUG% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug    display commands executed by this script
echo     -verbose  display progress messages
echo   Subcommands:
echo     help      display this help message
echo     test      perform test with generated ANTLR parser
goto :eof

:init
if not exist "%_ANTLR_JAR_FILE%" (
    if not exist "%_PARSER_LIBS_DIR%" (
        if %_DEBUG%==1 echo [%_BASENAME%] mkdir "%_PARSER_LIBS_DIR%"
         mkdir "%_PARSER_LIBS_DIR%"
    )
    if %_DEBUG%==1 ( echo [%_BASENAME%] %_CURL_CMD% %_CURL_OPTS% --output %_ANTLR_JAR_FILE% %_ANTLR_JAR_URL%
    ) else if %_VERBOSE%==1 ( echo Download file %_ANTLR_JAR_NAME% from ANTLR website
    )
    call %_CURL_CMD% %_CURL_OPTS% --output %_ANTLR_JAR_FILE% %_ANTLR_JAR_URL%
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
goto :eof

:test
if exist "%_PARSER_CLASSES_DIR%" rmdir /s /q "%_PARSER_CLASSES_DIR%"
mkdir "%_PARSER_CLASSES_DIR%"

if %_VERBOSE%==1 echo Generate test class %_MAIN_CLASS_NAME%.java into directory %_PARSER_SOURCE_DIR%
(
    echo package com.oracle.truffle.sl.parser;
    echo.
    echo import java.io.FileInputStream;
    echo import java.io.InputStream;
    echo.
    echo import org.antlr.v4.runtime.CharStreams;
    echo import org.antlr.v4.runtime.CommonTokenStream;
    echo import org.antlr.v4.runtime.Lexer;
    echo import org.antlr.v4.runtime.TokenStream;
    echo.
    echo import com.oracle.truffle.sl.parser.SimpleLanguageParser.SimplelanguageContext;
    echo.
    echo public final class %_MAIN_CLASS_NAME% {
    echo     public static void main(String[] args^) throws Exception {
    echo         System.out.println("SimpleLanguage Example"^);
    echo.
    echo         InputStream inputStream = new FileInputStream(args[0]^); 
    echo         Lexer lexer = new SimpleLanguageLexer(CharStreams.fromStream(inputStream^)^);
    echo         TokenStream tokenStream = new CommonTokenStream(lexer^);
    echo         SimpleLanguageParser parser = new SimpleLanguageParser(tokenStream^);
    echo         // @SuppressWarnings("unused"^)
    echo         SimplelanguageContext slContext = parser.simplelanguage(^);
    echo    }
    echo }
) > %_PARSER_SOURCE_DIR%\%_MAIN_CLASS_NAME%.txt
(
    echo package com.oracle.truffle.sl.parser;
    echo.
    echo import java.io.File;
    echo import java.util.HashMap;
    echo import java.util.Map;
    echo.
    echo import org.graalvm.polyglot.Context;
    echo import org.graalvm.polyglot.Source;
    echo import org.graalvm.polyglot.Value;
    echo.
    echo public final class %_MAIN_CLASS_NAME% {
    echo     private static final String SL = "sl";
    echo.
    echo     public static void main(String[] args^) throws Exception {
    echo         Map^<String, String^> options = new HashMap^<^>(^);
    echo.
    echo         System.out.println("SimpleLanguage Example"^);
    echo         Source source = Source.newBuilder(SL, new File(args[0]^)^).build(^);
    echo         Context context = Context.newBuilder(SL^).in(System.in^).out(System.out^).options(options^).build(^);
    echo         System.out.println("== running on " + context.getEngine(^)^);
    echo         Value result = context.eval(source^);
    echo         if (context.getBindings(SL^).getMember("main"^) == null^) {
    echo             context.close(^);
    echo             System.err.println("No function main(^) defined in SL source file."^);
    echo             System.exit(1^);
    echo         }
    echo         if (^^!result.isNull(^)^) {
    echo             System.out.println(result.toString(^)^);
    echo         }
    echo         context.close(^);
    echo         System.exit(0^);
    echo     }
    echo }
) > %_PARSER_SOURCE_DIR%\%_MAIN_CLASS_NAME%.java

set __CPATH=
for /f %%f in ('where /r "%JAVA_HOME%\jre\lib\truffle" *.jar') do (
    set __CPATH=!__CPATH!;%%f
)
for /f %%f in ('where /r "%_PARSER_LIBS_DIR%" *.jar') do (
    set __CPATH=!__CPATH!;%%f
)
set __CPATH=%__CPATH%;%_PARSER_CLASSES_DIR%

set __SOURCE_LIST_FILE=%_PARSER_DIR%\source_list.txt
if exist "%__SOURCE_LIST_FILE%" del "%__SOURCE_LIST_FILE%"

for /f %%f in ('where /r "%_LANGUAGE_DIR%\src\main\java" *.java') do (
    set __SOURCE_FILE_NAME=%%~nxf
    if "!__SOURCE_FILE_NAME!"=="SimpleLanguageParser.java" (
         rem ignore
    ) else if "!__SOURCE_FILE_NAME!"=="SimpleLanguageLexer.java" (
        rem ignore
    ) else ( echo %%f>> "%__SOURCE_LIST_FILE%"
    )
)
for /f %%f in ('where /r "%_PARSER_SOURCE_DIR%" *.java') do (
    echo %%f>> "%__SOURCE_LIST_FILE%"
)

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVAC_CMD% -cp %__CPATH% -d "%_PARSER_CLASSES_DIR%" @"%__SOURCE_LIST_FILE%"
) else if %_VERBOSE%==1 ( echo Compile Java source files to directory %_PARSER_CLASSES_DIR%
)
call %_JAVAC_CMD% -cp %__CPATH% -d "%_PARSER_CLASSES_DIR%" @"%__SOURCE_LIST_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
rem see https://github.com/oracle/graal/issues/1474
set __JAVA_OPTS=%_JAVA_OPTS% -Dtruffle.class.path.append=%_ANTLR_JAR_FILE%;%_PARSER_CLASSES_DIR%
if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVA_CMD% %__JAVA_OPTS% -cp %__CPATH% com.oracle.truffle.sl.parser.%_MAIN_CLASS_NAME% "%_LANGUAGE_DIR%\tests\Add.sl"
) else if %_VERBOSE%==1 ( echo Execute test with SimpleLangage example tests\Add.sl
)
call %_JAVA_CMD% %__JAVA_OPTS% -cp %__CPATH% com.oracle.truffle.sl.parser.%_MAIN_CLASS_NAME% "%_LANGUAGE_DIR%\tests\Add.sl"
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
