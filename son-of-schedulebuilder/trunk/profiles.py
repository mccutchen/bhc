"""profiles.py

Provides a set of configuration classes which
control the execution of son-of-schedulebuilder.

CreditProfile should be subclassed to produce a
valid, working profile.  The generic Print, Web
and RoomCoordinator profiles may be subclassed
to provide semester- or term-specific profiles."""

import glob, inspect, os, re, sys
from datetime import date
from wrm.profile import BaseProfile, ProfileError, get_profile

PROFILES = {}

class CreditProfileMeta(type):
    """Metaclass for CreditProfile classes which correctly propagates the
    saxon_params setting for inherited classes and derives a large set of 
    specialized profiles for each term's base profile."""
    
    def __init__(cls, name, bases, dct):
        super(CreditProfileMeta, cls).__init__(name, bases, dct)
            
        # Set up Saxon params dict by merging the params defined in all of
        # this class's base classes
        params = {}
        for base in bases:
            if hasattr(base, 'saxon_params'):
                params.update(base.saxon_params)
        # Make sure to use this class's saxon_params last, so they take
        # precedence.
        params.update(dct.get('saxon_params', {}))
        
        # Set the 'output-directory' Saxon param automagically
        if len(bases) > 1:
            output_dir = '-'.join(base.__name__.lower() for base in bases)
        elif len(bases) == 1:
            output_dir = '%s-%s' % (name.lower(), bases[0].__name__.lower())
        else:
            output_dir = name.lower()
        params.update({'output-directory': output_dir})
        
        # Set the final Saxon params on the class
        cls.saxon_params = params
        
        # If we are creating a basic term profile (eg Fall08), create a set
        # of specialized profiles for that term as well
        if re.match(r'^(Spring|Summer|Fall)\d{2}$', name):
            PROFILES[name] = cls
            cls.derive_profiles()
    
    def derive_profiles(cls):
        """Derives a set of specialized profiles for the given base profile,
        which should be a basic term profile (eg, Spring07, Fall08)."""
        name = cls.__name__
        
        # Create the 'basic' profiles for this term
        proof = make_credit_profile('%sProof' % name, cls, 'Proof')
        fullproof = make_credit_profile('%sFullProof' % name, cls, 'FullProof')
        rooms = make_credit_profile('%sRooms' % name, cls, 'RoomCoordinator')
        prnt = make_credit_profile('%sPrint' % name, cls, 'Print')
        web = make_credit_profile('%sWeb' % name, cls, 'Web')
        
        # Create more profiles for this term based on the 'basic' profiles
        # above.
        enrolling = make_credit_profile('%sEnrolling' % name, web, 'Enrolling')
        coreproof = make_credit_profile('%sCoreProof' % name, proof, 'CoreOnly')
        coreprint = make_credit_profile('%sCorePrint' % name, prnt, 'CoreOnly')
        noncoreproof = make_credit_profile('%sNonCoreProof' % name, proof, 'NonCore')
        noncoreprint = make_credit_profile('%sNonCorePrint' % name, prnt, 'NonCore')        

def make_credit_profile(name, *bases):
    """Function that will create a new class with the given name and
    with the given bases.  If the given bases are not already CreditProfile
    objects, they will be looked up in the global PROFILES dict first, then
    in the globals() dict."""

    def get_base(base):
        if isinstance(base, basestring):
            # Try to look up the base class in PROFILES and globals()
            if base in PROFILES:
                base = PROFILES[base]
            elif base in globals():
                base = globals()[base]
            else:
                raise ProfileError('Creating profile %s:  Could not find base class %s' % (name, base))
        
        # If we don't have a valid base profile here, something is wrong
        if not isinstance(base, (CreditProfile, CreditProfileMeta)):
            raise ProfileError('The given base class, %s, is not a valid base class (%s)' % (base, type(base)))
        return base

    base_objs = tuple(get_base(base) for base in bases)
    c = type(name, base_objs, {})
    PROFILES[c.__name__] = c
    return c

