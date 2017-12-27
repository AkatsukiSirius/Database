---------------------------Partitions----------------------
---- Steps:

---- Create a Partition Function
---- Create File Groups & Assign a File to Each
---- Create a Partition Scheme
---- Create/Modify a Table/Index with Partition Scheme
---- If CI already existed, we have to drop it.


---------------1) Create a Partition Function
---- Defines a boundary point for partitioning of data
---- along with the data type on which the partition needs
---- to be done.

create partition function part_func(int)
as
range left for values (50,100,150,200)

--------------- 2) Create File Groups & Assign a File to Each
---- Defines name, filename, path,size,maxsize,filegrowth.

alter database test_db
   add filegroup filegroup1
alter database test_db
   add filegroup filegroup2
alter database test_db
   add filegroup filegroup3
alter database test_db
   add filegroup filegroup4
 alter database test_db
   add filegroup filegroup5



alter database test_db
   add file 
   (name=FG1_dat,
   filename="C:\Partitions\FG1.ndf",
   size=30MB,
   maxsize=50MB,
   filegrowth=5MB)
   to filegroup filegroup1

alter database test_db
   add file 
   (name=FG2_dat,
   filename="C:\Partitions\FG2.ndf",
   size=30MB,
   maxsize=50MB,
   filegrowth=5MB)
   to filegroup filegroup2

alter database test_db
   add file 
   (name=FG3_dat,
   filename="C:\Partitions\FG3.ndf",
   size=30MB,
   maxsize=50MB,
   filegrowth=5MB)
   to filegroup filegroup3

alter database test_db
   add file 
   (name=FG4_dat,
   filename="C:\Partitions\FG4.ndf",
   size=30MB,
   maxsize=50MB,
   filegrowth=5MB)
   to filegroup filegroup4


   alter database test_db
   add file 
   (name=FG5_dat,
   filename="C:\Partitions\FG5.ndf",
   size=30MB,
   maxsize=50MB,
   filegrowth=5MB)
   to filegroup filegroup5


---------------3) Create a Partition Scheme
---- Describes physical file groups on to the
---- corresponding data needs to be partitioned
---- and must be mapped with partition function.
---- (mapping each partition to each file group)

Create Partition Scheme PART_SCHEME
AS
Partition PART_FUNC TO
(filegroup1,filegroup2,filegroup3,filegroup4,filegroup5)

create table partition_table
(ID int identity(1,1),name varchar(50)) on part_schame(ID)

drop table partition_table
drop partition scheme part_scheme
drop partition function part_func


---------------4) Create/Modify a Table/Index with Partition Scheme

alter database test_db
remove file fg1_dat

alter database test_db
remove file fg2_dat
alter database test_db
remove file fg3_dat
alter database test_db
remove file fg4_dat
alter database test_db
remove file fg5_dat

alter database test_db
remove filegroup filegroup1
alter database test_db
remove filegroup filegroup2
alter database test_db
remove filegroup filegroup3
alter database test_db
remove filegroup filegroup4
alter database test_db
remove filegroup filegroup5

use test_DB
go
begin tran
create partition function [part_func] as range left for value(N'50',N'100')

create partition scheme [part_scheme] as partition [part_fuc] to (primary1,primary2,primary3)
create clustered index [clusteredindex_on_part_scheme_6355555555527] on [dbo].[bulk_op]
(ID ) with(sort_in_tempob=off_drop_existing=off,online=off) on part_scheme(ID)
drop index [clusteredindex_on_part_scheme_6355555555527] on [dbo].[bulk_op]

commit tran