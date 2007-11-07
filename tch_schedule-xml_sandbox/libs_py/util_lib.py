# Author:     Travis Haapala
# Section:    Brookhaven MPI
# e-mail:     thaapala@dcccd.edu
# extention:  x4104
# Created:    11 June    2007
# Modified:   08 October 2007

# Utility Library: This library is included in many projects.
# PLEASE NOTE: the versions are *NOT* interchangeable. This library grows
#   with each project and some implementations may change. Updating this
#   lib could break your script if it is based on an older version. In
#   addition, some util_libs are specialized for the project into which
#   they are imported and could have /very bad/ effects on other scripts.
# So, DON'T update this lib unless you are going to edit the code in place.

# Contains some useful formatting, I/O, and validation functions. Only relies
#   on the os lib.
#
# Classes:
# ------------------
# PrintString(object)
#   write(self, string): stores the string
#   __str__(self): returns the string.
# Useful for using print statements to write strings rather than files
#
# Functions:
# ------------------
# GetInput(prompt, default), returns user string (or default if no user input)
#
# GetFilename(), returns a user string representing a valid (and existing)
#                   filename. Loops until a valid path is entered or user enters
#                   '.cancel', whereupon None is returned
#
# CleanPath(path), ***removed***
#                  use: os.path.normcase(path) to normalize path
#
# CleanURL(url), returns a URL in the standard format:
#                   'http:\www.orange.com/oregano//' yields
#                      'http://www.orange.com/oregano/'
#
# StripPathDirs(path), ***removed***
#                  use: os.path.basename(path) to retrieve filename
#
# StripPathFile(path), ***removed***
#                  use: os.path.dirname(path) to retrieve directory name(s)
#
# StripRel(root_path, full_path), returns the difference between two paths.
#                   If the root_path is not contained within the full_path,
#                   the full_path is returned.
#                   'c:\data\svn\' and 'c:\data\svn\oregano' would yield
#                      'oregano\'
#                   'c:\data\svn\' and 'data\svn\oregano' would yield
#                      full_path, ie: 'data\svn\oregano' since it cannot
#                      be assured that full_path is within root_path
#                      (ie: it may be in 'c:\_bak\data\svn\oregano')
#
# SafeSave(path), returns true if the path does not leave the current
#                   directory (useful to make sure output files do not
#                   overwrite anything outside of the script's directory
#
# Validate(id, data), returns True if the data is valid for id-type data
#                   id-types are:
#                    - none:  always returns true
#                    - dir:   returns true if the path in data exists and
#                               is a directory
#                    - file:  returns true if the path in data exists and
#                               is a file
#                    - path:  returns true if the path in data exists
#                    - yesno: returns true if data can be resolved to
#                               true or false ('yes'|'no','y'|'n','0'|'1',
#                               't'|'f','true'|'false')
# Validate[type](data): each id-type has a seperate Validate function; ie:
# ValidateDir(data), like Validate(id=id_validate_dir, data)
#
# Resolve(id, data), returns a cleaned-up version of data for id-type.
#                   id-types are the same as Validate id-types.
#                   If the data does not pass a Validate(id,data) test,
#                   the function returns None.
#                    - none:  returns data unchanged
#                    - dir:   returns os.path.normcase(data)
#                    - file:  returns os.path.normcase(data)
#                    - path:  returns os.path.normcase(data)
#                    - yesno: returns true if data can be resolved to
#                               true and returns false if teh data can
#                               be resolved to false.
# Resolve[type](data): each id-type has a seperate Resolve function; ie:
# ResolveDir(data), like Resolve(id=id_validate_dir, data)
#
# FormatWebsafe(data): returns the string or list of strings formatted for the web.
#


# required libs
import os


# def PrintString()
# stores a string via .write() and returns via .__str__()
class PrintString(object):
    __limit__ = ['string'];

    def __init__(self):
        self.string = '';
    def write(self, string):
        self.string = self.string + string;
    def __str__(self):
        return str(self.string);
        

# def GetInput()
# get input from user
# input:  prompt   - prompt string
#         default  - default if user enters nothing
# output: data_str - string entered by user
def GetInput(prompt, default):
    
    try:
        # make sure the msg is a string
        assert (type(prompt) == str), 'util_lib.GetInput(): prompt must be a string.\n';

        # get user input
        data_str = raw_input(prompt);
        if (data_str == ''):
            data_str = default;

        # return valid data list
        return data_str;
            
    except EOFError:
        sys.exit(1);


