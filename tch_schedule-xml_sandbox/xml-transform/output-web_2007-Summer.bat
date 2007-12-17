@ECHO OFF

SET data=..\data
SET split=..\xml-split
SET out=..
SET year=2007
SET sem=Summer
SET type=web


:: Step 1: Pre-Format the Data

SET splitter1=trim
SET format1=trimmed

SET splitter2=special
SET format2=special

SET source=%data%\%year%-%sem%.xml
SET dest1=%data%\%year%-%sem%_%format1%.xml

ECHO Removing suppressed classes for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest1% %source% %split%\xml-%splitter1%.xsl
ECHO Finished
ECHO.


SET source=%dest1%
SET dest2=%data%\%year%-%sem%_%format2%.xml

ECHO Inserting special sections for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest2% %source% %split%\xml-%splitter2%.xsl
ECHO Finished
ECHO.


:: Step 2, Produce Output

SET source=%dest2%
SET dest=%out%\no-file.txt

ECHO Generating %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.


:: Step 3, clean up

ECHO Cleaning up...
DEL %dest1%
DEL %dest2%


PAUSE
