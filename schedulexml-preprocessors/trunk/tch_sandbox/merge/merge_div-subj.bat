@REM Assumes that java is somewhere on %PATH%
@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o merged-divisions.xml divisions.xml merge_div-subj.xsl
@ECHO Finished.
@PAUSE