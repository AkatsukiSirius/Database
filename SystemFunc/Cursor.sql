------------------------------------ Cursor
Use AdventureWorks2012


---------------------  Introduction

--- Most operations within a SQL Server database should be set-based,
--- rather than using the procedural, row-by-row processing 
--- embodied by cursors. 

--- However, there may still be occasions when a cursor is the
--- more appropriate or more expedient way to resolve a problem.

--- Certainly, most query processing to support application behavior, 
--- reporting and other uses, will be best solved by concentrating 
--- on set-based solutions.
 
--- However,certain maintenance routines will be more easily 
--- implemented using cursors (although even these may need to be 
--- set-based in order to reduce the maintenance footprint in a
--- production system).

--- For cursors, there are bigger differences between 
--- the logical and physical operators.

--- Logical operators give more information about the actions 
--- that will occur while a cursor is created, opened, fetched, closed 
--- and de-allocated. 

--- The physical operators show the functions 
--- that are part of the actual execution of the query, 
--- with less regard to the operations of the cursor.

--- As with all the previous execution plans, we can view plans 
--- containing cursors graphically, as text, or as XML. 

------------------------------ Simple cursors

---- All the notes are descriping the information of estimated EP

DECLARE CurrencyList CURSOR
FOR
   SELECT CurrencyCode
   FROM Sales.Currency
   WHERE Name LIKE '%Dollar%'

---- This definition in the header includes the SELECT statement
---- that will provide the data that the cursor uses. 
---- This plan contains our first two cursor-specific operators but, 
---- as usual, we'll read this execution plan, starting from the right. 

---- First, there is a Clustered Index Scan 
---- against the Sales.Currency table.

---- The Clustered Index Scan retrieves an estimated 14 rows. 
---- Following, is a Compute Scalar operator, 
---- which creates a unique identifier to identify the data
---- returned by the query, independent of any unique keys 
---- on the table or tables from which the data was selected

---- With a new key value, these rows are inserted into a 
---- temporary clustered index, created in tempdb. 
---- This clustered index, commonly referred to as a worktable,
---- is the "cursor" mechanism by which the server is able 
---- to walk through a set of data.

---- Then we have fetch operator
---- The Fetch Query operator retrieves the rows from the cursor, 
---- the clustered index created above, 
---- when the FETCH command is issued. 

---- Finally, instead of yet another Select operator,
---- we finish with a Dynamic operator.

---- The Dynamic operator contains the definition of the cursor. 
---- In this case, the default cursor type is a dynamic cursor, 
---- which means that it sees data changes made by others to
---- the underlying data, including inserts, as they occur. 
---- This means that the data within the cursor can change over 
---- the life of the cursor. 
---- For example, if data in the table is modified 
---- before it has been passed through the cursor, 
---- the modified data will be picked up by the cursor. 
---- This time, the ToolTip shows some slightly different, 
---- more detailed and useful information.

OPEN CurrencyList
---- Cursor Catchall
FETCH NEXT FROM CurrencyList
---- Cursor Catchall
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- Normally there would be operations here using data from cursor
      FETCH NEXT FROM CurrencyList
   END
---- Cursor Catchall + Conditional
---- This Conditional operator is performing a check  the fetch status
---- against the information returned from the Fetch operation.

CLOSE CurrencyList
---- Cursor Catchall
DEALLOCATE CurrencyList
GO
---- Cursor Catchall


--------------------------- Physical operators

---- After we execute the query, we can see the actual EP is different
---- from the estimated EP.

---- This simple plan is repeated 15 times, once for each 
---- row of data added to the cursor.
---- The slight discrepancy between the actual number of rows, 15,
---- and the estimated 14 rows you'll see in the ToolTip 
---- is caused by a minor disparity between the actual data
---- and the statistics.

---- One interesting thing to note is that no cursor icons 
---- are present in the plan. 
---- Instead, the one cursor command immediately visible, FETCH CURSOR, is represented by the generic
---- T-SQL operator icon. 
---- This is because all the physical operations that occur 
---- with a cursor are represented by the actual operations 
---- being performed, 
---- and the FETCH is roughly equivalent to the SELECT statement.

---------------------------- More Cursor Options
---- Changing the settings and operations of the cursor
---- result in differences in the plans generated.

-------------- Static cursor

---- Unlike the DYNAMIC cursor outlined above, 
---- a STATIC cursor is a temporary copy of the data, 
---- created when the cursor is called. 
---- This means that it doesn't see any underlying
---- changes to the data over the life of the cursor.

DECLARE CurrencyList CURSOR STATIC FOR
 SELECT CurrencyCode
   FROM Sales.Currency
   WHERE Name LIKE '%Dollar%'
