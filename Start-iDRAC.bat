@echo off
cls
:begin

@echo off

:: BatchGotAdmin

REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
	
:Again

cls


set /P drachost="Host: "
set /P dracport="KVM PORT: "
set /p dracuser="Username: "
set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set dracpwd=%%p

IF NOT EXIST "avctKVM.jar" (
ECHO Grabbing avctKVM.jar from host...
powershell -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} ; $WebClient = New-Object System.Net.WebClient ; $WebClient.DownloadFile('https://%drachost%/software/avctKVM.jar','.\avctKVM.jar')"
)

IF NOT EXIST "lib" (
ECHO Creating lib directory
mkdir "lib"
)

IF NOT EXIST ".\lib\avmWinLib.dll" (
  IF NOT EXIST ".\lib\avctVMWin64.zip" (
    IF NOT EXIST ".\lib\avctVMWin64.jar" (
      ECHO Grabbing avctKVMWin64.jar from host...
      powershell -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} ; $WebClient = New-Object System.Net.WebClient ; $WebClient.DownloadFile('https://%drachost%/software/avctVMWin64.jar','.\lib\avctVMWin64.jar')"
    )
    ECHO Renaming avctVMWin64.jar to avctVMWin64.zip
    rename ".\lib\avctVMWin64.jar" avctVMWin64.zip
  )
  ECHO Unzipping avctKVMWin64.zip
  powershell Expand-Archive ".\lib\avctVMWin64.zip" -DestinationPath ".\lib"
  rmdir ".\lib\META-INF" /s /q
  erase ".\lib\avctVMWin64.zip" /q
)

IF NOT EXIST ".\lib\avctKVMIO.dll" (
  IF NOT EXIST ".\lib\avctKVMIOWin64.zip" (
    IF NOT EXIST ".\lib\avctKVMIOWin64.jar" (
      ECHO Grabbing avctKVMIOWin64.jar from host...
      powershell -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} ; $WebClient = New-Object System.Net.WebClient ; $WebClient.DownloadFile('https://%drachost%/software/avctKVMIOWin64.jar','.\lib\avctKVMIOWin64.jar')"
    )
    ECHO Renaming avctKVMIOWin64.jar to avctKVMIOWin64.zip
    rename ".\lib\avctKVMIOWin64.jar" avctKVMIOWin64.zip
  )
  ECHO Unzipping avctKVMIOWin64.zip
  powershell Expand-Archive ".\lib\avctKVMIOWin64.zip" -DestinationPath ".\lib"
  rmdir ".\lib\META-INF" /s /q
  erase ".\lib\avctKVMIOWin64.zip" /q
)

".\jre\bin\java" -cp avctKVM.jar -Djava.library.path=.\lib com.avocent.idrac.kvm.Main ip=%drachost% kmport=%dracport% vport=5900 user=%dracuser% passwd=%dracpwd% apcp=1 version=2 vmprivilege=true "helpurl=https://%drachost%:443/help/contents.html"

:CleanUpFiles

setlocal EnableExtensions EnableDelayedExpansion

set "UserChoice=N"
set /P "UserChoice=Delete Temp Files [Y/N]? "

if /I "!UserChoice!" == "N" endlocal & goto :no_clean
if /I not "!UserChoice!" == "Y" goto :clean
endlocal

:clean

echo "Cleaning up"
pause
RD /S /Q ".\lib"
del /S /Q ".\avctKVM.jar"
exit

:no_clean

echo "Leaving Files"
pause
exit

