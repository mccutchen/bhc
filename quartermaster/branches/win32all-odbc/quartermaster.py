# $Id: quartermaster.py 1666 2005-11-30 16:48:10Z wrm2110 $

import os, sys
import xmlbuilder
from profiles import profile

def main():
    # build the XML file
    xmldoc = xmlbuilder.build()
    
    # transform the XML file
    print 'Transforming XML document...'
    cmd = 'java -jar %s -o transform.log %s %s' % (profile.saxon_path, profile.output_xml_path, profile.template)
    saxonin, saxonout, saxonerr = os.popen3(cmd)
    
    # report any errors or status messages
    for line in saxonerr:
        print >> sys.stderr, ' ! Error: %s' % line.strip()
    for line in saxonout:
        print ' - Status: %s' % line.strip()

    print 'Finished.'
    


if __name__ == '__main__':
    main()