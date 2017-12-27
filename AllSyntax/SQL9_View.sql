--View

-- A view is essentially just a "stored query," in other words, 
-- a logical way of representing data as if it were in a table, 
-- without actually creating a new table. 
-- The various uses of views are well documented 
-- (preventing certain columns from being selected, reducing
-- complexity for end-users, and so on).

--- View is a SQL query that is permanently stored in database
--- and assigned a name to form a virtual table

--- View can be treated as a virtual table, by defining alternative view
--- we can look at the data in other ways

--- The result of stored query are visible through the view and SQL
--- provides users to access these query results as if they were
--- in a real table.

--- Note:
---      while a view can make coding easier, 
---      it doesn't in any way change the necessities of 
---      the query optimizer to perform the actions defined within the view. 
---      This is an important point to keep in mind, 
---      since developers frequently use views to mask 
---      the complexity of a query.

Use test_DB

CREATE VIEW EmpInfo AS
SELECT *
FROM AdventureWorks2012.HumanResources.Employee

select * from empinfo

DROP VIEW EmpInfo

CREATE VIEW EmpInfo AS
SELECT Employee.BusinessEntityID,FirstName +' ' + ISNULL(MiddleName + ' ' , '') + LastName AS 'Full Name', JobTitle, Gender, MaritalStatus
FROM AdventureWorks2012.HumanResources.Employee
	INNER JOIN AdventureWorks2012.Person.Person
	ON EMPLOYEE.BusinessEntityID = Person.BusinessEntityID

SELECT * 
FROM EmpInfo
INNER JOIN AdventureWorks2012.Person.Person
ON EmpInfo.BusinessEntityID = Person.BusinessEntityID

----- Schema Binding View
---- with Schemabinding
CREATE VIEW SchemaEmpInfo with Schemabinding AS
SELECT EmpID, Name, ManagedBy
FROM dbo.EMPLOYEE1


Select *
FROM SchemaEmpInfo


ALTER Table dbo.Employee1
DROP COLUMN Name --- Doesn't work

EXEC SP_HELPTEXT EmpInfo

-- Encryption --
ALTER VIEW EmpInfo WITH ENCRYPTION AS
SELECT Employee.BusinessEntityID,FirstName +' ' + ISNULL(MiddleName + ' ' , '') + LastName AS 'Full Name', JobTitle, Gender, MaritalStatus
FROM AdventureWorks2012.HumanResources.Employee
	INNER JOIN AdventureWorks2012.Person.Person
	ON EMPLOYEE.BusinessEntityID = Person.BusinessEntityID
