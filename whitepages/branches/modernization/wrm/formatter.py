# formatter.py
# $Id: formatter.py 871 2005-04-28 16:55:44Z wrm2110 $

class Formatter:
    """
    Used by Parsers to format the data in
    each parsed field
    
    Subclasses can implement custom formatting for
    specific fields by inheriting this class and
    defining format_<name> functions, which
    will be called automatically at parse time
    """
    
    # keep track of formatted fields
    cache = dict()
    results = dict()

    def format(self, name, data):
        """
        format(name, data) -> string

        Returns a string that is data after
        being processed by the default formatter
        and any custom formatters which have
        been defined
        """
        self.cache[name] = self.default_formatter(data)
        func =  getattr(self, 'format_%s' % name, self.default_formatter)
        self.results[name] = func(data)
        return self.results[name]
    
    def default_formatter(self, data):
        """
        default_formatter(data) -> object
        
        Returns data unchanged.
        """
        return data