class CreditProfile(BaseProfile):
    """
    Base profile class, which contains all of
    the settings a profile needs.
    """
    
    __metaclass__ = CreditProfileMeta

    # the location of the input data (either a
    # string or a tuple of strings)
    input = None

    # the location of the template to be used to
    # transform the XML output
    template = None

    # the filename of the XML output to produce
    output_xml_path = 'base-schedule.xml'

    # the path to an XML file which will supply any
    # additional mappings needed for this profile
    mappings_dir = 'mappings/'
    additional_mappings = None

    # A dict mapping term names to term dates; values must two date objects
    # for the start and end dates.  Example:
    # terms = {
    #     'Spring': (date(2005,12,1), date(2006,5,15)),
    # }
    terms = {}

    # whether or not to do any of the fancy regrouping
    # work required for a complete schedule
    regroupings = False

    # whether or not to build the <special-section>
    # elements (Minimesters, Distance Learning,
    # Weekend, etc.)
    special_sections = False

    # the minimester cutoff:  any class that lasts
    # fewer than this many weeks is a minimester
    minimester_threshold = 15

    # Dictionaries used to match particular fields in the
    # "class record" dict against a list of patterns.  The
    # keys in the dictionaries are used as keys in the class
    # record and the class record's value is matched against
    # the list of regular expressions provided.
    skip_minimesters = {
        'rubrik': ['EMSP', 'RADR', 'RNSG', 'HPRS'],
        'topic-code': ['^E$'],
    }
    skip_cross_listings = {
        'rubrik': ['EMSP'],
    }

    # a list of topic codes to skip
    # (generally out of XX, YY and ZZ)
    skip_topic_codes = []

    # If this is a valid datetime.date object, only classes which
    # begin after this date will be included in the schedule.  This
    # will also cause the web schedule to become an "Enrolling Now--"
    # schedule
    include_classes_after = None

    # should the schedule include only Core Curriculum courses?
    core_only_schedule = False

    # should the schedule include only non-Core Curriculum courses?
    non_core_schedule = False

    # default values for fields
    defaults = {
        'schedule_type': 'UNKNOWN',
        'faculty': 'Staff',
        'type': 'Unknown',
        'time': 'TBA',
        'division': 'Unknown',
        'days': 'TBA',
        'room': 'TBA',
    }
    
    # Maps given rooms to what they should be replaced with.  Used to handle
    # the transition to the new topic codes for online and video-based courses
    room_map = {
        'INET': 'OL',
        'TV': 'VB',
        'TVP': 'VB',
    }

    ###########################################
    # Generally static settings which you may #
    # ignore unless you have special needs    #
    ###########################################

    # A list of duplicated last names; any instructor
    # with a last name in this list should appear with
    # their first initial.  Generated by the script
    # data/analyzers/teachernames.py
    duplicate_names = ['Adams', 'Anderson', 'Bright', 'Brooks', 'Brown', 'Burton', 'Campbell', 'Clark', 'Collins', 'Cross', 'Douglas', 'Evans', 'Fernandez', 'Fleming', 'Garcia', 'Gorman', 'Hammond', 'Hardy', 'Hathaway', 'Hueston', 'Jackson', 'Johnson', 'Jones','Lane', 'Lewis', 'Lynch', 'Martin', 'Maxey', 'Meyer', 'Milian', 'Miller', 'Moore', 'Nelson', 'Nguyen', 'Odom', 'Owens', 'Page', 'Riley', 'Robinson', 'Schmidt','Scott', 'Sims', 'Smith', 'Thomas', 'Thompson', 'Thornton', 'Walker', 'Weaver','Wood']

    # where to find the XSL post-processing templates
    post_processor_dir = 'xsl/post-processors/'

    # the names of the post-processing templates
    post_processors = [
        'base.xsl',
    ]

    # where is the Saxon jar file located?
    saxon_path = os.name == 'posix' and os.path.expanduser('~/src/saxon/saxon8.jar') or 'C:/saxon/saxon8.jar'

    # what parameters should we pass to Saxon?
    saxon_params = {}
    
    # a list of errors to report to the user
    errors = set()


