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
# Summer 2011 profiles
# ===================================================================
class Summer11(Summer):
    input = ('data/2011-summer/bh2011s1.txt', 'data/2011-summer/bh2011s2.txt')
    terms = {
        'Summer I/May Term': (date(2011, 5, 11), date(2011, 6, 5), 'May 11-June 5'),
        'Summer I':  (date(2011, 6, 6), date(2011, 7, 7), 'June 6-July 7'),
        'Summer II':  (date(2011, 7, 12), date(2011, 8, 11), 'July 11-Aug. 11'),
    }
    saxon_params = {'schedule-title': 'Summer 2011 Credit'}

# ===================================================================
# Fall 2010 profiles
# ===================================================================
class Fall10(Fall):
    input = 'data/2010-fall/BH2010FA.TXT'
    terms = {
        'Fall': (date(2010, 8, 23), date(2010, 12, 9), 'Aug. 23-Dec. 9'),
    }


# ===================================================================
# Spring 2011 profiles
# ===================================================================
class Spring11(Spring):
    input = 'data/2011-spring/BH2011SP.TXT'
    terms = {
        'Spring': (date(2011, 1, 18), date(2011, 5, 12), 'Jan. 18-May 12'),
    }
   
# ===================================================================
# The actual profile to use
# ===================================================================
profile = get_profile(PROFILES, validate_profile)



if __name__ == '__main__':
    # Just tell us what profile was chosen
    print 'Chosen profile: %s' % profile
