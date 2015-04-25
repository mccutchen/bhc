from schema import schema

"""
Checks to see which classes are < 15 weeks long but
not marked as "Flex" classes in Colleague.
"""

inpath = '../2006-fall/latest.txt'
week_threshold = 15
flex_types = ('FD', 'FN')

fields = 'title rubrik number section synonym weeks type'.split()

def extract(data, strip=True):
    results = {}
    for field in fields:
        a, b = schema[field]
        results[field] = data[a:b]
        if strip:
            results[field] = results[field].strip()
    return results


shortnotflex = []
toolongflex = []
for line in file(inpath):
    data = extract(line, fields)
    try:
        weeks = int(data['weeks'])
        if weeks < week_threshold and data['type'] not in flex_types:
            shortnotflex.append(data)
        elif data['type'] in flex_types and weeks >= week_threshold:
            toolongflex.append(data)
    except ValueError:
        print 'Bad weeks: %(rubrik)s %(number)s-%(section)s (%(weeks)s)' % data
print
print

print 'Probably should be flex'
print 'Class number\tType\tWeeks\tTitle'
for clss in sorted(shortnotflex, key=lambda d: '%(rubrik)s %(number)s-%(section)s' % d):
    print '%(rubrik)s %(number)s-%(section)s\t%(type)s\t%(weeks)s\t%(title)s' % clss

print
print

print 'Maybe should not be flex'
print 'Class number\tType\tWeeks\tTitle'
for clss in sorted(toolongflex, key=lambda d: '%(rubrik)s %(number)s-%(section)s' % d):
    print '%(rubrik)s %(number)s-%(section)s\t%(type)s\t%(weeks)s\t%(title)s' % clss
