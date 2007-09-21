# Just building a list of courses from tidy xml document, 
#   then ripping out the DL classes and checking the topic
#   codes by division/subject/course/class.

# some globals
title_index = 'Topic Code Report for Distance Learning Courses';
title_tcs   = 'Topic Code Report for Distance Learning Courses: Topic-Code '; # followed by tc
title_divs  = 'Topic Code Report for Distance Learning Courses: '; # followed by division name
stylesheet  = 'dl_analysis.css';
style_str   = 'h1, h2, h3, h4, h5\n{\n\tmargin:  0 0 0 0;\n\tpadding: 0 0 0 0;\n}\nul, li\n{\n\tmargin:  0 0 0 0;\n\tpadding: 0 0 0 5px;\n\tlist-style: none;\n}\ndiv\n{\n\tmargin-left: 10px;\n}\n\ndiv.index, div.by-tc, div.by-div\n{\n\twidth: 600px;\n\tposition: absolute;\n\tleft: 50%;\n\tmargin-left: -300px;\n}\n\ndiv.index div.topic-code, div.by-tc div.topic-code, div.by-div div.division\n{\n\tbackground-color: #DDDDDD;\n\tborder: 1px solid #000000;\n\tmargin-bottom: 15px;\n}\n\ndiv.index div.topic-code, div.by-tc div.topic-code, div.by-div div.division\n{\n\tborder-bottom: 1px solid #000000;\n\tmargin-left: 0px;\n}\n\ndiv.nav\n{\n\ttext-align: center;\n\tbackground-color: #DDDDDD;\n\tborder: 1px solid #000000;\n\tmargin-bottom: 15px;\n\tmargin-left: 0px;\n}\n\na:link\n{\n\tcolor: #1111AA;\n}';

# get xml lib (stolen out of Will's test.py)
try:
    # Python 2.5 has ElementTree built in
    from xml.etree import cElementTree as ET;
except ImportError:
    # Otherwise, it must be installed by the user
    import cElementTree as ET;


class Item(object):
    def __init__(self):
        self.item_dict = {};
        self.course_dict = {};
    def has_key(self, key):
        return self.item_dict.has_key(key);
    def __getitem__(self, key):
        return self.item_dict[key];
    def __setitem__(self, key, value):
        self.item_dict[key] = value;
    def keys(self):
        return self.item_dict.keys();
    def items(self):
        return self.item_dict.items();
    def values(self):
        return self.item_dict.values();
    def Merge(self, other):
        self.MergeItems(self, other.item_dict);
        self.MergeCourses(self, other.course_dict);
    def MergeItems(self, other):
        for key in other.keys():
            if (not self.item_dict.has_key(key)):
                self.item_dict[key] = other[key];
            else:
                self.item_dict[key] += other[key];
    def MergeCourses(self, other):
        for key in other.keys():
            if (not self.course_dict.has_key(key)):
                self.course_dict[key] = other[key];
            else:
                self.course_dict[key] += other[key];
    def Count(self):
        return Count(self.item_dict) + Count(self.course_dict);

class CourseItem(object):
    def __init__(self, title):
        self.title    = title;
        self.class_list = [];
    def keys(self):
        return [];
    def Count(self):
        return len(self.class_list);

class ClassItem(object):
    def __init__(self, sec, syn):
        self.sec = sec;
        self.syn = syn;

def Count(item):
    count = 0;
    if (type(item) == Item):
        return item.Count();
    elif (type(item) == CourseItem):
        return item.Count();
    elif(type(item) == CourseItem):
        return 1;
    elif (type(item) == dict):
        for key in item.keys():
            count += Count(item[key]);
        return count;
    elif (type(item) == list):
        return len(item);
    else:
        assert 0, 'Count(items): Unknown item type: ' + str(type(item));

def BuildUrl(name):
    name_list = list(name);
    i = 0;
    while (i < len(name_list)):
        n = name_list[i];
        if (not((n >= 'a' and n <= 'z') or  (n >= 'A' and n <= 'Z') or (n <= '0' and n >= '9'))):
            name_list[i] = '_';
        i += 1;
    return (''.join(name_list)).replace('__', '_');

def BuildStartString(template, title, stylesheet):
    return (template[0] + title + template[1] + template[2] + stylesheet + template[3]);

def Level_0_Link(name, path=''):
    if (path == ''):
        return '<a href="' + BuildUrl(name) + '.html">' + name + '</a>';
    else:
        return '<a href="' + BuildUrl(path) + '/' + BuildUrl(name) + '.html">' + name + '</a>';
def Level_1_Link(name, path=''):
    if (path == ''):
        return '<a href="../' + BuildUrl(name) + '.html">' + name + '</a>';
    else:
        return '<a href="../' + BuildUrl(path) + '/' + BuildUrl(name) + '.html">' + name + '</a>';


