@ECHO OFF

SET dir=..\data
SET split=..\xml-split
SET out=..
SET year=2007
SET sem=Fall
SET type=web


:: Step 1, produce the normal output

SET splitter=trim
SET format=trimmed

SET raw=%data%\%year%-%sem%.xml
SET source=%data%\%year%-%sem%_%format%.xml
SET dest=%out%\no-file.txt

ECHO Formatting input for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %source% %raw% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

ECHO Generating normal %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.


:: Step 2, produce special section output

SET splitter=special
SET format=special

SET raw=%source%.xml
SET source=%data%\%year%-%sem%_%format%.xml
SET dest=%out%\no-file.txt

ECHO Formatting special input for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %source% %raw% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

ECHO Generating special %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.


ECHO Cleaning up...
DEL %raw%
DEL %source%


PAUSE
