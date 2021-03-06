import os, sys
from wrm import xmlutils
from wrm.utils import apdate, copyfiles
import settings, xmlbuilder

def build(xmldoc):
    print 'Building staff directory output...'
    
    # Set up Saxon parameters
    params = { 'date': apdate() }
    
    # Run the transformation (which will print any messages from Saxon
    # to stdout and stderr)
    xmlutils.transform(settings.output_xml_path, settings.templates_xsl,
                       settings.saxon_path, params)
        
    print 'Finished.'


def main():
    xmldoc = xmlbuilder.build()
    build(xmldoc)


if __name__ == '__main__':
    main()