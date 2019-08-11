# <span id="top">SimpleLanguage on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:60px;max-width:100px;">
    <a href="https://www.graalvm.org/"><img style="border:0;" src="https://www.graalvm.org/resources/img/graalvm.png" alt="GraalVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    In the following we describe how to build/run the <b><code><a href="https://github.com/graalvm/simplelanguage">SimpleLanguage</a></code></b> (aka SL) example project on a Windows machine.<br/>In particular we show how to generate both the JVM version and the native version of the SL parser.
  </td>
  </tr>
</table>


## <span id="section_00">Preamble</span>

Let us start with the short path to run the SL parser:

- open a console with the *"Windows SDK 7.1 Command Prompt"* shortcut
- ensure environment variables `JAVA_HOME` and `PATH` are correctly setup
- generate the SL parser with command **`mvn package`**
- run the SL parser, eg. **`sl.bat language\tests\Add.sl`**

Unfortunately the above scenario will fail on a Windows machine unless we complete the current infrastructure (eg. command **`sl.bat`**). 


## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.6](http://maven.apache.org/download.cgi) ([requires Java 7](http://maven.apache.org/docs/history.html))  ([*release notes*](http://maven.apache.org/docs/3.6.1/release-notes.html))
- [GraalVM Community Edition 19.1](https://github.com/oracle/graal/releases) <sup id="anchor_01">[[1]](#footnote_01)</sup> ([*release notes*](https://www.graalvm.org/docs/release-notes/#1911))
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4](https://www.microsoft.com/en-us/download/details.aspx?id=8442) <sup id="anchor_02a">[[2]](#footnote_02)</sup>
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_02b">[[2]](#footnote_02)</sup>

Optionally one may also install the following software:

- [Git 2.22](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.22.0.txt))

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).

For instance our development environment looks as follows (*August 2019*):

<pre style="font-size:80%;">
C:\opt\apache-maven-3.6.1\                            <i>( 10 MB)</i>
C:\opt\graalvm-ce-19.1.1\                             <i>(381 MB)</i>
C:\opt\Git-2.22.0\                                    <i>(271 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).


## Directory structure

