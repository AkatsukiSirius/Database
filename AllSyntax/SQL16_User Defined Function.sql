-------------------- Inline Function

-------------------- Multiline Function
-------------------- Sumation

create function udf_determinant(@input1 int,@input2 int)
returns int
as
     begin
	      return @input1+@input2
	 end
select dbo.udf_determinant(12,22) as 'results'


-------------------- Date
create function udf_nondeter()
returns int
as 
      begin
	       declare @var int
		   set @var=datepart(ms,getdate())
		   return @var
      end

select dbo.udf_nondeter() as 'mon deter'

-------------------
-- UDF
create function emp1(@empID int)
returns table
as 
       return (select *
	            from AdventureWorks2012.HumanResources.Employee
				where BusinessEntityID=@empID)

select * 
from dbo.emp1(148)
go

-- Sprocs

go
create proc sp_input_test(@emp int) as
     select jobtitle
	 from AdventureWorks2012.HumanResources.Employee
	 where BusinessEntityID=@emp

exec sp_input_test 100

drop proc sp_input_test



--------------------

create function emp2(@empID int)
returns @tabvar table(ID INT,Firstname varchar(50),Lastname varchar(50),jobtitle varchar(100))
as
   begin
        insert into @tabvar
		     select Employee.BusinessEntityID,FirstName,LastName,JobTitle
			 from AdventureWorks2012.HumanResources.Employee
			 inner join AdventureWorks2012.Person.Person
			 on Employee.BusinessEntityID=person.BusinessEntityID
			 where Employee.BusinessEntityID=@empID

	    return
	end

select * from emp2(2)

--------------------- Exmaple

USE TEST_DB

CREATE FUNCTION IsInFiscalYear (@YearEnding DATE, @CompareDate DATE)
RETURNS BIT
AS
BEGIN
     DECLARE @out BIT = 0; --Assume FALSE
	 IF @CompareDate BETWEEN DATEADD(day, 1, DATEADD(year, -1, @YearEnding))
AND @YearEnding
     SET @out = 1; --Conditionally set to TRUE
RETURN @out;
END;

---------------------- Example

CREATE FUNCTION IsInFiscalYear2005 (@YearEnding DATETIME, @CompareDate DATETIME)
RETURNS BIT
AS
BEGIN
     DECLARE @out BIT,
     @YearEndingTruncated DATETIME,
     @CompareDateTruncated DATETIME;
     SET @out = 0;
     SELECT
     @YearEndingTruncated = CAST(CONVERT(varchar(12), @YearEnding, 101) AS DATETIME),
     @CompareDateTruncated = CAST(CONVERT(varchar(12), @CompareDate, 101) AS DATETIME);
     IF @CompareDateTruncated BETWEEN DATEADD(DAY,1,DATEADD(YEAR,-1, @YearEndingTruncated))
                              AND @YearEndingTruncated
     SET @out = 1;
	 RETURN @out;
END

DECLARE @YearEnding DATE = DATEADD(MONTH, 15, SYSDATETIME());
SELECT *
FROM Orders
WHERE dbo.IsInFiscalYear(@YearEnding, OrderDate) = 1;

------------------------ Example

USE AdventureWorks2012;
SELECT Name,ListPrice,
       (SELECT AVG(ListPrice) FROM Production.Product) AS Average,
       ListPrice - (SELECT AVG(ListPrice) FROM Production.Product) AS Difference
FROM Production.Product
WHERE ProductSubcategoryID = 1; -- The Mountain Bikes Sub-cat

----- Create Function do the same thing

CREATE FUNCTION dbo.AveragePrice()
RETURNS money
WITH SCHEMABINDING
AS
BEGIN
     RETURN (SELECT AVG(ListPrice) FROM Production.Product);
END

GO

CREATE FUNCTION dbo.PriceDifference(@Price money)
RETURNS money
AS
BEGIN
     RETURN @Price - dbo.AveragePrice();
END

---- Execute it

USE AdventureWorks2012
SELECT Name,ListPrice,
       dbo.AveragePrice() AS Average,
       dbo.PriceDifference(ListPrice) AS Difference
FROM Production.Product
WHERE ProductSubcategoryID = 1; -- The Mountain Bikes Sub-cat

----------------------------- Example
USE AdventureWorks2012
GO
CREATE FUNCTION dbo.fnContactList()
RETURNS TABLE
AS
  RETURN (SELECT BusinessEntityID,
                 LastName + ',' + FirstName AS Name
                 FROM Person.Person);
GO

---- Execute

SELECT *
FROM dbo.fnContactList();

----------------------------- Example use view in previous example

--CREATE your view
CREATE VIEW vFullContactName
AS
  SELECT p.BusinessEntityID,
         LastName + ',' + FirstName AS Name,
         ea.EmailAddress
  FROM Person.Person as p
  LEFT OUTER JOIN Person.EmailAddress ea
  ON ea.BusinessEntityID = p.BusinessEntityID;
