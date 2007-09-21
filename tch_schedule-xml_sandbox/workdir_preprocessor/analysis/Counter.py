# Just building a list of courses from tidy xml document, 
#   then ripping out the DL classes and checking the topic
#   codes by division/subject/course/class.

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;


def CountDLs(input_path):
    # get xml
    print input_path;
    xml = ET.ElementTree(file=input_path);
    types_xml = xml.findall('//type');
    
    # count courses & classes
    course_count = 0;
    class_count  = 0;
    for t in types_xml:
        if (t.get('id') != 'DL'): continue;

        courses_xml = t.findall('course');
        course_count += len(courses_xml);
        for c in courses_xml:
            classes_xml = c.findall('class');
            class_count += len(classes_xml);
            
    print 'Total courses: ' + str(course_count);
    print 'Total classes: ' + str(class_count);


if __name__ == '__main__':
    # get filenames to work with
    import sys, os;
    assert len(sys.argv) == 2, 'path and file name for tidy XML.';
    input_path = sys.argv[1];

    # count
    CountDLs(input_path);
