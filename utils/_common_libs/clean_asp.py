# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   04 May  2007
# Modified:  03 July 2007

# Utility Script: This script is included in many projects.
# PLEASE NOTE: the versions are *NOT* interchangeable. This script grows
#   with each project and its implementation may change. Updating this
#   script could break your project if it is based on an older version.
#   In addition, some clean_asp scripts are specialized for the project
#   into which they are imported and could have /very bad/ effects on
#   other projects.
# So, DON'T update this lib unless you are going to edit the code in place.

# Cleans up .aspx, .ascx files in the target directory
# Converts:
#   - '<div class="asp">' to '<%' and the VERY NEXT '</div>' to '%>'
#   - '<div class="asp:bhc">' to '<bhc:' and the VERY NEXT '</div>' to ' />'
#   Iff the following are between '<div class="asp">' tags:
#          'and'  to  '&&'
#          'or'   to  '||'
#          '&lt;' to  '<'
#          '&gt;' to  '>'

# UGLINESS: this script is not very advanced. You *MUST* update the globals
#   in order to specify /where/ the files to be cleaned are. Please do not
#   include the complete path. Place any files to be modified within the
#   script's working directory to prevent overwritting something important.

# NOTE: util_lib may need to be modified depending on what the local copy
#   of the util_lib is named. The 'as util_lib' will prevent the script
#   from breaking when you specify the local file.

# we'll need these for working with files and sending exit value
import sys, glob, os

# some helpful functions
import util_lib as util_lib

# globals
max_read  = 1000000; # a meg should be enuf. That's *HUGE* for a text file.
dir_in    = 'chatter-output\\';
ext_list  = ['.aspx', '.ascx'];
tag_map   = {
    '<div class="asp">'    : [Tag('<div class="asp">'    ,'</div>'), Tag('<'    , ' %>')],
    '<div class="asp-bhc">': [Tag('<div class="asp-bhc">','</div>'), Tag('<bhc' , ' />')],
    'asp:%'                : [Tag('asp:%'                ,'%'     ), Tag('<%'   , '%>' )],
    'asp-char:%'           : [Tag('asp-char:%'           ,'%'     ), Tag('&'    , ';'  )]}
intag_map = {
    'and' : '&&',
    'or'  : '||',
    '&lt;': '<' ,
    '&gt;': '>' };


# Tag
class Tag:
    open  = '';
    close = '';

    def __init__(self, o_in, c_in):
        assert(type(o_in) == str) and (type(c_in) == str), 'clean_asp.Tag.__init__(): o_in and c_in must be strings';
        self.open  = o_in;
        self.close = c_in;
    def __str__(self):
        return 'open:  \'' + str(self.open)  + '\'\nclose: \'' + str(self.close) + '\''


# Def: GetFilenames()
# recursively check dir_in for files with extensions in ext_list
# input:  dir_in - directory in which to search
# output: returns a list of paths matching criteria
# uses:   ext_list at global scope
def GetFilenames(dir_in):
    # globals used (not necessary here, but self-documenting)
    global ext_list;
    
    # a place to store results
    path_list = [];

    # clean dir_in
    dir_in = util_lib.CleanPath(dir_in);

    # find the paths
    for f in glob.glob(dir_in + '*'):
        if (os.path.isfile(f)):
            if (util_lib.GetExt(f) in ext_list):
                path_list.append(f);
        elif (os.path.isdir(f)):
            path_list = path_list + GetFilenames(f);

    # all done
    return path_list;


# Def: ReadFile()
# open file and read in data
# IN:  filename (or path) to file to read
# OUT: the content of the file on success, None on failure
def ReadFile(path_in):

    # if the file doesn't exist, don't try to read it
    if (not os.path.exists(path_in)) or (not os.path.isfile(path_in)):
        return None;

    # open, read, and close the file
    in_file = open(path_in, 'r');
    input_str = in_file.read(max_read);
    in_file.close();

    # we're done
    return input_str;


# Def: FindReplace()
# checks passed string for start and end ASP markers
# IN:   the string to be tested
# OUT:  [count, (start, end)]
#        count = number of strings found, -1 if error
def FindReplace(str_in):

    # for each key in tag_map
    for tag in tag_map.keys():
        # zero out processing string
        str_out = '';
        
        # get values to subsitute
        old_tag = tag_map.get(tag)[0];
        new_tag = tag_map.get(tag)[1];
            
        # find start of current str
        pos_start = str_in.find(tag);
        prev_end  = 0;
        while (pos_start > prev_end):
            # store intervening str
            str_out = str_out + str_in[prev_end:pos_start];

            # find end of current str
            pos_start = pos_start + len(old_tag.open);
            pos_end   = str_in[pos_start:].find(old_tag.close) + pos_start;

            # if we don't find an end, fail out
            if (pos_end < pos_start): return None;

            # store modified string
            sub_str = str_in[pos_start:pos_end];
            # modify substring
            for key in intag_map.keys():
                sub_str.replace(key, intag_map.get(key));

            # stuff our modified string into the output
            str_out = str_out + new_tag.open + sub_str + new_tag.close;

            # for the next pass, the end is the start
            prev_end = pos_end  + len(old_tag.close);

            # find next pos_start
            pos_start = str_in[prev_end:].find(tag) + prev_end;

        # add the remainder of the string
        str_out = str_out + str_in[prev_end:];

        # for subsequent keys, the output is the input
        str_in = str(str_out);

    # return the modified input
    return str_in;


# Def: write output
# writes the passed string to file (replaces contents of file)
# IN:   filename (or path) to write to, string to write
# OUT:  0 on success, -1 on failure
# FILE: file specified by filename has contents replaced with input string
def WriteString(path_in, str_in):

    # verify existance (if the file doesn't exist, then there's no way
    #   we're writing back modified information from it
    if not (os.path.exists(path_in) and os.path.isfile(path_in)):
        return False;

    # verify this is safe
    if (not util_lib.SafeSave(path_in)):
        return False;

    # open the file for writing
    out_file = open(path_in, 'w');

    # write the file
    print >> out_file, str_in;

    # close the file
    out_file.close();
    return True;


# main
if (__name__ == '__main__'):
    
    # ok, this is really short && simple:
    #   Find all the files we'll need to work with, then for each:
    #       1) read in the file
    #       2) perform replacements on specified tags
    #       3) write modified string back into the file

    # Find the filenames we want to work with
    path_list = GetFilenames(dir_in)

    # if no filenames, or no extensions
    if (path_list == []):
        print 'No files to work with.';
        sys.exit(0);
    if  (ext_list == []):
        print 'No extensions specified.';
        sys.exit(0);

    # for each filename:
    print 'Updating files named: ' + ext_list[0],
    for ext in ext_list[1:]:
        print ', \'' + ext + '\'',
    print ' in directory \'' + dir_in + '\'...';
    for path in path_list:
        
        # 1) read in the file
        str_in = ReadFile(path);
        if (len(str_in) == 0):
            print '  Error: cannot read file \'' + path + '\.';
            continue;

        # 2) perform replacements on specified tags
        out_str = FindReplace(str_in);
        if ((not out_str) or (len(out_str) == 0)):
            print 'Unable to perform replacements on \'' + path + '\'.';
            continue;
            
        # 3) write the modified string back to file
        if (not WriteString(path, out_str)):
            print '  Error: cannot write file \'' + path + '\'.';
        else:
            print '  Cleaned file: \'' + path + '\'.';

    print 'Processing complete.';
