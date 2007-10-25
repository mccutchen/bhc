// Author:   Travis Haapala
// Email:    thaapala@dcccd.edu
// Phone:    972-860-4104
// Division: MPI
// Date:     Aug. 28, 2007
// Modified: Aug. 30, 2007
// Required: Import Namespace="System.Data"
//           Import Namespace="Finisar.SQLite"

/* Description
The purpose of this lib is to facilitate SQLite interactions.
I've tried to make sure that everything is completely safe, but of course sometimes 
   an exception will get through or a user will accidentally delete their database, 
   so take care anyway.
*/

// some globals
bool    SQLite_debug = false;  // set to true in your app if you want debug messages.
DataSet data_set     = null;   // for returning results of SELECT queries

// this is fairly trivial, just nice to collapse it into something more readable
bool FileExists(string path)
{
	if (SQLite_debug) { Response.Write("Server path: " + Server.MapPath(path)); }
	return System.IO.File.Exists(Server.MapPath(path));
}

/*
cmd.CommandText="CREATE TABLE BlogItems (Blogid integer primary key, title varchar(250), link varchar(300), [description] varchar(8000), pubDate datetime, guid varchar(128), [public] integer)"; 
cmd.CommandText="Insert into BlogItems(title,link,description,pubDate,public) Values ('Test title','http://www.yahoo.com', 'description', " + DateTime.Now + "', 1)";
cmd.CommandText="UPDATE BlogItems SET pubDate='"+ pubDate +"',title='" +title+ "',description='"+description+"',link='" +link +"'" + " Where BlogId="+blogId.ToString(); 
cmd.CommandText="DELETE FROM BlogItems Where BlogId="+blogId.ToString();
cmd.CommandText="SELECT BlogId ,title, link, description, pubDate, guid FROM BlogItems WHERE public=1 and datetime(pubDate) > '" +String.Format("{0:u}",startDate)+ "'"+ " ORDER BY datetime(pubDate) Desc";
*/

// here's some error codes
int SQLerror_none  = 0,
    SQLerror_no_db = 1;

string StripApos(string strIn)
{
	return strIn.Replace("'", "&rsquo;");
}
string ReplaceApos(string strIn)
{
	return strIn.Replace("&rsquo;", "'");
}

// generic sql execute
int SQLiteExecute(string db_name, string sql)
{ return SQLiteExecute(db_name, sql, "false", "off"); }
int SQLiteExecute(string db_name, string sql, string isNew, string sync)
{
	// set up return value with default (no errors... yet)
	int err_code = SQLerror_none;
	
	// our processing vars
	SQLiteConnection conn = new SQLiteConnection();
	
	// if we're in debug, we want verbose errors
	if (SQLite_debug)
	{
		// try to execute sql
		try
		{
			// open db
			conn.ConnectionString = "Data Source=" + Server.MapPath(db_name) + ";Compress=False;Synchronous=" + sync + ";New=" + isNew + ";Version=3";
			conn.Open();
			
			// set up query
			SQLiteCommand cmd = new SQLiteCommand();
			cmd = conn.CreateCommand();
			cmd.CommandText = sql;
			
			// echo query to output
			Response.Write("Query used:<br /> - " + sql + "<br />");
			
			// run query
			cmd.ExecuteNonQuery();
			
			// clean up
			cmd.Dispose();
		}
		// catch any errors
		catch
		{
			err_code += 1;
		}
		// ensure db closes
		finally
		{
			conn.Close();
		}
	}
	// if we're not in debug mode, we do NOT want verbose errors
	else
	{
		// try to execute sql
		try
		{
			// open db
			conn.ConnectionString = "Data Source=" + Server.MapPath(db_name) + ";Compress=False;Synchronous=" + sync + ";New=" + isNew + ";Version=3";
			conn.Open();
			
			// set up query
			SQLiteCommand cmd = new SQLiteCommand();
			cmd = conn.CreateCommand();
			cmd.CommandText = sql;
			
			// run query
			cmd.ExecuteNonQuery();
			
			// clean up
			cmd.Dispose();
		}
		// ensure db closes
		finally
		{
			conn.Close();
		}
	}
	
	// return the error or lack thereof
	return err_code;
}
int SQLiteQuery(string db_name, string sql)
{
	// set up return value with default (no errors... yet)
	int err_code = SQLerror_none;
	
	// our processing vars
	SQLiteConnection conn = new SQLiteConnection();
	
	// if we're in debug, we want verbose errors
	if (SQLite_debug)
	{
		// try to execute sql
		try
		{
			// open db
			conn.ConnectionString = "Data Source=" + Server.MapPath(db_name) + ";Compress=False;Synchronous=off;New=false;Version=3";
			conn.Open();
			
			// set up query
			SQLiteCommand cmd = new SQLiteCommand();
			cmd = conn.CreateCommand();
			cmd.CommandText = sql;
			
			// echo query to output
			Response.Write("Query used:<br /> - " + sql + "<br />");
			
			// set up data adapter
			SQLiteDataAdapter data_adap = new SQLiteDataAdapter();
			data_adap.SelectCommand = cmd;
			
			// set up data set
			data_set = new DataSet();
			
			// extract data
			data_adap.Fill(data_set);
			
			// clean up
			cmd.Dispose();
		}
		// catch any errors
		catch
		{
			err_code += 1;
		}
		// ensure db closes
		finally
		{
			conn.Close();
		}
	}
	// if we're not in debug mode, we do NOT want verbose errors
	else
	{
		// try to execute sql
		try
		{
			// open db
			conn.ConnectionString = "Data Source=" + Server.MapPath(db_name) + ";Compress=False;Synchronous=off;New=false;Version=3";
			conn.Open();
			
			// set up query
			SQLiteCommand cmd = new SQLiteCommand();
			cmd = conn.CreateCommand();
			cmd.CommandText = sql;
			
			// set up data adapter
			SQLiteDataAdapter data_adap = new SQLiteDataAdapter();
			data_adap.SelectCommand = cmd;
			
			// set up data set
			data_set = new DataSet();
			
			// extract data
			data_adap.Fill(data_set);
			
			// clean up
			cmd.Dispose();
		}
		// ensure db closes
		finally
		{
			conn.Close();
		}
	}
	
	// return the error or lack thereof
	return err_code;
}

