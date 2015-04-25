import sys

"""
Sees how many non-ascii characters there
are in the a given file.
"""

try:
    inpath = sys.argv[1]
except IndexError:
    inpath = 'regroupings.xml'
infile = file(inpath)

# how high can the chars go?
# 128 = ASCII, I think
ordlimit = 128

print '%s' % inpath
print '=' * len(inpath)

linecount = 0
charcount = 0
for line in infile:
    linecount += 1
    linechar = 0
    for char in line:
        charcount += 1
        linechar += 1
        if ord(char) > ordlimit:
            print >> sys.stderr, 'Bad char: %s (%d) at line %d, char %d' % (char, ord(char), linecount, linechar)

print '%d line(s)' % linecount
print '%d char(s)' % charcount