Create Database SequenceTest
Use SequenceTest

----------- A. Using a sequence number in a single table
---- The following example creates a schema named Test, 
---- a table named Orders, and a sequence named CountBy1, 
---- and then inserts rows into the table using the NEXT VALUE FOR function.




--Create the Test schema
CREATE SCHEMA Test ;
GO

-- Create a table
CREATE TABLE Test.Orders
    (OrderID int PRIMARY KEY,
    Name varchar(20) NOT NULL,
    Qty int NOT NULL);
GO

-- Create a sequence
CREATE SEQUENCE Test.CountBy1
    START WITH 1
    INCREMENT BY 1 ;
GO

-- Insert three records
INSERT Test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Tire', 2) ;
INSERT test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Seat', 1) ;
INSERT test.Orders (OrderID, Name, Qty)
    VALUES (NEXT VALUE FOR Test.CountBy1, 'Brake', 1) ;
GO

-- View the table
SELECT * FROM Test.Orders ;
GO

--------------- B. Calling NEXT VALUE FOR before inserting a row

---- Using the Orders table created in example A,
---- the following example declares a variable named @nextID,
---- and then uses the NEXT VALUE FOR function to set the variable 
---- to the next available sequence number. 

---- The application is presumed to do some processing of the order,
---- such as providing the customer with the OrderID number of their 
---- potential order, and then validates the order. 

---- No matter how long this processing might take, 
---- or how many other orders are added during the process, 
---- the original number is preserved for use by this connection. 

---- Finally, the INSERT statement adds the order to the Orders table.

DECLARE @NextID int ;
SET @NextID = NEXT VALUE FOR Test.CountBy1;
-- Some work happens
INSERT Test.Orders (OrderID, Name, Qty)
    VALUES (@NextID, 'Rim', 2) ;
GO
-- View the table
SELECT * FROM Test.Orders ;
GO

----------------- C. Using a sequence number in multiple tables

---- This example assumes that a production-line monitoring process 
---- receives notification of events that occur throughout the workshop.
---- Each event receives a unique and monotonically increasing EventID number.
---- All events use the same EventID sequence number so that reports 
---- that combine all events can uniquely identify each event.
---- However the event data is stored in three different tables, 
---- depending on the type of event.
---- The code example creates a schema named Audit, 
---- a sequence named EventCounter, and three tables 
---- which each use the EventCounter sequence as a default value. 
---- Then the example adds rows to the three tables and queries the results.

-- Create Schema
CREATE SCHEMA Audit ;
GO

-- Create Sequence
CREATE SEQUENCE Audit.EventCounter
    AS int
    START WITH 1
    INCREMENT BY 1 ;
GO

-- Create Table
CREATE TABLE Audit.ProcessEvents
(
    EventID int PRIMARY KEY CLUSTERED 
        DEFAULT (NEXT VALUE FOR Audit.EventCounter),
    EventTime datetime NOT NULL DEFAULT (getdate()),
    EventCode nvarchar(5) NOT NULL,
    Description nvarchar(300) NULL
) ;
GO

-- Create table
CREATE TABLE Audit.ErrorEvents
(
    EventID int PRIMARY KEY CLUSTERED
        DEFAULT (NEXT VALUE FOR Audit.EventCounter),
    EventTime datetime NOT NULL DEFAULT (getdate()),
    EquipmentID int NULL,
    ErrorNumber int NOT NULL,
    EventDesc nvarchar(256) NULL
) ;
GO

-- Create Table
CREATE TABLE Audit.StartStopEvents
(
    EventID int PRIMARY KEY CLUSTERED
        DEFAULT (NEXT VALUE FOR Audit.EventCounter),
    EventTime datetime NOT NULL DEFAULT (getdate()),
    EquipmentID int NOT NULL,
    StartOrStop bit NOT NULL
) ;
GO

---- Notice: In all above tables, same sequence is used to generate
----         incrementing values, which is the PK !!!!

INSERT Audit.StartStopEvents (EquipmentID, StartOrStop) 
    VALUES (248, 0) ;
INSERT Audit.StartStopEvents (EquipmentID, StartOrStop) 
    VALUES (72, 0) ;
INSERT Audit.ProcessEvents (EventCode, Description) 
    VALUES (2735, 
    'Clean room temperature 18 degrees C.') ;
INSERT Audit.ProcessEvents (EventCode, Description) 
    VALUES (18, 'Spin rate threashold exceeded.') ;
INSERT Audit.ErrorEvents (EquipmentID, ErrorNumber, EventDesc) 
    VALUES (248, 82, 'Feeder jam') ;
INSERT Audit.StartStopEvents (EquipmentID, StartOrStop) 
    VALUES (248, 1) ;
INSERT Audit.ProcessEvents (EventCode, Description) 
    VALUES (1841, 'Central feed in bypass mode.') ;

-- The following statement combines all events, though not all fields.
SELECT EventID, EventTime, Description 
FROM Audit.ProcessEvents 
UNION 
SELECT EventID, EventTime, EventDesc 
FROM Audit.ErrorEvents 
UNION 
SELECT EventID, EventTime, 
CASE StartOrStop 
    WHEN 0 THEN 'Start' 
    ELSE 'Stop'
END 
FROM Audit.StartStopEvents
ORDER BY EventID ;
GO

