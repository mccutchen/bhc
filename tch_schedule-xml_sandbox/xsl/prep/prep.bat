@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug


:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables
CALL %prep_dir_in%config %1 %2



ECHO Preparing raw data for %sem% %year%
ECHO ----------------------------------------


:: Step 3: Create Mappings

SET text=Preparing mappings
SET xsl=%prep%xml-mappings.xsl

SET source=%basemap%
SET dest=%mappings%
SET params=path-mappings=%xsl_root%%mapdir%

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
ECHO Finished
ECHO.



:: Step 4: Fix Data

SET format=fixed
SET text=Fixing data
SET xsl=%prep%\xml-fix.xsl

SET source=%raw%
SET dest=%fixed%
SET params=path-sortkeys=%xsl_root%%sortkeys%
SET params=%params% path-core=%xsl_root%%core%
SET params=%params% path-mappings=%xsl_root%%mappings%
IF "%raw2%"=="": GOTO FIX
SET params=%params% second-schedule=%xsl_root%%raw2%
:FIX

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
ECHO Finished
ECHO.



:: Step 5: Form Data

SET format=formed
SET text=Forming data
SET xsl=%prep%\xml-form.xsl

SET source=%fixed%
SET dest=%formed%
SET params=path-sortkeys=%xsl_root%%sortkeys%
SET params=%params% path-mappings=%xsl_root%%mappings%/

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%
ECHO Finished
ECHO.



:: Step 6: Error Check

::ECHO Error-checking %sem% %year%...
CD %py_dir_in%
GOTO ErrorCheck%sched%

:ErrorCheckNormal
python -m compare %py_root%%raw% %py_root%%fixed% %py_root%%formed% %py_root%%compare%
GOTO ErrorCheckComplete

:ErrorCheckSummer
python -m compare %py_root%%raw% %py_root%%raw2% %py_root%%fixed% %py_root%%formed% %py_root%%compare%

:ErrorCheckComplete
CD %py_dir_out%
ECHO Finished
ECHO.



:: Step 7: Clean Up

ECHO Cleaning up...
COPY %formed% %data%%ys%.xml >nul
IF (%mode%)==(debug) GOTO FINISH
DEL %mappings%
DEL %fixed%
DEL %formed%

:FINISH
ECHO Finished
ECHO.
GOTO END



:SYNTAX
ECHO Syntax: %0 {semester} {year}
ECHO.
GOTO END

:END
