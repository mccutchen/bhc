# $Id: decorators.py 2132 2006-07-19 21:22:01Z wrm2110 $

import sys, types

def trace(f):
    """Decorator which prints the values and types of the arguments
    passed to the function, as well as the value and type it returns"""
    def tracedfunc(*args, **kwds):
        name = f.func_name
        argstring = ', '.join(map(lambda x: '%s %s' % (x, type(x)), args))
        print >> sys.stderr, '%s(%s)' % (name, argstring)
        result = f(*args, **kwds)
        print >> sys.stderr, 'returned', result, type(result)
        return result
    return tracedfunc



def hashargs(*args, **kwds):
    """The hash function used by the cached and cachedmethod
    decorators.  TODO: This could be dramatically improved."""
    return str(args) + str(kwds)

class cached:
    """Memoization decorator.  Caches the return value of the given
    function with specific arguments and uses that value on subsequent
    calls."""
    def __init__(self, func):
        self.cache = {}
        self.func = func

    def __call__(self, *args, **kwds):
        key = hashargs(*args, **kwds)
        if key not in self.cache:
            self.cache[key] = self.func(*args, **kwds)
        return self.cache[key]

def cachedmethod(function):
    """Memoizes a class method, using the same rules as the cached
    decorator defined above. From the comments on
    http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/325205"""
    class MemoizedMethod(object):
        def __init__(self, func):
            self.cache = {}
            self.func = func
        def __get__(self, instance, cls=None):
            self.instance = instance
            return self
        def __call__(self, *args, **kwds):
            key = hashargs(*args, **kwds)
            if not self.cache.has_key(key):
                self.cache[key] = self.func(self.instance, *args, **kwds)
            return self.cache[key]
    return MemoizedMethod(function)



class excepting:
    """Decorator which will catch the given exception and
    automatically return a default value.

    The given default can be a value or a function.
    If it's a value, it will be returned if the given
    exception is caught.

    If it's a function, it will be called with the
    same arguments as the original function, and
    its return value will be returned.

    Example usage:
        @excepting(AttributeError, '')
        def safestrip(s):
            return s.strip()

    In the above example, if s is not a string (which
    would cause an AttributeError to be raised), a
    blank string will be returned."""

    def __init__(self, exception, default):
        self.exception = exception
        self.default = default
    def __call__(self, func):
        def decorated_excepting(*args, **kwds):
            try:
                return func(*args, **kwds)
            except self.exception:
                if callable(self.default):
                    return self.default(*args, **kwds)
                return self.default
            except Exception, e:
                raise Exception, e
        return decorated_excepting


################################
# String formatting decorators #
################################
def stripped(func):
    """Ensures that the return value of func has all leading and
    trailing whitespace stripped. Assumes func will return a string."""
    def decorated_stripped(*args, **kwds):
        result = func(*args, **kwds)
        return result.strip()
    return decorated_stripped

def uppercased(func):
    """Ensures that the return value of func is made all uppercase.
    Assumes func will return a string."""
    def decorated_uppercased(*args, **kwds):
        result = func(*args, **kwds)
        return result.upper()
    return decorated_uppercased
