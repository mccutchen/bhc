# Author: Travis Haapala
# Section: Brookhaven MPI
# e-mail: thaapala@dcccd.edu
# extention: x4104
# Creation Date: 26 June 07
# Last Modified: 15 August 08

# Beta Version: stable and works with currently-available data
#               please send me an email if you find any bugs

# Usage:
# Run sa_updater.bat and enter the semester & year when prompted. You may use a two or
#   four digit format for the year, and you may abbreviate the semester to the first two
#   letters (summer is su, rather than s1 or s2. summer scans *ALL* summer. Pick and
#   choose what output to paste if you require more granularity).
# If the web or source layout changes, you may need to update the sa_updater.ini file
#   This can be accomplished in any text editor (notepad works great). Variable names
#   are fairly self explainatory. CR stands for 'credit' and NC stands for 'non-credit'.
# You may include as many semester/year sources as you like.
# Once you have your output, check over the Non-Credit course section. Non-credit course
#   listings are in ALL CAPS, and I can only do so much to fix that. I've lowercased the
#   string and uppercased the first letter of each word. It's a start. If you feel like
#   it's still too much work, feel free to add in some code to catch common words like
#   'in', 'on', 'with', 'by', 'XP', etc.
# You may see duplicates in the output - they're not really duplicates. If you look at the
#   hyperlinks, you'll see they point to different courses, which (despite having the
#   same name) may not be located anywhere near each other on the senior_adult section
#   of the course-schedules page.
# Final step: copy-paste the list from the output file into the senir-adult page. You're
#   done. Split the columns how you choose.

# Change Log:
# v 1.1
# - Added new ini attribute, 'recursive'
#   This attribute controls whether the SA Updater checks directories recursively
#   If true, will include entries for sub-folders (like special sections / flex terms)



import os, sys, glob
import sa_util_lib as util_lib
import sa_data_lib as data_lib

# globals
version_str    = '[sa_updater version=1.1]';
ini_path       = 'sa_updater.ini';
ini            = None;
fname_pattern  = 'senior_adult'
k_max_filesize = pow(2, 20);


# additional class
class iniData(object):
    __limit__ = ['cr_path', 'nc_path', 'cr_url', 'nc_url', 'recurse', 'out_path', 'ind_str', 'lvl_int'];

    def __init__(self):
        self.cr_path  = '';
        self.nc_path  = '';
        self.cr_url   = '';
        self.nc_url   = '';
        self.out_path = '';
        self.ind_str  = '';
        self.lvl_int  = 0;

    def IsLabel(self, label):
        return (label in self.__limit__);

    def Set(self, label, value):
        if (not self.IsLabel(label)): return False;
        if (type(value) != str): return False;

        if   (label == 'cr_path' ): self.cr_path  = util_lib.ResolveDir(value);
        elif (label == 'nc_path' ): self.nc_path  = util_lib.ResolveDir(value);
        elif (label == 'cr_url'  ): self.cr_url   = util_lib.CleanURL(value);
        elif (label == 'nc_url'  ): self.nc_url   = util_lib.CleanURL(value);
        elif (label == 'recurse' ): self.recurse  = (value.strip() == "true");
        elif (label == 'out_path'): self.out_path = util_lib.CleanPath(value);
        elif (label == 'ind_str' ):
            if (value == '\'\\t\''): self.ind_str = '\t';
            else: self.ind_str  = value[1:len(value)-1];
        elif (label == 'lvl_int' ):
            if (not value.isdigit()): return False;
            self.lvl_int  = int(value);

        return True;

    def Get(self, label):
        if   (label == 'cr_path' ): return self.cr_path;
        elif (label == 'nc_path' ): return self.nc_path;
        elif (label == 'cr_url'  ): return self.cr_url;
        elif (label == 'nc_url'  ): return self.nc_url;
        elif (label == 'out_path'): return self.out_path;
        elif (label == 'recurse' ): return self.recurse;
        elif (label == 'ind_str' ): return self.ind_str;
        elif (label == 'lvl_int' ): return self.lvl_int;
        else: return None;

    def IsValid(self):
        # all fields entered:
        if ((type(self.cr_path)  != str) or (self.cr_path  == '')): return False;
        if ((type(self.nc_path)  != str) or (self.nc_path  == '')): return False;
        if ((type(self.cr_url)   != str) or (self.cr_url   == '')): return False;
        if ((type(self.nc_url)   != str) or (self.nc_url   == '')): return False;
        if ((type(self.recurse)  != bool)                        ): return False;
        if ((type(self.out_path) != str) or (self.out_path == '')): return False;
        if ((type(self.ind_str)  != str) or (self.ind_str  == '')): return False;
        if ((type(self.lvl_int)  != int) or (self.lvl_int  <  0 )): return False;

        # additional checks by-data
        if (not util_lib.ValidateDir(self.cr_path)): return False;
        if (not util_lib.ValidateDir(self.nc_path)): return False;
        if (not util_lib.SafeSave(self.out_path)): return False;
        if (self.lvl_int < 0): return False;
        return True;
    

