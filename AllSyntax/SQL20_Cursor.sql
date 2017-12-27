declare @name varchar(50),@ID int,@string varchar(100)

declare TESTING cursor scroll
for
   select firstname,businessentityID
   from AdventureWorks2012.person.person
open TESTING
   Fetch last from TESTING into @name,@ID
   while @@FETCH_STATUS=0
   Begin
       set @string='person with ID '+cast(@ID as varchar(5))+' is named '+@name
	   print @string
	   Fetch prior from TESTING into @name,@ID
	end
close TESTING
deallocate TESTING

----------------------------------------------------------------------------

declare @name varchar(50),@ID int,@string varchar(100)

--- Step 1, declare:type, movement, where

declare TESTING cursor scroll
for
   select firstname,businessentityID
   from AdventureWorks2012.person.person

--- Step 2, Open,
open TESTING

---  Step 3, fetch status (First, Last, Next, Prior)
   Fetch TESTING into @name,@ID
   while @@FETCH_STATUS=0
   Begin
       set @string='person with ID '+cast(@ID as varchar(5))+' is named '+@name
	   print @string
	   Fetch prior from TESTING into @name,@ID
	end

--- Step 4, Close
close TESTING
--- Step 5, Deallocate
deallocate TESTING



