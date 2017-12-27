Create database TEST_DB --This will be our testing database
 
Use TEST_DB

----------------------------------

----Tabel: A collection of rows and cols, it defines the structure and organization
----       of data, it is the core relational model


---- DDL -- Data Definition Language --

---- DDL: is used to define tables, views, stored procedures and other objects
----     that physically and logically express the data model we're working with
----     Graphical tools cab also be used to create tables

-- Create Statements --

Create table Sales
(
SalesID int not null,
ProdID int not null,
ClientID int not null,
Qty int not null,
Total money
)

Create table Product
(
ProdID int not null,
ProdName varchar(50),
ProdDesc varchar(50),
QoH int,
UnitPrice money
)

Create table Client
(
ClientID int,
CName varchar(50),
Phone Numeric(10,0)
)
 

--Create Schema--

----Schema: The structure described in a formal language supported by DBMS,
----        and refers to the organization of data as blueprint of how data is structured

Create Schema Test
 
Create Table Test.TestTable
(ID int,
Name varchar(20)
)

Drop Table Test.TestTable
Drop Schema Test

--------------------------------------------------------------

--Alter Statements--

Alter table Client
Alter column Phone int

Alter table Client
Alter Column ClientID int not null
 
--Adding a new column--

Alter table Client
ADD Email varchar(50)

 
--Dropping a column--

Alter table Client
Drop column Email
 
--Adding Schema to Table--

Alter Schema Test
       Transfer dbo.Sales

	   
 
--Using Alter to add Constraints--

---- Constriants: are used to specify rules for the data in a table
----              If there is any violation between the constraint and the data action,
----              the action is aborted by the constraint 

---- Type:Not Null; Unique; PK; FK; Check; Default

---- Method 1
---- Add the constriants after table is created.
---- Good for flexibility, allowing people to modify constriants on their own time
---- Bad in that, the whole works rely on team to remember the extra work to do

--Adding a PK constraint--

Alter Table Sales
Add constraint PK_Sales_SalesID Primary Key (SalesID)

Alter Table sales
Add constraint pk_sales_salesid primary key (salesID)

--Dropping a PK constraint--
Alter Table Sales
DROP constraint PK_Sales_SalesID

 
--Adding a composite PK--
Alter table Sales
Add constraint PK_Sales_SalesID_ProdID
Primary Key (SalesID,ProdID)

--Dropping composite PK--
Alter table Sales
Drop constraint PK_Sales_SalesID_ProdID
 
--Create PK and FK--
Alter table Product
Add constraint PC_Product_ProdID
       Primary Key (ProdID)

GO
Alter Table Sales
Add constraint FK_Product_Sales_ProdID
       Foreign Key (ProdID) References Product (ProdID)

--Drop PK and FK--
Alter table sales
Drop constraint FK_Product_Sales_ProdID
 
Alter Table Product
Drop constraint PC_Product_ProdID
 
--Unique Constraint--
Alter Table Product
Add constraint UK_Product_ProdName Unique (ProdName)
 
Alter table Product
Drop constraint UK_Product_ProdName

alter Table Client
add constraint PK_Client_ClientID Primary Key (ClientID)
 
---- Method 2
---- Create table & constriants at same time
---- Good for order and make sure tables are created correctly

Create table Sales2
(
SalesID int Identity(1,2) Primary Key, --Random Name--
ProdID int not null references Product(ProdID),
ClientID int not null references Client(ClientID),
Qty int not null,
Total Money
)

Create table Sales3
(                          --Named Key--
SalesID int Identity(1,2) Constraint PK_SALES2_ID Primary Key,
ProdID int not null references Product(ProdID),
ClientID int not null references Client(ClientID),
Qty int not null,
Total Money
)
 
---- Method 3
---- Create table and constraints at same time, but seperate the syntax into two parts

