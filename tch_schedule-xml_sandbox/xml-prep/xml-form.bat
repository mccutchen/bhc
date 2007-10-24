@ECHO OFF

SET dir=..\data
SET map=..\mappings
SET year=2007
SET sem=Fall

SET fix=%dir%\%year%-%sem%_fixed.xml
SET form=%dir%\%year%-%sem%_formed.xml

SET sortkeys=%map%\sortkeys.xml
SET mappings=%dir%\%year%-%sem%_mappings.xml


ECHO Forming %sem% %year%...
SET params=path-sortkeys=%sortkeys% path-mappings=%mappings%
java -jar C:\saxon\saxon8.jar -o %form% %fix% xml-form.xsl %params%
ECHO Finished
ECHO.

PAUSE