import os, sys

from wrm import xmlutils
import xmlbuilder
from profiles import profile

def main():
    # build the XML file
    xmldoc = xmlbuilder.build()
    
    # transform the XML file
    print 'Generating Quartermaster output...'
    xmlutils.transform(profile.output_xml_path, profile.template,
                       profile.saxon_path)
    
    print 'Finished.'
    

if __name__ == '__main__':
    main()