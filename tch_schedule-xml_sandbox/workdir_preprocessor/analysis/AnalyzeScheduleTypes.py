# Just building a list of courses from tidy xml document, 
#   then ripping out the schedule-types and doing some minor 
#   analysis of the courses/devisions that contain those 
#   schedule-types.

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;

class DivisionItem:
    def __init__(self, name):
        self.name = name;
        self.sched_dict = {};
        self.course_dict = {};
class CourseItem:
    def __init__(self, name):
        self.name = name;
        self.class_list = [];
class ClassItem:
    def __init__(self, syn, sec):
        self.syn = syn;
        self.sec = sec;

def BuildUrl(name):
    name_list = list(name);
    i = 0;
    while (i < len(name_list)):
        n = name_list[i];
        if (not((n >= 'a' and n <= 'z') or  (n >= 'A' and n <= 'Z') or (n <= '0' and n >= '9'))):
            name_list[i] = '_';
        i = i + 1;
    return (''.join(name_list)).replace('__', '_');

def TopLink(name):
    return '<a href="../' + BuildUrl(name) + '.html">' + name + '</a>';
def DivLink(name):
    return '<a href="divisions/' + BuildUrl(name) + '.html">' + name + '</a>';
def STLink(name):
    return '<a href="sts/' + BuildUrl(name) + '.html">' + name + '</a>';

def CountST(div_list):
    course_cnt = 0;
    class_cnt  = 0;
    for d in div_list:
        course_cnt = course_cnt + len(d.course_dict.keys());
        class_cnt  = class_cnt  + CountCourse(d.course_dict);
    return str(course_cnt) + '/' + str(class_cnt);

def CountDiv(st_dict):
    course_cnt = 0;
    class_cnt  = 0;
    for st in st_dict.keys():
        course_cnt = course_cnt + len(st_dict[st].keys());
        class_cnt  = class_cnt  + CountCourse(st_dict[st]);
    return str(course_cnt) + '/' + str(class_cnt);

def CountCourse(course_dict):
    class_cnt = 0;
    for key in course_dict.keys():
        class_cnt = class_cnt + len(course_dict[key].class_list);
    return class_cnt;

def BuildDivList(input_path):
    # get xml
    xml = ET.ElementTree(file=input_path);
    divisions_xml = xml.findall('//division');
    
    # build div_list
    div_list = [];
    for d in divisions_xml:
        division_name = d.get('name');
        temp_div = DivisionItem(division_name);

        types_xml = d.findall('.//type');
        for t in types_xml:
            type_name = t.get('name');
            
            st = t.get('id');
            if (st == ""): st = "none";
        
            if (not temp_div.sched_dict.has_key(st)):
                temp_div.sched_dict[st] = {};
                
            courses_xml = t.findall('.//course');
            for c in courses_xml:
                course_name = c.get('title-long');
                course_id   = c.get('rubric') + ' ' + c.get('number');
                
                if (not temp_div.sched_dict[st].has_key(course_id)):
                    temp_div.sched_dict[st][course_id] = CourseItem(course_name);
                    
                classes_xml = c.findall('.//class');
                for b in classes_xml:
                    class_sec = b.get('section');
                    class_syn = b.get('synonym');

                    # add to div_list
                    temp_div.sched_dict[st][course_id].class_list.append(ClassItem(class_syn, class_sec));

        # add temp_div to div_list
        div_list.append(temp_div);

    # return results
    return div_list;

def BuildSTDict(div_list):
    # build st_dict
    st_dict = {};
    for d in div_list:
        for st in d.sched_dict.keys():
            if (not st): continue;
            if (not st_dict.has_key(st)):
                st_dict[st] = [];
            temp_div = DivisionItem(d.name);
            temp_div.course_dict = d.sched_dict[st];
            st_dict[st].append(temp_div);

    # return what we've got
    return st_dict;

def WriteIndex(output_path, st_dict, start_str, end_str, lvl, ind):
    # build output (index)
    out_str = start_str;
    for st in st_dict.keys():
        if (not st): continue;
        out_str = out_str + ind*lvl + '<div class="division">\n';
        # DEBUG:
        if (not st_dict[st]):
            print "WriteIndex: empty st_dict[st]: '" + st + "'.";
        else:
            out_str = out_str + ind*(lvl+1) + '<h3>' + CountST(st_dict[st]) + ' - ' + STLink(st) + '</h3>\n';
        out_str = out_str + ind*(lvl+1) + '<ul>\n';
        for d in st_dict[st]:
            out_str = out_str + ind*(lvl+2) + '<li>' + str(len(d.course_dict)) + '/' + str(CountCourse(d.course_dict)) + ' - ' + DivLink(d.name) + '</li>\n';
        out_str = out_str + ind*(lvl+1) + '</ul>\n';
        out_str = out_str + ind*lvl + '</div>\n';
    out_str = out_str + end_str;

    f_out = open((os.path.normcase(output_path + '/index.html')).replace('\\\\', '\\'), 'w');
    print >> f_out, out_str;
    f_out.close();

