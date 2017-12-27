---- Rowset Functions

---- OPENDATASOURCE
---- Provides ad-hoc connection information as part of 
---- a four-part object name without using a linked server name.

---- Syntax:OPENDATASOURCE ( provider_name, init_string )

SELECT *
FROM OPENDATASOURCE('SQLNCLI',
    'Data Source=London\Payroll;Integrated Security=SSPI')
    .AdventureWorks2012.HumanResources.Employee

