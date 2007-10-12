:: Assumes that java is somewhere on %PATH%
@ECHO OFF

::Set this to debug in order to keep intermediate files
SET mode=debug

SET dir=mappings
SET year=2007
SET sem=Fall

SET input=%dir%\%year%-%sem%\base.xml
SET output=%dir%\%year%-%sem%_mappings.xml
SET params=semester=%sem% year=%year%


ECHO Flattening %sem% %year%...
java -jar C:\saxon\saxon8.jar -o %output% %input% mappings-combine.xsl %params%
ECHO Finished
ECHO.
PAUSE