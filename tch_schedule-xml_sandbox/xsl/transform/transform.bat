@ECHO OFF

:: Step 1: Check Parameters
::----------------------------------------------
IF NOT "%setup%"=="true" CALL setup %1 %2 %3
IF "%ys%"=="" GOTO SYNTAX
IF "%type%"=="" GOTO SYNTAX



:: Step 2: Check for correct data file
::----------------------------------------------
IF EXIST %file% GOTO OUTPUT
CALL %split_bat% %type%
IF NOT EXIST %file% GOTO ERROR



:OUTPUT
:: Step 3: Generate output
::----------------------------------------------
SET xsl=%transform_dir_in%%type%.xsl
SET source=%file%
SET dest=no-file.txt

ECHO Generating %type% output for %semester% %year%
GOTO %type%

:rooms
:print
:proof
:web
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
GOTO CLEAN-UP

:enrolling-now
SET params="schedule-type=Enrolling Now"
GOTO ENROLL
:enrolling-soon
SET params="schedule-type=Enrolling Soon"
GOTO ENROLL
:ENROLL
SET xsl=%transform_dir_in%web.xsl
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
GOTO CLEAN-UP



GOTO END

:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: 3_generate-output {semester} {year} {type}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year
ECHO and   {type} = rooms, print, proof, web, enrolling-now, enrolling-soon
ECHO.
GOTO END

:ERROR
ECHO Unable to load data file: %file%
ECHO.
GOTO END

:CLEAN-UP
IF NOT EXIST %dest% GOTO END
DEL %dest%
GOTO END

:END
ECHO Finished