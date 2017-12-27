use test_DB

---------------------------- Create Table

create table rank_test_table
(ID int identity(1,1),
 name varchar(50))

 insert into rank_test_table values('bruce'),('alfred'),('diana'),('nal'),('clark')

 drop table rank_test_table
 select * from rank_test_table
	   

 ------------------ 

 select ROW_NUMBER() over (order by name) as 'rownumber',name
 from rank_test_table





 select ROW_NUMBER() over (partition by name order by name) as 'rownumber',name
 from rank_test_table

 ------------------ 

 select RANK() over (order by name) as 'rownumber',name
 from rank_test_table

 select RANK() over (partition by name order by name) as 'rownumber',name
 from rank_test_table

 select DENSE_RANK() over (order by name) as 'rownumber',name
 from rank_test_table

 select DENSE_RANK() over (partition by name order by name) as 'rownumber',name
 from rank_test_table

 select ntile(2) over (order by name) as 'rownumber',name
 from rank_test_table

 select ntile(2) over (partition by name order by name) as 'rownumber',name
 from rank_test_table

 select ROW_NUMBER() over (partition by name order by name) as 'rownumber',name
 from rank_test_table
 

 --------------------------- Delete Duplicate
 -------------- Method 1
 delete
 from rank_test_table
 where ID in (select ID
              from (select ID,ROW_NUMBER() over (partition by name order by name) as 'DupID'
			        from rank_test_table)  derivedtablerank
					where DupID>1)

select * from rank_test_table

DBCC chechident ('rank_test_table', reseed,0)
truncate table rank_test_table

---- DBCC (Database Console Command statements)
---- I) Maintenance, II) Miscellaneous, III) Informational, IV) Validation

-- 1)

USE AdventureWorks2012;
GO
DBCC CHECKIDENT ('Person.AddressType');
GO

-- 2)

USE AdventureWorks2012; 
GO
DBCC CHECKIDENT ('Person.AddressType', NORESEED); 
GO
----- NORESEED: Specifies that the current identity value should not be changed.

-- 3) Change the identity value

USE AdventureWorks2012;
GO
DBCC CHECKIDENT ('Person.AddressType', RESEED, 10);
GO

-------------- Method 2
Select * From rank_test_table

Create view duplicatedeleteview 
as
Select ID,ROW_NUMBER() over (partition by name order by name) as DupID
From rank_test_table

----
SELECT ROW_NUMBER() OVER (PARTITION BY name ORDER BY name)AS DupID 
----

select * from duplicatedeleteview

delete from duplicatedeleteview
where DupID>1

select * from duplicatedeleteview

---------------  Method 3

Create Database RemoveDuplicate
Use RemoveDuplicate
Drop Table dbo.duplicateTest 
CREATE TABLE dbo.duplicateTest 
( 
[ID] [int] , 
[FirstName] [varchar](25), 
[LastName] [varchar](25)  
) ON [PRIMARY] 

INSERT INTO dbo.duplicateTest VALUES(1, 'Bob','Smith') 
INSERT INTO dbo.duplicateTest VALUES(2, 'Dave','Jones') 
INSERT INTO dbo.duplicateTest VALUES(3, 'Karen','White') 
INSERT INTO dbo.duplicateTest VALUES(1, 'Bob','Smith')
INSERT INTO dbo.duplicateTest VALUES(2, 'Dave','Jones')
INSERT INTO dbo.duplicateTest VALUES(3, 'Karen','White')
INSERT INTO dbo.duplicateTest VALUES(1, 'Bob','Smith')
INSERT INTO dbo.duplicateTest VALUES(2, 'Dave','Jones') 
INSERT INTO dbo.duplicateTest VALUES(3, 'Karen','White')  

Select * From dbo.duplicateTest

DBCC CHECKIDENT ('dbo.duplicateTest ');

Declare @Counter int,@Total int
Select @Total=count(Distinct ID) From dbo.duplicateTest
Set @Counter=1
While @Counter<=@Total
Begin
SET ROWCOUNT 1 
DELETE FROM dbo.duplicateTest WHERE ID = @Counter
Set Rowcount 0
Set @Counter=@Counter+1
End

---- SET ROWCOUNT: Causes SQL Server to stop processing the query 
---- after the specified number of rows are returned.


---------------- Method 4

Declare @Counter1 int,@Total1 int
Select @Total1=count(Distinct ID) From dbo.duplicateTest
Set @Counter1=1
While @Counter1<=@Total1
Begin
DELETE TOP(1) FROM dbo.duplicateTest WHERE ID = @Counter1
Set @Counter1=@Counter1+1 
End


