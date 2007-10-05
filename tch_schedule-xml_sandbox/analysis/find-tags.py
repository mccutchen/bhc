if __name__ == '__main__':
    # get filenames to work with
    import sys, os;
    assert len(sys.argv) == 2, 'path of input file.';
    input_path = sys.argv[1];
    assert(os.path.isfile(input_path)), 'invalid input path.';

    # some globals
    p_list = [];
    c_list = [];
    filename = (os.path.split(input_path))[1];
    

    print 'Reading file:', filename, '...',;
    
    # filestream
    fin = open(input_path, 'r');
    data = fin.read();
    fin.close();
    data_list = (data.replace('\n','\r')).split('\r');

    print 'complete.'

    print 'Reading style information...',;
    
    # search for styles
    for line in data_list:
        # paragraph styles
        if line.find('@') == 0:
            end = line.find(':');
            key = line[:end];
            if not key in p_list:
                p_list.append(key);

        # character styles
        start = line.find('<@');
        end    = 0;
        while start >= 0 and start < len(line):
            start += end;
            end = line[start:].find('>') + start;
            if (end > start):
                key = line[start:end+1];
                if not key in c_list and key != '<@$p>':
                    c_list.append(key);
            start = line[end:].find('<@');

    print 'complete.';

    print '\n----------------------------------------';
    if len(p_list) > 0:
        print 'Paragraph styles in use:';
        for key in p_list:
            print key;
    else:
        print 'No paragraph styles in use.';

    print '';
    
    if len(c_list) > 0:
        print 'Character styles in use:';
        for key in c_list:
            print key;
    else:
        print 'No character styles in use.';
    print '----------------------------------------\n';

    fout = open('find-tags.txt', 'a');
    print >> fout, '\n', filename;
    print >> fout, '----------------------------------------';
    if len(p_list) > 0:
        print >> fout, 'Paragraph styles in use:';
        for key in p_list:
            print >> fout, key;
    else:
        print >> fout, 'No paragraph styles in use.';

    print '';
    
    if len(c_list) > 0:
        print >> fout, 'Character styles in use:';
        for key in c_list:
            print >> fout, key;
    else:
        print >> fout, 'No character styles in use.';
    print >> fout, '----------------------------------------\n';
    fout.close();
