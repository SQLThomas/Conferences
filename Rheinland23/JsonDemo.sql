USE JsonDemo;

-- Constructing JSON from relational table data
SELECT * 
FROM Sales.Person

SELECT TOP 5 * 
FROM Sales.Person
WHERE (Country = 'Germany')

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country
FROM Sales.Person
WHERE (Country = 'Germany')
FOR JSON AUTO

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country
FROM Sales.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, INCLUDE_NULL_VALUES

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country
FROM Sales.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, 
  JSON_QUERY(PhoneNumbers) AS Phones, JSON_QUERY(EmailAddresses) AS EMails
FROM Sales.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, 
  JSON_QUERY(PhoneNumbers) AS Phones, JSON_QUERY(EmailAddresses) AS EMails
FROM Sales.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, ROOT('Persons')

-- New in SQL Server 2022: JSON_OBJECT() and JSON_ARRAY()
SELECT TOP 5 JSON_OBJECT('BusinessEntityID':p.BusinessEntityID, 'First Name':p.FirstName, 'Last Name':p.LastName, 'Address 1':p.AddressLine1, 
    'Address 2':p.AddressLine2, 'City':p.City, 'State':p.[State], 'PO Code':p.PostalCode, 'Country':p.Country) AS jPerson
FROM Sales.Person p
WHERE (Country = 'Germany')


-- Constructing JSON from relational tables data including joins
SELECT SalesOrder.[SalesOrderID]
      ,SalesOrder.[OrderDate]
      ,SalesOrder.[SalesOrderNumber]
      ,SalesOrder.[CustomerID]  
      ,SalesOrder.[TotalDue]
      ,SalesOrder.[SalesReasons]
        ,Lines.[SalesOrderDetailID]
        ,Lines.[OrderQty]
        ,Lines.[ProductID]
            ,Product.Name
            ,Product.Color
        ,Lines.[UnitPrice]
        ,Lines.[UnitPriceDiscount]
        ,Lines.[LineTotal]
FROM Sales.SalesOrderHeader SalesOrder
JOIN Sales.SalesOrderDetail Lines ON Lines.SalesOrderID = SalesOrder.SalesOrderID
JOIN Sales.Product Product ON Product.ProductID = Lines.ProductID
WHERE (SalesOrder.SalesOrderID = 2)
ORDER BY SalesOrder.SalesOrderID, Lines.SalesOrderDetailID

SELECT SalesOrder.[SalesOrderID]
      ,SalesOrder.[OrderDate]
      ,SalesOrder.[SalesOrderNumber]
      ,SalesOrder.[CustomerID]
      ,SalesOrder.[TotalDue]
      ,SalesOrder.[SalesReasons]
        ,Lines.[SalesOrderDetailID]
        ,Lines.[OrderQty]
        ,Lines.[ProductID]
            ,Product.Name
            ,Product.Color
        ,Lines.[UnitPrice]
        ,Lines.[UnitPriceDiscount]
        ,Lines.[LineTotal]
FROM Sales.SalesOrderHeader SalesOrder
JOIN Sales.SalesOrderDetail Lines ON Lines.SalesOrderID = SalesOrder.SalesOrderID
JOIN Sales.Product Product ON Product.ProductID = Lines.ProductID
WHERE (SalesOrder.SalesOrderID = 2)
ORDER BY SalesOrder.SalesOrderID, Lines.SalesOrderDetailID
FOR JSON AUTO

SELECT SalesOrder.[SalesOrderID] AS [Order.OrderID]
      ,SalesOrder.[OrderDate] AS [Order.OrderDate]
      ,SalesOrder.[SalesOrderNumber] AS [Order.OrderNo]
      ,SalesOrder.[CustomerID] AS [Order.Customer]
      ,SalesOrder.[TotalDue] AS [Order.TotalDue]
      ,SalesOrder.[SalesReasons] AS [Order.SalesReasons]
        ,Lines.[SalesOrderDetailID] AS [Order.Lines.LineNo]
        ,Lines.[OrderQty] AS [Order.Lines.Qty]
        ,Lines.[ProductID] AS [Order.Lines.ProductID]
            ,Product.Name AS [Order.Lines.ProductName]
            ,Product.Color AS [Order.Lines.ProductColour]
        ,Lines.[UnitPrice] AS [Order.Lines.UnitPrice]
        ,Lines.[UnitPriceDiscount]  AS [Order.Lines.Discount]
        ,Lines.[LineTotal] AS [Order.Lines.LineTotal]
