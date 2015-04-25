@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o saxon-output.txt ../base-schedule.xml room-coordinator.xsl
@ECHO Finished.
@PAUSE