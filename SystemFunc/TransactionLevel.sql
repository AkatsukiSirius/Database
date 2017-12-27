Create Database TransactionIsolationTest

CREATE TABLE IsolationTests  
(
    Id INT IDENTITY,
    Col1 INT,
    Col2 INT,
    Col3 INT
)

INSERT INTO IsolationTests(Col1,Col2,Col3)  
SELECT 1,2,3  
UNION ALL SELECT 1,2,3  
UNION ALL SELECT 1,2,3  
UNION ALL SELECT 1,2,3  
UNION ALL SELECT 1,2,3  
UNION ALL SELECT 1,2,3  
UNION ALL SELECT 1,2,3  

Select * From IsolationTests


-------- Dirty Reads: This is when you read uncommitted data, 
-------- when doing this there is no guarantee that data read 
-------- will ever be committed meaning the data could well be bad.
-------- Read Uncommitted data

-------- Phantom Reads: This is when data that you are working 
-------- with has been changed by another transaction since you first read it in. 
-------- This means subsequent reads of this data in the same transaction could well be different.

-------- Non Repeatable read: Read multi times in a transaction and a seperate transaction alters
-------- the data (modify or delete) ealier than the transcation we are using. 

-------- Shared Lock: allows multiple users to SELECT the same data,
-------- but none can modify the data as its being read. By default, the shared lock
-------- will be released as soon as the data is read unless specified,
-------- otherwise, no one take control the data being saved, no one can make change.
-------- Used when we only need to read data, they can be compatible with other locks.

-------- Exclusive Lock: can't read, can't write. not compatible with other locks

---------------------------------- Read Uncommitted--------------------------

--- This is the lowest isolation level there is. 
--- Read uncommitted causes no shared locks to be requested 
--- which allows you to read data that is currently being modified in other transactions. 
--- It also allows other transactions to modify data that you are reading.
--- As you can probably imagine this can cause some unexpected results in a variety of different ways. 
--- For example data returned by the select could be in a half way state 
--- if an update was running in another transaction causing some of your rows 
--- to come back with the updated values and some not to.
--- Di

------- Query 1
--- To see read uncommitted in action lets run Query1 in one tab of Management Studio 
--- and then quickly run Query2 in another tab before Query1 completes.

BEGIN TRAN  
UPDATE IsolationTests SET Col1 = 2  
--Simulate having some intensive processing here with a wait
WAITFOR DELAY '00:00:10'  
ROLLBACK 

------ Query 2

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SELECT * FROM IsolationTests 

--- Notice that Query2 will not wait for Query1 to finish, 
--- also more importantly Query2 returns dirty data. 
--- Remember Query1 rolls back all its changes however Query2 has returned the data anyway, 
--- this is because it didn't wait for all the other transactions with exclusive locks on this data 
--- it just returned what was there at the time.
--- There is a syntactic shortcut for querying data 
--- using the read uncommitted isolation level by using the NOLOCK table hint. 
--- You could change the above Query2 to look like this and it would do the exact same thing.


SELECT * FROM IsolationTests WITH(NOLOCK)

---------------------------------- Read Committed --------------------------

--- This is the default isolation level and means selects will only return committed data. 
--- Select statements will issue shared lock requests against data you’re querying 
--- this causes you to wait if another transaction already has an exclusive lock on that data. 
--- Once you have your shared lock any other transactions trying to modify that data 
--- will request an exclusive lock and be made to wait until your Read Committed transaction finishes.

--- You can see an example of a read transaction waiting for a modify transaction 
--- to complete before returning the data by running the following Queries 
--- in separate tabs as you did with Read Uncommitted.

--- Query1

BEGIN TRAN  
UPDATE IsolationTests SET Col1 = 2  
--Simulate having some intensive processing here with a wait
WAITFOR DELAY '00:00:10'  
ROLLBACK 

--- Query2

SELECT * FROM IsolationTests  

--- Notice how Query2 waited for the first transaction to complete before returning 
--- and also how the data returned is the data we started off with as Query1 did a rollback. 
--- The reason no isolation level was specified is because 
--- Read Committed is the default isolation level for SQL Server. 
--- If you want to check what isolation level you are running under you can run “DBCC useroptions”. 
--- Remember isolation levels are Connection/Transaction specific so different queries 
--- on the same database are often run under different isolation levels.

---------------------------------- Repeatable Read--------------------------

