import re, sys, glob

"""Looks at the data in the file named by inpath,
which should be a Quark XPress Tags file, and extracts
all the tags."""

data_dir = 'xtag-extractor data/';
data_files = glob.glob(data_dir + '*.txt');
out_file = 'xtag report.txt';

paragraph_pattern = r'@([A-z ]+):';
inline_pattern = r'<@([A-z ]+)>';

paragraph_styles = [];
inline_styles = [];

for inpath in data_files:
    input = file(inpath).read();

    # find paragraph styles
    for match in re.finditer(paragraph_pattern, input):
        style = match.group(1);
        if style not in paragraph_styles:
            paragraph_styles.append(style);

    # find inline styles
    for match in re.finditer(inline_pattern, input):
        style = match.group(1);
        if style not in inline_styles:
            inline_styles.append(style);

paragraph_styles.sort();
inline_styles.sort();

fout = file(out_file, 'w');

print >> fout, "Paragraph styles:";
for style in paragraph_styles:
    print >> fout, style;


print >> fout, "\nInline styles:";
for style in inline_styles:
    print >> fout, style;
