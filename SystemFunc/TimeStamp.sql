Create Database TStest
USE TStest

------------------------- Example 1
Create Table ExampleTable(
ID int Primary Key,
Name varchar(10), timestamp
)

Insert into ExampleTable values(1,'A',Default)
Insert into ExampleTable values(2,'B',Default)
Insert into ExampleTable values(3,'C',Default)
Insert into ExampleTable values(4,'D',Default)
Insert into ExampleTable values(5,'E',Default)

Select * From ExampleTable

----- Now modify the table
Update ExampleTable
Set Name ='Jihoon'
Where ID = 4

Update ExampleTable
Set Name='AA'
Where ID = 1

Delete From ExampleTable
Where Name = 'E'

Insert into ExampleTable values (77,'oo',Default),(88,'ooo',Default)

Select * From ExampleTable 

------------------------------------  Example 2

CREATE TABLE [dbo].[Names]
(
    [Name] [nvarchar](64) NOT NULL,
    RowVers rowversion ,
    [CreateTS] [datetime] NOT NULL 
	CONSTRAINT CreateTS_DF DEFAULT CURRENT_TIMESTAMP,
    [UpdateTS] [datetime] NOT NULL

)
Select * From [dbo].[Names]
Drop Table [dbo].[Names]
--- PS I think a smalldatetime is good enough. 
--- You may decide differently.
--- Can you not do this at the "moment of impact" ?
--- In Sql Server, this is common:

Update dbo.MyTable
Set 
ColA = @SomeValue ,
UpdateDS = CURRENT_TIMESTAMP
Where 

--- Sql Server has a "timestamp" datatype.
--- But it may not be what you think.
--- Here is a reference:

--- http://msdn.microsoft.com/en-us/library/ms182776(v=sql.90).aspx


CREATE TABLE [dbo].[Names]
(
    [Name] [nvarchar](64) NOT NULL,
    RowVers rowversion,
	--- Track which rows have been modified
	--- http://www.codeproject.com/Articles/698025/Rowversion-datatype-in-SQL-Server-Track-which-rows
    [CreateTS] [datetime] NOT NULL CONSTRAINT CreateTS_DF DEFAULT CURRENT_TIMESTAMP,
    [UpdateTS] [datetime] NOT NULL
)



INSERT INTO dbo.Names (Name,UpdateTS)
select 'John' , CURRENT_TIMESTAMP
UNION ALL select 'Mary' , CURRENT_TIMESTAMP
UNION ALL select 'Paul' , CURRENT_TIMESTAMP

Select * From dbo.Names

Select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers) 
From [dbo].[Names]

Update dbo.Names Set Name = Name
Select * From dbo.Names

Select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers) 
From [dbo].[Names]

Select * From dbo.Names
--- Maybe a complete working example:

DROP TABLE [dbo].[Names]
GO


CREATE TABLE [dbo].[Names]
(
    [Name] [nvarchar](64) NOT NULL,
    RowVers rowversion ,
    [CreateTS] [datetime] NOT NULL 
	CONSTRAINT CreateTS_DF DEFAULT CURRENT_TIMESTAMP,
    [UpdateTS] [datetime] NOT NULL

)


Select * From dbo.Names
GO

CREATE TRIGGER dbo.trgKeepUpdateDateInSync_ByeByeBye ON dbo.Names
AFTER INSERT, UPDATE
AS

BEGIN

Update dbo.Names Set UpdateTS = CURRENT_TIMESTAMP 
from dbo.Names myAlias, inserted triggerInsertedTable 
where 
triggerInsertedTable.Name = myAlias.Name

END

GO

INSERT INTO dbo.Names (Name,UpdateTS)
select 'John' , CURRENT_TIMESTAMP
UNION ALL select 'Mary' , CURRENT_TIMESTAMP
UNION ALL select 'Paul' , CURRENT_TIMESTAMP

Select * From dbo.Names

select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers) 
from [dbo].[Names]

Update dbo.Names Set Name = Name , UpdateTS = '03/03/2003' 
/* notice that even though I set it to 2003, the trigger takes over */

select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers) 
from [dbo].[Names]

--- Matching on the "Name" value is probably not wise.
--- Try this more mainstream example with a SurrogateKey

DROP TABLE [dbo].[Names]
GO


CREATE TABLE [dbo].[Names]
(
    SurrogateKey int not null 
	Primary Key Identity (1001,1),
    [Name] [nvarchar](64) NOT NULL,
    RowVers rowversion ,
    [CreateTS] [datetime] NOT NULL 
	CONSTRAINT CreateTS_DF DEFAULT CURRENT_TIMESTAMP,
    [UpdateTS] [datetime] NOT NULL

)

Select * From dbo.Names

CREATE TRIGGER dbo.trgKeepUpdateDateInSync_ByeByeBye ON dbo.Names
AFTER UPDATE
AS

BEGIN

   UPDATE dbo.Names
    SET UpdateTS = CURRENT_TIMESTAMP
    From  dbo.Names myAlias
    WHERE exists ( select null 
	               from inserted triggerInsertedTable 
				   where myAlias.SurrogateKey = triggerInsertedTable.SurrogateKey)

END

GO

INSERT INTO dbo.Names (Name,UpdateTS)
select 'John' , CURRENT_TIMESTAMP
UNION ALL select 'Mary' , CURRENT_TIMESTAMP
UNION ALL select 'Paul' , CURRENT_TIMESTAMP

Select * From dbo.Names

Select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers)
From [dbo].[Names]

Update dbo.Names 
Set Name = Name , UpdateTS = '03/03/2003' 
/* notice that even though I set it to 2003, the trigger takes over */

Select *  ,  ConvertedRowVers = CONVERT(bigint,RowVers) 
From [dbo].[Names]
--- Check if we have both CreateST and UpdateST.
 