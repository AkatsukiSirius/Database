use test_DB
go

create procedure sp_emp_data as
select JobTitle,Gender,firstname,lastname 
from AdventureWorks2012.HumanResources.Employee
     inner join AdventureWorks2012.Person.Person
	 on employee.BusinessEntityID=person.BusinessEntityID

exec sp_emp_data

drop proc sp_emp_data

-----------------------


go
create proc sp_temp_table as
if OBJECT_ID('tempdb.dbo.#testtable') is not null
   drop table #testtable
else
   create table #testtable
               ( ID int,name varchar(50))

exec sp_temp_table


drop proc sp_temp_table


--------
go
create proc sp_input_test(@emp int) as
     select jobtitle
	 from AdventureWorks2012.HumanResources.Employee
	 where BusinessEntityID=@emp

exec sp_input_test 100

drop proc sp_input_test

--------------- Example: Summation
create proc sp_sumation (@a int,@b int,@c int out)
as
select @c=@a+@b

---- Test

declare @result int
execute sp_sumation 1,3,@result out
print @result

---------------- Example: Call Sproc in Sproc
create proc sp_message
as
print 'this is from another sproc'

create proc sp_anothersproc
as
exec sp_message

----
Exec sp_anothersproc

--------------------------------

go
create proc sp_output_test(@ID int,@job varchar(50) out) as
select @job=jobtitle
from AdventureWorks2012.HumanResources.Employee
where BusinessEntityID=@ID
 



------
declare @title varchar(100)
exec sp_output_test 12,@title out
print @title
------ 

--------------------------------- 

go

create proc sp_default_test (@ID int =null,@lname varchar(50) =null)
as
begin
 if @ID is not null and @lname is null
    select FirstName+' '+LastName as 'name',Title
	from AdventureWorks2012.Person.Person
	where BusinessEntityID=@ID
	    else if @ID is null and @lname is not null
             select FirstName+' '+LastName as 'name',Title
	         from AdventureWorks2012.Person.Person
	         where LastName=@lname
	             else if @ID is not null and @lname is not null
                     select FirstName+' '+LastName as 'name',Title
	                 from AdventureWorks2012.Person.Person
	                 where BusinessEntityID=@ID and
	                       LastName=@lname
else
    print 'please provide ID or last name.thank you'
end

exec sp_default_test 785
exec sp_default_test @lname='degrasse'
exec sp_default_test 785,'Degrasse'
exec sp_default_test 

drop proc sp_default_test

--------------------------------- Change The Execution Plan
----------Alter
go
alter proc sp_output_test (@ID int,@job varchar(100) out) as
  select @job=jobtitle
  from AdventureWorks2012.HumanResources.Employee
  where BusinessEntityID=@ID

----------with recompile
go
create proc sp_output_test with reconpil as
select * from


--------System stored proc

exec sp_recompile sp_output_test


------------------- Example

USE AdventureWorks2012;
GO
CREATE PROC spEmployeeByName
@LastName nvarchar(50)
AS
SELECT p.LastName, p.FirstName, e.JobTitle, e.HireDate
FROM Person.Person p
JOIN HumanResources.Employee e
ON p. BusinessEntityID = e.BusinessEntityID
WHERE p.LastName LIKE @LastName + '%';

EXEC spEmployeeByName 'Dobney';

DROP PROC dbo.spEmployeeByName


---- NOTE: Be careful using wildcard matches, such as the LIKE statement used
---- in the preceding code. This particular example would likely perform okay because
---- the wildcard is at the end. Keep in mind that wildcards used at the beginning of a
---- search eff ectively eliminate the opportunity for SQL Server to use an index
---- because any starting character is potentially a match.

