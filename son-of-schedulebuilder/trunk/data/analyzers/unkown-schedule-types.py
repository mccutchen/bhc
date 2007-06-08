"""
Counts the unknown schedule types in 
Colleague.
"""

badtypes = []

for line in file('../latest.txt'):
    giventype = line[444:449].strip()
    if not giventype:
        number = '%s %s-%s' % (line[10:17].strip(), line[17:24].strip(), line[24:29].strip())
        synonym = line[34:45].strip()
        title = line[64:94].strip()
        badtypes.append((number, synonym, title))

print 'Unknown Course Types'
print '==================='

badtypes.sort(lambda a,b: cmp(a[1], b[1]))
for course in badtypes:
    print '%s\t%s\t%s' % course