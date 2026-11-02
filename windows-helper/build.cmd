@echo off
rem ShareXF — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
rem Builds bin\sharexf-winhelper.exe with the .NET Framework C# compiler (C# 5 only).
rem AnyCPU: 64-bit on x64 PCs, native on Windows 11 on ARM (it has .NET Framework 4.8.1).
rem Works while ShareXF is running: a running .exe can be renamed, so the new build is swapped
rem in and the app picks it up the next time it starts the helper.
setlocal
set CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe
set BIN=%~dp0bin
rem Bluetooth LE and Wi-Fi Direct (Ble.cs, Wfd.cs) are WinRT: the Windows SDK's Windows.winmd (the one
rem .NET's WinRT bridge is built against; System32\WinMetadata's split files don't work with it).
set UM=
for /d %%d in ("%ProgramFiles(x86)%\Windows Kits\10\UnionMetadata\10.*") do if exist "%%d\Windows.winmd" set UM=%%d
if not defined UM (
  echo The Windows 10/11 SDK is needed ^(Windows Kits\10\UnionMetadata^): install it with Visual Studio Build Tools or the SDK installer.
  exit /b 1
)
set FW=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319
rem ReZume reads browsers' address bars with UI Automation (Activity.cs), WPF's assemblies in the Framework.
set UIA=/r:"%FW%\WPF\UIAutomationClient.dll" /r:"%FW%\WPF\UIAutomationTypes.dll" /r:"%FW%\WPF\WindowsBase.dll"
set WINRT=/r:"%UM%\Windows.winmd" /r:"%FW%\System.Runtime.WindowsRuntime.dll" /r:"%FW%\System.Runtime.dll" ^
  /r:"%FW%\System.Threading.Tasks.dll" /r:"%FW%\System.Runtime.InteropServices.WindowsRuntime.dll"
if not exist "%BIN%" mkdir "%BIN%"
"%CSC%" /nologo /optimize+ /platform:anycpu /target:exe /out:"%BIN%\sharexf-winhelper.new.exe" ^
  /r:System.Web.Extensions.dll /r:System.Windows.Forms.dll /r:System.Drawing.dll %UIA% %WINRT% "%~dp0src\*.cs" || exit /b 1
rem The previous build may still be running (old.exe): then park the current one under another name.
del /q "%BIN%\sharexf-winhelper.old*.exe" 2>nul
set OLD=sharexf-winhelper.old.exe
if exist "%BIN%\%OLD%" set OLD=sharexf-winhelper.old-%RANDOM%.exe
if exist "%BIN%\sharexf-winhelper.exe" ren "%BIN%\sharexf-winhelper.exe" %OLD%
ren "%BIN%\sharexf-winhelper.new.exe" sharexf-winhelper.exe
rem Multi-device's helper (docs/multi-device.md): the same sources with MULTI, several watched sides
rem (CaptureMulti.cs); only windows/mesh starts it. Without MULTI the code above is the one-to-one helper's.
"%CSC%" /nologo /optimize+ /platform:anycpu /target:exe /define:MULTI /out:"%BIN%\sharexf-winhelper-multi.new.exe" ^
  /r:System.Web.Extensions.dll /r:System.Windows.Forms.dll /r:System.Drawing.dll %UIA% %WINRT% "%~dp0src\*.cs" || exit /b 1
del /q "%BIN%\sharexf-winhelper-multi.old*.exe" 2>nul
set OLD=sharexf-winhelper-multi.old.exe
if exist "%BIN%\%OLD%" set OLD=sharexf-winhelper-multi.old-%RANDOM%.exe
if exist "%BIN%\sharexf-winhelper-multi.exe" ren "%BIN%\sharexf-winhelper-multi.exe" %OLD%
ren "%BIN%\sharexf-winhelper-multi.new.exe" sharexf-winhelper-multi.exe
rem The calls' sound on this PC (windows/callaudio.js): its own .exe with its own manifest (calls\),
rem and the signed sparse package that gives it an identity (pack.ps1). A Windows app, not a console
rem one: Windows starts it by itself on a call (phoneCallActivation), and a console app opened a terminal.
"%CSC%" /nologo /optimize+ /platform:anycpu /target:winexe /out:"%BIN%\sharexf-calls.new.exe" ^
  /win32manifest:"%~dp0calls\sharexf-calls.manifest" /r:System.Web.Extensions.dll %WINRT% ^
  "%~dp0calls\Calls.cs" "%~dp0src\Json.cs" || exit /b 1
del /q "%BIN%\sharexf-calls.old*.exe" 2>nul
set OLD=sharexf-calls.old.exe
if exist "%BIN%\%OLD%" set OLD=sharexf-calls.old-%RANDOM%.exe
if exist "%BIN%\sharexf-calls.exe" ren "%BIN%\sharexf-calls.exe" %OLD%
ren "%BIN%\sharexf-calls.new.exe" sharexf-calls.exe
rem Without PowerShell 7's module path (a pwsh terminal, CI): Windows PowerShell then loads its own PKI.
set PSModulePath=
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0calls\pack.ps1" -Bin "%BIN%" || exit /b 1
rem The virtual camera (windows/vcam.js), C++: built when Visual Studio's C++ tools are there.
call "%~dp0vcam\build.cmd" || exit /b 1
rem Real gamepad (windows/gamepad.js: Remote), C++ likewise.
call "%~dp0pad\build.cmd" || exit /b 1
