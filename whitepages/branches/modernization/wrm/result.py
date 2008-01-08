# result.py
# $Id: result.py 521 2005-02-01 18:45:51Z wrm2110 $

def Result(row, schema):
    """Result(row, schema) -> dict

        Returns a dictionary whose keys come from the fields in schema
        and whose data come from the fields in row

        schema should be a wrm.schema.Schema object, and row should be a
        list-like object which matches up to the schema
    """
    return dict(zip(schema.fields(), row))