Use AdventureWorks2012

SELECT
       SalesOrderHeader.SalesOrderID,
       SalesOrderHeader.OrderDate,
       SalesOrderHeader.SalesOrderNumber,
       SalesOrderHeader.PurchaseOrderNumber,
       SalesOrderHeader.CustomerID,
       SalesOrderDetail.ProductID,
       SUM(SalesOrderDetail.UnitPrice),
       SUM(SalesOrderDetail.UnitPriceDiscount),
       SUM(SalesOrderDetail.LineTotal)
      
FROM
       Sales.SalesOrderHeader,
       Sales.SalesOrderDetail
WHERE
       SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
 

GROUP BY
       SalesOrderHeader.SalesOrderID,
       SalesOrderHeader.OrderDate,
       SalesOrderHeader.SalesOrderNumber,
       SalesOrderHeader.PurchaseOrderNumber,
       SalesOrderHeader.CustomerID,
       SalesOrderDetail.ProductID