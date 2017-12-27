---------------------------------------------- Index ---------------------------------

---- Index: it is an object help to improve the efficiency,
----        by creating a data structure in background
----        which can be used to find the content of database
----        The goal for index is to provide the ability to seek.

---- Summary: 1) Primary mechanism to get improved performance on a db,
----             By building the right indexes over a db for its workload, we
----             can get orders of magnitude performance improvement,
----             We need to pay attention to the update frequency of tables
----          2) Persistent data structure stored in db.

---- Utility: Comparing with full table scans, it can immediate find the location of tuples

---- How to set index: Choose the attributes that are going to be used frequently in conditions,
----                   especially the conditions which are very selective.
----                   Primrary keys are sometimes set to index automatically.

---- Underlying Data Structure: Balanced Tree/ Hash Table
---- Diff: Conditions to seperate data is different;
---- For BT: The index can work with the condtions such as attributes equal to value
----         Attributes less than values, attribute between two valuse 
---- For Hash Table: The index only work for equlity conditions.

---- Balanced Tree: It is a data structure running on SQL server,
----                created after the index being set.Constraints doesn't work
----                work on BT and it will not effect index.
------- Three Components: Root Level, Intermediate Level and Leaf Page Level;
------- Leaf Page: Cluster Index will store data in Leaf Page,and sort them
-------            based on the key values of the cols being selected.
-------            Nonclusterd Index will point to the rows they reference. 

use TEST_DB

select * from employee1

----------------Clustered Index

---- Clustered Index: will physically move the data from the table into it's Balanced Tree.
----                  Only one clustered index per table.Because data can only physically 
----                  be sorted and stored once.

---- Once a col is selected as CI, it becomes key value.  

---- Heap Table: Table without a CI



Create Clustered Index CI_EMP on dbo.Employee1(EmpID)

Drop Index [CI_EMP] on dbo.Employee1

-----------------Non-Clustered index

---- NCI: will not physically sort, store or move anything. It only
----      identify where is the data. We can have many NCI in one table.

---- Heap Table: When we have NCI in Heap Table, row identifier will be 
----             applied to search the data.

---- CI Table: When we set NCI in Table with CI. Key identifier will be used
----           When we locating some data, the engine 1st point to be location
----           based on NCI, which will identify the row with the data we're 
----           looking for. Then with the help of CI, the exact location can 
----           be achieved     


 
create nonclustered index NCI_EMP on dbo.employee1(name)

select name from dbo.employee1

drop index [NCI_EMP] on dbo.employee1