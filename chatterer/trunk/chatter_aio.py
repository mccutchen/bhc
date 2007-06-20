# Author: Travis Haapala
# Section: Brookhaven MPI
# e-mail: thaapala@dcccd.edu
# extention: x4104
# Creation Date: 27 Apr 07
# Last Modified: 22 May 07

# Acknowledgements: Will McCutchen wrote the original chatterer. Most of
#   v2.0 is a direct copy-paste from his program. The update was undertaken
#   to improve the user interface rather than the basic operation of the
#   program itself.

# Beta Version: stable and works with currently-available data
#               please send me an email if you find any bugs

# NOTE:
# For each issue, modify the first section of variables to ensure proper dates
#   in the final output

# Usage:
# Place all input files (text files) into the source/ directory.
# Output is put in with the source files (because it's the source for the next step)
# The output will be a file called chatter.raw.xml - this is NOT a perfect transfer
#   because of the complexity of the data (and simplicity of this program ;oP


# we'll need these for working with files
import glob, os, sys

# variables to change per-issue
month            = "July" # <-- SET ONE MONTH AHEAD: this is for the birthdays
date_short       = "0620"
date_long        = "June 20, 2007"

# file locations:
dir_input        = "source\\"
dir_output       = "source\\"
file_output      = "chatter.raw.xml"
filenames_list   = []
# Note: filenames_list indices (each is a string):
id_announcements = 0
id_events        = 1
id_birthdays     = 2
id_hails         = 3
id_articles      = 4
id_bodies        = 5  # <-- a list of strings

# Def: set filenames
def GetFilenames(dir_in):
    f_list = ['','','','','',[]]
    for f in glob.glob(dir_in + '*.txt'):
        if (f.lower().find('announcements.txt') >= 0):
            f_list[id_announcements] = f
        elif (f.lower().find('events.txt') >= 0):
            f_list[id_events] = f
        elif (f.lower().find('birthdays.txt') >= 0):
            f_list[id_birthdays] = f
        elif (f.lower().find('hailfarewell.txt') >= 0):
            f_list[id_hails] = f
        elif (f.lower().find('articles.txt') >= 0):
            f_list[id_articles] = f
        else:
            f_list[5].append(f)
    return f_list

# Def: format
def Format(line_in, replace = True):
    char_map = {
        10:  '',        # newline
        38:  '&amp;',   # ampersand
        145: '&#8216;', # left single quote
        146: '&#8217;', # right single quote
        147: '&#8220;', # left double quote
        148: '&#8221;', # right double quote
        150: '&#8211;', # dash
        151: '&#8212;', # long dash
        233: '&#233;',  # lowercase e (accent: acute)
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
        else:
            out_list.append(c)
        index = index + 1
        
    return out_str.join(out_list)

# Def: make id
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



# Def: get type (of line in events.txt)
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

# Def: read announcements
def ReadAnnouncements(fname):
    body_list = []
    title_str = ""
    id_str    = ""
    id_cnt    = 0
    id_list   = []
    out_list  = []
    r_mode    = "title"
    
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

    in_file.close()
    return out_list

# Def: read events
# NOTE: I did my best to stuff the text into the correct tags,
#       but I'm willing to bet that some of it will be in the
#       wrong place. Too many possibilities to code.
# NOTE: I included an option to tag each line in the events.txt
#       We'll see if it's worth the time, but the code supports it.
def ReadEvents(fname):
    date_str   = ""
    id_list    = []
    event_list = ['title',['presenter'],['location'],['date'],['url'],['desc']]
    date_list  = ['',[]] # ['date',[event_list]]
    out_list   = []
    r_mode     = "title"
    
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
                event_list = ['title',['presenter'],['location'],['date'],['url'],['desc']]
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
        out_list.append([date_str, event_list])

    in_file.close()
    return out_list

# Def: read birthdays
def ReadBirthdays(fname):
    date_str  = ""
    name_str = ""
    out_list  = []
    
    in_file = open(fname, "r")
    for line in in_file:
        pos = line.find(" - ")
        if (pos >= 0):
            out_list.append([Format(line[:pos]), Format(line[pos+3:])])

    in_file.close()
    return out_list

# Def: read hail/farewells
def ReadHails(fname):
    type_list = ['',[]]
    out_list  = []
    r_mode    = "type"

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
                if ("new hires" in line.strip().lower()):
                    type_list[0] = 'Hail'
                elif ("terminations" in line.strip().lower()):
                    type_list[0] = 'Farewell'
                elif ("changing roles" in line.strip().lower()):
                    type_list[0] = 'Role Changes'
                else:
                    continue
                    #print "Unknown Hail-and-Farewell type: " + line
                    #type_list = [Format(line)]
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

    in_file.close()
    return out_list

# Def: read articles
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

    # read intros
    in_file = open(f_articles, "r")
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
        else:
            print "Unable to process article body: " + title_str

        # close f_articles
        in_file.close()

    # all done
    return out_list

# writes the articles section
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

        out_str = out_str + indent*(lvl+2) + '<body>\n'
        for body in article[3]:
            out_str = out_str + indent*(lvl+3) + '<p>' + body + '</p>\n'
        out_str = out_str + indent*(lvl+2) + '</body>\n'

        out_str = out_str + indent*(lvl+1) + '</article>\n'

    out_str = out_str + indent*(lvl) + '</articles>\n'

    return out_str


# writes the features section
def WriteFeatures(indent, lvl, announcement_list, event_list, birthday_list, hail_list):
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

#start main
# verify we have input
if not (os.path.exists(dir_input)):
    print "No input files!"
    exit
# create output directory if not already present
if (not os.path.exists(dir_output)):
    os.mkdir(dir_output)

# get our list of files we'll be working with
filenames_list = GetFilenames(dir_input)

# verify that the non-optional portions exist
if not ((len(filenames_list[id_articles]) > 0)
        and (len(filenames_list[id_bodies]) > 0)):
    print "No articles!"
    exit

# read in optional files
if (len(filenames_list[id_announcements]) > 0):
    list_announcements = ReadAnnouncements(filenames_list[id_announcements])
else:
    list_announcements = []
if (len(filenames_list[id_events]) > 0):
    list_events = ReadEvents(filenames_list[id_events])
else:
    list_events = []
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
xml_string = xml_string + WriteFeatures("    ", 2, list_announcements, list_events, list_birthdays, list_hails)
xml_string = xml_string + """    </issue>\n</chatter>"""

# print out the xml
f_out = open(dir_output + file_output, "w")
print >> f_out, xml_string
f_out.close()

# We're done.
