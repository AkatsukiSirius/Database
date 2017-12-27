----- Throw()

---- A. Using THROW to raise an exception
---- The following example shows how to use the 
---- THROW statement to raise an exception.

THROW 51000, 'The record does not exist.', 1;

---- B. Using THROW to raise an exception again
---- The following example shows how use the THROW 
---- statement to raise the last thrown exception again.

USE tempdb;
GO
CREATE TABLE dbo.TestRethrow
(    ID INT PRIMARY KEY
);

BEGIN TRY
    INSERT dbo.TestRethrow(ID) VALUES(1);
--  Force error 2627, Violation of PRIMARY KEY constraint to be raised.
    INSERT dbo.TestRethrow(ID) VALUES(1);
END TRY

BEGIN CATCH

    PRINT 'In catch block.';
    THROW;
END CATCH;


---- C. Using FORMATMESSAGE with THROW 
----    The following example shows how to 
----    use the FORMATMESSAGE function with THROW 
----    to throw a customized error message. 
----    The example first creates a user-defined error message 
----    by using sp_addmessage. 
----    Because the THROW statement does not allow 
----    for substitution parameters in the message parameter 
----    in the way that RAISERROR does, 
----    the FORMATMESSAGE function is used to pass 
----    the three parameter values expected by error message 60000.

