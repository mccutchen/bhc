@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o test.html test.xml test.xsl
@ECHO Finished.
@PAUSE