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
    assert len(sys.argv) == 5, 'path for: dsc, fix, form.';
    dsc_path, fix_path, form_path, out_path = sys.argv[1:];
    # flat_path, tidy_path, 

    # get xml
    dsc_xml  = ET.ElementTree(file=dsc_path).findall('//class');
    fix_xml  = ET.ElementTree(file=fix_path).findall('//course');
    form_xml = ET.ElementTree(file=form_path).findall('//course');
#    flat_xml = ET.ElementTree(file=flat_path).findall('//class');
#    tidy_xml = ET.ElementTree(file=tidy_path).findall('//course');

    # build class list for dsc
    dsc_classes = {};
    dsc_repeats = [];
    for e in dsc_xml:
        syn = e.get('synonym');
        if (dsc_classes.has_key(syn)): dsc_repeats.append(syn);
        else: dsc_classes[syn] = e.get('rubric') + ' ' + e.get('number') + '-' + e.get('section');

    # build class list for fixed
    fix_classes = {};
    fix_repeats = [];
    for course in fix_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = e.get('synonym');
            if (fix_classes.has_key(syn)): fix_repeats.append(syn);
            else: fix_classes[syn] = cid + e.get('section');

    # build class list for formed
    form_classes = {};
    form_repeats = [];
    for course in form_xml:
        cid = course.get('rubric') + ' ' + course.get('number') + '-';
        for e in course.findall('class'):
            syn = e.get('synonym');
            if (form_classes.has_key(syn)): form_repeats.append(syn);
            else: form_classes[syn] = cid + e.get('section');

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
            print '  ', len(dsc_only), ' missing classes.';
            print >> fout, len(dsc_only), ' classes not copied from dsc xml:';
            for k in dsc_only: print >> fout, dsc_classes[k], ' : ', k;
        if (len(fix_extra) > 0):
            print '  ', len(fix_extra), ' extra classes.';
            print >> fout, len(fix_extra), ' extra classes created by fix xml:';
            for k in fix_extra: print >> fout, fix_extra[k], ' : ', k;
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
            print '  ', len(dsc_only), ' missing classes.';
            print >> fout, len(dsc_only), ' classes not copied from dsc xml:';
            for k in dsc_only: print >> fout, dsc_classes[k], ' : ', k;
        if (len(form_extra) > 0):
            print '  ', len(form_extra), ' extra classes.';
            print >> fout, len(form_extra), ' extra classes created by fix xml:';
            for k in form_extra: print >> fout, form_extra[k], ' : ', k;
    else: print 'ok.';
    
    fout.close();