OPEN CurrencyList
---- Cursor Catchall
FETCH NEXT FROM CurrencyList
---- Cursor Catchall
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- Normally there would be operations here using data from cursor
      FETCH NEXT FROM CurrencyList
   END
---- Cursor Catchall + Conditional
CLOSE CurrencyList
---- Cursor Catchall
DEALLOCATE CurrencyList
GO
---- Logical operators

---- Reading the query in the direction of the physical operations, 
---- from the top right-hand side, 
---- we see an Index Scan to retrieve the data 
---- from the Sales.Currency table. 
---- This data passes to the Segment operator, 
---- which divides the input into segments, based on a
---- particular column, or columns.

---- The derived column splits the data up in order to pass it 
---- to the next operation, which will assign the unique key.

---- Cursors require worktables and, to make them efficient, 
---- SQL Server creates them as a clustered index with a unique key. 
---- With a STATIC cursor, the key is generated 
---- after the segments are defined. 

------------------ Population Query

---- The Population Query Cursor operator, as stated 
---- in the description of the operator on the Properties sheet says, 
---- "populates the work table for a cursor when the cursor is opened"
---- or, in other words, from a logical standpoint, 
---- this is when the data that has been marshaled
---- by all the other operations is loaded into the worktable.

---- The Fetch Query operation retrieves the rows 
---- from the cursor via an Index Seek on the index in tempdb,
---- the worktable created to manage the cursor.
---- Notice that, in this case, the Fetch Query operation
---- is defined in a separate sequence, independent from the
---- Population Query. 
---- This is because this cursor is static, unlike the dynamic cursor, 
---- which reads its data each time it's accessed.

-------------------------- Snapshot

---- Finally, we see the Snapshot cursor operator, 
---- which represents a cursor that does not see
---- changes made to the data by separate data modifications.

---- Clearly, with a single INSERT operation, 
---- and then a simple Clustered Index Seek to retrieve the data,
---- this cursor will operate much faster than the dynamic cursor.
---- The Index Seek and the Fetch operations show 
---- how the data will be retrieved from the cursor.

-------------------- Physical operators

---- Two different Actural EP

---- The first plan is the query that loads the data into 
---- the cursor worktable, as represented by the clustered index.

---- The second plan is repeated, and we see a series of 
---- plans identical to the one shown for Query 2

--------------------- Keyset cursor

---- The KEYSET cursor retrieves a defined set of keys 
---- as the data defined within the cursor.
---- This means that it doesn't retrieve the actual data but, 
---- instead, a set of identifiers for finding that data later. 
---- The KEYSET cursor allows for the fact that data may be updated
---- during the life of the cursor. 
---- This behavior leads to yet another execution plan, different
---- from the previous two examples.

DECLARE CurrencyList CURSOR KEYSET FOR
 SELECT CurrencyCode
   FROM Sales.Currency
   WHERE Name LIKE '%Dollar%'
OPEN CurrencyList
---- Cursor Catchall
FETCH NEXT FROM CurrencyList
---- Cursor Catchall
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- Normally there would be operations here using data from cursor
      FETCH NEXT FROM CurrencyList
   END
---- Cursor Catchall + Conditional
CLOSE CurrencyList
---- Cursor Catchall
DEALLOCATE CurrencyList
GO

-------------- Logical EP

---- It ends with the Keyset operator, indicating that the cursor can
---- see updates, but not inserts.

---- The major difference is evident in how the Fetch Query works,
---- in order to support the updating of data after 
---- the cursor was built.

------------------------ Physical operators

---- Query 1 contains the Open Cursor operator,
---- and populates the key set exactly as 
---- the estimated plan envisioned.

---- In Query 2, the FETCH NEXT statements against the cursor 
---- activate the Fetch Cursor operation 15 times, 
---- as the cursor walks through the data.
---- While this can be less costly than a dynamic cursor, 
---- it's clearly more costly than a Static cursor. 
---- The performance issues come from the fact 
---- that the cursor queries the data twice, 
---- once to load the key set and a second time 
---- to retrieve the row data. 
---- Depending on the number of rows retrieved into the
---- worktable, this can be a costly operation.

---------------------------- READ_ONLY cursor

---- Each of the preceding cursors, except for Static, 
---- allowed the data within the cursor to be updated. 
---- If we define the cursor as READ_ONLY 
---- and look at the execution plan, we sacrifice the ability
---- to capture changes in the data, 
---- but we create what is known as a Fast Forward cursor.

DECLARE CurrencyList CURSOR READ_ONLY FOR
 SELECT CurrencyCode
   FROM Sales.Currency
   WHERE Name LIKE '%Dollar%'
