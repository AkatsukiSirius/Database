use AdventureWorks2012

-- 1.sub query 

--- Maximun nesting level is 32

---------- What are sub-queries?
--- 1) query within a query 
--- 2) the result of one query can be used to perform another query
--- 3) it can be used in different part of statement based on different application
--- 4) to create filters or condtions and get the information we need by using
---    multiple tables without acturally join them.

--------- 1.1 UnCorrelated Subquery
--- the result of a subquery which doesn't depend on the attributes from the 
--- main structure of the query, (in many cases this result is a number)

--- as the quntity of subquery increased, the operating speed will slow down
--- but if the uncorrelated part is detected by SQL server, then the independent
--- result can be got at first, after that, main structure of SQL will work,
--- in this case, the performance of whole statement will be  better

--------- 1.2 Correlated Subquery
--- the result of subquery is an outer reference which depends on the items occur
--- in main query, in this case, each time the whole query works, the result of
--- subquery will be changed since it is depend on main query.

---------- 1.3 Difference with join
--- Join: using the match method to find out the information we want
--- Subquery: fast typing way to find out the table with the info


-- Select statement
--- Can be used to retrieve values in a select statment, but only if 
--- they return a single result

select (select firstname+' '+lastname from person.Person
         where person.BusinessEntityID=Employee.BusinessEntityID),jobtitle,gender
from HumanResources.Employee

-- From statement
--- We can use it to form a derived table which contain the information we need,
--- and it is temporary existing, alias function must be used to name this 
--- temporary table
select *
from(select firstname+' '+lastname as 'full',businessentityID
     from person.Person) subderivedtable

-- where statement
--- Most frequently used in where clause of a SQL statement,
--- when a subquery appears in where clause, it works as part of the row selection
--- process which will filter the result based on other table

select firstname+' '+lastname
from person.person
where BusinessEntityID in 
(select BusinessEntityID from HumanResources.Employee)


-- 2.Set operators

--------------- What is set operator?
--- It provides a method to filter result of queries
--- We can combine 2 input tables to form an output table
--- It is done in a vertical manner, which means it works column by column
--- and return a table of them in a single data set.


--intersect
select businessentityID
from HumanResources.Employee --290rows
intersect
select businessentityID --19972rows
from person.Person  --290rows

--except
select businessentityID
from person.Person --19972rows
except
select businessentityID --290rows 
from HumanResources.Employee  --19682rows

--union

---- It combines two or more select statment results.
---- Each select statement must have the same number
---- of columns, since the dta will be dumped into one table
---- Union will only display the distinct values
select businessentityID
from HumanResources.Employee --290rows
union
select businessentityID --19972rows
from person.Person  --19972rows

--union all
---- It will display all the data, even duplicates.
select businessentityID
from HumanResources.Employee --290rows
union all
select businessentityID --19972rows
from person.Person --20262rows

