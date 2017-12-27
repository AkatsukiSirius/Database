------------------------Wild Card----------------
Use AdventureWorks2012

select * from HumanResources.Employee

select BusinessEntityID,JobTitle,Gender
from HumanResources.Employee
where JobTitle like '%s%a%' 
--- jobtile has s and a

select BusinessEntityID,JobTitle,Gender
from HumanResources.Employee
where JobTitle like '%sales%'

select BusinessEntityID,JobTitle,Gender
from HumanResources.Employee
where JobTitle like '[a,f,s]%'

select BusinessEntityID,JobTitle,Gender
from HumanResources.Employee
where JobTitle not like 'P%'

--- _ means anything
select BusinessEntityID,JobTitle,Gender
from HumanResources.Employee
where JobTitle not like '____e%' and
               JobTitle like '%a%'

-------------- Escape
--- Use it to retieve special symbols

USE tempdb;
GO
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_NAME = 'mytbl2')
   DROP TABLE mytbl2;
GO
USE tempdb;
GO
CREATE TABLE mytbl2
(
 c1 sysname
);
GO
INSERT mytbl2 VALUES ('Discount is 10 - 15 ~ off'), ('Discount is .10 -.15 off');

GO
--- Search '~'
SELECT c1 
FROM mytbl2
WHERE c1 LIKE '%*~%' ESCAPE '*';
GO
--- Search '-'
Select c1
From mytbl2
Where c1 Like '%*-%' Escape '*'
------

select * from person.Person

select firstname,middlename,lastname
from person.Person

select Firstname as 'First', Middlename as 'Middle',Lastname as 'Last'
from person.Person

select CONCAT(FirstName,' ',lastname) as 'Full'
from person.Person 

select stuff('HI world',1,2,'Hello') as 'stuff'
---- stuff(expression1,start,# of character,expression2)

select replace('Hi world Hi world Hi world','Hi','Hello') as 'replace'

select SUBSTRING('firstname',2,4) as 'firstname'

------ Exampe l

Select * 
From Production.Product
Where Name Like '_L %'

--- First character is anything
--- Second character is an L
--- Third character is a space

------ Example 2

Select *
From Production.Product
Where Name Like'[MHL]L%'

--- First character is M H or L
--- Second character is L

------ Exmaple 3

Select *
From Production.Product
Where Name Like '[A-C]%'

--- First character is A B or C

------ Exmaple 4

Select *
From Production.Product
Where Name Like '[^A-C]%'

--- First character is not an A B or C

 ------ Exmaple 5
 Select * 
 From Production.Product
 Where Name like '%a%b%'