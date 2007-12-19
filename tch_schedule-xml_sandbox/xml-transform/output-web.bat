@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug


:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables

SET type=web
SET year=%1
SET sem=%2
SET ys=%year%-%sem%

SET data=data
SET split=xml-split
SET trans=xml-transform


ECHO Generating %type% output for %sem% %year%
ECHO ----------------------------------------


:: Step 3: Pre-Format the Data

:: A. Trim

SET splitter=trim
SET text=Trimming data
SET format=%type%1

SET source=%data%\%ys%.xml
SET dest1=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest1% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: B. Split

SET splitter=split
SET text=Splitting courses

SET format=%type%2

SET source=%dest1%
SET dest2=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest2% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: C. Sort

SET splitter=sort
SET text=Sorting data

SET format=%type%3

SET source=%dest2%
SET dest3=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest3% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: D. Special Sections

SET splitter=special
SET text=Inserting Special Sections

SET format=%type%4

SET source=%dest3%
SET dest4=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest4% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.


:: Step 4, Produce Output

SET text=Producing output

SET source=%dest4%
SET dest=no-file.txt

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %trans%\output-%type%.xsl
ECHO Finished
ECHO.


:: Step 5, clean up

ECHO Cleaning up...
IF (%mode%)==(debug) GOTO FINISH
DEL %dest1%
DEL %dest2%
DEL %dest3%
DEL %dest4%

:FINISH
ECHO Finished
ECHO.
GOTO END

:SYNTAX
ECHO Syntax: {filename}.bat {year} {semester}
ECHO.

:END