# def GetFilename()
# calls a few  util_lib functions to get a valid filename
# input:  (none)
# output: data_str - the name of a file that exists
def GetFilename():
    valid = False;
    while (not valid):
        data_str = GetInput('Enter filename: ', '');
        if (data_str == '.cancel'):
            return None;
        valid = ValidateFile(data_str)
        if (not valid):
            print 'File not found: ' + data_str + '\nPlease try again.\n'

    return data_str;


# def GetExt()
# input:  filename - the path to the file + filename
# output: ext      - the extiontion of the file
def GetExt(filename):
    assert (type(filename) == str), 'util_lib.GetExt(): filename must be a string.\n';
    # processing vars
    name_len = len(filename);
    name_list = list(filename);

    # step backwards until we find a '.'
    i = name_len - 1;
    while (i >= 0):
        if (name_list[i] == '.'):
            break;
        if (name_list[i] == '/') or (name_list[i] == '\\'):
            i = -1;
            break;
        i = i - 1;

    # if we didn't find a '.', we're done
    if (i < 0):
        return '';

    # otherwise, return what we've got
    return filename[i:];


# def CleanURL()
# formats a URL in a consistant way to assist display and pattern checking
# input:  url_in  - the url to be cleaned
# output: url_out - the cleaned url
def CleanURL(url_in):
    assert(type(url_in) == str), "util_lib.CleanURL(): url_in must be a string.";

    # if there's a '.', I'm going to assume it ends in a filename with an extension
    out_str = url_in;
    if (url_in.find('.') < 0): out_str = url_in + '/';
    out_str = out_str.strip().lower().replace('\\','/').replace('//', '/');
    out_str = out_str.replace('http:/', 'http://').replace('https:/','https://');
    return out_str



# def StripRel()
# strips off relative part of path
# input:  path_root  - the root path
#         path_full  - the full path
# output: path_final - the part of full path not contained within root path
def StripRel(path_root, path_full):
    # quick assert
    assert (type(path_root) == str), 'util_lib.StripRel(): path_root must a string.';
    assert (type(path_full) == str), 'util_lib.StripRel(): path_full must a string.';

    # short circuit if root is empty
    if (path_root == ''):
        return os.path.normcase(path_full);

    # prevent false negatives (clean up):
    path_root = os.path.normcase(path_root);
    path_full = os.path.normcase(path_full);

    # compare 'em
    if (path_root in path_full):
        return path_full[(path_full.find(path_root) + len(path_root)):];

    else:
        return path_full;


# def SafeSave()
# ensures the file is not outside of current directory
def SafeSave(path):
    # quick assert
    assert (type(path) == str), 'util_lib.SafeFile(): path must be a string.';

    # clean it
    path = os.path.normcase(path)

    # if it's '{something}:', then it's not in the cwd
    if (path.find(':') > 0):
        return False;

    # if it starts with '..\', '\', or '~\', then it's not safe
    if ((path[:1] == '\\') or (path[:3] == '..\\') or (path[:2] == '~\\')):
        return False;
    
    # otherwise, it's probably safe
    return True;

    
# ids for Validate()
id_validate_min   = -1;
id_validate_none  =  0;
id_validate_dir   =  1;
id_validate_file  =  2;
id_validate_path  =  3;
id_validate_yesno =  4;
id_validate_max   =  5;

# def Validate()
# validate data as type id_validate_<type>:
#    id_validate_none  : always returns true
#    id_validate_dir   : returns true iff exists and isdir
#    id_validate_file  : returns true iff exists and isfile
#    id_validate_path  : returns true iff exists
#    id_validate_yesno : returns true if data_in can be resolved to True|False
# input:  id_in   - type of validation to perform
#         data_in - raw data
# output: valid   - True if valid, else False
def Validate(id_in, data_in):
    assert(type(id_in) == int), "MultiScan.util_lib.Validate(): id_in must be an integer.";
    assert((id_in > id_validate_min) and (id_in < id_validate_max)), "MultiScan.util_lib.Validate(): id_in out of range.";

    # none
    if (id_in == id_validate_none): return True;
    # dir
    if (id_in == id_validate_dir): return ValidateDir(data_in);
    # file
    if (id_in == id_validate_file): return ValidateFile(data_in);
    # path
    if (id_in == id_validate_path): return ValidatePath(data_in);
    # yes|no, true|false, 1|0
    if (id_in == id_validate_yesno): return ValidateYesNo(data_in);