FROM Sales.SalesOrderHeader SalesOrder
JOIN Sales.SalesOrderDetail Lines ON Lines.SalesOrderID = SalesOrder.SalesOrderID
JOIN Sales.Product Product ON Product.ProductID = Lines.ProductID
WHERE SalesOrder.SalesOrderID = 2
ORDER BY SalesOrder.SalesOrderID, Lines.SalesOrderDetailID
FOR JSON PATH

SELECT SalesOrder.[SalesOrderID] AS [OrderID]
      ,SalesOrder.[OrderDate] AS [OrderDate]
      ,SalesOrder.[SalesOrderNumber] AS [OrderNo]
      ,SalesOrder.[CustomerID] AS [Customer]
      ,SalesOrder.[TotalDue] AS [TotalDue]
      ,SalesOrder.[SalesReasons] AS [SalesReasons]
      , (
       SELECT 
         SLines.[SalesOrderDetailID] AS [LineNo]
        ,SLines.[OrderQty] AS [Qty]
        ,SLines.[ProductID] AS [ProductID]
            ,Product.Name AS [ProductName]
            ,Product.Color AS [ProductColour]
        ,SLines.[UnitPrice] AS [UnitPrice]
        ,SLines.[UnitPriceDiscount] AS [Discount]
        ,SLines.[LineTotal] AS [LineTotal]
        FROM Sales.[SalesOrderDetail] SLines
        JOIN Sales.[Product] Product ON Product.ProductID = SLines.ProductID
        WHERE SLines.SalesOrderID = SalesOrder.SalesOrderID
        ORDER BY SLines.SalesOrderDetailID
        FOR JSON PATH
        ) AS [Lines]
FROM Sales.[SalesOrderHeader] SalesOrder
WHERE SalesOrder.SalesOrderID < 3
ORDER BY SalesOrder.SalesOrderID
FOR JSON PATH, ROOT('Orders')


-- Checking JSON data in SQL Server with ISJSON()
SELECT TOP 5 _ID, jorder, ISJSON(jorder) AS IsJson
FROM Sales.JsonOrders

-- SQL Server 2022: additional parameters for ISJSON() function: VALUE, OBJECT, ARRAY, SCALAR
SELECT TOP 5 _ID, jorder, ISJSON(jorder, OBJECT) AS IsJsonObject
FROM Sales.JsonOrders

SELECT TOP 5 _ID, jorder, ISJSON(jorder, ARRAY) AS IsJsonArray
FROM Sales.JsonOrders

-- SQL Server 2022: Checking JSON_PATH_EXISTS()
SELECT TOP 10 *, JSON_PATH_EXISTS(jperson, '$.Phones[0].PhoneNumber') AS PhoneExists, JSON_PATH_EXISTS(jperson, '$.AddressLine2') AS Add2Exists
FROM Sales.JsonPerson
WHERE JSON_PATH_EXISTS(jperson, '$.AddressLine2') = 1


-- Retrieve JSON data from SQL Server
DECLARE @jsontext NVARCHAR(Max)
SELECT @jsontext = jorder
FROM Sales.JsonOrders
WHERE _ID = 2
SELECT * FROM OPENJSON(@jsontext)

DECLARE @jsontext NVARCHAR(Max)
SELECT @jsontext = jorder
FROM Sales.JsonOrders
WHERE _ID = 2
SELECT * FROM OPENJSON(@jsontext, '$.Lines[0]')

