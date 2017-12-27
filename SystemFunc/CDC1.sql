---------------------------- CDC 1

---- Prior to SQL Server 2008 there was no in-built support to identify 
---- changed data set for incrementally pulling data from a source table 
---- and hence we had to write our own custom logic 
---- (for example by adding Last Created Date or Last Modified Date columns 
---- in the source table and updating it accordingly or by some other means)
---- So that changed data sets can be identified for incremental data pull.

---- Starting with SQL Server 2008 we have two different in-built mechanisms 
---- (please note, you don’t need to write code for leveraging these features 
---- though you just need to enable it accordingly as per your need) 
---- to identify DML changes (INSERT, UPDATE, DELTE) happening 
---- at the source table so that only changed data sets can be considered 
---- for data pull from the source table and to load into the data warehouse.

---- These two in-built mechanisms are Change Data Capture (CDC) 
---- and Change Tracking (CT). 

---------------- Understanding Change Data Capture (CDC)

---- Change Data Capture (CDC) is an Enterprise edition 
---- (available in Developer and Evaluation editions as well) feature 
---- and once enabled for a table, 
---- it captures DML changes (insert, update and delete activities) 
---- on a tracked table.
 
---- The captured information then becomes available in a relational format 
---- for consumption.

---- When you enable CDC on a table, SQL Server creates a table 
---- that contains same columns as a source\tracked table 
---- along with the metadata needed to understand the changes that have occurred.
 
---- Table-valued functions are created to systematically access the change data 
---- from the CDC table over a specified range, 
---- returning the information in the form of a filtered result set.

-------------- Change Data Capture (CDC) vs Change Tracking (CT)

---- Change Data Capture is an asynchronous process 
---- which reads the transaction log asynchronously in the background 
---- to track and record the DML changes (complete history of changes) 

---- whereas Change Tracking is a light-weight synchronous process, 
---- which tracks what has happened with the last changed data (no history). 



---- As the Change Data Capture feature captures the complete history 
---- of the changes it requires more storage space than Change Tracking.
 
---- Change Data Capture requires SQL Server Agent to capture the information 
---- from the SQL Server transaction log as it works in asynchronous manner 
---- whereas Change Tracking captures information about the changes 
---- in synchronous manner as part of the user transaction itself.

----------------------- How CDC Works

---- Once CDC is enabled on a tracked table, 
---- SQL Server uses an asynchronous capture mechanism 
---- that reads the SQL Server transaction logs and populates the CDC table 
---- (table which keeps track of history of changes 
---- along with meta-data about changes) 
---- with the row's data that changes.
 
---- This feature is entrenched in transaction log architecture, 
---- thus a lot of the metadata in CDC is related around 
---- the concept of a Log Sequence Number 
---- (LSN, every record in the transaction log is uniquely identified by a LSN.
---- LSNs are ordered such that if LSN2 is greater than LSN1, 
---- the change described by the log record referred to by LSN2 occurred 
---- after the change described by the log record LSN1).

---- To enable Change Data Capture for a table, 
---- you first need to enable it at the database level using 
---- sys.sp_cdc_enable_db system procedure, 
---- which creates the change data capture objects that have database wide scope, 
---- including meta-data tables and 
---- required Data Definition Language (DDL) triggers. 
---- It also creates the CDC schema and CDC database user. 
---- You can verify if the database is enabled for CDC or not 
---- by looking at the is_cdc_enabled column for the database entry 
---- in the sys.databases catalog view.

---- Next you can enable CDC for the required table using 
---- sys.sp_cdc_enable_table system stored procedure. 
---- When CDC is enabled for a table, a CDC table 
---- (a table that keeps track of history of changes along 
---- with meta-data about changes) 
---- and one or two table-valued functions are generated along 
---- with capture and cleanup jobs for the database 
---- if this is the first table in the database to be enabled for CDC. 
---- You can verify if the table is enabled for CDC 
---- by looking into the is_tracked_by_cdc column 
---- of the sys.tables catalog view.

