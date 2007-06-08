"""
Counts the unique days in a Colleague download
"""

from schema import schema

uniquedays = dict()
a,b = schema['meets_0']

for line in file('../latest.txt'):
    days = line[a:b][26:33].strip().replace(' ','')
    if days:
        if days not in uniquedays:
            uniquedays[days] = 0
        uniquedays[days] += 1

print 'Unique Days'
print '==========='
days = uniquedays.keys()
days.sort()
for day in days:
    print '%s (%s)' % (day.ljust(10), uniquedays[day])