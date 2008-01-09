import string, re
from cElementTree import ElementTree, Element, SubElement
import wrm
from wrm.utils import unicodeize
import settings, meta

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
    
    # Should we write out our xml output?
    try:
        outpath = settings.output.xml.path
        print >> settings.log.info, ' - Writing xml data to %s' % outpath
        outfile = file(outpath, 'w')
        outfile.write('<?xml version="1.0" encoding="utf-8"?>\n')
        doc.write(outfile, encoding='utf-8')
    except AttributeError:
        pass
    
    print >> settings.log.info, 'Finished.\n'
    return doc


##############################
# Element creation functions #
##############################
def alphagroup_element(parent, letter):
    # unicode? yes!
    letter = unicodeize(letter)
    
    # the letter element
    el = SubElement(parent, 'alphagroup', letter=letter)
    
    # get the surrounding letters in the alphabet
    nextletter = chr(ord(letter) + 1)
    prevletter = chr(ord(letter) - 1)
    
    # get the filenames for the pages for the surrounding letters
    prefix = settings.output.html.prefix
    suffix = settings.output.html.suffix
    nextpage = prefix + nextletter.lower() + suffix
    prevpage = prefix + prevletter.lower() + suffix
    
    # add poiters to previous and next page
    if nextletter in string.ascii_uppercase:
        el.attrib['next'] = unicodeize(nextpage)
    if prevletter in string.ascii_uppercase:
        el.attrib['previous'] = unicodeize(prevpage)

    return el

def employee_element(parent, employee):
    # make sure we're using unicode
    employee = unicodeize(employee)
    
    # PhotoPath will be an attribute, not a child
    exclude = ('PhotoPath')
    children = wrm.utils.filterdict(employee, exclude)
    
    # create the employee element
    el = SubElement(parent, 'employee')
    
    # create its children
    for name, value in children.items():
        child = SubElement(el, name)
        child.text = value
    
    # if there is a photopath, add it
    if employee['PhotoPath']:
        el.attrib['PhotoPath'] = employee['PhotoPath']

    return el
    
def get_employees(table):
    sql = 'select $columns$ from $table$ order by LastName'
    table.execute(sql)
    return filter(employee_filter, map(meta.parser.parse, table.results()))

def employee_filter(employee):
    """Employees with a last name of 'Vacant' should be filtered out."""
    return employee['LastName'] and not re.match('vacant', employee['LastName'], re.I)

    
if __name__ == '__main__':
    tree = build()
    root = tree.getroot()
    
    print >> settings.log.info, 'Summary:'
    print >> settings.log.info, ' - Letter elements: %d' % len(root.findall('.//letter'))
    print >> settings.log.info, ' - Employee elements: %d' % len(root.findall('.//employee'))