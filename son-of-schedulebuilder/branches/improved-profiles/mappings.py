# $Id$

import re, sys

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

from wrm.decorators import cached
from wrm.utils import files
from profiles import profile

"""mappings.py - Generates a dictionary-based set of mappings
based on a special mappings XML file (located at 'mappings.xml')
and provides a simple API into the generated mappings in the form
of one function:

    get(data, mappingtype, key=None)

get() will try to match the given data against a pattern in the
given mapping type.  If a match is found, it will either return
the entire mapping for the match as a dictionary, or return only
the element of the matching mapping specified by the optional key
argument.

If more than one match is found, it returns the match with the
highest priority, as defined in the mappings XML file.
"""

# where to find the default mappings file to use
__defaultpath__ = 'base.xml'

# where the actual mappings will live
__mappings__ = dict()

# default priority for patterns
__defaultpriority__ = 1

# default key to map against
__defaultkey__ = 'class_number'

# should we print debugging information?
DEBUG = False

# global variables for holding the prebuilt caches
RUBRIK_MAPPING_CACHE = None
FULL_MAPPING_CACHE = None


class Pattern(object):
    """Encapsulates a compiled regular expression and keeps
    track of its own priority.  Used as a key in the mappings."""
    def __init__(self, pattern, priority, key=None, flags=0):
        self.pattern = pattern
        self.flags = flags
        self.compiledpattern = re.compile(pattern, flags)
        self.key = key

        try:
            # try to turn the given priority into an int, since
            # it will be parsed out of the XML file as a string
            self.priority = int(priority)
        except TypeError:
            print >> sys.stderr, ' ! Could not use given priority: %s' % repr(priority)
            self.priority = __defaultpriority__

    def match(self, string):
        """Simply passes the request on to the internal
        compiled regular expression object and returns
        the results."""
        return self.compiledpattern.match(string)

    def __str__(self):
        return self.pattern

    def __repr__(self):
        return str(self)

class Mapping(dict):
    """A specialized dictionary object that is used to
    store the actual mapping information and the calculated
    sortkey for a specific MappingPattern used in the
    mappings."""
    sortkey = None


# Mapping API
# ===========
# get() is the only API into the mappings.  See
# the module documentation for more info
@cached
def get(data, mappingtype, key=None):
    """Gets the regrouping that matches the given data for the given
    mappingtype, which should be a valid mapping type found in the
    mappings XML file.

    If multiple matches are found, the match with the highest priority
    (as defined in the mappings XML file) is returned.  If no match
    is found, None is returned."""

    # keep track of the results to allow multiple patterns
    # to be matched
    results = None
    priority = None

    try:
        mapping = __mappings__[mappingtype]
    except KeyError:
        print >> sys.stderr, ' ! Invalid mapping type: %s' % mappingtype
        return None

    for pattern in mapping:
        if pattern.match(data):
            regrouping = mapping[pattern]
            newpriority = pattern.priority

            # do we have multiple matches?
            if results is not None and priority is not None:
                # if we've got a higher-priority match, use it
                if newpriority > priority:
                    if DEBUG: print >> sys.stderr, ' ! Multiple patterns matched input (%s); using higher-priority pattern %s (%d)' % (data, pattern, newpriority)
                    priority = newpriority
                    results = regrouping

                # if we've got an equal priority, use this one
                elif newpriority == priority:
                    if DEBUG: print >> sys.stderr, ' ! Multiple patterns with equal priority matched input (%s); using %s (%d)' % (data, pattern, newpriority)
                    priority = newpriority
                    results = regrouping

                # if we've got a lower-priority match, skip it
                elif newpriority < priority:
                    if DEBUG: print >> sys.stderr, ' ! Multiple patterns matched input (%s); skipping lower-priority pattern %s (%d)' % (data, pattern, newpriority)
                    pass

            # otherwise, just use what we've got
            else:
                priority = newpriority
                results = regrouping

    # return the requested part of the mapping
    if results and key:
        return results.get(key)

    # or return the whole thing
    else:
        return results


