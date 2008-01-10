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
SET splitter=%split_dir_in%


::================================================::
:: File setup					  ::
::================================================::

SET base=%data%%ys%.xml
SET trimmed=%data%%ys%_trimmed.xml
SET split=%data%%ys%_split.xml
SET sorted=%data%%ys%_sorted.xml
SET sectioned=%data%%ys%_sectioned.xml
SET enrolling=%data%%ys%_enrolling.xml
SET enrolling-sectioned=%data%%ys%_enrolling-sectioned.xml