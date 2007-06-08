"""db.py sets up the database table to be used throughout
Quartermaster."""

from wrm.wrappers import AccessTable
from profiles import profile
table = AccessTable(profile.database_path, profile.database_table)