def LoadINI():
    global ini;
    ini = iniData();
    
    # make sure there is one
    if (not util_lib.ValidateFile(ini_path)): return False;

    fin = open(ini_path);
    try:
        valid = True;

        # check version
        if (valid):
            line = fin.readline().lower().strip();
            if (line != version_str): valid = False;

        # load strings
        line = fin.readline().lower().strip();
        while (line):
            label, value = line.split(' = ');
            label = label[1:].strip();
            value = value[:len(value)-1].strip();
            if (not ini.IsLabel(label)): break;
            if (len(value) < 1): break;
            if (not ini.Set(label, value)): break;
            line = fin.readline().lower().strip();
    finally:
        fin.close();

    # we're done
    return ini.IsValid();
            
        
def GetSemesterList():
    # processing vars
    valid = False;
    valid_list = ['summer', 'fall', 'spring'];
    abbr_map   = {
        'su' : 'summer',
        'fa' : 'fall',
        'sp' : 'spring' }
    out_list = [];
    
    
    # while the user enters poor data
    while (not valid):
        # prompt user for semester
        str_in = util_lib.GetInput('Enter semester to use as input (ie Summer2007):\n(other options: done, exit): ', '');

        # check for cancel and exit
        if (str_in.lower().strip() == 'done'):
            if (len(out_list) > 0):
                return out_list;
            else:
                str_in = 'exit';
        if (str_in.lower().strip() == 'exit'):
            sys.exit(0);

        # error check
        s0 = '';
        s1 = '';
        if (len(str_in) >= 4):
            s1 = str_in[len(str_in)-4:];
            if (not s1.isdigit()):
                s1 = str_in[len(str_in)-2:];
                if (s1.isdigit()):
                    s1 = '20' + s1;
                    s0 = str_in[:len(str_in)-2].lower();
            else:
                s0 = str_in[:len(str_in)-4].lower();

        # if it's invalid, kick 'em back to the begining
        if (s0 in abbr_map.keys()): s0 = abbr_map.get(s0);
        if ((not s0 in valid_list) or (not s1.isdigit())):
            print 'Invalid semester. Please try again.';
            continue;

        # verify with user
        pretty_str = s0[:1].upper() + s0[1:] + ' of ' + s1
        yn = None;
        while (yn == None):
            str_in = util_lib.GetInput('Is this correct? : ' + pretty_str + '\n(default: yes): ', 'y');
            yn = util_lib.ResolveYesNo(str_in);

        # if user said no, just break out and start over
        if (not yn):
            print 'Semester discarded.';
            continue;

        # if the user said yes, but the directory doesn't exist, break out and start over.
        path = ini.cr_path + s1 + '/' + s0 + '/'
        if (not util_lib.ValidateDir(path)):
            print 'Semester data not found.'
            continue;

        # if the user repeated a semester
        if (path in out_list):
            print 'Semester already selected.'
            continue;

        # othwerwise, store it
        print 'Semester accepted: ' + pretty_str;
        out_list.append(path);

        # see if user wants to add another
        yn = None;
        while (yn == None):
            str_in = util_lib.GetInput('Add another semester?\n(default: no): ', 'no');
            yn = util_lib.ResolveYesNo(str_in);

        # set whether to loop again
        valid = not yn;

    # if we've exited the loop, return semester_list
    return out_list;
        
    
def QikMerge(url_in, path_in):
    assert ((type(url_in) == str) and (type(path_in) == str));
    
    # split into a list of directories
    url_list = url_in.replace('http://','').replace('https://','').split('/');
    path_list = path_in.split('\\');
    if (path_list[0][1:2] == ':'): path_list = path_list[1:];

    # find the first dir in the url that corresponds to a dir in the path
    i = 0;
    j = 0;
    while (i < len(url_list)):
        j = 0;
        while (j < len(path_list)):
            if (url_list[i] == path_list[j]): break;
            j = j + 1;
        if ((j < len(path_list)) and (url_list[i] == path_list[j])): break;
        i = i + 1;

    # if no match found, give up
    if (url_list[i] != path_list[j]): return None;

    # otherwise, try to peice them together
    # first, see how many dirs they have in common
    k = 1;
    while ((i + k < len(url_list)) and (j + k < len(path_list))):
        if (url_list[i+k] != path_list[j+k]): break;
        k = k + 1;

    # now paste 'em together
    out_list = [];
    n = 0;
    while (n < i + k):
        out_list.append(url_list[n] + '/');
        n = n + 1;
    n = j + k;
    while (n < len(path_list) - 1):
        out_list.append(path_list[n] + '/');
        n = n + 1;
    out_list.append(path_list[n]);

    return ''.join(out_list);