def BuildDLDict(input_path):
    # get xml
    xml = ET.ElementTree(file=input_path);
    divisions_xml = xml.findall('//division');
    
    # build dl_dict
    dl_dict = {};
    for d in divisions_xml:
        subjects_xml = d.findall('subject');
        for s in subjects_xml:
            subject_courses = CompileCourseDict(s);
            topics_xml = s.findall('topic');
            for t in topics_xml:
                topic_courses = CompileCourseDict(t);
                subtopics_xml = t.findall('subtopic');
                for st in subtopics_xml:
                    subtopic_courses = CompileCourseDict(st);
                    dl_dict = MergeCourses(dl_dict, subtopic_courses, d, s, t, st);
                dl_dict = MergeCourses(dl_dict, topic_courses, d, s, t);
            dl_dict = MergeCourses(dl_dict, subject_courses, d, s);
    return dl_dict;


def CompileCourseDict(xml):
    # find courses
    course_dict = {};
    types_xml = xml.findall('type');
    for t in types_xml:
        if (t.get('id') != 'DL'): continue;

        courses_xml = t.findall('course');
        for c in courses_xml:
            rubric = c.get('rubric');
            number = c.get('number');
            cid    = rubric + ' ' + number;

            classes_xml = c.findall('class');
            for x in classes_xml:
                key = x.get('topic-code');
                if (not course_dict.has_key(key)):
                    course_dict[key] = {};
                if (not course_dict[key].has_key(cid)):
                    course_dict[key][cid] = CourseItem(c.get('title-long'));
                course_dict[key][cid].class_list.append(ClassItem(x.get('section'), x.get('synonym')));

    return course_dict;

def MergeCourses(dl_dict, course_dict, d, s, t=None, st=None):
    for key in course_dict.keys():
        div = d.get('name');
        sub = s.get('name');
        if (t != None): top = t.get('name');
        if (st != None): stop = st.get('name');

        # key (topic-code)
        if (not dl_dict.has_key(key)):
            dl_dict[key] = {};

        # division
        if (not dl_dict[key].has_key(div)):
            dl_dict[key][div] = {};

        #subject
        if (not dl_dict[key][div].has_key(sub)):
            dl_dict[key][div][sub] = Item();

        # see if we are dealing with a sub-list or a sub-dict
        if (t == None):
            dl_dict[key][div][sub].MergeCourses(course_dict[key]);
        else:
            top = t.get('name');
            if (not dl_dict[key][div][sub].has_key(top)):
                dl_dict[key][div][sub][top] = Item();
            if (st == None):
                dl_dict[key][div][sub][top].MergeCourses(course_dict[key]);
            else:
                stop = st.get('name');
                if (not dl_dict[key][div][sub][top].has_key(stop)):
                    dl_dict[key][div][sub][top][stop] = Item();
                dl_dict[key][div][sub][top][stop].MergeCourses(course_dict[key]);

    return dl_dict;

def CleanDivDict(dl_dict):
    for dk in dl_dict.keys():
        if (dl_dict[dk].Count() == 0): del dl_dict[dk];
        else:
            for sk in dl_dict[dk].keys():
                continue;
        
def FormatHeading(pre, name, count, post):
    return pre + name + ' (' + str(count) + ')' + post;

def FormatKeys(item_dict):
    keys = item_dict.keys();
    keys.sort();
    return keys;

def FormatCourses(course_dict, lvl, ind):
    # build output (courses)
    out_str = '';
    course_keys = course_dict.keys();
    course_keys.sort();
    for c in course_keys:
        out_str += ind*lvl + '<div class="course">\n';
        out_str += ind*(lvl+1) + '<h5>' + course_dict[c].title + '</h5>\n';
        out_str += ind*(lvl+1) + '<ul>';

        for x in course_dict[c].class_list:
            out_str += ind*(lvl+2) + '<li>' + c + '-' + x.sec + ' (' + x.syn + ')</li>\n';

        out_str += ind*(lvl+1) + '</ul>\n';
        out_str += ind*lvl + '</div>\n';

    return out_str;
        

def WriteOutput(output_path, dl_dict, start_str, end_str, lvl, ind):
    WriteIndex(output_path, dl_dict, start_str, end_str, lvl, ind);
    WriteTopicCodes(output_path, dl_dict, start_str, end_str, lvl, ind);
    WriteDivisions(output_path, dl_dict, start_str, end_str, lvl, ind);
    WriteStylesheet(output_path);
    
