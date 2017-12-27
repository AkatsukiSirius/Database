------------------ Recovery Mode

---- Database property that controls how transactions are logged 
---- and what restore operations are available.
---- Typically a database uses Full or Simple recovery models
---- Can be switched at any time

---- Simple 
---- Little to no log backups 
---- Reclaims space used by logs to keep requirements small 
---- Unable to use Log Shipping, AlwaysOn, Database Mirroring, 
---- Point in Time Restores, and Media Recovery

alter database test_db 
set recovery simple

---- Full 
---- No work is lost
---- Can recover to any point as it logs all transactions

alter database test_db 
set recovery full

---- Bulk-Logged 
---- Permits high performance bulk copy operations for logs 
---- Records bulk operation logs

alter database test_db 
set recovery bulk_logged

------------------ Backup

---- Backups are used to make a compressed copy of the data in a database

---- Only backup data if it is online, any offline databases 
---- can’t be backed up

---- If a backup is started when a DB is being created, 
---- the backup will wait or time out

BACKUP DATABASE [Northwind]
TO DISK = N'D:\Work\Job Agent\SQLBackups\Nwind.bak' WITH NOFORMAT, INIT, NAME = N'Northwind-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
GO

----------------------Full Backup----------------------------

---- Copies all the data in a specific database with enough logs 
---- for recovering data

backup database test_db
to disk='C:\Backup\FB1.bak'

--- bak: full backup, all data & enough log

---------------------Differential---------------------------

---- Records all the data that has been changed or modified 
---- since the last Full Backup

Backup Database test_db
to disk='C:\Backup\FB1.dif'

--- dif: differential, data being changed since last bak

---------------------Transaction Log----------------------------

---- DBCC: Database consistency checker

---- Records all the transaction logs that were not backed up in 
---- a previous Log Backup

Backup Database test_db
to disk='C:\Backup\TLB.trn'

--- trn: transaction, not backed up in previous trn

----------------------Tail-Backup---------------------------

---- Records the latest log records that have not yet been backed up 
---- to prevent data loss and to keep the log chain intact.
---- Before you can recover a SQL Server database to its latest point
---- in time, you must back up the tail of its transaction log.
---- The tail-log backup will be the last backup of interest 
---- in the recovery plan for the database.

---- Please take note that not all restore scenarios 
---- will require you to make a tail-log backup. 
---- You are not forced to make a tail-log backup 
---- if the recovery point is already present 
---- in an earlier log backup.
---- Moreover, a tail-log backup is not necessary 
---- if you are either replacing, this includes overwriting, 
---- or moving a database and you do not need to restore it 
---- to a state from a time which is after its most recent backup.

-------------- Situations where a Tail-Log Backup is required

http://sqlbak.com/blog/tail-log-backups/