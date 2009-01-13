# Author: Travis Haapala
# Section: Brookhaven MPI
# e-mail: thaapala@dcccd.edu
# extention: x4104
# Creation Date: 27 Apr  07
# Last Modified: 20 June 07

# Acknowledgements: Will McCutchen wrote the original chatterer. Most of
#   v2.0 is a direct copy-paste from his program. The update was undertaken
#   to improve the user interface rather than the basic operation of the
#   program itself.

# Beta Version: stable and works with currently-available data
#               please send me an email if you find any bugs

# NOTE:
# when the batch file is run, you will be prompted for a date unless you provide a
#   'source\issue-date.txt' file with a valid date.
# date format is: mmddyy

# Usage:
# Place all input files (text files) into the source/ directory.
# Output is put in with the source files (because it's the source for the next step)
# The output will be a file called chatter.raw.xml - this is NOT a perfect transfer
#   because of the complexity of the data (and simplicity of this program ;oP )


# we'll need these for working with files
import glob, os, sys, datetime

# issue variables
month            = ''
date_short       = ''
date_long        = ''

# file locations:
dir_input        = 'source\\'
date_file        = 'issue-date.txt'
dir_output       = 'source\\'
file_output      = 'chatter.raw.xml'
filenames_list   = []
# Note: filenames_list indices (each item in the list is a string, except the last):
id_announcements = 0
id_events        = 1
id_aroundtown    = 2
id_birthdays     = 3
id_hails         = 4
id_articles      = 5
id_bodies        = 6  # <-- a list of strings

# for error purposes
cur_file = '';


# Def: loads dates from file, or prompts user and creates file
def SetDates():
    # what we're looking for
    date = None;
    global month;
    global date_short;
    global date_long;
    
    # first, see if there's a file called 'issue-date.txt' in the dir_input directory
    if (os.path.exists(dir_input + date_file) and os.path.isfile(dir_input + date_file)):
        fin = open(dir_input + date_file);
        date_in = fin.readline();
        fin.close();
        date = ParseDate(date_in.strip());

    # if that didn't work, prompt user until they get it right
    if (not date):
        while (not date):
            date_in = raw_input('Enter the issue date (mmddyy): ');
            date = ParseDate(date_in);

            if (not date):
                print 'Invalid date. Please try again.';

        # write date to file so we don't have to do this again
        if (os.path.exists(dir_input + date_file)):
            print 'Unable to write issue-date.txt; file already exists';
        else:
            fout = open(dir_input + date_file, 'w');
            print >> fout, date.strftime('%m%d%Y');
            fout.close();

    # now make use of the date 
    if (date):
        # store short / long formates
        date_short = date.strftime('%m%d');
        date_long  = date.strftime('%B %d, %Y');

        # store next month
        month = datetime.date(date.year, (date.month) % 12 + 1, 1).strftime('%B');

        # we're done
        valid = True;

    return True;

# Def: converts date into useable form
def ParseDate(date_in):
    if (type(date_in) != str): return None;
    if (len(date_in) < 6): return None;
    if (not date_in.isdigit()): return None;
    try:
        if (len(date_in) == 6):
            d = datetime.date(2000+int(date_in[4:]), int(date_in[:2]), int(date_in[2:4]))
        elif (len(date_in) == 8):
            d = datetime.date(int(date_in[4:]), int(date_in[:2]), int(date_in[2:4]))
        else:
            return None;
    except:
        return None;
    else:
        return d;

# Def: gets a list of all text files in the source directory
def GetFilenames(dir_in):
    f_list = ['','','','','','',[]]
    for f in glob.glob(dir_in + '*.txt'):
        if (f.lower().find('announcements.txt') >= 0):
            f_list[id_announcements] = f
        elif (f.lower().find('events.txt') >= 0):
            f_list[id_events] = f
        elif (f.lower().find('aroundtown.txt') >= 0):
            f_list[id_aroundtown] = f
        elif (f.lower().find('birthdays.txt') >= 0):
            f_list[id_birthdays] = f
        elif (f.lower().find('hailfarewell.txt') >= 0):
            f_list[id_hails] = f
        elif (f.lower().find('articles.txt') >= 0):
            f_list[id_articles] = f
        elif (f.lower().find('issue-date.txt') >= 0):
            continue;
        else:
            f_list[id_bodies].append(f)
    return f_list

