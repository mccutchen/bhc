@ECHO OFF

SET data=..\data
SET map=..\mappings
SET year=2007
SET sem=Summer
SET type=mappings
SET format=mappings

SET mapdir=%map%/%year%-%sem%
SET source=%mapdir%\base.xml
SET dest=%data%\%year%-%sem%_%format%.xml


ECHO Generating %format% output for %sem% %year%...
SET params=path-mappings=%mapdir%/
java -jar C:\saxon\saxon8.jar -o %dest% %source% xml-%type%.xsl %params%
ECHO Finished
ECHO.

PAUSE