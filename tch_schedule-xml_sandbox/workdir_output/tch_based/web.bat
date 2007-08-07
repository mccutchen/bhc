@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o web.txt tidy_FA.xml web.xsl
@ECHO Finished.
@PAUSE
