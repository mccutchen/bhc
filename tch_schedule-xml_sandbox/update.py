# Author:     Travis Haapala
# Section:    Brookhaven MPI
# e-mail:     thaapala@dcccd.edu
# extention:  x4104
# Created:    09 November 2007
# Modified:   09 November 2007

# Hits the district website to find the names of the most
# current schedule xml (per-semester), then downloads
# that xml into the specified directory.

# required libs
import os, sys, urllib2

# globals
base_url = ('http://econnect.dcccd.edu/econnect/Schedule/',
            '/xml/');
output_dir = 'data/';
HTML_MAX   = 2048;      # 2 KB
XML_MAX    = 4194304;   # 4 MB

# run
# the main, sorta
def run():
    semesters = ('Fall',
                 'Spring',
                 'Summer1',
                 'Summer2');
    fail_cnt = 0;

    # download the xml for each semester
    print 'Fetching DSC XML...';
    for s in semesters:
        filename = GetFilename(s);
        if (not(filename)):
            print '  !Error! Fetch filename of ' + s + ' xml failed.';
            fail_cnt += 1;
        else:
            path_dsc = os.path.normcase(output_dir + filename);
            if (GetXML(s, filename, path_dsc)):
                print '  Successfully updated ' + s + ' xml.';
            else:
                print '  !Error! Update of ' + s + ' xml failed.';
                fail_cnt += 1;
    print 'Complete.\n\n';
    return fail_cnt;

# GetFilename
# fetches the filename from the district xml index
def GetFilename(semester):
    # open website and check to make sure it succeeded
    webfile = urllib2.urlopen(base_url[0] + semester + base_url[1]);
    if (not(webfile)): return None;

    # store website and close file
    webstring = webfile.read(HTML_MAX);
    webfile.close();

    # find start and stop of filename
    start = webstring.find('schedule-200-');
    if (start < 0): return None;
    temp = webstring[start:].find('.xml');
    if (temp < 0): return None;
    stop = start + temp + len('.xml');

    # return filename
    return webstring[start:stop];

# GetXML
# fetches the xml from the district web
def GetXML(semester, filename, outpath):
    # open the xml url and check to make sure it succeeded
    url = base_url[0] + semester + base_url[1] + filename;
    xmlfile = urllib2.urlopen(url);
    if (not(xmlfile)):
        print '    !Error! Unable to open url:', url;
        return False;

    # grab the xml and close the url
    xmlstring = xmlfile.read(XML_MAX);
    xmlfile.close();

    # write output
    isOk = True;
    try:
        fout = open(outpath, 'w');
        if (fout):
            fout.write(xmlstring);
        else:
            print '    !Error! Unable to open output path:', outpath;
            isOk = False;
    except:
        print '    !Error! Error occurred while attempting to open or write to path:', outpath;
        isOk = False;

    fout.close();

    # return results, one way or the other
    return isOk;


# MAIN
if (__name__ == '__main__'):
    try:
        rVal = run();
    except:
        print '!Error! update failed utterly!';
    os.system('pause');
    sys.exit(rVal);
