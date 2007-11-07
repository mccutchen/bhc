@ECHO OFF

SET data=..\data
SET split=..\xml-split
SET out=..
SET year=2007
SET sem=Fall
SET type=proof
SET splitter=trim
SET format=trimmed

SET raw=%data%\%year%-%sem%.xml
SET source=%data%\%year%-%sem%_%format%.xml
SET dest=%out%\no-file.txt

ECHO Formatting input for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %source% %raw% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

ECHO Generating %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.

PAUSE
