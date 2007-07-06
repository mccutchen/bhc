# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   13 June 2007
# Modified:  03 July 2007

# Synopsis:
# Defines data structures to hold and process multiscan data

# required libs
import os, glob

# required user-created lib
import ms_util_lib as util_lib

# def GetType()
# an exception-safe way to get the data type of data_lib objects
# input:  obj - the object whose type is to be tested
# output: what type of data_lib object was passed in
#         if the object is not a data_lib object, None is returend
def GetType(obj):
        # get type
        try:
            data_type = obj.GetType();
        except (AttributeError):
            data_type = None;
        return data_type;

# list of data types
type_BatchData  = 'BatchData';
type_NodeData   = 'NodeData';
type_LocData    = 'LocData';
type_ResultData = 'ResultData';


# Exceptions
class InvalidFormat(Exception):
    def __init__(self, msg, data, data_type):
        self.msg = str(msg);
        self.data =  str(data);
        self.type = str(data_type);
    def __str__(self):
        return 'Error in ' + self.type + ' - ' + self.msg + ': \'' + self.data + '\'.';

# Data structure to store and retrieve formatting ids
class fmt(object):
    __limit__ = ['id_map', 'fmt_list', 'fmt_map'];

    fmt_list = ['norm', 'first', 'last', 'only'];
    id_map = {
        'type'   :  0,
        'indent' :  1,
        'level+' :  2,
        'level-' :  3,
        'data'   :  4,
        'name'   :  5,
        'hits'   :  6,
        'idx'    :  7,
        'row'    :  8,
        'col'    :  9,
        'str'    : 10,
        'pre'    : 11,
        'fol'    : 12,
        'line'   : 13 };

    def __init__(self):
        self.fmt_map = {};

    def id(value):
        if (value in fmt.id_map.keys()):
            return fmt.id_map.get(value);
        else:
            return None;
    id = staticmethod(id);

    def SetFmt(self, ids_in, list_in):
        if (type(list_in) != list): return False;
        if (len(list_in) < 1): return False;
        if (type(ids_in) != list): return False;
        if (len(ids_in) < 1): return False;

        # otherwise, process each in turn
        else:
            for i in ids_in:
                if (not i in self.fmt_list): return False;
                elif (i in self.fmt_map.keys()):
                    print '! Warning: overwriting format';
                else:
                    self.fmt_map[i] = list_in;
        return True;

    def GetFmt(self, id_in):
        if (not id_in in self.fmt_list): return None;

        if (id_in in self.fmt_map.keys()):
            return self.fmt_map.get(id_in);
        elif (self.IsValid()):
            return self.fmt_map.get('norm');
        else:
            return None;

    def IsValid(self):
        # just verify that we have a fallback.
        if ('norm' in self.fmt_map.keys()): return True;
        return False;

    def Clear(self):
        self.fmt_map = {};
            

