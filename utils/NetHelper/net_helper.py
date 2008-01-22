# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   19 January 2008
# Modified:  19 January 2008

# Synopsis:
# Keeps network connections open. Created because the dev server connection times out
#   so frequently and takes ages to reconnect.

# system imports
import sys, os, time

# globals
sleep_time = 300; # 300 seconds (5 min) between actions
total_slept = -sleep_time;  # an accumulator for the total sleep time


# run
def Run(path):
    err = 0;
    while (err == 0): err = Cycle(path);

    print 'An error occured: ', err;
    return err;

def Cycle(path):
    # just recheck params to ensure they're not screwy
    if (not(os.path.isfile(path))): return 1;
    if (type(sleep_time) != int and type(sleep_time) != float): return 2;
    if (sleep_time <= 0): return 2;

    # construct output string
    global total_slept;
    total_slept += sleep_time;
    out_str = 'Connection open for: ' + str(total_slept) + ' seconds.';

    # write output to command line and specified path
    try:
        fout = open(path, 'w');

        try:
            print >> fout, out_str;
            print out_str;
            
        except:
            fout.close()
            return 4;

        fout.close();
        
    except:
        return 3;

    # sleep a bit
    time.sleep(sleep_time);
    return 0;

def ErrorSyntax():
    print 'Invalid syntax\nSYNTAX: net_helper {path to file} [time to sleep]';
    sys.exit(-1);

def PrintError(msg, err):
    print msg;
    sys.exit(err);
    

# main
if (__name__ == '__main__'):

    # validate arguments
    arg_cnt = len(sys.argv);
    if (arg_cnt > 3 or arg_cnt < 2): ErrorSyntax();

    # grab path and verify
    path = sys.argv[1];
    if (not(os.path.isfile(path))):
        PrintError('Invalid path: ' + path);

    # grab sleep time and verify
    if (arg_cnt == 3):
        sleep_time = int(sys.argv[2]);
        if (sleep_time <= 0):
            PrintError('Invalid sleep time: ' + str(sleep_time), -1);

    # run
    err = Run(path);
    sys.exit(err);