def WriteIndex(output_path, dl_dict, start_str, end_str, lvl, ind):
    # verify input/output exist (make output if it does not)
    assert(os.path.isfile(input_path)), 'invalid data dir.';
    if (os.path.exists(output_path)):
        assert(os.path.isdir(output_path)), 'invalid output dir.';
    else:
        os.mkdir(output_path);
        
    # build output (index)
    out_str  = BuildStartString(start_template, title_index, stylesheet);
    out_str += ind*lvl + '<div class="index">\n';

    tc_keys = FormatKeys(dl_dict);
    for tc in tc_keys:
        tc_name = tc;
        if (tc_name == ''): tc_name = 'None';

        out_str += ind*(lvl+1) + '<div class="topic-code">\n';
        out_str += ind*(lvl+2) + FormatHeading('<h1>', Level_0_Link(tc_name, 'tcs'), Count(dl_dict[tc]), '</h1>\n');

        divs = dl_dict[tc];
        div_keys = FormatKeys(divs);
        for div in div_keys:
            out_str += ind*(lvl+2) + '<div class="division">\n';
            out_str += ind*(lvl+3) + FormatHeading('<h2>', Level_0_Link(div, 'divisions'), Count(divs[div]), '</h3>\n');

            subs = divs[div];
            sub_keys = FormatKeys(subs);
            for sub in sub_keys:
                out_str += ind*(lvl+3) + '<div class="subject">\n';
                out_str += ind*(lvl+4) + FormatHeading('<h3>', sub, Count(subs[sub]), '</h3>\n');
                out_str += ind*(lvl+3) + '</div>\n';

            out_str += ind*(lvl+2) + '</div>\n';

        out_str += ind*(lvl+1) + '</div>\n';

    out_str += ind*lvl + '</div>\n';

    f_out = open((os.path.normcase(output_path + '/index.html')).replace('\\\\', '\\'), 'w');
    print >> f_out, out_str;
    f_out.close();


def WriteTopicCodes(output_path, dl_dict, start_template, end_str, lvl, ind):
    # verify input/output exist (make output if it does not)
    assert(os.path.isfile(input_path)), 'invalid data dir.';
    assert(os.path.isdir(output_path)), 'invalid output dir.';
    tcs_path = os.path.normcase(output_path + '/tcs/');
    if (os.path.exists(tcs_path)):
        assert(os.path.isdir(tcs_path)), 'invalid output dir.';
    else:
        os.mkdir(tcs_path);

    # build output (by-topic-code)
    tc_keys = FormatKeys(dl_dict);
    for tc in tc_keys:
        tc_name = tc;
        if (tc_name == ''): tc_name = 'None';

        out_str  = BuildStartString(start_template, title_tcs + tc_name, '../' + stylesheet);
        out_str += ind*lvl + '<div class="by-tc">\n';
        out_str += ind*(lvl+1) + '<div class="nav">' + Level_1_Link('index') + '</div>\n';

        out_str += ind*(lvl+1) + '<div class="topic-code">\n';
        out_str += ind*(lvl+2) + FormatHeading('<h1>', tc_name, Count(dl_dict[tc]), '</h1>\n');

        divs = dl_dict[tc];
        div_keys = FormatKeys(divs);
        for div in div_keys:
            out_str += ind*(lvl+2) + '<div class="division">\n';
            out_str += ind*(lvl+3) + FormatHeading('<h2>', div, Count(divs[div]), '</h3>\n');

            subs = divs[div];
            sub_keys = FormatKeys(subs);
            for sub in sub_keys:
                out_str += ind*(lvl+3) + '<div class="subject">\n';
                out_str += ind*(lvl+4) + FormatHeading('<h3>', sub, Count(subs[sub]), '</h3>\n');

                out_str += FormatCourses(subs[sub].course_dict, lvl, ind);

                tops = subs[sub];
                top_keys = FormatKeys(tops);
                for top in top_keys:
                    out_str += ind*(lvl+4) + '<div class="topic">\n';
                    out_str += ind*(lvl+5) + FormatHeading('<h4>', top, Count(tops[top]), '</h4>\n');

                    out_str += FormatCourses(tops[top].course_dict, lvl, ind);

                    stops = tops[top];
                    stop_keys = FormatKeys(stops);
                    for stop in stop_keys:
                        out_str += ind*(lvl+5) + '<div class="subtopic">\n';
                        out_str += ind*(lvl+6) + FormatHeading('<h5>', stop, Count(stops[stop]), '</h5>\n');

                        out_str += FormatCourses(stops[stop].course_dict, lvl, ind);

                        out_str += ind*(lvl+5) + '</div>\n';

                    out_str += ind*(lvl+4) + '</div>\n';

                out_str += ind*(lvl+3) + '</div>\n';

            out_str += ind*(lvl+2) + '</div>\n';

        out_str += ind*(lvl+1) + '</div>\n';

        out_str += ind*lvl + '</div>\n';

        f_out = open((os.path.normcase(tcs_path + BuildUrl(tc_name) + '.html')).replace('\\\\', '\\'), 'w');
        print >> f_out, out_str;
        f_out.close();