# Def: replaces special chars with their unicode entities
def Format(line_in, replace = True):
    global cur_file;
    char_map = {
        10:  '',        # newline
        13:  '\n',      # newline
        160: '',        # non-printable char
        38:  '&amp;',   # ampersand
        60:  '&lt;',    # less than
        62:  '&gt;',    # greater than
        145: '&#8216;', # left single quote
        146: '&#8217;', # right single quote
        34:  '&quot;',  # straight quote
        147: '&#8220;', # left double quote
        148: '&#8221;', # right double quote
        133: '&#8230;', # elipsis
        150: '&#8211;', # dash
        151: '&#8212;', # long dash
        169: '&#169;',  # Copywrite symbol
        174: '&#174;',  # Registered Trademark symbol
        188: '&#188;',  # 1/4
        189: '&#189;',  # 1/2
        190: '&#190;',  # 3/4
        224: '&#224;',  # lowercase a (accent: grave)
        225: '&#225;',  # lowercase a (accent: acute)
        232: '&#232;',  # lowercase e (accent: grave)
        233: '&#233;',  # lowercase e (accent: acute)
        236: '&#236;',  # lowercase i (accent: grave)
        237: '&#237;',  # lowercase i (accent: acute)
        239: '&#239;',  # lowercase i (w/umlaut)
        242: '&#242;',  # lowercase o (accent: grave)
        243: '&#243;',  # lowercase o (accent: acute)
        }
    char_list = list(line_in.strip())
    out_list  = []
    out_str   = ""
    index     = 0
    for c in char_list:
        n = ord(c)
        if (n in char_map):
            if (replace):
                # if it's not a character reference (ie: &#number;)
                if (index+1 >= len(char_list)) or (c != '&') or (char_list[index+1] != '#'):
                    out_list.append(char_map.get(n))
                else:
                    out_list.append(c)
        elif (n <= 31):
            print '!Non-printable character (' + str(n) + ') skipped in file ' + cur_file + '.';
        elif (n >= 128):
            print '- Non-standard character (' + str(n) + ') found: ' + c + ' in file ' + cur_file + '.';
            out_list.append(c);
        else:
            out_list.append(c)
        index = index + 1
        
    return out_str.join(out_list)

# Def: converts an article title into a filename-format string
def MakeID(line_in):
    # remove extra spaces
    line_in = Format(line_in.strip(), False)
    while ("  " in line_in):
        line_in = line_in.replace("  ", " ")            

    # get some processing variables
    line_len = len(line_in)
    id_parts = ['','','']
    line_spc = [0,0,0]
    id_out   = ""

    # basically, it uses the first three words of the title to make the id
    # I can see where this could be a problem if multiple articles started
    #   with the same three wrods. If it becomes a problem, I'll fix it.
    line_spc[0] = line_in.find(" ")
    if (line_spc[0] >= 0):
        id_parts[0] = line_in[:line_spc[0]]
        line_spc[1] = line_in[line_spc[0]+1:].find(" ") + line_spc[0]+1
        if (line_spc[1] > line_spc[0]+1):
            id_parts[1] = line_in[line_spc[0]+1:line_spc[1]]
            line_spc[2] = line_in[line_spc[1]+1:].find(" ") + line_spc[1]+1
            if (line_spc[2] > line_spc[1]+1):
                id_parts[2] = line_in[line_spc[1]+1:line_spc[2]]
                id_str = id_parts[0] + "-" + id_parts[1] + "-" + id_parts[2]
            elif (line_len > line_spc[2]+1):
                id_parts[2] = line_in[line_spc[1]+1:]
        elif (line_len > line_spc[1]+1):
            id_parts[1] = line_in[line_spc[0]+1:]
    elif (line_len > line_spc[0]+1):
        id_parts[0] = line_in

    id_out = id_parts[0]
    if (len(id_parts[1]) > 0):
        id_out = id_out + "-" + id_parts[1]
        if (len(id_parts[2]) > 0):
            id_out = id_out + "-" + id_parts[2]

    # Ok, the ID's almost done, now to just remove anything that isn't a
    #  letter or a -.
    for c in list(id_out):
        if (not c.isalpha()) and (not c.isdigit()) and (not c == '-'):
            id_out = id_out.replace(c,'')
    return id_out.lower()



