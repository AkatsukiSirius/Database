Use AdventureWorks2012

select * from HumanResources.Employee
select * from person.person

select He.BusinessEntityID,PP.BusinessEntityID
from HumanResources.Employee HE
     right join person.person PP
	 on He.BusinessEntityID=PP.BusinessEntityID
	 where HE.BusinessEntityID is null

select He.BusinessEntityID,PP.BusinessEntityID
from HumanResources.Employee HE
     left join person.person PP
	 on He.BusinessEntityID=PP.BusinessEntityID
	 where HE.BusinessEntityID is null

select He.BusinessEntityID,PP.BusinessEntityID
from HumanResources.Employee HE
     full outer join person.person PP
	 on He.BusinessEntityID=PP.BusinessEntityID
	 where HE.BusinessEntityID is null or
	       PP.BusinessEntityID is null

select He.BusinessEntityID,PP.BusinessEntityID
from HumanResources.Employee HE
     cross join person.person PP
	


---- Self Join
use test_DB



create table employee1
(empID int,
name varchar(50),
managedby int)

insert into employee1 values (1,'clark',null)
insert into employee1 values (2,'bruce',1)
insert into employee1 values (3,'nal',1)
insert into employee1 values (4,'maly',3)
insert into employee1 values (5,'diana',2)

select * from employee1
truncate table employee1
select emp2.empID,emp1.empID
from employee1 emp1
  left join employee1 emp2
 on emp2.empID=emp1.empID
 where emp1.empID is null
 
 
select *
from employee1 emp1
cross join employee1 emp2
