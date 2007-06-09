import atexit
from decorators import cachedmethod

class SimpleDatabaseWrapper:
    """A simple wrapper around a DB-API 2.0 compliant database.  Provides
    SQL logging and a few convenience functions.
    
    Only useful if you're working with one table in one database."""
    def __init__(self, connection, tablename):
        self.connection = connection
        self.cursor = self.connection.cursor()
        self.tablename = tablename
        
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
            yield row
    
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


def AccessTable(path, tablename):
    """Returns a SimpleDatabaseWrapper which wraps the Access database
    found at the given path
        
    Requires either mx.ODBC.Windows module."""
    try:
        # requires mx.ODBC.Windows module
        import mx.ODBC.Windows
        
        # use DSN-less connection string to make connection
        connectionstring = 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=%s' % path
        connection = mx.ODBC.Windows.DriverConnect(connectionstring)
        
        # we only want to get unicode strings from the database, so we hope that
        # its encoding is utf-8 and let the driver do the conversion for us
        connection.encoding = 'utf-8'
        connection.stringformat = mx.ODBC.Windows.NATIVE_UNICODE_STRINGFORMAT
        
        wrapper = SimpleDatabaseWrapper(connection, tablename)  
        atexit.register(close_on_exit, wrapper)
        return wrapper

    except ImportError:
        raise ImportError, "wrappers.AccessTable requires mx.ODBC.Windows module"


def SQLiteTable(path, tablename):
    """Returns a SimpleDatabaseWrapper which wraps the SQLite database
    found at the given path.
    
    Requires sqlite module."""
    try:
        import sqlite
    except ImportError:
        raise ImportError, "Wrappers.SQLiteTable requires sqlite module"
    wrapper = SimpleDatabaseWrapper(sqlite.connect(path), tablename)
    atexit.register(close_on_exit, wrapper)
    return wrapper


def close_on_exit(db):
    """Should be registered as an exit handler and passed a
    SimpleDatabaseWrapper whose connection should be closed."""
    db.close()
