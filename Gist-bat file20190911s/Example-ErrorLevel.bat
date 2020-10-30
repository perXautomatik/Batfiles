@echo off
echo Example iMacros Batch File
echo Tip: You may have to adjust iMacros default macros folder to iMacros\Macros\Demo

@REM %pf% expands to the right program location depending if it is x86 or x64 system
@setlocal
@set pf=%ProgramFiles%
@if not "[%ProgramFiles(x86)%]"=="[]" set pf=%ProgramFiles(x86)%

@REM %macropath% expands to the demo macros path
@set macropath=%~dp0..\..\Macros\Demo

REM Note: The "-loop <x> " command runs the macro <x> times in a loop. 
REM This is the same as pressing the LOOP button in the iMacros browser.

"%pf%\iOPus\iMacros\iMacros.exe" -macro "%macropath%\Loop-Csv-2-Web.iim" -loop 4

REM The batch variable %errorlevel% is automatically set by "imacros.exe" upon exit

REM Alternatively, you can also start VB Scripts from the command line: http://wiki.imacros.net/VBS_Command_Line

if %errorlevel% == 1 goto ok
if NOT %errorlevel% == 1 goto error

:ok
echo Macro completed succesfully!
goto end

:error
echo Error encountered during replay.
echo Errorcode=%errorlevel% 
echo Please see http://wiki.imacros.net/Error-Codes
echo for a detailed description of error codes.

:end
pause












































