---- The Paging Function is part of the SELECT syntax, 
---- as an extension to the ORDER BY clause. 
---- Below is an example of its usage to retrieve a data set
---- with TransactionID from 5001 and for the next 100 rows.

---- 1) Offset...Fetch Next # Rows Only

Use AdventureWorks2012

SELECT [TransactionID],[ProductID],[ReferenceOrderID],
[ReferenceOrderLineID],[TransactionDate],[TransactionType],
[Quantity],[ActualCost],[ModifiedDate]
FROM [Production].[TransactionHistoryArchive]
ORDER BY [TransactionID]
OFFSET 5001 ROWS
FETCH NEXT 100 ROWS ONLY

---- A few things to note about the Paging Function:
---- i) The ORDER BY column(s) doesn’t have to be consecutive, 
----    meaning that we can avoid creating a surrogate consecutive 
----    integer key for the purpose of paging. 
----    This helps in a typical query to retrieve a page of “active” 
----    Transaction records whereby some rows in the table may be 
----    deleted or “deactivated”, rendering broken IDs.
---- ii) OFFSET and FETCH can only be used in the last query 
----     that participates in UNION, EXCEPT or INTERSECT operation.
---- iii) If the column specified in the ORDER BY column(s) is not 
----      unique,the order of the output is not always consistent. 

---- Performance:
---- Surprisingly, SQL Server is using Clustered Index Scan 
---- and the Actual Number of Rows returned here is 5101!

---- 2) TOP … Batching

---- In an earlier version, you could write a query to return 
---- the same data set using the TOP keyword.  
---- Please note that the SET ROWCOUNT clause to limit the 
---- number of rows returned in a SELECT query, will not be
---- supported in the next version of SQL Server 
---- and the TOP keyword should be used instead.

-- TOP... Batching
-- Retrieve 100 rows starting from TransactionID of 5001

SELECT TOP 100[TransactionID],[ProductID],[ReferenceOrderID],
[ReferenceOrderLineID],[TransactionDate],[TransactionType],
[Quantity],[ActualCost],[ModifiedDate]
FROM [Production].[TransactionHistoryArchive]
WHERE [TransactionID] >= 5001
ORDER BY [TransactionID]

---- Perform:
---- Similar to the Direct ID Batching, SQL Server is also using 
---- Clustered Index Seek. It then uses TOP as the next step.
---- Note that here similar to Direct ID Batching, 
---- the Clustered Index Seek is also returning Actual Number of 
---- Rows of 100.

---- 3) Alternative: Direct ID Batching
---- An alternative to the above in an earlier version to 
---- SQL Server 2012 is shown below, The result will be the same,
---- assuming TransactionID values are always consecutive.

-- Direct ID Batching
-- Retrieve 100 rows starting from TransactionID of 5001
SELECT [TransactionID],[ProductID],
[ReferenceOrderID],[ReferenceOrderLineID],
[TransactionDate],[TransactionType],
[Quantity],[ActualCost],[ModifiedDate]
FROM [Production].[TransactionHistoryArchive]
WHERE [TransactionID] BETWEEN 5001 AND 5100
ORDER BY [TransactionID]

---- As expected, here SQL Server is using Clustered Index Seek
---- as per the index filter on the ID between the 2 values
---- (5001 and 5100). 
---- Note that the Actual Number of Rows on the Execution Plan Details
---- of the Clustered Index Seek is 100.

---- Performance: Similar to the Direct ID Batching, 
---- SQL Server is also using Clustered Index Seek.
---- It then uses TOP as the next step.
---- Note that here similar to Direct ID Batching, 
---- the Clustered Index Seek is also returning 
---- Actual Number of Rows of 100.

---------------- Performance Summary

---- Using Paging Fuction on a source table with a large number of
---- records may not be ideal. 
---- The larger the offset size, the larger the Actual Number of 
---- Rows is returned too. 
---- The Paging Function will take longer 
---- and longer as the paging progresses. 
---- To demonstrate this, I have a table with over 14.5 Million rows
---- where I iterate through the records in a batch size of 500,000. 
---- Each iteration inserts the batched records into a heap table
---- that is empty to start with.

---- Although SQL Server 2012 new Paging function is intuitive for 
---- the purpose of paging a data set, it comes at a cost for 
---- large volume of data. 
---- The Top Batching and Direct ID Batching perform significantly
---- better under similar circumstances, 
---- i.e. simple Source Data with continuous ID.