---- Once enabled, each DML change to the tracked table 
---- is captured from the SQL Server transaction log 
---- and it writes changes to the CDC table that is accessed 
---- by using a set of table-valued functions.

---- By default, all of the columns in the tracked table are considered 
---- for capturing changes though you can specify only a subset of columns, 
---- for privacy or performance reasons, 
---- using the @captured_column_list parameter of sys.sp_cdc_enable_table 
---- system stored procedure. 

---- Also, by default, the CDC table is created in the default filegroup 
---- of the database though you can specify to create it on another filegroup 
---- using @filegroup_name parameter.

---- It’s not mandatory to have SQL Server Agent service running 
---- when enabling a database\table for CDC but it must be running 
---- for CDC to work properly.
 
---- Please note, if the SQL Server Agent job is not running 
---- then transaction log will keep on growing and will not get truncated 
---- after transaction log backup and hence you need to 
---- ensure SQL Server Agent job is running to ensure changes are read 
---- from transaction log and written to the CDC table.

---------------------- What about CDC Tracking Table Growth?

---- You might be wondering about the CDC table 
---- (table which keeps track of history of changes 
---- along with meta-data about changes), will it keep on growing? 
---- The answer is NO, there is an automatic cleanup process that occurs 
---- every three days by default 
---- (and this is configurable and can be changed as per specific need). 
---- For more intense environments, where you want to directly manage 
---- the CDC table cleanup process, you can leverage the manual method 
---- using the system stored procedure sys.sp_cdc_cleanup_change_table. 
---- When we execute this system procedure you need to specify 
---- the low LSN and any change records occurring 
---- before this point are removed and the start_lsn is set 
---- to the low LSN we specified.

----------------------- What Happens When Tracked Table is Changed?

---- DDL changes are not prevented for a CDC tracked table 
---- but a new column added will not be reflected 
---- and a dropped column will return null values 
---- for the column in the subsequent change entries. 
---- It means, CDC ignores any new columns that are not identified 
---- for capture when the source table was enabled for CDC for 
---- the current capture instance as it retains or preserves its shape 
---- when DDL changes are applied to its tracked table. 
---- However, it is possible to create a second capture instance for 
---- the table that reflects the new column structure. 
---- Please note, a tracked table can have a maximum of two capture instances.

------------------------ Conclusion

---- In this article, I talked about Change Data Capture (CDC), 
---- which captures DML changes (insert, update and delete activities) 
---- on a tracked table and can be used to incrementally pull data 
---- from the tracked table. 
---- In my next article on this series, I am going to demonstrate 
---- how this new feature can be leveraged, in detail, with an example.


------------------------ CDC 2

----------------- Getting Started with Change Data Capture (CDC)

---- First need to enable CDC at the database level 
---- using the sys.sp_cdc_enable_db system procedure, 
---- which creates the change data capture objects 
---- that have:
-----1) database wide scope, 
---- 2) including meta-data tables and 
---- 3) required Data Definition Language (DDL) triggers. 
---- 4) It also creates the CDC schema and CDC database user. 

---- You can verify if the database that is enabled for CDC is not 
---- by looking at the is_cdc_enabled column 
---- for the database entry in the sys.databases catalog view
---- or by executing the following script. 
---- You need to be a member of sysadmin fixed server role 
---- in order to execute the below script to enable CDC at the database level:

USE master
GO
CREATE DATABASE LearningCDC
GO
USE LearningCDC
GO
--This command can be executed by a member of the sysadmin fixed server role
EXECUTE sys.sp_cdc_enable_db;
GO
SELECT is_cdc_enabled, * FROM sys.databases WHERE name= 'LearningCDC'
GO

---- Now under LearningCDC database and in sys table folder
---- we can find several tables are created.

