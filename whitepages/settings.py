import os

# the path to the database
database_path = 'H:\IAA\PI\Shared Folder\Employee Database and Org Charts\employees_db.mdb'

# the name of the table in the database
database_tablename = 'BrookhavenEmployees'

# character encoding used by the database
database_encoding = 'windows-1252'

# The prefix to use for the file names
output_html_prefix = 'sdir_'

# The suffix, including file extension, to use for the file names
output_html_suffix = '.html'

# Where to write the intermediate XML file
output_xml_path = 'whitepages.xml'

# the absolute path to where the images are stored on the server,
# minus the http://intranet.dcccd.edu part.
portraits_location = '/images/bhc/sdir/'

# XSLT template to use
templates_xsl = 'templates/template.xsl'

# Where to find saxon8.jar
saxon_path = os.name == 'posix' and \
    os.path.expanduser('~/src/saxon/saxon8.jar') or \
    'C:/saxon/saxon8.jar'
