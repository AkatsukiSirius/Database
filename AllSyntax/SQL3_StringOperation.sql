use AdventureWorks2012

select * from HumanResources.Employee

select JobTitle
from HumanResources.Employee
where JobTitle like '&Manager%' OR
      JobTitle like '%Supervisor%'

select * from person.Person

select firstname,middlename,lastname
from person.Person
where firstname like 'G%'

select BusinessEntityID,JobTitle
from HumanResources.Employee
where BusinessEntityID>100 and
      Jobtitle like '%er'

select firstname+' '+middlename+' '+lastname as 'full'
from person.Person
where middlename not like '%NULL%'

select concat(firstname,' ',middlename,' ',lastname) as 'full name'
from person.Person
where middlename not like '%NULL%'

select concat(firstname,' ',middlename,' ',lastname) as 'full name'
from person.Person
where middlename is not null

Select firstname+' '+isnull(middlename,' ')+' '+lastname as 'full name'
From person.person

select concat(firstname,' ',middlename,' ',lastname) as 'full name'
from person.Person
where middlename is null and
      lastname like '%e%e%' and
	  lastname not like '%e%e%e%'


select concat(substring('abcdefghijklmnopqrstuvwxyz',20,1),substring('abcdefghijklmnopqrstuvwxyz',1,1), 
substring('abcdefghijklmnopqrstuvwxyz',15,1),' ',substring('abcdefghijklmnopqrstuvwxyz',12,1),
substring('abcdefghijklmnopqrstuvwxyz',9,1)) as 'my name'

select replace(stuff('Hello my name is blank1, I''m from Blank2',18,6,'Tiezheng Song'),'Blank2','NYC') as Introduction






