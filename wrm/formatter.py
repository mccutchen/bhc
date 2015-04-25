import re
from decorators import cached

class Formatter(object):
    """A Formatter takes a dict as input and returns a new dict as output
    after "formatting" or processing each of the values in the input dict.
    By default, the values are returned unchanged, but Formatters can be
    subclassed to provide custom formatting methods for individual fields.
    
    This input will be used in all of the following examples.  Note that the
    'age' field is a string, not an int.
    
    >>> input = dict(name='Will', age='25', sex='Male')
    >>> input
    {'age': '25', 'name': 'Will', 'sex': 'Male'}
    
    An instance of the Formatter base class will return an identical dict.
    
    >>> formatter = Formatter()
    >>> formatter.format(input)
    {'age': '25', 'name': 'Will', 'sex': 'Male'}
    
    The result is equivalent, but it is a fresh dict.
    
    >>> formatter.format(input) == input
    True
    >>> formatter.format(input) is input
    False
    

    Sublcasses of Formatter can define specialized methods to format
    individual fields.  This custom Formatter should return an int for the
    age and just the first letter of the sex in the input dict.
    
    >>> class PersonFormatter(Formatter):
    ...     def format_age(self, data):
    ...         return int(data)
    ...     def format_sex(self, data):
    ...         return data[0]

    >>> person_formatter = PersonFormatter()
    >>> person_formatter.format(input)
    {'age': 25, 'name': 'Will', 'sex': 'M'}
    
    
    The input dict given to a Formatter is cached in the instance variable
    'input', so it is available to all of the formatting functions.  Thus,
    the formatting functions can change their behavior based on other values
    in the input.  This formatter should add some text to the 'name' if the
    given 'sex' is 'Male'.
    
    >>> class NameChangeFormatter(Formatter):
    ...     def format_name(self, data):
    ...         if self.input['sex'] == 'Male':    
    ...             return data + ' the Man' 
    ...         else:
    ...             return data
    
    >>> name_changer = NameChangeFormatter()
    >>> name_changer.format(input)
    {'age': '25', 'name': 'Will the Man', 'sex': 'Male'}
    """

    def __init__(self):
        self.input = None

    @cached
    def __get_format_func(self, field):
        return 'format_%s' % field.replace('-', '_')
    
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
        
        # reset self.input for the next go-round
        self.input = None

        return results

    def default_formatter(self, value):
        """By default, return the input value unchanged."""
        return value

    def post_formatter(self, value):
        """By default, return the input value unchanged."""
        return value


if __name__ == '__main__':
    import doctest
    failures, tests = doctest.testmod()
    if failures is 0:
        print 'All tests passed.'