# Def: figure out what type of line we are reading from events.txt
def GetType(line):
    # A line can be one of the following (matched in this order):
    #  -title
    #     *No checks made for this type, as the text can by literally anything
    #  -presenter
    #     *Line starts with "Presented by"
    #  -location
    #     *Line contains "Bldg." and/or "Room"
    #  -date
    #     *Line contains a month
    #  -url
    #     *Line starts with "www." or "http"
    #  -description
    #     *Anything not caught in the above categories goes here

    # If we pre-tagged the file:
    tag_list = ['title:','presenter:','location:','date:','url:','description:']
    for tag in tag_list:
        if (tag in line[:line.find(" ")].lower()):
            return [tag[:len(tag)-1],line[len(tag):]]

    # Otherwise, do it the hard way
    month_list = ['jan. ','jan ','january ','feb. ','feb ','february',
                  'mar. ','mar ','march ','apr. ','apr ','april ',
                  'may ','june ','july ','aug. ','aug ','august ',
                  'sept. ','sept ','september ','oct. ','oct ','october ',
                  'nov. ','nov ','november ','dec. ','dec ','december ']
    location_list = ['bldg.','building','room','international courtyard',
                     'student services building','performance hall',
                     'treetop caf','lobby']

    line_type = ''
    if (line.lower().find("presented by") == 0):
        line_type = 'presenter'
    if (line_type == ''):
        for loc in location_list:
            if (line.lower().find(loc) >= 0):
                line_type = 'location'
    if (line_type == ''):
        if (line.find(" ") > 0) and (line[:line.find(" ")+1].lower() in month_list):
            line_type = 'date'
    if (line_type == ''):
        if (line.lower().find("www.") == 0) or (line.lower().find("http") == 0):
            line_type = 'url'
    if (line_type == ''):
        line_type = 'description'

    return [line_type, line]

# Def: reads the announcements file
def ReadAnnouncements(fname):
    body_list = []
    title_str = ""
    id_str    = ""
    id_cnt    = 0
    id_list   = []
    out_list  = []
    r_mode    = "title"
    global cur_file;
    cur_file = fname;
    
    in_file = open(fname, "r")
    for line in in_file:
        if (line.strip() == ""):
            if (r_mode == "body"):
                id_str = MakeID(title_str)
                if (id_str in id_list):
                    id_str = id_str + str(id_cnt)
                out_list.append([id_str, title_str, body_list])
                body_list = []
                title_str= ""
                id_cnt = id_cnt + 1
                r_mode = "title"
        else:
            if (r_mode == "title"):
                title_str = Format(line)
                r_mode = "body"
            else:
                body_list.append(Format(line))
    if (len(title_str) > 0):
        out_list.append([id_str, title_str, body_list])

    if (len(out_list) > 0):
        print "Processed Announcements";

    in_file.close()
    return out_list