# Data structure to hold the batch attributes
class BatchData(object):
    __limit__ = ['str_list', 'path_list', 'ext_list', 'skip_list', 'output'];
    
    # current set of attributes for a scan
    str_list   = [];
    path_list  = [];
    ext_list   = [];
    skip_list  = [];
    output     = '';

    # data_ids
    id_data_min    = -1;
    id_data_str    =  0;
    id_data_path   =  1;
    id_data_ext    =  2;
    id_data_skip   =  3;
    id_data_output =  4;
    id_data_max    =  5;

    # data map
    data_map = {
        'strings:'   : id_data_str,
        'paths:'     : id_data_path,
        'filetypes:' : id_data_ext,
        'skip:'      : id_data_skip,
        'output:'    : id_data_output };
    

    # def ___init___()
    # just zeroes out
    def __init__(self):
        self.Clear();

    # def Clear()
    # zeroes out data
    def Clear(self):
        self.str_list   = [];
        self.path_list  = [];
        self.ext_list   = [];
        self.skip_list  = [];
        self.output     = '';

    # def GetType()
    # because Python is not typesafe
    # input:  (none)
    # output: the name of the object's class in a string
    def GetType(self):
        return type_BatchData;

    # def __str__()
    # mostly for debugging, just print out the data
    def __str__(self):
        return self.FormatOutput('{\n', '}\n', 1, '   ', '\n');

    # def FormatOutput()
    # formatted output string
    def FormatOutput(self, block_prefix, block_suffix, level, indent, end_line, data_id = -1):
        assert((data_id < self.id_data_max) and (data_id >= self.id_data_min))

        # by data_id:
        if (data_id == self.id_data_min):
            # start the string
            str_out = block_prefix + indent*level + 'Batch Data ';

            # just give user indication of whether the data's valid at this point
            if (self.IsValid()):
                str_out = str_out + '(valid)' + end_line;
            else:
                str_out = str_out + '(INVALID)' + end_line;

            # str_list
            str_out = str_out + self.FormatOutput('', '', level+1, indent, end_line, self.id_data_str);

            # path_list
            str_out = str_out + self.FormatOutput('', '', level+1, indent, end_line, self.id_data_path);

            # ext_list
            str_out = str_out + self.FormatOutput('', '', level+1, indent, end_line, self.id_data_ext);

            # skip_list
            str_out = str_out + self.FormatOutput('', '', level+1, indent, end_line, self.id_data_skip);

            # output
            str_out = str_out + self.FormatOutput('', '', level+1, indent, end_line, self.id_data_output);

            # cap off the string
            str_out = str_out + block_suffix;

        # str_list
        if (data_id == self.id_data_str):
            str_out = indent*level + 'String List:' + end_line;
            # if it's invalid, just say so and skip to next section
            if (type(self.str_list) != list):
                str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
            # otherwise, print it out
            else:
                # for each line
                for i in self.str_list:
                    # if it's invalid, say so
                    if (type(i) != str):
                        str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
                    # otherwise, print data
                    else:
                        str_out = str_out + indent*(level+1) + '\'' + i + '\'' + end_line;

            # cap off the string
            str_out = str_out + block_suffix;

        # path_list
        if (data_id == self.id_data_path):
            str_out = indent*level + 'Path List:' + end_line;
            # if it's invalid, just say so and skip to next section
            if (type(self.path_list) != list):
                str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
            # otherwise, print it out
            else:
                # for each line
                for i in self.path_list:
                    # if it's invalid, say so
                    if ((type(i[0]) != str) or (not util_lib.Validate(util_lib.id_validate_path, i[0])) or (type(i[1]) != bool)):
                        str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
                    # otherwise, print data
                    else:
                        str_out = str_out + indent*(level+1) + '\'' + i[0] + '\'';
                        if (i[1]):
                            str_out = str_out + ' -r' + end_line;
                        else:
                            str_out = str_out + ' -n' + end_line;

            # cap off the string
            str_out = str_out + block_suffix;

        # ext_list
        if (data_id == self.id_data_ext):
            str_out = indent*level + 'Extension List:' + end_line;
            # if it's invalid, just say so and skip to next section
            if (type(self.ext_list) != list):
                str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
            # otherwise, print it out
            else:
                # for each line
                for i in self.ext_list:
                    # if it's invalid, say so
                    if (type(i) != str):
                        str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
                    # otherwise, print data
                    else:
                        str_out = str_out + indent*(level+1) + '\'' + i + '\'' + end_line;

            # cap off the string
            str_out = str_out + block_suffix;

        # skip_list
        if (data_id == self.id_data_skip):
            str_out = indent*level + 'Skip List:' + end_line;
            # if it's invalid, just say so and skip to next section
            if (type(self.skip_list) != list):
                str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
            # otherwise, print it out
            else:
                # for each line
                for i in self.skip_list:
                    # if it's invalid, say so
                    if ((type(i) != str) or (not util_lib.Validate(util_lib.id_validate_path, i))):
                        str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
                    # otherwise, print data
                    else:
                        str_out = str_out + indent*(level+1) + '\'' + i + '\'' + end_line;

            # cap off the string
            str_out = str_out + block_suffix;

        # output
        if (data_id == self.id_data_output):
            str_out = indent*level + 'Output:' + end_line;
            # if it's invalid, just say so and skip to next section
            if (type(self.output) != str):
                str_out = str_out + indent*(level+1) + 'invalid data' + end_line;
            # otherwise, print it out
            else:
                str_out = str_out + indent*(level+1) + '\'' + self.output + '\'' + end_line;

            # cap off the string
            str_out = str_out + block_suffix;


        # return the final output string
        return str_out;

    # def IsValid()
    # ensures that all data is valid (run prior to use)
    # input:  (none)
    # output: True if data is valid, else False
    def IsValid(self):
        # scan_str
        if (type(self.str_list) != list): return False;
        if (len(self.str_list) < 1): return False;
        for s in self.str_list:
            if (type(s) != str): return False;
            if (len(s) < 1): return False;
        # path_list
        if (type(self.path_list) != list): return False;
        if (len(self.path_list) < 1): return False;
        for path_item in self.path_list:
            if (type(path_item) != list): return False;
            if (len(path_item) != 2): return False;
            if (type(path_item[0]) != str): return False;
            if (not util_lib.Validate(util_lib.id_validate_path, path_item[0])): return False;
            if (type(path_item[1]) != bool): return False;
        # ext_list
        if (type(self.ext_list) != list): return False;
        for i in self.ext_list:
            if (type(i) != str): return False;
        if (len(self.ext_list) < 1): return False;
        # skip_list
        if (type(self.skip_list) != list): return False;
        for i in self.skip_list:
            if (type(i) != str): return False;
            if (not util_lib.Validate(util_lib.id_validate_path, i)): return False;
        # output
        if (type(self.output) != str): return False;
        if (len(self.output) < 1): return False;
        if (not util_lib.SafeSave(self.output)): return False;
        
        return True;

    # def IsEmpty()
    # checks if object is empty (has no data)
    # input:  (none)
    # output: True if no data, else False
    def IsEmpty(self):
        # scan_str
        if (self.str_list != []): return False;
        # path_list
        if (self.path_list != []): return False;
        # ext_list
        if (type(self.ext_list) != list): return False;
        if (len(self.ext_list) != 0): return False;
        # skip_list
        if (type(self.skip_list) != list): return False;
        if (len(self.skip_list) != 0): return False;
        # output
        if (self.output != ''): return False;
        
        return True;

    # def Load()
    # loads a batch file
    # input:   filename_in
    # output:  True if successful, else False
    # note:    modifies self.data
    #          modifies self.scan_list
    def Load(self, filename_in):
        assert (type(filename_in) == str), 'data_lib.BatchData.Load(): file_in must be a string';
        assert (util_lib.Validate(util_lib.id_validate_file, filename_in)), 'data_lib.BatchData.Load(): file_in not found.';

        # clear old data
        self.Clear();

        # load it
        file_in  = open(filename_in);
        line_cnt = 0;
        state    = 'next';
        for line in file_in:
            line = line.strip().lower();
            line_cnt = line_cnt + 1;

            # blank line (end of section)
            if (line == ''):
                state = 'next';

            # comment
            elif (line[:2] != '//'):

                # if waiting for section
                if (state == 'next'):
                    # start of section
                    if (line in self.data_map.keys()):
                        state = self.data_map.get(line);

                    # invalid
                    else:
                        self.ShowWarning(filename_in, line_cnt);

                # not waiting on section: process data
                else:
                    # process data
                    if (not self.Add(state, line)):
                        self.ShowWarning(filename_in, line_cnt);
                
        # close up
        file_in.close();
        return True;

    # def Add()
    # extracts data of the type id_<type>:
    # input:   item_id   - type of data to process
    #          data_in   - the data to process
    # output:  pref_flag - True if valid, False if not
    # note:    modifies self.data
    #          modifies self.scan_list
    def Add(self, item_id, data_in):
        # data verification
        assert (type(item_id) == int), 'data_lib.BatchData.Add(): item_id must be an integer';
        assert ((item_id < self.id_data_max) and (item_id > self.id_data_min)), 'data_lib.BatchData.Add(): item_id out of bounds';
        assert (type(data_in) == str), 'data_lib.BatchData.Add(): data_in must be a string';
        assert (len(data_in) > 1), 'data_lib.BatchData.Add(): data_in must be at least 2 chars long';

        # str
        if (item_id == self.id_data_str):
            # chop out the string to find
            temp_str = data_in.strip();
            temp_str = temp_str[1:len(temp_str)-1];

            # validate
            if (len(temp_str) < 1): return False;

            # store
            self.str_list.append(temp_str);

        # path
        elif (item_id == self.id_data_path):
            # check for attributes
            str_in  = data_in;
            bool_in = True;
            if (data_in[len(data_in)-2:] == '-r'):
                str_in = data_in[:len(data_in)-2].strip();
                bool_in = True;
            elif (data_in[len(data_in)-2:] == '-n'):
                str_in = data_in[:len(data_in)-2].strip();
                bool_in = False;

            # validate
            str_in = util_lib.Resolve(util_lib.id_validate_path, str_in);
            if (not str_in): return False;

            # store
            self.path_list.append([str_in, bool_in]);

        # ext
        elif (item_id == self.id_data_ext):
            # validate
            if (data_in != util_lib.GetExt(data_in)):
                return False;

            # store
            self.ext_list.append(data_in);

        # skip
        elif (item_id == self.id_data_skip):
            # validate
            valid = util_lib.Validate(util_lib.id_validate_path, data_in);
            if (not valid):
                return False;

            # store
            self.skip_list.append(data_in);

        # output
        elif (item_id == self.id_data_output):
            # validate
            if (len(data_in) < 1): return False;
            if (not util_lib.SafeSave(data_in)): return False;
            
            # store
            self.output = data_in;

        # unknown id
        else:
            return False;
                
        return True;    

    # def ShowWarning()
    # prints standard warning message for Batch object
    # input:  filename - name of preference file
    #         line     - line number
    # output: False (always false)
    def ShowWarning(self, filename, line):
        print '!Warning! invalid preference data in file(' + filename + ') at line(' + str(line) + ')';
        return False;


    # def Scan()
    # scans for the provided string
    # input:  suppress  - (optional) suppresses status messages
    # output: results   - object (ResultData instance)
    # note:   creates output files specified in self.file_list
    def Scan(self):
        assert (self.IsValid()), 'data_lib.BatchData.ScanDir(): data must be valid in order to scan a directory';

        # if the data's not good, the scan won't work
        if (not self.IsValid()):
            return False;

        # create the results object
        results = ResultData();

        # scan each directory
        for d in self.path_list:
            temp_results = self.ScanDir(d[0],d[1]);
            # if we got some, save 'em
            if (temp_results):
                results.AddNode(temp_results);

        # validate
        if results.IsValid():
            return results;
        else:
            return None;

    # def ScanDir()
    # ***DO NOT CALL DIRECTLY***
    # input:  path - the path to the current file/directory
    #         rcrs - whether to recurse
    # output: returns a ResultData object
    def ScanDir(self, path, rcrs):
        
        # create and set a NodeData object
        results = NodeData(path);
        
        # if this is a file
        if (os.path.isfile(path)):
            # if it has an acceptable extension scan it
            if (util_lib.GetExt(path) in self.ext_list):
                temp_locs = self.ScanFile(path);
                # if we got some, save 'em
                if (temp_locs != []):
                    results.SetLocs(temp_locs);

        # if it's a dir
        elif (os.path.isdir(path)):
            # check if we should skip
            if (path in self.skip_list):
                print 'Skipping: -' + path;
                return None;
            # otherwise, print status message
            else:
                print 'Scanning: ' + path;

            # get a list of files and a list of sub-dirs
            #  (because files should come first in output, for clarity)
            full_list = glob.glob(path + '*');
            file_list = [];
            dir_list  = [];
            for f in full_list:
                # clean it up
                f = util_lib.CleanPath(f);
                
                # if we should skip, skip
                if (f in self.skip_list):
                    print 'Skipping: -' + f;
                    continue;

                # otherwise, store it
                if (os.path.isfile(f)):
                    file_list.append(f);
                elif (os.path.isdir(f)):
                    dir_list.append(f);
                # not a dir or a file? What good are ya.

            # now scan the files
            for f in file_list + dir_list:
                temp_node = self.ScanDir(f, rcrs);
                if ((temp_node) and (temp_node.IsValid())):
                    results.AddNode(temp_node);

        # if we have results, return them
        if (results.IsValid() and results.hits > 0):
            return results;
        else:
            return None;


    # def ScanFile()
    # ***DO NOT CALL DIRECTLY***
    # input:  path   - file to be scanned
    # output: output - a formated list of lists
    def ScanFile(self, path):

        # set up our proc vars
        count    = 0;
        output   = [];
        line_cnt = 1;

        # open file
        f = open(path, 'r');

        # scan
        for line in f:
            # check for strings
            id_s = 0;
            for s in self.str_list:
                # find string in line
                loc = line.find(s);
                loc_old = 0;
                while (loc > 0):
                    loc = loc + loc_old
                    pre = line[:loc].lstrip()
                    fol = line[loc+len(s):].rstrip();
                    output.append(LocData(id_s, line_cnt, loc, s, pre, fol));
                    loc_old = loc + len(s);
                    loc = line[loc_old:].find(s);
                id_s = id_s + 1;

            # incriment line_cnt
            line_cnt = line_cnt + 1;

        # close up
        f.close();
        return output;


