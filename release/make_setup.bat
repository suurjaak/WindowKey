@echo off
set VERSION=%1%
if "%1" == "" set VERSION=1.0

pushd ..
set SOURCEDIR=%CD%
popd

set DESTFILE=windowkey_%VERSION%_setup.exe
echo Creating installer for WindowKey %VERSION%.
if exist "%DESTFILE%" del "%DESTFILE%"
set NSISDIR=C:\Program Files (x86)\Nullsoft Scriptable Install System
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files\Nullsoft Scriptable Install System
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files (x86)\NSIS
if not exist "%NSISDIR%" set NSISDIR=C:\Program Files\NSIS
"%NSISDIR%\makensis.exe" /DPRODUCT_VERSION=%VERSION% /DSOURCE_DIR="%SOURCEDIR%" "exe_setup.nsi"
echo.
echo Successfully created WindowKey source distribution %DESTFILE%.
goto :EOF

:NOVERSION
echo Error: no version given.
