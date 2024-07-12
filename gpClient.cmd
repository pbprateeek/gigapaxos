@echo off
set BINFILE=%~f0

if "%BINFILE%"=="" (
  set BINFILE=%0
)

rem Get the directory name (equivalent to `dirname $BINFILE`)
for %%I in ("%BINFILE%") do set BINDIR=%%~dpI

rem Remove the trailing backslash
set BINDIR=%BINDIR:~0,-1%

pushd %BINDIR%\..
set HEAD=%CD%
popd

set VERBOSE=1
set FILESET=

for %%F in ("%HEAD%\jars\*.jar" "%HEAD%\jars\*.class") do (
  if exist %%F (
    for %%I in (%%F) do (
      set "FILESET=!FILESET! %%~fI"
    )
  )
)

set FILESET=%FILESET:~1%
set DEFAULT_GP_CLASSPATH=

rem Iterate over each file in FILESET and concatenate with colons
for %%F in (%FILESET%) do (
  if defined DEFAULT_GP_CLASSPATH (
    set DEFAULT_GP_CLASSPATH=!DEFAULT_GP_CLASSPATH!:%%F
  ) else (
    set DEFAULT_GP_CLASSPATH=%%F
  )
)

set DEV_MODE=1
set CLASSPATH=%DEFAULT_GP_CLASSPATH%

set CONF=conf
set CONFDIR=%HEAD%\%CONF%

:SET_DEFAULT_CONF
set default=%1
set returnValue=
if exist %CONFDIR%\%default% (
  set returnValue=%CONFDIR%\%default%
  goto :EOF
)

for %%I in (%CONFDIR%\%default%) do (
  if exist "%%~fI" (
    rem Read the symbolic link target (requires PowerShell)
    for /f "tokens=*" %%J in ('powershell -command "(Get-Item -Path %%I).Target"') do (
      set linkTarget=%%J
    )
    if exist "!linkTarget!" (
      set returnValue=!linkTarget!
    )
  )
)
goto :EOF

set DEFAULT_LOG_PROPERTIES=logging.properties
call :SET_DEFAULT_CONF %DEFAULT_LOG_PROPERTIES%
set LOG_PROPERTIES=%returnValue%

set DEFAULT_LOG4J_PROPERTIES=log4j.properties
call :SET_DEFAULT_CONF %DEFAULT_LOG4J_PROPERTIES%
set LOG4J_PROPERTIES=%returnValue%

set DEFAULT_GP_PROPERTIES=gigapaxos.properties
call :SET_DEFAULT_CONF %DEFAULT_GP_PROPERTIES%
set GP_PROPERTIES=%returnValue%

call :SET_DEFAULT_CONF "keyStore.jks"
set KEYSTORE=%returnValue%

call :SET_DEFAULT_CONF "trustStore.jks"
set TRUSTSTORE=%returnValue%

set ACTIVE="active"
set RECONFIGURATOR="reconfigurator"

set SSL_OPTIONS= "-Djavax.net.ssl.keyStorePassword=qwerty -Djavax.net.ssl.keyStore=%KEYSTORE% -Djavax.net.ssl.trustStorePassword=qwerty \ -Djavax.net.ssl.trustStore=%TRUSTSTORE%"

set ARGS_EXCEPT_CLASSPATH=

rem Loop through all arguments
:loop
if "%~1"=="" goto endloop
  if "%~1"=="-cp" (
    shift
    shift
  ) else if "%~1"=="-classpath" (
    shift
    shift
  ) else (
    set "ARGS_EXCEPT_CLASSPATH=!ARGS_EXCEPT_CLASSPATH! %~1"
    shift
  )
goto loop

:endloop

rem Trim leading space
set "ARGS_EXCEPT_CLASSPATH=!ARGS_EXCEPT_CLASSPATH:~1!"

rem Initialize CLASSPATH_SUPPLIED
set CLASSPATH_SUPPLIED=

rem Loop through all arguments
:loop
if "%~1"=="" goto endloop
  if "%~1"=="-cp" (
    shift
    set CLASSPATH_SUPPLIED=%~1
    shift
  ) else if "%~1"=="-classpath" (
    shift
    set CLASSPATH_SUPPLIED=%~1
    shift
  ) else (
    shift
  )
goto loop

:endloop

rem Construct the final CLASSPATH
if defined CLASSPATH_SUPPLIED (
  set CLASSPATH=%CLASSPATH_SUPPLIED%;%CLASSPATH%
)


set DEFAULT_CLIENT_ARGS=

rem Loop through all arguments
:loop
if "%~1"=="" goto endloop
  if "%~1"=="-D" (
    shift
  ) else (
    set "DEFAULT_CLIENT_ARGS=!DEFAULT_CLIENT_ARGS! %~1"
    shift
  )
goto loop

:endloop

rem Trim leading space
set "DEFAULT_CLIENT_ARGS=!DEFAULT_CLIENT_ARGS:~1!"

set "GP_PROPERTIES="
for %%A in (%ARGS_EXCEPT_CLASSPATH%) do (
  set "arg=%%A"
  rem Check if the argument matches the pattern -D.*=
  echo !arg! | findstr /r /c:"^-D.*=" >nul
  if !errorlevel! == 0 (
    rem Extract key and value
    for /f "tokens=1,2 delims==" %%i in ("!arg:-D=!") do (
      set "key=%%i"
      set "value=%%j"
    )
    rem Check if the key is gigapaxosConfig
    if "!key!" == "gigapaxosConfig" (
      set "GP_PROPERTIES=!value!"
    )
  )
)

if not defined GP_PROPERTIES (
  goto error
)

if not exist "%GP_PROPERTIES%" (
  goto error
)

goto end

:error
echo Error: Unable to find file %DEFAULT_GP_PROPERTIES% >&2
exit /b 1

:end

set DEFAULT_JVMARGS= "%ENABLE_ASSERTS% -cp %CLASSPATH% -Djava.util.logging.config.file=%LOG_PROPERTIES% -Dlog4j.configuration=log4j.properties -DgigapaxosConfig=%GP_PROPERTIES%"

set "JVM_APP_ARGS=%DEFAULT_JVMARGS% %ARGS_EXCEPT_CLASSPATH%"

set "APP="
for /f "tokens=*" %%A in ('findstr /r /c:"^[ \t]*APPLICATION=" %GP_PROPERTIES%') do (
  set "line=%%A"
  for /f "tokens=2 delims==" %%B in ("!line!") do (
    set "APP=%%B"
  )
)
if "%APP%"=="" (
  set "APP=edu.umass.cs.reconfiguration.examples.noopsimple.NoopApp"
)

set "DEFAULT_CLIENT="
if "%APP%"=="edu.umass.cs.gigapaxos.examples.noop.NoopPaxosApp" if "%DEFAULT_CLIENT_ARGS%"=="" (
  set "DEFAULT_CLIENT=edu.umass.cs.gigapaxos.examples.noop.NoopPaxosAppClient"
) else if "%APP%"=="PQR" if "%DEFAULT_CLIENT_ARGS%"=="" (
  set "DEFAULT_CLIENT=STU"
)