# Def: reads the events file
# NOTE: I did my best to stuff the text into the correct tags,
#       but I'm willing to bet that some of it will be in the
#       wrong place. Too many possibilities to code.
# NOTE: I included an option to tag each line in the events.txt
#       We'll see if it's worth the time, but the code supports it.
def ReadEvents(fname):
    date_str   = ""
    id_list    = []
    event_list = ['title',['presenter'],['location'],['date'],['url'],['description']]
    date_list  = ['',[]] # ['date',[event_list]]
    out_list   = []
    r_mode     = "title"
    global cur_file;
    cur_file = fname;
    
    in_file = open(fname, "r")
    for line in in_file:
        
        if (line.strip() == ""):
            if (r_mode == "other"):
                # save old
                if (date_str in id_list):
                    date_list[1].append(event_list)
                else:
                    id_list.append(date_str)
                    date_list = [date_str, [event_list]]
                    out_list.append(date_list)
                event_list = ['title',['presenter'],['location'],['date'],['url'],['description']]
                r_mode = "title"
        else:
            # Here's the magic line. We'll see how well it works.
            # Basically, since the line types can occur in any order
            #   within events.txt, this function *attempts* to figure
            #   out which type of information each line contains.
            line_type = GetType(Format(line))
            if (r_mode == "title"):
                if (line_type[0] == 'date'):
                    date_str = line_type[1]
                else:
                    event_list[0] = line_type[1]
                    r_mode = 'other'
            else:
                if (line_type[0] == 'presenter'):
                    event_list[1].append(line_type[1])
                elif (line_type[0] == 'location'):
                    event_list[2].append(line_type[1])
                elif (line_type[0] == 'date'):
                    event_list[3].append(line_type[1])
                elif (line_type[0] == 'url'):
                    event_list[4].append(line_type[1])
                else:
                    event_list[5].append(line_type[1])
                    
    if (event_list[0] != 'title'):
        out_list.append([date_str, [event_list]])

    if (len(out_list) > 0):
        print "Processed Events";

    in_file.close()
    return out_list

# Def: reads the around town file
# NOTE: this is really just a copy-paste (mostly) of read events
#       most of the same functionality is supported. We'll see how
#       much tweaking is required.
def ReadAroundTown(fname):
    date_str   = ""
    id_list    = []
    event_list = ['title',['location'],['date'],['description']]
    out_list   = []
    r_mode     = "title"
    global cur_file;
    cur_file = fname;
    
    in_file = open(fname, "r")
    for line in in_file:
        
        if (line.strip() == ""):
            if (r_mode == "other"):
                # save old
                out_list.append(event_list);
                event_list = ['title',['location'],['date'],['description']]
                r_mode = "title"
        else:
            # Here's the magic line. We'll see how well it works.
            # Basically, since the line types can occur in any order
            #   within events.txt, this function *attempts* to figure
            #   out which type of information each line contains.
            line_type = GetType(Format(line))
            if (r_mode == "title"):
                event_list[0] = line_type[1];
                r_mode = 'other'
            else:
                if (line_type[0] == 'location'):
                    event_list[1].append(line_type[1])
                elif (line_type[0] == 'date'):
                    event_list[2].append(line_type[1])
                else:
                    event_list[3].append(line_type[1])
                    
    if (event_list[0] != 'title'):
        out_list.append(event_list)

    if (len(out_list) > 0):
        print "Processed Around Town";
        
    in_file.close()
    return out_list

# Def: reads the birthdays file
def ReadBirthdays(fname):
    date_str  = ""
    name_str = ""
    out_list  = []
    global cur_file;
    cur_file = fname;
    
    in_file = open(fname, "r")
    for line in in_file:
        pos = line.find(" - ")
        if (pos >= 0):
            out_list.append([Format(line[:pos]), Format(line[pos+3:])])

    if (len(out_list) > 0):
        print "Processed Birthdays";
        
    in_file.close()
    return out_list

