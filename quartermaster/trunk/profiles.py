"""
$Id: profiles.py 1619 2005-11-08 17:22:03Z wrm2110 $

(Stolen from Son-of-Schedulebuilder)

Provides a set of configuration classes which
control the execution of Quartermaster.

When loaded, this module looks for a profile name
as the first argument given to the program (which
is sys.argv[1]).  If no argument is given, or if
an invalid profile name is given, a ProfileError
is raised.

BaseProfile should be subclassed to produce a
valid, working profile.  The generic Print, Web
and RoomCoordinator profiles may be subclassed
to provide semester- or term-specific profiles.
"""

import inspect, os, sys

class ProfileError(Exception):
    pass

class BaseProfile:
    """
    Base profile class, which contains all of
    the settings a profile needs.
    """
    
    # the location of the input database and the
    # table to use inside the database
    database_path = 'data/CE Web Data.mdb'
    database_table = None
    
    # the location of the template to be used to
    # transform the XML output
    template = None
    
    # the directory to store the final output in
    output_dir = None
    
    # the filename of the XML output to produce
    output_xml_path = 'schedule.xml'
    
    # the encoding of the XML output
    output_xml_encoding = 'utf-8'
    
    # after what hour are classes considered to be
    # evening classes?
    evening_threshold = 6
    
    # default values for fields
    defaults = {
        'faculty': 'TBA',
    }
    
    # where is the Saxon jar file located?
    saxon_path = os.name == 'posix' and os.path.expanduser('~/src/saxon/saxon8.jar') or 'C:/saxon/saxon8.jar'


class Print(BaseProfile):
    database_table = '[CE Print Schedule]'
    template = 'templates/print.xsl'

class Web(BaseProfile):
    template = 'templates/web.xsl'
    database_table = '[CE Web Schedule]'

# Choose the default profile
Default = Web

##########################################
## Custom profiles for particular terms ##
##########################################
class Spring2006Print(Print):
    database_path = 'data\2006-spring-print.mdb'


##########################
## Initialization stuff ##
##########################
def is_valid_profile(obj):
    """Is this a valid profile?"""
    if inspect.isclass(obj) and issubclass(obj, BaseProfile):
        return True
    return False

# put each valid profile into a dictionary keyed
# on its name
validprofiles = dict(
    ((key, value)
    for key,value in globals().items()
    if is_valid_profile(value))
)


# figure out which profile was selected on the command line,
# defaulting to Default if no profile was selected or if an
# unknown profile was selected
try:
    profilename = sys.argv[1]
    profile = validprofiles[profilename]
except IndexError:
    print >> sys.stderr, 'No profile given; using default profile: %s' % Default
    profile = Default
except KeyError:
    raise ProfileError, 'Invalid profile name given: %s.  (Valid profile names: %s)' % (sys.argv[1], ', '.join(validprofiles.keys()))


if __name__ == '__main__':
    print 'Valid profiles: %s' % ', '.join(validprofiles.keys())
    print 'Chosen profile: %s' % profile
