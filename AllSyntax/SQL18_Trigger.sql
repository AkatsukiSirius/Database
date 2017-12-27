---------create trigger

------DML triggers

create trigger DLM_Instead on dbo.client
instead of insert,delete,update
as
print 'a DML operation has been stopped'



insert into client values(1,'Bruce','555-555-5555')

delete from client
where clientID=1

drop trigger DLM_Instead
go

select * from client
select * from sys.triggers

create trigger DML_after on dbo.client
after insert,delete,update
as
print 'a DML operation has been stopped'

drop trigger DML_after


-----DDL triggers

create trigger deny_creation on database
after create_table
as

declare @tbname varchar(200),@string varchar(200)

select @tbname=ST.name
from sys.tables ST
where ST.create_date=(select max(create_date) from sys.tables)

set @string='drop table' + @tbname
exec (@string)

select * from sys.triggers

create table testme(id int)

drop table testme
drop trigger DML_after
drop trigger deny_creation on database
go

------- login triggers

create trigger login_test on all server
after logon
as
begin
     print suser_sname()+'has just logged into'+ upper(ltrim(@@servername))+'SQL SERVER at'+ltrim(getdate())
end

select * from sys.triggers
select * from sys.server_trigger_events

drop trigger login_test on all server