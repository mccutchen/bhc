# $Id: sxml.py 820 2005-04-15 20:01:28Z wrm2110 $

from cElementTree import ElementTree, Element, SubElement, tostring
import Pyana
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
        SubElement(el, childname).text = value

    return el

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


def transform(root, xslpath, xslparams={}, xmlencoding='utf-8'):
    xsldata = file(xslpath).read()
    xmldata = tostring(root, xmlencoding)
    result = Pyana.transform2String(source=xmldata, style=xsldata, params=xslparams)
    return result
    
def transformer(root, xslpath, xpath=None, nameattribute=None, xslparams={}, xmlencoding='utf-8'):
    """
    Provides a very specialized generator object which takes
    an xml.dom.Document object and (optionally) breaks it apart
    into splitelement elements and transforms it according to the
    stylesheet located at xslpath.
    
    Useful if your data is in one big XML file whose root element's children
    are the bits that need to be transformed.  If that makes sense.
    """    
    # get the xsl data into a string
    xsldata = file(xslpath).read()
    
    # split the element into the chunks that we're interested in
    if xpath:
        chunks = root.findall(xpath)
    
    # or just let chunks be the root element
    else: chunks = [root]
    
    # process each chunk and return the transformation results and the
    # name provided by nameattribute
    for chunk in chunks:
        chunkxml = tostring(chunk, xmlencoding)
        result = Pyana.transform2String(source=chunkxml, style=xsldata, params=xslparams)
        if nameattribute:
            yield chunk.attrib.get(nameattribute), result
        else:
            yield result
