import re
from formatter import Formatter
from wrappers import SimpleDatabaseWrapper


class SchemaError(Exception):
    pass


class Schema:
    """Defines a set of fields to be extracted.  If a Formatter is
    given, that formatter will be used to format the fields at
    extraction time."""

    def __init__(self, formatter, *fields):
        """Takes any number of fields as arguments, ensures that they
        are all valid fields and adds them to an internal dictionary."""
        assert isinstance(formatter, Formatter) or formatter is None

        # ensure that each of the given fields is valid
        Schema.validate_fields(fields)

        self.formatter = formatter
        self.fields = fields

    def extract(self, data):
        """Extracts field values from the given data and returns them
        in a dict keyed on field name."""
        results = {}
        for field in self.fields:
            results[field.name] = field.extract(data)

        if self.formatter:
            results = self.formatter.format(results)

        return results

    def __repr__(self):
        return '{Schema (%d fields)}' % len(self.fields)

    @classmethod
    def validate_fields(self, fields):
        """Ensures that each of the given fields is an instance of the
        BaseField class.  Raises a SchemaError if this is not the
        case."""
        for field in fields:
            if not isinstance(field, BaseField):
                raise SchemaError, "The given field (%s) is not a valid Field." % repr(field)
        return True


class DatabaseSchema(Schema):
    """Defines a set of fields to be extracted from a database.  The fields
    in the database are automatically discovered."""
    
    def __init__(self, formatter, db, virtual_fields=[]):
        assert isinstance(formatter, Formatter) or formatter is None
        assert isinstance(db, SimpleDatabaseWrapper)
        
        self.formatter = formatter
        self.db = db
        self.fields = db.get_columns()
        
        # ensure that virtual field names don't clash with fields in the
        # database
        for vf in virtual_fields:
            if vf in self.fields:
                raise SchemaError, 'Virtual field %s clashes with a preexisting field in the database.' % vf
        self.virtual_fields = virtual_fields
    
    def extract(self, row):
        assert len(self.fields) == len(row)
        
        # combine the given row with its field names
        results = dict(zip(self.fields, row))
        
        # manually add empty strings for the virtual fields
        for vf in self.virtual_fields:
            results[vf] = ''
        
        # format the fields
        if self.formatter:
            results = self.formatter.format(results)

        return results
        
    

class BaseField:
    """A base class to represent all the various field types.  All
    field classes must implement one method: extract()."""
    def extract(self, data):
        raise SchemaError, "Abstract method extract() not implemented in BaseField."


class Field(BaseField):
    """A basic field, defined by a start index and an end index.
    Returns a stripped string."""

    def __init__(self, name, start, end):
        self.name = name
        self.start = start
        self.end = end

    def extract(self, data):
        return data[self.start:self.end].strip()

    def __repr__(self):
        return '<%s (%d, %d)>' % (self.name, self.start, self.end)


class AnonymousField(Field):
    """A field defined by a start index and an end index, but which
    has no name.  Commonly used in FieldSets."""

    def __init__(self, start, end):
        """Initialize a Field with a name of 'AnonymousField'"""
        Field.__init__(self, 'AnonymousField', start, end)


class SchemaField(BaseField):
    """A field that contains subfields which are defined by the given
    schema.  The field positions in the given schema are relative to
    the section of the input data between the given start and end
    indexes.  The given schema is used to extract the individual
    subfields."""

    def __init__(self, name, start, end, schema):
        """Initializes a SchemaField where start and end define the
        area of the input data to pass on to the given schema, which
        will then extract its defined subfields."""
        assert isinstance(schema, Schema)
        self.name = name
        self.start = start
        self.end = end
        self.schema = schema

    def extract(self, data):
        """Delegates to this field's associated schema to do the
        actual extraction."""
        return self.schema.extract(data[self.start:self.end])


class DumbSchemaField(SchemaField):
    """A schema field whose field positions are given in terms of the
    original data, rather than as a specific subset (as is the case
    with the base SchemaField, which is how it should work).

    This is dumb and I don't like it."""

    def __init__(self, name, schema):
        assert isinstance(schema, Schema)
        self.name = name
        self.schema = schema

    def extract(self, data):
        return self.schema.extract(data)


class FieldSet(BaseField):
    """A field comprised of subfields.  Returns a list.  By default,
    any elements of the resulting list which are false according to
    FieldSet.collapse_func() are omitted."""

    # by default, collapse any empty fields
    collapse = True

    def __init__(self, name, *fields, **kwds):
        Schema.validate_fields(fields)
        self.name = name
        self.fields = fields
        self.collapse = kwds.get('collapse', self.collapse)

    def extract(self, data):
        """Delegates to each subfield to do the actual extraction,
        adding each result to a list."""
        results = [field.extract(data) for field in self.fields]
        if self.collapse:
            # remove any elements that are False according to collaspe_func
            results = [result for result in results if FieldSet.not_empty_field(result)]
        return results

    @classmethod
    def not_empty_field(self, data):
        """Tests whether or not the given data is 'empty.'  If the
        given data is a dict, it is empty if none of its values acts
        as True."""
        if isinstance(data, dict):
            for value in data.values():
                if value:
                    return True
            return False
        else:
            return data and True or False


class VirtualField(BaseField):
    """A field whose data is not available at extraction time.  Always
    returns the empty string."""
    def __init__(self, name):
        self.name = name
    def extract(self, data):
        return ''
