# Author:     Travis Haapala
# Section:    Brookhaven MPI
# e-mail:     thaapala@dcccd.edu
# extention:  x4104
# Created:    31 March 2008
# Modified:   31 March 2008

# Synopsis: The EMGI calendar is recreated by hand every month (I think?)
#   This does the bulk of the formatting and you can spot-correct.

# Instructions: EMGI sends their calendar as a word document with an
#   internal table. Not a readable file format. So save as a plain txt
#   file and check the 'Insert line breaks' checkbox. It'll add extras,
#   but most of those are very necessary.
# Once the file is converted:
#  1) open the file in notepad
#  2) ensure the first line has the date/year
#  3) delete the list of seven days, EXCEPT for the day on which the
#       month starts (ie April 2008 starts on a Tuesday, so I'd leave
#       that day directly under the 'April 2008' line).
#  4) add a third line under the day of the week containing the total
#       number of days in the month (ie April 2008 has 30 days, so I
#       would insert a line with '30' just under 'Tuesday').
#  5) make sure there is at least one blank line between the header and
#       the data block.
#  6) (optional) scroll down to the bottom of the page. You may see some items that
#       belong in a legend rather than as part of a daily event. If you
#       do, take those out. You'll have to put them back in by hand. Or
#       leave them in and move them from the last day's events.


# standard includes
import sys, os, re, glob

# user defined includes
import cal_data_lib as data_lib
import cal_menu_lib as menu_lib

# globals
max_file_len = 1048576; # 1 MB


# get data filenames
def get_file_list():
    return glob.glob('*.txt');

# readfile
def read_file(filename):
    if (not(os.path.isfile(filename))): failexit('File not found: ' + filename);

    fin = open(filename, 'r');
    data = fin.read(max_file_len);
    fin.close();

    if (len(data) >= max_file_len): failexit('File exceeds maximum file size. Please ensure the filename is correct: ' + filename);

    data = data.split('\n');
    if (len(data) < 4): failexit('File format is inconsistent with desired input format: ' + filename);

    return data;

# parse calendar data
def parse(data):
    cal = data_lib.Calendar();
    mode = 'date';

    # container for temp data
    day   = None;
    event = None;

    # grab the first three lines, which must be calendar date, first day, and day count
    if (not cal.SetDate(data[0])): return None;
    if (not cal.SetDayFirst(data[1])): return None;
    if (not cal.SetDayLast(data[2])): return None;

    # the rest should be events, parse 'em one line at a time
    for line in data[3:]:
        # clean up the line
        line = line.strip();

        # if it's blank, skip it
        if (line == ""): continue;

        # check for day of the month
        if (len(line) < 3 and re.match('[0-9]{1,2}', line)):
            if (day):
                if (not(event == None) and not(event.IsEmpty())):
                    day.AddEvent(event);
                    event = data_lib.Event();
                cal.AddDay(day);
            day = data_lib.Day(int(line));
            continue;

        # otherwise, there should be data to extract
        else:

            # check for time
            times = re.search('[0-9]{1,2}(:[0-9][0-9])?[ap]-[0-9]{1,2}(:[0-9][0-9])?[ap]', line);
            if (times):
                # if there's a time, this is a new event
                if (event):
                    day.AddEvent(event);
                event = data_lib.Event();

                # process times
                event.SetTimes(times.group());
                line = line.replace(times.group(), '').strip();
                if (line == ''): continue;

            # check for room
            rooms = re.search('(H1[0-9][0-9])(, )?', line);
            while (rooms):
                event.AddRoom(rooms.groups()[0]);
                line = line.replace(rooms.group(0), '').strip();
                rooms = re.search('(H1[0-9][0-9])(, )?', line);
                if (line == ''): continue;

            # anything else just gets appended to the text portion
            if (event):
                event.AddText(line);

    return cal;

def write_file(cal):
    out_str = cal.FormatASPX();
    fout = open('calendar.aspx', 'w')
    print >> fout, out_str;
    fout.close();
    

def failexit(error):
    print error;
    os.exit(1);
            
# if run directly
if (__name__ == "__main__"):
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
        data = read_file(filename);
        print 'Parsing data...';
        cal = parse(data)
        print 'Writing output...';
        write_file(cal)
        print 'Complete.'

    sys.exit(0);
