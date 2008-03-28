# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   28 March 2008
# Modified:  28 March 2008

# Synopsis:
# We recently modified how the enrolling section of the online course schedule is handled.
#   Instead of a single enrolling/ directory, we now have enrolling/now/ and enrolling/soon/.
#   In order to change the titles on the pages, we need two sets of web.xsl and
#   web/page-template.xsl - one for enrolling now and one for enrolling soon. Well, they could
#   be combined, but this is easier. This just swaps the two sets out so that it's easy.

# imports
import os;

# main
if (not(os.path.isfile('web.xsl') and os.path.isfile('web/page-template.xsl'))):
    print 'unable to find files to swap';
else:
    if (os.path.isfile('web.now.xsl') and os.path.isfile('web/page-template.now.xsl')):
        os.rename('web.xsl', 'web.soon.xsl');
        os.rename('web/page-template.xsl', 'web/page-template.soon.xsl')
        os.rename('web.now.xsl', 'web.xsl');
        os.rename('web/page-template.now.xsl', 'web/page-template.xsl')
        print 'Enrolling Soon enabled';
    elif (os.path.isfile('web.soon.xsl') and os.path.isfile('web/page-template.soon.xsl')):
        os.rename('web.xsl', 'web.now.xsl');
        os.rename('web/page-template.xsl', 'web/page-template.now.xsl')
        os.rename('web.soon.xsl', 'web.xsl');
        os.rename('web/page-template.soon.xsl', 'web/page-template.xsl')
        print 'Enrolling Soon enabled';
    else:
        print 'Unable to find the files to swap.';


