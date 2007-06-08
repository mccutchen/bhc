"""db.py sets up the database table to be used throughout
Quartermaster."""

import os
from wrm.wrappers import AccessTable
from profiles import profile

class DatabaseError(Exception):
    pass

# make sure the database file exists
if not os.path.exists(profile.database_path):
    raise DatabaseError('Could not find the database file at %s' % profile.database_path)

# try to connect to the database
try:
    table = AccessTable(profile.database_path, profile.database_table)
except:
    raise DatabaseError('Error opening database at %s.  Make sure the table defined in the profile (%s) is the correct table.' \
        % profile.database_path, profile.database_settings)
