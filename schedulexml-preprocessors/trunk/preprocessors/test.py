"""test.py -- crude tests for the ScheduleXML preprocessors

This is a really crude test for consistency between the input
ScheduleXML document from Rik Jones and the output ScheduleXML file
after being preprocessed.

At the moment, this just ensures that the root elements are the same,
that a few elements are included in the output file, and most
importantly, that the number of <class> elements is identical.

Making sure the number of <class> elements is identical tries to
ensure that we're not dropping information."""

import sys

try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET

MUST_BE_ROOT = 'schedule'
MUST_EXIST = 'term course class'.split()
MUST_BE_NONEMPTY = 'schedule term grouping course'.split()
MUST_COUNT_EQUAL = 'class'.split()

def reporterrors(testfunc):
    def error_reporter(*args, **kwds):
        try:
            testfunc(*args, **kwds)
            return True
        except AssertionError, e:
            print >> sys.stderr, '*** A test failed ***'
            print >> sys.stderr, '*** Error message: %s' % e
            return False
    error_reporter.__name__ = testfunc.__name__
    error_reporter.__doc__ = testfunc.__doc__
    return error_reporter

@reporterrors
def test(old, new):
    old = ET.ElementTree(file=old)
    new = ET.ElementTree(file=new)

    # make sure we have the correct root element
    assert old.getroot().tag == MUST_BE_ROOT and \
        new.getroot().tag == MUST_BE_ROOT, \
        'Wrong root element.  Expected <%s>' % MUST_BE_ROOT

    # make sure each element that must be in the schedule is actually
    # there
    for tag in MUST_EXIST:
        xpath = '//%s' % tag
        assert old.findall(xpath) and new.findall(xpath), \
            'Element <%s> missing.' % tag
    
    # make sure each element that must not be empty has at least one
    # child element
    for tag in MUST_BE_NONEMPTY:
        for el in new.findall('//%s' % tag):
            assert len(el) > 0, \
                'Element <%s> cannot be empty' % tag

    # make sure that each element which must show up an equal amount
    # of times, does
    for tag in MUST_COUNT_EQUAL:
        xpath = '//%s' % tag
        old_els = old.findall(xpath)
        new_els = new.findall(xpath)

        assert len(old_els) == len(new_els), \
            'Element <%s> does not appear the same number of times ' \
            '(%d in old document vs. %d in new document).' \
            % (tag, len(old_els), len(new_els))
    
    # all tests passed
    return True

if __name__ == '__main__':
    import sys
    assert len(sys.argv) == 3, \
        'The two files to compare must be given as arguments'
    a, b = sys.argv[1:]
    test(a, b)
