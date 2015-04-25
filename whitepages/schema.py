from wrm.schema import DatabaseSchema
from formatters import WhitePagesFormatter
import db

schema = DatabaseSchema(
    # the formatter to use when extracting the data
    WhitePagesFormatter(),
    
    # the database to which this schema applies
    db.table
)