---- Next as a member of the db_owner fixed database role, 
---- It is avaiable to enable CDC for the required table (a capture instance) 
---- using the sys.sp_cdc_enable_table system stored procedure. 
---- When CDC is enabled for a table, a CDC table 
---- (table which keeps track of history of changes 
---- along with meta-data about changes) and two table-valued functions 
---- are generated along with capture and cleanup jobs for the database 
---- if this is the first table in the database to be enabled for CDC. 
---- You can verify if the table is enabled for CDC 
---- by looking into the is_tracked_by_cdc column of the sys.tables catalog view.

CREATE TABLE dbo.Employee
(
EmployeeID INT IDENTITY PRIMARY KEY,
FirstName VARCHAR(100),
LastName VARCHAR(100),
CurrentPayScale DECIMAL
)
GO
INSERT INTO dbo.Employee(FirstName, LastName, CurrentPayScale)
VALUES
('Steve', 'Savage', 10000),
('Ranjit', 'Srivastava', 12000),
('Akram', 'Haque', 12000)
GO
SELECT * FROM dbo.Employee
GO

---- Execute the script below to enable CDC on the above created table. 
---- With @role_name parameter, you can specify the name of the database role 
---- used to gate access to changed data; if it already exists then it is used, 
---- or else an attempt is made to create a database role with this name. 
---- With @supports_net_changes parameter you can enable support 
---- for querying for net changes. 
---- This means all changes that happen on a record will be summarized 
---- in the form of net change. 
---- By default its value is 1 if the table has a primary key or the table 
---- has a unique index that has been specified with @index_name parameter otherwise,
---- the default value is 0. 

------ https://technet.microsoft.com/en-us/library/bb522475.aspx

EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name   = N'Employee',
@role_name     = N'MyCDCUserRole',
@supports_net_changes = 1
GO
SELECT is_tracked_by_cdc, * FROM sys.tables WHERE name = 'Employee'
GO

---- Now let’s run some DML statement against the CDC enabled table with this script:

INSERT INTO dbo.Employee(FirstName, LastName, CurrentPayScale)
VALUES('Ahmad', 'Jamal', 10000)
GO
DELETE FROM dbo.Employee
WHERE EmployeeID = 2
GO
UPDATE dbo.Employee
SET CurrentPayScale = 15000, FirstName = 'Akramul'
WHERE EmployeeID = 3
GO
UPDATE dbo.Employee
SET CurrentPayScale = 18000
WHERE EmployeeID = 3

GO

select * from dbo.Employee

---- When you enable CDC for a table, SQL Server creates the table 
---- (with this naming convention: cdc.<capture instance>_CT) 
---- and keeps recording DML changes happening to the tracked table in this table. 
---- For example, in the current example here is the result-set of changes captured
---- for the above changes:

SELECT * FROM [cdc].[dbo_Employee_CT]
GO

---- As you can see above, along with the data there are some columns 
---- which capture meta information about the changes. 
---- For example:  
---- 1) __$operation, it captures the DML operation needed to apply the row of 
----                  change data to the target data source. 
----    Valid values are 1 = delete, 
----                     2 = insert, 
----                     3 = value before update and 
----                     4 = value after update. 
---- 2) __$update_mask, it is a bit mask representing columns that were changed 
----                    during DML operations. It means: 
----                    i) delete (__$operation = 1) and 
----                    ii) insert (__$operation = 2) operation will have value 
----                        set to 1 for all defined bits whereas for 
----                    iii) update (__$operation = 3 and __$operation = 4) 
----                         only those bits corresponding to columns 
----                         that changed are set to 1.

---- When you enable CDC, several functions are created to return changes. 
---- For example, cdc.fn_cdc_get_all_changes_<capture_instance> function returns one row 
---- for each change applied to the CDC tracked table within 
---- the specified log sequence number (LSN) range. 
---- If a source row had multiple changes during the specified range interval, 
---- each change is represented in the returned result set whereas 

