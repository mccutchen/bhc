@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o room-coordinator.txt data/2007-Fall_tidy.xml room-coordinator.xsl
@ECHO Finished.
@PAUSE