def WriteDivs(output_path, div_list, start_str, nav_str, end_str, lvl, ind):
    for d in div_list:
        out_str = start_str + nav_str;
        out_str = out_str + ind*lvl + '<h3>' + CountDiv(d.sched_dict) + ' - ' + d.name + '</h3>\n';
        
        out_str = out_str + ind*lvl + '<ul>\n';
        for st in d.sched_dict.keys():
            # DEBUG:
            if (not d.sched_dict[st]):
                print "WriteDivs: empty st_dict[st]: '" + st + "'.";
            elif (not d.sched_dict[st].keys()):
                print "WriteDivs: empty dict at st: '" + st + "'.";
            else:
                out_str = out_str + ind*(lvl+1) + '<li>' + str(len(d.sched_dict[st].keys())) + '/' + str(CountCourse(d.sched_dict[st])) + ' - ' + st + '\n';

                out_str = out_str + ind*(lvl+2) + '<ul>\n';
                out_str = out_str + BuildClassString(d.sched_dict[st], lvl+3, ind);
                out_str = out_str + ind*(lvl+2) + '</ul>\n';
                out_str = out_str + ind*(lvl+1) + '</li>\n';
        out_str = out_str + ind*lvl + '</ul>\n';
        out_str = out_str + end_str;

        path = os.path.normcase(output_path + '/divisions/').replace('\\\\', '\\');
        if (not(os.path.exists(path))):
            os.mkdir(path);
        f_out = open((os.path.normcase(path + BuildUrl(d.name) + '.html')).replace('\\\\', '\\'), 'w');
        print >> f_out, out_str;
        f_out.close();
    
def WriteSTs(output_path, st_dict, start_str, nav_str, end_str, lvl, ind):
    for st in st_dict.keys():
        div_list = st_dict[st];
        out_str = start_str + nav_str;
        out_str = out_str + ind*lvl + '<h3>' + CountST(div_list) + ' - ' + st + '</h3>\n';
        
        out_str = out_str + ind*lvl + '<ul>\n';
        for d in div_list:
            out_str = out_str + ind*(lvl+1) + '<li>' + str(len(d.course_dict.keys())) + '/' + str(CountCourse(d.course_dict)) + ' - ' + d.name + '\n';

            out_str = out_str + ind*(lvl+2) + '<ul>\n';
            out_str = out_str + BuildClassString(d.course_dict, lvl+3, ind);
            out_str = out_str + ind*(lvl+2) + '</ul>\n';
            out_str = out_str + ind*(lvl+1) + '</li>\n';
        out_str = out_str + ind*lvl + '</ul>\n';
        out_str = out_str + end_str;

        path = os.path.normcase(output_path + '/sts/').replace('\\\\', '\\');
        if (not(os.path.exists(path))):
            os.mkdir(path);
        f_out = open((os.path.normcase(path + BuildUrl(st) + '.html')).replace('\\\\', '\\'), 'w');
        print >> f_out, out_str;
        f_out.close();
    

def BuildClassString(course_dict, lvl, ind):
    out_str = "";
    
    for cid in course_dict.keys():
        course = course_dict[cid];
        out_str = out_str + ind*lvl + '<li>' + str(len(course.class_list)) + ' - ' + course.name + '<br />\n';

        for c in course.class_list:
            out_str = out_str + ind*(lvl+1) + c.sec + ' (' + c.syn + ')  ';

        out_str = out_str + ind*lvl + '</li>\n';

    return out_str;



if __name__ == '__main__':
    # get filenames to work with
    import sys, os;
    assert len(sys.argv) == 3, 'path and file name for tidy XML.';
    input_path, output_path = sys.argv[1:];
    assert(os.path.isfile(input_path)), 'invalid data dir.';
    if (os.path.exists(output_path)):
        assert(os.path.isdir(output_path)), 'invalid output dir.';
    else:
        os.mkdir(output_path);

    # build data structures
    div_list = BuildDivList(input_path);
    st_dict  = BuildSTDict(div_list);

    # write output (three ways)

    # generic output vars
    start_str = '<html>\n\t<head>\n\t\t<title>Schedule Type Report</title>\n\t</head>\n\t<body>\n';
    nav_str   = '\t\t<div class="nav">\n\t\t\t' + TopLink('index') + '\n\t\t</div>\n';
    end_str   = '\t</body>\n</html>';
    
    # build output (index)
    WriteIndex(output_path, st_dict, start_str, end_str, 2, '\t');

    # build output (divisions)
    WriteDivs(output_path, div_list, start_str, nav_str, end_str, 3, '\t');

    # build output (schedule types)
    WriteSTs(output_path, st_dict, start_str, nav_str, end_str, 3, '\t');
