--1. while statement
declare @counter int

set @counter=0

while @counter<10
begin
    print @counter
    set @counter=@counter+1
end


use AdventureWorks2012

declare @counter int,@maxrowlimite int
declare @string varchar(200),@ID int,@job varchar(100),@gender char(1)

set @counter=1

set @maxrowlimite=(select count(*) from HumanResources.Employee)

while @counter<=@maxrowlimite
begin
    select @ID=BusinessEntityID,@JOB=JobTitle,@gender=Gender
	FROM HumanResources.Employee
	WHERE BusinessEntityID=@counter

	SET @string='person with ID'+cast(@ID as varchar(3))+'is working a(n)'+@job+'and is '+@gender+'.'
	print @string

	set @counter=@counter+1
end

--2. if...else statement

declare @number int
set @number=10
if @number>10
   print 'The number is large'
else
   print 'The number is small'
---
declare @number int
set @number=2
if @number>10
   print 'The number is large'
else
       if @number>5
	      print 'The number is medium'
	   else
	      print 'The number is small'
---
declare @number int
set @number=7
if @number>10
   print 'The number is large'
else if @number>=5 and @number<10
	      print 'The number is medium'
	   else if @number<5
	      print 'The number is small'
---
if(select count(*) from HumanResources.Employee where gender='M')
   >
   (select count(*) from HumanResources.Employee where gender='F')

   print 'There are more males working'
else
   print 'there are more females working'

--3. Case statement
select BusinessEntityID,JobTitle,OrganizationLevel,
job_lever=case organizationlevel 
            when 0 then 'boss'
		    when 1 then 'supervisors'
		    when 2 then 'manager'
		    when 3 then 'worker'
		    when 4 then 'interns'
		  end
from HumanResources.Employee
order by OrganizationLevel

