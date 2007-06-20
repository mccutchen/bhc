import atexit
from decorators import cachedmethod

class SimpleDatabaseWrapper:
    """A simple wrapper around a DB-API 2.0 compliant database.  Provides
    SQL logging and a few convenience functions.
    
    Only useful if you're working with one table in one database."""
    def __init__(self, connection, tablename, encoding=None):
        self.connection = connection
        self.cursor = self.connection.cursor()
        self.tablename = tablename
        self.encoding = encoding
        
        # autodiscover the columns in this table
        self.columns = self.get_columns()
    
    def execute(self, sql, params = ()):
        """Takes an SQL statement and runs it against the database, inserting
        parameters, if provided.
            
        The SQL statement can have two keywords which will be
        automatically replaced:
                
            $table$ - replaced by actual table name
                
            $columns$ - replaced by a comma-separated string of the
            column names in this table."""
        
        # keywords to replace and their replacement values
        keywords = {
            'table': self.tablename,
            'columns': self.get_columns_for_select(),
        }
        
        # Access odbc driver doesn't accept unicode strings
        sql = str(sql)
        
        # Replace any keywords in the SQL
        for kwd, replacement in keywords.items():
            sql = sql.replace('$%s$' % kwd, replacement)
        
        try:
            self.cursor.execute(sql, params)
        except Exception, e:
            print ' ! Database error: %s' % e
            print ' ! Caused by: %s' % sql
            import sys
            sys.exit()
    
    def results(self):
        """Generator function which will iterate over the cursor's result
        set."""
        while 1:
            row = self.cursor.fetchone()
            if not row: break
            yield self.decode_row(row)
    
    def decode_row(self, row):
        """Should be overridden by inheriting classes to provide db-specific
        decoding behavior."""
        return row
    
    def get_unique_values(self, column):
        """Returns a tuple containing all of the unique values in the
        specified column of the database"""
        sql = 'select distinct %s from $table$' % column
        self.execute(sql)
        return tuple([row[0] for row in self.results()])
    
    @cachedmethod
    def get_columns(self):
        """Returns a tuple of the column names found in the underlying
        table."""
        sql = 'select * from %s' % self.tablename
        self.cursor.execute(sql)
        columns = tuple([column[0] for column in self.cursor.description])
        return columns
    
    def get_columns_for_select(self):
        """Convenience function which returns a SQL-ready list of the column
        names."""
        return ', '.join(self.columns)
    
    def all(self):
        self.execute('select $columns$ from $table$')
        return self.results()
    
    def commit(self):
        """Commits any pending operations to the underlying database""" 
        self.connection.commit()
    
    def close(self):
        """Closes the connection to the underlying database, committing any
        pending changes in the process"""
        self.commit()
        self.cursor.close()
        self.connection.close()


def AccessTable(path, tablename, encoding=None):
    """Returns a SimpleDatabaseWrapper which wraps the Access database
    found at the given path."""
    import pyodbc
        
    # use DSN-less connection string to make connection
    connectionstring = 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=%s' % path
    connection = pyodbc.connect(connectionstring)
    
    wrapper = SimpleDatabaseWrapper(connection, tablename, encoding)  
    atexit.register(close_on_exit, wrapper)
    
    # add in pyodbc-specific decode_row method
    self = wrapper
    def decode_row(row):
        """If self.encoding is not None, decodes any string objects found
        in the given row into unicode objects according to self.encoding."""
        if not self.encoding:
            return row
        for i, value in enumerate(row):
            if isinstance(value, str):
                row[i] = value.decode(self.encoding)
        return row
    wrapper.decode_row = decode_row
    
    return wrapper


def SQLiteTable(path, tablename, encoding=None):
    """Returns a SimpleDatabaseWrapper which wraps the SQLite database
    found at the given path."""
    import sqlite
    wrapper = SimpleDatabaseWrapper(sqlite.connect(path), tablename, encoding)
    atexit.register(close_on_exit, wrapper)
    return wrapper


def close_on_exit(db):
    """Should be registered as an exit handler and passed a
    SimpleDatabaseWrapper whose connection should be closed."""
    db.close()
