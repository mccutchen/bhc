"""profiles.py

Provides a set of configuration classes which
control the execution of son-of-schedulebuilder.

CreditProfile should be subclassed to produce a
valid, working profile.  The generic Print, Web
and RoomCoordinator profiles may be subclassed
to provide semester- or term-specific profiles."""

import datetime, glob, inspect, os, sys
from wrm.profile import BaseProfile, ProfileError, get_profile



class CreditProfile(BaseProfile):
    """
    Base profile class, which contains all of
    the settings a profile needs.
    """

    # the location of the input data (either a
    # string or a tuple of strings)
    input = None

    # the location of the template to be used to
    # transform the XML output
    template = None

    # the directory to store the final output in
    output_dir = None

    # the filename of the XML output to produce
    output_xml_path = 'base-schedule.xml'

    # the path to an XML file which will supply any
    # additional mappings needed for this profile
    mappings_dir = 'mappings/'
    additional_mappings = None

    # dictionary mapping Colleague's term abbreviations
    # to full term names
    term_names = {
        'S1': 'Summer I',
        'S2': 'Summer II',
        'FA': 'Fall',
        'SP': 'Spring',
    }

    # dictionary keyed on term name, used to override the
    # above term names.  For example:
    # term_dates = {
    #   'Summer I/May Term', '05/15/2006-06/02/2006',
    # }
    term_dates = {}

    # dictionary keyed on term name, used to get the
    # "print-ready" term dates
    ap_term_dates = {}

    # dictionary which maps term names to their sort keys,
    # used to arrange terms if there are more than one.
    term_sort_keys = {}

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
    skip_crosslistings = {
        'rubrik': ['PHED'],
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

    ###########################################
    # Generally static settings which you may #
    # ignore unless you have special needs    #
    ###########################################

    # A list of duplicated last names; any instructor
    # with a last name in this list should appear with
    # their first initial.  Generated by the script
    # data/analyzers/teachernames.py
    duplicate_names = ['Anderson', 'Brooks', 'Bryant', 'Burton', 'Campbell', 'Collins', 'Fields', 'Hammond', 'Jackson', 'Johnson', 'Jones', 'Karcher', 'Lynch', 'Maxey', 'Miller', 'Moore', 'Neal', 'Page', 'Robinson', 'Scott', 'Stewart', 'Thomas', 'Thompson', 'Thornton', 'Turner', 'Walker', 'Weaver', 'Wood']

    # where to find the XSL post-processing templates
    post_processor_dir = 'xsl/post-processors/'

    # the names of the post-processing templates
    post_processors = [
        'base.xsl',
    ]

    # where is the Saxon jar file located?
    saxon_path = os.name == 'posix' and os.path.expanduser('~/src/saxon/saxon8.jar') or 'C:/saxon/saxon8.jar'

    # what parameters should we pass to Saxon?
    saxon_params = ''


class FullProfile(CreditProfile):
    output_xml_path = 'schedule.xml'
    regroupings = True
    special_sections = True
    skip_topic_codes = 'XX YY'.split()
    post_processors = [
        'warnings.xsl',
        'types.xsl',
        'groups.xsl',
        'contact-info.xsl',
        'senior-adults.xsl',
        'special-sections.xsl',
        'sortkeys.xsl',
    ]

class Proof(FullProfile):
    template = 'xsl/proof.xsl'
    output_dir = 'proof-output'
    saxon_params = 'for-secretaries="true"'

class FullProof(Proof):
    output_dir = 'full-proof-output'
    saxon_params = 'for-secretaries="false" with-highlighted-groups="true"'

class Print(FullProfile):
    template = 'xsl/print.xsl'
    output_dir = 'print-output'

class Web(FullProfile):
    template = 'xsl/web.xsl'
    output_dir = 'web-output'

class RoomCoordinator(CreditProfile):
    template = 'xsl/room-coordinator.xsl'
    output_dir = 'room-coordinator-output'
    skip_topic_codes = []
    regroupings = False
    special_sections = False
    post_processors = ['base.xsl']

# Base classes for specific terms
class Fall:
    additional_mappings = 'fall.xml'
class Spring:
    additional_mappings = 'spring.xml'
class Summer:
    additional_mappings = 'summer.xml'
    term_sort_keys = {
        'Summer I/May Term': 0,
        'Summer I': 1,
        'Summer II': 2,
    }
    minimester_threshold = None # Summer terms are too short to have minimesters

# Base classes for certain specialty output types
class Enrolling: include_classes_after = datetime.date.today()
class CoreOnly: core_only_schedule = True
class NonCore: non_core_schedule = True


# Choose the default profile
Default = BaseProfile



# ===================================================================
# Fall 2005 profiles
# ===================================================================
class Fall05(Fall):
    input = 'data/2005-fall/latest.txt'

class Fall05Proof(Fall05, Proof):
    output_dir = 'fall05-proof'
    saxon_params = 'for-secretaries="false"'



# ===================================================================
# Spring 2006 profiles
# ===================================================================
class Spring06(Spring):
    input = 'data/2006-spring/latest.txt'
    terms = {
        'Spring': '12/1/2005-05/15/2006',
    }

class Spring06Proof(Spring06, Proof):
    output_dir = 'spring06-proof'
    saxon_params = 'for-secretaries="false"'

class Spring06Print(Spring06, Print):
    output_dir = 'spring06-print'

class Spring06Web(Spring06, Web):
    output_dir = 'spring06-web'
    saxon_params = 'schedule-title="Spring 2006 Credit"'

class Spring06Enrolling(Spring06, Spring06Web, Enrolling):
    output_dir = 'spring06-enrolling'


# ===================================================================
# Summer 2006 profiles
# ===================================================================
class Summer06(Summer):
    input = 'data/2006-summer/latest.txt'
    term_dates = {
        'Summer I/May Term': '05/1/2006-06/2/2006',
    }
    ap_term_dates = {
        'Summer I/May Term': 'May 15-June 2',
        'Summer I': 'June 5-July 6',
        'Summer II': 'July 12-Aug. 10',
    }
    minimester_threshold = None

class Summer06Proof(Summer06, Proof):
    output_dir = 'summer06-proof'

class Summer06Print(Summer06, Print):
    output_dir = 'summer06-print'

class Summer06Rooms(Summer06, RoomCoordinator):
    output_dir = 'summer06-rooms'

class Summer06FullProof(Summer06, FullProof):
    output_dir = 'summer06-full-proof'

class Summer06Web(Summer06, Web):
    output_dir = 'summer06-web'
    saxon_params = 'schedule-title="Summer 2006 Credit"'

class Summer06Enrolling(Enrolling, Summer06, Summer06Web):
    output_dir = 'summer06-enrolling'


# ===================================================================
# Fall 2006 profiles
# ===================================================================
class Fall06(Fall):
    input = 'data/2006-fall/BH2006FA.TXT'
    ap_term_dates = {
        'Fall': '',
    }

class Fall06Proof(Fall06, Proof):
    output_dir = 'fall06-proof'

class Fall06FullProof(Fall06, FullProof):
    output_dir = 'fall06-full-proof'

class Fall06Rooms(Fall06, RoomCoordinator):
    output_dir = 'fall06-rooms'

class Fall06Print(Fall06, Print):
    output_dir = 'fall06-print'

class Fall06Web(Fall06, Web):
    output_dir = 'fall06-web'
    saxon_params = 'schedule-title="Fall 2006 Credit"'

class Fall06Enrolling(Enrolling, Fall06, Fall06Web):
    output_dir = 'fall06-enrolling'

class Fall06CorePrint(CoreOnly, Fall06Print):
    output_dir = 'fall06-core-print'

class Fall06CoreProof(CoreOnly, Fall06FullProof):
    output_dir = 'fall06-core-proof'

class Fall06NonCorePrint(NonCore, Fall06Print):
    output_dir = 'fall06-noncore-print'

class Fall06NonCoreProof(NonCore, Fall06Proof):
    output_dir = 'fall06-noncore-proof'

class Fall06ForSpring07(Fall06Print):
    include_classes_after = datetime.date(2006, 11, 1)
    output_dir = 'fall06-for-spring07'


# ===================================================================
# Spring 2007 profiles
# ===================================================================
class Spring07(Spring):
    input = 'data/2007-spring/BH2007SP.TXT'
    ap_term_dates = {
        'Spring': '',
    }

class Spring07Proof(Spring07, Proof):
    output_dir = 'spring07-proof'

class Spring07FullProof(Spring07, FullProof):
    output_dir = 'spring07-full-proof'

class Spring07Rooms(Spring07, RoomCoordinator):
    output_dir = 'spring07-rooms'

class Spring07Print(Spring07, Print):
    output_dir = 'spring07-print'

class Spring07Web(Spring07, Web):
    output_dir = 'spring07-web'
    saxon_params = 'schedule-title="Spring 2007 Credit"'

class Spring07Enrolling(Enrolling, Spring07, Spring07Web):
    output_dir = 'spring07-enrolling'

class Spring07CorePrint(CoreOnly, Spring07Print):
    output_dir = 'spring07-core-print'

class Spring07CoreProof(CoreOnly, Spring07FullProof):
    output_dir = 'spring07-core-proof'

class Spring07NonCorePrint(NonCore, Spring07Print):
    output_dir = 'spring07-noncore-print'

class Spring07NonCoreProof(NonCore, Spring07Proof):
    output_dir = 'spring07-noncore-proof'


# ===================================================================
# Summer 2007 profiles
# ===================================================================
class Summer07(Summer):
    input = ('data/2007-summer/bh2007s1.txt', 'data/2007-summer/bh2007s2.txt')
    term_dates = {
        'Summer I/May Term': '5/14/2006-6/1/2006',
    }
    ap_term_dates = {
        'Summer I/May Term': 'May 14-June 2',
        'Summer I': 'June 4-July 3',
        'Summer II': 'July 9-Aug. 9',
    }
    minimester_threshold = None

class Summer07Proof(Summer07, Proof):
    output_dir = 'summer07-proof'

class Summer07Print(Summer07, Print):
    output_dir = 'summer07-print'

class Summer07Rooms(Summer07, RoomCoordinator):
    output_dir = 'summer07-rooms'

class Summer07FullProof(Summer07, FullProof):
    output_dir = 'summer07-full-proof'

class Summer07Web(Summer07, Web):
    output_dir = 'summer07-web'
    saxon_params = 'schedule-title="Summer 2007 Credit"'

class Summer07Enrolling(Enrolling, Summer07, Summer07Web):
    output_dir = 'summer07-enrolling'


# ===================================================================
# Fall 2007 profiles
# ===================================================================
class Fall07(Fall):
    input = 'data/2007-fall/BH2007FA.TXT'
    ap_term_dates = {
        'Fall': '',
    }

class Fall07Proof(Fall07, Proof):
    output_dir = 'fall07-proof'

class Fall07FullProof(Fall07, FullProof):
    output_dir = 'fall07-full-proof'

class Fall07Rooms(Fall07, RoomCoordinator):
    output_dir = 'fall07-rooms'

class Fall07Print(Fall07, Print):
    output_dir = 'fall07-print'

class Fall07Web(Fall07, Web):
    output_dir = 'fall07-web'
    saxon_params = 'schedule-title="Fall 2007 Credit"'

class Fall07Enrolling(Enrolling, Fall07, Fall07Web):
    output_dir = 'fall07-enrolling'

# ===================================================================
# Spring 2008 profiles
# ===================================================================
class Spring08(Spring):
    input = 'data\\2008-spring\\BH2008SP.TXT'
    ap_term_dates = {
        'Spring': '',
    }

class Spring08Proof(Spring08, Proof):
    output_dir = 'spring08-proof'

class Spring08FullProof(Spring08, FullProof):
    output_dir = 'spring08-full-proof'

class Spring08Rooms(Spring08, RoomCoordinator):
    output_dir = 'spring08-rooms'

class Spring08Print(Spring08, Print):
    output_dir = 'spring08-print'

class Spring08Web(Spring08, Web):
    output_dir = 'spring08-web'
    saxon_params = 'schedule-title="Spring 2008 Credit"'

class Spring08Enrolling(Enrolling, Spring08, Spring08Web):
    output_dir = 'spring08-enrolling'

class Spring08CorePrint(CoreOnly, Spring08Print):
    output_dir = 'spring08-core-print'

class Spring08CoreProof(CoreOnly, Spring08FullProof):
    output_dir = 'spring08-core-proof'

class Spring08NonCorePrint(NonCore, Spring08Print):
    output_dir = 'spring08-noncore-print'

class Spring08NonCoreProof(NonCore, Spring08Proof):
    output_dir = 'spring08-noncore-proof'



# ===================================================================
# Profile validator
# ===================================================================

# what attribute are required for this to be a valid profile?
REQUIRED_ATTRS = 'input template output_dir output_xml_path mappings_dir'.split()

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



# ===================================================================
# The actual profile to use
# ===================================================================
profile = get_profile(globals(), validate_profile)



if __name__ == '__main__':
    print 'Chosen profile: %s' % profile