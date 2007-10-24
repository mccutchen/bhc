@ECHO OFF

SET dir=..\data
SET year=2007
SET sem=Fall
SET abbr=FA

SET source=%dir%\schedule-200-%year%%abbr%.xml
SET fix=%dir%\%year%-%sem%_fixed.xml
SET form=%dir%\%year%-%sem%_formed.xml

SET compare=%dir%\%year%-%sem%_compare.txt

ECHO Error-checking %sem% %year%...
python -m xml-compare %source% %fix% %form% %compare%
ECHO Finished
ECHO.

PAUSE