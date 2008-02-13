"""
Counts duplicate teacher names in a download file
and returns a python list to be used in the
schedule building program.
"""

names = dict()
nameslices = [(94,124), (124,154), (154,184), (184,214), (214,244)]

for line in file('../2006-fall/latest.txt'):
    for start,stop in nameslices:
        name = line[start:stop].strip()
        if name:
            try:
                lastname, initial = name.split(',')
                lastname = lastname.strip()
                initial = initial.strip()
                if lastname not in names:
                    names[lastname] = {}
                if initial not in names[lastname]:
                    names[lastname][initial] = 0
                names[lastname][initial] += 1
            except ValueError:
                pass

print 'Duplicated Last Names'
print '====================='
lastnames = names.keys()
lastnames.sort()
duplicates = []
for lastname in lastnames:
    initials = names[lastname]
    if len(initials) > 1:
        duplicates.append(lastname)
        initials = initials.keys()
        initials.sort()
        initials = ', '.join(initials)
        lastname = '%s:' % lastname
        print '%s\t%s' % (lastname.ljust(15), initials)

print
print 'Python list'
print '==========='
print repr(duplicates)
