import datetime, time
from schema import schema

"""
Checks to see what subjects have self-paced or
flex-entry classes.
"""


classtypes = {}

fields = 'title rubrik number section synonym type'.split()
types = 'SP FD FN'.split()

def extract(data, fields, strip=True):
    results = {}
    for field in fields:
        a, b = schema[field]
        results[field] = data[a:b]
        if strip:
            results[field] = results[field].strip()
    return results

for line in file('../latest.txt'):
    data = extract(line, fields)
    if data['type'] in types:
        title = data['title']
        rubrik = data['rubrik']
        class_number = '%s %s-%s' % (data['rubrik'], data['number'], data['section'])
        synonym = data['synonym']
        classtype = data['type']
        
        if rubrik not in classtypes:
            classtypes[rubrik] = []
        classtypes[rubrik].append((title, class_number, synonym, classtype))

rubriks = classtypes.keys()
rubriks.sort()

for rubrik in rubriks:
    print rubrik