@echo off
rem =========================================================================
rem ==
rem == Fonction : 
rem ==
rem == Argument :  
rem ==
rem =========================================================================
rem =========================================================================
rem use perl version 5.004_02
rem use cat from cygwin version V2011.01

setlocal
set PATH_MAIN_TASK_EDITOR=%~dp0
set VERSION_MAIN_TASK_EDITOR=%PATH_MAIN_TASK_EDITOR:~-6,-1%
set PATH="C:\Windows\System32";"L:\Perl\v5.8.8\bin"

echo -=[ MAIN_TASK_EDITOR %VERSION_MAIN_TASK_EDITOR% ]=-
perl %PATH_MAIN_TASK_EDITOR%main_task_editor.pl %*
exit /B %ERRORLEVEL%
