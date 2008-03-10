# Author:     Travis Haapala
# Section:    Brookhaven MPI
# e-mail:     thaapala@dcccd.edu
# extention:  x4104
# Created:    13 February 2008
# Modified:   10 March    2008

# checks mappings for duplicates that could mess with order in output

# GLOBALS
# I didn't include 'base.xml', because I don't want to touch that one
mappings = ['fall.xml', 'spring.xml', 'summer.xml'];

# get xml lib (stolen out of Will's SoSB test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;

# required imports
import sys

class pattern(object):
    def __init__(self, name, priority):
        self.name = name;
        self.priority = priority;
    def __cmp__(self, other):
        temp = cmp(self.name, other.name);
        if (temp == 0):
            return cmp(self.priority, other.priority);
        else:
            return temp;
    def __str__(self):
        if (self.priority != None):
            priority = 'priority="'+str(self.priority)+'" ';
        else:
            priority = '';
        return '<pattern match="'+str(self.name)+'" '+priority+' />';

def run(filename):
    # find all patterns and check for duplicates
    print 'Checking ' + filename + ' for duplicates...'
    i = 0;
    
    pattern_list = [];
    dup_list = [];
    patterns_xml = ET.ElementTree(file=filename).findall('//pattern');
    for p in patterns_xml:
        temp = pattern(p.get('match'), p.get('priority'));
        if temp in pattern_list:
            dup_list.append(temp);
        else:
            pattern_list.append(temp);
        i += 1;

    print str(i) + ' patterns scanned.';
            
    # if there's duplicates
    if (len(dup_list) > 0):
        print str(len(dup_list)) + ' duplicates found:'
        for d in dup_list:
            print '   ' + str(d);
    else:
        print 'no duplicates found.'

    print '\n';

if (__name__ == '__main__'):

    for filename in mappings:
        run(filename);
