"""test.py -- crude tests for the ScheduleXML preprocessors

This is a really crude test for consistency between the input ScheduleXML
document from Rik Jones and the output ScheduleXML file after being
preprocessed.

At the moment, this just ensures that the root elements are the same, that
a few elements are included in the output file, and most importantly, that
the number of <class> elements is identical.

Making sure the number of <class> elements is identical tries to ensure that
we're not dropping information."""

try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET

MUST_BE_ROOT = 'schedule'
MUST_EXIST = 'term course class'.split()
MUST_COUNT_EQUAL = 'class'.split()

def test(a, b):
    a = ET.ElementTree(file=a)
    b = ET.ElementTree(file=b)

    # make sure we have the correct root element
    assert a.getroot().tag == MUST_BE_ROOT and b.getroot().tag == MUST_BE_ROOT, 'Wrong root element.  Expected <%s>' % MUST_BE_ROOT

    # make sure each element that must be in the schedule
    # is actually there
    for tag in MUST_EXIST:
        xpath = '//%s' % tag
        assert a.findall(xpath) and b.findall(xpath), 'Element <%s> missing.' % tag

    # make sure that each element which must show up an
    # equal amount of times, does
    for tag in MUST_COUNT_EQUAL:
        xpath = '//%s' % tag
        a_els = a.findall(xpath)
        b_els = b.findall(xpath)

        assert len(a_els) == len(b_els), 'Element <%s> does not appear the same number of times (%d vs. %d).' % (tag, len(a_els), len(b_els))

if __name__ == '__main__':
    import sys
    assert len(sys.argv) == 3, 'The two files to compare must be given as arguments'
    a, b = sys.argv[1:]
    try:
        test(a, b)
    except AssertionError, e:
        print '*** A test failed ***'
        print '*** Error message: %s' % e