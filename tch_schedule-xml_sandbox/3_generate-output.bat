@ECHO OFF

:: Step 1: Check Parameters
IF NOT "%3"=="" GOTO SINGLE-SETUP
SET run-mode=all
:RETURN
IF "%1"=="" GOTO SYNTAX
IF "%2"=="" GOTO SYNTAX

:: Step 2: Set Variables
CALL config
GOTO %run-mode%


:ALL
:: Step 4a: Generate All Output

:: Syntax: CALL %transform_bat% {output} {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {output}   = proof, print, rooms, web, enroll
::                    enrolling-now, enrolling-soon
:: and   {year} is a valid, 4-digit year
:: NOTE: enroll is the same as enrolling-now

CALL %transform_bat% rooms          %1 %2
CALL %transform_bat% print          %1 %2
CALL %transform_bat% proof          %1 %2
CALL %transform_bat% web            %1 %2
CALL %transform_bat% enrolling-now  %1 %2
CALL %transform_bat% enrolling-soon %1 %2

GOTO END


:SINGLE
:: Step 4b: Generate Single Output

:: Syntax: CALL %transform_bat% {output} {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {output}   = proof, print, rooms, web, enroll
::                    enrolling-now, enrolling-soon
:: and   {year} is a valid, 4-digit year
:: NOTE: enroll is the same as enrolling-now

CALL %transform_bat% %output-type% %1 %2

GOTO END


:SINGLE-SETUP
:: Sets the batch for a single-output run
SET output-type=%1
SET run-mode=single
SHIFT /1
GOTO RETURN


:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: %0 {semester} {year} {output}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year


:END
IF "%pause%"=="" PAUSE