# Data structure to hold scan results
class ResultData(object):
    __limit__ = ['hits',    # total hits
                 'nodes',   # list of nodes (per-scan-directory)
                 'res_fmt'];    # default format for ResultData object

    res_fmt = fmt();
    res_fmt.SetFmt(['norm'],
                   [fmt.id('indent'), fmt.id('hits'), ' results found:\n',
                    fmt.id('level+'),
                    fmt.id('data')]);

    # def GetType()
    # because Python is not typesafe
    # input:  (none)
    # output: the name of the object's class in a string
    def GetType(self):
        return type_ResultData;

    # def __init__()
    # initializes some of the values
    # input:  str_cnt
    # output:
    def __init__(self):
        self.Clear();

    # def Clear()
    # zeroes out data
    def Clear(self):
        self.hits   = 0;
        self.nodes = [];

    # def Add()
    # accepts a node (with possible sub-nodes) and integrates them into self
    # input:  node_in - a NodeData object
    # output: (none)
    def AddNode(self, node_in):
        assert (GetType(node_in) == type_NodeData), 'data_lib.ResultData.Add(): node_in must be a valid NodeData';
        assert (node_in.IsValid()), 'data_lib.ResultData.Add(): node_in must be a valid NodeData';

        # store node
        self.nodes.append(node_in);

        # update count
        self.hits = self.hits + node_in.hits;
    
    # def __str__()
    # returns data as a formatted string
    def __str__(self):
        # get raw output
        fmt_str, val_list = self.FormatOutput('   ', 0,
                                              self.res_fmt.GetFmt('only'),
                                              NodeData.node_fmt,
                                              LocData.loc_fmt);

        # apply formatting
        ps = util_lib.PrintString();
        print >> ps, fmt_str %tuple(val_list), ;

        # return string
        return str(ps);
    
    # def FormatOutput()
    # formatted output string
    def FormatOutput(self, ind, lvl, this_fmt, node_fmt, loc_fmt):
        # if the results aren't valid, something's seriously wrong, so just say they're invalid
        if (not self.IsValid()):
            return 'Results Invalid!\n';
        if ((not node_fmt.IsValid()) or (not loc_fmt.IsValid())):
            return 'Format Invalid!\n';

        # parse input list
        assert(type(this_fmt) == list);
        out_str  = '';
        out_list = [];
        temp_str = '';
        fmt_flag = False;
        for item in this_fmt:
            if (type(item) == str):
                temp_str = item;
                fmt_flag = True;
            elif (type(item) == int):
                if (item == fmt.id('type')):
                    temp_str = self.GetType();
                    fmt_flag = True;
                elif (item == fmt.id('indent')):
                    temp_str = ind*lvl;
                    fmt_flag = True;
                elif (item == fmt.id('level+')):
                    lvl = lvl + 1;
                    continue;
                elif (item == fmt.id('level-')):
                    lvl = lvl - 1;
                    continue;
                elif (item == fmt.id('data')):
                    temp_str, temp_list = self.FormatData(ind, lvl, node_fmt, loc_fmt);
                    out_str  = out_str  + temp_str;
                    out_list = out_list + temp_list;
                    continue;
                elif (item == fmt.id('hits')):
                    temp_str = str(self.hits);
                    fmt_flag = False;
                else:
                    raise InvalidFormat('Invalid id', item, self.GetType());
            else:
                raise InvalidFormat('Invalid item type', item, self.GetType());

            # append
            if (fmt_flag):
                out_str = out_str + temp_str;
            else:
                out_str = out_str + '%s';
                out_list.append(temp_str);

        # make sure we got something
        if (len(out_str) < 1):
            raise InvalidFormat('No output', res_fmt, self.GetType());

        # kick it out
        return out_str, out_list;

    # def FormatData()
    # creates formated string based on data (for output)
    def FormatData(self, ind, lvl, node_fmt, loc_fmt):
        # quick check on params
        if ((type(loc_fmt) != fmt)  or
            (type(node_fmt) != fmt) or
            (type(ind) != str)      or
            (type(lvl) != int)      or
            (lvl < 0)):
            assert (False), 'data_lib.ResultData.FormatData(): invalid data passed'
            return None;

        # create the data portion
        data_str  = '';
        data_list = [];
        i = 0;
        for n in self.nodes:
            # incriment counter
            i = i + 1;

            # get type of format to use
            if (len(self.nodes) == 1):
                fmt_type = 'only';
            elif (i == 1):
                fmt_type = 'first';
            elif (i == len(self.nodes)):
                fmt_type = 'last';
            else:
                fmt_type = 'norm';

            # process data
            if (type(n) == NodeData):
                temp_str, temp_list = n.FormatOutput(ind, lvl, node_fmt.GetFmt(fmt_type), node_fmt, loc_fmt);
            else:
                assert (False), 'data_lib.NodeData.FormatData(): Invalid node data.';
            data_str  = data_str  + temp_str;
            data_list = data_list + temp_list;

        # we're done
        return data_str, data_list;

    # def IsValid()
    # ensures that all data is valid (run prior to use)
    # input:  (none)
    # output: True if data is valid, else False
    def IsValid(self):
        # hits
        if (type(self.hits) != int): return False;
        if (self.hits < 0): return False;
        # node_list
        if (type(self.nodes) != list): return False;
        if (len(self.nodes) < 1): return False;
        for i in self.nodes:
            if (GetType(i) != type_NodeData): return False;
            if (not i.IsValid()): return False;
        
        return True;

    # def IsEmpty()
    # checks if object is empty (has no data)
    # input:  (none)
    # output: True if no data, else False
    def IsEmpty(self):
        # hits
        if (self.hits != 0): return False;
        # node_list
        if (self.nodes != []): return False;

        return True;