# Def: reads the hail/farewell file
def ReadHails(fname):
    type_list = ['',[]]
    out_list  = []
    r_mode    = "type"
    global cur_file;
    cur_file = fname;

    in_file = open(fname, "r")
    for line in in_file:
        if (line.strip() == ""):
            r_mode = "type"
            if (len(type_list[1]) > 0):
                if (len(out_list) == 0):
                    out_list = [type_list]
                else:
                    out_list.append(type_list)
            type_list = ['',[]]
        else:
            if (r_mode == "type"):
                r_mode = "names"
                lsl = line.strip().lower();
                if ("hires" in lsl or "welcome" in lsl or "hail" in lsl):
                    type_list[0] = 'Hail'
                elif ("terminations" in lsl or "bye" in lsl or "farewell" in lsl):
                    type_list[0] = 'Farewell'
                elif ("roles" in lsl or "change" in lsl or "move" in lsl):
                    type_list[0] = 'Role Changes'
                else:
                    continue;
                    print "Unknown Hail-and-Farewell type: " + line
            else:
                pos0 = line.find(',')
                pos1 = line[pos0+1:].find(',') + pos0+1
                pt0_str = Format(line[:pos0])
                pt1_str = Format(line[pos0+2:pos1])
                pt2_str = Format(line[pos1+2:])

                if not (pt0_str or pt1_str or pt2_str):
                    print "Error processing name: '" + pt0_str + "' '" + pt1_str + "' '" + pt2_str + "'."
                else:
                    if (len(type_list[1]) == 0):
                        type_list[1] = [[pt0_str, pt1_str, pt2_str]]
                    else:
                        type_list[1].append([pt0_str, pt1_str, pt2_str])

    if (len(type_list[1]) > 0):
        out_list.append(type_list)

    if (len(out_list) > 0):
        print "Processed Hails and Farewells";

    in_file.close()
    return out_list

# Def: reads the articles file
def ReadArticles(f_articles, f_bodies):
    title_map  = {}
    title_key  = 0
    title_str  = ""
    id_str     = ""
    intro_str  = ""
    id_list    = []   # only used to ensure id's are unique
    intro_list = []
    body_list  = []
    out_list   = []
    r_mode     = "title"
    global cur_file;

    # read intros
    in_file = open(f_articles, "r")
    cur_file = in_file;
    for line in in_file:
        if (line.strip() == ""):
            if (r_mode == "intro"):
                if not (title_str in title_map.keys()):
                    title_map[title_str.lower()] = title_key
                    title_key = title_key + 1
                    out_list.append([id_str, title_str, intro_list, []])
                    intro_list = []
                title_str= ""
                r_mode = "title"
        else:
            if (r_mode == "title"):
                id_str    = MakeID(line)
                title_str = Format(line)
                if (id_str in id_list):
                    id_str = id_str + str(title_key)
                id_list.append(id_str)
                r_mode    = "intro"
            else:
                intro_list.append(Format(line))
                r_mode = "intro"
    if (len(title_str) > 0):
        if not (title_str.lower() in title_map.keys()):
            title_map[title_str.lower()] = title_key
            title_key = title_key + 1
            out_list.append([id_str, title_str, intro_list, []])

    # close f_articles
    in_file.close()

    # read bodies
    for fname in f_bodies:
        cur_file = fname;
        in_file   = open(fname, "r")
        r_mode    = "title"
        title_str = ""
        body_list = []
        for line in in_file:
            if (line.strip() != ""):
                if (r_mode == "title"):
                    title_str = Format(line)
                    r_mode = "intro"
                else:
                    body_list.append(Format(line))
        if (title_str.lower() in title_map.keys()):
            title_key = title_map.get(title_str.lower())
            out_list[title_key][3] = body_list
            print "Processed: " + title_str;
        else:
            print '\n'
            print "Unable to process article body: " + title_str;
            print 'title map keys:'
            for key in title_map.keys():
                print ' - ' + key;
            print '\n'

        # close f_articles
        in_file.close()

    # all done
    return out_list

# Def: writes the articles section
def WriteArticles(indent, lvl, article_list):
    # avoid writing empty tags:
    if (len(article_list) == 0):
        return ''

    # write what we've got!
    out_str = indent*(lvl) + "<articles>\n"

    for article in article_list:
        out_str = out_str + indent*(lvl+1) + '<article id="' + article[0] + '">\n'
        out_str = out_str + indent*(lvl+2) + '<title>' + article[1] + '</title>\n'

        # I don't think there should be multiple info's, but there are in some.
        # prolly more accurate to call the extra intro lines "bylines"
        for intro in article[2]:
            out_str = out_str + indent*(lvl+2) + '<intro>' + intro + '</intro>\n'

        # I'm adding this 'cause most of the time we have images. Easier to have a
        # boiler plate already there
        out_str = out_str + indent*(lvl+2) + '<img src="' + article[0] + '" alt="' + Format(article[1]) + '" />\n';
        
        out_str = out_str + indent*(lvl+2) + '<body>\n'
        for body in article[3]:
            out_str = out_str + indent*(lvl+3) + '<p>' + body + '</p>\n'
        out_str = out_str + indent*(lvl+2) + '</body>\n'

        out_str = out_str + indent*(lvl+1) + '</article>\n'

    out_str = out_str + indent*(lvl) + '</articles>\n'

    return out_str


