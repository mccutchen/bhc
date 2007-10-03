@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o proof.txt data\2007-Fall_tidy.xml proof.xsl year=2007 semester=Fall
@ECHO Finished.
@PAUSE
