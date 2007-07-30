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
    assert len(sys.argv) == 3, 'path and file name for DSC XML and BHC XML, respectively.';
    dsc_path, bhc_path = sys.argv[1:];

    # get xml
    dsc_xml = ET.ElementTree(file=dsc_path).findall('//class');
    bhc_xml = ET.ElementTree(file=bhc_path).findall('//course');

    # build class list for dsc
    dsc_classes = {};
    dsc_repeats = [];
    for e in dsc_xml:
        syn = e.get('synonym');
        if (dsc_classes.has_key(syn)): dsc_repeats.append(syn);
        else: dsc_classes[syn] = e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section');

    # build class list for bhc
    bhc_classes = {};
    bhc_repeats = [];
    for course in bhc_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = e.get('synonym');
            if (bhc_classes.has_key(syn)): bhc_repeates.append(syn);
            else: bhc_classes[syn] = cid + e.get('section');

    # start comparison
    dsc_only = [];
    bhc_only = [];
    for k in dsc_classes.keys():
        if (not bhc_classes.has_key(k)): dsc_only.append(k);
    for k in bhc_classes.keys():
        if (not dsc_classes.has_key(k)): bhc_only.append(k);

    # now output
    fout = file('class-compare.txt', 'w');
    if (len(dsc_repeats) > 0):
        print 'DSC: ', len(dsc_repeats), ' repeats.';
        print >> fout, len(dsc_repeats), ' repeated classes in dsc xml:';
        for k in dsc_repeats: print >> fout, dsc_classes[k], ' : ', k;
    if (len(dsc_only) > 0):
        print 'DSC: ', len(dsc_only), ' onlys.';
        print >> fout, len(dsc_only), ' classes found only in dsc xml:';
        for k in dsc_only: print >> fout, dsc_classes[k], ' : ', k;
    if (len(bhc_repeats) > 0):
        print 'BHC: ', len(bhc_repeats), ' repeats.';
        print >> fout, len(bhc_repeats), ' repeated classes in bhc xml:';
        for k in bhc_repeats: print >> fout, bhc_classes[k], ' : ', k;
    if (len(bhc_only) > 0):
        print 'BHC: ', len(bhc_only), ' onlys.';
        print >> fout, len(bhc_only), ' classes found only in bhc xml:';
        for k in bhc_only: print >> fout, bhc_classes[k], ' : ', k;
