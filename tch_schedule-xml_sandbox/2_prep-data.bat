@ECHO OFF

:: Step 1: Set Variables
::----------------------------------------------
CALL config
CALL setup %1 %2
IF "%ys%"=="" GOTO SYNTAX



:: Step 2: Prepare the Data
::----------------------------------------------
:: Syntax: CALL %prep_bat% {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {year} is a valid, 4-digit year

CALL clean semester
CALL %prep_bat% %1 %2



GOTO END

:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: 2_prep-data.bat {semester} {year}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year



:END
IF "%pause%"=="" PAUSE