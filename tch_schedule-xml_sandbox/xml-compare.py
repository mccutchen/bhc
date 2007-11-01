# Just building a list of courses from each xml document, then comparing the lists

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;

def main():
    # get filenames to work with
    import sys;
    if (len(sys.argv) == 5):
        dsc_path = [sys.argv[1]];
        fix_path, form_path, out_path = sys.argv[2:];
    elif (len(sys.argv) == 6):
        dsc_path = sys.argv[1:3];
        fix_path, form_path, out_path = sys.argv[3:];
    else:
        assert False, 'useage: xml-compare <dsc path> <fixed path> <formed path> <output path>';

    # build class list for dsc
    dsc_classes = {};
    dsc_repeats = [];
    for path in dsc_path:
        dsc_xml  = ET.ElementTree(file=path).findall('//class');
        for e in dsc_xml:
            syn = int(e.get('synonym'));
            if (dsc_classes.has_key(syn)): dsc_repeats.append(syn);
            else: dsc_classes[syn] = e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section');
    dsc_xml = None;

    # build class list for fixed
    fix_classes = {};
    fix_repeats = [];
    fix_xml  = ET.ElementTree(file=fix_path).findall('//course');
    for course in fix_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = int(e.get('synonym'));
            if (fix_classes.has_key(syn)): fix_repeats.append(syn);
            else: fix_classes[syn] = cid + e.get('section');
    fix_xml = None;

    # build class list for formed
    form_classes = {};
    form_repeats = [];
    form_xml = ET.ElementTree(file=form_path).findall('//course');
    for course in form_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = int(e.get('synonym'));
            if (form_classes.has_key(syn)): form_repeats.append(syn);
            else: form_classes[syn] = cid + e.get('section');
    form_xml = None;

    # start comparison
    fix_extra    = [];
    fix_missing  = [];
    form_extra   = [];
    form_missing = [];
    
    for k in dsc_classes.keys():
        if (not fix_classes.has_key(k)): fix_missing.append(k);
    for k in fix_classes.keys():
        if (not dsc_classes.has_key(k)): fix_extra.append(k);
        if (not form_classes.has_key(k)): form_missing.append(k);
    for k in form_classes.keys():
        if (not fix_classes.has_key(k)): form_extra.append(k);
        

    # now output
    fout = file(out_path, 'w');

    # dsc
    print 'DSC  ', len(dsc_classes), 'classes',
    if (len(dsc_repeats) > 0):
        print 'with errors:';
        if (len(dsc_repeats) > 0):
            print '  ', len(dsc_repeats), ' repeated classes.';
            print >> fout, len(dsc_repeats), ' repeated classes in dsc xml:';
            for k in dsc_repeats: print >> fout, dsc_classes[k], ' : ', k;
    else: print 'ok.';

    # fixed
    print 'Fix  ', len(fix_classes), 'classes',
    if (len(fix_repeats) > 0 or len(fix_missing) > 0 or len(fix_extra) > 0):
        print 'with errors:';
        if (len(fix_repeats) > 0):
            print '  ', len(fix_repeats), ' repeated classes.';
            print >> fout, len(fix_repeats), ' repeated classes in fixed xml:';
            for k in fix_repeats: print >> fout, fix_classes[k], ' : ', k;
        if (len(fix_missing) > 0):
            print '  ', len(fix_missing), ' missing classes.';
            print >> fout, len(fix_missing), ' classes not copied from dsc xml:';
            for k in fix_missing: print >> fout, dsc_classes[k], ' : ', k;
        if (len(fix_extra) > 0):
            print '  ', len(fix_extra), ' extra classes.';
            print >> fout, len(fix_extra), ' extra classes created by fix xml:';
            for k in fix_extra: print >> fout, fix_classes[k], ' : ', k;
    else: print 'ok.';

    # formed
    print 'Form ', len(form_classes), 'classes',
    if (len(form_repeats) > 0 or len(form_missing) > 0 or len(form_extra) > 0):
        print 'with errors:';
        if (len(form_repeats) > 0):
            print '  ', len(form_repeats), ' repeated classes.';
            print >> fout, len(form_repeats), ' repeated classes in fixed xml:';
            for k in form_repeats: print >> fout, form_classes[k], ' : ', k;
        if (len(form_missing) > 0):
            print '  ', len(form_missing), ' missing classes.';
            print >> fout, len(form_missing), ' classes not copied from dsc xml:';
            for k in form_missing: print >> fout, dsc_classes[k], ' : ', k;
        if (len(form_extra) > 0):
            print '  ', len(form_extra), ' extra classes.';
            print >> fout, len(form_extra), ' extra classes created by fix xml:';
            for k in form_extra: print >> fout, form_classes[k], ' : ', k;
    else: print 'ok.';
    
    fout.close();


if __name__ == '__main__':
    main();
