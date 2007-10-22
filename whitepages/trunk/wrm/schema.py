# $Id: schema.py 872 2005-04-28 16:55:54Z wrm2110 $

"""
A Schema defines the field names in a database or
database-like object, optionally associating
field sizes and field types with field names

>>> s = Schema()
>>> s.add('column1')
>>> s.add('column2')
>>> s.add('column3')

>>> s.fields()
('column1', 'column2', 'column3')

>>> s.rules()
(('column1', None), ('column2', None), ('column3', None))

>>> s['column2']
1
>>> s['column9000']
Traceback (most recent call last):
  ...
IndexError: Schema does not contain a field called column9000


get_columns_for_select() should return a string
containing the columns defined in this Schema,
which may be used in a SQL select statement:

>>> s.get_columns_for_select()
'column1, column2, column3'


A FixedWidthSchema represents its fields as
fixed-width pieces of data, so it describes
a fixed-width delimited text file

>>> fws = FixedWidthSchema()
>>> fws.add('blue',(0,10))
>>> fws.add('green',(10,20))
>>> fws.add('yellow',[(20,30),(30,40)])

FixedWidthSchema should have automatically created
two yellow rules (one for each size given)
>>> fws.fields()
('blue', 'green', 'yellow_0', 'yellow_1')

>>> fws.rules()
(('blue', (0, 10)), ('green', (10, 20)), ('yellow_0', (20, 30)), ('yellow_1', (30, 40)))

>>> fws['yellow_0']
2

This schema should not contain a rule for 'yellow',
even though a rule called 'yellow' was added
>>> fws['yellow']
Traceback (most recent call last):
  ...
IndexError: Schema does not contain a field called yellow
"""

class Schema:
    """
    Represents fields internally as
    a list, but deals exclusively in tuples,
    to ensure that the rules are not changed
    outside of itself
    """
    def __init__(self, name=None):
        self.name = name
        self.schema = []

    def add(self, name, size=None):
        self.schema.append((name, size))
    
    def rules(self):
        return tuple(self.schema)
    
    def fields(self):
        return tuple([rule[0] for rule in self.schema])
    
    def get_columns_for_select(self):
        return ', '.join(self.fields())
    
    def __getitem__(self, key):
        """
        Returns the index of the field named %(key)s in
        this schema
        """
        for i in range(len(self.schema)):
            if self.schema[i][0] == key:
                return i
        raise IndexError, "Schema does not contain a field called %s" % key



class FixedWidthSchema(Schema):
    """
    Extends Schema to support fixed-width fields
    by modifying size parameter to expect a tuple
    in the form (startposition, endposition)
    
    Used to describe fixed-width-data files
    """
    def __init__(self, name=None):
        self.name = name
        self.schema = []
    
    def add(self, name, bounds=(0,0)):
        """
        Adds a rule to this Schema.  Expects bounds to
        be a tuple in the form (startposition, endposition)
        or a list of tuples in that form
        
        If bounds is a list, iterates through the list and
        adds rules to this Schema like so:
            
            (name_0, bounds[0])
            (name_1, bounds[1])
            ...
            (name_N, bounds[N])
        
        Useful as a shortcut for defining multiple similar
        fields
        """
        if isinstance(bounds, list):
            for i in range(len(bounds)):
                self.schema.append(("%s_%s" % (name, i), bounds[i]))
        else:
            self.schema.append((name, bounds))

def test():
    import doctest, schema, sys
    return doctest.testmod(schema)

if __name__ == "__main__":
    print "Testing Schema...",
    test()
    print "Successful!"
    