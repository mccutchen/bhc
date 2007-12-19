@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug


:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables

SET type=rooms
SET year=%1
SET sem=%2
SET ys=%year%-%sem%

SET data=data
SET split=xml-split
SET trans=xml-transform


ECHO Generating %type% output for %sem% %year%
ECHO ----------------------------------------


:: Step 3: No preformatting required

:: Step 4, Produce Output

SET text=Producing output

SET source=%data%\%ys%.xml
SET dest=no-file.txt

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %trans%\output-%type%.xsl
ECHO Finished
ECHO.


:: Step 5, clean up

ECHO Cleaning up...
IF (%mode%)==(debug) GOTO FINISH

:FINISH
ECHO Finished
ECHO.
GOTO END

:SYNTAX
ECHO Syntax: output-proof.bat {year} {semester}
ECHO.

:END