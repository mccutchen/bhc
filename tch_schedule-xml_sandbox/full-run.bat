@ECHO OFF

:: Step 1: Check Parameters

if "%1"=="" GOTO SYNTAX
if "%2"=="" GOTO SYNTAX


:: Step 2: Set Variables
CALL config



:: Step 3: Fetch New Data

CD %py_dir_in%
python -m update %py_dir_out%%data_dir_in% -no_pause
CD %py_dir_out%



:: Step 4: Prepare the Data

:: Syntax: CALL %prep_bat% {semester} {year}
:: where {semester} = Summer, Spring, or Fall

CALL %prep_bat% %1 %2



:: Step 5: Split the Data

:: Syntax: CALL %split_bat% {semester} {year}
:: where {semester} = Summer, Spring, or Fall

CALL %split_bat% %1 %2



:: Step 6: Generate Output

:: Syntax: CALL %transform_bat% {output} {semester} {year}
:: where {semester} = Summer, Spring, or Fall
:: and   {output}   = proof, print, rooms, web, enroll
::                    enrolling-now, enrolling-soon
:: NOTE: enroll is the same as enrolling-now

CALL %transform_bat% rooms          %1 %2
CALL %transform_bat% print          %1 %2
CALL %transform_bat% proof          %1 %2
CALL %transform_bat% web            %1 %2
CALL %transform_bat% enrolling-now  %1 %2
CALL %transform_bat% enrolling-soon %1 %2

GOTO END


:SYNTAX
ECHO Invalid syntax.
ECHO Syntax: %0 {semester} {year}
ECHO where {semester} = Summer, Spring, or Fall
ECHO and   {year} is a valid, 4-digit year


:END
PAUSE