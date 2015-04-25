#!/usr/bin/env python

import os, sys

from wrm import xmlutils
from profiles import profile
import classparser
import xmlbuilder


def main():
    # parse the input file
    classes = classparser.parse_classes()

    # build the XML file with the parsed classes
    xmldoc = xmlbuilder.build(classes)

    if profile.template:
        # transform the XML file (this will echo any Saxon output to
        # stderr and stdout)
        xmlutils.transform(profile.output_xml_path, profile.template,
                           profile.saxon_path, profile.saxon_params)

        print 'Finished.'
    else:
        print >> sys.stderr, ' ! Error: No XSL template defined in %s' % profile

if __name__ == "__main__":
    main()
