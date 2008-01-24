import os, re

try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET

import decorators
from utils import exclude

@decorators.cached
def add_element(parent, tagname, attrs={}, children={}, text=None):
    """Returns an ElementTree.Element object which is guaranteed to be unique,
    based on the given arguments."""

    forbiddenvalues = [None, '']
    attrs = exclude(attrs, values=forbiddenvalues)
    children = exclude(children, values=forbiddenvalues)

    el = ET.SubElement(parent, tagname, **attrs)

    if text and not attrs and not children:
        el.text = text

    for childname, value in children.items():
        if is_xml_fragment(value) and not value.startswith('<%s' % childname):
            # create a valid xml fragment
            value = '<%s>%s</%s>' % (childname, value, childname)
            child = ET.fromstring(value)
            el.append(child)
        else:
            ET.SubElement(el, childname).text = value

    return el

def is_xml_fragment(data):
    if isinstance(data, basestring):
        if '<' in data and '>' in data:
            return True
    return False

def xml_escape(text):
    """Encodes reserved and non-ascii chars in text as numerical entity
    references.  Taken from ElementTree.SimpleXMLWriter."""

    # reserved and non-ascii chars
    chars_to_escape = re.compile(eval(r'u"[&<>\"\u0080-\uffff]+"'))

    def escape_entities(m):
        """Maps the reserved and non-ascii chars in MatchObject m to
        their numerical entity references."""
        out = []
        for char in m.group():
            out.append("&#%d;" % ord(char))
        return ''.join(out)

    return re.sub(chars_to_escape, escape_entities, text).encode("ascii")

def write_xml(tree, outputpath, encoding='utf-8'):
    assert isinstance(tree, ET.ElementTree), 'xmlutils.write_xml() requires an \
        instance of ElementTree to write to disk.'
    
    # add indentation to the given element
    indent(tree.getroot())
    
    # write to disk
    outfile = open(outputpath, 'w')
    tree.write(outfile, encoding)
    outfile.close()    

def indent(elem, level=0):
    """Adds whitespace to the given element and its children, which results
    in pretty-printing when the element is actually output.
    
    From:  http://effbot.org/zone/element-lib.htm#prettyprint"""
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        for e in elem:
            indent(e, level+1)
            if not e.tail or not e.tail.strip():
                e.tail = i + "  "
        if not e.tail or not e.tail.strip():
            e.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def transform(xml_path, xsl_path, saxon_path, params={}):
    """A wrapper around calling out to Saxon on the command line.  Returns
    two lists, the lines Saxon prints to STDOUT and those it prints to
    STDERR."""

    # Convert params dict into a string suitable for command line parameters
    params = ' '.join(['%s="%s"' % (item) for item in params.items()])
    
    # Sub in arguments given to this function
    cmd = 'java -jar %(saxon_path)s -o transform.log %(xml_path)s %(xsl_path)s %(params)s' % locals()
    
    # Open a named pipe to run the command
    saxonin, saxonout, saxonerr = os.popen3(cmd)
    
    # Utility function that removes empty lines from the results of 
    # running the command
    def strippedlines(lines):
        return [line.strip() for line in lines if line.strip()]
    
    # Return two lists, stdout and stderr output from the command
    return strippedlines(saxonout), strippedlines(saxonerr)