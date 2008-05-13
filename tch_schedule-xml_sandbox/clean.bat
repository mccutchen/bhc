@ECHO OFF

:: NOTE:
:: Ok, so I can't find a way to remove the "Could Not Find" error on DEL.
:: So I'm just going to pipe in a null file and that should fix it.

:: Step 1: Check for params
IF "%1"=="" GOTO CLEAN_ALL
IF "%1"=="semester" GOTO CLEAN_SEMESTER
GOTO SYNTAX


:: Step 2a: Clean all generated data files
:CLEAN_ALL
ECHO nul>%data_dir_in%201.xml
ECHO nul>%data_dir_in%201.txt
DEL %data_dir_in%20*.xml
DEL %data_dir_in%20*.txt
GOTO END

:: Step 2b: Clean a single semester of generated data files
:CLEAN_SEMESTER
ECHO nul>%data_dir_in%%ys%.xml
ECHO nul>%data_dir_in%%ys%.txt
DEL %data_dir_in%%ys%*.xml
DEL %data_dir_in%%ys%*.txt
GOTO END

:SYNTAX
ECHO.
ECHO Syntax: %0 {semester} {year}
ECHO You may omit the semester and year to clean all files
ECHO.

:END
IF "%pause%"=="" PAUSE