@echo off

rem ===================================================================
rem Settings
rem ===================================================================

rem Where are the preprocessors located (no trailing slash)
set PREPROCESSOR_PATH=preprocessors

rem Where to find the list of preprocessors to run (this should be a
rem file with one preprocessor name per line)
set PREPROCESSOR_ORDER=%PREPROCESSOR_PATH%\ORDER.txt

rem Where is Saxon located?
set SAXON_PATH=C:\saxon\saxon8.jar

rem Where should the output go?
set SCHEDULE_FILE=schedule.xml

rem Set the default input path
set INPUT_PATH=input\schedule-200-2007SP.xml

rem If an input path was given on the command line, use it
if exist %1 set INPUT_PATH=%1


rem ===================================================================
rem Run
rem ===================================================================

echo Preprocessing Rik's ScheduleXML...
echo.

rem First, copy Rik's original schedule to a new location
echo Copying input file %INPUT_PATH%...
copy %INPUT_PATH% %SCHEDULE_FILE% > garbage.txt && del garbage.txt
echo.

rem Loop through each of the preprocessors defined in the file found
rem at %PREPROCESSOR_ORDER%
echo Running preprocessors...
for /F %%P in (%PREPROCESSOR_ORDER%) do echo - %%P.xsl && java -jar %SAXON_PATH% -o %SCHEDULE_FILE% %SCHEDULE_FILE% %PREPROCESSOR_PATH%/%%P.xsl
echo Finished.
echo.

echo Testing...
python test.py %INPUT_PATH% %SCHEDULE_FILE% && echo Passed!

pause
