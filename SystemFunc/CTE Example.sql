----- CTE is a "temporary result set" that exists only within the 
----- scope of a single SQL statement. 
----- It allows access to functionality within that single SQL statement 
----- that was previously only available through use of 
----- functions, temp tables, cursors, and so on.


---- Similar to derived tables, CTE allow a programmer to create  an 
---- intermediary result set which will be further manipulated 
---- by the outer query. 

---- Unlike derived tables, CTE is defined using a WITH clause 
---- within the query that will reference it. 

---- Recursive CTE's can reference themselves and can be very helpful 
---- in implementing common requirements involving hierarchical data. 

---- Since the definition of CTE isn't stored in the database CTE, 
---- is a good alternative to views or user-defined functions for infrequent,
---- "one-off" queries. 

---- If you do wish to re-use a CTE, you can enclose it 
---- in views, user-defined functions or stored procedures. 

---- CTE can also improve code readability by dividing a single complex query
---- into simpler building blocks.


----- https://www.simple-talk.com/sql/t-sql-programming/sql-server-2005-common-table-expressions/

----- 1) CTE basics

with MyCTE(x)
as
(select x='hello')
select x from MyCTE

---- Like a derived table, a CTE lasts only for 
---- the duration of a query but, in contrast to a derived table, 
---- a CTE can be referenced multiple times in the same query. 
---- So, we now we have a way of calculating percentages 
---- and performing arithmetic using aggregates 
---- without repeating queries or using a temp table:

with MyCTE(x) 
as 
( select top 10 x = id from sysobjects ) 
select x, maxx = (select max(x) from MyCTE), 
pct = 100.0 * x / (select sum(x) from MyCTE) from MyCTE



----- 2) CTE and recursion

----- The table defined in the CTE can be 
----- referenced in the CTE itself to give a recursive expression,
----- using union all:

with MyCTE(x)
as
(
select x = convert(varchar(8000),'*')
union all
select x + '*' 
from MyCTE 
where len(x) < 5
)
select x from MyCTE
order by x

---- 3) Parsing CSV values

declare @s varchar(1000)
select @s = 'a,b,cd,ef,zzz,hello'

;with csvtbl(i,j)
as
(
select i=1, j=charindex(',',@s+',')
union all
select i=j+1, j=charindex(',',@s+',',j+1) from csvtbl
where charindex(',',@s+',',j+1) <> 0
)
select substring(@s,i,j-i)
from csvtbl

---- How does this work? 
---- The anchor member, select i=1, j=charindex(',',@s+','), 
---- returns 1 and the location of the first comma. 
---- The recursive member gives the location of the first character 
---- after the comma and the location of the next comma
---- (we append a comma to the string to get the last entry). 
---- The result set is then obtained by using these values in a substring.

---------------------------------------------------------------------

WITH MyCTE AS (
SELECT sc.CustomerID, sc.AccountNumber, sst.Name, pp.Name ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pp
ON sod.ProductID = pp.ProductID
JOIN Sales.Customer sc
ON sc.CustomerID = soh.CustomerID 
JOIN Sales.SalesTerritory sst
ON sc.TerritoryID = sst.TerritoryID
)
SELECT DISTINCT Rear.AccountNumber, Rear.Name
FROM MyCTE Rear --Rear Wheel
JOIN MyCTE Front --Front Wheel
ON Rear.CustomerID = Front.CustomerID
WHERE Rear.ProductName = 'HL Mountain Rear Wheel'
AND Front.ProductName = 'HL Mountain Front Wheel'

declare @random_number int
set @random_number= DatePart(ms,Getdate())
print @random_number

---- MyCTE functions very much like a derived table, 
---- but because it’s defined at the start of the statement,
---- it can be used as many times during the statement as you like.

---- MyCTE retrieves all the combinations of products purchased by customers.

---- It’s easy to see that if you wanted to compare a third product, 
---- you could simply join the CTE in again — say if you wanted to see 
---- whether those wheels were purchased along with a frame.


-------------------------------- Using Multiple CTEs

---- 1. Having started your statement with WITH lets you define not just one, 
---- but many CTEs without repeating the WITH keyword.
 
---- 2. What’s more, each one can use (as a part of its definition) any CTE 
---- defined earlier in the statement. 
---- All you have to do is finish your CTE with a comma and start the next definition. 
---- Working this way can build up a final result with a bit more procedural thinking 
---- (“first I need a complete customer made up of these things, 
---- then I need an order made up of those . . . ”) while 
---- still allowing the query optimizer to have a decent chance 
---- to work things out efficiently using set theory. 
---- For example, let’s try that sales query again, but build it up one step at a time.

Use AdventureWorks2012

