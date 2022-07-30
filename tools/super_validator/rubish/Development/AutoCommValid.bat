@echo off
rem =========================================================================
rem ==
rem == Version  : 1.00
rem ==
rem == Fonction :
rem ==
rem ==
rem == Argument :
rem ==
rem =========================================================================
rem ==
rem == Historique
rem ==
rem ==  28/02/2018 : Création
rem ==
rem =========================================================================
rem use perl version 5.004_02


setlocal
set PATH_SCOPY=%~dp0
rem set VERSION_AUTO_COMM_VALID_=%PATH_SCOPY:~-6,-1%
set PATH="C:\Windows\System32";"L:\Perl\v5.8.8\bin"

rem echo =-=[ AUTO_COMM_VALID %VERSION_AUTO_COMM_VALID_% ]=-=
perl %PATH_SCOPY%\Main.pl %*
exit /B %ERRORLEVEL%

