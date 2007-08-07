@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o output\flat_FA.xml data\schedule-200-2007FA.xml flatten_xml.xsl semester=Fall year=2007
@ECHO Finished.
@PAUSE