# setup.py
import glob, sys
from distutils.core import setup
import py2exe


# If run without args, build executables, in quiet mode.
if len(sys.argv) == 1:
    sys.argv.append("py2exe")
    sys.argv.append("-q")


# where the support files go
librarypath = 'lib/lib.zip'

# modules to exclude
excludes = 'settings.py setup.py doctest ftplib gopherlib httplib sqlite sqlite.main unittest urllib urllib2 urlparse popen2 ext.IsDOMString ext.SplitQName mxDateTime.__version__'.split()

# modules to explicitly include
includes = 'elementtree.ElementTree cElementTree encodings encodings.*'.split()

# what extra files do we need to use the program?
templates = ('templates', glob.glob('templates/*.xml') + glob.glob('templates/*.xsl') + glob.glob('templates/*.html'))
css = ('templates/css', glob.glob('templates/css/*.css'))
dlls = ('.', ['C:\WINDOWS\system32\msvcr71.dll', 'C:\WINDOWS\system32\msvcp71.dll'])
settings = ('.', 'settings.py'.split())
runtime_data = [templates, css, settings, dlls]

setup(
    name='whitepages',
    version='1.0',
    description='Brookhaven College Intranet staff directory creator',
    author='Will McCutchen',
    author_email='wmccutchen@dcccd.edu',
    
    # py2exe-specific options
    options = {
        "py2exe": {
            "compressed": 1, # create a compressed zip archive
            "optimize": 2, # optimize for speed!
            "excludes": excludes,
            "includes": includes,
            "xref": 0
        }
    },
    console=["whitepages.py"],
    zipfile=librarypath,
    data_files=runtime_data
)