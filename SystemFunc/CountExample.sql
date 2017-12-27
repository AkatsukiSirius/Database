
---- COUNT() function.

--- 1. Never use COUNT(*), it must read all columns 
---    and cause unnecessary reads.
--- 2. Always use COUNT(1) because, generally, 
---    the primary key is the first column in the table 
---    and you want it to read the clustered index.
--- 3. Always use COUNT(column_name) so that you can select 
---    which index it will scan.

Create Database [Test2014]
Use [Test2014];

If Exists (Select *
           From sys.tables
		   Where name='CountDemo')
	Drop Table dbo.CountDemo;

Create Table dbo.CountDemo
(
ID uniqueidentifier Not Null Default(NewID()),
Num int Identity(1000,2) Not Null,
String Nvarchar(50) Not Null
);
Go

Insert Into [CountDemo] ([String])
Values
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose');

Select * From [CountDemo]

--------- 1. Test
Select Count(*) From [CountDemo]
Select Count(1) From [CountDemo]
Select Count([String]) From [CountDemo]

--- all table scan

--------- 2. Add Index

Create Nonclustered Index [IX_ID]
On dbo.[CountDemo](ID);

Create Nonclustered Index [IX_Num]
On dbo.[CountDemo](Num);

Create Nonclustered Index [IX_String]
On dbo.[CountDemo](String);

Select Count(*) From [CountDemo]
Select Count(1) From [CountDemo]
Select Count([String]) From [CountDemo]

--- All Index Scan (Use [IX_Num])

--- 3. Counting with Nulls

Create Table dbo.CountDemoNull
(
 ID uniqueidentifier Not Null Default (NewID()),
 Num int identity(1000,2) Not Null,
 String Nvarchar(50) Null
);
Go
Insert Into [CountDemoNull] ([String])
Values
(Null),(Null),(Null),(Null),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose'),
(N'Some text,for demonstration purpose');

Select * From dbo.CountDemoNull

------------- Test

Select Count(*) From [CountDemoNull]
Select Count(1) From [CountDemoNull]
Select Count([String]) From [CountDemoNull]

--- Same EP

------------- Add Index 
Create Nonclustered Index [IX_ID]
On dbo.[CountDemoNull](ID);

Create Nonclustered Index [IX_Num]
On dbo.[CountDemoNull](Num);

Create Nonclustered Index [IX_String]
On dbo.[CountDemoNull](String);


Select Count(*) From [CountDemoNull]
Select Count(1) From [CountDemoNull]
Select Count([String]) From [CountDemoNull] --- No Null


------------ Take-aways

---- 1.COUNT(*) and COUNT(1) are completely interchangeable. 
----   The 1 is not interpreted as an ordinal reference 
----   to a column and results in a count of all rows, regardless of NULLs.
---- 2.COUNT(column_name) is also interchangeable with COUNT(*) 
----   and COUNT(1), if that column is NOT NULL.
---- 3.Your selection of column in the COUNT() function 
----   is very important if NULLs are present. 
----   In that case, your concern should be accuracy of the result before performance.
---- 4.The SQL Server optimizer will select the best index possible for your COUNT().
---- 5.If you use COUNT() a lot in your queries 
----   and you typically have wide indexes, you might want to consider 
----   making a very narrow index which can be used for the COUNT() operation. 