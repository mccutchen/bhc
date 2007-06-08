import datetime, time
from schema import schema

"""
Checks to see how many mismatches there are
between the number of weeks that Colleague reports
and that I calculate for each class.
"""


badweeks = []
goodweeks = []
mismatches = []

beginsfield = schema['begins']
endsfield = schema['ends']
weeksfield = schema['weeks']

rubrikfield = schema['rubrik']
numberfield = schema['number']
sectionfield = schema['section']

def parsedate(datestring, format='%m/%d/%Y'):
    return datetime.date(*time.strptime(datestring.strip(), format)[:3])

def extract(bounds, data):
    a, b = bounds
    return data[a:b]

for line in file('../2007-spring/BH2007SP.TXT'):
    a, b = beginsfield
    begins = line[a:b].strip()

    a, b = endsfield
    ends = line[a:b].strip()

    a, b = weeksfield
    weeks = line[a:b].strip()

    rubrik = extract(schema['rubrik'], line).strip()
    number = extract(schema['number'], line).strip()
    section = extract(schema['section'], line).strip()

    course_number = '%s %s-%s' % (rubrik, number, section)

    if weeks == '17':
        if begins == '01/16/2007' and ends == '05/10/2007':
            badweeks.append(1)
        elif begins != '01/16/2007' and ends != '05/10/2007':
            goodweeks.append(course_number)

    fmt = '%m/%d/%Y'
    start = parsedate(begins, fmt)
    end = parsedate(ends, fmt)
    delta = end - start
    rawweeks = delta.days / 7.0
    myweeks = str(int(round(rawweeks)))

    if myweeks != weeks:
        mismatches.append(1)
        #print 'Given %s - calculated %s\t(%s)' % (weeks, rawweeks)

print 'Number of bad weeks: %d' % len(badweeks)
print 'Number of good weeks: %d' % len(goodweeks)
#print 'Number of week mismatches: %d' % len(mismatches)

for number in goodweeks:
    print number
