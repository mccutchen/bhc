@REM Assumes that java is somewhere on %PATH%

@ECHO Running chatter aio...
@python -m chatter_aio
@ECHO Finished.
@PAUSE

@ECHO Running transformation...
@java -jar C:\saxon\saxon8.jar -o chatter.raw.html source\chatter.raw.xml chatter.xsl
@ECHO Finished.

@ECHO Cleaning up...
@python -m clean_asp
@ECHO Finished.

@PAUSE