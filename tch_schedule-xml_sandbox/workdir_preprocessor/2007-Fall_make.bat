@REM Assumes that java is somewhere on %PATH%

@ECHO Flattening Fall...
@java -jar C:\saxon\saxon8.jar -o output\2007-Fall_flat.xml data\schedule-200-2007FA.xml flatten_xml.xsl semester=Fall year=2007
@ECHO Finished.
@ECHO .

@ECHO Tidying Fall...
@java -jar C:\saxon\saxon8.jar -o output\2007-Fall_tidy.xml output\2007-Fall_flat.xml tidy_xml.xsl semester=Fall year=2007
@ECHO Finished.
@ECHO .

@ECHO Error-checking Spring...
@python -m class-compare data/schedule-200-2007FA.xml output/2007-Fall_flat.xml output/2007-Fall_tidy.xml Fall 2007
@ECHO Finished.
@ECHO .

@PAUSE