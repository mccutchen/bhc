#!/usr/bin/env python

"""Builds and returns an ElementTree object from the given input
file(s)"""

import datetime, os, re, sys

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree
    
from wrm import decorators, xmlutils
from wrm.utils import get_machine_name

import classparser
from profiles import profile

def build(classes=None):
    if not classes:
        classes = classparser.parse_classes()
    
    # get a timestamp to add to the root element
    timestamp = datetime.datetime.now().isoformat()

    # create the root element and a tree around it
    root = ElementTree.Element('schedule', timestamp=timestamp)
    tree = ElementTree.ElementTree(root)

    for class_data in classes:
        # build the elements to support this class
        build_xml(root, class_data)

        # build any 'special' sections
        if profile.special_sections:
            
            # this will be a cached copy of the term element built by
            # build_xml, used by the functions below
            term = get_term_element(root, class_data, True)
            
            # only make a minimester section if we have a valid minimester
            # threshold set in the profile
            if profile.minimester_threshold is not None:
                get_minimester(term, class_data)

            special_section(term, 'Learning Community - Interdisciplinary Studies', class_data, topicfilter('LC'))
            special_section(term, 'Self-Paced', class_data, typefilter('SP'), notype=True)
            special_section(term, 'Distance Learning', class_data, typefilter('DL'), notype=True)
            special_section(term, 'Weekend', class_data, typefilter('W'), notype=True)

            # Another special section that only includes weekend core
            # courses.
            weekend_core_test = lambda data: typefilter('W')(data) and corefilter(data)
            special_section(term, 'Weekend Core Curriculum', class_data, weekend_core_test, notype=True)

            # Another special section that only includes classes that meet
            # one day per week (the same day for all meetings)
            special_section(term, 'One-Day-Per-Week', class_data, onedayfilter, notype=True)
    
    # report any errors encountered while building the XML
    report_errors(timestamp)

    print 'Writing xml data to %s ...' % profile.output_xml_path
    xmlutils.write_xml(tree, profile.output_xml_path)
    print

    # post_process the output
    print 'Post-processing %s ...' % profile.output_xml_path
    post_process(profile.output_xml_path)
    print

    # read the post-processed file back into an ElementTree
    tree = ElementTree.parse(profile.output_xml_path)

    print 'Finished.\n'
    return tree


########################################
# Element creation functions           #
#                                      #
# These all return elements that are   #
# unique in their parents, to properly #
# structure the schedule data          #
########################################
def build_xml(root, data):
    return get_term_element(root, data)

def get_term_element(parent, data, returnself=False):
    attrs = {
        'name':         data['term'],
        'machine_name': get_machine_name(data['term']),
        'dates':        data['term-dates'],
        'year':         data['year'],
        'sortkey':      data['term-sortkey'],
    }
    el = xmlutils.add_element(parent, 'term', attrs)
    if returnself:
        return el
    return get_division_element(el, data)

def get_division_element(parent, data, returnself=False):
    attrs = {
        'name':         data['division'],
        'machine_name': get_machine_name(data['division']),
    }
    el = xmlutils.add_element(parent, 'division', attrs)
    if returnself:
        return el
    return get_subject_element(el, data)

def get_subject_element(parent, data, returnself=False, notype=False):
    attrs = {
        'name':         data['subject-name'],
        'machine_name': get_machine_name(data['subject-name']),
    }
    children = {
        'comments': data['subject-comments'],
    }
    el = xmlutils.add_element(parent, 'subject', attrs, children)
    if returnself:
        return el
    return get_topic_element(el, data, notype=notype)

def get_topic_element(parent, data, returnself=False, notype=False):
    topic = data.get('topic-name')
    if topic:
        topic_comments = data['topic-comments']

        if topic.strip().lower() == 'none':
            name = None
        else:
            name = topic
        machine_name = get_machine_name(name)
        attrs = dict(name=name, machine_name=machine_name, sortkey=data['topic-sortkey'])
        children = dict(comments=topic_comments)

        el = xmlutils.add_element(parent, 'topic', attrs, children)
    else:
        el = parent

    if returnself:
        return el
    return get_subtopic_element(el, data, notype=notype)

def get_subtopic_element(parent, data, returnself=False, notype=False):
    subtopic = data.get('subtopic-name')
    if subtopic:
        subtopic_comments = data['subtopic-comments']

        name = subtopic
        machine_name = get_machine_name(name)
        attrs = dict(name=name, machine_name=machine_name, sortkey=data['subtopic-sortkey'])
        children = dict(comments=subtopic_comments)

        el = xmlutils.add_element(parent, 'subtopic', attrs, children)
    else:
        el = parent

    if returnself:
        return el

    return get_course_element(el, data)


def get_course_element(parent, data, returnself=False):
    """Returns a course element that is said to be unique based on the
    hash of the course title and the course comments"""

    # If this course has "special" cross-listings, they take precedence over
    # cross-listings from Colleague.  Note that the "groups.xsl" XSLT
    # post-processor is what actually creates the <group> elements based on
    # each course's cross-listings.
    cross_listings = data.get('special-cross-listings') or \
                     ''.join(data.get('cross-listings'))

    # UGLY HACK: they want LC courses to superceed Day/Night/Weekend/etc
    temp_type = data['type'];
    if (data['topic-code'] == 'LC'):
        temp_type = data['topic-code'];
    attrs = {
        'title':          data['title'],
        'machine_name':   get_machine_name(data['title']),
        'rubrik':         data['rubrik'],
        'number':         data['number'],
        'type':           temp_type,
        'core-component': data['core-component'],
        'cross-listings': cross_listings,
        'credit-hours':   data['credit-hours'],
    }
    children = {
        'comments': data['comments'],
    }
    el = xmlutils.add_element(parent, 'course', attrs, children)

    if returnself:
        return el
    return get_class_element(el, data)

