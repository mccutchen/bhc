@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

SET dir=..\data
SET map=..\mappings
SET year=2007
SET sem=Fall

SET mapdir=../mappings/%year%-%sem%
SET mapin=%mapdir%\base.xml
SET mapout=%dir%\%year%-%sem%_mappings.xml


ECHO Generating mappings for %sem% %year%...
SET params=dir-mappings=%mapdir%/
java -jar C:\saxon\saxon8.jar -o %mapout% %mapin% xml-mappings.xsl %params%
ECHO Finished
ECHO.

PAUSE