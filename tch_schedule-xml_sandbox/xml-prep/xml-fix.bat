@ECHO OFF

SET dir=..\data
SET map=..\mappings
SET year=2007
SET sem=Fall
SET abbr=FA

SET source=%dir%\schedule-200-%year%%abbr%.xml
SET fix=%dir%\%year%-%sem%_fixed.xml

SET sortkeys=%map%\sortkeys.xml
SET core=%map%\core.xml
SET mappings=%dir%\%year%-%sem%_mappings.xml

ECHO Fixing %sem% %year%...
SET params=path-sortkeys=%sortkeys% path-core=%core% path-mappings=%mappings%
java -jar C:\saxon\saxon8.jar -o %fix% %source% xml-fix.xsl %params%
ECHO Finished
ECHO.

PAUSE