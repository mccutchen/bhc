@ECHO OFF

SET data=..\data
SET map=..\mappings
SET year=2007
SET sem=Summer
SET abbr1=S1
SET abbr2=S2
SET type=fix
SET format=fixed

SET source1=%data%\schedule-200-%year%%abbr1%.xml
SET source2=%data%\schedule-200-%year%%abbr2%.xml
SET dest=%data%\%year%-%sem%_%format%.xml

SET mappings=%data%/%year%-%sem%_mappings.xml
SET sortkeys=%map%\sortkeys.xml
SET core=%map%\core.xml


ECHO Generating %format% output for %sem% %year%...
SET params=path-sortkeys=%sortkeys% path-core=%core% path-mappings=%mappings% second-schedule=%source2%
java -jar C:\saxon\saxon8.jar -o %dest% %source1% xml-%type%.xsl %params%
ECHO Finished
ECHO.

PAUSE