@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o print.txt data/2008-Spring_tidy.xml print.xsl output-directory=output/
@ECHO Finished.
@PAUSE
