---- JOIN
---- Is used to combine dataset, based on the matching 
---- condition being give by user.

---- Inner Join
---- Works on the matching values.
---- Which means it will discard the unmatching values
---- in both tables.

---- Outer Join
---- It will preserver the unmatching values
---- From the main table, if no matching is found.



use AdventureWorks2012

select * from HumanResources.Employee

select * from person.Person

select employee.BusinessEntityID
from HumanResources.Employee
     inner join person.person
	 on employee.BusinessEntityID=person.BusinessEntityID

select HE.BusinessEntityID as 'employee',PP.BusinessEntityID as 'person'
from HumanResources.Employee HE
     inner join person.person as PP
	 on HE.BusinessEntityID=PP.BusinessEntityID

select HE.BusinessEntityID as 'employee',PP.BusinessEntityID as 'person'
from HumanResources.Employee HE
     full outer join person.person as PP
	 on HE.BusinessEntityID=PP.BusinessEntityID


select HE.BusinessEntityID as 'employee',PP.BusinessEntityID as 'person'
from HumanResources.Employee HE
     full outer join person.person as PP
	 on HE.BusinessEntityID=PP.BusinessEntityID
	 where HE.BusinessEntityID=PP.BusinessEntityID

select HE.BusinessEntityID as 'employee',PP.BusinessEntityID as 'person'
from HumanResources.Employee HE
     left join person.person as PP
	 on HE.BusinessEntityID=PP.BusinessEntityID

select HE.BusinessEntityID as 'employee',PP.BusinessEntityID as 'person'
from HumanResources.Employee HE
     right join person.person as PP
	 on HE.BusinessEntityID=PP.BusinessEntityID