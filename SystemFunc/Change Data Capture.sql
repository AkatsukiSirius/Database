--------------------- CDC

----- Introduction:
----- Before CDC we might simply query a last updated DATETIME 
----- column in our source system tables to determine 
----- what rows have changed. But this method doesn't work for
----- delete operation.


----- 1) Setup and configure CDC 
----- 2) Use CDC to extract rows that have been inserted, updated, 
-----    or deleted via T-SQL queries


----- After performing some setup and configuration steps, 
----- CDC will begin scanning the database transaction log for 
----- changes to certain tables that you specify, 
----- and will insert these changes into change tables. 

----- These change tables are created during the setup 
----- and configuration process.
 
----- The setup and configuration process will also 
----- create table-valued functions which can be used to query for 
----- the changes. 

----- Use the table-valued functions in lieu of querying 
----- the underlying change tables directly.

Create Database CDCTest

Use CDCTest
-------- I. Setup and Configuration

--- CDC is a feature that must be enabled at the database level; 
--- it is disabled by default. 
--- To enable CDC you must be a member of the sysadmin 
--- fixed server role. You can enable CDC on any user database; 
--- you cannot enable it on system databases.

Declare @rc int
Exec @rc = sys.sp_cdc_enable_db
Select @rc
-- new column added to sys.databases: is_cdc_enabled
Select name, is_cdc_enabled from sys.databases

--- 1) The sys.sp_cdc_enable_db stored procedure will 
--- return 0 if successful and 1 if it fails. 
--- 2) You can query whether CDC is enabled for any database by checking 
--- the new column is_cdc_enabled in the sys.databases table. 
--- You will see a value of 1 if CDC is enabled, a 0 otherwise.

--- The next step is to specify a table that you want to enable for CDC.

create table dbo.customer 
( id int identity not null, 
  name varchar(50) not null, 
  state varchar(2) not null, 
  constraint pk_customer primary key clustered (id) 
 )

Exec sys.sp_cdc_enable_table @source_schema = 'dbo',
                             @source_name = 'customer',
							 @role_name = 'CDCRole',
							 @supports_net_changes = 1

Select name, Type, type_desc, is_tracked_by_cdc 
From sys.tables

--- Must be a member of the db_owner fixed database role in order to 
--- execute the above system stored procedure and SQL Agent must be running.

--- Parameters in sys.sp_cdc_enable_table:
--- 1) @source_schema is the schema name of the table that you want to enable for CDC 
--- 2) @source_name is the table name that you want to enable for CDC 
--- 3) @role_name is a database role which will be used to determine whether 
---    a user can access the CDC data; the role will be created if it doesn't exist. 
---    You can add users to this role as required; 
---    you only need to add users that aren't already members of 
---    the db_owner fixed database role. 
--- 4) @supports_net_changes determines whether you can summarize multiple 
---    changes into a single change record; set to 1 to allow, 0 otherwise. 
--- 5) @capture_instance is a name that you assign to this particular CDC instance; 
---    you can have up two instances for a given table. 
--- 6) @index_name is the name of a unique index to use to identify rows in the source table; 
---    you can specify NULL if the source table has a primary key.
--- 7）@captured_column_list is a comma-separated list of column names 
---    that you want to enable for CDC; you can specify NULL to enable all columns. 
--- 8）@filegroup_name allows you to specify the FILEGROUP to be used to 
---    store the CDC change tables. 
--- 9）@partition_switch allows you to specify 
---    whether the ALTER TABLE SWITCH PARTITION command is allowed; 
---    i.e. allowing you to enable partitioning (TRUE or FALSE).


--- There is a new column named is_tracked_by_cdc in sys.tables; 
--- you can query it to determine whether CDC is enabled for a table.


--- Enabling CDC at the database and table levels will create certain 
--- tables, jobs, stored procedures and functions in the CDC-enabled database
--- These objects will be created in a schema named cdc and a cdc user is also created. 
--- You will see a message that two SQL Agent jobs were created;

-------- Examine the schema:

Select o.name, o.type, o.type_desc 
From sys.objects o
join sys.schemas s on s.schema_id = o.schema_id
Where s.name = 'cdc'


-------- Disable CDC at Table

Exec sys.sp_cdc_disable_table
@source_schema = 'dbo',
@source_name = 'customer',
@capture_instance = 'dbo_customer' 
-- or 'all'

-------- Disable CDC at Database

Declare @rc int
Exec @rc = sys.sp_cdc_disable_db
Select @rc
-- show databases and their CDC setting
Select name, is_cdc_enabled 
From sys.databases

---

Truncate Table Customer

--- Disabling CDC at the table and/or database level will drop the 
--- respective tables, jobs, stored procedures and functions 
--- that were created in the database when CDC was enabled.

--------------------------- Demo

--- 1) Perform a couple of inserts, update, and deletes to the customer table
---    Show T-SQL code samples to query the changes

--- 2) Show T-SQL code samples to query the changes

Insert customer values ('abc company', 'md')
Insert customer values ('xyz company', 'de')
Insert customer values ('xox company', 'va')

