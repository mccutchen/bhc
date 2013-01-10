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
# Summer 2013 profile
# ===================================================================
class Summer13(Summer):
    input = 'data/2013-summer/BH2013SU.TXT'
    terms = {
        'Summer':  (date(2013, 5, 11), date(2013, 8, 8), 'May 11-Aug. 8'),
    }


# ===================================================================
# Fall 2012 profiles
# ===================================================================
class Fall12(Fall):
    input = 'data/2012-fall/BH2012FA.TXT'
    terms = {
        'Fall': (date(2012, 8, 27), date(2012, 12, 13), 'Aug. 27-Dec. 13'),
    }


# ===================================================================
# Spring 2013 profiles
# ===================================================================
class Spring13(Spring):
    input = 'data/2013-spring/BH2013SP.TXT'
    terms = {
        'Spring': (date(2013, 1, 22), date(2013, 5, 16), 'Jan. 22-May 16'),
    }
   
# ===================================================================
# The actual profile to use
# ===================================================================
profile = get_profile(PROFILES, validate_profile)



if __name__ == '__main__':
    # Just tell us what profile was chosen
    print 'Chosen profile: %s' % profile