def get_class_element(parent, data, returnself=False):
    """Returns a class element, including any extra meetings (like labs or
    extra lectures) as children"""

    # set up the attributes
    attrs = {
        'class-number':       data['class-number'],
        'classroom-sessions': data['classroom-sessions'],
        'end-date':           data['end-date'],
        'formatted-dates':    data['formatted-dates'],
        'section':            data['section'],
        'section-capacity':   data['section-capacity'],
        'start-date':         data['start-date'],
        'synonym':            data['synonym'],
        'sortkey':            data['class-sortkey'],
        'sortkey-date':       data['class-sortkey-date'],
        'sortkey-time':       data['class-sortkey-time'],
        'weeks':              data['weeks'],
    }

    # add in the meeting time, days, etc., info from the session
    attrs.update(data['session'])

    # add the element for this class
    el = xmlutils.add_element(parent, 'class', attrs)

    # add any extra sessions
    for extra in data['extra-sessions']:
        extra_el = xmlutils.add_element(el, 'extra', extra)

    return el


# WARNING: UGLY HACKS
# these create the "special" sections of the schedule
def get_minimester(parent, data):
    if not data['minimester']:
        return None

    # First, create the 'special-section' element for all minimesters
    special_section = make_special_section_el(parent, 'Flex Term')

    # Then, get the 'minimester' element for this minimester, which will
    # be a child of the <special-section> created above
    name = '%s Flex Term' % data['minimester']
    machine_name = get_machine_name(name)
    sortkey = data['minimester-sortkey']
    attrs = dict(name=name, machine_name=machine_name, sortkey=sortkey)

    el = xmlutils.add_element(special_section, 'minimester', attrs)
    return get_subject_element(el, data)

def make_special_section_el(parent, name):
    """Creates a special section element with the given name as a
    child of the given parent element.  Uses the given name to create
    the machine_name attribute."""
    attrs = dict(name=name, machine_name=get_machine_name(name))
    return xmlutils.add_element(parent, 'special-section', attrs)

def special_section(parent, name, data, test=lambda x: False, **kwargs):
    """Creates a special section with the given name as a child of the
    of the given parent element.  Works only if the given test
    function returns True for the given data.  Passes the remaining
    kwargs through to the get_subject_element function."""
    if test(data):
        el = make_special_section_el(parent, name)
        return get_subject_element(el, data, **kwargs)


#######################################################################
# Class filters
# Used to only include certain classes in special sections
#######################################################################
def corefilter(data):
    """Include only Core Curriculum classes"""
    return data.get('core-component','') not in ('', None)

def onedayfilter(data):
    """Include only classes that meet on a single day, but not RadTech, Nursing, or EMS"""
    excluded_subjects = ('Radiologic Sciences', 'Nursing', 'Emergency Medical Services')
    days = data['session']['days']
    otherdays = [s['days'] for s in data['extra-sessions'] if s['days'] != days]
    return (len(days) == 1) and (not otherdays) and (not (data.get('subject-name') in excluded_subjects))

# Functions that build filters that might be useful as test args to
# the special_section function.
def classfilter(key, *values):
    return lambda data: data.get(key, '') in values
def typefilter(*types):
    return classfilter('type', *types)
def topicfilter(*topics):
    return classfilter('topic-code', *topics)


def post_process(outpath):
    # XSL post-processing
    for p in profile.post_processors:
        processor = os.path.join(os.path.normpath(profile.post_processor_dir), p)
        print ' - Using %s' % processor
        cmd = 'java -jar %s -o %s %s %s' % (profile.saxon_path, outpath, outpath, processor)
        saxonin, saxonout, saxonerr = os.popen3(cmd)

        # report any errors or status messages
        for line in saxonerr:
            if line.strip():
                print >> sys.stderr, ' ! %s' % line.strip()
        for line in saxonout:
            if line.strip():
                print ' - %s' % line.strip()


def report_errors(timestamp):
    errors = [error for error in profile.errors if not error.ignore]
    if not errors:
        return

    errorfile = file('errors.txt', 'w')
    
    def duplex_print(s):
        """Prints to stdout and to the error file opened above."""
        print s
        print >> errorfile, s
    
    divider = '=' * 72
    duplex_print('Errors in schedule data (also written to %s)' % errorfile.name)
    duplex_print(divider)
    duplex_print('Course            Reg #      Description')
    #             XXXX 1234-1234    #XXXXXX    Description...
    duplex_print(divider)
    for error in sorted(errors):
        duplex_print(error)
    duplex_print(divider)
    print


###############
# Main method #
###############
def main():
    tree = build()
    root = tree.getroot()

    # what elements do we want information on?
    notables = 'term division subject topic subtopic type group course class www'.split()

    print 'Summary:'
    for el in notables:
        print ' - %s element(s):\t%d' % (el.title(), len(root.findall('.//%s' % el)))

if __name__ == "__main__":
    main()
