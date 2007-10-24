@ECHO OFF

SET dir=..\data
SET map=..\mappings
SET year=2007
SET sem=Fall

SET source=%dir%\%year%-%sem%.xml
SET trim=%dir%\%year$-%sem%_trimmed.xml
SET enroll=%dir%\%year$-%sem%_enrolling.xml

SET info=%map%\%year%-%sem%\base.xml

ECHO Trimming %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %trim% %form% xml-trim.xsl
ECHO Finished
ECHO.

ECHO Enrolling %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %enroll% %trim% xml-enroll.xsl
ECHO Finished
ECHO.

PAUSE