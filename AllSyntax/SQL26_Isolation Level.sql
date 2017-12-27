----------------------------------
set transaction isolation level read committed

begin tran
   select * from AdventureWorks2012.HumanResources.Employee
commit tran