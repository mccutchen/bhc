@ECHO OFF

SET data=data
SET year=2007
SET sem=Summer
SET abbr1=S1
SET abbr2=S2

SET source1=%data%\schedule-200-%year%%abbr1%.xml
SET source2=%data%\schedule-200-%year%%abbr2%.xml
SET fix=%data%\%year%-%sem%_fixed.xml
SET form=%data%\%year%-%sem%_formed.xml

SET compare=%data%\%year%-%sem%_compare.txt

ECHO Error-checking %sem% %year%...
python -m compare %source1% %source2% %fix% %form% %compare%
ECHO Finished
ECHO.

PAUSE