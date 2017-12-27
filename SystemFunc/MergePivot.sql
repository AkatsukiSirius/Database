Create Database MergePivot
use MergePivot


----------------------------- Merge

Create Table Employee
(
EmpID int,
EmpName varchar(50)
)

insert into Employee values(1,'Joy')
insert into Employee values(2,'Ira')
insert into Employee values(3,'Chris')
Select * From Employee

Create Table Project
(
ProjectID int,
ProjectName varchar(50)
)

insert into Project values(1,'GAE')
insert into Project values(2,'CVue')
insert into Project values(3,'1098T')
Select * From Project


Create Table ProjectAssignment
(
ProjectID int,
EmpID varchar(50)
)

insert into ProjectAssignment values(1,1)
insert into ProjectAssignment values(1,2)
insert into ProjectAssignment values(2,2)
insert into ProjectAssignment values(2,3)
insert into ProjectAssignment values(3,1)


Select * From Employee
Select * From Project
Select * From ProjectAssignment

------ Pivot: rwo to col

Select * From Project

Select TP.Total_Project -------, Joy_Project_Count, Ira_Project_Count, Chris_Project_Count
From (Select count(ProjectID) as Total_Project From Project)as TP


Select COUNT(Distinct A.ProjectID) as Total_Project,
(Select Count(ProjectID) From (Select Emp.EmpID,EmpName,Pro.ProjectID,ProjectName 
      From Project Pro
      Join ProjectAssignment PA
      on PA.ProjectID=Pro.ProjectID
      Join Employee Emp
      on Emp.EmpID=PA.EmpID )B Where B.EmpName='Joy') as Joy_Project_Count,
(Select Count(ProjectID) From (Select Emp.EmpID,EmpName,Pro.ProjectID,ProjectName 
      From Project Pro
      Join ProjectAssignment PA
      on PA.ProjectID=Pro.ProjectID
      Join Employee Emp
      on Emp.EmpID=PA.EmpID )B Where B.EmpName='Ira') as Ira_Project_Count,
(Select Count(ProjectID) From (Select Emp.EmpID,EmpName,Pro.ProjectID,ProjectName 
      From Project Pro
      Join ProjectAssignment PA
      on PA.ProjectID=Pro.ProjectID
      Join Employee Emp
      on Emp.EmpID=PA.EmpID )C Where C.EmpName='Chris') as Chris_Project_Count
From (Select Emp.EmpID,EmpName,Pro.ProjectID,ProjectName 
      From Project Pro
      Join ProjectAssignment PA
      on PA.ProjectID=Pro.ProjectID
      Join Employee Emp
      on Emp.EmpID=PA.EmpID
	  GO
SELECT (SELECT COUNT(DISTINCT ProjectID) FROM dbo.Project) AS [TotalCount],
[1] AS 'Joy_ProjectCount',[2] AS 'Ira_ProjectCount',[3] AS 'Chris_ProjectCount'
FROM (SELECT ProjectID, EmpID FROM dbo.ProjectAssignment) AS AA 
PIVOT(COUNT(ProjectID) FOR EmpID IN ([1],[2],[3])) AS BB


SELECT *
FROM (SELECT ProjectID, EmpID FROM dbo.ProjectAssignment) AS A 
PIVOT(COUNT(ProjectID) FOR EmpID IN ([1],[2],[3])) AS B
