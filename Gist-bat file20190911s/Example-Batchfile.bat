@echo Example iMacros Batch File
@echo Tip: You may have to adjust iMacros default macros folder to iMacros\Macros\Demo

@REM %pf% expands to the right program location depending if it is x86 or x64 system
@setlocal
@set pf=%ProgramFiles%
@if not "[%ProgramFiles(x86)%]"=="[]" set pf=%ProgramFiles(x86)%

@REM %macropath% expands to the demo macros path
@set macropath=%~dp0..\..\Macros\Demo

"%pf%\iOpus\iMacros\iMacros.exe" -macro "%macropath%\FillForm.iim"
"%pf%\iOpus\iMacros\iMacros.exe" -macro "%macropath%\Loop-Csv-2-Web.iim" -loop 4

@echo Batch file completed
pause





















