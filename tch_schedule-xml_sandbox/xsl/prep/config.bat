::================================================::
:: Year / Semester setup			  ::
::================================================::

SET sem=%1
SET year=%2
SET ys=%year%-%sem%


::================================================::
:: Directory setup				  ::
::================================================::

SET data=%data_dir_in%
SET prep=%prep_dir_in%
SET map=%map_dir_in%
SET py=%py_dir_in%

SET mapdir=%map%\%ys%\


::================================================::
:: File setup					  ::
::================================================::

SET core=%map%core.xml
SET sortkeys=%map%sortkeys.xml
SET basemap=%mapdir%base.xml

SET mappings=%data%%ys%_mappings.xml
SET compare=%data%%ys%_compare.txt
SET fixed=%data%%ys%_fixed.xml
SET formed=%data%%ys%_formed.xml


GOTO SetAbbr
:RETURN



GOTO END
::================================================::
:: FUNCTION: abbreviation & raw datafile setup	  ::
::================================================::

:SetAbbr
GOTO %sem%
:Fall
SET sched=Normal
SET abbr=FA
SET raw=%data%schedule-200-%year%%abbr%.xml
SET raw2=""
GOTO RETURN
:Spring
SET sched=Normal
SET abbr=SP
SET raw=%data%schedule-200-%year%%abbr%.xml
SET raw2=""
GOTO RETURN
:Summer
SET sched=Summer
SET abbr=S1
SET abbr2=S2
SET raw=%data%schedule-200-%year%%abbr%.xml
SET raw2=%data%schedule-200-%year%%abbr2%.xml
GOTO RETURN
:default
ECHO Unknown semester: %sem%
GOTO END

:END