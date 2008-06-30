@ECHO OFF

:: Step 1: Check Parameters
::----------------------------------------------
IF NOT "%setup%"=="true" CALL setup %1 %2
IF "%ys%"=="" GOTO SYNTAX


ECHO.
ECHO Preparing data for %semester% %year%


:: Step 2: Create Mappings
::----------------------------------------------
IF NOT EXIST %map_sem% GOTO NO-MAPPINGS
SET xsl=%prep_dir_in%mappings.xsl
SET source=%base%
SET dest=%mappings%
SET params=path-mappings=%xsl_root%%map_sem%

ECHO  - creating mappings
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%



:: Step 4: Fix Data
::----------------------------------------------
IF NOT EXIST %raw% GOTO NO-DATA
SET xsl=%prep_dir_in%fix.xsl
SET source=%raw%
SET dest=%fixed%
SET params=path-sortkeys=%xsl_root%%sortkeys%
SET params=%params% path-core=%xsl_root%%core%
SET params=%params% path-mappings=%xsl_root%%mappings%
IF "%raw2%"=="" GOTO FIX
IF NOT EXIST "%raw2%" GOTO NO-DATA-S2
SET params=%params% second-schedule=%xsl_root%%raw2%
:FIX

ECHO  - fixing data
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%



:: Step 5: Form Data
::----------------------------------------------
SET xsl=%prep_dir_in%\form.xsl
SET source=%fixed%
SET dest=%formed%
SET params=path-sortkeys=%xsl_root%%sortkeys%
SET params=%params% path-mappings=%xsl_root%%mappings%/

ECHO  - forming data
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl% %params%



:: Step 6: Error Check
::----------------------------------------------
ECHO  - error checking

CD %py_dir_in%
GOTO ErrorCheck%schedule%

:ErrorCheckNormal
python -m compare %py_root%%raw% %py_root%%fixed% %py_root%%formed% %py_root%%compare%
GOTO ErrorCheckComplete

:ErrorCheckSummer
python -m compare %py_root%%raw% %py_root%%raw2% %py_root%%fixed% %py_root%%formed% %py_root%%compare%
GOTO ErrorCheckComplete

:default
ECHO Unable to error check output!
GOTO ErrorCheckComplete

:ErrorCheckComplete
CD %py_dir_out%



:: Step 7: Fix Meetings
::----------------------------------------------
SET xsl=%prep_dir_in%\meetings.xsl
SET source=%formed%
SET dest=%meetings%

ECHO  - fixing meetings
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%



:: Step 8: Clean Up

ECHO  - cleaning up
IF (%mode%)==(debug) GOTO END
:DEL %mappings%
DEL %fixed%
DEL %formed%
GOTO END


:NO-MAPPINGS
ECHO There are no mappings for %semester% %year%.
GOTO END

:NO-DATA
ECHO There is no raw data for %semester% %year%.
GOTO END

:NO-DATA-S2
ECHO There is no second schedule for %semester% %year%.
GOTO END

:SYNTAX
ECHO Syntax: %0 {semester} {year}
ECHO.
GOTO END

:END
ECHO Finished.
ECHO.
