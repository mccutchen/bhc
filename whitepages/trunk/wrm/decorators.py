# $Id: decorators.py 832 2005-04-25 15:34:42Z wrm2110 $

import sys

def trace(f):
    """
    Decorator which prints the values and types
    of the arguments passed to the function, as
    well as the value and type it returns
    """
    def tracedfunc(*args, **kwds):
        name = f.func_name
        argstring = ', '.join(map(lambda x: '%s %s' % (x, type(x)), args))
        print >> sys.stderr, '%s(%s)' % (name, argstring)
        result = f(*args, **kwds)
        print >> sys.stderr, 'returned', result, type(result)
        return result
    return tracedfunc

class cached:
    """
    Decorator which caches the return value of
    func
    """
    def __init__(self, func):
        self.cache = dict()
        self.func = func
    
    def __call__(self, *args, **kwds):
        # TODO: improve hash function
        key = str(args) + str(kwds)
        
        if key not in self.cache:
            self.cache[key] = self.func(*args, **kwds)

        return self.cache[key]