------------------ Exmaple Default Vaule
USE AdventureWorks2012;
DROP PROC spEmployeeByName; -- Get rid of the previous version
GO
CREATE PROC spEmployeeByName
@LastName nvarchar(50) = NULL
AS
IF @LastName IS NOT NULL
SELECT p.LastName, p.FirstName, e.JobTitle, e.HireDate
FROM Person.Person p
JOIN HumanResources.Employee e
ON p.BusinessEntityID = e.BusinessEntityID
WHERE p.LastName LIKE @LastName + '%';
ELSE ---- without this part, nothing in result set, since default value is null
SELECT p.LastName, p.FirstName, e.JobTitle, e.HireDate
FROM Person.Person p
JOIN HumanResources.Employee e
ON p.BusinessEntityID = e.BusinessEntityID;

-------------

EXEC spEmployeeByName;

------------------------- Example:Creating Output Parameters

-- uspLogError logs error information in the ErrorLog table about the
-- error that caused execution to jump to the CATCH block of a
-- TRY...CATCH construct. This should be executed from within the scope
-- of a CATCH block otherwise it will return without inserting error
-- information.

CREATE PROCEDURE [dbo].[uspLogError]
@ErrorLogID [int] = 0 OUTPUT -- contains the ErrorLogID of the row inserted
AS -- by uspLogError in the ErrorLog table
BEGIN
SET NOCOUNT ON;

-- Output parameter value of 0 indicates that error
-- information was not logged

SET @ErrorLogID = 0;
BEGIN TRY
-- Return if there is no error information to log
IF ERROR_NUMBER() IS NULL
RETURN;

-- Return if inside an uncommittable transaction.
-- Data insertion/modification is not allowed when
-- a transaction is in an uncommittable state.

IF XACT_STATE() = -1
BEGIN
PRINT 'Cannot log error since the current transaction is in an
uncommittable state.'+ 
'ROLLBACK the transaction before executing uspLogError in order
to successfully log error information.';
RETURN;
END
INSERT [dbo].[ErrorLog]
(
[UserName],
[ErrorNumber],
[ErrorSeverity],
[ErrorState],
[ErrorProcedure],
[ErrorLine],
[ErrorMessage]
)
VALUES
(
CONVERT(sysname, CURRENT_USER),
ERROR_NUMBER(),
ERROR_SEVERITY(),
ERROR_STATE(),
ERROR_PROCEDURE(),
ERROR_LINE(),
ERROR_MESSAGE()
);

-- Pass back the ErrorLogID of the row inserted

SET @ErrorLogID = @@IDENTITY;
END TRY
BEGIN CATCH
PRINT 'An error occurred in stored procedure uspLogError: ';
EXECUTE [dbo].[uspPrintError];
RETURN -1;
END CATCH
END;



------------------------ Example
---- This stored procedure returns a single OUT parameter (managerID), 
---- which is an integer, based on the specified IN parameter (employeeID), 
---- which is also an integer. 
---- The value that is returned in the OUT parameter is the ManagerID 
---- based on the EmployeeID that is contained in the HumanResources.Employee table.
CREATE PROCEDURE GetImmediateManager
   @BusinessEntityID INT,
   @NationalIDNumber INT OUTPUT
AS
BEGIN
   SELECT @NationalIDNumber = NationalIDNumber
   FROM HumanResources.Employee 
   WHERE BusinessEntityID = @BusinessEntityID
END

DECLARE @NationalIDNumber INT
EXECUTE GetImmediateManager 1,@NationalIDNumber OUT
PRINT @NationalIDNumber


--------------- Example: How to use return

USE AdventureWorks2012;
GO
CREATE PROC spTestReturns
AS
DECLARE @MyMessage varchar(50);
DECLARE @MyOtherMessage varchar(50);
SELECT @MyMessage = 'Hi, it''s that line before the RETURN';
PRINT @MyMessage;
RETURN;
SELECT @MyOtherMessage = 'Sorry, but you won''t get this far';
PRINT @MyOtherMessage;
RETURN;

EXEC dbo.spTestReturns

--- To capture the value of a RETURN statement, 
--- you need to assign it to a variable during your EXEC statement.

DECLARE @Return int;
EXEC @Return = spTestReturns;
SELECT @Return AS ReturnValue; --- the default value is zero, also means no error

-------------------- Example Return