SELECT TOP 5 JSON_VALUE(jorder, '$.OrderNo') AS OrderNo, JSON_VALUE(jorder, '$.TotalDue') AS TotalDue, JSON_VALUE(jorder, '$.Customer') AS Customer
FROM Sales.JsonOrders

SELECT TOP 5 JSON_VALUE(jorder, '$.OrderNo') AS OrderNo, JSON_VALUE(jorder, '$.TotalDue') AS TotalDue, PE.FirstName, PE.LastName, PE.City
FROM Sales.JsonOrders ORD
JOIN Sales.Customer CUS ON CUS.CustomerID = JSON_VALUE(jorder, '$.Customer')
JOIN Sales.Person PE ON PE.BusinessEntityID = CUS.PersonID

SELECT PE.FirstName, PE.LastName, PE.City, Orders.OrderCnt, Orders.GrandTotal FROM 
  (SELECT JSON_VALUE(jorder, '$.Customer') As CustNo, COUNT(*) AS OrderCnt, SUM(CAST(JSON_VALUE(jorder, '$.TotalDue') AS Decimal(18,2))) AS GrandTotal
  FROM Sales.JsonOrders ORD
  GROUP BY JSON_VALUE(jorder, '$.Customer')
  HAVING COUNT(*) > 10) Orders
JOIN Sales.Customer CUS ON CUS.CustomerID = Orders.CustNo
JOIN Sales.Person PE ON PE.BusinessEntityID = CUS.PersonID
ORDER BY PE.LastName, PE.FirstName

SELECT TOP 5 JSON_VALUE(jorder, '$.OrderNo') AS OrderNo, 
  (SELECT STRING_AGG(P.ProductCol, ',')
  FROM (
    SELECT DISTINCT ProductCol
    FROM OPENJSON(JSON_QUERY(ORD.jorder, '$.Lines'))
    WITH (ProductCol nvarchar(50) '$.ProductColour')
    ) AS P ) AS Colours
FROM Sales.JsonOrders ORD


-- Modifying JSON data within SQL Server
SELECT TOP 2 *
FROM Sales.JsonPerson

SELECT JSON_VALUE(jperson, '$.FirstName') + ' ' + JSON_VALUE(jperson, '$.LastName') AS [Name], JSON_VALUE(jperson, '$.City') AS City, JSON_VALUE(jperson, '$.PostalCode') AS Postcode
FROM Sales.JsonPerson
WHERE JSON_VALUE(jperson, '$.PostalCode') = '98004'

UPDATE  Sales.JsonPerson
SET jperson = JSON_MODIFY(jperson, '$.City', 'Nice view')
WHERE JSON_VALUE(jperson, '$.PostalCode') = '98004'

SELECT JSON_VALUE(jperson, '$.FirstName') + ' ' + JSON_VALUE(jperson, '$.LastName') AS [Name], JSON_VALUE(jperson, '$.City') AS City, JSON_VALUE(jperson, '$.PostalCode') AS Postcode
FROM Sales.JsonPerson
WHERE JSON_VALUE(jperson, '$.PostalCode') = '98004'

UPDATE  Sales.JsonPerson
SET jperson = JSON_MODIFY(jperson, '$.City', 'Bellevue')
WHERE JSON_VALUE(jperson, '$.PostalCode') = '98004'


SELECT *
FROM Sales.JsonPerson
WHERE JSON_VALUE(jperson, '$.State') = 'Florida'

UPDATE  Sales.JsonPerson
SET jperson = JSON_MODIFY(jperson, '$.HappyCustomer', 'True')
WHERE JSON_VALUE(jperson, '$.State') = 'Florida'

SELECT *
FROM Sales.JsonPerson
WHERE JSON_VALUE(jperson, '$.HappyCustomer') = 'True'

UPDATE  Sales.JsonPerson
SET jperson = JSON_MODIFY(jperson, '$.HappyCustomer', NULL)
WHERE JSON_VALUE(jperson, '$.State') = 'Florida'

SELECT *
FROM Sales.JsonPerson
WHERE JSON_VALUE(jperson, '$.State') = 'Florida'
