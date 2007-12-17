@ECHO OFF

SET year=2007
SET sem=Fall
SET abbr=FA

SET type=fix
SET format=fixed

SET data=..\data
SET map=..\mappings

SET mappings=%data%/%year%-%sem%_mappings.xml
SET sortkeys=%map%\sortkeys.xml
SET core=%map%\core.xml

SET source=%data%\schedule-200-%year%%abbr%.xml
SET dest=%data%\%year%-%sem%_%format%.xml


ECHO Generating %format% output for %sem% %year%...
SET params=path-sortkeys=%sortkeys% path-core=%core% path-mappings=%mappings%
java -jar C:\saxon\saxon8.jar -o %dest% %source% xml-%type%.xsl %params%
ECHO Finished
ECHO.

PAUSE