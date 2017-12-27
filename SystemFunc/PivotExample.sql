Create Database PivotExample
Use PivotExample

----------- Example 1
----------- Create Table
CREATE TABLE SalesByQuarter
    (    year INT,    -- 年份
        quarter CHAR(2),  -- 季度
        amount MONEY  -- 总额
    )

----------- Insert

SET NOCOUNT ON
    DECLARE @index INT
    DECLARE @q INT
    SET @index = 0
    DECLARE @year INT
    while (@index < 30)
    BEGIN
        SET @year = 2005 + (@index % 4)
        SET @q = (CAST((RAND() * 500) AS INT) % 4) + 1
        INSERT INTO SalesByQuarter VALUES (@year, 'Q' + CAST(@q AS CHAR(1)), RAND() * 10000.00)
        SET @index = @index + 1
    END

---------
 
Select * From SalesByQuarter 

SELECT year as [Year],
sum (case when quarter = 'Q1' then amount else 0 end) [1st Season], 
sum (case when quarter = 'Q2' then amount else 0 end) [2nd Season],
sum (case when quarter = 'Q3' then amount else 0 end) [3rd Season],
sum (case when quarter = 'Q4' then amount else 0 end) [4th Season]
FROM SalesByQuarter 
GROUP BY year 
ORDER BY year DESC


---------

Select * From SalesByQuarter
 
Select year as [Year], Q1 as [1st Season], Q2 as [2nd Season], 
       Q3 as [3rd Season], Q4 as [4th Season] 
From SalesByQuarter 
PIVOT (SUM (amount) For quarter IN (Q1, Q2, Q3, Q4) ) as P 
Order By YEAR Desc

--------- Example 2
Create Table WEEK_INCOME(WEEK VARCHAR(10),INCOME DECIMAL)

INSERT INTO WEEK_INCOME 
SELECT 'Mon',1000 
UNION ALL 
SELECT 'Tue',2000 
UNION ALL 
SELECT 'Wen',3000 
UNION ALL 
SELECT 'Thr',4000 
UNION ALL 
SELECT 'Fri',5000 
UNION ALL 
SELECT 'Sat',6000 
UNION ALL 
SELECT 'Sun',7000

Truncate Table WEEK_INCOME

Select * From WEEK_INCOME

Select Mon,Tue,Wen,Thr,Fri,Sat,Sun
--这里是PIVOT第三步（选择行转列后的结果集的列）这里可以用“*”表示选择所有列，也可以只选择某些列(也就是某些天)
From WEEK_INCOME 
--这里是PIVOT第二步骤(准备原始的查询结果，因为PIVOT是对一个原始的查询结果集进行转换操作，
--所以先查询一个结果集出来)这里可以是一个select子查询，但为子查询时候要指定别名，否则语法错误
PIVOT
(
    SUM(INCOME) for [week] in(Mon,Tue,Wen,Thr,Fri,Sat,Sun)
	--这里是PIVOT第一步骤，也是核心的地方，进行行转列操作。
	--聚合函数SUM表示你需要怎样处理转换后的列的值，
	--是总和(sum)，还是平均(avg)还是min,max等等。
	--例如如果week_income表中有两条数据并且其week都是“星期一”，其中一条的income是1000,
	--另一条income是500，那么在这里使用sum，行转列后“星期一”这个列的值当然是1500了。
	
	--后面的for [week] in([星期一],[星期二]...)中 for [week]就是说将week列的值
	--分别转换成一个个列，也就是“以值变列”。
	--但是需要转换成列的值有可能有很多，我们只想取其中几个值转换成列，那么怎样取呢？
	--就是在in里面了，比如我此刻只想看工作日的收入，在in里面就只写“星期一”至“星期五”
	--（注意，in里面是原来week列的值,"以值变列"）。
	--总的来说，SUM(INCOME) for [week] in
	--([星期一],[星期二],[星期三],[星期四],[星期五],[星期六],[星期日])
	--这句的意思如果直译出来，就是说：
	--将列[week]值为"星期一","星期二","星期三","星期四","星期五","星期六","星期日"
	--分别转换成列，这些列的值取income的总和。
)TBL--别名一定要写

----------- Example 2
create table student
(
StudentID int constraint pk_sid primary key,
StudentName Varchar(20)
)
create table marks
(
StudentID int constraint fk_sid foreign key references student(StudentID),
[Subject] Varchar(20),
Marks int
)
insert into student values (1, 'Zainab')
insert into student values (2, 'Shyam')
insert into student values (3, 'Ravi')

insert into marks values (1, 'English', 30)
insert into marks values (1, 'Maths', 45)
insert into marks values (1, 'Science', 40)
insert into marks values (2, 'English', 40)
insert into marks values (2, 'Maths', 43)
insert into marks values (2, 'Science', 42)
insert into marks values (3, 'English', 35)
insert into marks values (3, 'Maths', 41)
insert into marks values (3, 'Science', 32)

Select * From student

Select * From marks

---- Pivot: row to col

SELECT c.StudentName,
 [English] as [Eng],
 [Maths] as [Mat],
 [Science] as [Sci]
FROM (SELECT StudentID,[Subject], Marks FROM marks) o
  PIVOT (Sum([Marks]) FOR [Subject] IN ([English],[Maths],[Science])) p
  JOIN student c ON p.StudentID=c.StudentID
 ORDER BY c.StudentName

--------

Select * From student

Select * From marks

SELECT *
FROM (
SELECT count(Distinct StudentID)as Student#,count(marks.Marks) as Col1 
FROM marks) o
PIVOT (Sum(Student#) FOR Col1 IN ([a],[b])) p

Select * From marks

SELECT *
FROM marks PIVOT (Sum([Marks]) FOR [Subject] IN ([English],[Maths],[Science])) p


---------- Example 3
if object_id('tb')is not null drop table tb

go

create table tb(Name varchar(10),Course varchar(10),Mark int)

insert into tb values('Black','Chinese',74)

insert into tb values('Black','Maths',83)

insert into tb values('Black','Physics',93)

insert into tb values('White','Chinese',74)

insert into tb values('White','Maths',84)

insert into tb values('White','Physics',94)

go

select* from tb

------
select* from tb

select Name,
SUM(case Course when'Chinese'then Mark else 0 end)Chinese,
SUM(case Course when'Maths'then Mark  else 0 end)Maths,
SUM(case Course when'Physics'then Mark else 0 end)Physics
From tb
Group by Name

select* from tb
select*from tb pivot(sum(Mark) for Course in(Chinese,Maths,Physics))a
