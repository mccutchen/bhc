import sys

#    These are the settings for whitepages (the Intranet
#    staff directory builder).
#    
#    There are a few things to know if you are going to
#    change any of these settings:
#        
#        1) Anything that is not a number must be wrapped
#        in quotes:
#            directory = 'output' <- Good
#            directory = output <- Bad!
#            
#        2) Anything following a # is a comment, and is only
#        there to provide you with extra information.  I've put
#        comments before all of the important lines, to help
#        you understand this file, in case you need to make changes.

class database:
    # the path to the database
    path = 'employees_db.mdb'
    
    # the name of the table in the database
    tablename = 'BrookhavenEmployees'
    
    # character encoding used by the database
    encoding = 'windows-1252'

class output:
    # the name of the folder to store the output in
    directory = 'output'
    
    class html:
        # The prefix to use for the file names
        prefix = 'sdir_'
        
        # The suffix, including file extension, to use for the file names
        suffix = '.html'

class portraits:
    # the absolute path to where the images are stored on the server,
    # minus the http://intranet.dcccd.edu part.
    location = '/images/bhc/sdir/'


# You can probably safely ignore anything below here
class templates:
    xsl = 'templates/template.xsl'

class log:
    info = sys.stdout

class extras:
    sourcedir = 'templates'
    patterns = 'sdir.html css/*.css'