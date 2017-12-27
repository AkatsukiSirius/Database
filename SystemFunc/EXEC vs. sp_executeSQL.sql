---- 1) sp_executesql allows for statements to be parameterized 
----    Therefore It’s more secure than EXEC in terms of SQL injection 

---- 2) sp_executesql can leverage cached query plans. 
----    The TSQL string is built only one time, 
----    after that every time same query is called with sp_executesql, 
----    SQL Server retrieves the query plan from cache and reuses it
 
---- 3) Temp tables created in EXEC can not use temp table caching mechanism.

------------------------- EXEC Example

Use AdventureWorks2012
GO
 
--DO NOT RUN this script on Production environment
--Clear the plan cache
dbcc freeproccache
 
--Use EXEC to execute a TSQL string
declare @str varchar(max)='',
            @param1 varchar(50)='',
            @param2 varchar(50)=''
set @param1='1'
set @param2='2'
set @str='select * from Person.Address where AddressID in ('+@param1+','+@param2+')'
exec(@str)
 
--Execute the same query with different paramaters
declare @str varchar(max)='',
            @param1 varchar(50)='',
            @param2 varchar(50)=''
set @param1='3'
set @param2='4'
set @str='select * from Person.Address where AddressID in ('+@param1+','+@param2+')'
exec(@str)
 
--Look at the cached query plans
select st.text,*
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
where (st.text like '%select * from Person.Address%')
and st.text not like '%select st.text%'


--- As you see 2 different query plans(1 for each query) are cached. 
--- Because EXEC does not allow for statements to be parameterized. 
--- They are similar to ad-hoc queries.


---------------------------- Sp_executesql Example

--- Let's do same example with sp_executesql
 
Use AdventureWorks2012
GO
 
--DO NOT RUN this script on Production environment
--Clear the plan cache
dbcc freeproccache
 
--- DBCC: The Database Console Commands (DBCC) are a series of statements in 
---       Transact-SQL programming language to check the physical and 
---       logical consistency of a Microsoft SQL Server database.
---       These commands are also used to fix existing issues.
---       They are also used for administration and file management.
---       DBCC was previously expanded as Database Consistency Checker


--sp_executesql 1
declare @param1 int,
          @param2 int
set @param1=1
set @param2=2
exec sp_executesql N'select * from Person.Address where AddressID in (@1,@2)'
            ,N'@1 int, @2 int'
            ,@param1, @param2
           
--sp_executesql 2
declare @param1 int,
          @param2 int
set @param1=3
set @param2=4
exec sp_executesql N'select * from Person.Address where AddressID in (@1,@2)'
            ,N'@1 int, @2 int'
            ,@param1, @param2
           
--Look at the cached query plans
select st.text,*
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
where (st.text like '%select * from Person.Address%')
and st.text not like '%select st.text%'       

