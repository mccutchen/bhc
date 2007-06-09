# utils.py
# $Id: utils.py 2341 2006-10-27 18:03:35Z wrm2110 $

import datetime, glob, os, re, shutil, sys, time
import decorators

def any(sequence, test=lambda x:x):
    for item in iter(sequence):
        if test(item):
            return True
    return False

def every(sequence, test=lambda x:x):
    for item in iter(sequence):
        if not test(item):
            return False
    return True

def files(*paths):
    """Utility for iterating through the lines of multiple
    files as if they were one file.

    Usage:
        for line in files('a.txt', 'b.txt', 'c.txt.'):
            print line
    """
    for path in paths:
        for line in file(path):
            yield line


def unicodeize(data):
    """unicodeize(data) -> unicode string

    Prepares a given object by turning it into a unicode string."""
    if isinstance(data, unicode):
        # if we're already dealing with unicode,
        # just give it back
        return data

    elif isinstance(data, list) or isinstance(data, tuple):
        # if we get a list, return a list
        # of unicode strings
        return map(unicodeize, data)

    elif isinstance(data, dict):
        # if we get a dict, return a new
        # dict whose keys and values
        # are unicode strings
        newdata = dict()
        for k, v in data.items():
            k = unicodeize(k)
            v = unicodeize(v)
            newdata[k] = v
        return newdata

    else:
        # otherwise, just try to make a unicode
        # string out of data
        try:
            if data is None: data = ''
            return unicode(data, 'utf-8')
        except TypeError, e:
            return unicode(data)
        except UnicodeError, e:
            print >> sys.stderr, ' ! unicodeize error: %s' % data
            return unicode(data, 'utf-8', 'replace')


def splits(s, n=1, result=None):
    """Splits a string s into equal parts of length n.  The last item
    in the list returned is the remainder of the string."""
    if result is None:
        result = []
    if len(s) >= n:
        result.append(s[:n])
        return splits(s[n:], n, result)
    if s:
        result.append(s)
    return result


def get_machine_name(name, prefix='', suffix=''):
    """get_machine_name(name) -> string

    Returns a filename-appropriate version of the given name, by
    removing forbidden characters, replacing some characters with
    underscores, and replacing some non-ascii letters with their ascii
    relatives."""
    underscores = r'[ \\/&\-]' # characters to replace with an underscore
    nonascii = [(u'\xf1','n')] # nonascii letters and their ascii counterparts
    blacklist = r'[^A-z0-9_]'  # blacklisted characters

    # make sure we're dealing with a string
    assert isinstance(name, basestring) or name is None

    if name is None:
        return ''

    prefix = prefix or ''
    suffix = suffix or ''

    # normalize the prefix and suffix
    if prefix: prefix = get_machine_name(prefix)
    if suffix: suffix = get_machine_name(suffix)

    name = name.lower()
    name = '%s%s%s' % (prefix, name, suffix)

    # replace non-ascii chars
    for bad, good in nonascii:
        if bad in name:
            name = name.replace(bad, good)

    name = re.sub(underscores, '_', name)
    name = re.sub(blacklist, '', name)
    return name


def apdate(date=datetime.date.today(), include_year=True):
    """Returns the given date as a string formatted in AP
    style.  Defaults to today's date.  By default, the year
    is included in the output, but this can be controlled
    with the include_year argument."""
    months = ('Jan.', 'Feb.', 'March', 'April', 'May', 'June', 'July', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.')
    month = months[date.month-1]
    return include_year and \
        '%s %d, %d' % (month, date.day, date.year) or \
        '%s %d' % (month, date.day)


@decorators.cached
def parsedate(datestring, format='%m/%d/%Y'):
    """Parses a given datestring into a datetime.date object according
    to format"""
    return datetime.date(*time.strptime(datestring.strip(), format)[:3])


def filterdict(d, badkeys):
    """Returns a copy of d with badkeys removed"""
    filtered = {}
    for key in filter(lambda key: key not in badkeys, d):
        filtered[key] = d[key]
    return filtered


def exclude(d, keys=[], values=[]):
    """Returns a copy of d with keys and/or values removed.  E.g.:

    d = dict(a=1,b=2,c=3)
    exclude(d, 'a', 2) -> {'c':3}"""

    # we don't mess with the original
    filtered = dict(d)

    # make sure we have a lists to work with
    if not isinstance(keys, list): keys = [keys]
    if not isinstance(values, list): values = [values]

    # filter based on the values
    for key, value in filtered.items():
        if key in keys or value in values:
            del filtered[key]

    return filtered

def only(d, keys=[], values=[]):
    """Returns a copy of d containing only keys and values (the
    opposite of exclude(), above)."""
    filtered = dict(d)

    if not isinstance(keys, list): keys = [keys]
    if not isinstance(values, list): values = [values]

    for key, value in filtered.items():
        if keys and key not in keys:
            del filtered[key]
        if values and value not in values:
            del filtered[key]

    return filtered


def members(object):
    """Utility function which yields the non-private members of a
    class"""
    return [getattr(object, member) for member in object.__dict__ if not member.startswith('_')]


def copyfiles(sourcedir, destdir, patterns = '*'):
    """Copies files and directories which match pattern from sourcedir
    into destdir, recreating directory structure as necessary.

    `patterns` should be a space-separated list of patterns
    to feed to glob.glob()."""

    if not os.path.isdir(sourcedir):
        raise IOError, 'sourcedir must exist and must be a directory.'

    if not os.path.exists(destdir):
        os.mkdir(destdir)
    else:
        if not os.path.isdir(destdir):
            raise IOError, 'If destdir exists, it must be a directory'

    # remember where we started
    cwd = os.getcwd()

    # get the paths to the files we want to copy
    os.chdir(sourcedir)
    files = []
    for pattern in patterns.split():
        files.extend(glob.glob(pattern))
    os.chdir(cwd)

    # copy the files
    for f in files:
        dest = destdir
        path, name = os.path.split(f)

        # do we need to copy this file to a subdirectory?
        if path:
            # create the subdirectory under destdir to hold the
            # file, if it doesn't exist
            if not os.path.exists(os.path.join(destdir, path)):
                os.chdir(destdir)
                os.makedirs(path)
                os.chdir(cwd)

            # add the subdirectory to the destination path
            dest = os.path.join(destdir, path)

        # add the source directory to the file path
        f = os.path.join(sourcedir, f)

        # copy the file
        shutil.copy2(f, dest)
