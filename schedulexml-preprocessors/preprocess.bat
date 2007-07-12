@echo off

rem ===================================================================
rem Settings
rem ===================================================================

rem The list of preprocessors to run
set PREPROCESSORS=(remove-locations divisions-1 divisions-2 subjects-1 subjects-2 types-1 types-2 consolidate-descriptions)

rem Where are the preprocessors located (no trailing slash)
set PREPROCESSOR_PATH=preprocessors

rem Where is Saxon located?
set SAXON_PATH=C:\saxon\saxon8.jar

rem Where should the output go?
set SCHEDULE_FILE=schedule.xml

rem Where is Rik's input file?
set INPUT_PATH=input\schedule-200-2007SP.xml


rem ===================================================================
rem Run
rem ===================================================================

echo Preprocessing Rik's ScheduleXML...
echo.

rem First, copy Rik's original schedule to a new location
echo Copying input...
copy %INPUT_PATH% %SCHEDULE_FILE% > garbage.txt && del garbage.txt
echo.

rem Loop through each of the %PREPROCESSORS%
echo Running preprocessors...
for %%P in %PREPROCESSORS% do echo - %%P.xsl && java -jar %SAXON_PATH% -o %SCHEDULE_FILE% %SCHEDULE_FILE% %PREPROCESSOR_PATH%/%%P.xsl
echo Finished.
echo.

echo Testing...
python test.py %INPUT_PATH% %SCHEDULE_FILE% && echo Passed!

pause