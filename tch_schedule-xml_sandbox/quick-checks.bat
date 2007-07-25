@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o quick-checks.html divisions.xml quick-checks.xsl
@ECHO Finished.
@PAUSE