GO

--- can’t parameterize things right in the view itself, so use where clause to filter condition

SELECT *
FROM vFullContactName
WHERE Name LIKE 'Ad%';

--- Use Function to escapsulate it

USE AdventureWorks2012;
GO
CREATE FUNCTION dbo.fnContactSearch(@LastName nvarchar(50))
RETURNS TABLE
AS
RETURN (SELECT p.BusinessEntityID,
               LastName + ', ' + FirstName AS Name,
               ea.EmailAddress
        FROM Person.Person as p
        LEFT OUTER JOIN Person.EmailAddress ea
        ON ea.BusinessEntityID = p.BusinessEntityID
        WHERE LastName Like @LastName + '%');
GO

SELECT *
FROM fnContactSearch('Ad');


---------------------- Example System Function
USE TEST_DB
CREATE TABLE TestIdent
(
IDCol int IDENTITY
PRIMARY KEY
);
CREATE TABLE TestChild1
(
IDcol int
PRIMARY KEY
FOREIGN KEY
REFERENCES TestIdent(IDCol)
);
CREATE TABLE TestChild2
(
IDcol int
PRIMARY KEY
FOREIGN KEY
REFERENCES TestIdent(IDCol)
);

/*****************************************
** This script illustrates how the identity
** value gets lost as soon as another INSERT
** happens
****************************************** */
DECLARE @Ident INT; -- This will be a holding variable
/* We’ll use it to show how you can
** move values from system functions
** into a safe place.
*/

INSERT INTO TestIdent --- Where indentity occurs
  DEFAULT VALUES;

SET @Ident = SCOPE_IDENTITY();

PRINT 'The value we you got originally from SCOPE_IDENTITY() was ' 
+CONVERT(varchar(2),@Ident);

PRINT 'The value currently in SCOPE_IDENTITY() is '
+ CONVERT(varchar(2),SCOPE_IDENTITY());

/* On this first INSERT using SCOPE_IDENTITY(), you’re going to get lucky.
** You’ll get a proper value because there is nothing between the
** original INSERT and this one. You’ll see that on the INSERT that
** will follow after this one, you won’t be so lucky anymore. */

INSERT INTO TestChild1 VALUES (SCOPE_IDENTITY());

PRINT 'The value you got originally from SCOPE_IDENTITY() was ' +
CONVERT(varchar(2),@Ident);

IF (SELECT SCOPE_IDENTITY()) IS NULL
   PRINT 'The value currently in SCOPE_IDENTITY() is NULL';
ELSE
   PRINT 'The value currently in SCOPE_IDENTITY() is ' 
   + CONVERT(varchar(2),SCOPE_IDENTITY());

-- The next line is just a spacer for your print out
PRINT '';

/* The next line is going to blow up because the one column in
** the table is the primary key, and primary keys can’t be set
** to NULL. SCOPE_IDENTITY() will be NULL because you just issued an
** INSERT statement a few lines ago, and the table you did the
** INSERT into doesn’t have an identity field. Perhaps the biggest
** thing to note here is when SCOPE_IDENTITY() changed - right after
** the next INSERT statement. */
INSERT INTO TestChild2
VALUES
      (SCOPE_IDENTITY());


--------------------------

/*****************************************
** This script illustrates how the identity
** value gets lost as soon as another INSERT
** happens
****************************************** */
DECLARE @Ident1 int; -- This will be a holding variable
/* You’ll use it to show how you can
** move values from system functions
** into a safe place.
*/

INSERT INTO TestIdent
DEFAULT VALUES;

SET @Ident1 = SCOPE_IDENTITY();

PRINT 'The value you got originally from SCOPE_IDENTITY() was ' +
CONVERT(varchar(2),@Ident);

PRINT 'The value currently in SCOPE_IDENTITY() is '
+ CONVERT(varchar(2),SCOPE_IDENTITY());

/* On this first INSERT using SCOPE_IDENTITY(), you’re going to get lucky.
** You’ll get a proper value because there is nothing between your
** original INSERT and this one. You’ll see that on the INSERT that
** will follow after this one, you won’t be so lucky anymore. */

INSERT INTO TestChild1
VALUES
(SCOPE_IDENTITY());

PRINT 'The value you got originally from SCOPE_IDENTITY() was ' + 
      CONVERT(varchar(2),@Ident1);

IF (SELECT SCOPE_IDENTITY()) IS NULL
   PRINT 'The value currently in SCOPE_IDENTITY() is NULL';
ELSE
   PRINT 'The value currently in SCOPE_IDENTITY() is '
   + CONVERT(varchar(2),SCOPE_IDENTITY());
-- The next line is just a spacer for your print out
PRINT '';

/* This time all will go fine because you are using the value that
** you have placed in safekeeping instead of SCOPE_IDENTITY() directly.*/

INSERT INTO TestChild2
VALUES (@Ident1);