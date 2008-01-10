@ECHO OFF

:: Step 1: Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2: Set Variables
CALL config
SET pause=no-pause



:: Step 3: Fetch New Data

CALL 1_fetch-dsc-xml



:: Step 4: Prepare the Data

CALL 2_prep-data %1 %2



:: Step 5: Generate Output

CALL 3_generate-output %1 %2


GOTO END


:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: full-run.bat {semester} {year}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year


:END
PAUSE