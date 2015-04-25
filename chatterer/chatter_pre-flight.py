import glob, os, sys, datetime, chatter_aio as aio

for f in glob.glob(aio.dir_input + '*.txt'):
    fin = open(f, 'r');
    data = fin.read();
    fin.close();
    
    data = data.replace(chr(13), '\n');

    fout = open(f, 'w');
    print >> fout, data;
    fout.close();
    
    print 'Finished ', f;

    
