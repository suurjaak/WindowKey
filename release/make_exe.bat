:: Creates an executable from AutoHotkey script and compresses it with Mpress.
::
:: @author    Erki Suurjaak
:: @created   08.01.2014
:: @modified  15.01.2014
@echo off
set NAME=WindowKey
set SOURCEDIR=..
set SCRIPTFILE=%SOURCEDIR%\%NAME%.ahk
set EXEFILE=%NAME%.exe
set ICONFILE=%SOURCEDIR%\Icon.ico

if exist %EXEFILE% (echo Removing previous %EXEFILE%. & del "%EXEFILE%")
echo Compiling %EXEFILE%.
start Ahk2Exe.exe /in "%SCRIPTFILE%" /out "%EXEFILE%" /icon "%ICONFILE%"
timeout /t 1 > NUL

if not exist "%EXEFILE%" (echo ERROR: %EXEFILE% not found. & goto :EOF)
for %%F in ("%EXEFILE%") do echo %EXEFILE% uncompressed size: %%~zF.
mpress "%EXEFILE%"
if errorlevel 1 goto :EOF

echo.
for %%F in ("%EXEFILE%") do echo %EXEFILE% compressed size: %%~zF.
