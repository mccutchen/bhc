@ECHO OFF

:: Step 1: Fetch New Data
ECHO.
python -m update -no_pause
ECHO.


:: Step 2: Prepare the Data
SET bat=xml-prep\prep

:: Syntax:  CALL %bat% {year} {semester}
:: where  {semester} = Summer, Spring, or Fall

ECHO.
CALL %bat% 2007 Fall
ECHO.
ECHO.


:: Step 3: generate output
SET bat=xml-transform\output xml-transform\

:: Syntax:  CALL %bat% {output} {year} {semester}
:: where  {output}   = proof, print, web, or rooms
:: and    {semester} = Summer, Spring, or Fall

ECHO.
CALL %bat% proof 2007 Fall
ECHO.

ECHO.
CALL %bat% prinT 2007 Fall
ECHO.

ECHO.
CALL %bat% WEB 2007 Fall
ECHO.

ECHO.
CALL %bat% rooms 2007 Fall
ECHO.

PAUSE