def WriteDivisions(output_path, dl_dict, start_template, end_str, lvl, ind):
    # verify input/output exist (make output if it does not)
    assert(os.path.isfile(input_path)), 'invalid data dir.';
    assert(os.path.isdir(output_path)), 'invalid output dir.';
    div_path = os.path.normcase(output_path + '/divisions/');
    if (os.path.exists(div_path)):
        assert(os.path.isdir(div_path)), 'invalid output dir.';
    else:
        os.mkdir(div_path);

    # flip division and topic code in the data structure
    div_dict = {};
    for tc in dl_dict.keys():
        for div in dl_dict[tc].keys():
            if (not div_dict.has_key(div)):
                div_dict[div] = Item();
            if (not div_dict[div].has_key(tc)):
                div_dict[div][tc] = Item();
            div_dict[div][tc].MergeItems(dl_dict[tc][div]);

    # build output (by-topic-code)
    div_keys = FormatKeys(div_dict);
    for div in div_keys:
        out_str  = BuildStartString(start_template, title_divs + div, '../' + stylesheet);
        out_str += ind*lvl + '<div class="by-div">\n';
        out_str += ind*(lvl+1) + '<div class="nav">' + Level_1_Link('index') + '</div>\n';

        out_str += ind*(lvl+1) + '<div class="division">\n';
        out_str += ind*(lvl+2) + FormatHeading('<h1>', div, Count(div_dict[div]), '</h1>\n');

        tcs = div_dict[div];
        tc_keys = FormatKeys(tcs);
        for tc in tc_keys:
            tc_name = tc;
            if (tc_name == ''): tc_name = 'None';
            out_str += ind*(lvl+2) + '<div class="topic-code">\n';
            out_str += ind*(lvl+3) + FormatHeading('<h2>', tc_name, Count(tcs[tc]), '</h3>\n');

            subs = tcs[tc];
            sub_keys = FormatKeys(subs);
            for sub in sub_keys:
                out_str += ind*(lvl+3) + '<div class="subject">\n';
                out_str += ind*(lvl+4) + FormatHeading('<h3>', sub, Count(subs[sub]), '</h3>\n');

                out_str += FormatCourses(subs[sub].course_dict, lvl, ind);

                tops = subs[sub];
                top_keys = FormatKeys(tops);
                for top in top_keys:
                    out_str += ind*(lvl+4) + '<div class="topic">\n';
                    out_str += ind*(lvl+5) + FormatHeading('<h4>', top, Count(tops[top]), '</h4>\n');

                    out_str += FormatCourses(tops[top].course_dict, lvl, ind);

                    stops = tops[top];
                    stop_keys = FormatKeys(stops);
                    for stop in stop_keys:
                        out_str += ind*(lvl+5) + '<div class="subtopic">\n';
                        out_str += ind*(lvl+6) + FormatHeading('<h5>', stop, Count(stops[stop]), '</h5>\n');

                        out_str += FormatCourses(stops[stop].course_dict, lvl, ind);

                        out_str += ind*(lvl+5) + '</div>\n';

                    out_str += ind*(lvl+4) + '</div>\n';

                out_str += ind*(lvl+3) + '</div>\n';

            out_str += ind*(lvl+2) + '</div>\n';

        out_str += ind*(lvl+1) + '</div>\n';

        out_str += ind*lvl + '</div>\n';

        f_out = open((os.path.normcase(div_path + BuildUrl(div) + '.html')).replace('\\\\', '\\'), 'w');
        print >> f_out, out_str;
        f_out.close();

def WriteStylesheet(output_path):
    # verify input/output exist (make output if it does not)
    assert(os.path.isdir(output_path)), 'invalid output dir.';

    f_out = open((os.path.normcase(output_path + '/' + stylesheet)).replace('\\\\', '\\'), 'w');
    print >> f_out, style_str;
    f_out.close();



if __name__ == '__main__':
    # get filenames to work with
    import sys, os;
    assert len(sys.argv) == 3, 'path and file name for tidy XML.';
    input_path, output_path = sys.argv[1:];

    # build data structures
    dl_dict = BuildDLDict(input_path);

    # generic output vars
    start_template = ['<html>\n\t<head>\n\t\t<title>', '</title>\n\t</head>\n',
                      '\t\t<link rel="stylesheet" type="text/css" href="', '" />\n\t<body>\n'];
    end_str   = '\t</body>\n</html>';
    
    # build output (index)
    WriteOutput(output_path, dl_dict, start_template, end_str, 2, '\t');
