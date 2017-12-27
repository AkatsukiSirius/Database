------------------------------Bulk Operation

---- Import or export data from SQL server to file without developing ssis packets.
---- ssis move data from one sys to another.

-------------------Bulk Copy Program(BCP)
---- Nothing used in SQL server
---- BCP uses the CMD of the sys, so it si cmmand line driven;
---- Since it uses the CMD, it is avoiding any GUIor software, making it the
---- fastest way for communication between DBMS and RDBMS
---- BCP allows you to either pull data from SQL server or move data into SQL
---- server from sys files;
use test_DB

create table bulk_op(ID int,Fname varchar(50),Lname varchar(50))

select BusinessEntityID,FirstName,LastName 
from AdventureWorks2012.Person.Person

SELECT * FROM bulk_op

---- Import
Create Table dbo.testBCPLoad
(
      SalesOrderID          int      Not Null
    , SalesOrderDetailID    int      Not Null
    , OrderQty              smallint Null
    , ProductID             int      Null
 
    Constraint PK_testBCPLoad
        Primary Key Clustered
        (SalesOrderID)
);

----- When importing, Primary key error happens

--- Fix it
Alter Table dbo.testBCPLoad
    Drop Constraint PK_testBCPLoad;
 
Alter Table dbo.testBCPLoad
    Add Constraint PK_testBCPLoad
    Primary Key Clustered
        (SalesOrderID, SalesOrderDetailID);

Alter Table dbo.testBCPLoad
    Drop Constraint PK_testBCPLoad;
 
Alter Table dbo.testBCPLoad
    Add Constraint PK_testBCPLoad
    Primary Key Clustered
        (SalesOrderID, SalesOrderDetailID);

-------

---------------------------------Bulk Insert(BI)-----------------------



truncate table bulk_op

bulk insert bulk_op
from 'c:\Bulk_OP\EmpInfo.txt'

truncate table bulk_op

