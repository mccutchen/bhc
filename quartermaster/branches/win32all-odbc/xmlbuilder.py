import datetime, os, re, string, sys, time, types
from cStringIO import StringIO
from cElementTree import ElementTree, Element, SubElement, parse

from wrm import xmlutils
from wrm import decorators
from wrm.utils import get_machine_name, exclude, filterdict, only

import db
from schema import schema
from profiles import profile


def build():
    print 'Building XML document from %s...' % profile.database_path

    # create the root element and a tree around it
    root = Element('schedule')
    doc = ElementTree(root)

    print ' - Extracting data from database.'
    
    for row in db.table.all():
        row = schema.extract(row)
        build_divisions(root, row)

    # do any post-processing
    doc = post_process(doc)

    # write the XML to disk
    print ' - Writing xml data to %s' % profile.output_xml_path
    xmlutils.write_xml(doc, profile.output_xml_path)

    print 'Finished.\n'

    # return the ElementTree (like a DOM object) we just created
    return doc

def build_divisions(parent, row):
    """Build the real schedule structure under the given parent element.
    This allows for variation between the xml format of the print schedule
    and the web schedule."""

    # get all of the possible divisions
    major_division = create_division(parent, row, 'major_division')
    minor_division = create_division(parent, row, 'minor_division')
    other_division = create_division(parent, row, 'other_division')

    # filter out any nonexistant divisions
    divisions = [div for div in (major_division, minor_division, other_division) if div is not None]

    # fill in each division
    for division in divisions:
        cluster_element = create_cluster_element(division, row)
        course_element = create_course_element(cluster_element, row)
        class_element = create_class_element(course_element, row)


##############################
# Element creation functions #
##############################
def create_division(parent, row, type='major_division'):
    if row[type]:
        name = row[type]
        machine_name = get_machine_name(name)
        attrs = dict(name=name, machine_name=machine_name)
        return xmlutils.add_element(parent, 'division', attrs)
    else:
        return None

def create_cluster_element(parent, row):
    # Only create a new cluster if the given cluster is different from
    # the given division name.  The exception is that if there is a
    # catalog_prefix for the cluster, you have to create it.
    if row['cluster'] and (row['cluster'].lower() != parent.attrib.get('name').lower() or row['catalog_prefix']):        
        attrs = dict(
            name=row['cluster'],
            machine_name=get_machine_name(row['cluster']),
            catalog_sort_order=row['catalog_sort_order'],
        )
        
        # filter out any unneeded values
        attrs = exclude(attrs, values=[None, ''])

        element = xmlutils.add_element(parent, 'cluster', attrs)

        # add the description elements
        add_description_element(element, 'catalog_page_header', row['catalog_page_header'])
        add_description_element(element, 'catalog_prefix', row['catalog_prefix'])
        add_description_element(element, 'suffix_description', row['suffix_description'])

        return element
    else:
        return parent


def create_course_element(parent, row):
    attrs = dict(
        title = row['title'],
        machine_name = get_machine_name(row['title']),
        cluster_sort_order = row['cluster_sort_order'],
        spanish = row['spanish'],
        financial_aid = row['Financial_Aid'],
        concurrent = row['concurrent'],
    )
    children = dict(
        prerequisites = row['prerequisites'],
        supplies = row['supplies'],
        textbooks = row['textbooks']
    )

    # create the course element
    element = xmlutils.add_element(parent, 'course', attrs, children)

    # add the course_description
    add_description_element(element, 'course_description', row['course_description'])

    # add the notes element
    add_notes_element(element, row['Notes'])

    return element


def create_class_element(parent, row):
    # skip any dummy classes
    if row['class_number'] and row['class_number'].startswith('DUMM'):
        return None
    
    attrs = only(row, keys=[
        'class_number',
        'date_sortkey',
        'days',
        'end_date',
        'evening',
        'faculty',
        'hours',
        'location',
        'room',
        'session',
        'start_date',
        'time_formatted',
        'time_sortkey',
        'tuition',
        'evening',
        'time_sortkey',
        'date_sortkey',])

    # create the class element
    element = xmlutils.add_element(parent, 'class', attrs)

    return element

def add_description_element(parent, tagname, description):
    if not description or not description.strip():
        return None

    # Make sure there are two spaces after each period.
    description = re.sub(r'(\.)( +)(\S+)', r'\1  \3', description)

    # get the actual description element
    el = xmlutils.add_element(parent, tagname)

    # add a <p> child for each paragraph found
    paras = [s.strip() for s in description.split('\n') if s.strip()]
    for para in paras:
        xmlutils.add_element(el, 'p', text=para)
    return el

def add_notes_element(parent, notes):
    if not notes or not notes.strip():
        return None
    el = xmlutils.add_element(parent, 'notes', text=notes)
    return el



#####################
# Utility functions #
#####################
def post_process(tree):
    print ' - Post-processing.'

    buf = StringIO()
    tree.write(buf, encoding='utf-8')
    buf.reset()

    regexes = [
        [   # urls
            r'((http://|www\.)+(www\.)?[A-Za-z0-9\.\-]+\.{1}[A-Za-z]{3}[A-Za-z0-9\.\-\_/]*)\b',
            r'<url>\1</url>'],
        [   # emails
            r'([A-Za-z0-9\.\_\-]+@[A-Za-z0-9\.\-]+\.{1}[A-Za-z]{3})\b',
            r'<email>\1</email>'],
        [   # --Online
            r' (name|title)="([A-Za-z0-9 ]+)--Online"',
            r' \1="\2&#8212;online course"'],
        [   # --ONLINE
            r' (name|title)="([A-Za-z0-9 ]+)--ONLINE"',
            r' \1="\2&#8212;online course"'],
        [   # improperly-formatted phone numbers
            r'\(([0-9]{3})\)[ \-]([0-9]{3})[ \-]([0-9]{4})',
            r'\1-\2-\3'],
    ]

    data = buf.read()
    for pattern, replace in regexes:
        data = re.sub(pattern, replace, data)

    # give an ElementTree object back
    buf = StringIO(data)
    return parse(buf)



###############
# Main method #
###############
def main():
    tree = build()
    root = tree.getroot()

    # what elements do we want information on?
    notables = 'schedule-type division cluster course class'.split()
    print 'Summary:'
    for el in notables:
        print ' - %s element(s):\t%d' % (el.title(), len(root.findall('.//%s' % el)))

if __name__ == "__main__":
    main()
