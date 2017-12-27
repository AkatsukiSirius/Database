--------------------------------Merge Join--------------------------
use AdventureWorks2012
select * from Person.Person
select * from HumanResources.Employee

select * from HumanResources.Employee
inner merge join Person.Person
on Employee.BusinessEntityID=person.BusinessEntityID
go

--------------------------------Query Hints--------------------------

select * from HumanResources.Employee
with (index(AK_Employee_NationalIDNumber))
inner join Person.Person
on Employee.BusinessEntityID=person.BusinessEntityID
go

-------------------------------Table Hints---------------------------

select * from HumanResources.Employee with(xlock)
go