@REM Assumes that java is somewhere on %PATH%

@ECHO Sorting Fall 2007...
@java -jar C:\saxon\saxon8.jar -o output\2007-Fall_sorted.xml output\2007-Fall_tidy.xml sort_xml.xsl semester=Fall year=2007
@ECHO Finished.

@PAUSE