# Author: Travis Haapala
# Created: 11 June 2007
# Last Modified: 11 June 2007
# Based on Link_Scanner.util_lib.py (direction of project shifted)
# Link_Scanner author: Travis Haapala

# required libs
import os


# def GetInput()
# get input from user and validate
# input:  prompt_list  - list of message strings
#         default_list - defaults to use if user enters nothing
# output: data_str     - string entered by user
def GetInput(prompt, default):
    
    try:
        # make sure the msg is a string
        assert (type(prompt) == str), 'MultiScan.util_lib.GetInput(): prompt must be a string.\n';

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
        valid = Validate(id_validate_file, data_str)
        if (not valid):
            print 'File not found: ' + data_str + '\nPlease try again.\n'

    return data_str;


# def GetExt()
# input:  filename - the path to the file + filename
# output: ext      - the extiontion of the file
def GetExt(filename):
    assert (type(filename) == str), 'MultiScan.util_lib.GetExt(): filename must be a string.\n';
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


# def CleanPath()
# formats a path in a consistant way to assist display and pattern checking
# input:  path_in  - the path to be cleaned
# output: path_out - the cleaned path
def CleanPath(path_in):
    assert(type(path_in) == str), "MultiScan.util_lib.CleanPath(): path_in must be a string.";

    if (os.path.isdir(path_in)):
        return (path_in + '\\').strip().lower().replace('/','\\').replace('\\\\', '\\');
    else:
        return path_in.strip().lower().replace('/','\\').replace('\\\\', '\\');


# def StripPathDirs()
# input:  path - the path to the file or directory
# output: returns the filename if the path points to a file, else None
def StripPathDirs(path):
    assert (type(path) == str), 'MultiScan.util_lib.StripFilename(): path must be a string.\n';

    # quick check
    if (os.path.isdir(path)):
        return '';
    
    # clean up the path
    temp_str = CleanPath(path);

    # strip off drives
    pos = temp_str.find(':');
    while (pos > 0):
        temp_str = temp_str[pos+1:];
        pos = temp_str.find(':');
        
    # start stripping off directories
    pos = temp_str.find('\\');
    while (pos > 0):
        temp_str = temp_str[pos+1:];
        pos = temp_str.find('\\');

    # return what we've got
    return temp_str;


# def StripPathFile()
# input:  path - the path to the file or directory
# output: returns the filename if the path points to a file, else ''
def StripPathFile(path):
    assert (type(path) == str), 'MultiScan.util_lib.StripFilename(): path must be a string.\n';

    # clean up the path
    temp_str = CleanPath(path);

    # quick check
    if (os.path.isdir(path)):
        return path;

    # get filename
    fn = StripPathDirs(path);

    # return what we've got
    if (len(path) - len(fn) < 0):
        return '';
    else:
        return path[:len(path) - len(fn)];

           
# def StripRel()
# strips off relative part of path
# input:  path_root  - the root path
#         path_full  - the full path
# output: path_final - the part of full path not contained within root path
def StripRel(path_root, path_full):
    # quick assert
    assert (type(path_root) == str), 'MultiScan.util_lib.CleanPath(): path_root must a string.';
    assert (type(path_full) == str), 'MultiScan.util_lib.CleanPath(): path_full must a string.';

    # short circuit if root is empty
    if (path_root == ''):
        return path_full.lower().replace('/','\\').replace('\\\\', '\\');

    # prevent false negatives (clean up):
    path_root = CleanPath(path_root);
    path_full = CleanPath(path_full);

    # compare 'em
    if (path_root in path_full):
        return path_full[(path_full.find(path_root) + len(path_root)):];

    else:
        return path_full;


# def SafeSave()
# ensures the file is not outside of current directory
def SafeSave(path):
    # quick assert
    assert (type(path) == str), 'MultiScan.util_lib.SafeFile(): path must be a string.';

    # clean it
    path = CleanPath(path)

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
    if (id_in == id_validate_none):
        return True;

    # dir
    if (id_in == id_validate_dir):
        assert (type(data_in) == str);
        return ((os.path.exists(data_in)) and (os.path.isdir(data_in)));

    # file
    if (id_in == id_validate_file):
        assert (type(data_in) == str);
        return ((os.path.exists(data_in)) and (os.path.isfile(data_in)));

    # path
    if (id_in == id_validate_path):
        assert (type(data_in) == str);
        return os.path.exists(data_in);

    # yes|no, true|false, 1|0
    if (id_in == id_validate_yesno):
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
    if (id_in == id_validate_none):
        return data_in;

    # dir, file, path
    if (id_in == id_validate_dir or
        id_in == id_validate_file or
        id_in == id_validate_path):
        assert (type(data_in) == str);
        if (Validate(id_in, data_in)):
            return CleanPath(data_in);

    # yes|no, true|false, 1|0
    if (id_in == id_validate_yesno):
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
