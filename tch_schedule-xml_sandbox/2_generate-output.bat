@ECHO OFF

:: Step 1: Set Variables
::----------------------------------------------
CALL config
CALL setup %1 %2 %3
IF "%ys%"=="" GOTO SYNTAX
IF "%type%"=="" GOTO SYNTAX



:: Step 2: Generate Output
::----------------------------------------------

CALL %transform_bat% %type% %semester% %year%



GOTO END

:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: 3_generate-output {semester} {year} {type}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year
ECHO and   {type} = rooms, print, InDesign-print, proof, proof-full, web, enrolling-now, enrolling-soon
ECHO.



:END
IF "%pause%"=="" PAUSE