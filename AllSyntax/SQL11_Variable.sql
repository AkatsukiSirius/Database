use AdventureWorks2012
go



declare @random_number int
set @random_number= DatePart(ms,Getdate())
print @random_number


declare @value int
set @value=34
select *
from AdventureWorks2012.HumanResources.Employee
where BusinessEntityID=@value

go

---------------------------------- Run String
declare @ID INT,@STRING VARCHAR(200)
set @ID=125
set @string='select firstname+lastname
             from adventureworks2012.person.person
			 where businessentityID='+cast(@ID as varchar)

print @string
exec (@string)

SELECT @@VERSION

SELECT @@LANGUAGE

SELECT @@ROWCOUNT

SELECT @@ERROR

SELECT @@IDENTITY

