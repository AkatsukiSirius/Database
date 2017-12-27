Use AdventureWorks2012

------ 1. Aggregation Function
select * from sales.SalesOrderHeader

select salesorderID,customerID,salespersonID,totaldue
from sales.SalesOrderHeader

select sum(totaldue) as 'total sales'
from sales.SalesOrderHeader

select max(totaldue) as 'max sales'
from sales.SalesOrderHeader

select min(totaldue) as 'min sales'
from sales.SalesOrderHeader

select top 1 totaldue
from sales.SalesOrderHeader
order by totaldue desc

select avg(totaldue) as 'avg sales'
from sales.SalesOrderHeader

select count(totaldue) as 'number of sales'
from sales.SalesOrderHeader

select customerID,sum(totaldue) 
from sales.SalesOrderHeader
group by CustomerID
having sum(totaldue) > 5000
order by CustomerID

select customerID,sum(totaldue) as 'number of sales'
from sales.SalesOrderHeader
group by CustomerID,SalesPersonID

--- Count: Count(*) return the # of rows,
---        Group all rows into a single group
---        and count the rows for that group

--- Group by: used to take similar values that would
---           repeat during an aggregate and combine them
---           in a new entry.
---           it doesn't matter everything together,
---           it only matters everything related to a column
---           it find all similar or duplicate values and
---           put them in new entry

--- Having: used to filter and create conditions for 
---         the aggregate values.
---         aggregated values can only be filtered in Having 
---         not in where
---         values are not limited to only what has been selected

--- Where clause filters on row basis not on group basis

---- 2. System Function

--- System funcitons are saved T-Sql statements made to perform
--- some business calculation, mainly for mathematical purpose

--- created by the system for SQL, these functions perform different
--- mathematical or operational functions

--- called in select statement 

select getdate() as 'current time'

select datediff(year,'02-22-1975',getdate()) as 'age'

select datediff(day,'02-22-1975',getdate())/365.25 as 'age'

select dateadd(day,5,getdate()) as 'shipping date'

select datepart(year,getdate())
select datepart(month,getdate())
select datepart(day,getdate())

select year(getdate())
select month(getdate())
select day(getdate())

select datepart(weekday,getdate())

select getutcdate()
--- return the UTC time of the current system

Select Dateadd(year,10,'2006/08/09')
--- add interval on corresponding date,based on the given date.
----- 3. Cast & Convert & Parse

--- 3.1 Cast: used to change the data type from one to another type
---           data types must be compatible
---           e.g. # from int can go to varchar, while
---                varchar can't go to int

select cast(10 as varchar)

--------not availible
select cast('abc' as int)

select ' you are number' + cast(1 as varchar)

--- 3.2 Convert: used to change data type from one to another,
---              following the same compatible rules
---              has an extra feature of STYLE and will display
---              the data in different way.




select convert(varchar,getdate(),2)
select convert(varchar,getdate(),4)
select convert(varchar,getdate(),6)
select convert(varchar,getdate(),7)
select convert(varchar,getdate(),9)


---- 3.3 Parse

---- Returns the result of an expression, 
---- translated to the requested data type in SQL Server.

---- PARSE ( string_value AS data_type [ USING culture ] )

SELECT PARSE('Monday, 13 December 2010' AS datetime2 USING 'en-US') 
AS Result;


SELECT PARSE('€345,98' AS money USING 'de-DE') AS Result;

SET LANGUAGE 'English';
SELECT PARSE('12/16/2010' AS datetime2) AS Result;