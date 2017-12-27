---- in VS exist
Use AdventureWorks2012

--------------- 1. Exist

---- Return Type: Boolean

---- The exists keyword can be used in that way, 
---- but really it's intended as a way to avoid unnecessary counting:

-- this statement needs to check the entire table
Select Count(*) 
From Person.Person
Where BusinessEntityID=1

-- this statement is true as soon as one match is found

Select Count(*) 
From Person.Person
Where Exists ( 
               Select * 
			   From Person.Person 
			   Where BusinessEntityID=1
			   )

----------- 2. In

---- Return Type: Boolean

---- The in is best used where you have a static list to pass:
 Select * 
 From Person.Person
 where BusinessEntityID in (1, 2, 3)

----------- 3. Any
---- Compares a scalar value with a single-column set of values. 
---- SOME and ANY are equivalent.
---- If the value of test_expression is equal to any value returned by
---- subquery or is equal to any expression from the comma-separated list, 
---- the result value is TRUE; otherwise, the result value is FALSE.
---- Using NOT IN negates the subquery value or expression.

---- Return Type: Boolean

---- Example 1

Create Database TestAnySome
Use TestAnySome

CREATE TABLE T1
(ID int) ;
GO
INSERT T1 VALUES (1) ;
INSERT T1 VALUES (2) ;
INSERT T1 VALUES (3) ;
INSERT T1 VALUES (4) ;

Select * From T1

--- 
IF 3 < Any (SELECT ID FROM T1)
PRINT 'TRUE' 
ELSE
PRINT 'FALSE' ;

---
IF 3 < Some (SELECT ID FROM T1)
PRINT 'TRUE' 
ELSE
PRINT 'FALSE' ;

--- 
IF 3 < ALL (SELECT ID FROM T1)
PRINT 'TRUE' 
ELSE
PRINT 'FALSE' ;

---- Example 2

---- The following example creates a stored procedure that determines 
---- whether all the components of a specified SalesOrderID 
---- in the AdventureWorks2012 database can be manufactured 
---- in the specified number of days.
 
---- The example uses a subquery to create a list of the number of
---- DaysToManufacture value for all the components of the specific 
---- SalesOrderID, and then tests whether any of the values 
---- that are returned by the subquery are greater 
---- than the number of days specified.
 
---- If every value of DaysToManufacture that is returned is less 
---- than the number provided, the condition is TRUE
---- and the first message is printed.

CREATE PROCEDURE ManyDaysToComplete @OrderID int, @NumberOfDays int
AS
IF 
@NumberOfDays < SOME
   (
    SELECT DaysToManufacture
    FROM AdventureWorks2012.Sales.SalesOrderDetail A
    JOIN AdventureWorks2012.Production.Product B
    ON A.ProductID = B.ProductID 
    WHERE SalesOrderID = @OrderID
   )
PRINT 'At least one item for this order cannot be manufactured in specified number of days.'
ELSE 
PRINT 'All items for this order can be manufactured in the specified number of days or less.' ;

Execute ManyDaysToComplete 1,2