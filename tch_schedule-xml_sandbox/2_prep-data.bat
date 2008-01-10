@ECHO OFF

:: Step 1: Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2: Set Variables
CALL config



:: Step 3: Prepare the Data

:: Syntax: CALL %prep_bat% {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {year} is a valid, 4-digit year

CALL %prep_bat% %1 %2



:: Step 4: Split the Data

:: Syntax: CALL %split_bat% {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {year} is a valid, 4-digit year

CALL %split_bat% %1 %2


GOTO END


:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: 2_prep-data.bat {semester} {year}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year


:END
IF "%pause%"=="" PAUSE