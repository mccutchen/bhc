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
# Summer 2012 profile
# ===================================================================
class Summer12(Summer):
    input = ('data/2012-summer/bh2012s1.txt', 'data/2012-summer/bh2012s2.txt')
    terms = {
        'Summer I/May Term': (date(2012, 5, 11), date(2012, 6, 5), 'May 11-June 5'),
        'Summer I':  (date(2012, 6, 6), date(2012, 7, 3), 'June 6-July 3'),
        'Summer II':  (date(2012, 7, 9), date(2012, 8, 9), 'July 9-Aug. 9'),
    }
    saxon_params = {'schedule-title': 'Summer 2012 Credit'}

# ===================================================================
# Fall 2012 profiles
# ===================================================================
class Fall12(Fall):
    input = 'data/2012-fall/BH2012FA.TXT'
    terms = {
        'Fall': (date(2012, 8, 27), date(2012, 12, 13), 'Aug. 27-Dec. 13'),
    }


# ===================================================================
# Spring 2012 profiles
# ===================================================================
class Spring12(Spring):
    input = 'data/2012-spring/BH2012SP.TXT'
    terms = {
        'Spring': (date(2012, 1, 17), date(2012, 5, 10), 'Jan. 17-May 10'),
    }
   
# ===================================================================
# The actual profile to use
# ===================================================================
profile = get_profile(PROFILES, validate_profile)



if __name__ == '__main__':
    # Just tell us what profile was chosen
    print 'Chosen profile: %s' % profile