USE AdventureWorks2012;
GO
ALTER PROC spTestReturns ---- Use alter to make change
AS
DECLARE @MyMessage varchar(50);
DECLARE @MyOtherMessage varchar(50);
SELECT @MyMessage = 'Hi, it''s that line before the RETURN';
PRINT @MyMessage
RETURN 100;
SELECT @MyOtherMessage = 'Sorry, but we won''t get this far';
PRINT @MyOtherMessage;
RETURN;



DECLARE @Return int;
EXEC @Return = spTestReturns;
SELECT @Return AS ReturnValue; 

--------------------- Example Error Handling

USE AdventureWorks2012;
GO
INSERT INTO Person.BusinessEntityContact
(BusinessEntityID
,PersonID
,ContactTypeID)
VALUES
(0,0,1);
 

 ----- Making Use of @@

USE AdventureWorks2012;
GO
DECLARE @Error int;
-- Bogus INSERT - there is no PersonID or BusinessEntityID of 0. Either of
-- these could cause the error we see when running this statement.
INSERT INTO Person.BusinessEntityContact
(BusinessEntityID
,PersonID
,ContactTypeID)
VALUES
(0,0,1);
-- Move our error code into safekeeping. Note that, after this statement,
-- @@Error will be reset to whatever error number applies to this statement
SELECT @Error = @@ERROR;
-- Print out a blank separator line
PRINT '';
-- The value of our holding variable is just what we would expect
PRINT 'The Value of @Error is ' + CONVERT(varchar, @Error);
-- The value of @@ERROR has been reset - it’s back to zero
-- since our last statement (the PRINT) didn’t have an error.
PRINT 'The Value of @@ERROR is ' + CONVERT(varchar, @@ERROR);

----- Using @@ERROR in a Sproc

USE AdventureWorks2012;
GO
INSERT INTO Person.BusinessEntityContact
(BusinessEntityID
,PersonID
,ContactTypeID)
VALUES(0,0,1);
---- Create Stored Procedure
USE AdventureWorks2012
GO
CREATE PROC spInsertValidatedBusinessEntityContact
            @BusinessEntityID int,
            @PersonID int,
            @ContactTypeID int
AS
BEGIN
            DECLARE @Error int;
            INSERT INTO Person.BusinessEntityContact 
			(BusinessEntityID,PersonID,ContactTypeID)
			VALUES
			(@BusinessEntityID, @PersonID, @ContactTypeID);
			SET @Error = @@ERROR;
			IF @Error = 0
			   PRINT 'New Record Inserted';
			ELSE
			   BEGIN
			        IF @Error = 547 -- Foreign Key violation. Tell them about it.
			           PRINT 'At least one provided parameter was not found. Correct and retry';
					ELSE -- something unknown
                       PRINT 'Unknown error occurred. Please contact your system admin';
			   END
END


EXEC spInsertValidatedBusinessEntityContact 1, 1, 11;

EXEC spInsertValidatedBusinessEntityContact 0, 1, 11;


----- Do it with Try Catch
USE TEST_DB
BEGIN TRY
-- Try and create our table
CREATE TABLE OurIFTest(
    Col1 int PRIMARY KEY
	)
END TRY
BEGIN CATCH
    -- Uh oh, something went wrong, see if it’s something
    -- we know what to do with
	DECLARE @ErrorNo int,
            @Severity tinyint,
		    @State smallint,
		    @LineNo int,
		    @Message nvarchar(4000);
	SELECT
            @ErrorNo = ERROR_NUMBER(),
			@Severity = ERROR_SEVERITY(),
			@State = ERROR_STATE(),
			@LineNo = ERROR_LINE (),
			@Message = ERROR_MESSAGE();
	IF @ErrorNo = 2714 -- Object exists error, we knew this might happen
	   PRINT 'WARNING: Skipping CREATE as table already exists';
	ELSE -- hmm, we don’t recognize it, so report it and bail
	   RAISERROR(@Message, 16, 1 );
END CATCH


--- Try it with inline error checking

CREATE TABLE OurIFTest(
Col1 int PRIMARY KEY
);
IF @@ERROR != 0
PRINT 'Problems!';
ELSE
PRINT 'Everything went OK!';

