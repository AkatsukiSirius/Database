-------------------Commit----------------------
----1
Declare @INT int

begin tran
set @INT = 6
rollback tran
print @int

---- 2
Declare @INT int
begin tran
set @INT = 2
commit tran

print @int


Declare @INT int

begin tran
set @INT = 6
rollback tran


print @int
go

----------------------Rollback----------------------

use test_DB

select * from rank_test_table

begin transaction
truncate table rank_test_table
rollback transaction

select * from rank_test_table

---- After Truncation, the table still there, since we use RollBack
go

select * from rank_test_table

begin tran T1
save tran S1
    update rank_test_table
	set name='tim'
	where ID=4
rollback tran S1
    update rank_test_table
	set name='superman'
	where ID=5
commit tran T1

select * from rank_test_table
go

-----

begin tran T1 with mark 'updating table'
save tran S1
    update rank_test_table
	set name='tim'
	where ID=4
rollback tran S1
    update rank_test_table
	set name='superman'
	where ID=5
commit tran T1

select * from rank_test_table


set implicit_transactions on
update rank_test_table
set name='Tim'
where ID=4

rollback transaction

update rank_test_table
set name='superman'
where ID=5

commit transaction
set implicit_transactions off

select * from rank_test_table


----- 
Use Northwind

Begin Tran
Declare @Discount float
Set @Discount=0.05
Update Products
Set UnitPrice= UnitPrice -(@Discount*UnitPrice)
Go
---- Check the result
Select ProductID,UnitPrice
From Products
Order by UnitPrice Desc
------
Rollback
Go
Select ProductID, UnitPrice
From Products
Order by UnitPrice Desc
Go

Commit
Go