#!/usr/bin/env python

"""
Builds and returns an ElementTree object from the given
input file(s)
"""

import copy, datetime, os, re, sys

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree
    
from wrm import decorators, xmlutils
from wrm.utils import filterdict, unicodeize, get_machine_name, splits

import classparser
from profiles import profile

def build(classes=None):
    if not classes:
        classes = classparser.parse_classes()

    # create the root element and a tree around it
    root = ElementTree.Element('schedule')
    tree = ElementTree.ElementTree(root)

    for class_data in classes:
        # build the elements to support this class
        build_xml(root, class_data)

        if profile.special_sections:
            # get any 'extra' elements
            term = get_term_element(root, class_data, True)
            get_minimester(term, class_data)
            get_distance_learning(term, class_data)
            get_weekend(term, class_data)

    print 'Writing xml data to %s ...' % profile.output_xml_path
    tree.write(profile.output_xml_path, encoding=profile.output_xml_encoding) # XML data
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
    name = data['term']
    machine_name=get_machine_name(name)
    dates = data['term-dates']
    year = data['year']
    sortkey = data['term-sortkey']
    attrs = dict(name=name, machine_name=machine_name, sortkey=sortkey, dates=dates, year=year)
    el = xmlutils.add_element(parent, 'term', attrs)

    if returnself:
        return el
    return get_division_element(el, data)

def get_division_element(parent, data, returnself=False):
    name = data['division']
    machine_name = get_machine_name(name)
    attrs = dict(name=name, machine_name=machine_name)
    el = xmlutils.add_element(parent, 'division', attrs)

    if returnself:
        return el
    return get_subject_element(el, data)

def get_subject_element(parent, data, returnself=False, notype=False):
    subject = data['subject-name']
    subject_comments = data['subject-comments']

    name = subject
    machine_name = get_machine_name(name)
    attrs = dict(name=name, machine_name=machine_name)
    children = dict(comments=subject_comments)

    attrs = unicodeize(attrs)
    children = unicodeize(children)
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

        attrs = unicodeize(attrs)
        children = unicodeize(children)

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

        attrs = unicodeize(attrs)
        children = unicodeize(children)

        el = xmlutils.add_element(parent, 'subtopic', attrs, children)
    else:
        el = parent

    if returnself:
        return el

    return get_course_element(el, data)


def get_course_element(parent, data, returnself=False):
    """
    Returns a course element that is said to be
    unique based on the hash of the course title
    and the course comments
    """
    title = data['title']
    rubrik = data['rubrik']
    number = data['number']
    comments = data['comments']
    course_type = data['type']
    cross_listings = data['group']
    core_component = data['core-component']
    machine_name = get_machine_name(title)
    credit_hours = data['credit-hours']

    attrs = {
        'title':title,
        'machine_name': machine_name,
        'rubrik': rubrik,
        'number': number,
        'type': course_type,
        'core-component': core_component,
        'cross-listings': cross_listings,
        'credit-hours': credit_hours,
    }
    children = {
        'comments': comments,
    }
    el = xmlutils.add_element(parent, 'course', attrs, children)

    if returnself:
        return el
    return get_class_element(el, data)

def get_class_element(parent, data, returnself=False):
    """
    Returns a class element, including any extra
    meetings (like labs or extra lectures) as
    children
    """

    def copyvalue(to_dict, from_dict, to_key, from_key=None, default=None):
        from_key = from_key or to_key
        to_dict[to_key] = from_dict.get(from_key, default)

    # set up the attributes
    attrs = {}
    copyvalue(attrs, data, 'class-number')
    copyvalue(attrs, data, 'classroom-sessions')
    copyvalue(attrs, data, 'end-date')
    copyvalue(attrs, data, 'formatted-dates')
    copyvalue(attrs, data, 'section')
    copyvalue(attrs, data, 'section-capacity')
    copyvalue(attrs, data, 'start-date')
    copyvalue(attrs, data, 'synonym')
    copyvalue(attrs, data, 'sortkey', 'class-sortkey')
    copyvalue(attrs, data, 'sortkey-date', 'class-sortkey-date')
    copyvalue(attrs, data, 'sortkey-time', 'class-sortkey-time')
    copyvalue(attrs, data, 'weeks')

    # add in the meeting time, days, etc., info from the session
    attrs.update(data['session'])

    # add the element for this class
    el = xmlutils.add_element(parent, 'class', attrs)

    # add any extra sessions
    for extra in data['extra-sessions']:
        extra_el = xmlutils.add_element(el, 'extra', extra)

    return el


# WARNING: UGLY HACK
# these create the "special" sections of the schedule
def get_minimester(parent, data):
    if not data['minimester']:
        return None

    # First, create the 'special-section' element for all minimesters
    name = 'Flex Term'
    machine_name = get_machine_name(name)
    attrs = dict(name=name, machine_name=machine_name)
    special_section = xmlutils.add_element(parent, 'special-section', attrs)

    # Then, get the 'minimester' element for this minimester, which will
    # be a child of the <special-section> created above
    name = '%s Flex Term' % data['minimester']
    machine_name = get_machine_name(name)
    sortkey = data['minimester-sortkey']
    attrs = dict(name=name, machine_name=machine_name, sortkey=sortkey)

    el = xmlutils.add_element(special_section, 'minimester', attrs)
    return get_subject_element(el, data)

def get_distance_learning(parent, data):
    if data['type'] != 'DL':
        return None

    name = 'Distance Learning'
    machine_name = get_machine_name(name)
    attrs = dict(name=name, machine_name=machine_name)
    el = xmlutils.add_element(parent, 'special-section', attrs)
    return get_subject_element(el, data, notype=True)

def get_weekend(parent, data):
    if data['type'] != 'W':
        return None

    name = 'Weekend'
    machine_name = get_machine_name(name)
    attrs = dict(name=name, machine_name=machine_name)
    el = xmlutils.add_element(parent, 'special-section', attrs)
    return get_subject_element(el, data, notype=True)


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
