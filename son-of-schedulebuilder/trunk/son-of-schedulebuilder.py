#!/usr/bin/env python

import os, sys

from profiles import profile
import classparser
import xmlbuilder


def main():
    # parse the input file
    classes = classparser.parse_classes()

    # build the XML file with the parsed classes
    xmldoc = xmlbuilder.build(classes)

    if profile.template:
        # get any necessary Saxon parameters
        params = saxon_parameters()

        # transform the XML file
        print 'Building schedule output...'
        cmd = 'java -jar %s -o transform.log %s %s %s' % (profile.saxon_path, profile.output_xml_path, profile.template, params)
        saxonin, saxonout, saxonerr = os.popen3(cmd)

        # report any errors or status messages
        for line in saxonerr:
            print >> sys.stderr, ' ! Error: %s' % line.strip()
        for line in saxonout:
            print ' - Status: %s' % line.strip()

        print 'Finished.'
    else:
        print >> sys.stderr, ' ! Error: No XSL template defined in %s' % profile

def saxon_parameters():
    """Get the Saxon parameters for this build based on the
    current profile."""

    # the output directory
    params = 'output-directory="%s"' % (profile.output_dir)

    # if we're only including classes after a certain date,
    # make this an "Enrolling Now" type schedule
    if profile.include_classes_after:
        params += ' enrolling-now="true"'

    # add any params taken from the profile
    if profile.saxon_params:
        params += ' %s' % profile.saxon_params

    return params

if __name__ == "__main__":
    main()
