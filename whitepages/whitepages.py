import os, sys
from wrm import xmlutils
from wrm.utils import apdate, copyfiles
import settings, xmlbuilder

def build(xmldoc):
    print 'Building staff directory output...'

    # Set up Saxon parameters
    params = { 'date': apdate() }

    # Run the transformation
    out, err = xmlutils.transform(settings.output_xml_path,
                                  settings.templates_xsl,
                                  settings.saxon_path,
                                  params)

    # Report the results
    for line in out:
        print ' - Status: %s' % line
    for line in err:
        print >> sys.stderr, ' ! Error: %s' % line

    print 'Finished.'


def main():
    xmldoc = xmlbuilder.build()
    build(xmldoc)

    # wait for some input from the user and quit
    raw_input('\nPress return to exit.')
    sys.exit(0)


if __name__ == '__main__':
    main()
