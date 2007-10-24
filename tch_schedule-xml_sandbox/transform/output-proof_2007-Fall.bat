@ECHO OFF

SET dir=..\data
SET out=..
SET year=2007
SET sem=Fall
SET type=proof

SET source=%dir%\%year%-%sem%.xml
SET dest=%out%\no-file.txt

ECHO Generating %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.

PAUSE
