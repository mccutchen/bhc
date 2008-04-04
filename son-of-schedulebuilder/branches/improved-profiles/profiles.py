"""profiles.py

Provides a set of profiles that control the execution of
son-of-schedulebuilder.

These profiles should be year-specific subclasses of the Spring, Summer
and Fall profiles defined in baseprofiles.py.  A whole suite of specialized
profiles will be created for each term profile defined below.

These profiles MUST be named according to the pattern TermYY, where YY is
the last two digits of a year.  For example:  Spring08, Fall07."""

from datetime import date
from wrm.profile import get_profile
from baseprofiles import Spring, Summer, Fall, PROFILES, validate_profile

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
# The actual profile to use
# ===================================================================
profile = get_profile(PROFILES, validate_profile)

if __name__ == '__main__':
    print 'Chosen profile: %s' % profile