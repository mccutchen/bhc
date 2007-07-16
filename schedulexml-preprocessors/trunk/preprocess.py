#!/usr/bin/env python
import os, shutil, sys

# ===================================================================
# Settings
# ===================================================================

# Where are the preprocessors located (no trailing slash)
PREPROCESSOR_PATH = "preprocessors"

# Where to find the list of preprocessors to run (this should be a
# file with one preprocessor name per line)
PREPROCESSOR_ORDER = "%s/ORDER.txt" % PREPROCESSOR_PATH

# Where is Saxon located?
SAXON_PATH = os.name == 'posix' and "~/src/saxon/saxon8.jar" or "C:/saxon/saxon8.jar"

# Where should the output go?
SCHEDULE_FILE = "schedule.xml"

# Where is Rik's input file?
INPUT_PATH = "input/schedule-200-2007SP.xml"


# ===================================================================
# Run
# ===================================================================
print "Preprocessing Rik's ScheduleXML...\n"

# First, copy Rik's original schedule to a new location
print "Copying input..."
shutil.copy(INPUT_PATH, SCHEDULE_FILE)
print

# Loop through each of the preprocessors defined in the file found
# at $PREPROCESSOR_ORDER
print "Running preprocessors..."
for p in file(PREPROCESSOR_ORDER):
    p = p.strip()
    print " - %s.xsl" % p
    #cmd = 'java -jar $SAXON_PATH -o $SCHEDULE_FILE $SCHEDULE_FILE $PREPROCESSOR_PATH/$p.xsl'
    cmd = 'java -jar %s -o %s %s %s/%s.xsl' % (SAXON_PATH, SCHEDULE_FILE, SCHEDULE_FILE, PREPROCESSOR_PATH, p)
    os.system(cmd)
print "Finished.\n"

print "Testing..."
import test
if test.test(INPUT_PATH, SCHEDULE_FILE):
    print "Passed!"