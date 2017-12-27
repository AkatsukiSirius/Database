---------------Offset-Fetch

---- Example 1

Select *
From Production.Product
Order by ListPrice DESC --- Order by is mandatory 
Offset 10 rows Fetch Next 1 row only

--- Show the 11th maximun one

---- Example 2

Select *
From Production.Product
Order by ListPrice DESC --- Order by is mandatory 
Offset 100 Rows ---- Skip the first 100 row,0 will return all rows


---- Example 3

SELECT *
From Production.Product
Order by ListPrice DESC --- Order by is mandatory 
Offset 0 Rows Fetch 25 Rows Only --- Return the first 25 rows

----- Exmaple 4

SELECT *
FROM Production.Product
ORDER BY (SELECT Null) ---- What if we dont want to Order by ?
OFFSET 1 ROW FETCH FIRST 25 ROWS ONLY