def ScanForFilename(fname, root_dir):
    out_list = [];
    global ini;

    # get a list of paths to search
    path_list = glob.glob(util_lib.CleanPath(root_dir) + '*');

    # loop through each path
    for path in path_list:
        # if this is a directory
        if (os.path.isdir(path)):
            # if recursion is enabled
            if (ini.Get("recurse")):
                out_list = out_list + ScanForFilename(fname, path);
        # otherwise it's a file
        else:
            if ((fname in path) and (not '_bak' in path)):
                out_list.append(path);

    # return what we've got
    return out_list;

def ScanCredit(path_list):
    # processing vars:
    topic_list   = [];
    file_list = [];

    for path in path_list:
        file_list = file_list + ScanForFilename(fname_pattern, path);

    # if we didn't get any, we can't do anything
    if ((not file_list) or (len(file_list) < 1)):
        print '! Warning: No credit filenames detected that match the pattern \'' + fname_str + '\'.'
        return None;

    # Otherwise, load each file
    for f in file_list:
        fin = open(f);
        try:
            str_in = data_lib.PrepStr(fin.read(k_max_filesize));
        finally:
            fin.close();

        # status message so the user doesn't think we're frozen
        print 'Scanning ' + f;
        
        # now suck out the classes
        cur_loc = 0;
        while(cur_loc != None):
            # create object and parse
            temp = data_lib.CR_Topic();
            temp.SetURL(QikMerge(ini.cr_url, f));
            cur_loc = temp.Parse(str_in, cur_loc);
            
            # if results, store
            if (cur_loc):
                topic_list.append(temp);
            
    return topic_list;

def ScanNonCredit(path):
    # processing vars:
    topic_list   = [];
    file_list = [];

    file_list = ScanForFilename(fname_pattern, path);

    # if we didn't get any, we can't do anything
    if ((not file_list) or (len(file_list) < 1)):
        print '! Warning: No non-credit filenames detected that match the pattern \'' + fname_str + '\'.'
        return None;

    # Otherwise, load each file
    for f in file_list:
        fin = open(f);
        try:
            str_in = data_lib.PrepStr(fin.read(k_max_filesize));
        finally:
            fin.close();

        # status message so the user doesn't think we're frozen
        print 'Scanning ' + f;
        
        # now suck out the classes
        cur_loc = 0;
        # create object and parse
        temp = data_lib.NCR_Topic();
        temp.SetURL(QikMerge(ini.nc_url, f));
        cur_loc = temp.Parse(str_in, cur_loc);
            
        # set the topic fields
        temp.Set('','Non-Credit');
        
        # if results, store
        if (cur_loc):
            topic_list.append(temp);
        
    return topic_list;

# output
def WriteOutput(topic_list):
    # make sure it's safe to save here (I know this is already checked. I'm paranoid.)
    if (util_lib.SafeSave(ini.out_path)):
        fname = ini.out_path;
    else:
        fname = 'output.txt';
        print '! Warning: designated output file is not safe. Truncating to \'output.txt\'.';

    # build output string
    ind = ini.ind_str;
    lvl = ini.lvl_int;
    out_str = ind*lvl + '<ul>\n'
    for topic in topic_list:
        anchor_str = '<a href="' + topic.url + '#' + topic.anchor + '">';
        out_str = out_str + ind*(lvl+1) + '<li>' + anchor_str + topic.title + '</a>\n'
        out_str = out_str + ind*(lvl+2) + '<ul>\n'
        for course in topic.course_list:
            anchor_str = '<a href="' + topic.url + '#' + course.anchor + '">';
            out_str = out_str + ind*(lvl+3) + '<li>' + anchor_str + course.name + '</a></li>\n';
        out_str = out_str + ind*(lvl+2) + '</ul>\n';
        out_str = out_str + ind*(lvl+1) + '</li>\n';
    out_str = out_str + ind*lvl + '</ul>\n'
    
    # save
    fout = open(fname, 'w')
    try:
        print >> fout, out_str;
    finally:
        fout.close();
            

# main
if (__name__ == '__main__'):
    # our data:
    topic_list   = [];

    # load ini
    if (not LoadINI()):
        print '! Error: ' + ini_path + ' failed to load successfully.'
        sys.exit(0);

    # get semesters
    cr_path_list = GetSemesterList();

    # CREDIT:
    print 'Scanning credit topics...';
    cr_list = ScanCredit(cr_path_list);
    if (not cr_list):
        print '! Warning: no credit topics found.';

    # NON-CREDIT:
    print 'Scanning non-credit topics...';
    nc_list = ScanNonCredit(ini.nc_path);
    if (not nc_list):
        print '! Warning: no credit topics found.';

    # combine
    topic_list = cr_list + nc_list;

    # sort
    topic_list.sort(lambda x, y: cmp(x.title, y.title));
    for topic in topic_list:
        topic.course_list.sort(lambda x, y: cmp(x.name, y.name));

    # write to file
    WriteOutput(topic_list);

    # and exit
    sys.exit(0);