OPEN CurrencyList
---- Cursor Catchall
FETCH NEXT FROM CurrencyList
---- Cursor Catchall
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- Normally there would be operations here using data from cursor
      FETCH NEXT FROM CurrencyList
   END
---- Cursor Catchall + Conditional
CLOSE CurrencyList
---- Cursor Catchall
DEALLOCATE CurrencyList
GO

---- Clearly, this represents the simplest cursor definition plan 
---- that we've examined so far.
---- Unlike for other types of cursor, there is no branch of operations
---- within the estimated plan. 
---- It simply reads what it needs directly from the data.
---- In our case, an Index Scan operation 
---- against the CurrencyName index shows how this is accomplished. 
---- The amount of I/O, compared to any of the other execution plans, 
---- is reduced since there is not a requirement 
---- to populate any worktables. 
---- Instead, there is a single step: get the data. 
---- The actual execution plan is identical except that it doesn't 
---- have to display the Fast Forward logical operator.


------------------------- Cursors and performance

---- Cursors are notorious for their ability to cause 
---- performance problems within SQL Server.

---- The following example shows, for each of the cursors,
---- how you can tweak their performance.

---- The example also demonstrates how to get rid of the cursor
---- and use a set-based operation that performs even better.

---- Let's assume that, in order to satisfy a business requirement, 
---- we need a report that lists the number of sales by store, 
---- assigning an order to them, 
---- and then, depending on the amount sold, 
---- displays how good a sale it is considered.
---- Here's a query, using a dynamic cursor, which might do the trick.

DECLARE @WorkTable TABLE
(
DateOrderNumber INT IDENTITY(1, 1) ,
Name VARCHAR(50) ,
OrderDate DATETIME ,
TotalDue MONEY ,
SaleType VARCHAR(50)
)
DECLARE @DateOrderNumber INT ,
@TotalDue MONEY
INSERT INTO @WorkTable
( Name ,
OrderDate ,
TotalDue
)
SELECT s.Name,soh.OrderDate,soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Store AS s
ON soh.SalesPersonID = s.SalesPersonID
WHERE soh.CustomerID = 29731
ORDER BY soh.OrderDate

DECLARE ChangeData CURSOR
FOR
SELECT DateOrderNumber ,
TotalDue
FROM @WorkTable
OPEN ChangeData
FETCH NEXT FROM ChangeData INTO @DateOrderNumber, @TotalDue
WHILE @@FETCH_STATUS = 0
BEGIN
-- Normally there would be operations here using data from cursor
IF @TotalDue < 1000
UPDATE @WorkTable
SET SaleType = 'Poor'
WHERE DateOrderNumber = @DateOrderNumber
ELSE
IF @TotalDue > 1000
AND @TotalDue < 10000
UPDATE @WorkTable
SET SaleType = 'OK'
WHERE DateOrderNumber = @DateOrderNumber
ELSE
IF @TotalDue > 10000
AND @TotalDue < 30000
UPDATE @WorkTable
SET SaleType = 'Good'
WHERE DateOrderNumber = @DateOrderNumber
ELSE
UPDATE @WorkTable
SET SaleType = 'Great'
WHERE DateOrderNumber = @DateOrderNumber
FETCH NEXT FROM ChangeData INTO @DateOrderNumber, @TotalDue
END
CLOSE ChangeData
DEALLOCATE ChangeData
SELECT *
FROM @WorkTable

---- The estimated execution plan (not shown here) displays 
---- the plan for populating the temporary table, 
---- and updating the temporary table, 
---- as well as the plan for the execution of the cursor. 
---- The cost to execute this script, as a dynamic cursor, includes,
---- not only the query against the database tables, Sales.OrderHeader 
---- and Sales.Store, but also the INSERT into the temporary table, 
---- all the UPDATEs of the temporary table, and the final SELECT 
---- from the temporary table. 
---- The result is about 27 different scans and about 113 reads.

----------------- Improve it by useing different Types of Cursor

DECLARE ChangeData CURSOR STATIC

DECLARE ChangeData CURSOR KEYSET

DECLARE ChangeData CURSOR READ_ONLY
---- Keyset is the fastest so far

DECLARE ChangeData CURSOR FAST_FORWARD

DECLARE ChangeData CURSOR FORWARD_ONLY KEYSET

----------------------- Summary

---- Don't forget that the estimated plan shows both 
---- how the cursor will be created, in the top part of the plan,
---- and how the data in the cursor will be accessed, 
---- in the bottom part of the plan. 
---- The primary differences between a plan generated from a cursor
---- and one from a set-based operation are 
---- in the estimated execution plans.
 
---- Other than that, as you have seen, reading these plans 
---- is no different than reading the plans from a set-based operation: 
---- start at the right and top and work your way to the left.
---- There are just a lot more plans generated, 
---- because of the way in which cursors work.