# Data structure to hold a node
class NodeData(object):
    __limit__ = ['name',    # node name (the path)
                 'hits',    # number of hits
                 'data',    # sub-nodes | loc list, (for: not IsLeaf() | IsLeaf())
                 'fmt_obj'];    # default format for node objects

    node_fmt = fmt();
    node_fmt.SetFmt(['norm'],
                    [fmt.id('indent'), 'Name: ', fmt.id('name'), ' - ', fmt.id('hits'), ' result(s)\n',
                     fmt.id('level+'),
                     fmt.id('data')]);


    # def __init__()
    # initialization constructor
    # input:  name_in - name initial value
    # output: (none)
    def __init__(self, name_in):
        assert (type(name_in) == str), 'data_lib.NodeData.__init__(): name_in must be a positive-length string';
        assert (len(name_in) > 0), 'data_lib.NodeData.__init__(): name_in must be a positive-length string';

        self.name = name_in;
        self.hits = 0;
        self.data = [];

    # def GetType()
    # because Python is not typesafe
    # input:  (none)
    # output: the name of the object's class in a string
    def GetType(self):
        return type_NodeData;

    # def AddNode()
    # accepts a node (with possible sub-nodes) and integrates them into self
    # input:  node_in - a Node object
    # output: (none)
    def AddNode(self, node_in):
        assert (not self.IsLeaf()), 'data_lib.NodeData.SetLocs(): cannot add sub-nodes to a leaf node';
        assert (GetType(node_in) == type_NodeData), 'data_lib.NodeData.Add(): node_in must be a NodeData';

        # add node to list
        self.data.append(node_in);

        # update count
        self.hits = self.hits + node_in.hits;

    # def SetLocs()
    # accepts a list of locations (fmt: [cnt, [s_ind,row,col],...] and integrates them into self
    # input:  locs_in - a list of lists whose items are in the form [cnt, [s_ind,row,col],...]
    # output: (none)
    def SetLocs(self, locs_in):
        assert (not self.NotLeaf()), 'data_lib.NodeData.SetLocs(): locs_in must be a list of valid LocData objects';
        assert (type(locs_in) == list), 'data_lib.NodeData.SetLocs(): locs_in must be a list of valid LocData objects';
        assert (len(locs_in) > 0), 'data_lib.NodeData.SetLocs(): locs_in must be a list of valid LocData objects';
        for loc in locs_in:
            assert (GetType(loc) == type_LocData), 'data_lib.NodeData.SetLocs(): locs_in must be a list of valid LocData objects';
            assert (loc.IsValid()), 'data_lib.NodeData.SetLocs(): locs_in must be a list of valid LocData objects';

        # set data
        self.data = locs_in;

        # set hits
        self.hits = len(locs_in);

    # def __str__()
    # handy for debug and possibly can be used in output
    def __str__(self):
        # get raw output
        fmt_str, val_list = self.FormatOutput('   ', 0,
                                              self.node_fmt.GetFmt('only'),
                                              self.node_fmt,
                                              LocData.loc_fmt);

        # apply formatting
        ps = util_lib.PrintString();
        print >> ps, fmt_str %tuple(val_list), ;

        # return string
        return str(ps);
    
    # def FormatOutput()
    # formatted output string
    def FormatOutput(self, ind, lvl, this_fmt, node_fmt, loc_fmt):
        # if the results aren't valid, something's seriously wrong, so just say they're invalid
        if (not self.IsValid()):
            return 'Results Invalid!\n';
        if ((not node_fmt.IsValid()) or (not loc_fmt.IsValid())):
            return 'Format Invalid!\n';

        # parse input list
        assert(type(this_fmt) == list);
        out_str  = '';
        out_list = [];
        temp_str = '';
        fmt_flag = False;
        for item in this_fmt:
            if (type(item) == str):
                temp_str = item;
                fmt_flag = True;
            elif (type(item) == int):
                if (item == fmt.id('type')):
                    temp_str = self.GetType();
                    fmt_flag = True;
                elif (item == fmt.id('indent')):
                    temp_str = ind*lvl;
                    fmt_flag = True;
                elif (item == fmt.id('level+')):
                    lvl = lvl + 1;
                    continue;
                elif (item == fmt.id('level-')):
                    lvl = lvl - 1;
                    continue;
                elif (item == fmt.id('data')):
                    temp_str, temp_list = self.FormatData(ind, lvl, node_fmt, loc_fmt);
                    out_str  = out_str  + temp_str;
                    out_list = out_list + temp_list;
                    continue;
                elif (item == fmt.id('name')):
                    temp_str = self.name;
                    fmt_flat = False;
                elif (item == fmt.id('hits')):
                    temp_str = str(self.hits);
                    fmt_flag = False;
                else:
                    raise InvalidFormat('Invalid id', item, self.GetType());
            else:
                raise InvalidFormat('Invalid item type', item, self.GetType());

            # append
            if (fmt_flag):
                out_str = out_str + temp_str;
            else:
                out_str = out_str + '%s';
                out_list.append(temp_str);

        # make sure we got something
        if (len(out_str) < 1):
            raise InvalidFormat('No output', node_str, self.GetType());

        # kick it out
        return out_str, out_list;

    # def FormatData()
    # creates formated string based on data (for output)
    def FormatData(self, ind, lvl, node_fmt, loc_fmt):
        # quick check on params
        if ((type(loc_fmt) != fmt)  or
            (type(node_fmt) != fmt) or
            (type(ind) != str)      or
            (type(lvl) != int)      or
            (lvl < 0)):
            assert(False), 'Invalid data passed to NodeData.FormatData()';
            return None, None;

        # create the data portion
        data_str  = '';
        data_list = [];
        i = 0;
        for n in self.data:
            # incriment counter
            i = i + 1;

            # get type of format to use
            if (len(self.data) == 1):
                fmt_type = 'only';
            elif (i == 1):
                fmt_type = 'first';
            elif (i == len(self.data)):
                fmt_type = 'last';
            else:
                fmt_type = 'norm';

            # process data
            if (type(n) == NodeData):
                temp_str, temp_list = n.FormatOutput(ind, lvl, node_fmt.GetFmt(fmt_type), node_fmt, loc_fmt);
            elif (type(n) == LocData):
                temp_str, temp_list = n.FormatOutput(ind, lvl, loc_fmt.GetFmt(fmt_type));
            else:
                assert (False), 'data_lib.NodeData.FormatData(): Invalid node data.';
            data_str  = data_str  + temp_str;
            data_list = data_list + temp_list;

        # we're done
        return data_str, data_list;

    # def IsLeaf()
    # checks if object is a leaf node
    # input:  (none)
    # output: True iff this is a leaf node, else False
    def IsLeaf(self):
        # if empty, it doesn't mater so bail
        if (self.IsEmpty()):
            return False;
        
        # if self.data is invalid, it doesn't matter so bail
        if (type(self.data) != list): return False;

        # if there's no data, it's not either
        if (len(self.data) == 0): return False;

        # if valid leaf node
        if (GetType(self.data[0]) == type_LocData):
            return True;

        # if we've gotten this far and it's still not returned a value, the data is a mess so bail
        return False;

    # def NotLeaf()
    # checks if object is a non-leaf node
    # input:  (none)
    # output: True iff this is a non-leaf node, else False
    def NotLeaf(self):
        # if empty, it doesn't mater so bail
        if (self.IsEmpty()):
            return False;
        
        # if self.data is invalid, it doesn't matter so bail
        if (type(self.data) != list): return False;

        # if there's no data, it's not either
        if (len(self.data) == 0): return False;

        # if valid non-leaf
        if (GetType(self.data[0]) == type_NodeData):
            return True;

        # if we've gotten this far and it's still not returned a value, the data is a mess so bail
        return False;

    # def IsValid()
    # ensures that all data is valid (run prior to use)
    # input:  (none)
    # output: True if data is valid, else False
    def IsValid(self):
        # name
        if (type(self.name) != str): return False;
        if (len(self.name) < 1): return False;
        # hits
        if (type(self.hits) != int): return False;
        if (self.hits < 0): return False;
        # data
        if (type(self.data) != list): return False;
        if (len(self.data) > 0):
            data_type = GetType(self.data[0]);
            if ((data_type != type_NodeData) and
                (data_type != type_LocData)): return False;
            for d in self.data:
                if (GetType(d) != data_type): return False;
                if (not d.IsValid()): return False;

        return True;

    # def IsEmpty()
    # checks if object is empty (has no data)
    # input:  (none)
    # output: True if no data, else False
    def IsEmpty(self):
        # name
        if (self.name != ''): return False;
        # hits
        if (self.hits != 0): return False;
        # data
        if (self.data != []): return False;

        return True;