# Def: writes the features section
def WriteFeatures(indent, lvl, announcement_list, event_list, around_list, birthday_list, hail_list):
    # avoid writing empty tags:
    if (len(announcement_list) + len(event_list) + len(birthday_list) + len(hail_list) == 0):
        return ''

    # write what we've got!
    out_str = indent*(lvl) + "<features>\n"

    # avoid writing empty tags:
    if (len(announcement_list) > 0):
        # fill in announcements
        out_str = out_str + indent*(lvl+1) + '<feature id="announcements">\n'
        out_str = out_str + indent*(lvl+2) + '<title>Announcements</title>\n'
        for announcement in announcement_list:
            out_str = out_str + indent*(lvl+2) + '<announcement id="' + announcement[0] + '">\n'
            out_str = out_str + indent*(lvl+3) + '<title>' + announcement[1] + '</title>\n'
            out_str = out_str + indent*(lvl+3) + '<body>\n'
            for body in announcement[2]:
                out_str = out_str + indent*(lvl+4) + '<p>' + body + '</p>\n'
            out_str = out_str + indent*(lvl+3) + '</body>\n'
            out_str = out_str + indent*(lvl+2) + '</announcement>\n'
        out_str = out_str + indent*(lvl+1) + '</feature>\n'

    # avoid writing empty tags:
    if (len(event_list) > 0):
        # fill in events
        # (Treat as rough draft, unless the events.txt has been pre-formated)
        out_str = out_str + indent*(lvl+1) + '<feature id="campus-events">\n'
        out_str = out_str + indent*(lvl+2) + '<title>Campus Events</title>\n'

        for date_group in event_list:
            out_str = out_str + indent*(lvl+2) + '<date-group date="' + date_group[0] + '">\n'
            for event in date_group[1]:
                out_str = out_str + indent*(lvl+3) + '<event>\n'
                out_str = out_str + indent*(lvl+4) + '<title>' + event[0] + '</title>\n'
                for index in [1,2,3,4,5]:
                    # hack
                    if (index >= len(event)): continue;
                    
                    item = 1
                    while item < len(event[index]):
                        tag_o = '<' + event[index][0] + '>'
                        tag_c = '</' + event[index][0] + '>\n'
                        out_str = out_str + indent*(lvl+4) + tag_o + event[index][item] + tag_c
                        item = item + 1
                out_str = out_str + indent*(lvl+3) + '</event>\n'
            out_str = out_str + indent*(lvl+2) + '</date-group>\n'

        out_str = out_str + indent*(lvl+1) + '</feature>\n'

    # avoid writing empty tags:
    if (len(around_list) > 0):
        # fill in events
        # (Treat as rough draft, unless the events.txt has been pre-formated)
        out_str += indent*(lvl+1) + '<feature id="around-town">\n'
        out_str += indent*(lvl+2) + '<title>Events in the Metroplex</title>\n'

        for event in around_list:
            out_str = out_str + indent*(lvl+2) + '<event>\n'
            out_str = out_str + indent*(lvl+3) + '<title>' + event[0] + '</title>\n'
            for index in [1,2,3]:
                # hack
                if (index >= len(event)): continue;
                
                item = 1
                while item < len(event[index]):
                    tag_o = '<' + event[index][0] + '>'
                    tag_c = '</' + event[index][0] + '>\n'
                    out_str = out_str + indent*(lvl+3) + tag_o + event[index][item] + tag_c
                    item = item + 1
            out_str = out_str + indent*(lvl+2) + '</event>\n'

        out_str = out_str + indent*(lvl+1) + '</feature>\n'
                                 
    # avoid writing empty tags:
    if (len(birthday_list) > 0):
        # fill in birthdays
        out_str = out_str + indent*(lvl+1) + '<feature id="birthdays" month="' + month + '">\n'
        out_str = out_str + indent*(lvl+2) + '<title>' + month + ' Birthdays</title>\n'
        out_str = out_str + indent*(lvl+2) + '<birthday-list>\n'
        for bday in birthday_list:
            out_str = out_str + indent*(lvl+3) + '<birthday date="' + bday[0] + '" names="' + bday[1] + '" />\n'
        out_str = out_str + indent*(lvl+2) + '</birthday-list>\n'
        out_str = out_str + indent*(lvl+1) + '</feature>\n'

    # avoid writing empty tags:
    if (len(hail_list) > 0):
        # fill in hail-and-farewells
        out_str = out_str + indent*(lvl+1) + '<feature id="hail-and-farewell">\n'
        out_str = out_str + indent*(lvl+2) + '<title>Hail And Farewell</title>\n'
        for hail in hail_list:
            out_str = out_str + indent*(lvl+2) + '<people for="' + hail[0] + '">\n'
            for person in hail[1]:
                out_str = out_str + indent*(lvl+3) + '<person name="' + person[0] + '" department="' + person[1] + '" position="' + person[2] + '" />\n'
            out_str = out_str + indent*(lvl+2) + '</people>\n'
        out_str = out_str + indent*(lvl+1) + '</feature>\n'

    # finish off the features closing tag
    out_str = out_str + indent*(lvl) + '</features>\n'
    return out_str

