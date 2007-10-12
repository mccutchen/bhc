# Just building a list of courses from each xml document, then comparing the lists

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;

import sys, os, re

semester = '';

def main():
    # get filenames to work with
    assert len(sys.argv) == 2, 'path and file name for DSC XML.';
    dsc_path = os.path.normcase(sys.argv[1]);
    assert os.path.isfile(dsc_path), 'file does not exist';

    semester = (os.path.splitext(os.path.basename(os.path.normcase(dsc_path)))[0]).split('-')[2];
    
    # get xml
    print 'Retrieving xml...',
    dsc_xml  = ET.ElementTree(file=dsc_path).findall('//class');
    print 'done.'

    # build class list for dsc
    print 'Analyzing data...',
    dsc_same = {};
    dsc_diff = {};
    count    = [0,0];
    dsc_mini_values = {};
    for e in dsc_xml:
        syn = e.get('synonym');
        if (dsc_same.has_key(syn) or dsc_diff.has_key(syn)):
            print 'Repeated synonym: ', syn;
        else:
            item = [
                e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section'),
                bool(e.get('minimester') == 'true' or e.get('minimester') == 'True' or e.get('minimester') == None),
                is_minimester(e)];

            # add to dict
            if (item[1] == item[2]):
                dsc_same[syn] = item;
            else:
                dsc_diff[syn] = item;

            # incriment counters
            if (item[1]): count[0] += 1;
            if (item[2]): count[1] += 1;

        # store val
        key = e.get('minimester');
        if dsc_mini_values.has_key(key): dsc_mini_values[key] += 1;
        else: dsc_mini_values[key] = 1;
            
    print 'done.'

    # now output
    print 'Writing output...',
    fout = file('analyze-minimesters_' + os.path.splitext(os.path.basename(dsc_path))[0] + '.htm', 'w');
    print >> fout, '<html>';

    keys = dsc_diff.keys();
    keys.sort();
    print >> fout, '<h3>Different: ', str(len(keys)), '</h3><table>';
    print >> fout, '<tr><th>Class</th><th>Syn</th><th>dsc</th><th>bhc</th></tr>';
    for key in keys:
        e = dsc_diff[key];
        print >> fout, '<tr><td>', e[0], '</td><td>', key, '</td><td>', e[1], '/', e[2], '</td></tr>';
    print >> fout, '</table>';

    keys = dsc_same.keys();
    keys.sort();
    print >> fout, '<h3>Same: ', str(len(keys)), '</h3><table>';
    print >> fout, '<tr><th>Class</th><th>Syn</th><th>dsc</th><th>bhc</th></tr>';
    for key in keys:
        e = dsc_same[key];
        print >> fout, '<tr><td>', e[0], '</td><td>', key, '</td><td>', e[1], '/', e[2], '</td></tr>';
    print >> fout, '</table>';

    print >> fout, '</html>';
    fout.close();
    print 'done.'

    print '\n\n'
    print 'Summary:'
    print 'classes: ', len(dsc_same) + len(dsc_diff)
    print 'same: ', len(dsc_same)
    print 'diff: ', len(dsc_diff)
    print 'dsc mini count: ', count[0]
    print 'bhc mini count: ', count[1]

    print '\n\n'
    print 'Values of minimester in dsc xml:'
    for key in dsc_mini_values.keys():
        print str(key), ':', str(dsc_mini_values[key])


def is_minimester(e):
    """A course counts as a "minimester" course if either of the following
       conditions are met:
        - The class is a "Flex Day" or "Flex Night" class OR
        - The class lasts less than profile.minimester_threshold weeks AND
       the class does not match any of the patterns in
       profile.skip_minimesters"""

    # here's some values to make things work (profile.blahblah)
    minimester_threshold = 15;
    if (re.match('s[12]$', semester)):
        minimester_threshold = 0
    skip_minimesters = {
        'rubric': ['EMSP', 'RADR', 'RNSG', 'HPRS'],
        'topic-code': ['^E$'] }
    

    try:
        # collect the data we need to determine whether this is a
        # minimester class
        classtype = e.get('schedule-type')
        rubric = e.get('rubric')
        topic  = str(e.get('topic-code'))
        weeks = int(e.get('weeks').strip())
        start_date = e.get('start-date')
        end_date = e.get('end-date')
        #? term = FormatUtils.get_term(classdata['term'], start_date)
        
        # does this class meet the minimum criteria?
        if classtype in ('FD', 'FN') or \
            weeks < minimester_threshold:
        #or \
            #? is_flex_hack(start_date, end_date, term): # UGLY, TEMPORARY HACK!

            # if this class matches any of the patterns in
            # profile.skip_minimesters, return False
            for pattern in skip_minimesters.get('rubric'):
                if rubric in pattern:
                    return False
            for pattern in skip_minimesters.get('topic-code'):
                if re.match(pattern, topic):
                    return False;

            # all tests passed, so this class qualifies as a
            # minimester class
            return True

    except ValueError:
        # error converting the number of weeks to an int
        pass

    # some test along the way failed, so return False
    return False

def any(sequence, test=lambda x:x):
    for item in iter(sequence):
        if test(item):
            return True
    return False


if __name__ == '__main__':
    main();
