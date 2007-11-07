# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   05 November 2007
# Modified:  05 November 2007

# Synopsis:
# scans the Schedule Builder data directory for possible data sets and presents the
#   user with a list of year-semester options. The user may then select from a list
#   of possible output transformations.


# system imports
import sys, glob

# we'll need regular expressions
import re

# _common_libs
import libs_py.util_lib as util_lib

# multiscan libs
import libs_py.menu_lib as menu_lib
import libs_py.data_lib as data_lib

# Translate Params
def TranslateParams(*argv):
    # set up patterns
    pattern_sem  = r'(summer|fall|spring)';
    pattern_year = r'([0-9]{2}|[0-9]{4})';
    pattern_tfm  = r'(print|proof|rooms|web|enrolling|now|soon)';
    pattern = r'^' + pattern_sem + pattern_year + pattern_tfm + r'$';
    
    # create return object
    user_input = data_lib.UserInput();

    # merge arguments
    args = (str.join(argv)).strip().lowercase().replace(' ','');
    # check against pattern
    if (not(re.match(args, pattern))):
        user_input.err_msg  = 'Invalid parameter format.\nUse: output (semester)(year)(transformation): ie spring08proof';
        user_input.err_code = 1;
        return user_input;

    # fill in user_input object
    user_input.semester  = (re.search(pattern_sem, args).group());
    user_input.year      = (re.search(pattern_year, args).group());
    user_input.transform = (re.search(pattern_tfm, args).group());

    return user_input;


# main
if (__name__ == '__main__'):

    # if there are commandline arguments, translate
    if (len(argv) > 1):
        user_input = TranslateParams(argv[1:]);

    # otherwise, collect them manually
    else:
        user_input = PromptUser();

    # Make sure we've got data
    if (user_input.err_msg):
        print user_input.err_msg;
        sys.exit(user_input.err_code);

    # make sure the data's valid
    ValidateData(user_input)
    if (user_input.err_msg):
        print user_input.err_msg;
        sys.exit(user_input.err_code);

    # run the transform
    RunTransform(user_input)
    if (user_input.err_msg):
        print user_input.err_msg;
        sys.exit(user_input.err_code);
    else:
        sys.exit(0);
        


    # get a list of batch files
    f_list  = [];
    for f in glob.glob('*.txt'):
        if (f.find('batch_') == 0):
            f_list.append(f);
    f_list.append('Other...');
    id_other = len(f_list);
    f_list.append('Exit');
    id_exit = len(f_list);

    # create necessary objects
    menu    = menu_lib.ExtMenu('Choose a file to load...', f_list);
    batch   = data_lib.BatchData();
    results = data_lib.ResultData();

    # present menu
    fname = menu.DisplayMenu();

    # if exit
    if (fname == id_exit):
        fname = None;

    # else other
    elif (fname == id_other):
        fname = util_lib.GetFilename();

    # if file picked
    else:
        fname = f_list[fname-1];

    # if we have an fname
    if (fname):
        # load file
        if (not batch.Load(fname)):
            print 'Couldn\'t load file: \'' + fname + '\'';

        # run scan
        else:
            results = batch.Scan();

            # if we didn't find anything, no need to write output
            if (not results):
                print 'No results found!'

            # write results
            else:
                # generate output
                fmt_str, val_list = results.FormatOutput('\t', 0,
                                                         fmt.res().GetFmt('only'),
                                                         fmt.node(),
                                                         fmt.loc());

                # format data for web-display
                val_list = util_lib.FormatWebsafe(val_list);

                # store it
                ps = util_lib.PrintString();
                print >> ps, fmt_str %tuple(val_list), ;
                
                # write output
                fout = open(batch.output, 'w');
                print >> fout, str(ps)
                fout.close()

    # done.
    sys.exit(0);

