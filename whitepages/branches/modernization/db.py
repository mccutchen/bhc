"""db.py sets up the database table to be used throughout Whitepages.  Taken
from Quartermaster."""

import os
from wrm.wrappers import AccessTable

import settings

class DatabaseError(Exception):
    pass

# make sure the database file exists
if not os.path.exists(settings.database.path):
    raise DatabaseError('Could not find the database file at %s' % settings.database.path)

# try to connect to the database
try:
    table = AccessTable(settings.database.path, settings.database.table, settings.database.encoding)
except Exception, e:
    raise DatabaseError("""Error opening database at %s.  Make sure the table
defined in the profile (%s) is the correct table.\nException information: %s""" \
        % (settings.database.path, settings.database.table, e))
