# parser.py
# $Id: parser.py 521 2005-02-01 18:45:51Z wrm2110 $

import re, types
import formatter, schema

class ParserError(Exception):
    """
    Dummy class used to raise errors
    encountered during parsing
    """
    pass


class Parser:
    """
    Abstract class defining a parser which
    uses a Schema and a Formatter to parse
    data one line at a time
    """
    def __init__(self, schema, formatter=formatter.Formatter()):
        self.schema = schema
        self.formatter = formatter
    
    def parse(self, data):
        raise ParserError, "Parser.parse(): Abstract method not implemented"


class FixedWidthParser(Parser):
    """
    Parser subclass which parses lines of
    fixed-width data
    """
    def parse(self, line):
        results = dict()
        for name, bounds in self.schema.rules():
            data = line[bounds[0]:bounds[1]]
            data = self.formatter.format(name, data)
            results[name] = data
        return results


class DatabaseParser(Parser):
    """
    Parses rows of results from database queries
    according to a schema and an optional formatter
    """
    def parse(self, row):
        results = dict()
        fields = self.schema.fields()
        for name, data in zip(fields, row):
            data = self.formatter.format(name, data)
            results[name] = data
        return results


if __name__ == "__main__":
    data = "1234567890     "
    schema = schema.Schema()
    schema.add('a',(0,3))
    schema.add('b',(3,6))
    schema.add('c',(6,20))

    fwp = FixedWidthParser(schema)
    print "Data:"
    print fwp.parse(data)
    
    data = ('big','fat','red')
    dbp = DatabaseParser(schema)
    print "Data (parsed from database row):"
    print dbp.parse(data)
    
    