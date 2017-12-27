---------------------------Try ....catch----------------------------

---- Allows to monitor for error, if error then execute Catch, Else continue
---- When we know where error may occur
---- Return the error message defined by user
---- Used when we know where the error may occur

begin try
    select BusinessEntityID+JobTitle  from HumanResources.Employee
end try

begin catch
    print'please correct your syntax'
end catch

----------------------------Raiserror-------------------------------
---- allow user to create his own error message with different error levels can also include error
---- 0~10 Warning: sth still execute but no result
---- 11~18 Critical: should int give char
---- 19~ 24 Sys Critical: highest, mandatory must be lock, damage sys even hard drive 



begin try
    select BusinessEntityID+JobTitle  from HumanResources.Employee
end try

begin catch
    raiserror('There has been an error',13,2)
end catch


go

begin try
    select BusinessEntityID+JobTitle  from HumanResources.Employee
end try

begin catch
    raiserror('There has been an error',22,2)
	with log
end catch
go

-----------------------------@@Error--------------------------------
---- Retrieve the error message number for last statement run 


select @@ERROR 

select * from sys.messages
where message_id=@@ERROR


---------------------------If Else----------------------------------

---- Address all the possibilities come in.
---- It can anticipate possible error and we can set proper condition on it
---- Used to check is the number entered? Is it acceptable? Does it still exist? 
---- Mainly for logical use, one can anticipate possible errors and make proper conditions 


----------------------------Common Table Expression------------------

---- It specifies a temporary result set. ABOUT = Derived Table + View. 
---- But it can be self referencing, this feature
---- makes it possible to use CTE for recursive purposes
---- And CTE is more organized, sometimes we can use it to replace DT.

---- Often used to help to display the syntax in a more presentable manner 
---- instead of just using numerous joins or subqueries.

---- ONLY ONE operation can be performed after creating a Common Table Expression 

---- Add WITH clause before other DML clause.
---- The WITH clause can include one or more CTEs, as shown in the following syntax:

with CTETEST(ID,JOB,GENDER)
as
(select BusinessEntityID,JobTitle,Gender
 from HumanResources.Employee)
 select * from CTETEST
 go

 with repeatingMEssage(Message,Length)
 AS
 (select message=cast('I like ' as varchar(300)),
         LEN('I like ')
union all
select cast(message+'SQL Server!' as varchar(300)),
         LEN(message) from repeatingMEssage
where Length < 300)
select message,length
from repeatingMEssage
go