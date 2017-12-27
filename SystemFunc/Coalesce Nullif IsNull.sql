Use AdventureWorks2012
----------------------------- Coalesce
---- Returns the first non-null expression in a list
---- otherwise it returns null

---- Coalesce(expression1, expression2,...)
---- Same as,
---- case when expression1 is not null expression1
----      when expression2 is not null expression2,etc


---- Example 1
---- Shows how COALESCE selects the data from the first column 
---- that has a nonnull value.
---- This example uses the AdventureWorks2012 database.

Select Name, Class, Color, ProductNumber,
Coalesce(Class, Color, ProductNumber) AS FirstNotNull
From Production.Product;

---------------------------- Nullif

---- Returns null if a condition is true, and the second

---- Nullif(expression1,expression2,...)
---- Same as,
---- case when expression1=expression2 then Null
---- else expression1

---- Example 1

------------- Returning budget amounts that have not changed

---- The following example creates a budgets table to show 
---- a department (dept) its current budget (current_year) 
---- and its previous budget (previous_year). 

---- For the current year, 

---- NULL is used for departments 
---- with budgets that have not changed from the previous year,

---- 0 is used for budgets that have not yet been determined. 

---- To find out the average of only those departments 
---- that receive a budget and to include the budget value 
---- from the previous year (use the previous_year value, 
---- where the current_year is NULL), 
---- combine the NULLIF and COALESCE functions.

IF OBJECT_ID ('dbo.budgets','U') IS NOT NULL
   DROP TABLE budgets;
GO
SET NOCOUNT ON;

CREATE TABLE dbo.budgets
(
   dept tinyint   IDENTITY,
   current_year decimal NULL,
   previous_year decimal NULL
);

INSERT budgets VALUES(100000, 150000);
INSERT budgets VALUES(NULL, 300000);
INSERT budgets VALUES(0, 100000);
INSERT budgets VALUES(NULL, 150000);
INSERT budgets VALUES(300000, 250000);
GO  
SET NOCOUNT OFF;

Select * From budgets

Select
AVG(NULLIF(COALESCE(current_year,previous_year), 0.00))
AS 'Average Budget'
From budgets;
GO

---- Example 2

---- Comparing NULLIF and CASE

---- To show the similarity between NULLIF and CASE, 
---- the following queries evaluate whether the values in the MakeFlag
---- and FinishedGoodsFlag columns are the same. 
---- The first query uses NULLIF. 
---- The second query uses the CASE expression.

---- 1) 



USE AdventureWorks2012;
GO
Select ProductID, MakeFlag, FinishedGoodsFlag, 
Nullif(MakeFlag,FinishedGoodsFlag) AS 'Null if Equal'
From Production.Product
Where ProductID < 10;
GO

---- 2)
 
Select ProductID, MakeFlag, FinishedGoodsFlag,'Null if Equal' =
   Case
       When MakeFlag = FinishedGoodsFlag Then NULL
       Else MakeFlag
   End
From Production.Product
Where ProductID < 10;
GO

---------------------------- IsNull
---- Alternate value if the expression is null.

---- IsNull(expression1,expression2)
