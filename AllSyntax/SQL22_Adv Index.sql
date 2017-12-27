
---------------Covering Index

---- Covering Index: An index that contains all information required 
----                 to resolve the query, it completely cover the query

create nonclustered index COV_EMP on dbo.employee1(name)
include(managedby)
 

select managedby
from dbo.employee1

---------------Filtered Index

---- Filter Index: Index only the values that fall into the condition
----               Uses Where condition

create nonclustered index FILT_NCI on dbo.employee1(name)
where empID in (1,3,4,5,6)


select * from employee1

--------------Full Text Index

---- Full Text Index: Allows indexing and searching for string or 
----                  character based data

---- Note: Only one full-text index is allowed per table or indexed view, 
----       and each full-text index applies to a single table or indexed view. 
----       A full-text index can contain up to 1024 columns.

---- Three Steps:
---- 1) Create the catalog
---- 2) Create the index
---- 3) Populate the index            

---- Two Additional Options:
---- 1) Freetext()
---- 2) Contains()

use AdventureWorks2012

---- Step 1 Create Catalog

create fulltext catalog departments

---- Step 2 Create Index

create fulltext index on humanresources.department(name)
key index [PK_Department_DepartmentID] on departments

---- Step 3 Populate


select * from HumanResources.Department
where contains(name,'engineering or development')

-------------- Unique index

---- When I want a unique index which means I need to 
---- find out the unique information or data in the data sets.
---- Since Index is not default to have Unique Constraints. 
---- When we want an Unique index, we must set the keyword UNIQUE.

create UNIQUE nonclustered index COV_EMP on dbo.employee1(name)

---------------Indexed View
use test_DB

create view INDEX_VIEW_TEST with schemabinding as
select empID,name,managedby
from dbo.employee1

create unique clustered index IDX_CI on dbo.INDEX_VIEW_TEST(empID)


-------------- How index benefit
---- You’re going to look for an ID range within this table, 
---- chosen across two columns: ReferenceOrderID and ReferenceOrderLineID. 
---- The table, as it exists already, has an index across those two columns.

USE AdventureWorks2012
SELECT *
FROM [Production].[TransactionHistory]
WHERE ReferenceOrderLineID = 0
  AND ReferenceOrderID BETWEEN 41500 AND 42000;

SELECT *
FROM [Production].[TransactionHistory]
WHERE ReferenceOrderLineID BETWEEN 0 AND 2
  AND ReferenceOrderID = 41599;

---- There are some slight differences between the two, 
---- but both use an index seek of the existing index
---- called IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID. 
---- As its name implies, this non-clustered index is on ReferenceOrderID 
---- and ReferenceOrderLineID, in that order.


---- Next, disable this index and create a new one in the opposite order,
---- then check your query plans again. 
---- Disable the existing index

ALTER INDEX [IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID]
ON [Production].[TransactionHistory] DISABLE;

---- Create new one
CREATE NONCLUSTERED INDEX
[IX2_TransactionHistory_ReferenceOrderLineID_ReferenceOrderID]
ON [Production].[TransactionHistory]
(
[ReferenceOrderLineID] ASC,
[ReferenceOrderID] ASC
);

---- Rebuild

ALTER INDEX [IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID]
ON [Production].[TransactionHistory] REBUILD;

