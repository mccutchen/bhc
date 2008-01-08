@ECHO OFF

:: Semester / year
SET semester=Summer
SET year=2008

:: Step 1: Fetch New Data
ECHO.
::python -m update -no_pause
ECHO.


:: Step 2: Prepare the Data
SET bat=xml-prep\prep

:: Syntax:  CALL %bat% {year} {semester}
:: where  {semester} = Summer, Spring, or Fall

ECHO.
::CALL %bat% %year% %semester%
ECHO.
ECHO.


:: Step 3: generate output
SET bat=xml-transform\output xml-transform\

:: Syntax:  CALL %bat% {output} {year} {semester}
:: where  {output}   = proof, print, web, or rooms
:: and    {semester} = Summer, Spring, or Fall

ECHO.
::CALL %bat% proof %year% %semester%
ECHO.

ECHO.
::CALL %bat% print %year% %semester%
ECHO.

ECHO.
CALL %bat% web %year% %semester%
ECHO.

ECHO.
CALL %bat% enrolling %year% %semester%

ECHO.
::CALL %bat% rooms %year% %semester%
ECHO.

PAUSE