// Create Table
int SQLiteCreateTable(string db_name, string table_name, string column_list)
{
	// see if db exists
	string isNew = "True";
	if (FileExists(db_name))
		isNew = "False";
		
	string sql = "CREATE TABLE " + table_name + " (" + column_list + ")";
	
	return SQLiteExecute(db_name, sql, isNew, "FULL");
}

// Insert
int SQLiteInsert(string db_name, string table_name, string column_list, string value_list)
{
	// see if db exists
	if (!FileExists(db_name))
		return SQLerror_no_db;
		
	string sql = "INSERT INTO " + table_name + " (" + column_list + ") VALUES (" + value_list + ")";
	
	return SQLiteExecute(db_name, sql);
}

// Update
int SQLiteUpdate(string db_name, string table_name, string update_list, string filter_list)
{
	// see if db exists
	if (!FileExists(db_name))
		return SQLerror_no_db;
		
	string sql = "UPDATE " + table_name + " SET " + update_list + " WHERE " + filter_list;
	
	return SQLiteExecute(db_name, sql);
}

// Delete
int SQLiteDelete(string db_name, string table_name, string filter_list)
{
	// see if db exists
	if (!FileExists(db_name))
		return SQLerror_no_db;
		
	string sql = "DELETE FROM " + table_name + " WHERE " + filter_list;
	
	return SQLiteExecute(db_name, sql);
}

int SQLiteSelect(string db_name, string table_name, string [] table_list, string column_list)
{ return SQLiteSelect(db_name, table_name, table_list, column_list, "", ""); }
int SQLiteSelect(string db_name, string table_name, string [] table_list, string column_list, string filter_list)
{ return SQLiteSelect(db_name, table_name, table_list, column_list, filter_list, ""); }
int SQLiteSelect(string db_name, string table_name, string [] table_list, string column_list, string filter_list, string order_list)
{
	// see if db exists
	if (!FileExists(db_name))
		return SQLerror_no_db;
		
	string sql = "SELECT " + column_list + " FROM " + table_name;
	if (filter_list != "")
		sql += " WHERE " + filter_list;
	if (order_list != "")
		sql += " ORDER BY " + order_list;
	
	int err_code = SQLiteQuery(db_name, sql);
	
	// fill in table names
	for (int i = 0; i < data_set.Tables.Count; i++)
		data_set.Tables[i].TableName = table_list[i];

	return err_code;
}