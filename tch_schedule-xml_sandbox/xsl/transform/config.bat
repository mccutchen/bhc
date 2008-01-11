::================================================::
:: Year / Semester / Type / Format setup	  ::
::================================================::

SET sem=%2
SET year=%3
SET ys=%year%-%sem%

GOTO SetType
:RETURN



::================================================::
:: Directory setup				  ::
::================================================::

SET data=%data_dir_in%
SET trans=%transform_dir_in%



GOTO END
::================================================::
:: FUNCTION: type and format setup		  ::
::================================================::

:SetType
GOTO %1

:room
:rooms
SET type=rooms
SET format=Rooms
SET params=""
GOTO RETURN

:print
SET type=print
SET format=Print
SET params=""
GOTO RETURN

:proof
SET type=proof
SET format=Proof
SET params=""
GOTO RETURN

:web
SET type=web
SET format=Web
SET params=""
GOTO RETURN

:enrolling
:web-enrolling
:enrolling-now
SET type=web
SET format=Enrolling Now
SET params="schedule-type=Enrolling Now"
GOTO RETURN

:enrolling-soon
SET type=web
SET format=Enrolling Soon
SET params="schedule-type=Enrolling Soon"
GOTO RETURN

:default
ECHO.
ECHO %1 is not a valid transformation
ECHO.

:END