-- Without the TRY block, SQL Server aborts the script entirely on the particular
-- error you’re generating here
-- Difference between inline error checking and Try Catch:
-- Notice that your PRINT statements never got a chance to execute — SQL Server had already
-- terminated processing. With TRY/CATCH you could trap and handle this error, 
-- but using inline error checking, your attempts to trap an error like this will fail.

----------------------- Example Handling Errors Before They Happen
DROP PROC HumanResources.uspUpdateEmployeeHireInfo2

USE AdventureWorks2012;
GO
CREATE PROCEDURE HumanResources.uspUpdateEmployeeHireInfo2
                 @BusinessEntityID int,
                 @JobTitle nvarchar(50),
                 @HireDate datetime,
                 @RateChangeDate datetime,
                 @Rate money,
                 @PayFrequency tinyint,
                 @CurrentFlag dbo.Flag
WITH EXECUTE AS CALLER
AS
BEGIN
     SET NOCOUNT ON;
	 
	 -- To Handle Error 1: Set up “constants” for error codes
     
	 DECLARE @BUSINESS_ENTITY_ID_NOT_FOUND int = -1000,
             @DUPLICATE_RATE_CHANGE int = -2000;
	 -- To Handle Error 1;
	 -- By doing so, I’ll get away
     -- from just returning numbers and, instead, 
	 -- RETURN a variable name that makes my code more
     -- readable by indicating the nature of the error I’m returning.
	 -- Use Negative Value to indicate errors
	 -- Use Posotive Value to indicate native information

	 BEGIN TRY
	        BEGIN TRANSACTION;

			UPDATE HumanResources.Employee
			SET JobTitle = @JobTitle,
			    HireDate = @HireDate, -- To Handle Error 1
				CurrentFlag = @CurrentFlag
			WHERE BusinessEntityID = @BusinessEntityID;

			-- To Handle Error 1:
			IF @@ROWCOUNT > 0 -- things happened as expected
			   INSERT INTO HumanResources.EmployeePayHistory
			   (BusinessEntityID,RateChangeDate,Rate,PayFrequency)
               VALUES 
			   (@BusinessEntityID, @RateChangeDate, @Rate, @PayFrequency);
			ELSE
			-- since the effected row in this case is zero, which means
			-- doesn't find any matching row 
			-- ruh roh, the update didn’t happen, so skip the insert,
            -- set the return value and exit, REMOVE HireDate
			-- To Handle Error 1;
               BEGIN
                    PRINT 'BusinessEntityID Not Found';
					ROLLBACK TRAN;
					RETURN @BUSINESS_ENTITY_ID_NOT_FOUND;
			   END
			   COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
	-- Rollback any active or uncommittable transactions before
	-- inserting information in the ErrorLog
    IF @@TRANCOUNT > 0
    BEGIN
         ROLLBACK TRANSACTION;
    END
	EXECUTE dbo.uspLogError;
	-- To Handle Error 2:
	IF ERROR_NUMBER() = 2627 -- Primary Key violation
	   BEGIN
            PRINT 'Duplicate Rate Change Found';
            RETURN @DUPLICATE_RATE_CHANGE;
       END
	-- To Handle Error 2;
    END CATCH;
END;

--- There are two statements (one to update the
--- existing employee record and one to handle the additional history record) 
--- plus a very generic error handler.

--- Error 1: An employee whose BusinessEntityID doesn’t already exist 
--- The UPDATE statement in the sproc actually runs just fine (no errors) 
--- without a valid BusinessEntityID. It just fails to
--- find a match and winds up affecting zero rows; 
--- the error here is logical in nature, and SQL Server sees no problem with it at all. 
--- You should detect this condition yourself and trap it at this point 
--- before the sproc continues (because there is a foreign key between
--- EmployeePayHistory and Employee, SQL Server winds up raising an error on the INSERT
--- statement when it can’t find a matching BusinessEntityID).

