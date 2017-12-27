-------------------------------------Login----------------------------------------

create login [mytestlogin] with password ='changeme'
must_change, check_expiration=on, default_database=[adventureworks2012]

------- To create a login using Windows Authentication

-- Create a login for SQL Server by specifying a server name 
-- and a Windows domain account name.

CREATE LOGIN [<domainName>\<loginName>] FROM WINDOWS;
GO

------- To create a login using SQL Server Authentication

-- Creates the user "shcooper" for SQL Server using 
-- the security credential "RestrictedFaculty" 

-- The user login starts with the password "Baz1nga," 
-- but that password must be changed after the first login.

CREATE LOGIN shcooper 
   WITH PASSWORD = 'Baz1nga' MUST_CHANGE,
   CREDENTIAL = RestrictedFaculty;
GO

------------------------------------ User ----------------------------------------

create user test_mc_test for login mytestlogin