def init(path):
    """Initializes the __mappings__ dict with all of the
    regroupings found in the parsed regroupings XML file.  Must
    be called before anything else."""

    def getancestors(el):
        """Gets a list of the given element's ancestors, excluding
        the root element and any top-level mapping elements."""
        ancestors = []
        ancestor = __parentmap__.get(el)
        while ancestor and ancestor.tag != __root__.tag and ancestor.tag not in __types__:
            ancestors.append(ancestor)
            ancestor = __parentmap__.get(ancestor)
        return ancestors

    def getsortkey(el):
        """Calculates the given element's position inside its parent
        element.  Returns a string for use in XML."""
        if el.attrib.get('unsorted') and el.attrib.get('unsorted').strip() == 'true':
            # if this element has asked to be unsorted, return None
            return None
        else:
            # otherwise, calculate its position inside its parent
            parent = __parentmap__.get(el)
            result = list(parent).index(el) + 1
            return str(result)

    # parse the file into an ElementTree object
    __tree__ = ElementTree.parse(path)
    __root__ = __tree__.getroot()
    __types__ = [el.tag for el in __root__]

    # create a map of children to their parents
    # (taken from the ElementTree documentation)
    __parentmap__ = dict((c, p) for p in __tree__.getiterator() for c in p)

    # keep track of which patterns we've seen
    seen_patterns = {}

    for mappingtype in __root__:
        typename = mappingtype.attrib.get('type')

        # add this mapping-type to the __mappings__
        mappingdict = __mappings__.setdefault(typename, {})

        # add this mapping-type to the seen_patterns dict
        if mappingtype not in seen_patterns:
            seen_patterns[typename] = []

        # loop through each <pattern> element
        for el in mappingtype.findall('.//pattern'):
            pattern = el.attrib.get('match')

            # report any duplicate patterns
            if pattern in seen_patterns[typename] and DEBUG:
                print >> sys.stderr, ' * Duplicate pattern found in %s mappings: %s' % (typename, pattern)
            seen_patterns[typename].append(pattern)

            # build the regrouping for this pattern, which consists
            # of a tuple for each parent, containing its name, comments
            # and sortkey
            mapping = Mapping()
            ancestors = getancestors(el)
            for ancestor in ancestors:
                name = ancestor.attrib.get('name')
                comments = ancestor.find('comments')
                if comments is not None:
                    if len(comments) == 0:
                        # plain text comment, so we simply extract the text
                        comments = comments.text
                    else:
                        # "rich" comment, containing HTML, so we generate a string representation
                        # of the HTML
                        comments = ''.join(ElementTree.tostring(el).strip() for el in comments.getchildren())
                sortkey = getsortkey(ancestor)
                mapping[ancestor.tag] = (name, comments, sortkey)

            # set this regrouping's sortkey
            mapping.sortkey = getsortkey(el)

            priority = el.attrib.get('priority') or __defaultpriority__
            key = el.attrib.get('key') or __defaultkey__

            # create a RegroupingPattern to represent this pattern
            patternobject = Pattern(pattern, priority, key)

            # add this regrouping to __mappings__ keyed on its
            # compiled pattern
            mappingdict[patternobject] = mapping


def build_caches():
    """Builds a set of mappings caches based on the Colleague download
    files for the current profile.  This cuts down on the run time of
    the program by eliminating the need for searching through the
    mappings for every course as it's parsed."""
    
    # a list of all the records, to be extracted from the current
    # profile's input file(s)
    records = []

    for line in files(*profile.input):
        # the offsets are hard-coded
        records.append(dict(rubrik=line[10:17].strip(),
                            number=line[17:24].strip(),
                            section=line[24:29].strip()))

    def build_full_mapping_cache():
        """Builds a cache of all the mappings based on full class numbers
        (e.g. ACCT 1301-2001) for each class in the input."""
        key_func = lambda record: '%(rubrik)s %(number)s-%(section)s' % record
        return build_cache(key_func)

    def build_rubrik_mapping_cache():
        """Builds a cache of all the mappings based on the rubriks found
        in the input (e.g. ACCT)."""
        key_func = lambda record: record.get('rubrik','')
        return build_cache(key_func)

    def build_cache(key_func):
        """Builds a cache of the mappings for keys gotten as the result of
        mapping the given key_func across the records in the input."""
        cache = {}
        for key in map(key_func, records):
            if key not in cache:
                # add the key and its mappings to the cache
                cache[key] = get(key, 'subject')
        return cache

    return (build_full_mapping_cache(),
            build_rubrik_mapping_cache())


def post_init():
    """Runs any processes that need to be run after all of the
    mappings have been initialized."""

    global FULL_MAPPING_CACHE, RUBRIK_MAPPING_CACHE

    print 'Building the mappings caches...',
    FULL_MAPPING_CACHE, RUBRIK_MAPPING_CACHE = build_caches()
    print 'Finished.'


# initialize the mappings from the default file
init(profile.mappings_dir + __defaultpath__)

# if we need to, add any additional mappings
if profile.additional_mappings:
    init(profile.mappings_dir + profile.additional_mappings)

# run any post-initialization operations
post_init()


if __name__ == '__main__':
    from pprint import pprint
    pprint(__mappings__['subject'])