# Data structure to hold a hit
class LocData(object):
    __limit__ = ['idx',    # index of string found
                 'row',    # row found at
                 'col',    # column found at
                 'str',    # string found
                 'pre',    # preceeding part of line (wrt str)
                 'fol',    # following part of line  (wrt str)
                 'loc_fmt'];   # default format for a LocData object

    loc_fmt = fmt();
    loc_fmt.SetFmt(['norm'],
                   [fmt.id('indent'), 'string[', fmt.id('idx'), ']: \'', fmt.id('str'), '\'\n',
                    fmt.id('level+'),
                    fmt.id('indent'), '- at: ', '(', fmt.id('row'), ', ', fmt.id('col'), ')\n',
                    fmt.id('indent'), '- in: \'', fmt.id('line'), '\'']);

    # def GetType()
    # because Python is not typesafe
    # input:  (none)
    # output: the name of the object's class in a string
    def GetType(self):
        return type_LocData;

    # def __init__(row,col)
    # initialization constructor
    def __init__(self, idx_in, row_in, col_in, str_in, pre_in, fol_in):
        self.idx = idx_in;
        self.row = row_in;
        self.col = col_in;
        self.str = str_in;
        self.pre = pre_in;
        self.fol = fol_in;

    # def __str__()
    # handy for debug and possibly can be used in output
    def __str__(self):
        # get raw output
        fmt_str, val_list = self.FormatOutput('   ', 0, self.loc_fmt.GetFmt('only'));

        # apply formatting
        ps = util_lib.PrintString();
        print >> ps, fmt_str %tuple(val_list), ;

        # return string
        return str(ps);
    
    # def FormatOutput()
    # formatted output string
    def FormatOutput(self, ind, lvl, this_fmt):
        # if the results aren't valid, something's seriously wrong, so just say they're invalid
        if (not self.IsValid()):
            return 'Results Invalid!\n';

        # parse input list
        assert(type(this_fmt) == list);
        out_str  = '';
        out_list = [];
        temp_str = '';
        fmt_flag = False;
        for item in this_fmt:
            if (type(item) == str):
                temp_str = item;
                fmt_flag = True;
            elif (type(item) == int):
                if (item == fmt.id('type')):
                    temp_str = self.GetType();
                    fmt_flag = True;
                elif (item == fmt.id('indent')):
                    temp_str = ind*lvl;
                    fmt_flag = True;
                elif (item == fmt.id('level+')):
                    lvl = lvl + 1;
                    continue;
                elif (item == fmt.id('level-')):
                    lvl = lvl - 1;
                    continue;
                elif (item == fmt.id('idx')):
                    temp_str = str(self.idx);
                    fmt_flag = False;
                elif (item == fmt.id('row')):
                    temp_str = str(self.row);
                    fmt_flag = False;
                elif (item == fmt.id('col')):
                    temp_str = str(self.col);
                    fmt_flag = False;
                elif (item == fmt.id('str')):
                    temp_str = str(self.str);
                    fmt_flag = False;
                elif (item == fmt.id('pre')):
                    temp_str = str(self.pre);
                    fmt_flag = False;
                elif (item == fmt.id('fol')):
                    temp_str = str(self.fol);
                    fmt_flag = False;
                elif (item == fmt.id('line')):
                    temp_str = str(self.pre) + str(self.str) + str(self.fol);
                    fmt_flag = False;
                else:
                    raise InvalidFormat('Invalid id', item, self.GetType());
            else:
                raise InvalidFormat('Invalid item type', item, self.GetType());

            # append
            if (fmt_flag):
                out_str = out_str + temp_str;
            else:
                out_str = out_str + '%s';
                out_list.append(temp_str);

        # make sure we got something
        if (len(out_str) < 1):
            raise InvalidFormat('No output', res_fmt, self.GetType());

        # kick it out
        return out_str, out_list;

    # def IsValid()
    # ensures that all data is valid (run prior to use)
    # input:  (none)
    # output: True if data is valid, else False
    def IsValid(self):
        # idx
        if (type(self.idx) != int): return False;
        if (self.idx < 0): return False;
        # row
        if (type(self.row) != int): return False;
        if (self.row < 0): return False;
        # col
        if (type(self.col) != int): return False;
        if (self.col < 0): return False;
        # line
        if (type(self.str) != str): return False;
        if (type(self.pre) != str): return False;
        if (type(self.fol) != str): return False;

        return True;
