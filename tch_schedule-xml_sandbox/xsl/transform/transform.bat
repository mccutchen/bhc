@ECHO OFF

:: Step 1: Check Parameters
::----------------------------------------------
IF NOT "%setup%"=="true" CALL setup %1 %2 %3
IF "%ys%"=="" GOTO SYNTAX
IF "%type%"=="" GOTO SYNTAX



:: Step 2: Check for correct data file
::----------------------------------------------
IF EXIST %file% GOTO OUTPUT
CALL %split_bat% %1 %2
IF NOT EXIST %file% GOTO ERROR



:OUTPUT
:: Step 3: Generate output
::----------------------------------------------
SET xsl=%transform_dir_in%%type%.xsl
SET source=%file%
SET dest=no-file.txt

ECHO.
ECHO Generating %type% output for %semester% %year%
GOTO %type%

:rooms
:print
:print-quark
:proof
:web
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
GOTO CLEAN-UP

:proof-full
SET xsl=%transform_dir_in%proof.xsl
SET params="is-full=true"
SET params=%params% "hilight=true"
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
GOTO CLEAN-UP

:print-indesign
SET xsl=%transform_dir_in%print.xsl
SET params="format=indesign"
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
GOTO CLEAN-UP

:enrolling-now
SET params="schedule-type=Enrolling Now"
SET xsl=%transform_dir_in%web.xsl
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
GOTO CLEAN-UP

:enrolling-soon
SET params="schedule-type=Enrolling Soon"
SET xsl=%transform_dir_in%web.xsl
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
GOTO CLEAN-UP

GOTO END

:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: 3_generate-output {semester} {year} {type}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year
ECHO and   {type} = rooms, print, print-InDesign, proof, proof-full, web, enrolling-now, enrolling-soon
ECHO.
GOTO END

:ERROR
ECHO Unable to load data file: %file%
ECHO.
GOTO END

:CLEAN-UP
IF (%mode%)==(debug) GOTO END
IF NOT EXIST %dest% GOTO END
DEL %dest%
GOTO END

:END
ECHO Finished.
ECHO.