:: Assumes that java is somewhere on %PATH%
@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

SET dir=data
SET map=mappings
SET year=2008
SET sem=Spring
SET abbr=SP

SET mapin=%map%\%year%-%sem%\base.xml
SET mapout=%map%\%year%-%sem%_mappings.xml

SET source=%dir%\schedule-200-%year%%abbr%.xml
SET flat=%dir%\%year%-%sem%_flat.xml
SET tidy=%dir%\%year%-%sem%_tidy.xml
SET params=semester=%sem% year=%year%

SET compare=%dir%\%year%-%sem%_compare.txt
SET last=%tidy%
SET final=%dir%\%year%-%sem%.xml


ECHO Generating mappings %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %mapout% %mapin% xml-mappings.xsl %params%
ECHO Finished
ECHO.

ECHO Flattening %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %flat% %source% xml-flatten.xsl %params%
ECHO Finished
ECHO.

ECHO Tidying %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %tidy% %flat% xml-tidy.xsl %params%
ECHO Finished
ECHO.

ECHO Error-checking %sem% %year%...
python -m xml-compare %source% %flat% %tidy% %sem% %year%
ECHO Finished
ECHO.

:: copies the last file into final. If not debugging, deletes intermediate steps
ECHO. Cleaning up...
copy /b %last% %final%

IF (%mode%)==(debug) GOTO FINISH
DEL %flat%
DEL %tidy%
DEL %compare%

:FINISH
ECHO. Finished
ECHO.
PAUSE