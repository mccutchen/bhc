import string
import wrm.formatter, wrm.schema, wrm.parser, wrm.wrappers
import settings

class Formatter(wrm.formatter.Formatter):
    
    def default_formatter(self, data):
        if isinstance(data, basestring):
            return data.strip()
        return data
    
    def format_PhotoPath(self, data):
        if isinstance(data, basestring):
            return settings.portraits.location + data.strip()
        return None
    
    def format_Room(self, data):
        try:
            data = data.strip()
            if data[0] in string.letters and data[1] in string.digits:
                return 'Room %s' % data
        except: pass
        return data

def Schema():
    schema = wrm.schema.Schema(settings.database.tablename)
    fields = 'LastName FirstName Extension Room Division Title EmailNickname PhotoPath'.split()
    map(schema.add, fields)
    return schema

def Parser(schema, formatter):
    return wrm.parser.DatabaseParser(schema, formatter)

def Table(dbpath, schema):
    return wrm.wrappers.AccessTable(dbpath, schema)


######################################################
# Create re-usable references to each of the objects #
# provided by this module                            #
######################################################
formatter = Formatter()
schema = Schema()
parser = Parser(schema, formatter)
table = Table(settings.database.path, schema)