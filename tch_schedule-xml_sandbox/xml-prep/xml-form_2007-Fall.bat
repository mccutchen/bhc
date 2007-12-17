@ECHO OFF

SET year=2007
SET sem=Fall

SET type=form
SET format=formed
SET input=fixed

SET data=..\data
SET map=..\mappings

SET sortkeys=%map%\sortkeys.xml
SET mappings=%data%/%year%-%sem%_mappings.xml

SET source=%data%\%year%-%sem%_%input%.xml
SET dest=%data%\%year%-%sem%_%format%.xml

ECHO Generating %format% output for %sem% %year%...
SET params=path-sortkeys=%sortkeys% path-mappings=%mappings%/
java -jar C:\saxon\saxon8.jar -o %dest% %source% xml-%type%.xsl %params%
ECHO Finished
ECHO.

PAUSE