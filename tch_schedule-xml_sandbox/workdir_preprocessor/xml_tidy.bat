@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o tidy_FA.xml flat_FA.xml xml_tidy.xsl
@ECHO Finished.
@PAUSE