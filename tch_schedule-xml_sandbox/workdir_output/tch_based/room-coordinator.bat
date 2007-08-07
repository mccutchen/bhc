@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o room-coordinator.txt tidy_FA.xml room-coordinator.xsl
@ECHO Finished.
@PAUSE
