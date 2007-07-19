from wrm.schema import DatabaseSchema
from formatters import CCEFormatter
import db

schema = DatabaseSchema(
    # the formatter to use when extracting the data
    CCEFormatter(),
    
    # the database to which this schema applies
    db.table,
    
    # virtual fields, which are not actually in the database
    # (these will be populated by the CCEFormatter)
    virtual_fields = [
        'textbooks',
        'spanish',
        'evening',
        'time_sortkey',
        'date_sortkey',
    ]
)