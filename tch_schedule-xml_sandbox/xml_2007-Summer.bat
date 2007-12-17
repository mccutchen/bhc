@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

SET year=2007
SET sem=Summer
SET abbr=SU
SET abbr1=S1
SET abbr2=S2

SET data=data
SET map=mappings
SET prep=xml-prep

SET mapdir=%map%\%year%-%sem%
SET sortkeys=%map%\sortkeys.xml
SET core=%map%\core.xml

SET mappings=%data%\%year%-%sem%_mappings.xml
SET raw1=%data%\schedule-200-%year%%abbr1%.xml
SET raw2=%data%\schedule-200-%year%%abbr2%.xml
SET fixed=%data%\%year%-%sem%_fixed.xml
SET formed=%data%\%year%-%sem%_formed.xml
SET last=%formed%
SET final=%data%\%year%-%sem%.xml
SET compare=%data%\%year%-%sem%_compare.txt

:: Step 1: Generate Mappings

SET type=mappings
SET format=mappings
SET source=%mapdir%\base.xml
SET dest=%mappings%

SET params=path-mappings=../%mapdir%/

ECHO Generating %format% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %prep%\xml-%type%.xsl %params%
ECHO Finished
ECHO.


:: Step 2: Fix DSC XML

SET type=fix
SET format=fixed
SET source=%raw1%
SET dest=%fixed%

SET params=path-sortkeys=../%sortkeys% path-core=../%core% path-mappings=../%mappings% second-schedule=../%raw2%

ECHO Generating %format% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %prep%\xml-%type%.xsl %params%
ECHO Finished
ECHO.


:: Step 3: Form DSC XML

SET type=form
SET format=formed
SET source=%fixed%
SET dest=%formed%

SET params=path-sortkeys=../%sortkeys% path-mappings=../%mappings%/

ECHO Generating %format% output for %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %prep%\xml-%type%.xsl %params%
ECHO Finished
ECHO.


:: Step 4: Error check

ECHO Error-checking %sem% %year%...
python -m compare %raw1% %raw2% %fixed% %formed% %compare%
ECHO Finished
ECHO.


:: Step 5: Clean up
:: copies the last file into final. If not debugging, deletes intermediate steps
ECHO. Cleaning up...
copy /b %last% %final%

IF (%mode%)==(debug) GOTO FINISH
DEL %mappings%
DEL %fixed%
DEL %formed%

:FINISH
ECHO Finished
ECHO.
PAUSE
