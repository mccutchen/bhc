"""
Counts the topic codes in a download file.
"""

codes = dict()

for line in file('../latest.txt'):
    code = line[477:482].strip()    
    if code:
        if code not in codes:
            codes[code] = 0
        codes[code] += 1

print 'Topic codes'
print '==========='
for values in codes.items():
    print '%s: %d' % values