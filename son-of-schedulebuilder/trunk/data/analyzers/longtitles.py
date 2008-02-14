import datetime, time
from schema import schema

"""
Checks to see how many classes have titles longer
than 27 characters, which can cause them to break
the layout in Quark.
"""

longtitles = {}

fields = 'title rubrik number section synonym topic_code'.split()


def extract(data, fields, strip=True):
    results = {}
    for field in fields:
        a, b = schema[field]
        results[field] = data[a:b]
        if strip:
            results[field] = results[field].strip()
    return results

for line in file('../2008-spring/BH2008SP.TXT'):
    data = extract(line, fields)
    if data['topic_code'] not in ('XX', 'YY'):
        if len(data['title']) > 27:
            title = data['title']
            length = len(title)
            class_number = '%s %s-%s' % (data['rubrik'], data['number'], data['section'])
            synonym = data['synonym']

            if length not in longtitles:
                longtitles[length] = {}

            if title not in longtitles[length]:
                longtitles[length][title] = []

            longtitles[length][title].append((class_number, synonym))
    elif len(data['title']) > 27:
        print 'Suppressed: %s (%d) (%s)' % (data['title'], len(data['title']), data['synonym'])

print
print

for length, titles in longtitles.items():
    headline = '%d-character titles: %d' % (length, len(titles))
    print headline
    print '=' * len(headline)

    titlelist = titles.keys()
    titlelist.sort()

    for title in titlelist:
        numbers = titles[title]
        numbers.sort(lambda a,b: cmp(a[0],b[0]))

        print title
        for number in numbers:
            print '    %s (%s)' % number
        print
    print
    print
