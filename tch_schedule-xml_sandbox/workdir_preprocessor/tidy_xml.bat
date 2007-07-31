@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o output\tidy_FA.xml output\flat_FA.xml tidy_xml.xsl
@ECHO Finished.
@PAUSE