--- Error 2: Two updates affecting the same BusinessEntityID at the same RateChangeDate
--- Again, the UPDATE statement has no issues with such an update, 
--- but the INSERT statement does (the primary key for EmployeePayHistory is the composite 
--- of BusinessEntityID and RateChangeDate). This is a primary key violation problem.

DECLARE @Return int;
EXEC @Return = HumanResources.uspUpdateEmployeeHireInfo2
@BusinessEntityID = 1,
@JobTitle = 'His New Title',
@HireDate = '1996-07-01',
@RateChangeDate = '2008-07-31',
@Rate = 15,
@PayFrequency = 1,
@CurrentFlag = 1;
SELECT @Return AS ReturnValue;


------- Manually Raising Errors
RAISERROR ('Hi there, I''m an ERROR', 1, 1);

--- Notice that the assigned message number, 
--- even though you didn’t supply one, is 50000. 
--- This is the default error value for any ad hoc error. 
--- It can be overridden using the WITH SETERROR option.

----- Example Error Argument
RAISERROR ('This is a sample parameterized %s, along with a zero
padding and a sign%+010d',1,1, 'string', 12121);

----- Example Throw Error
USE TEST_DB
BEGIN TRY
      INSERT OurIFTest(Col1) VALUES (1);
END TRY
BEGIN CATCH
      -- Uh oh, something went wrong, see if it’s something
      -- we know what to do with
      PRINT 'Arrived in the CATCH block.';
      DECLARE @ErrorNo int,
              @Severity tinyint,
              @State smallint,
              @LineNo int,
              @Message nvarchar(4000);
      SELECT
              @ErrorNo = ERROR_NUMBER(),
              @Severity = ERROR_SEVERITY(),
              @State = ERROR_STATE(),
              @LineNo = ERROR_LINE (),
              @Message = ERROR_MESSAGE();
      IF @ErrorNo = 2714 -- Object exists error, not likely this time
         PRINT 'WARNING: object already exists';
      ELSE -- hmm, we don’t recognize it, so report it and bail
         THROW;
END CATCH


------------- Example Adding Your Own Custom Error Messages
sp_addmessage
@msgnum = 60000,
@severity = 10,
@msgtext = '%s is not a valid Order date.
Order date must be within 7 days of current date.';

SELECT * FROM sys.messages
sp_dropmessage 60000

----------------- Example Recursion

---- 1. Factorial

USE TEST_DB

DROP PROC spFactorial

CREATE PROC spFactorial
            @ValueIn int,
            @ValueOut int OUTPUT
AS
DECLARE @InWorking int;
DECLARE @OutWorking int;
IF @ValueIn >= 1
   BEGIN
        SELECT @InWorking = @ValueIn - 1;
        EXEC spFactorial @InWorking, @OutWorking OUTPUT;
        SELECT @ValueOut = @ValueIn * @OutWorking;
   END
ELSE
   BEGIN
        SELECT @ValueOut = 1;
   END
RETURN;
GO

DECLARE @WorkingOut int;
DECLARE @WorkingIn int;
SELECT @WorkingIn = 5;
EXEC spFactorial @WorkingIn, @WorkingOut OUTPUT;
PRINT CAST(@WorkingIn AS varchar) + ' factorial is '
+ CAST(@WorkingOut AS varchar);

----- 2. Triangular

CREATE PROC spTriangular
            @ValueIn int,
            @ValueOut int OUTPUT
AS
DECLARE @InWorking int;
DECLARE @OutWorking int;
IF @ValueIn != 1
   BEGIN
        SELECT @InWorking = @ValueIn - 1;
        EXEC spTriangular @InWorking, @OutWorking OUTPUT;
        SELECT @ValueOut = @ValueIn + @OutWorking;
   END
ELSE
   BEGIN
        SELECT @ValueOut = 1;
   END
RETURN;
GO

-----

DECLARE @WorkingOut int;
DECLARE @WorkingIn int;
SELECT @WorkingIn = 5;
EXEC spTriangular @WorkingIn, @WorkingOut OUTPUT;
PRINT CAST(@WorkingIn AS varchar) + ' Triangular is '
+ CAST(@WorkingOut AS varchar);



