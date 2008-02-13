import re, sys

"""Looks at the data in the file named by inpath,
which should be a Quark XPress Tags file, and extracts
all the tags."""

inpath = 'fall.txt'
input = file(inpath).read()

patterns = [
    # paragraph styles
    r'@([A-z ]+):',

    # character styles
    r'<@([A-z ]+)>',
]

styles = []
for pattern in patterns:
    for match in re.finditer(pattern, input):
        style = match.group(1)
        if style not in styles:
            styles.append(style)

styles.sort()
for style in styles:
    print style
