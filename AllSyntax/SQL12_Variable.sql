USE test_DB

DECLARE @TESTTABLE TABLE (ID INT,NAME VARCHAR(40))

INSERT INTO @TESTTABLE VALUES(1,'Nally')
INSERT INTO @TESTTABLE VALUES(2,'TIM')
INSERT INTO @TESTTABLE VALUES(3,'TOM')
INSERT INTO @TESTTABLE VALUES(4,'NAVA')
INSERT INTO @TESTTABLE VALUES(5,'YI')

select * from @TESTTABLE A
     inner join employee1
	 on A.id=employee1.empID

select * from @TESTTABLE
select * from employee1

