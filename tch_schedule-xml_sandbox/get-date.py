# Author:     Travis Haapala
# Section:    Brookhaven MPI
# e-mail:     thaapala@dcccd.edu
# extention:  x4104
# Created:    04 January 2008
# Modified:   04 January 2008

# Just gets the current date and stores it in xml form. Because the creators
# of XSL decided no one would ever want to get the current date when using XSL.
# Who uses dates, anyway? Putzes.

# required libs
import sys, datetime

def main(filename):
    try:
        fout = open(filename, 'w');
    except:
        print 'Unable to open file:', filename;
        sys.exit(-1);

    date = datetime.date.today();

    fout.write('<date today="' + date.strftime('%m/%d/%Y') + '" />');

    fout.close();

if __name__ == '__main__':
    if (len(sys.argv) != 1):
        assert 'Syntax: get-date [filename in which to store xml]';
    
    main(sys.argv[1]);
