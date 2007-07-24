@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o summer_i.html schedule-200-2007S1.xml xml_tidy.xsl
@ECHO Finished.
@PAUSE