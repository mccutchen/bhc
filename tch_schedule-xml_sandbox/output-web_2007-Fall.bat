::Assumes that java is somewhere on %PATH%
@ECHO OFF

SET xsl=web
SET year=2007
SET sem=Fall
SET dir=data

SET input=%dir%\%year%-%sem%.xml


ECHO Running transformation...
java -jar C:\saxon\saxon8.jar -o no-file.txt %input% output-%xsl%.xsl
ECHO Finished
ECHO.
PAUSE
