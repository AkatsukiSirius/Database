create table #testtemp
(ID int constraint pk_testtemp primary key)

select * from #testtemp

alter table #testtemp
drop constraint pk_testtemp

drop table #testtemp

