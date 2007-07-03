# k, we'll need something to store a topic
#
# CREDIT
# Topic
# tagged: '<div class="topic">'
# store anchor: '<a name="'[anchor]'"></a>'
# store title:  '<h1 class="topic">'[title]'</h1>'
# store list of courses:
#   Course
#   tagged: '<div class="course-section">'
#   store anchor: '<a name="'[anchor]'"></a>'
#   *anchor is the rubric*
#   skip next anchor...
#   store name: '<h3>'[name]'</h3>
#
# NON-CREDIT
# Doesn't have Topics (non-credit is the topic)
# Course
#   tagged: '<div class="course">'
#   store anchor: '<a name="'[anchor]'"></a>'
#   store title:  '<h3>'[title]'</h3>'


def ParseStr(start_str, stop_str, str_in, cur_loc):
        start_loc = str_in[cur_loc:].find(start_str) + len(start_str) + cur_loc;
        if (start_loc < cur_loc + len(start_str)): return None;
        stop_loc = str_in[start_loc:].find(stop_str) + start_loc;
        if (stop_loc < start_loc): return None;
        return [str_in[start_loc:stop_loc], stop_loc + len(stop_str)];

def PrepStr(str_in):
    trim_loc = str_in.find('<div id="page-content">');
    # if we can, trim the file down
    if (trim_loc > 0):
        return str_in[trim_loc:].replace('\n', '').replace('\t','').replace('  ', '').replace('> <', '><');
    # otherwise, use whole thing
    return str_in.replace('\n', '').replace('\t','').replace('  ', '').replace('> <', '><');


class Course(object):
    __limit__ = ['anchor', 'name'];
    
    def __init__(self):
        self.anchor = '';
        self.name   = '';

    def __str__(self):
        out_str = '\tClass: ' + str(self.__class__) + '\n'
        out_str = out_str + '\t\tAnchor: \'' + self.anchor + '\'\n'
        out_str = out_str + '\t\tName: \'' + self.name + '\'\n'

        return out_str;

    def Parse(self, str_in, loc_in):
        # find where we start
        cur_loc = str_in[loc_in:].find(self.marker) + loc_in;
        if (cur_loc < loc_in): return None;

        # get anchor
        temp = ParseStr('<a name="', '"></a>', str_in, cur_loc);
        if (not temp): return None;
        self.anchor = temp[0];
        cur_loc = temp[1];

        # get name
        temp = ParseStr('<h3>', '</h3>', str_in, cur_loc);
        if (not temp): return None;
        self.name = self.FmtName(temp[0]);
        cur_loc = temp[1];

        # we're done. return new cur_loc
        return cur_loc;

    def FmtName(self, str_in):
        tag_loc = str_in.find('<');
        if (tag_loc > 0):
            return str_in[:tag_loc];
        return str_in;

class NCR_Course(Course):
    marker = '<div class="course">';

    def FmtName(self, str_in):
        out_str = '';
        temp_list = Course.FmtName(self, str_in).lower().split(' ');
        for word in temp_list:
            out_str = out_str + word[:1].upper() + word[1:] + ' '
        return out_str[:len(out_str)-1];
    
class CR_Course(Course):
    marker = '<div class="course-section">';
    


class Topic(object):
    __limit__ = ['title', 'url', 'anchor', 'course_list'];
    
    def __init__(self):
        self.title  = '';
        self.anchor = '';
        self.url    = '';
        self.course_list = [];

    def __str__(self):
        out_str = 'Class: ' + str(self.__class__) + '\n'
        out_str = out_str + '\tTitle: \'' + self.title + '\'\n'
        out_str = out_str + '\tAnchor: \'' + self.anchor + '\'\n'
        out_str = out_str + '\tURL: \'' + self.url + '\'\n'
        for course in self.course_list:
            out_str = out_str + str(course);

        return out_str;

    def SetURL(self, url_in):
        if (url_in[1:2] == ':'):
            self.url = url_in[2:];
        else:
            self.url = url_in;

class NCR_Topic(Topic):
    def Set(self, anchor_in, title_in):
        self.anchor = anchor_in;
        self.title  = title_in;

    def Parse(self, str_in, loc_in):
        #get a list of classes
        cur_loc = loc_in;
        while (str_in[cur_loc:].find('<div class="course">') > 0):
            temp = NCR_Course();
            cur_loc = temp.Parse(str_in, cur_loc);
            if (not cur_loc): return None;
            self.course_list.append(temp);

        # if we got here, we're good
        return cur_loc;
        

class CR_Topic(Topic):
    marker = '<div class="topic">';

    def Parse(self, str_in, loc_in):
        # find where we start
        cur_loc = str_in[loc_in:].find(self.marker) + loc_in;
        if (cur_loc < loc_in): return None;

        # get anchor
        temp = ParseStr('<a name="', '"></a>', str_in, cur_loc);
        if (not temp): return None;
        self.anchor = temp[0];
        cur_loc = temp[1];

        # get title
        temp = ParseStr('<h1 class="topic">', '</h1>', str_in, cur_loc);
        if (not temp): return None;
        self.title = temp[0];
        cur_loc = temp[1];

        # now, we have to get a list of classes
        course_loc = str_in[cur_loc:].find('<div class="course-section">') + cur_loc
        topic_loc  = str_in[cur_loc:].find(self.marker) + cur_loc
        while ((course_loc > cur_loc) and ((course_loc < topic_loc) or (topic_loc < cur_loc))):
            temp = CR_Course();
            cur_loc = temp.Parse(str_in, cur_loc);
            if (not cur_loc): return None;
            self.course_list.append(temp);

            # set up for next itteration
            course_loc = str_in[cur_loc:].find('<div class="course-section">') + cur_loc

        # if we got here, we're good
        return cur_loc;
            
