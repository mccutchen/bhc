@ECHO OFF

SET dir=..\data
SET split=..\xml-split
SET out=..
SET year=2007
SET sem=Fall
SET type=rooms


:: Step 1: No pre-formatting required


:: Step 2: Produce Output

SET source=%dir%\%year%-%sem%.xml
SET dest=%out%\no-file.txt

ECHO Generating %type% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% output-%type%.xsl
ECHO Finished
ECHO.


:: Step 3: No cleanup required


PAUSE
