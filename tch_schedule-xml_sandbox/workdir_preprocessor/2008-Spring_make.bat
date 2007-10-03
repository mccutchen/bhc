@REM Assumes that java is somewhere on %PATH%

@ECHO Flattening Spring 2008...
@java -jar C:\saxon\saxon8.jar -o output\2008-Spring_flat.xml data\schedule-200-2008SP.xml flatten_xml.xsl semester=Spring year=2008
@ECHO Finished.
@ECHO .

@ECHO Tidying Spring 2008...
@java -jar C:\saxon\saxon8.jar -o output\2008-Spring_tidy.xml output\2008-Spring_flat.xml tidy_xml.xsl semester=Spring year=2008
@ECHO Finished.
@ECHO .

@ECHO Error-checking Spring 2008...
@python -m class-compare data/schedule-200-2008SP.xml output/2008-Spring_flat.xml output/2008-Spring_tidy.xml Spring 2008
@ECHO Finished.
@ECHO .

@PAUSE