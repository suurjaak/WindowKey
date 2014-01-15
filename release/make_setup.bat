:: Creates a setup distribution of AutoHotkey executable using NullSoft
:: Scriptable Install System.
::
:: @author    Erki Suurjaak
:: @created   08.01.2014
:: @modified  15.01.2014
@echo off
set NAME=WindowKey
set EXEFILE=%NAME%.exe
set SOURCEDIR=..
set SCRIPTFILE=%SOURCEDIR%\%NAME%.ahk
if not exist "%EXEFILE%" if exist "make_exe.bat" (
	echo %EXEFILE% missing, calling make_exe.
	call make_exe.bat
)
if not exist "%EXEFILE%" (echo %EXEFILE% not detected, exiting. & goto :EOF)

set VERSIONLINE=""
for /f "tokens=2 delims==""" %%G in ('find "VERSION " %SCRIPTFILE% ^| findstr VERSION') do set VERSIONLINE=%%G
if ERRORLEVEL 0 set VERSION=%VERSIONLINE:~2,-1%
if "%VERSION%" == "" (echo Version not detected, exiting. & goto :EOF)

set DESTFILE=%NAME%_%VERSION%_setup.exe
echo Creating installer for %NAME% %VERSION%.
if exist "%DESTFILE%" (echo Removing previous %DESTFILE%. & del "%DESTFILE%")
set NSISDIR=C:\Program Files (x86)\Nullsoft Scriptable Install System
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files\Nullsoft Scriptable Install System
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files (x86)\NSIS
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files\NSIS
"%NSISDIR%\makensis.exe" /DPRODUCT_VERSION=%VERSION% /DSOURCE_DIR="%SOURCEDIR%" "exe_setup.nsi"
if ERRORLEVEL 1 goto :EOF

echo.
for /f %%F in ('dir /b %DESTFILE%') do set DESTFILE=%%F
if exist "%DESTFILE%" echo Successfully created %NAME% v%VERSION% source distribution %DESTFILE%.
