@ECHO OFF

GOTO %2

:proof
:print
:web
:rooms
CALL %1output-%2 %3 %4
GOTO END

:default
ECHO.
ECHO %1 is not a valid transformation
ECHO.

:END