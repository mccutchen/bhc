import re
from decorators import cachedmethod

class Formatter:
    """A data formatter that operates on dicts.  Each value in the
    input dict is formatted according to the format function defined
    by the results of __get_format_func(key).  If no format function
    is found, the default_formatter() function is used."""

    def __init__(self):
        self.input = None
        self.re_dash = re.compile('-')
        self.re_underscore = '_'

    @cachedmethod
    def __get_format_func(self, field):
        return 'format_%s' % re.sub(self.re_dash, self.re_underscore, field)

    def format(self, input):
        """Formats the given input according to the formatting
        function defined in this instance.  Stores the original input
        value in self.input, which the formatting functions may
        access.  Accepts and returns a dict."""

        assert isinstance(input, dict)

        # cache the input for use by the formatting functions
        self.input = input

        # format each field
        results = {}
        for field, value in input.items():
            func = getattr(self, self.__get_format_func(field), self.default_formatter)
            results[field] = self.post_formatter(func(value))
            
            # if 'division' in field:
                # print 'Formatted %s field:' % field
                #                 print 'Input:  %s (%s)' % (value, type(value))
                #                 print 'Output: %s (%s)' % (results[field], type(results[field]))
                #                 #print 'XXX:    %s (%s)' % (func(value), type(func(value)))
                #                 print

        # reset self.input for the next go-round
        self.input = None

        return results

    def default_formatter(self, value):
        """By default, return the input value unchanged."""
        return value

    def post_formatter(self, value):
        """By default, return the input value unchanged."""
        return value
