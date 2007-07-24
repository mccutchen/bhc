@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o flat.xml schedule-200-2007FA.xml xml_flatten.xsl
@ECHO Finished.
@PAUSE