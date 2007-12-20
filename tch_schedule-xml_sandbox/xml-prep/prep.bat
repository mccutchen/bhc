@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables

SET type=print
SET year=%1
SET sem=%2
SET ys=%year%-%sem%

CALL config

SET mapdir=%map%\%ys%

SET core=%map%\core.xml
SET sortkeys=%map%\sortkeys.xml
SET basemap=%mapdir%\base.xml

SET mappings=%data%\%ys%_mappings.xml
SET compare=%data%\%ys%_compare.txt


ECHO Preparing raw data for %sem% %year%
ECHO ----------------------------------------
GOTO SetAbbr
:RETURN


:: Step 3: Create Mappings

SET text=Preparing mappings
SET xsl=%root%%prep%\xml-mappings.xsl

SET source=%root%%basemap%
SET dest1=%root%%mappings%
SET params=path-mappings=%up%%mapdir%/

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest1% %source% %xsl% %params%
ECHO Finished
ECHO.


:: Step 4: Fix Data

SET format=fixed
SET text=Fixing data
SET xsl=%root%%prep%\xml-fix.xsl

SET source=%root%%raw%
SET dest2=%root%%data%\%ys%_%format%.xml
SET params=path-sortkeys=%up%%sortkeys%
SET params=%params% path-core=%up%%core%
SET params=%params% path-mappings=%up%%mappings%
IF "%params%"=="": GOTO FIX
SET params=%params% second-schedule=%up%%raw2%
:FIX

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest2% %source% %xsl% %params%
ECHO Finished
ECHO.


:: Step 5: Form Data

SET format=formed
SET text=Forming data
SET xsl=%root%%prep%\xml-form.xsl

SET source=%dest2%
SET dest3=%root%%data%\%ys%_%format%.xml
SET params=path-sortkeys=%up%%sortkeys%
SET params=%params% path-mappings=%up%%mappings%/

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest3% %source% %xsl% %params%
ECHO Finished
ECHO.


:: Step 6: Error Check

::ECHO Error-checking %sem% %year%...
GOTO ErrorCheck%sched%

:ErrorCheckNormal
python -m compare %root%%raw% %root%%dest2% %root%%dest3% %root%%compare%
GOTO ErrorCheckComplete

:ErrorCheckSummer
python -m compare %root%%raw% %root%%raw2% %root%%dest2% %root%%dest3% %root%%compare%

:ErrorCheckComplete
ECHO Finished
ECHO.


:: Step 5: Clean Up

ECHO Cleaning up...
COPY %dest3% %root%%data%\%ys%.xml
IF (%mode%)==(debug) GOTO FINISH
DEL %dest1%
DEL %dest2%
DEL %dest3%

:FINISH
ECHO Finished
ECHO.
GOTO END

:SYNTAX
ECHO Syntax: {filename}.bat {year} {semester}
ECHO.
GOTO END



:SetAbbr
GOTO %sem%
:Fall
SET sched=Normal
SET abbr=FA
SET raw=%data%\schedule-200-%year%%abbr%.xml
GOTO RETURN
:Spring
SET sched=Normal
SET abbr=SP
SET raw=%data%\schedule-200-%year%%abbr%.xml
GOTO RETURN
:Summer
SET sched=Summer
SET abbr=S1
SET abbr2=S2
SET raw=%data%\schedule-200-%year%%abbr%.xml
SET raw2=%data%\schedule-200-%year%%abbr2%.xml
GOTO RETURN
:default

:END
