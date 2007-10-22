# utils.py
# $Id: utils.py 930 2005-05-12 22:27:48Z wrm2110 $

import datetime, glob, os, re, shutil, sys, time
import decorators

def unicodeize(data):
    """
    unicodeize(data) -> unicode string
    
    Prepares a given object by turning it into
    a unicode string.
    """
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
    """
    Splits a string s into equal parts of
    length n.  The last item in the list
    returned is the remainder of the string.
    """
    if result is None:
        result = []
    if len(s) >= n:
        result.append(s[:n])
        return splits(s[n:], n, result)
    if s:
        result.append(s)
    return result


def get_machine_name(name, prefix='', suffix=''):
    """
    get_machine_name(name) -> string
    
    Returns a filename-appropriate version of
    the given name, by removing forbidden
    characters, replacing some characters with
    underscores, and replacing some non-ascii
    letters with their ascii relatives
    """
    forbidden = """:'","""
    underscores = """ /\&""" # characters to replace with an underscore
    foreign = [(u'\xf1','n')] # foreign letters and their ascii counterparts
    
    # make sure we're dealing with a string
    if not isinstance(name, basestring):
        name = str(name)
    
    if prefix is None:
        prefix = ''
    if prefix is None:
        prefix = ''

    if prefix:
        prefix = get_machine_name(prefix)
    if suffix:
        suffix = get_machine_name(suffix)
    
    name = name.lower()
    name = '%s%s%s' % (prefix, name, suffix)
    for bad, good in foreign:
        if bad in name:
            name = name.replace(bad, good)
    name = re.sub('[%s]' % underscores, '_', name)
    name = re.sub('[%s]' % forbidden, '', name)
    return name


def apdate():
    """
    apdate() -> string
    
    Returns today's date as an appropriately-
    formatted date
    """
    format = '%b. $day, %Y'
    today = time.localtime()
    return time.strftime(format, today).replace('$day', str(today[2]))


def parsedate(datestring, format='%m/%d/%Y'):
    """
    pares_date(datestring[, format]) -> datetime.date
    
    Parses a given datestring into a datetime.date object
    according to format
    """
    return datetime.date(*time.strptime(datestring.strip(), format)[:3])


def filterdict(d, badkeys):
    """
    filterdict(d, badkeys) -> dict
    
    Returns a copy of d with badkeys
    removed
    """
    filtered = {}
    for key in filter(lambda key: key not in badkeys, d):
        filtered[key] = d[key]
    return filtered


def exclude(d, keys=[], values=[]):
    """
    exclude(d[,keys[, values]]) -> dict
    
    Returns a copy of d with keys and/or
    values removed
    
    E.g.:
    d = dict(a=1,b=2,c=3)
    exclude(d, 'a', 2) -> {'c':3}
    """
    
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
    """
    only(d[, keys[, values]]) -> dict
    
    Returns a copy of d containing only keys
    and values (the opposite of exclude() above)
    """
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
    """Utility function which yields the non-private members of a class"""
    return [getattr(object, member) for member in object.__dict__ if not member.startswith('_')]
    

def copyfiles(sourcedir, destdir, patterns = '*'):
    """
    Copies files and directories which match pattern
    from sourcedir into destdir, recreating directory
    structure as necessary.

    patterns should be a space-separated list of patterns
    to feed to glob.glob()
    """
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