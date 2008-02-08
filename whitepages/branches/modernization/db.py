"""db.py sets up the database table to be used throughout Whitepages.  Taken
from Quartermaster."""

import os
from wrm.wrappers import AccessTable

import settings

class DatabaseError(Exception):
    pass

# make sure the database file exists
if not os.path.exists(settings.database_path):
    raise DatabaseError('Could not find the database file at %s' % settings.database_path)

# try to connect to the database
try:
    table = AccessTable(settings.database_path, settings.database_tablename, settings.database_encoding)
except Exception, e:
    raise DatabaseError("""Error opening database at %s.  Make sure the table
defined in the profile (%s) is the correct table.\nException information: %s""" \
        % (settings.database_path, settings.database_tablename, e))
