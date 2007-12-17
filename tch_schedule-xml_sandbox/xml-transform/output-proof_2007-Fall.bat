@ECHO OFF

SET data=..\data
SET split=..\xml-split
SET out=..
SET year=2007
SET sem=Fall
SET type=proof


:: Step 1: Pre-Format the Data

SET splitter=trim
SET format=trimmed

SET source=%data%\%year%-%sem%.xml
SET dest=%data%\%year%-%sem%_%format%.xml

ECHO Formatting input for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.


:: Step 2, Produce Output

SET source=%dest%
SET dest=%out%\no-file.txt

ECHO Generating %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.


:: Step 3, clean up

ECHO Cleaning up...
DEL %source%

PAUSE
