@ECHO OFF

:: Step 1: Set Variables

CALL config



:: Step 2: Clean Data Directory

CALL clean



:: Step 3: Fetch New Data

CD %py_dir_in%
python -m update %py_dir_out%%data_dir_in% -no_pause
CD %py_dir_out%


:END
IF "%pause%"=="" PAUSE