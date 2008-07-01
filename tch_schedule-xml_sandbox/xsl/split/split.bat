@ECHO OFF

:: Step 1: Check Parameters
::----------------------------------------------
IF NOT "%setup%"=="true" CALL setup %1 %2
IF "%ys%"=="" GOTO SYNTAX


:: Step 2: Check if we're already done
IF NOT EXIST %final% GOTO PREP
IF NOT EXIST %current% GOTO SPLIT
IF NOT EXIST %enrolling% GOTO SPLIT
GOTO END



:: Step 3: Call prep (if necessary)
::----------------------------------------------

:PREP
CALL %prep_bat% %semester% %year%


:: Step 4: Start splitting (if necessary)
::----------------------------------------------

:SPLIT
ECHO.
ECHO Splitting data for %semester% %year%

:: Trim
SET xsl=%split_dir_in%trim.xsl
SET source=%final%
SET dest=%trimmed%
ECHO  - trimming
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %trimmed% GOTO ERROR

:: Split
SET xsl=%split_dir_in%split.xsl
SET source=%trimmed%
SET dest=%split%
ECHO  - splitting
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %split% GOTO ERROR

:: Sort
SET xsl=%split_dir_in%sort.xsl
SET source=%split%
SET dest=%sorted%
ECHO  - sorting
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %sorted% GOTO ERROR

:: Link
SET xsl=%split_dir_in%link.xsl
SET source=%split%
SET dest=%linked%
ECHO  - linking
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %linked% GOTO ERROR

:: Section
SET xsl=%split_dir_in%section.xsl
SET source=%linked%
SET dest=%sectioned%
ECHO  - sectioning
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %sectioned% GOTO ERROR

:: Group
SET xsl=%split_dir_in%group.xsl
SET source=%sectioned%
SET dest=%sectioned-grouped%
ECHO  - grouping sectioned
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %sectioned-grouped% GOTO ERROR

:: Enroll
SET xsl=%split_dir_in%enroll.xsl
SET source=%sectioned%
SET dest=%enrolled%
ECHO  - enrolling
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %enrolled% GOTO ERROR

:: Group
SET xsl=%split_dir_in%group.xsl
SET source=%enrolled%
SET dest=%enrolled-grouped%
ECHO  - grouping enrolled
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%
IF NOT EXIST %enrolled-grouped% GOTO ERROR

IF (%mode%)==(debug) GOTO END
DEL %trimmed%
DEL %split%
DEL %sorted%
DEL %linked%
GOTO END


:SYNTAX
ECHO Syntax: %0 {semester} {year}
ECHO.
GOTO END

:END
ECHO Finished.
ECHO.