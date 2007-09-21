@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o web.txt data/2007-Fall_tidy.xml web.xsl
@ECHO Finished.
@PAUSE