---- cdc.fn_cdc_get_net_changes_<capture_instance> function returns one net change row 
---- for each source row changed within the specified LSN range. 
---- That is, when a source row has multiple changes during the specified LSN range, 
---- a single row that reflects the final content of the row is returned.

---- For example, as you can see below cdc.fn_cdc_get_all_changes_dbo_Employee function 
---- returns two rows for two updates of EmployeeID = 3:
DECLARE @MinimumLSN binary(10), @MaximumLSN binary(10)
SET @MinimumLSN = sys.fn_cdc_get_min_lsn('dbo_Employee')
SET @MaximumLSN = sys.fn_cdc_get_max_lsn()
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Employee (@MinimumLSN, @MaximumLSN, N'all');
GO

---- Whereas cdc.fn_cdc_get_net_changes_dbo_Employee function returns net or final changes 
---- for EmployeeID = 3 in a single record:

DECLARE @MinimumLSN binary(10), @MaximumLSN binary(10)
SET @MinimumLSN = sys.fn_cdc_get_min_lsn('dbo_Employee')
SET @MaximumLSN = sys.fn_cdc_get_max_lsn()
SELECT * FROM cdc.fn_cdc_get_net_changes_dbo_Employee (@MinimumLSN, @MaximumLSN, N'all');
GO

---- The above functions expect starting LSN and ending LSN and returns the changes 
---- between these two LSNs. You can use sys.fn_cdc_get_min_lsn to get start LSN 
---- for the specified capture instance and 
---- sys.fn_cdc_get_max_lsn to get ending LSN from cdc.lsn_time_mapping system table.

---- Sometimes, you would like to pull data based on a time range instead of LSN range 
---- and hence you can use the sys.fn_cdc_map_time_to_lsn function 
---- to get start LSN from cdc.lsn_time_mapping system table for the specified time.


----------------------------- CDC Jobs and Cleanup Process


---- You can disable CDC for either each individual table or 
---- disable it at the database level. 

---- For each CDC enabled database there will be two jobs created 
---- as shown below. 

---- The first job captures the information from the SQL Server transaction log 
---- as it works in asynchronous manner whereas 

---- the second job cleans up the tracked table. 
---- The cleanup process occurs every three days by default 
---- (this is configurable and can be changed as per specific needs). 

---- For more intense environments, where you want to directly manage the 
---- CDC table cleanup process, you can leverage the manual method 
---- using the system stored procedure sys.sp_cdc_cleanup_change_table.
 
---- When we execute this system procedure you need to specify the low LSN 
---- and any change records occurring before this point are removed and 
---- the start_lsn is set to the low LSN we specified.

-------------------- Disabling Change Data Capture (CDC)

---- You can disable CDC for either each individual table or 
---- disable it at the database level, 
---- which in effect will disable CDC for all the tables of the given database. 
---- You need to be a member of the db_owner fixed database role 
---- to disable CDC at the table level and a member of the sysadmin fixed server 
---- for disabling at database level.

--To disable CDC for a table in a database for a given capture instance
EXEC sys.sp_cdc_disable_table
@source_schema = N'dbo',
@source_name   = N'Employee',
@capture_instance = N'dbo_Employee'
GO
--To disable CDC for the database in the context
EXEC sys.sp_cdc_disable_db
GO
Disabling CDC at the database level removes all associated CDC metadata, including the CDC user and schema and the CDC jobs.

You can execute the scripts below to get more information about CDC configuration:

--Returns CDC configuration information for a specified schema and table
EXECUTE sys.sp_cdc_help_change_data_capture 
    @source_schema = N'db',
    @source_name = N'Employee';
GO
--Returns CDC configuration information for all tables in the database
EXECUTE sys.sp_cdc_help_change_data_capture
GO

------------------------- Conclusion

---- In this article I demonstrated how you can leverage the Change Data Capture feature 
---- of SQL Server to track DML changes on the source table and 
---- how you can pull data incrementally from the tracked table.