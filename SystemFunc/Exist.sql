---- Specifies a subquery to test for the existence of rows.

Use AdventureWorks2012

---- A. Using NULL in a subquery to still return a result set
----    The following example returns a result set 
----    with NULL specified in the subquery 
----    and still evaluates to TRUE by using EXISTS.

SELECT DepartmentID, Name 
FROM HumanResources.Department 
WHERE EXISTS (SELECT NULL) ---- Since Null exists,this condition
                           ---- is always true
ORDER BY Name ASC;

---- B. Comparing queries by using EXISTS and IN
----    The following example compares two queries that are 
----    semantically equivalent. 
----    The first query uses EXISTS and the second query uses IN.

----    Same result

SELECT a.FirstName, a.LastName
FROM Person.Person AS a
WHERE EXISTS
(SELECT * 
    FROM HumanResources.Employee AS b
    WHERE a.BusinessEntityID = b.BusinessEntityID
    AND a.LastName = 'Johnson');
GO

---- Use in

SELECT a.FirstName, a.LastName
FROM Person.Person AS a
WHERE a.LastName IN
(SELECT a.LastName
    FROM HumanResources.Employee AS b
    WHERE a.BusinessEntityID = b.BusinessEntityID
    AND a.LastName = 'Johnson');
GO

---- C. Comparing queries by using EXISTS and = ANY
----    The following example shows two queries to find stores 
----    whose name is the same name as a vendor. 
----    The first query uses EXISTS and the second uses = ANY.

SELECT DISTINCT s.Name
FROM Sales.Store AS s 
WHERE EXISTS
(   SELECT *
    FROM Purchasing.Vendor AS v
    WHERE s.Name = v.Name) ;
GO

---- Use Any
---- Any: Compares a scalar value with a single-column set of values. 
----      SOME and ANY are equivalent.

SELECT DISTINCT s.Name
FROM Sales.Store AS s 
WHERE s.Name = ANY
(SELECT v.Name
    FROM Purchasing.Vendor AS v ) ;
GO

---- D. Comparing queries by using EXISTS and IN
----    The following example shows queries to find employees of 
----    departments that start with P.

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p 
JOIN HumanResources.Employee AS e
   ON e.BusinessEntityID = p.BusinessEntityID 
WHERE EXISTS
(SELECT *
    FROM HumanResources.Department AS d
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
       ON d.DepartmentID = edh.DepartmentID
    WHERE e.BusinessEntityID = edh.BusinessEntityID
    AND d.Name LIKE 'P%');
GO

---- Use in

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p JOIN HumanResources.Employee AS e
   ON e.BusinessEntityID = p.BusinessEntityID 
JOIN HumanResources.EmployeeDepartmentHistory AS edh
   ON e.BusinessEntityID = edh.BusinessEntityID 
WHERE edh.DepartmentID IN
(SELECT DepartmentID
   FROM HumanResources.Department
   WHERE Name LIKE 'P%');
GO

---- E. Using NOT EXISTS
----    NOT EXISTS works the opposite of EXISTS. 
----    The WHERE clause in NOT EXISTS is satisfied 
----    if no rows are returned by the subquery. 
----    The following example finds employees who are not 
----    in departments which have names that start with P.

SELECT p.FirstName, p.LastName, e.JobTitle
FROM Person.Person AS p 
JOIN HumanResources.Employee AS e
   ON e.BusinessEntityID = p.BusinessEntityID 
WHERE NOT EXISTS
(SELECT *
   FROM HumanResources.Department AS d
   JOIN HumanResources.EmployeeDepartmentHistory AS edh
      ON d.DepartmentID = edh.DepartmentID
   WHERE e.BusinessEntityID = edh.BusinessEntityID
   AND d.Name LIKE 'P%')
ORDER BY LastName, FirstName
GO

---- F. Using EXISTS
----    The following example identifies whether any rows 
----    in the ProspectiveBuyer table could be matches to rows 
----    in the DimCustomer table. 
----    The query will return rows only when both the LastName 
----    and BirthDate values in the two tables match.

SELECT a.LastName, a.BirthDate
FROM DimCustomer AS a
WHERE EXISTS
(SELECT * 
    FROM dbo.ProspectiveBuyer AS b
    WHERE (a.LastName = b.LastName) AND (a.BirthDate = b.BirthDate));

---- G. Using NOT EXISTS
----    NOT EXISTS works as the opposite as EXISTS. 
----    The WHERE clause in NOT EXISTS is satisfied 
----    if no rows are returned by the subquery. 
----    The following example finds rows in the DimCustomer table 
----    where the LastName and BirthDate do not match any entries 
----    in the ProspectiveBuyers table.

SELECT a.LastName, a.BirthDate
FROM DimCustomer AS a
WHERE NOT EXISTS
(SELECT * 
    FROM dbo.ProspectiveBuyer AS b
    WHERE (a.LastName = b.LastName) AND (a.BirthDate = b.BirthDate));