
-------------------------------------Fragmentation----------------------------------------------

---- Caused by DML actions
---- What’s the problem: Once page has been lost or changed.
----                     The previous index may not work well anymore
----                     So, we need to monitor, keep track on index is needed, 
----                     the more move or change in index, f issues come.  
---- Reason to Cause:

---- 1) It will create empty spaces in the B-Tree known as memory bubbles
----    When create index BT is built, changes on data may cause empty tuples in BT

---- 2) Page splitting can also cause fragmentation when data needs more room than 
----    allowed in a single leaf node. Since item is not splited uniformly




DBCC showcontig('HumanResources.Employee')

DBCC showcontig('HumanResources.Employee',3)

select * from sys.dm_db_index_physical_stats
              (db_ID('adventureworks2012'),object_ID('humanresources.employee'),
			  object_ID('[IX_Employee_OrganizationLevel_OrganizationNode]'),
			   null,'detailed')

select AVG_fragmentation_in_percent as 'external frag',
       avg_page_space_used_in_percent as 'internal frag'
from sys.dm_db_index_physical_stats
              (db_ID('adventureworks2012'),object_ID('humanresources.employee'),
			  object_ID('[ID_employee_organization_organizationnode]'),
			   null,'detailed')

---------------------------------Rebuild and Reorganize-----------------------------------------

alter index [PK_employee_businessentityID]
on humanresources.employee
rebuild

alter index all
on humanresources.employee
reorganize


alter index [PK_employee_businessentityID]
on humanresources.employee
rebuild with (fillfactor=80,PAD_index=on,sort_in_tempdb=on,online=on)