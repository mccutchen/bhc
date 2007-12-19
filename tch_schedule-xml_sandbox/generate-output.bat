@ECHO OFF

SET bat=xml-prep\prep

ECHO.
CALL %bat% 2007 Fall
ECHO.

PAUSE


SET bat=xml-transform\output xml-transform\

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