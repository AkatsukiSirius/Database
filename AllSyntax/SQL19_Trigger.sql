Use TEST_DB
Go
------------------------ Magic Table
create trigger DML_MAGIC_TEST ON dbo.client
after insert,delete,update
as
   select * from inserted
   select * from deleted
  
   select * from client

---------------------------------------------------- 

insert into client values(1,'Bruce',12345)

update client
set clientID=2
where clientID=1

delete from client
where clientID=2

drop trigger DML_MAGIC_TEST
truncate table client
go

--------------------------

create trigger DML_MAGIC_TEST ON dbo.client
after insert,delete,update
as
   declare @inserted int,@deleted int

   select @inserted=count(*) from inserted
   select @deleted=count(*) from deleted

   if @inserted=0 and @deleted=0
      print 'A delete has occurred'
    else if @inserted<>0 and @deleted=0
      print 'A insert has occurred'
   else if @inserted<>0 and @deleted<>0
      print 'A update has occurred'

--------------------- 
---- Test 1

insert into client values(1,'Bruce','555-555-5555')

---- Test 2
update client
set clientID=2
where clientID=1

---- Test 3

delete from client
where clientID=2

--------- Drop the trigger

drop trigger DML_MAGIC_TEST
go

--------------------------------------------

create trigger DML_MAGIC_TEST ON dbo.client
instead of insert,delete,update
as
   declare @inserted int,@deleted int

   select @inserted=count(*) from inserted
   select @deleted=count(*) from deleted

    if @inserted=0 and @deleted=0
	begin
        print 'A delete has occurred'

		declare @ID int
		select @ID=clientID from deleted

        delete from client
		where clientID=@ID
	end
    else if @inserted<>0 and @deleted=0
	begin
        print 'A insert has occurred'

		insert into client
		select * from inserted
	end
    else if @inserted<>0 and @deleted<>0
	begin
        print 'A update has occurred'

		declare @ID2 int
		select @ID2=clientID from deleted

        delete from client
		where clientID=@ID2

		insert into client
		select * from inserted
	end

-------------- 

drop trigger DML_MAGIC_TEST

select * from client
truncate table client

SELECT * FROM SYS.triggers

