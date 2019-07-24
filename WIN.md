# <span id="top">SimpleLanguage on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:60px;max-width:100px;">
    <a href="https://www.graalvm.org/"><img style="border:0;" src="https://www.graalvm.org/resources/img/graalvm.png"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    In the following we describe how to build/run the <b><code><a href="https://github.com/graalvm/simplelanguage">SimpleLanguage</a></code></b> (aka SL) example project on a Windows machine. In particular we generate both the JVM version and the native version of the Java application.
  </td>
  </tr>
</table>

## <span id="section_01">Project dependencies</span>

This project depends on several external software for the **Microsoft Windows** platform:

- [Apache Maven 3.6](http://maven.apache.org/download.cgi) ([requires Java 7](http://maven.apache.org/docs/history.html))  ([*release notes*](http://maven.apache.org/docs/3.6.1/release-notes.html))
- [GraalVM Community Edition 19.1](https://github.com/oracle/graal/releases)  ([*release notes*](https://www.graalvm.org/docs/release-notes/#1911))
- [Microsoft Windows SDK for Windows 7 and .NET Framework 4](https://www.microsoft.com/en-us/download/details.aspx?id=8442) <sup id="anchor_01">[[1]](#footnote_01)</sup>
- [Microsoft Visual C++ 2010 Service Pack 1 Compiler Update for the Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422) <sup id="anchor_01">[[1]](#footnote_01)</sup>

Optionally you may also install the following software:

- [Git 2.22](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.22.0.txt))

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).

For instance our development environment looks as follows (*July 2019*):

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
launcher\src\main\scripts\sl.bat
native\clean_native.bat
native\make_native.bat
native\pom.xml                    <i>(modified)</i>
build.bat
generate_parser.bat
setenv.bat
sl.bat
</pre>

We also define a virtual drive **`W:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst W: %USERPROFILE%\workspace\simplelanguage</b>
> </pre>

In the next section we give a brief description of the added batch files.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`javac.exe`**](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html), [**`scalac.bat`**](https://docs.scala-lang.org/overviews/compiler-options/index.html), [**`dotc.bat`**](bin/0.16/dotc.bat), etc. directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { options | subcommands }
      Options:
        -verbose         display environment settings
      Subcommands:
        help             display this help message
    Tool versions:
       javac 1.8.0_222, mvn 3.6.1, git 2.22.0.windows.1, diff 3.7
       cl 16.00.40219.01 for x64, uuidgen v1.01
    </pre>

2. [**`build.bat`**](build.bat) - This batch command is the most useful script in this project; it provides subcommands such as **`clean`** to delete the generated files (**`target`** directories), **`dist`** to generate the binary distributions (JVM and native versions) and **`parser`** to generate the ANTLR parser to SL (call to [**`generate_parser.bat`**](generated_parser.bat)).

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

3. [**`generate_parser.bat`**](generate_parser.bat) - This batch command generates the ANTLR parser from the grammar file [**`SimpleLanguage.g4`**](./language/src/main/java/com/oracle/truffle/sl/parser/SimpleLanguage.g4).

    <pre style="font-size:80%;">
    <b>&gt; generate_parser help</b>
    Usage: generate_parser { options | subcommands }
      Options:
        -debug      display commands executed by this script
        -verbose    display progress messages
      Subcommands:
        help        display this help message
        test        perform test with generated ANTLR parser
    </pre>

4. [**`sl.bat`**](sl.bat) - This batch command performs the same operations as the corresponding shell script [**`sl`**](sl) (called from [Travis job](https://docs.travis-ci.com/user/job-lifecycle/) **`script`** in file [**`.travis.yml`**](.travis.yml)).


    > **:mag_right:** Batch file [**`launcher\src\main\scripts\sl.bat`**](launcher/src/main/scripts/sl.bat) is a minimalized version of [**`sl.bat`**](sl.bat); command [**`build dist`**](build.bat) does add it to the generated binary distribution.

5. [**`component\clean_component.bat`**](component/clean_component.bat) and [**`component\make_component.bat`**](component/make_component.bat) - These two batch commands are call from the POM file [**`component\pom.xml`**](component/pom.xml).

6. [**`native\clean_native.bat`**](native\clean_native.bat) and [**`native\make_native.bat`**](native\make_native.bat) - These two batch commands are called from the POM file [**`native\pom.xml`**](native/pom.xml).


## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`mvn.cmd`**](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), [**`git.exe`**](https://git-scm.com/docs/git) and [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiling-a-c-cpp-program?view=vs-2019) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_222, mvn 3.6.1, git 2.22.0.windows.1, diff 3.7
   cl 16.00.40219.01 for x64, uuidgen v1.01

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
   cl 16.00.40219.01 for x64, uuidgen v1.01
Tool paths:
   C:\opt\graalvm-ce-19.1.1\bin\javac.exe
   C:\opt\apache-maven-3.6.1\bin\mvn.cmd
   C:\opt\Git-2.22.0\bin\git.exe
   C:\opt\Git-2.22.0\usr\bin\diff.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\x64\Uuidgen.Exe
</pre>

#### `build.bat`

Command [**`build -verbose clean`**](build.bat) deletes all output directories.

<pre style="font-size:80%;">
<b>&gt; build -verbose clean</b>
Delete directory "W:\component\target"
Delete directory "W:\language\target"
Delete directory "W:\launcher\target"
Delete directory "W:\native\target"
Delete directory "W:\target"
</pre>

> **:mag_right:** Unlike the other shell scripts [**`component\make_component.sh`**](component/make_component.sh) generates its output directly into directory **`component\`** instead of **`component\target\`**. We changed that behavior: the corresponding batch file [**`component\make_component.bat`**](component/make_component.bat) generates its output into directory **`component\target\`**.

Command [**`build -native -verbose dist`**](build.bat) generates both the JVM version and the native version of our application.

<pre style="font-size:80%;">
<b>&gt; build -native -verbose dist</b>
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
[W:\\native\target\slnative:3432]    classlist:   2,794.53 ms
[W:\\native\target\slnative:3432]        (cap):  23,393.11 ms
[W:\\native\target\slnative:3432]        setup:  24,715.09 ms
[W:\\native\target\slnative:3432]   (typeflow):  13,055.30 ms
[W:\\native\target\slnative:3432]    (objects):  10,122.69 ms
[W:\\native\target\slnative:3432]   (features):   2,000.37 ms
[W:\\native\target\slnative:3432]     analysis:  26,150.04 ms
[W:\\native\target\slnative:3432]     (clinit):     529.91 ms
1349 method(s) included for runtime compilation              
[W:\\native\target\slnative:3432]     universe:   1,655.70 ms
[W:\\native\target\slnative:3432]      (parse):   2,496.46 ms
[W:\\native\target\slnative:3432]     (inline):   3,769.89 ms
[W:\\native\target\slnative:3432]    (compile):  22,064.46 ms
[W:\\native\target\slnative:3432]      compile:  30,115.63 ms
[W:\\native\target\slnative:3432]        image:   2,829.75 ms
[W:\\native\target\slnative:3432]        write:     753.58 ms
[W:\\native\target\slnative:3432]      [total]:  90,272.90 ms
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
Copy executable W:\native\target\slnative.exe to directory W:\target\sl\bin
</pre>

> **:mag_right:** Omitting option **`-native`** (which controls variable **`SL_BUILD_NATIVE`**) will skip the step 4:
> <pre style="font-size:80%;">
> [...]
> [INFO] --- exec-maven-plugin:1.6.0:exec (make_native) @ simplelanguage-graalvm-native ---
> Skipping the native image build because SL_BUILD_NATIVE is set to false.
> [...]
> </pre>

Output directory is **`target\sl\`**; its structure looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /f target</b>
W:\TARGET
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

> **:mag_right:** 

As expected the file sizes for the JVM and native versions are very different:

<pre style="font-size:80%;">
<b>&gt; where /t /r target\sl\lib *.jar</b>
    337904   22.07.2019      18:41:46  W:\target\sl\lib\antlr4-runtime-4.7.2.jar
      4945   24.07.2019      12:53:37  W:\target\sl\lib\launcher-19.1.1-SNAPSHOT.jar
    339575   24.07.2019      12:53:37  W:\target\sl\lib\simplelanguage-19.1.1-SNAPSHOT.jar

<b>&gt; where /t /r target\sl\bin *.exe</b>
  26853376   24.07.2019      13:09:57  W:\target\sl\bin\slnative.exe
</pre>

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

#### `generate_parser.bat`

Command [**`generate_parser`**](generate_parser.bat) with no arguments produces the lexer/parser files for the [**`SimpleLanguage`**](https://github.com/graalvm/simplelanguage) example.

The output looks as follows:

<pre style="font-size:80%;">
<b>&gt; tree /f target</b>
W:\TARGET
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

Command [**`generate_parser -verbose test`**](generate_parser.bat) generates a test class **`SimpleLanguageMainTest.java`** and compiles/executes it together with the output files from **`target\parser\src\`**.

<pre style="font-size:80%;">
<b>&gt; generate_parser -verbose test</b>
Generate ANTLR parser files into directory W:\target\parser\src
Generate test class SimpleLanguageMainTest.java into directory W:\target\parser\src
Compile Java source files to directory W:\target\parser\classes
Execute test with SimpleLangage example tests\Add.sl
SimpleLanguage Example
== running on org.graalvm.polyglot.Engine@e580929
7
34
34
34
4000000000003
3000000000004
7000000000000
</pre>

Source file **`SimpleLanguageMainTest.java`** <sup id="anchor_02">[[2]](#footnote_02)</sup> is a simplified version of [**`SLMain.java`**](https://github.com/graalvm/simplelanguage/blob/master/launcher/src/main/java/com/oracle/truffle/sl/launcher/SLMain.java) available from the [**`graalvm/simplelanguage`**](https://github.com/graalvm/simplelanguage) project.


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

<a name="footnote_01">[1]</a> ***2018-09-24*** [↩](#anchor_01)

<div style="margin:0 0 1em 20px;">
The two Microsoft software listed in the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md#windows-specifics-1">Windows Specifics</a> section of the <a href="https://github.com/oracle/graal/blob/master/compiler/README.md">oracle/graal README</a> file are available for free.<br/>
Okay, that's fine but... what version should you download ? The <a href="https://stackoverflow.com/questions/20115186/what-sdk-version-to-download/22987999#22987999">answer</a> is:
<pre style="font-size:80%;">
GRMSDK_EN_DVD.iso is a version for x86 environment.
GRMSDKX_EN_DVD.iso is a version for x64 environment.
GRMSDKIAI_EN_DVD.iso is a version for Itanium environment.
</pre>
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
<pre style="font-size:80%;">
apache-maven-3.6.1-bin.zip          <i>(  8 MB)</i>
graalvm-ce-windows-amd64-19.1.1.zip <i>(179 MB)</i>
GRMSDKX_EN_DVD.iso                  <i>(570 MB)</i>
VC-Compiler-KB2519277.exe           <i>(121 MB)</i>
</pre>
</div>

<a name="footnote_02">[2]</a> [↩](#anchor_02)

<div style="margin:0 0 1em 20px;">
The generated source file <b><code>SimpleLanguageMainTest.java</code></b> looks as follows:
<pre style="font-size:80%;">
package com.oracle.truffle.sl.parser;
&nbsp;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
&nbsp;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Source;
import org.graalvm.polyglot.Value;

public final class SimpleLanguageMainTest {
    private static final String SL = "sl";
    &nbsp;
    public static void main(String[] args) throws Exception {
        Map<String, String> options = new HashMap<>();
        &nbsp;
        System.out.println("SimpleLanguage Example");
        Source source = Source.newBuilder(SL, new File(args[0])).build();
        Context context = Context.newBuilder(SL).in(System.in).out(System.out).options(options).build();
        System.out.println("== running on " + context.getEngine());
        Value result = context.eval(source);
        if (context.getBindings(SL).getMember("main") == null) {
            context.close();
            System.err.println("No function main(^) defined in SL source file.");
            System.exit(1);
        }
        if (!result.isNull()) {
            System.out.println(result.toString());
        }
        context.close();
        System.exit(0);
    }
}
</pre>
</div>

***

<!--

## Links

1) xxxxxxxx
   http://cesquivias.github.io/blog/2014/10/13/writing-a-language-in-truffle-part-1-a-simple-slow-interpreter/

2) Java with ANTLR
   https://www.baeldung.com/java-antlr
-->

*[mics](http://lampwww.epfl.ch/~michelou/)/July 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>