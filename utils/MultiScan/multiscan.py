# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   15 June 2007
# Modified:  03 July 2007

# Synopsis:
# scans the given directory or set of directories for the specified string or strings and
#  creates formatted output of each occurrance found.


# system imports
import sys, glob

# _common_libs
import ms_util_lib as util_lib

# multiscan libs
import ms_menu_lib as menu_lib
import ms_data_lib as data_lib

# output format lib
from ms_formats import WebOutputFormat as fmt


# main
if (__name__ == '__main__'):

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

