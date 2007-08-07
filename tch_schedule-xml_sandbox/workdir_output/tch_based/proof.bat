@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o proof.txt tidy_FA.xml proof.xsl
@ECHO Finished.
@PAUSE
