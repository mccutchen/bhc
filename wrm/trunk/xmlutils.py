# $Id: xmlutils.py 2224 2006-09-22 21:32:30Z wrm2110 $

import re
from cElementTree import ElementTree, Element, SubElement, iselement, tostring, fromstring
import wrm.decorators
from wrm.utils import exclude

@wrm.decorators.cached
def add_element(parent, tagname, attrs={}, children={}, text=None):
    """
    add_element(parent, tagname[, attrs[, children[, text]]]) -> ElementTree.Element

    Returns an ElementTree.Element object which is guaranteed
    to be unique, based on the given arguments.
    """

    forbiddenvalues = [None, '']
    attrs = exclude(attrs, values=forbiddenvalues)
    children = exclude(children, values=forbiddenvalues)

    el = SubElement(parent, tagname, **attrs)

    if text and not attrs and not children:
        el.text = text

    for childname, value in children.items():
        if is_xml_fragment(value) and not value.startswith('<%s' % childname):
            # create a valid xml fragment
            value = '<%s>%s</%s>' % (childname, value, childname)
            child = fromstring(value)
            el.append(child)
        else:
            SubElement(el, childname).text = value

    return el

def is_xml_fragment(data):
    if isinstance(data, basestring):
        if '<' in data and '>' in data:
            return True
    return False

def xml_escape(text):
    """Encodes reserved and non-ascii chars in text as numerical
    entity references.  Taken from ElementTree.SimpleXMLWriter."""

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


def get_unique_element(root, tagname, attrs={}, children={}):
    """
    Returns the first element in root whose attributes
    match those given in the attrs dictionary
    """
    candidates = root.findall(tagname)
    for candidate in candidates:
        badflag = 0
        for attr, value in attrs.items():
            if candidate.attrib.get(attr) != value:
                badflag = 1
                break
        if not badflag:
            return candidate

    el = SubElement(root, tagname, **attrs)
    for childname, value in children.items():
        SubElement(el, childname).text = value
    return el
