@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug


:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables
CALL %split_dir_in%config %1 %2


ECHO Splitting data for %sem% %year%
ECHO ----------------------------------------


:: Step 3: Create rooms

ECHO Creating Rooms data...
COPY %base% %data%%ys%_rooms.xml >nul
ECHO Finished.
ECHO.



:: Step 4: Create Print

ECHO Creating Print data...

SET xsl=%splitter%xml-trim.xsl
SET source=%base%
SET dest=%trimmed%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

COPY %trimmed% %data%%ys%_print.xml >nul
ECHO Finished
ECHO.



:: Step 5: Create Proof

ECHO Creating Proof data...

SET xsl=%splitter%\xml-split.xsl
SET source=%trimmed%
SET dest=%split%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

SET xsl=%splitter%\xml-sort.xsl
SET source=%split%
SET dest=%sorted%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

COPY %sorted% %data%%ys%_proof.xml >nul
ECHO Finished
ECHO.



:: Step 6: Create Web

ECHO Creating Web data...

SET xsl=%splitter%xml-section.xsl
SET source=%sorted%
SET dest=%sectioned%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

COPY %sectioned% %data%%ys%_web.xml >nul
ECHO Finished
ECHO.



:: Step 7: Create Web-Enrolling

ECHO Creating Web-Enrolling data...

SET xsl=%splitter%xml-enroll.xsl
SET source=%sorted%
SET dest=%enrolling%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

SET xsl=%splitter%\xml-section.xsl
SET source=%enrolling%
SET dest=%enrolling-sectioned%
java -jar C:\saxon\saxon8.jar -o %dest% %source% %xsl%

COPY %enrolling-sectioned% %data%%ys%_web-enrolling.xml >nul
ECHO Finished
ECHO.



:: Step 8: Clean Up

ECHO Cleaning up...
IF (%mode%)==(debug) GOTO FINISH
DEL %trimmed%
DEL %split%
DEL %sorted%
DEL %sectioned%
DEL %enrolling%
DEL %enrolling-sectioned%

:FINISH
ECHO Finished
ECHO.
GOTO END



:SYNTAX
ECHO Syntax: %0 {semester} {year}
ECHO.
GOTO END

:END