class FullProfile(CreditProfile):
    output_xml_path = 'schedule.xml'
    regroupings = True
    special_sections = True
    skip_topic_codes = 'XX YY'.split()
    post_processors = [
        'types.xsl',
        'groups.xsl',
        'contact-info.xsl',
        'senior-adults.xsl',
        'special-sections.xsl',
        'sortkeys.xsl',
    ]

class Proof(FullProfile):
    template = 'xsl/proof.xsl'
    saxon_params = {'for-secretaries': 'true'}

class FullProof(Proof):
    saxon_params = {'for-secretaries': 'false', 'with-highlighted-groups': 'true'}

class Print(FullProfile):
    template = 'xsl/print.xsl'
    output_dir = 'print-output'

class Web(FullProfile):
    template = 'xsl/web.xsl'
    output_dir = 'web-output'

class RoomCoordinator(CreditProfile):
    template = 'xsl/room-coordinator.xsl'
    skip_topic_codes = []
    regroupings = False
    special_sections = False
    post_processors = ['base.xsl']

# Base classes for specific terms
class Fall(CreditProfile):
    additional_mappings = 'fall.xml'
class Spring(CreditProfile):
    additional_mappings = 'spring.xml'
class Summer(CreditProfile):
    additional_mappings = 'summer.xml'
    minimester_threshold = None # Summer terms are too short to have minimesters

# Base classes for certain specialty output types
class Enrolling(CreditProfile):
    include_classes_after = date.today();
    saxon_params = {'enrolling-now': 'true'}
class CoreOnly(CreditProfile):
    core_only_schedule = True
class NonCore(CreditProfile):
    non_core_schedule = True


# ===================================================================
# Fall 2005 profiles
# ===================================================================
class Fall05(Fall):
    input = 'data/2005-fall/latest.txt'
    terms = {
        'Fall': (),
    }

# ===================================================================
# Spring 2006 profiles
# ===================================================================
class Spring06(Spring):
    input = 'data/2006-spring/latest.txt'
    terms = {
        'Spring': (date(2005,12,1), date(2006,5,15), 'TERM DATES'),
    }
    saxon_params = {'schedule-title': 'Spring 2006 Credit'}

# ===================================================================
# Summer 2006 profiles
# ===================================================================
class Summer06(Summer):
    input = 'data/2006-summer/latest.txt'
    terms = {
        'Summer I/May Term': (date(2006,5,15), date(2006,6,2), 'TERM DATES'),
        'Summer I': (date(2006,6,5), date(2006,7,6), 'TERM DATES'),
        'Summer II': (date(2006,7,12), date(2006,8,10), 'TERM DATES'),
    }
    saxon_params = {'schedule-title': 'Summer 2006 Credit'}

# ===================================================================
# Fall 2006 profiles
# ===================================================================
class Fall06(Fall):
    input = 'data/2006-fall/BH2006FA.TXT'
    terms = {
        'Fall': (),
    }
    saxon_params = {'schedule-title': 'Fall 2006 Credit'}

# ===================================================================
# Spring 2007 profiles
# ===================================================================
class Spring07(Spring):
    input = 'data/2007-spring/BH2007SP.TXT'
    terms = {
        'Spring': (),
    }
    saxon_params = {'schedule-title': 'Spring 2007 Credit'}

# ===================================================================
# Summer 2007 profiles
# ===================================================================
class Summer07(Summer):
    input = ('data/2007-summer/bh2007s1.txt', 'data/2007-summer/bh2007s2.txt')
    terms = {
        'Summer I/May Term': (date(2007, 5, 14), date(2007, 6, 1), 'TERM DATES'),
        'Summer I':  (date(2007, 6, 4), date(2007, 7, 3), 'TERM DATES'),
        'Summer II':  (date(2007, 7, 9), date(2007, 8, 9), 'TERM DATES'),
    }
    saxon_params = {'schedule-title': 'Summer 2007 Credit'}

# ===================================================================
# Fall 2007 profiles
# ===================================================================
class Fall07(Fall):
    input = 'data/2007-fall/BH2007FA.TXT'
    terms = {
        'Fall': (date(2007, 8, 27), date(2007, 12, 13), 'TERM DATES'),
    }
    saxon_params = {'schedule-title': 'Fall 2007 Credit'}

