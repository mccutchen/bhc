@ECHO OFF

SET pause=no-pause

:: Step 1: Fetch New Data

CALL 1_fetch-dsc-xml



:: Step 2: Run the usual

CALL 2_generate-output Summer 2008 web
CALL 2_generate-output Summer 2008 enrolling-now
CALL 2_generate-output Spring 2009 proof


:: Done
PAUSE