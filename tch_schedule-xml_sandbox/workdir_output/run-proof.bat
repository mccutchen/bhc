@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o saxon-output.txt schedule_FA_new.xml proof.xsl
@ECHO Finished.
@PAUSE
