@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

SET prep=xml-prep
SET data=data
SET map=mappings
SET year=2007
SET sem=Fall
SET abbr=FA

SET mapdir=mappings/%year%-%sem%/
SET mapin=%mapdir%base.xml
SET mapout=%data%\%year%-%sem%_mappings.xml

SET sortkeys=%map%\sortkeys.xml
SET mappings=%data%\%year%-%sem%_mappings.xml

SET source=%data%\schedule-200-%year%%abbr%.xml
SET fix=%data%\%year%-%sem%_fixed.xml
SET form=%data%\%year%-%sem%_formed.xml

SET compare=%data%\%year%-%sem%_compare.txt
SET last=%form%
SET final=%data%\%year%-%sem%.xml


ECHO Generating mappings for %sem% %year%...
SET params=dir-mappings=../%mapdir%
::java -jar C:\saxon\saxon8.jar -o %mapout% %mapin% %prep%\xml-mappings.xsl %params%
ECHO Finished
ECHO.

ECHO Fixing %sem% %year%...
SET params=path-sortkeys=..\%sortkeys% path-mappings=../%mappings%
::java -jar C:\saxon\saxon8.jar -o %fix% %source% %prep%\xml-fix.xsl %params%
ECHO Finished
ECHO.

ECHO Forming %sem% %year%...
SET params=path-sortkeys=../%sortkeys% path-mappings=../%mappings%
::java -jar C:\saxon\saxon8.jar -o %form% %fix% %prep%\xml-form.xsl %params%
ECHO Finished
ECHO.

ECHO Error-checking %sem% %year%...
python -m xml-compare %source% %fix% %form% %compare%
ECHO Finished
ECHO.

:: copies the last file into final. If not debugging, deletes intermediate steps
ECHO. Cleaning up...
copy /b %last% %final%

IF (%mode%)==(debug) GOTO FINISH
DEL %mapout%
DEL %fix%
DEL %form%
DEL %compare%

:FINISH
ECHO Finished
ECHO.
PAUSE