Update customer 
Set state = 'pa' 
Where id = 1
Delete 
From customer 
Where id = 3

Select * From Customer

Declare @begin_lsn binary(10), @end_lsn binary(10) 
-- get the first LSN for customer changes 
Select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_customer')
-- 'Use _ instead of .' 
-- get the last LSN for customer changes 
Select @end_lsn = sys.fn_cdc_get_max_lsn() 
-- get net changes; group changes in the range by the pk 
Select * from cdc.fn_cdc_get_net_changes_dbo_customer( @begin_lsn, @end_lsn, 'all'); 
-- get individual changes in the range 
Select * from cdc.fn_cdc_get_all_changes_dbo_customer( @begin_lsn, @end_lsn, 'all');

--------------- Result:
--- 1) Since there was an insert and a delete, 
---    the first result set doesn't show that row since it was added 
---    and deleted in the LSN range; (Id=3)

--- 2) The __$operation column values are: 
---    1 = delete, 
---    2 = insert, 
---    3 = update (values before update), 
---    4 = update (values after update).

--- To see the values before update you must pass 'all update old' 
--- to the cdc.fn_cdc_get_all_changes_dbo_customer() function. 
--- The __$update_mask column is a bit mask column that identifies the columns 
--- that changed. For __$operation = 1 or 2, all columns are indicated as changed. 
--- For __$operation = 3 or 4, the actual columns that changed are indicated. 
--- The columns are mapped to bits based on the column_ordinal; 
--- execute the stored procedure sys.sp_cdc_get_captured_columns 
--- passing the capture instance as a parameter to see the column_ordinal values;
---------------- Note:

--- An insufficient number of arguments were supplied for the procedure or function

--- 1) For the repro you cut/pasted above, you're passing in invalid LSN values, 
---    the reason you have invlaid LSN values is because you're querying LSNs 
---    for the wrong object. You enabled CDC for object 'Contacttype', 
---    but you're querying LSNs for object 'Contact'. So naturally, the @from_lsn 
---    and @to_lsn will be either 0x000 or NULL, which are invalid.

--- 2) The actual error message is by design, but it can easily be misleading 
---    if you're not familiar with the error handling 
---    (I should doublecheck that we are documenting this).
---    Unfortunately CDC has functions, and we have no way of doing error 
---    checking for invalid functions, we cannot have "raiserrors".  
---    So we created dummy functions, one of them is named the one you see 
---    in your error msg: "cdc.fn_get_all_changes_ ...".    
---    This is the only way we can indicate that invalid LSN values were passed in.  
---    Otherwise the customer may never know they have wrong LSN values.  
---    We're still working on trying to improve this type of error. 

--- To extract the changes for a table that has CDC enabled, 
--- you have to supply the relevant LSNs.
 
--- An LSN is a log sequence number that uniquely identifies entries 
--- in the database transaction log. 
--- If this is the first time you are querying to extract changes, 
--- you can get the minimum LSN and the maximum LSN using the functions 
--- sys.fn_cdc_get_min_lsn() and sys.fn_cdc_get_max_lsn().

--- If you set @supports_net_changes = 1 when enabling CDC on the table, 
--- you can query for the net changes using cdc.fn_cdc_get_net_changes_dbo_customer(). 
--- This will group multiple changes to a row based on the primary key or 
--- unique index you specified when enabling CDC. 
--- You can always invoke cdc.fn_cdc_get_all_changes_dbo_customer() 
--- to retrieve every change to the table within the LSN range. 
--- The dbo_customer portion of the function name is the capture instance; 
--- this is the default - schema_tablename. 

----------------------------- Periodically Extracting Changed Rows

--- Need to create a table to log the ending LSN

Create table dbo.customer_lsn (
last_lsn binary(10)
)

--- Need to create a function to retrieve the ending LSN from the table. 
--- This will allow us to pick up just what changed since the last time 
--- we ran our ETL process.

Create Function dbo.get_last_customer_lsn()
Returns binary(10)
as
Begin
Declare @last_lsn binary(10)
Select @last_lsn = last_lsn from dbo.customer_lsn
Select @last_lsn = isnull(@last_lsn, sys.fn_cdc_get_min_lsn('dbo_customer'))
Return @last_lsn
End

Declare @begin_lsn1 binary(10), @end_lsn1 binary(10)
-- get the next LSN for customer changes
Select @begin_lsn1 = dbo.get_last_customer_lsn()
-- get the last LSN for customer changes
Select @end_lsn1 = sys.fn_cdc_get_max_lsn()
-- get the net changes; group all changes in the range by the pk
Select * 
From cdc.fn_cdc_get_net_changes_dbo_customer(
@begin_lsn1, @end_lsn1, 'all');
-- get all individual changes in the range
Select * 
From cdc.fn_cdc_get_all_changes_dbo_customer(
@begin_lsn1, @end_lsn1, 'all');
-- save the end_lsn in the customer_lsn table
Update dbo.customer_lsn
Set last_lsn = @end_lsn1
If @@ROWCOUNT = 0
Insert into dbo.customer_lsn Values(@end_lsn1)




