"""baseprofiles.py"""

import glob, inspect, os, re, sys
from datetime import date
from wrm.profile import BaseProfile, ProfileType, ProfileMixin, ProfileError

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
        
        types = get_subclasses_of(ProfileType)
        mixins = get_subclasses_of(ProfileMixin)
        
        # Derive a profile for each available ProfileType
        for t in types:
            classname = '%s%s' % (name, t.__name__)
            c = make_credit_profile(classname, cls, t)
        
        # Define a profile for each ProfileMixin, which are added to
        # certain ProfileTypes according to the applies_to attribute.
        for m in mixins:
            for t in m.applies_to:
                if len(m.applies_to) == 1:
                    classname = '%s%s' % (name, m.__name__)
                else:
                    classname = '%s%s%s' % (name, m.__name__, t.__name__)
                typename = '%s%s' % (name, t.__name__)
                c = make_credit_profile(classname, typename, m)


class CreditProfile(BaseProfile):
    """Base profile class, which contains all of the settings a profile
    needs."""
    
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
    """Sets up a 'full' run of Son of ScheduleBuilder.  Used by most of the
    ProfileTypes below."""
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
        'vita.xsl',
    ]


# Base classes for specific terms
class Fall(CreditProfile):
    additional_mappings = 'fall.xml'
class Spring(CreditProfile):
    additional_mappings = 'spring.xml'
class Summer(CreditProfile):
    additional_mappings = 'summer.xml'
    minimester_threshold = None # Summer terms are too short to have minimesters


# ===========================================================================
# Profile types
# These are used by the CreditProfileMeta class to automatically generate
# a set of profiles for a given term.
# ===========================================================================
class Proof(FullProfile, ProfileType):
    template = 'xsl/proof.xsl'
    saxon_params = {'for-secretaries': 'true'}

class FullProof(Proof, ProfileType):
    saxon_params = {'for-secretaries': 'false', 'with-highlighted-groups': 'true'}

class Print(FullProfile, ProfileType):
    template = 'xsl/print.xsl'
    output_dir = 'print-output'

class Web(FullProfile, ProfileType):
    template = 'xsl/web.xsl'
    output_dir = 'web-output'

class RoomCoordinator(CreditProfile, ProfileType):
    template = 'xsl/room-coordinator.xsl'
    skip_topic_codes = []
    regroupings = False
    special_sections = False
    post_processors = ['base.xsl']


# ===========================================================================
# Profile types
# These specialize the output of the profile types above.  These are also
# used by the metaclass to generate profiles for each term.
# ===========================================================================
class EnrollingNow(CreditProfile, ProfileMixin):
    include_classes_after = date.today();
    saxon_params = {'enrolling': 'Now'}
    applies_to = [Web]
class EnrollingSoon(EnrollingNow):
    saxon_params = {'enrolling': 'Soon'}
class CoreOnly(CreditProfile, ProfileMixin):
    core_only_schedule = True
    applies_to = [Proof, Print, Web]
class NonCore(CreditProfile, ProfileMixin):
    non_core_schedule = True
    applies_to = [Proof, Print, Web]


# ===================================================================
# Profile validator
# ===================================================================

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


# ===========================================================================
# Utility functions
# ===========================================================================
def get_subclasses_of(cls):
    """Returns a list of the subclasses of the given class in the globals() 
    dict.  Does not include the class itself."""
    return [c for (n,c) in globals().items()
            if isinstance(c, type)
            and issubclass(c, cls)
            and not c.__name__ == cls.__name__]

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