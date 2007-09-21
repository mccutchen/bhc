# Just building a list of courses from each xml document, then comparing the lists

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;

if __name__ == '__main__':
    # get filenames to work with
    import sys;
    assert len(sys.argv) == 6, 'path and file name for DSC XML, flat XML, and tidy XML, respectively.';
    dsc_path, flat_path, tidy_path, semester, year = sys.argv[1:];

    # get xml
    dsc_xml  = ET.ElementTree(file=dsc_path).findall('//class');
    flat_xml = ET.ElementTree(file=flat_path).findall('//class');
    tidy_xml = ET.ElementTree(file=tidy_path).findall('//course');

    # build class list for dsc
    dsc_classes = {};
    dsc_repeats = [];
    for e in dsc_xml:
        syn = e.get('synonym');
        if (dsc_classes.has_key(syn)): dsc_repeats.append(syn);
        else: dsc_classes[syn] = e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section');

    # build class list for flat
    flat_classes = {};
    flat_repeats = [];
    for e in flat_xml:
        syn = e.get('synonym');
        if (flat_classes.has_key(syn)): flat_repeats.append(syn);
        else: flat_classes[syn] = e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section');
        
    # build class list for tidy
    tidy_classes = {};
    tidy_repeats = [];
    for course in tidy_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = e.get('synonym');
            if (tidy_classes.has_key(syn)): tidy_repeats.append(syn);
            else: tidy_classes[syn] = cid + e.get('section');

    # start comparison
    # first, flat is compared to dsc
    # then,  tidy is compared to flat
    # this allows me to see if any information is lost along the way, and at which step.
    dsc_only   = [];
    flat_extra = [];
    flat_only  = [];
    tidy_extra = [];
    tidy_only  = [];
    
    for k in dsc_classes.keys():
        if (not flat_classes.has_key(k)): dsc_only.append(k);
    for k in flat_classes.keys():
        if (not dsc_classes.has_key(k)): flat_extra.append(k);

    for k in flat_classes.keys():
        if (not tidy_classes.has_key(k)): flat_only.append(k);
    for k in tidy_classes.keys():
        if (not flat_classes.has_key(k)): tidy_extra.append(k);
    # and just in case something weird happens:
    for k in tidy_classes.keys():
        if (not dsc_classes.has_key(k)): tidy_only.append(k);

    # now output
    fout = file('output/' + year + '-' + semester + '_class-compare.txt', 'w');
    print 'DSC  ', len(dsc_classes), 'courses',
    if (len(dsc_repeats) > 0):
        print 'with errors:';
        if (len(dsc_repeats) > 0):
            print '  ', len(dsc_repeats), ' repeats.';
            print >> fout, len(dsc_repeats), ' repeated classes in dsc xml:';
            for k in dsc_repeats: print >> fout, dsc_classes[k], ' : ', k;
    else: print 'ok.';
    
    print 'flat ', len(flat_classes), 'courses',
    if ((len(flat_repeats) > 0) or (len(flat_extra) > 0) or (len(dsc_only) > 0)):
        print 'with errors:';
        if (len(flat_repeats) > 0):
            print '  ', len(flat_repeats), ' repeats.';
            print >> fout, len(flat_repeats), ' repeated classes in flat xml:';
            for k in flat_repeats: print >> fout, flat_classes[k], ' : ', k;
        if (len(dsc_only) > 0):
            print '  ', len(dsc_only), ' missing.';
            print >> fout, len(dsc_only), ' classes not copied from dsc xml:';
            for k in dsc_only: print >> fout, dsc_classes[k], ' : ', k;
        if (len(flat_extra) > 0):
            print '  ', len(flat_extra), ' extra classes.';
            print >> fout, len(flat_extra), ' extra classes created by flat xml:';
            for k in flat_extra: print >> fout, flat_extra[k], ' : ', k;
    else: print 'ok.';

    print 'tidy ', len(tidy_classes), 'courses',
    if ((len(tidy_repeats) > 0) or (len(flat_only) > 0) or (len(tidy_only) > 0)):
        print 'with errors:';
        if (len(tidy_repeats) > 0):
            print '  ', len(tidy_repeats), ' repeats.',;
            print >> fout, len(tidy_repeats), ' repeated classes in tidy xml:';
            for k in tidy_repeats: print >> fout, tidy_classes[k], ' : ', k;
        if (len(flat_only) > 0):
            print '  ', len(flat_only), ' missing.',;
            print >> fout, len(flat_only), ' classes not copied from flat xml:';
            for k in flat_only: print >> fout, flat_classes[k], ' : ', k;
        if (len(tidy_extra) > 0):
            print '  ', len(tidy_extra), ' extra classes.';
            print >> fout, len(tidy_extra), ' extra classes created by tidy xml:';
            for k in tidy_extra: print >> fout, tidy_extra[k], ' : ', k;
        if (len(tidy_only) > 0):
            print '  ', len(tidy_only), ' imaginary classes.',;
            print >> fout, len(tidy_only), ' imaginary classes found only in tidy xml:';
            for k in tidy_only: print >> fout, tidy_classes[k], ' : ', k;
    else: print 'ok.';