WITH 
CustomerTerritory AS (
SELECT sc.CustomerID, sc.AccountNumber, sst.Name TerritoryName
FROM Sales.Customer sc
JOIN Sales.SalesTerritory sst
ON sc.TerritoryID = sst.TerritoryID
), 
MyCTE AS (
SELECT sc.CustomerID, sc.AccountNumber, sc.TerritoryName, pp.Name ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pp
ON sod.ProductID = pp.ProductID
JOIN CustomerTerritory sc
ON sc.CustomerID = soh.CustomerID
)

SELECT DISTINCT Rear.AccountNumber, Rear.TerritoryName
FROM MyCTE Rear --Rear Wheel
JOIN MyCTE Front --Front Wheel
ON Rear.CustomerID = Front.CustomerID
WHERE Rear.ProductName = 'HL Mountain Rear Wheel'
AND Front.ProductName = 'HL Mountain Front Wheel';

----------- Example 1

WITH DirReps(ManagerID, DirectReports) AS --- Identify columns in CTE
(
    SELECT ManagerID, COUNT(*) 
    FROM HumanResources.Employee AS e
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT ManagerID, DirectReports 
FROM DirReps 
ORDER BY ManagerID


----------- Example 2 CTE with Ranking Function
---- The following example demonstrates usage of ROW_NUMBER ranking function 
---- to limit the output of a query. The TopCustomers CTE below finds 5 customers 
---- who have historically shopped the most (classified by amount of spent dollars). 
---- The OrderedPurchases CTE ranks individual purchases by the TopCustomers by individual purchase amount. 
---- Finally the outer query returns the only the top 10 purchases and orders the result set by customer name:

Use AdventureWorksDW2012
 
WITH TopCustomers AS
(
  SELECT TOP 5 
          a.CustomerKey,
          SUM(SalesAmount) AS total_purchases
  FROM FactInternetSales a 
  GROUP BY a.CustomerKey 
  ORDER BY 2 DESC
),
OrderedPurchases AS
(
     SELECT 
       FirstName + ' ' + LastName AS FullName, 
       SalesAmount AS PurchaseAmount,
     ROW_NUMBER() OVER (ORDER BY SalesAmount DESC) AS 'RowNumber'
     FROM FactInternetSales a INNER JOIN TopCustomers b 
       ON a.CustomerKey = b.CustomerKey
       INNER JOIN dimCustomer c 
       ON a.CustomerKey = c.CustomerKey
) 
SELECT * 
FROM OrderedPurchases 
WHERE RowNumber BETWEEN 1 AND 10
ORDER BY 1

----------- Example 2 CTE’s with Variables and Parameters

--- CTE can reference variables declared within the same batch or parameters used 
--- within the same code module. For example, the following query uses variables with CTE:
Use AdventureWorks2012

DECLARE @n TINYINT
SET @n = 3;
WITH direct_reports_CTE 
AS
 (
 SELECT 
	  TOP (@n) ManagerID AS manager_id, 
	  COUNT(*) AS number_of_direct_reports
 FROM HumanResources.Employee
 WHERE ManagerID IS NOT NULL
 GROUP BY ManagerID
 ORDER BY 2 DESC
 )
SELECT SUBSTRING(LoginID, (CHARINDEX('\', LoginID)+1), (LEN(LoginID)- 
CHARINDEX('\', LoginID)-1)) AS ManagerName, 
 number_of_direct_reports
FROM direct_reports_CTE a 
INNER JOIN HumanResources.Employee b ON a.Manager_ID = b.BusinessEntityID
ORDER BY 2 DESC

---- Next set of statements creates a stored procedure which exploits 
---- a CTE referencing a stored procedure parameter:

CREATE PROC return_top_bosses (@n TINYINT)
AS
WITH direct_reports_CTE 
AS
 (
 SELECT 
	  TOP (@n) ManagerID AS manager_id, 
	  COUNT(*) AS number_of_direct_reports
 FROM HumanResources.Employee
 WHERE ManagerID IS NOT NULL
 GROUP BY ManagerID
 ORDER BY 2 DESC
 )
SELECT 
 SUBSTRING(LoginID, (CHARINDEX('\', LoginID)+1), (LEN(LoginID)- 
 CHARINDEX('\', LoginID)-1)) AS ManagerName, 
 number_of_direct_reports
FROM direct_reports_CTE a 
INNER JOIN HumanResources.Employee b ON a.Manager_ID = b.BusinessEntityID
ORDER BY 2 DESC

----- Example 3 CTE Usage

Use AdventureWorksDW2012

WITH CountCustomersPerYear 
AS (
    SELECT EmployeeKey, 
    CalendarYear, 
    COUNT(DISTINCT ResellerKey) AS CustomerCount
    FROM FactResellerSales a 
    INNER JOIN DimDate b ON a.OrderDateKey = b.DateKey
    GROUP BY EmployeeKey, CalendarYear
    HAVING COUNT(DISTINCT ResellerKey) < 35
), 
 EmployeeSales AS
(
  SELECT a.EmployeeKey, 
  c.CalendarYear, 
  SUM(SalesAmount) AS TotalSales
  FROM FactResellerSales a INNER JOIN CountCustomersPerYear b
  ON a.EmployeeKey = b.EmployeeKey
  INNER JOIN DimDate c ON a.OrderDateKey = c.DateKey
  AND c.Calendaryear = b.CalendarYear
  GROUP BY a.EmployeeKey, c.CalendarYear
),
 EmployeeQuotas AS
(
  SELECT 
  FactSalesQuota.EmployeeKey, 
  FactSalesQuota.CalendarYear, 
  SUM(SalesAmountQuota) AS EmployeeQuota
  FROM FactSalesQuota INNER JOIN CountCustomersPerYear
  ON FactSalesQuota.EmployeeKey = CountCustomersPerYear.EmployeeKey
  AND FactSalesQuota.CalendarYear = CountCustomersPerYear.CalendarYear
  GROUP BY FactSalesQuota.EmployeeKey, FactSalesQuota.CalendarYear
)
SELECT 
	FirstName, 
	LastName, 
	c.CalendarYear, 
	c.TotalSales, 
	EmployeeQuota, 
	TotalSales - EmployeeQuota AS AmountOverQuota 
FROM DimEmployee a INNER JOIN EmployeeQuotas b ON a.EmployeeKey = b.EmployeeKey
INNER JOIN EmployeeSales c ON a.EmployeeKey = c.EmployeeKey
AND c.CalendarYear = b.CalendarYear
WHERE TotalSales > EmployeeQuota
ORDER BY 3, 2

---- A CTE can have the same name as the table it is querying. 
---- If this is the case, any reference to the object 
---- within the query will return data from CTE and not from the underlying object. 
---- Note also that CTE names cannot include schema names since they're not persisted objects. 
---- For example, the following query references a CTE 
---- that has the same name as the underlying table and returns only 
---- those records associated with Australia region:

WITH DimGeography AS
  (
	SELECT * FROM dbo.dimGeography
	WHERE EnglishCountryRegionName = 'Australia'
  )
SELECT * FROM DimGeography

---- You can reference the same CTE multiple times within a given query. 
---- For example, the following query sums up yearly reseller sales by employee; 
---- then it references the same CTE twice to create report of employee sales 
---- for each year and compare sales with immediately previous year's sales:

WITH YearlySales AS
(
 SELECT 
	EmployeeKey, 
	CalendarYear, 
	SUM(SalesAmount) AS TotalSales  
 FROM FactResellerSales a INNER JOIN DimDate b ON a.OrderDateKey = b.DateKey
 GROUP BY EmployeeKey,CalendarYear
)
 SELECT 
    FirstName +' ' +  LastName AS FullName, 
    CurrentYear.CalendarYear, 
    CurrentYear.TotalSales, 
    PreviousYear.CalendarYear AS PreviousYear,
    PreviousYear.TotalSales AS PreviousYearSales,
    CurrentYear.TotalSales - PreviousYear.TotalSales as SalesDifference
FROM dimEmployee Emp INNER JOIN YearlySales CurrentYear 
    ON emp.EmployeeKey = CurrentYear.EmployeeKey
INNER JOIN YearlySales PreviousYear 
    ON CurrentYear.CalendarYear = PreviousYear.CalendarYear + 1
AND PreviousYear.EmployeeKey = CurrentYear.EmployeeKey
ORDER BY 1

---- You can also use CTE's for modifying data. 
---- For example, the following query grants an extra week of vacation time (40 hours) 
---- to employees who have been with the company for longer than 10 years:

WITH LongHaulEmployees 
AS (
SELECT 
    EmployeeKey 
FROM DimEmployee
WHERE DATEDIFF(YEAR, HireDate, GETDATE())>=10
    AND CurrentFlag = 1
)
UPDATE DimEmployee
    SET VacationHours = VacationHours + 40
FROM DimEmployee a INNER JOIN LongHaulEmployees b
    ON a.EmployeeKey = b.EmployeeKey

---- In fact, it is possible to simplify the above query by updating 
---- CTE directly instead of joining to the underlying table. 
---- The following query would yield the same results as the one above:

WITH LongHaulEmployees 
AS (
SELECT 
    EmployeeKey, 
    VacationHours 
FROM DimEmployee
WHERE DATEDIFF(YEAR, HireDate, GETDATE())>=10
    AND CurrentFlag = 1
)
UPDATE LongHaulemployees
    SET VacationHours = VacationHours + 40

---------- Example 4 Recursive CTE Internals
Use AdventureWorksDW2012

WITH Department_CTE AS
(
SELECT 
     DepartmentGroupKey, 
     ParentDepartmentGroupKey, 
     DepartmentGroupName
  FROM dimDepartmentGroup
  WHERE DepartmentGroupKey = 2
UNION ALL
  SELECT 
     Child.DepartmentGroupKey, 
     Child.ParentDepartmentGroupKey, 
     Child.DepartmentGroupName
  FROM Department_CTE AS Parent
    JOIN DimDepartmentGroup AS Child
      ON Child.ParentDepartmentGroupKey = Parent.DepartmentGroupKey
)
SELECT * FROM Department_CTE

---- Notice that the first query within the CTE references 
---- "Executive General and Administration" department group. 
---- Next obtain the children of this group - "Inventory Management" and "Manufacturing", 
---- and the final recursion will catch "Quality Assurance" 
---- since this group rolls up to "Manufacturing".
---- You could modify the previous query slightly to retrieve 
---- the parent of "Executive General and Administration" group 
---- (and further ancestors, if any), as follows:

WITH Department_CTE AS
(
SELECT 
     DepartmentGroupKey, 
     ParentDepartmentGroupKey, 
     DepartmentGroupName
  FROM dimDepartmentGroup
  WHERE DepartmentGroupKey = 2
UNION ALL
  SELECT 
     Child.DepartmentGroupKey, 
     Child.ParentDepartmentGroupKey, 
     Child.DepartmentGroupName
  FROM Department_CTE AS Parent
    JOIN DimDepartmentGroup AS Child
      ON Parent.ParentDepartmentGroupKey = Child.DepartmentGroupKey
)

SELECT * FROM Department_CTE

---- It's important to realize that recursion stops 
---- as soon as the recursive query returns an empty result set. 
---- For example, the last query returns only two rows 
---- because the "Corporate" department group has no parent group, 
---- so the recursion stops only after executing two queries. 
---- As you might guess, recursion can cause problems if your data contains cycles. 
---- To demonstrate this let's temporarily modify the data in DimDepartmentGroup 
---- table of AdventureWorksDW database so that 
---- there is no root department group (a department group that has no parent):
UPDATE dimDepartmentGroup
SET ParentDepartmentGroupKey = 2
WHERE ParentDepartmentGroupKey IS NULL

---- Now the data is clearly erroneous because "Corporate" department group 
---- appears to be the parent of "Executive General and Administration" and vice versa. 
---- If you try querying this table using recursive CTE 
---- (using DepartmentGroupkey = 2 in the anchor query),
---- you will get 101 records back along with the following error:

---- The statement terminated. 
---- The maximum recursion 100 has been exhausted before statement completion. 
---- If you do expect such anomalies in your data you can specify MAXRECURSION hint 
---- and thereby limit the number of times the recursive query is invoked. 
---- You can specify MAXRECURSION hint with each query referencing a recursive CTE; 
---- this hint is specified immediately after the outer query, as follows:

WITH Department_CTE AS
(
SELECT 
     DepartmentGroupKey, 
     ParentDepartmentGroupKey, 
     DepartmentGroupName
  FROM dimDepartmentGroup
  WHERE DepartmentGroupKey = 2
UNION ALL
  SELECT 
     Child.DepartmentGroupKey, 
     Child.ParentDepartmentGroupKey, 
     Child.DepartmentGroupName
  FROM Department_CTE AS Parent
    JOIN DimDepartmentGroup AS Child
      ON Parent.ParentDepartmentGroupKey = Child.DepartmentGroupKey
)
SELECT * FROM Department_CTE
OPTION (MAXRECURSION 2) 


-------------------------
Use AdventureWorks2012

WITH direct_reports_CTE (manager_id, number_of_direct_reports)
AS
 (
 SELECT 
	  ManagerID, 
	  COUNT(*)
 FROM HumanResources.Employee
 WHERE ManagerID IS NOT NULL
 GROUP BY ManagerID
 )
SELECT 
     SUBSTRING(LoginID, (CHARINDEX('\', LoginID)+1), (LEN(LoginID)- 
     CHARINDEX('\', LoginID)-1)) AS ManagerName,
     number_of_direct_reports
FROM direct_reports_CTE a 
INNER JOIN HumanResources.Employee b ON a.Manager_ID = b.EmployeeID
WHERE number_of_direct_reports > = 10
ORDER BY 2 DESC