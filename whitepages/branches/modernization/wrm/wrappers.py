# wrappers.py
# $Id: wrappers.py 521 2005-02-01 18:45:51Z wrm2110 $

class SimpleDatabaseWrapper:
    """
    A simple wrapper around a DB-API 2.0 compliant
    database.  Provides SQL logging and a few
    convenience functions.
    
    Only useful if you're working with one table
    in one database.
    """
    def __init__(self, connection, schema):
        self.connection = connection
        self.cursor = self.connection.cursor()
        self.schema = schema
        self.tablename = schema.name
        self.columns = None
    
    def execute(self, sql, params = ()):
        """
        execute(sql, [params = ()]) -> None
            
            Takes an SQL statement and runs it
            against the database, inserting parameters,
            if provided.
            
            The SQL statement can have two keywords which
            will be automatically replaced:
                
                $table$ - replaced by actual table name
                
                $columns$ - replaced by a comma-separated
                string of the column names defined by this
                database's schema
        """
        sql = str(sql) # Access odbc driver doesn't accept unicode strings
        sql = sql.replace('$table$', self.tablename)
        sql = sql.replace('$columns$', self.schema.get_columns_for_select())

        # log each SQL statement, if needed
        try:
            msg = sql
            if params: msg += ' -> with params %s' % repr(params)
            #print >> settings.log.sql, msg
        except AttributeError:
            pass
        
        try:
            self.cursor.execute(sql, params)
        except Exception, e:
            print ' ! Database error: %s' % e
            print ' ! Caused by: %s' % sql
            import sys
            sys.exit()
    
    def results(self):
        """
        results() -> generator
            
            Generator function which will iterate over
            the cursor's result set
        """
        while 1:
            row = self.cursor.fetchone()
            if not row: break
            yield row
    
    def get_unique_values(self, column):
        """
        get_unique_values(column) -> tuple of unique values
        
            Returns a tuple containing all of the unique
            values in the specified column of the database
        """
        sql = 'select distinct %s from $table$' % column
        self.execute(sql)
        return tuple([row[0] for row in self.results()])

    def get_columns(self):
        """
        get_columns() -> tuple of column names
        
            Returns a tuple containing the names of
            the columns found in the underlying database
        """
        if self.columns is None:
            sql = 'select * from $table$'
            self.execute(sql)
            self.columns = tuple([column[0] for column in self.cursor.description])
        return self.columns
    
    def all(self):
        self.execute('select $columns$ from $table$')
        return self.results()
    
    def commit(self):
        """
        commit() -> None
        
            Commits any pending operations to
            the underlying database
        """ 
        self.connection.commit()
    
    def close(self):
        """
        close() -> None
        
            Closes connection to underlying
            database, committing any pending
            changes in the process
        """
        self.commit()
        self.cursor.close()
        self.connection.close()


def AccessTable(path, schema):
    """
    AccessTable(path, schema) -> SimpleDatabaseWrapper
    
        Returns a SimpleDatabaseWrapper which
        wraps the Access database found at the
        given path
        
        Requires either mx.ODBC.Windows module or
        win32 dbi and odbc modules.  Prefers mx
        over win32.
    """
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
        
        return SimpleDatabaseWrapper(connection, schema)

    except ImportError:
        raise ImportError, "wrappers.AccessTable requires mx.ODBC.Windows module"


def SQLiteTable(path, schema):
    """
    SQLiteTable(path, schema) -> SimpleDatabaseWrapper
    
        Returns a SimpleDatabaseWrapper which wraps
        the SQLite database found at the given path.
        
        Requires sqlite module.
    """
    try:
        import sqlite
    except ImportError:
        raise ImportError, "Wrappers.SQLiteTable requires sqlite module"
    return SimpleDatabaseWrapper(sqlite.connect(path),schema)