# main
if (__name__ == '__main__'):
    # verify we have input
    if not (os.path.exists(dir_input)):
        print "No input files!"
        sys.exit(0)
    # create output directory if not already present
    if (not os.path.exists(dir_output)):
        os.mkdir(dir_output)

    # get our list of files we'll be working with
    filenames_list = GetFilenames(dir_input)

    # verify that the non-optional portions exist
    if not ((len(filenames_list[id_articles]) > 0)
            and (len(filenames_list[id_bodies]) > 0)):
        print "No articles!"
        sys.exit(0);

    # set the date vars
    if (not SetDates()):
        sys.exit(0);

    # read in optional files
    if (len(filenames_list[id_announcements]) > 0):
        list_announcements = ReadAnnouncements(filenames_list[id_announcements])
    else:
        list_announcements = []
    if (len(filenames_list[id_events]) > 0):
        list_events = ReadEvents(filenames_list[id_events])
    else:
        list_events = []
    if (len(filenames_list[id_aroundtown]) > 0):
        list_around = ReadAroundTown(filenames_list[id_aroundtown])
    else:
        list_around = []
    if (len(filenames_list[id_birthdays]) > 0):
        list_birthdays = ReadBirthdays(filenames_list[id_birthdays])
    else:
        list_birthdays = []
    if (len(filenames_list[id_hails]) > 0):
        list_hails = ReadHails(filenames_list[id_hails])
    else:
        list_hails = []

    # read in articles
    list_articles = ReadArticles(filenames_list[id_articles], filenames_list[id_bodies])

    # Ok, we have all the information now, let's put it into the xml_string
    # xml string - we'll add to this as we go
    xml_string = '<?xml version="1.0" encoding="utf-8"?>\n<chatter>\n    <issue date="' + date_long + '" url="' + date_short + '">\n'
    xml_string = xml_string + WriteArticles("    ", 2, list_articles)
    xml_string = xml_string + WriteFeatures("    ", 2, list_announcements, list_events, list_around, list_birthdays, list_hails)
    xml_string = xml_string + """    </issue>\n</chatter>"""

    # print out the xml
    f_out = open(dir_output + file_output, "w")
    print >> f_out, xml_string
    f_out.close()

    # We're done.