Create table Sales4
(
SalesId int identity(1,3),
ProdID int not null,
ClientID int not null,
Qty int not null Constraint DF_Sales3_Qty1 Default 10,  --Defualt Constraint
Total Money
 
Constraint PK_Sales3_SalesID1 Primary key (SalesID),
constraint FK_Product_Sales3_ProdID1 Foreign Key (ProdID)
       References Product(ProdID),  --Check for PK on Product and Client--
Constraint FK_Client_Sales3_ClientID1 Foreign Key (ClientID)
       References Client(clientID),
constraint CK_Sales3_Qty1 Check(qty>=10)  --Check Constraint
)

 
----DML -- Data Modifiction/Manipulation Language --

---- DML: provides the language constructs for retrieving information from tables,
----      adding, modifying and deleting data. 
----      Any statement that adds modifies or views the information in DB, 
---- S     can be considered part of the data manipulation language.

--Insert / Update / Delete / Truncate (in face, more like DDL)* --
 
Create Table T1 --Test Table
(
ID int not null primary key,
Name Varchar(50)
)
 
Select * from T1
--Insert--
Insert into T1 values (10,'Nehal')
Insert into T1 values (15,'Cornell')  --Single Insert / Multiple Statements
Insert into T1 values (12,'Yuu')
Insert into T1 values (13,'Tsega'),(11,'Maxwell') --Multiple Inserts / Single Statement
Insert into T1 values (5,'Swapnil')
GO 50

--Updates--

Update T1
Set Name = 'Pengcheng'
Where ID = 11


Update T1
Set Name = 'Andrew'
Where Name = 'Cornell'
 
--Delete--

Delete from T1
Where ID = 10
 
Delete from T1
Where Name = 'Yuu'
 
--Truncate--
Truncate Table T1
 
--DQL - Data Query Language--
--Used to retrieve and access data stored in tables and the database--
--What we write Select, From, Where, Group By, Having, Order By--
--What SQL Server actually runs From, Where, Group By, Having, Select, Order By--

use AdventureWorks2012
 
Select *
From HumanResources.Employee
 
Select BusinessEntityID, JobTitle
From HumanResources.Employee
Where JobTitle = 'Senior Tool Designer'
 
--Using Operators - Mathmatical and Logical--

Select BusinessEntityID, JobTitle
From HumanResources.Employee
Where JobTitle IN ('Marketing Specialist','Vice President of Production')
 
Select BusinessEntityID, JobTitle
From HumanResources.Employee
Where JobTitle = 'Marketing Specialist' OR
              JobTitle = 'Vice President of Production'
 
Select *
from HumanResources.Employee
Where BusinessEntityID BETWEEN 20 AND 77
 
Select *
from HumanResources.Employee
where BusinessEntityID >= 20 AND
       BusinessEntityID <= 77
 
---- DCL -- Data Control Language--
---- a component of SQL statement, in most cases developers don't use it, it is used by owners or 
---- administrators, security/network/db to define what rights users have to the data and objects
---- in database
--Grant / Deny / Revoke--
 
Create Role Testing  --Create Role
 
Grant Create Table to Testing --Granting permissions to role
 
Grant Testing to NCornell --Assigning Role to a user
 
Revoke Create Table To Testing  --Revoking Permission
 
Deny Create Table to Testing   --Denying Permission
 
Drop Role Testing   --Dropping Role


------------------------------------Cascade Functions---------------------------------
---- Cascade Funtion: using cascade fucntion, the changes on pk can be reflected on Fk
---- For PK: On Delete; On Update;
---- For Fk: Set Null; Cascade; Restrict(No Action); Set Default;

------ Restrict(No Action): report error when we modify PK;
------ Cascade: the fk will do whatever we do to pk;
------ Set Null: fk will set to Null when we make changes on PK; Ensure no Orphan key.

----- Con's: easier to make mistake; no log; must be used on each FK
----- Good: convinent for operation; garauntee the referenctial indentity; Child tab
-----       can be created without PK;
 
CREATE TABLE dbo.Albums
(
      AlbumID     INT   PRIMARY KEY,
      Name        VARCHAR(50)
)
 
CREATE TABLE dbo.Tracks
(
      TrackID     INT   PRIMARY KEY,
      Title       VARCHAR(50),
      AlbumID     INT   REFERENCES Albums(AlbumID)
                        ON DELETE SET NULL
                        ON UPDATE CASCADE,
      Duration    TIME(0)
)