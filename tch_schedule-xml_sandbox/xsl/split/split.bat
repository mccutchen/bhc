@ECHO OFF

:: Step 1: Check Parameters
::----------------------------------------------
IF NOT "%setup%"=="true" CALL setup %1 %2 %3
IF "%ys%"=="" GOTO SYNTAX
IF "%type%"=="" GOTO SYNTAX


ECHO.
ECHO Splitting data for %semester% %year%

:: Step 2: Determine Type
::----------------------------------------------
GOTO %type%

: ROOMS
::----------------------------------------------
IF EXIST %rooms% GOTO ROOMS_END

CALL %prep_bat% %semester% %year%

:ROOMS_END
IF NOT EXIST %rooms% GOTO ERROR
IF "%type%"=="rooms" GOTO END


:PRINT
::----------------------------------------------
IF EXIST %print% GOTO PRINT_END
IF NOT EXIST %rooms% GOTO ROOMS

SET xsl=%split_dir_in%trim.xsl
SET source=%rooms%
SET dest=%trimmed%
ECHO  - trimming
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %trimmed% GOTO ERROR

:PRINT_END
IF NOT EXIST %print% GOTO ERROR
IF "%type%"=="print" GOTO END


:PROOF
::----------------------------------------------
IF EXIST %proof% GOTO PROOF_END
IF NOT EXIST %print% GOTO PRINT

SET xsl=%split_dir_in%split.xsl
SET source=%print%
SET dest=%split%
ECHO  - splitting
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %split% GOTO ERROR

SET xsl=%split_dir_in%sort.xsl
SET source=%split%
SET dest=%sorted%
ECHO  - sorting
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %sorted% GOTO ERROR

SET xsl=%split_dir_in%link.xsl
SET source=%sorted%
SET dest=%linked%
ECHO  - linking
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %linked% GOTO ERROR

IF (%mode%)==(debug) GOTO PROOF_END
DEL %split%
DEL %sorted%

:PROOF_END
IF NOT EXIST %proof% GOTO ERROR
IF "%type%"=="proof" GOTO END


:WEB
::----------------------------------------------
IF EXIST %web% GOTO WEB_END
IF NOT EXIST %proof% GOTO PROOF

SET xsl=%split_dir_in%section.xsl
SET source=%proof%
SET dest=%sectioned%
ECHO  - sectioning
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %sectioned% GOTO ERROR

:WEB_END
IF NOT EXIST %web% GOTO ERROR
IF "%type%"=="web" GOTO END


:ENROLLING-NOW
:ENROLLING-SOON
::----------------------------------------------
IF EXIST %enrolling-sectioned% GOTO ENROLLING_END
IF NOT EXIST %proof% GOTO PROOF

SET xsl=%split_dir_in%enroll.xsl
SET source=%proof%
SET dest=%enrolling%
ECHO  - enrolling
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %enrolling% GOTO ERROR

SET xsl=%split_dir_in%section.xsl
SET source=%enrolling%
SET dest=%enrolling-sectioned%
ECHO  - sectioning
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %enrolling-sectioned% GOTO ERROR

IF (%mode%)==(debug) GOTO ENROLLING_END
DEL %enrolling%

:ENROLLING_END
IF NOT EXIST %enrolling-sectioned% GOTO ERROR
IF "%type%"=="enrolling-now" GOTO END
IF "%type%"=="enrolling-soon" GOTO END


:default
::----------------------------------------------
ECHO Unknown type.
GOTO END


:ERROR
ECHO Unable to split data.
ECHO.
GOTO END


:SYNTAX
ECHO Syntax: %0 {semester} {year} {format}
ECHO.
GOTO END

:END
ECHO Finished.
ECHO.