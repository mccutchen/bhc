@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug


:: Step 1, Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2, Set Variables

SET type=enrolling
SET year=%1
SET sem=%2
SET ys=%year%-%sem%

SET data=data
SET split=xml-split
SET trans=xml-transform


ECHO Generating %type% output for %sem% %year%
ECHO ----------------------------------------


:: Step 3: Pre-Format the Data

:: A. Trim

SET step=1
SET splitter=trim
SET text=Trimming data
SET format=%type%_%step%-%splitter%

SET source=%data%\%ys%.xml
SET dest1=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest1% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: B. Enrolling

ECHO Fetching todays date...
SET date=%data%\%ys%_date.xml
python -m get-date %date%
ECHO Finished
ECHO.

SET step=2
SET splitter=enroll
SET text=Limiting to enrolling data
SET format=%type%_%step%-%splitter%

SET source=%dest1%
SET dest2=%data%\%ys%_%format%.xml

ECHO %text%...
SET params=date-path=../%date%
java -jar C:\saxon\saxon8.jar -o %dest2% %source% %split%\xml-%splitter%.xsl %params%
ECHO Finished
ECHO.

:: C. Split

SET step=3
SET splitter=split
SET text=Splitting courses

SET format=%type%_%step%-%splitter%

SET source=%dest2%
SET dest3=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest3% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: D. Sort

SET step=4
SET splitter=sort
SET text=Sorting data

SET format=%type%_%step%-%splitter%

SET source=%dest3%
SET dest4=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest4% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.

:: E. Special Sections

SET step=5
SET splitter=special
SET text=Inserting Special Sections

SET format=%type%_%step%-%splitter%

SET source=%dest4%
SET dest5=%data%\%ys%_%format%.xml

ECHO %text%...
java -jar C:\saxon\saxon8.jar -o %dest5% %source% %split%\xml-%splitter%.xsl
ECHO Finished
ECHO.


:: Step 4, Produce Output

SET text=Producing output

SET source=%dest5%
SET dest=no-file.txt

ECHO %text%...
SET params="schedule-type=Enrolling Soon"
java -jar C:\saxon\saxon8.jar -o %dest% %source% %trans%\output-%type%.xsl %params%
ECHO Finished
ECHO.


:: Step 5, clean up

ECHO Cleaning up...
IF (%mode%)==(debug) GOTO FINISH
DEL %dest1%
DEL %dest2%
DEL %dest3%
DEL %dest4%
DEL %dest5%

:FINISH
ECHO Finished
ECHO.
GOTO END

:SYNTAX
ECHO Syntax: {filename}.bat {year} {semester}
ECHO.

:END