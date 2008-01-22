# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   07 August 2007
# Modified:  19 December 2007

# Synopsis:
# Converts a text file to mappings xml style. Not very well yet, this grows with each use.


# includes
import ap_data_lib as data_lib;
import ap_util_lib as util_lib;
import ap_menu_lib as menu_lib;
import os, glob, sys, re;

# globals
indent     = '    ';
data_list  = [];
data_dir   = 'data\\';
output_dir = 'output\\';

def get_file_list():
    return glob.glob(data_dir + '*');
    
def read_file(filename):
    fin = open(filename, 'r');

    cnt = 0;
    for line in fin:
        cnt += 1;
        
        # skip empty lines
        if (line.strip() != ''):

            try:

                # get level and type
                level = get_level(line.rstrip());
                line  = line.strip();
                ltype = get_type(line);

                # first level
                if (level == 1):
                    if (ltype == 'name'): add_subject(line);
                    else: print_error(line, cnt);

                # second level
                elif (level == 2):
                    if (ltype == 'name'): add_topic(line);
                    elif (ltype == 'comment'): add_comment(line, get_subject());
                    elif (ltype == 'pattern'): add_pattern(line, get_subject());
                    else: print_error(line, cnt);

                # third level
                elif (level == 3):
                    if (ltype == 'name'): add_subtopic(line);
                    elif (ltype == 'comment'): add_comment(line, get_topic());
                    elif (ltype == 'pattern'): add_pattern(line, get_topic());
                    else: print_error(line, cnt);

                # fourth level
                elif (level == 4):
                    if (ltype == 'comment'): add_comment(line, get_subtopic());
                    elif (ltype == 'pattern'): add_pattern(line, get_subtopic());
                    else: print_error(line, cnt);

                # default
                else:
                    print_error(line, cnt);

            except:
                print 'Fatal exception on line', cnt;

    fin.close();

def get_level(line):
    level = 0;
    while (line[level:].find('\t') >= 0): level += 1;
    return level+1;
    
def get_type(line):
    if (line.find('<comments>') >= 0): return 'comment';
    elif (is_pattern(line)): return 'pattern';
    else: return 'name';

def print_error(line, cnt):
    print 'Error on line ', cnt, '\n  Can\'t decide what to do with \n\'', line, '\'\n';
    
no_caps = ['of', 'the', 'and', 'or', 'for', 'to'];
def fix_caps(name):
    words = ((name.replace('/', ' / ')).lower()).split(' ');
    out_str = '';
    for word in words:
        if (word in no_caps):
            out_str = out_str + word.lower() + ' ';
        else:
            out_str = out_str + word[:1].upper() + word[1:].lower() + ' ';
    return out_str.strip();

def is_pattern(line):
    assert(type(line) == str);

    pattern = re.compile('[a-zA-Z]{4} [0-9]{4}.*');
    if (pattern.match(line)):
        return True;
    else:
        return False;

def get_subject():
    return data_list[len(data_list)-1];

def get_topic(): return get_topic_of(get_subject());
def get_topic_of(subject):
    return subject.child_list[len(subject.child_list)-1];

def get_subtopic(): return get_subtopic_of(get_topic());
def get_subtopic_of(topic):
    return topic.child_list[len(topic.child_list)-1];


def add_subject(name):
    data_list.append(data_lib.Subject(fix_caps(name)));

def add_topic(name):
    (get_subject()).child_list.append(data_lib.Topic(fix_caps(name)));

def add_subtopic(name):
    (get_topic()).child_list.append(data_lib.Subtopic(fix_caps(name)));


def add_comment(comment, obj):
    obj.comment = comment;

def add_pattern(match, obj):
    obj.pattern_list.append(data_lib.Pattern(match));


def write_file(filename):
    assert (type(filename) == str);
    assert (type(data_list) == list);
    assert (util_lib.SafeSave(filename));

    if (len(data_list) > 0):
        fout = open(filename, 'w+');
        print >> fout, format_output(2)
        fout.close();
    else:
        print "Nothing to write.";

def format_output(lvl):
    out_str = '';
    for subject in data_list:
        out_str = out_str + format_subject(subject, lvl);
    return out_str;
    
def format_subject(subject, lvl):
    assert (data_lib.GetType(subject) == data_lib.type_Subject);

    out_str = indent*lvl + '<subject name="' + subject.name + '">\n';
    if (len(subject.comment) > 0):
        out_str = out_str + indent*(lvl+1) + subject.comment + '\n';
    if (len(subject.pattern_list) > 0):
        for pattern in subject.pattern_list:
            out_str = out_str + format_pattern(pattern, lvl+1);
    if (len(subject.child_list) > 0):
        for topic in subject.child_list:
            out_str = out_str + format_topic(topic, lvl+1);
    return (out_str + indent*lvl + '</subject>\n');

def format_topic(topic, lvl):
    assert (data_lib.GetType(topic) == data_lib.type_Topic);
    
    out_str = indent*lvl + '<topic name="' + topic.name + '">\n';
    if (len(topic.comment) > 0):
        out_str = out_str + indent*(lvl+1)+ topic.comment + '\n';
    if (len(topic.pattern_list) > 0):
        for pattern in topic.pattern_list:
            out_str = out_str + format_pattern(pattern, lvl+1);
    if (len(topic.child_list) > 0):
        for subtopic in topic.child_list:
            out_str = out_str + format_subtopic(subtopic, lvl+1);
    return (out_str + indent*lvl + '</topic>\n');

def format_subtopic(subtopic, lvl):
    assert (data_lib.GetType(subtopic) == data_lib.type_Subtopic);

    out_str = indent*lvl + '<subtopic name="' + subtopic.name + '">\n';
    if (len(subtopic.comment) > 0):
        out_str = out_str + indent*(lvl+1) + subtopic.comment + '\n';
    if (len(subtopic.pattern_list) > 0):
        for pattern in subtopic.pattern_list:
            out_str = out_str + format_pattern(pattern, lvl+1);
    if (len(subtopic.child_list) > 0):
        print "Error: not sure what to do with children of subtopic elements";
    return (out_str + indent*lvl + '</subtopic>\n');

def format_pattern(pattern, lvl):
    assert (data_lib.GetType(pattern) == data_lib.type_Pattern);

    return (indent*lvl + '<pattern match="' + pattern.match + '" />\n');


# main
if (__name__ == '__main__'):
    # figure out which file to use as input
    print "Reading file list...";
    file_list = get_file_list();

    file_list.append('cancel');
    menu = menu_lib.ExtMenu('File selection', file_list);
    selection = menu.DisplayMenu();

    # if user canceled
    if (selection == len(file_list)):
        print 'cancelled.';
        sys.exit(0);
    else:
        assert(type(selection) == int);
        filename = file_list[selection - 1];
        # load and use file
        print 'Loading ', filename, '...';
        read_file(filename);
        print 'Writing output...';
        write_file(os.path.splitext(output_dir + os.path.split(filename)[1])[0] + '_output.txt')
        print 'Complete.'

    sys.exit(0);
