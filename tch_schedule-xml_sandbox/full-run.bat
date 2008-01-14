@ECHO OFF

SET pause=no-pause

:: Step 1: Fetch New Data

CALL 1_fetch-dsc-xml



:: Step 2: Run the usual

CALL 3_generate-output Spring 2008 web
CALL 3_generate-output Spring 2008 enrolling-now
CALL 3_generate-output Summer 2008 proof

GOTO END


:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: full-run.bat {semester} {year}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year


:END
PAUSE