# individual validation functions. See Validate() for additional info
def ValidateDir(data_in):
    assert (type(data_in) == str);
    return ((os.path.exists(data_in)) and (os.path.isdir(data_in)));
def ValidateFile(data_in):
    assert (type(data_in) == str);
    return ((os.path.exists(data_in)) and (os.path.isfile(data_in)));
def ValidatePath(data_in):
    assert (type(data_in) == str);
    return os.path.exists(data_in);
def ValidateYesNo(data_in):
    assert (type(data_in) == str);
    if (Resolve(id_in, data_in) == None):
        return False;
    else:
        return True;


# def Resolve()
# resolve data as type id_validate_<type>:
#    id_validate_none  : returns data_in unmodified
#    id_validate_dir   : returns data_in in display-format
#    id_validate_file  : returns data_in in display-format
#    id_validate_path  : returns data_in in display-format
#    id_validate_yesno : returns true if data_in can be resolved to True, else False
# input:  id_in    - type of validation to perform
#         data_in  - raw data
# output: data_out - the prettied-up data
def Resolve(id_in, data_in):
    assert(type(id_in) == int), "Validate: id_in must be an integer.";
    assert((id_in > id_validate_min) and (id_in < id_validate_max)), "Validate: id_in out of range.";

    # none
    if (id_in == id_validate_none): return data_in;
    # dir, file, path
    if (id_in == id_validate_dir): return ResolveDir(data_in);
    # file
    if (id_in == id_validate_file): return ResolveFile(data_in);
    # path
    if (id_in == id_validate_path): return ResolvePath(data_in);
    # yes|no, true|false, 1|0
    if (id_in == id_validate_yesno): return ResolveYesNo(data_in);
        
# individual resolving functions. See Resolve() for additional info
def ResolveDir(data_in):
    if ((type(data_in) == str) and (ValidateDir(data_in))):
        return os.path.normcase(data_in);
    else:
        return None;
def ResolveFile(data_in):
    if ((type(data_in) == str) and (ValidateFile(data_in))):
        return os.path.normcase(data_in);
    else:
        return None;
def ResolvePath(data_in):
    if ((type(data_in) == str) and (ValidatePath(data_in))):
        return os.path.normcase(data_in);
    else:
        return None;
def ResolveYesNo(data_in):
        if (type(data_in) == str):
            yn_map = { 'yes'  : True,
                       'y'    : True,
                       'true' : True,
                       't'    : True,
                       '1'    : True,
                       'n'    : False,
                       'no'   : False,
                       'false': False,
                       'f'    : False };
            data_in = data_in.strip().lower();
            if (data_in in yn_map.keys()):
                return yn_map.get(data_in)
        elif (type(data_in) == int):
            if (data_in == 0):
                return False;
            elif (data_in == 1):
                return True;
        else:
            return None;

# def FormatWebsafe()
# formats the input string or list of strings for web display
# input:  data_in  - data to be processed. Must be a string or list of strings.
# output: data_out - processed data. If a string was passed, a string is returned,
#                    likewise for a list of strings.
#                    If data_in is not the correct type, returns None;
def FormatWebsafe(data_in):
    # a list of things we don't want in our web page text
    unsafe_map = {
        '<' : '&lt;',
        '>' : '&gt;',
        '"' : '&quot;',
        '&' : '&amp;' };
    # add more as necessary

    # store the input type (output will match)
    out_type = type(data_in);

    # if it's not a list and not a string, fail
    # if it's a single string, stuff it in a list for processing
    # if it's a list already, we're fine
    if (out_type != list):
        if (out_type != str): return None;
        in_list  = [data_in];
    else:
        in_list  = data_in;

    # for each string in the list
    out_list = [];
    for s in in_list:
        # if it's not really a string, fail
        if (type(s) != str): return None;

        # for each unsafe char in the map, replace it.
        for key in unsafe_map.keys():
            s = s.replace(key, unsafe_map.get(key));
        # add it to the output list
        out_list.append(s);

    # if we got a string, return a string
    if (out_type == str):
        return out_list[0];
    # otherwise, return the list
    return out_list;
