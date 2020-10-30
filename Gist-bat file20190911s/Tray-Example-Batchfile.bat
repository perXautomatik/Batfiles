@echo Example iMacros Batch File *TRAY MODE*
@echo Tip: You may have to adjust iMacros default macros folder to iMacros\Macros\Demo

@REM %pf% expands to the right program location depending if it is x86 or x64 system
@setlocal
@set pf=%ProgramFiles%
@if not "[%ProgramFiles(x86)%]"=="[]" set pf=%ProgramFiles(x86)%

@REM %macropath% expands to the demo macros path
@set macropath=%~dp0..\..\Macros\Demo

"%pf%\iOpus\iMacros\iMacros.exe" -macro "%macropath%\FillForm.iim" -tray

Rem If you want to run the software WITHOUT tray icon, use "-silent" instead of "-tray"

"%pf%\iOpus\iMacros\iMacros.exe" -macro "%macropath%\FillForm.iim" -silent

Rem Use "-kioskmode" to run the browser without the sidebar

"%pf%\iOpus\iMacros\iMacros.exe" -macro "%macropath%\FillForm.iim" -kioskmode

@echo Batch file completed
pause
























