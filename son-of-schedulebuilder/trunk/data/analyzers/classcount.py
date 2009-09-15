from schema import schema

skip_codes = 'XX YY'.split()

count = 0
skipped = 0
for line in file('ToAnalyze/BH2010SP.TXT'):
    a, b = schema['topic_code']
    code = line[a:b].strip()
    if code in skip_codes:
        skipped += 1
    else:
        count += 1

print '%d classes (%d skipped)' % (count, skipped)
