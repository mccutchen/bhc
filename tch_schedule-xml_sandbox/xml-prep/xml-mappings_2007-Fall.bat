@ECHO OFF

SET year=2007
SET sem=Fall

SET type=mappings
SET format=mappings

SET data=..\data
SET map=..\mappings

SET mapdir=%map%\%year%-%sem%
SET source=%mapdir%\base.xml
SET dest=%data%\%year%-%sem%_%format%.xml

SET params=path-mappings=%mapdir%/

ECHO Generating %format% output for %sem% %year%...
ECHO java -jar C:\saxon\saxon8.jar -o %dest% %source% xml-%type%.xsl %params%
ECHO Finished
ECHO.

PAUSE