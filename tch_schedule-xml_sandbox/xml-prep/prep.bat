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

SET data=data
SET prep=xml-prep
SET map=mappings

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

SET xsl=mappings
SET text=Preparing mappings

SET source=%basemap%
SET dest1=%mappings%
SET params=path-mappings=../%mapdir%/

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest1% %source% %prep%\xml-%xsl%.xsl %params%
ECHO Finished
ECHO.


:: Step 4: Fix Data

SET xsl=fix
SET format=fixed
SET text=Fixing data

SET source=%raw%
SET dest2=%data%\%ys%_%format%.xml
SET params=path-sortkeys=../%sortkeys% path-core=../%core% path-mappings=../%mappings%

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest2% %source% %prep%\xml-%xsl%.xsl %params%
ECHO Finished
ECHO.


:: Step 5: Form Data

SET xsl=form
SET format=formed
SET text=Forming data

SET source=%dest2%
SET dest3=%data%\%ys%_%format%.xml
SET params=path-sortkeys=../%sortkeys% path-mappings=../%mappings%/

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest3% %source% %prep%\xml-%xsl%.xsl %params%
ECHO Finished
ECHO.


:: Step 6: Error Check

ECHO Error-checking %sem% %year%...
GOTO ErrorCheck%sched%

:ErrorCheckNormal
python -m compare %raw% %dest2% %dest3% %compare%
GOTO ErrorCheckComplete

:ErrorCheckSummer
python -m compare %raw% %raw2% %dest2% %dest3% %compare%

:ErrorCheckComplete
ECHO Finished
ECHO.


:: Step 5: Clean Up

ECHO Cleaning up...
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
GOTO Return
:Spring
SET sched=Normal
SET abbr=SP
SET raw=%data%\schedule-200-%year%%abbr%.xml
GOTO Return
:Summer
SET sched=Summer
SET abbr=S1
SET abbr2=S2
SET raw=%data%\schedule-200-%year%%abbr%.xml
SET raw2=%data%\schedule-200-%year%%abbr2%.xml
GOTO Return
:default

:END
