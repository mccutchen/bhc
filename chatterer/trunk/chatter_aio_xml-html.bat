@REM Assumes that java is somewhere on %PATH%

@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o chatter.raw.html source\chatter.raw.xml chatter.xsl
@ECHO Finished.
@PAUSE