import string, re
from cElementTree import ElementTree, Element, SubElement

import wrm.utils
import wrm.xmlutils

import settings
import db
from schema import schema

def build():
    print >> settings.log.info, 'Building xml document from %s...' % settings.database.path
    
    root = Element('directory')
    doc = ElementTree(root)
    
    print >> settings.log.info, ' - Extracting data from database'
    employees = get_employees(db.table)
    
    seen_letters = []
    for employee in employees:
        if isinstance(employee['LastName'], basestring):
            firstletter = employee['LastName'][0].upper()
            
            if firstletter not in seen_letters:
                alphagroup = alphagroup_element(root, firstletter)
                seen_letters.append(firstletter)
            
            employee_el = employee_element(alphagroup, employee)
    
    # add empty <alphagroup>s for any missing letters
    missing_letters = [letter for letter in string.ascii_uppercase if letter not in seen_letters]
    for letter in missing_letters:
        alphagroup = alphagroup_element(root, letter)
    
    # Write our XML file to disk
    wrm.xmlutils.write_xml(doc, 'whitepages.xml')
    
    print >> settings.log.info, 'Finished.\n'
    return doc


##############################
# Element creation functions #
##############################
def alphagroup_element(parent, letter):
    # Create the letter element
    el = SubElement(parent, 'alphagroup', letter=letter)
    
    # get the surrounding letters in the alphabet
    nextletter = chr(ord(letter) + 1)
    prevletter = chr(ord(letter) - 1)
    
    # get the filenames for the pages for the surrounding letters
    prefix = settings.output.html.prefix
    suffix = settings.output.html.suffix
    nextpage = prefix + nextletter.lower() + suffix
    prevpage = prefix + prevletter.lower() + suffix
    
    # add pointers to previous and next page
    if nextletter in string.ascii_uppercase:
        el.attrib['next'] = nextpage
    if prevletter in string.ascii_uppercase:
        el.attrib['previous'] = prevpage

    return el

def employee_element(parent, employee):
    # Create the employee element
    el = SubElement(parent, 'employee')
    
    # create its children
    children = 'LastName FirstName Extension Room Division Title EmailNickname'.split()
    for name in children:
        child = SubElement(el, name)
        child.text = employee[name]
    
    # if there is a photopath, add it as an attribute
    if employee['PhotoPath']:
        el.attrib['PhotoPath'] = employee['PhotoPath']

    return el
    
def get_employees(table):
    # Get the employees out of the table and run them through the formatters
    employees = map(schema.extract, table.all(order_by='LastName'))
    
    # Filter out vacant employees
    return filter(employee_filter, employees)

def employee_filter(employee):
    """Employees with a last name of 'Vacant' should be filtered out."""
    return employee['LastName'] and not re.match('vacant', employee['LastName'], re.I)

    
if __name__ == '__main__':
    tree = build()
    root = tree.getroot()
    
    print >> settings.log.info, 'Summary:'
    print >> settings.log.info, ' - Alphagroup elements: %d' % len(root.findall('.//alphagroup'))
    print >> settings.log.info, ' - Employee elements: %d' % len(root.findall('.//employee'))