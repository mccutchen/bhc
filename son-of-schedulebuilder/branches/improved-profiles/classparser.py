# $Id: classparser.py 2342 2006-10-27 20:21:09Z wrm2110 $

import datetime, os, sys
from wrm.utils import parsedate, files

# application settings
from profiles import profile
from schemas import schema

def parse_classes():
    """Parses each line of the input file according to the
    schema defined in schemas.schema."""

    print 'Parsing data from %s ...' % ', '.join(profile.input)

    classes = []
    parsedcount = 0
    skippedcount = 0
    for line in files(*profile.input):
        classdata = schema.extract(line)
        if include_class(classdata):
            classes.append(classdata)
            parsedcount += 1
            report_progress(parsedcount)
        else:
            skippedcount += 1

    # report the results
    print
    print '%d total classes parsed' % parsedcount
    print '%d total classes skipped' % skippedcount
    print

    return classes

def include_class(input):
    """Tests whether or not this class should be included in the final
    output, according to various settings in the current profile."""

    # Should this class be suppressed according to its topic code?
    if input['topic-code'] in profile.skip_topic_codes:
        return False

    # only include classes that begin after the date given in the profile
    # if applicable
    if profile.include_classes_after:
        begindate = parsedate(input['start-date'])
        if begindate < profile.include_classes_after:
            return False

    # if we're generating a Core Curriculum schedule, skip any
    # classes that aren't marked as 'core'
    if profile.core_only_schedule and not input['core-component']:
        return False

    # if we're generating a non-Core Curriculum schedule, skip any
    # 'core' classes
    if profile.non_core_schedule and input['core-component']:
        return False
    
    # filter out junk lines, which won't start with a valid year
    try:
        assert int(input['year']) >= 1900
    except (ValueError, AssertionError):
        return False

    # go ahead and include this class
    return True

def report_progress(count):
    if count % 100 == 0:
        print count,


if __name__ == '__main__':
    results = parse_classes()
    print
    print '%d classes.' % len(results)

    import random
    from pprint import pprint
    pprint(results[random.randint(0, len(results))])
