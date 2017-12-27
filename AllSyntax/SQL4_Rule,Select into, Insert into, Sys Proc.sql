------------------ Rule

--- created as a general constraint to be applied to various table;
--- used instead of creating individual constriants for each table;

--- Benifits:
--- 1) several table, several columns need similar constraints,
--- then, we use rule combination, don't need multiple constraints;
--- 2) if drop table constraints gone, rule still exist.

--- How to create:
--- Rules are created in their own syntax using a create statement;

--- 1) create rule RuleName as <expression>; create an object
--- called a rule. Then, bound to a column or an alias data type,
--- a rule specifies the acceptable values that can be insterted
--- into that column.

--- 2) after rules are created, they must be bounded to a column in
--- table, only one rule per column in a table.
use test_DB

select * from client

alter table client ---- add column
add email varchar(50)



create rule email_variable
as
@variable like '%ccsglobletech.com'


exec sp_bindrule email_variable,'client.email'

insert into Client(ClientID,email) values(1,'hello@yahoo.com')
-- doesn't work, since it violate the rule

insert into Client(ClientID,email) values(2,'hello@ccsglobletech.com')

select email from Client

Exec sp_unbindrule 'Client.email'

----------------- System Stored Procedure

--- Stored Procedures are collection of transact sql statements 
--- which perform a defined set of work;
--- The frequent performed logic can be encapsulated into batches
--- and saved as stored procedure on server.

--- Sprocs: it is used for administering the server engine, 
--- which includes procedure for managing
--- system security, to setup and manage distributed queries and linked servers 
--- (making tables and data on different machines visible to each other), 
--- data replication, retrieve information about schema, 
--- view current preformanced and usage inforamtion, 
--- manage SQL agent(the schedular that comes with SQL server),
--- and to interface with XML data.


--- 1)	sp_help: display metadata for the table, such as name, 
---              owner of database, type, created time, etc.
execute sp_help

--- 2)	sp_helptext: display the syntax for saved object.

--- 3)	sp_columns: display the metadata focusing on the column in a table, 
---                 such as owner, table name, data type, column name, length.
execute sp_columns Test_DB

--- 4)	sp_helpdb: display metadata about the database, such as name, size, 
---                created time, where it store 
---                and backup information what it used for.
execute sp_helpdb Test_DB

--- 5)	sp_who: display information on user, sessions and servers, 
---             we can use it to know how many users login.

--- 6)	sp_who2: display more details on users, sessions and server, 
---              we can use it to figure out which user slow down 
---              the overall performance of the database.

--- 7)	sp_helpDB: it can be used to show how many databases exist 
---                  in a computer, what’s their name and size. 
execute sp_helpDB 

--- 8) sp_rename: change table name
--- 9) sp_renamedb: change database name
--- 10) sp_bindrule:
--- 11) sp_unbindrule:
--- 12) sp_addmessage: we can add our own message to system message.

exec sp_help
-- Return: name of all databases, their size,owner,DBID, Create Date
--         status, compatibility_level

exec sp_helpdb AdventureWorks2012
-- Return: 1) name of all databases, their size,owner,DBID, Create Date
--            status, compatibility_level
--         2) name,fileid,filename(path),filegroup,size,maxsize,growth,
--            usage(data/log)

USE AdventureWorks2012;
GO
EXEC sp_columns @table_name = N'Department',
@table_owner = N'HumanResources';

exec sp_helptext sp_help

exec sp_who

exec sp_who2



------------- Select Into & Insert Into

---- Both are used to copy data from one table into another

---- Select Into: used to create a new table as we take data;
----              Both structure and duplicate data can be hold;
----              copy data from exisiting table and can insert
----              them into a newly created table in same syntax.

---- Insert Into: used if a table already existed and we need
----              to move data into it. It copy the data but
----              doesn't hold structure.

select jobtitle,maritalstatus,gender into employeenewtable
from AdventureWorks2012.HumanResources.Employee

select * from employeenewtable

drop table employeenewtable


select jobtitle,maritalstatus,gender into employeenewtable
from AdventureWorks2012.HumanResources.Employee
where 1=0

---- by making empty table to get the data structure;

select * from employeenewtable

insert into employeenewtable
select jobtitle,maritalstatus,gender
from AdventureWorks2012.HumanResources.Employee
