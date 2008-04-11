::================================================::
:: Semester / Year setup			  ::
::================================================::

SET setup=true


:CHECK-YS
IF "%1"=="" GOTO NO-YS
IF "%2"=="" GOTO NO-YS
SET default-return=NO-YS
GOTO %1
:fall
SET schedule=normal
SET abbr=FA
SET abbr2=
GOTO GOOD-YS
:spring
SET schedule=normal
SET abbr=SP
SET abbr2=
GOTO GOOD-YS
:summer
SET schedule=summer
SET abbr=S1
SET abbr2=S2
GOTO GOOD-YS

:GOOD-YS
SET Semester=%1
SET Year=%2
SET ys=%year%-%semester%

:CHECK-TYPE
SET default-return=NO-TYPE
IF NOT "%3"=="" GOTO %3
GOTO NO-TYPE
:rooms
:print
:print-InDesign
:proof
:proof-full
:web
:enrolling-now
:enrolling-soon
SET type=%3
GOTO DIR_SETUP


:default
GOTO %default-return%

:NO-YS
SET Semester=
SET Year=
SET ys=
GOTO END

:NO-TYPE
SET type=
GOTO DIR_SETUP



:DIR_SETUP
::================================================::
:: Directory setup				  ::
::================================================::

SET data=%data_dir_in%
SET py=%py_dir_in%
SET map=%map_dir_in%
SET map_sem=%map%%ys%\



:FILE_SETUP
::================================================::
:: File setup					  ::
::================================================::

SET core=%map%core.xml
SET sortkeys=%map%sortkeys.xml
SET base=%map_sem%base.xml

SET default-return=END
IF NOT "%schedule%"=="" GOTO %schedule%
:Normal
SET raw=%data%schedule-200-%year%%abbr%.xml
SET raw2=
GOTO SCHEDULE-END
:Summer
SET raw=%data%schedule-200-%year%%abbr%.xml
SET raw2=%data%schedule-200-%year%%abbr2%.xml
:SCHEDULE-END

SET mappings=%data%%ys%_mappings.xml
SET compare=%data%%ys%_compare.txt
SET fixed=%data%%ys%_fixed.xml
SET formed=%data%%ys%_formed.xml
SET meetings=%data%%ys%_meetings.xml

SET trimmed=%data%%ys%_trimmed.xml
SET split=%data%%ys%_split.xml
SET sorted=%data%%ys%_sorted.xml
SET linked=%data%%ys%_linked.xml
SET sectioned=%data%%ys%_sectioned.xml
SET enrolled=%data%%ys%_enrolled.xml

SET final=%meetings%
SET current=%sectioned%
SET enrolling=%enrolled%


IF "%type%"=="" GOTO NO-FILE
SET default-return=NO-FILE
GOTO %type%
:rooms
SET file=%final%
GOTO END
:print
:print-InDesign
SET file=%current%
GOTO END
:proof
:proof-full
SET file=%current%
GOTO END
:web
SET file=%current%
GOTO END
:enrolling-now
SET file=%enrolling%
GOTO END
:enrolling-soon
SET file=%enrolling%
GOTO END

:NO-FILE
SET file=
GOTO END


:END