We added/modified the following files from the original [**`SimpleLanguage`**](https://github.com/graalvm/simplelanguage) example project:
<pre style="font-size:80%;">
component\clean_component.bat
component\make_component.bat
component\pom.xml                 <i>(modified)</i>
docs\ebnf\SimpleLanguage.ebnf
docs\ebnf\SimpleLanguage.md
launcher\src\main\scripts\sl.bat
native\clean_native.bat
native\make_native.bat
native\pom.xml                    <i>(modified)</i>
build.bat
generate_parser.bat
setenv.bat
sl.bat
WIN.md
</pre>

where

- directory [**`component\`**](component/) contains two additional batch files.
- file [**`docs\ebnf\SimpleLanguage.md`**](docs/ebnf/SimpleLanguage.md)<sup id="anchor_03">[[3]](#footnote_03)</sup> presents the EBNF grammar of the SL language as PNG images.
- file [**`launcher\src\main\scripts\sl.bat`**](launcher/src/main/scripts/sl.bat) is the batch script to be bundled into the SL distribution.
- directory [**`native\`**](native/) contains two additiona batch files.
- file [**`build.bat`**](build.bat) is the batch script for running **`mvn package`** inside or *outside* of the *Windows SDK 7.1 Command Prompt*.
- file [**`generate_parser.bat`**](generate_parser.bat) is the batch script for generating the SL parser source files.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.
- file [**`sl.bat`**](sl.bat) is the batch script for executing the generated SL parser.
- file [**`WIN.md`**](WIN.md) is the Markdown document of this page.

We also define a virtual drive **`S:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst S: %USERPROFILE%\workspace\simplelanguage</b>
> </pre>

In the next section we give a brief description of the added batch files.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`javac.exe`**](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html), [**`mvn.cmd`**](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) or [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019) directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -nosdk      don't setup Windows SDK environment (SetEnv.cmd)
        -verbose    display progress messages
      Subcommands:
        help        display this help message
    </pre>

2. [**`build.bat`**](build.bat) - This batch command provides subcommands such as **`clean`** to delete the generated files (**`target`** directories), **`dist`** to generate the binary distributions (JVM and native versions) and **`parser`** to generate the [ANTLR](https://www.antlr.org/) parser to SL (call to [**`generate_parser.bat`**](generated_parser.bat)).
    > **:mag_right:** Command [**`build.bat`**](build.bat) differs in two ways from command **`mvn package`**:<br/>
    > - it can also be executed *outside* of the *Windows SDK 7.1 Command Prompt*.<br/>
    > - it generates a distribution-ready output (see section [**Usage examples**](#section_04)).

    <pre style="font-size:80%;">
    <b>&gt; build help</b>
    Usage: build { options | subcommands }
      Options:
        -debug      show commands executed by this script
        -native     generate executable (native-image)
        -verbose    display progress messages
      Subcommands:
        clean       delete generated files
        dist        generate binary distribution
        help        display this help message
        parser      generate ANTLR parser for SL
    </pre>

3. [**`generate_parser.bat`**](generate_parser.bat) - This batch command generates the [ANTLR](https://www.antlr.org/) parser from the grammar file [**`SimpleLanguage.g4`**](./language/src/main/java/com/oracle/truffle/sl/parser/SimpleLanguage.g4). Compared to the corresponding shell script [**`generate_parser`**](generate_parser), it also provides subcommand **`clean`** and subcommand **`test`** to run a single test (same as in file [**`.travis.yml`**](.travis.yml)).

    <pre style="font-size:80%;">
    <b>&gt; generate_parser help</b>
    Usage: generate_parser { options | subcommands }
      Options:
        -debug      display commands executed by this script
        -verbose    display progress messages
      Subcommands:
        clean       delete generated files
        help        display this help message
        test        perform test with generated ANTLR parser
    </pre>

4. [**`sl.bat`**](sl.bat) - This batch command performs the same operations as the corresponding shell script [**`sl`**](sl) (called from [Travis job](https://docs.travis-ci.com/user/job-lifecycle/) **`script`** in file [**`.travis.yml`**](.travis.yml)).

5. [**`component\clean_component.bat`**](component/clean_component.bat) and [**`component\make_component.bat`**](component/make_component.bat) - These two batch commands are called from the POM file [**`component\pom.xml`**](component/pom.xml) as their shell equivalents.

6. [**`launcher\src\main\scripts\sl.bat`**](launcher/src/main/scripts/sl.bat) - This batch command is a minimized version of [**`sl.bat`**](sl.bat); command [**`build dist`**](build.bat) does add it to the generated binary distribution (see [**next section**](#section_04)).

7. [**`native\clean_native.bat`**](native/clean_native.bat) and [**`native\make_native.bat`**](native/make_native.bat) - These two batch commands are called from the POM file [**`native\pom.xml`**](native/pom.xml) as their shell equivalents.


## <span id="section_04">Usage examples</span>

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`mvn.cmd`**](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), [**`git.exe`**](https://git-scm.com/docs/git) and [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_222, mvn 3.6.1, git 2.22.0.windows.1, diff 3.7
   cl 16.00.40219.01 for x64, dumpbin 10.00.40219.01, uuidgen v1.01

<b>&gt; where javac mvn</b>
C:\opt\graalvm-ce-19.1.1\bin\javac.exe
C:\opt\apache-maven-3.6.1\bin\mvn
C:\opt\apache-maven-3.6.1\bin\mvn.cmd
</pre>

Command [**`setenv -verbose`**](setenv.bat) also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_222, mvn 3.6.1, git 2.22.0.windows.1, diff 3.7
   cl 16.00.40219.01 for x64, dumpbin 10.00.40219.01, uuidgen v1.01
Tool paths:
   C:\opt\graalvm-ce-19.1.1\bin\javac.exe
   C:\opt\apache-maven-3.6.1\bin\mvn.cmd
   C:\opt\Git-2.22.0\bin\git.exe
   C:\opt\Git-2.22.0\usr\bin\diff.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\dumpbin.exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\x64\Uuidgen.Exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\Uuidgen.Exe
</pre>


Command [**`setenv -nosdk`**](setenv.bat) is aimed at advanced users; we use option **`-nosdk`** to work with a reduced set of environment variables (4 variables in our case) instead of relying on the *"Windows SDK 7.1 Command Prompt"* shortcut (target **`C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd`**) to setup our development environment.

#### `build.bat`

Command [**`build -verbose clean`**](build.bat) deletes all output directories.

<pre style="font-size:80%;">
<b>&gt; build -verbose clean</b>
Delete directory S:\component\target
Delete directory S:\language\target
Delete directory S:\launcher\target
Delete directory S:\native\target
Delete directory S:\target
</pre>

> **:mag_right:** Unlike the other shell scripts [**`component\make_component.sh`**](component/make_component.sh) generates its output directly into directory **`component\`** instead of **`component\target\`**. We changed that behavior: the corresponding batch file [**`component\make_component.bat`**](component/make_component.bat) generates its output into directory **`component\target\`**.

Command [**`build -native -verbose dist`**](build.bat) generates both the JVM version and the native version of our application.

<pre style="font-size:80%;">
<b>&gt; build -verbose -native dist</b>
[INFO] Scanning for projects...
[...]
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO]
[INFO] simplelanguage-parent                                              [pom]
[INFO] simplelanguage                                                     [jar]
[INFO] launcher                                                           [jar]
[INFO] simplelanguage-graalvm-native                                      [pom]
[INFO] simplelanguage-graalvm-component                                   [pom]
[INFO]
[INFO] ------------------< com.oracle:simplelanguage-parent >------------------
[INFO] Building simplelanguage-parent 19.1.1-SNAPSHOT                     [1/5]
[INFO] --------------------------------[ pom ]---------------------------------
[...]
[INFO] --------------< com.oracle:simplelanguage-graalvm-native >--------------
[INFO] Building simplelanguage-graalvm-native 19.1.1-SNAPSHOT             [4/5]
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]
[INFO] --- exec-maven-plugin:1.6.0:exec (make_native) @ simplelanguage-graalvm-native ---
[S:\\native\target\slnative:3432]    classlist:   2,794.53 ms
[S:\\native\target\slnative:3432]        (cap):  23,393.11 ms
[S:\\native\target\slnative:3432]        setup:  24,715.09 ms
[S:\\native\target\slnative:3432]   (typeflow):  13,055.30 ms
[S:\\native\target\slnative:3432]    (objects):  10,122.69 ms
[S:\\native\target\slnative:3432]   (features):   2,000.37 ms
[S:\\native\target\slnative:3432]     analysis:  26,150.04 ms
[S:\\native\target\slnative:3432]     (clinit):     529.91 ms
1349 method(s) included for runtime compilation              
[S:\\native\target\slnative:3432]     universe:   1,655.70 ms
[S:\\native\target\slnative:3432]      (parse):   2,496.46 ms
[S:\\native\target\slnative:3432]     (inline):   3,769.89 ms
[S:\\native\target\slnative:3432]    (compile):  22,064.46 ms
[S:\\native\target\slnative:3432]      compile:  30,115.63 ms
[S:\\native\target\slnative:3432]        image:   2,829.75 ms
[S:\\native\target\slnative:3432]        write:     753.58 ms
[S:\\native\target\slnative:3432]      [total]:  90,272.90 ms
[INFO]     
[INFO] ------------< com.oracle:simplelanguage-graalvm-component >-------------
[INFO] Building simplelanguage-graalvm-component 19.1.1-SNAPSHOT          [5/5]
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]   
[INFO] --- exec-maven-plugin:1.6.0:exec (make_component) @ simplelanguage-graalvm-component ---
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for simplelanguage-parent 19.1.1-SNAPSHOT:
[INFO]
[INFO] simplelanguage-parent .............................. SUCCESS [  0.036 s]
[INFO] simplelanguage ..................................... SUCCESS [ 16.164 s]
[INFO] launcher ........................................... SUCCESS [  0.328 s]
[INFO] simplelanguage-graalvm-native ...................... SUCCESS [01:32 min]
[INFO] simplelanguage-graalvm-component ................... SUCCESS [  0.342 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  01:49 min
[INFO] Finished at: 2019-07-24T08:14:18+02:00
[INFO] ------------------------------------------------------------------------
Copy executable S:\native\target\slnative.exe to directory S:\target\sl\bin
</pre>

> **:mag_right:** Omitting option **`-native`** (which controls the **`SL_BUILD_NATIVE`** environment variable) will skip step 4:
> <pre style="font-size:80%;">
> [...]
> [INFO] --- exec-maven-plugin:1.6.0:exec (make_native) @ simplelanguage-graalvm-native ---
> Skipping the native image build because SL_BUILD_NATIVE is set to false.
> [...]
> </pre>

Output directory is **`target\sl\`**; its structure looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /f target</b>
S:\TARGET
└───sl
    ├───bin
    │       sl.bat
    │       slnative.exe
    │
    └───lib
            antlr4-runtime-4.7.2.jar
            launcher-19.1.1-SNAPSHOT.jar
            simplelanguage-19.1.1-SNAPSHOT.jar
</pre>

> **:mag_right:** As expected the file sizes for the JVM and native versions are very different:
> <pre style="font-size:80%;">
> <b>&gt; where /t /r target\sl\lib *.jar</b>
>    337904   22.07.2019      18:41:46  S:\target\sl\lib\antlr4-runtime-4.7.2.jar
>      4945   24.07.2019      12:53:37  S:\target\sl\lib\launcher-19.1.1-SNAPSHOT.jar
>    339575   24.07.2019      12:53:37  S:\target\sl\lib\simplelanguage-19.1.1-SNAPSHOT.jar
>
> <b>&gt; where /t /r target\sl\bin *.exe</b>
>  26853376   24.07.2019      13:09:57  S:\target\sl\bin\slnative.exe
> </pre>

We can now execute the two versions (JVM and native) of our application:

<pre style="font-size:80%;">
<b>&gt; target\sl\bin\sl.bat language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@3ac42916
7
34
34
34
4000000000003
3000000000004
7000000000000

<b>&gt; target\sl\bin\slnative.exe language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@3d2bb78
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

> **:mag_right:** For instance we can use command [**`dumpbin`**](https://docs.microsoft.com/en-us/cpp/build/reference/dumpbin-reference?view=vs-2019) to display the definitions exported from executable **`slnative.exe`** whose name starts with **`graal_`**:
> <pre style="font-size:80%;">
> <b>&gt; dumpbin /exports target\sl\bin\slnative.exe | awk '/[A-F0-9] graal_/ {print $4}'</b>
> graal_attach_thread
> graal_create_isolate
> graal_detach_thread
> graal_detach_threads
> graal_get_current_thread
> graal_get_isolate
> graal_tear_down_isolate
> </pre>


#### `generate_parser.bat`

Command [**`generate_parser`**](generate_parser.bat) with no arguments produces the lexer/parser files for the [**`SimpleLanguage`**](https://github.com/graalvm/simplelanguage) example.

Output directory is **`target\parser\`**; its structure looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /f target</b>
S:\TARGET
└───parser
    ├───libs
    │       antlr-4.7.2-complete.jar
    │
    └───src
            SimpleLanguage.interp
            SimpleLanguage.tokens
            SimpleLanguageLexer.interp
            SimpleLanguageLexer.java
            SimpleLanguageLexer.tokens
            SimpleLanguageParser.java
</pre>

Command [**`generate_parser test`**](generate_parser.bat) compiles the lexer/parser files from directory **`target\parser\src\`** with source files from [**`language\src\`**](language/src/) and executes the SL main class [**`SLMain`**](launcher/src/main/java/com/oracle/truffle/sl/launcher/SLMain.java). 

Output directory **`target\parser\`** now contains three additional elements:<br/>
- the [argument file](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html#commandlineargfile) **`source_list.txt`**<br/>
- the subdirectory **`classes\**\*.class`**:

<pre style="font-size:80%;">
<b>&gt; tree /f target</b>
S:\TARGET
└───parser
    │   source_list.txt
    │
    ├───classes
    │   ├───com
    │   │   └───oracle
    │   │       └───truffle
    │   │           └───sl
    │   │               │   *.class
    │   │               └─  **/*.class
    │   │
    │   └───META-INF
    │       └───truffle
    │               language
    │
    ├───libs
    │       antlr-4.7.2-complete.jar
    │
    └───src
            SimpleLanguage.interp
            SimpleLanguage.tokens
            SimpleLanguageLexer.interp
            SimpleLanguageLexer.java
            SimpleLanguageLexer.tokens
            SimpleLanguageParser.java
</pre>

Adding option **`-verbose`** to the above command (i.e. [**`generate_parser -verbose test`**](generate_parser.bat)) additionally displays progress messages: 

<pre style="font-size:80%;">
<b>&gt; generate_parser -verbose test</b>
Generate ANTLR parser files into directory S:\target\parser\src
Compile Java source files to directory S:\target\parser\classes
Execute test with SimpleLangage example tests\Add.sl
== running on org.graalvm.polyglot.Engine@e580929
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

Replacing option **`-verbose`** by **`-debug`** in the above command (i.e. [**`generate_parser -debug test`**](generate_parser.bat)) displays the internally executed commands:

<pre style="font-size:80%;">
<b>&gt; generate_parser -debug test</b>
[generate_parser] _DEBUG=1 _TEST=1 _VERBOSE=0
[generate_parser] java.exe -cp S:\target\parser\libs\antlr-4.7.2-complete.jar org.antlr.v4.Tool -package com.oracle.truffle.sl.parser -no-listener S:\language\src\main\java\com\oracle\truffle\sl\parser\SimpleLanguage.g4 -o S:\target\parser\src
[generate_parser] javac.exe -cp ;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\locator.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-api.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-dsl-processor.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-tck.jar;S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes -d "S:\target\parser\classes" @"S:\target\parser\source_list.txt"
[generate_parser] java.exe  -Dtruffle.class.path.append=S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes -cp ;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\locator.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-api.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-dsl-processor.jar;C:\opt\graalvm-ce-19.1.1\jre\lib\truffle\truffle-tck.jar;S:\target\parser\libs\antlr-4.7.2-complete.jar;S:\target\parser\classes com.oracle.truffle.sl.parser.SLMain "S:\language\tests\Add.sl"
== running on org.graalvm.polyglot.Engine@56cbfb61
7
34
34
34
4000000000003
3000000000004
7000000000000
[generate_parser] _EXITCODE=0
</pre>


#### `sl.bat`

<pre style="font-size:80%;">
<b>&gt; sl language\tests\Add.sl</b>
== running on org.graalvm.polyglot.Engine@47d384ee
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

## Footnotes

<a name="footnote_01">[1]</a> [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
<a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is available as Community Edition (CE) and Enterprise Edition (EE): GraalVM CE is based on the <a href="https://adoptopenjdk.net/">OpenJDK 8</a> and <a href="https://www.oracle.com/technetwork/graalvm/downloads/index.html">GraalVM EE</a> is developed on top of the <a href="https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html">Java SE 1.8.0_221</a>.
</p>

<a name="footnote_02">[2]</a> ***2018-09-24*** [↩](#anchor_02a)

<p style="margin:0 0 1em 20px;">
The two Microsoft software listed in the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md#windows-specifics-1">Windows Specifics</a> section of the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md">oracle/graal README</a> file are available for free.<br/>
Okay, that's fine but... what version should we download ? We found the <a href="https://stackoverflow.com/questions/20115186/what-sdk-version-to-download/22987999#22987999">answer</a> (April 2014 !) on StackOverflow:
<pre style="margin:0 0 1em 20px;font-size:80%;">
GRMSDK_EN_DVD.iso is a version for x86 environment.
GRMSDKX_EN_DVD.iso is a version for x64 environment.
GRMSDKIAI_EN_DVD.iso is a version for Itanium environment.
</pre>
</p>
<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see section <a href="#section_01"><b>Project dependencies</b></a>):
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://archive.apache.org/dist/ant/binaries/">apache-maven-3.6.1-bin.zip</a>          <i>(  8 MB)</i>
<a href="https://github.com/oracle/graal/releases/tag/vm-19.1.1">graalvm-ce-windows-amd64-19.1.1.zip</a> <i>(179 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                  <i>(570 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>           <i>(121 MB)</i>
</pre>
</p>

<a name="footnote_03">[3]</a> [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
We generated the PNG images presented in file <a href="docs/ebnf/SimpleLanguage.md"><b><code>docs\ebnf\SimpleLanguage.md</code></b></a> from grammar file <a href="docs/ebnf/SimpleLanguage.ebnf"><b><code>docs\ebnf\SimpleLanguage.ebnf</code></b></a> given as input to the online tool <a href="https://www.bottlecaps.de/rr/ui">Railroad Diagram Generator</a>.
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/August 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>