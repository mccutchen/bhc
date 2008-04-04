# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   28 March 2008
# Modified:  28 March 2008

# Synopsis:
# At present, the SoSB uses a single set of dates for display and term-association. Since
#   the two need to be different, we have to go in after-the-fact and fix the display dates.
#   I'm lazy, I wrote a script to do it for me. This will only work with Summer 2008. I don't
#   know what the dates will be / have been in other years. Tweak it yourself.

# imports
import glob;

# globals
dates = {
    '<span>May 1-May 30</span>' : '<span>May 12-30</span>',
    '<span>June 1-July 6</span>' : '<span>June 9-July 3</span>',
    '<span>July 7-Aug. 8</span>' : '<span>July 9-Aug. 7</span>'}

# main
def main():
    for f in get_filenames():
        replace_dates(f);

# utility functions
def get_filenames():
    return glob.glob('summer*/index.aspx') + glob.glob('summer*/summer*/index.aspx');

def replace_dates(f):
    fin = open(f, 'r');
    data = fin.read();
    fin.close()
    
    for key in dates.keys():
        start_loc = data.find(key);
        while (start_loc > -1):
            end_loc = start_loc + len(key);
            if end_loc > len(data): return "FAILED: found start, but not end";
            data = data[:start_loc] + dates[key] + data[end_loc:];
            print 'Made replacement in ' + f + '\n    ' + key + ' : ' + dates[key];
            start_loc = data.find(key);

    fout = open(f, 'w');
    fout.write(data);
    fout.close();


if (__name__ == '__main__'):
    main();
