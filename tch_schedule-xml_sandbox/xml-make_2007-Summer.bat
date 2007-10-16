:: Assumes that java is somewhere on %PATH%
@ECHO OFF

::Summer requires a little extra stuff - there are two input files, so an extra step to combine them

::Set this to debug in order to keep intermediate files
SET mode=debug

SET dir=data
SET map=mappings
SET year=2007
SET sem=Summer
SET abbr=SU
SET abbr1=S1
SET abbr2=S2

SET mapin=%map%\%year%-%sem%\base.xml
SET mapout=%map%\%year%-%sem%_mappings.xml

SET source1=%dir%\schedule-200-%year%%abbr1%.xml
SET source2=%dir%\schedule-200-%year%%abbr2%.xml
SET combined=%dir%\%year%-%sem%_combined.xml
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

ECHO Combining %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %combined% %source1% xml-combine.xsl s2=%source2%

ECHO Flattening %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %flat% %combined% xml-flatten.xsl %params%
ECHO Finished
ECHO.

ECHO Tidying %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %tidy% %flat% xml-tidy.xsl %params%
ECHO Finished
ECHO.

ECHO Error-checking %sem% %year%...
ECHO Can't errorcheck summer yet, will add functionality later.
::python -m xml-compare %source% %flat% %tidy% %sem% %year%
ECHO Finished
ECHO.

:: copies the last file into final. If not debugging, deletes intermediate steps
ECHO. Cleaning up...
copy /b %last% %final%

IF (%mode%)==(debug) GOTO FINISH
DEL %combined%
DEL %flat%
DEL %tidy%
::DEL %compare%

:FINISH
ECHO. Finished
ECHO.
PAUSE