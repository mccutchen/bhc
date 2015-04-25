ScheduleXML Builder
===================

Overview
--------
This is a proof-of-concept project that takes a ScheduleXML file as input and
generates the kinds of course schedule output needed by Brookhaven College.
This is a two stage process:

 1. Preprocessing
 2. Transforming

The input ScheduleXML file is run through a series of XSLT 2.0 preprocessors,
which massage the data into the form we need it in to generate the output we
require. The preprocessing stage is controlled using XProc and XML Calabash
(a Java XProc implementation).

Once the input ScheduleXML file has been preprocessed, it is run through an
XSLT 2.0 transformer to generate the actual schedule output in whatever
format is required. Right now, there are proof-of-concept implementations of
the proof and room-coordinator output formats.  Print and web transformers
still need to be implemented.

Usage
-----
Two shell scripts are provided to run each stage in the building process. The
first, `bin/preprocess`, preprocesses an input ScheduleXML file to generate
an intermediate `schedule.xml`. The second, `bin/build`, first runs the
`preprocess` script, then runs the intermediate `schedule.xml` through a
specific transformer to generate final output.

The two scripts should be called as follows:

    bin/preprocess input.xml

    bin/build input.xml transformer.xsl

If you're just generating a schedule, running `bin/build` should suffice.

Requirements
------------
Two Java libraries are required to run this software:

 1. [XML Calabash](http://xmlcalabash.com/)
 2. [Saxon 9 HE](http://saxon.sourceforge.net/#F9.3HE)