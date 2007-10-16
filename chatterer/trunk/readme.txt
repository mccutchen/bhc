# Acknowledgements: Will McCutchen wrote the original chatterer. Most of
#   v2.0 is a direct copy-paste from his program. The update was undertaken
#   to improve the user interface rather than the basic operation of the
#   program itself.

To use:
 1. put all of the input files (.txt) into the source/ directory (create it if it does not already exist)
 2. run the chatter_aio_txt-xml.bat
   a. enter date when prompted (or create issue-date.txt in the source/ directory and put the date on first line of the file). Date *must* be in 6-digit or 8-digit format: mmddyy or mmddyyyy.
   b. if you get errors (and you probably will, since the formatting has to be fairly exact), check the chatterer_aio_readme.txt to verify the formatting
   c. repeat steps a and b until you do not get errors
 4. run the chatterer_aio_xml-html.bat to generate the html in the chatterer-output/ directory
 5. copy the contents of the chatterer-output/ directory into the [dev server]:/chatter/[year] directory (ie for my current setup, that is B:/chatter/07/)
 6. add in the pictures and any fancy formatting you like (note: <hr /> is disabled on the bhc web, so use a <div> with a border to acheive the same effect)
 7. do not forget that there are two index.html files (one at [YY]/index.html and one at [YY]/[MMDD]/index.html) These two are NOT the same, but should look the same (the links are all relative, so their positions require different hyperlinks)
 8. Once things look good, send it live (just the [YY]/index.html and [YY]/[MMDD]/). Don't forget to copy the images used in the chatter to [live server]:/images/bhc/chatter/[YY]/[MMDD]/.


Special notes:
- event.txt doesn't have a standard format. There are 6 different tags that the text can be copied into and no real way to distinguish where it's going (well, humans can, but it'd take an awful lot of code to write that kind of pattern recognition). What I've done is made a best-guess kind of function. It'll try to get it into the right type of tag, but it's not perfect. So, just pay extra attention to the events page in the output when verifying that it's live-server worthy :)

- final output is placed in chatter-output directory (created if not already present). Note that the directory with the date (MMDD) needs to be put inside the year directory (YY) before any links will work.


FORMATS:

Announcements
Filename: announcements.txt
Title: <title>\n
Item: <item>\n
End of Item: \n
    # must be a blank line between sections and not between items

Haid and Farewell
Filename: hailfarewell.txt
Section Names: New Hires | Terminations | Changing Roles
Items: <name>, <section>, <title>\n

Birthdays
Filename: <whatever>birthdays.txt
Title: <whatever> Birthdays\n
Item: <Month> <day> - <name>, <name>, ... , <name>\n
    # as many names as you like, comma-seperated & newline-terminated list

Articles
Filename: articles.txt
Titles: <title>/n
    # The titles become the keys for linking the article preview to the full article.
    # They MUST MATCH the title of the individual story files.
Item: <item>\n
    # must be a blank line between sections and not between items

Story
Filename: <unimportant>.txt
Title: <title>\n
    # this title MUST MATCH the title listed in the articles.txt
Item: <item>\n
    # will read 'til end of file, so no rules on this.

Events
 prologue: Ok, events are by far the most difficult to automate. The number of tag types and no clear indication of which to use make for issues. There are two ways around this:
1) just run the chatterer and fix it in html
2) edit the source .txt and add in indicators
   the chatterer will pick up on the following:
      title:
      presenter:
      location:
      date:
      url:
      description:
   if this ends up being useful, additional tag indicators can be added quite easily

That being said, here is the format

Filename: events.txt
-- more to come, later ---