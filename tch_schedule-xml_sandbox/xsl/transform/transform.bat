@ECHO OFF

:: Step 1: Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2: Set Variables

CALL %transform_dir_in%config %1 %2 %3



:: Step 3: Generate output
SET source=%data%%ys%_%type%.xml
SET dest=no-file.txt

ECHO Generating %format% output for %sem% %year%
GOTO %format%

:rooms
:print
:proof
:web
java -jar C:\saxon\saxon8.jar -o %dest% %source% %trans%output-%type%.xsl
GOTO END

:enrolling now
:enrolling soon
java -jar C:\saxon\saxon8.jar -o %dest% %source% %trans%output-%type%.xsl %params%
GOTO END

:END
ECHO Finished