# ===================================================================
# Spring 2008 profiles
# ===================================================================
class Spring08(Spring):
    input = 'data/2008-spring/BH2008SP.TXT'
    terms = {
        'Spring': (date(2008, 1, 14), date(2008, 5, 8), 'TERM DATES'),
    }
    saxon_params = {'schedule-title': 'Spring 2008 Credit'}

# ===================================================================
# Summer 2008 profiles
# ===================================================================
class Summer08(Summer):
    input = ('data/2008-summer/bh2008s1.txt', 'data/2008-summer/bh2008s2.txt')
    terms = {
        # original dates
        # Mayterm: 5/12 - 5/30
        # Summer I: 6/9 - 7/3
        # Summer II: 7/9 - 8/7

        'Summer I/May Term': (date(2008, 5, 1), date(2008, 5, 30), 'May 12-May 30'),
        'Summer I':  (date(2008, 6, 1), date(2008, 7, 6), 'June 9-July 3'),
        'Summer II':  (date(2008, 7, 7), date(2008, 8, 8), 'July 9-Aug. 7'),
    }
    saxon_params = {'schedule-title': 'Summer 2008 Credit'}

# ===================================================================
# Fall 2008 profiles
# ===================================================================
class Fall08(Fall):
    input = 'data/2008-fall/BH2008FA.TXT'
    terms = {
        'Fall': (date(2008, 8, 25), date(2008, 12, 11), 'Aug. 25-Dec. 11'),
    }
    saxon_params = {'schedule-title': 'Fall 2008 Credit'}




# ===================================================================
# Profile validator
# ===================================================================

# what attribute are required for this to be a valid profile?
REQUIRED_ATTRS = 'input template output_xml_path mappings_dir terms'.split()

def validate_profile(profile):
    """Tests the given profile to see that it meets a minimum set of
    requirements.
    
    Side effects:  This will make sure that the given profile's input
    attribute is a list of input paths, even if only one input file is
    given."""
    
    name = profile.__name__
    
    for attr in REQUIRED_ATTRS:
        # does the required attribute exist?
        if not hasattr(profile, attr):
            raise ProfileError('Required profile setting is missing: %s' % attr)
        # is it set to a non-None value?
        if getattr(profile, attr) is None:
            raise ProfileError('Required profile setting cannot be None: %s' % attr)
    
    # is profile.input in the correct format?
    if not isinstance(profile.input, (basestring, list, tuple)):
        raise ProfileError('The input setting must be a string or a list \
            of strings representing the path(s) to the Colleague Download\
            File(s) to use.  Given: %r' % profile.input)
    else:
        # fix the input setting so that it is always a list of input paths
        if isinstance(profile.input, basestring):
            profile.input = [profile.input]
    
    # make sure the specified input files exist
    for path in profile.input:
        if not os.path.exists(path):
            raise ProfileError('Input Colleague Download File not found: %s' % path)
    
    # make sure we can find Saxon
    if not os.path.exists(profile.saxon_path):
        raise ProfileError('Cannot find the Saxon XSLT processor at the specified path: %s' % profile.saxon_path)
    
    # make sure the terms dict is properly formatted
    try:
        for term, (start, end, formatted_dates) in profile.terms.items():
            if not isinstance(start, date) or not isinstance(end, date):
                raise ProfileError('Start and end dates in terms setting must be datetime.date objects.  Given %s and %s' % (type(start), type(end)))
            if not isinstance(formatted_dates, basestring):
                raise ProfileError('Formatted dates in terms setting must be a string.  Given %s' % type(formatted_dates))
    except (TypeError, ValueError):
        raise ProfileError('Each value in a profile\'s terms dict must be a 3-tuple of start date, end date, and formatted dates.')
    except AttributeError:
        raise ProfileError('Each profile\'s terms setting must be a dict object.  Given %s' % type(profile.terms))



# ===================================================================
# The actual profile to use
# ===================================================================
profile = get_profile(PROFILES, validate_profile)


if __name__ == '__main__':
    print 'Chosen profile: %s' % profile