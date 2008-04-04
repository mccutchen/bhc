from schema import schema

"""
Master courses have section number 0000 and are set to
Do Not Print, according to Rik.
"""


for line in file('../2006-fall/latest.txt'):
    a, b = schema['section']
    section = line[a:b].strip()

    if section == '2000':
        print 'Found a master course'
