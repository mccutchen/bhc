import re
from schema import schema

"""
Checks to see which classes have the wrong number
of weeks reported by Colleague, and therefore nee
to be refreshed or updated.
"""

begins_date = '08/28/2006'
ends_date = '12/14/2006'
expected_weeks = '16'

fields = map(lambda n, c: '%s_%s' % (n, c), ['comments']*10, range(10))

def extract(data, strip=True):
    results = []
    for field in fields:
        a, b = schema[field]
        results.append(data[a:b])

    # algorithm taken from meta.py lines 452:454
    comments = ' '.join(results) # join fields, leaving a space between each
    comments = re.sub('\s{2,}', ' ', comments) # replace multiple spaces with one space
    comments = re.sub('([a-zA-Z]{1})(- )','\\1', comments) # collapse hyphenated words
    return comments.strip()


"""Split each comment into a course number and base comment, and add
them to a dict keyed on base comment, adding the course number to a
list of course numbers for that comment."""
d = {}
for line in file('../2006-fall/latest.txt'):
    data = extract(line, fields)
    match = re.match(r'^([A-Z]{4} \d{4}[ .\-]\d{4})(.*)$', data)
    if match:
        number, rest = match.groups()
        d.setdefault(rest, list())
        d[rest].append(number)

"""Print each comment that is identical except for the course number."""
for comments, numbers in d.items():
    if len(numbers) > 1:
        print '(%s) %s' % (', '.join(numbers), comments)
