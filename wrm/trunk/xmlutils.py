# $Id: xmlutils.py 2224 2006-09-22 21:32:30Z wrm2110 $

import re

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