-- ©2025 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

SELECT @@VERSION;

USE AdventureWorks2025;

SELECT 'Customer' AS TableName, count(*) AS RecordCount FROM [Sales].[Customer]
UNION 
SELECT '  Store', count(*) FROM [Sales].[Store]
UNION 
SELECT 'SalesOrderHeader', count(*) FROM [Sales].[SalesOrderHeader]
UNION 
SELECT '  SalesOrderDetail', count(*) FROM [Sales].[SalesOrderDetail]

SELECT TOP 10 *
FROM [Sales].[Customer] WHERE CustomerID > 696

SELECT TOP 10 *
FROM [Sales].[SalesOrderHeader]

SELECT TOP 20 *
FROM [Sales].[SalesOrderDetail]

SELECT TOP 20 *
FROM [Production].[Product]

SELECT Pers.FirstName + ' ' + Pers.LastName AS CustomerName, SOH.SalesOrderNumber, SOD.SalesOrderDetailID, Prod.ProductNumber, Prod.Name AS ProdName, SOD.LineTotal
FROM [Sales].[SalesOrderDetail] SOD 
JOIN [Sales].[SalesOrderHeader] SOH ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = SOH.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Production].[Product] Prod ON Prod.ProductID = SOD.ProductID


---- Aggregate functions:

SELECT COUNT(*) OrderLines, 
  SUM(LineTotal) OrderTotal
FROM [Sales].[SalesOrderDetail]
--
WHERE SalesOrderID = '43666'

SELECT SalesOrderID, 
  COUNT(*) OrderLines, 
  SUM(LineTotal) OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID IN ('43666', '43667', '43668')
GROUP BY SalesOrderID
ORDER BY SalesOrderID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER(PARTITION BY SalesOrderID) As OrderLines,
  SUM(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID IN ('43666', '43667', '43668')
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  CAST(ROUND(LineTotal / SUM(LineTotal) OVER(PARTITION BY SalesOrderID) * 100.0, 2, 0) AS money) AS PercentOfOrder
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID IN ('43666', '43667', '43668')
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SOH.CustomerID, SOD.SalesOrderID, SOD.SalesOrderDetailID, SOD.ProductID, SOd.LineTotal,
  MIN(LineTotal) OVER(PARTITION BY SOH.CustomerID) AS CustMin,
  AVG(LineTotal) OVER(PARTITION BY SOH.CustomerID) AS CustAvg,
  MAX(LineTotal) OVER(PARTITION BY SOH.CustomerID) AS CustMax
FROM [Sales].[SalesOrderDetail] SOD
JOIN [Sales].[SalesOrderHeader] SOH ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE SOH.CustomerID = '30052'
ORDER BY SOD.SalesOrderID, SOD.SalesOrderDetailID

SELECT SOH.CustomerID, SOD.SalesOrderID, SOD.SalesOrderDetailID, ProductID, LineTotal,
  SUM(LineTotal) OVER(PARTITION BY SOD.SalesOrderID) AS OrderTotal,
  SUM(LineTotal) OVER(PARTITION BY SOH.CustomerID) AS CustTotal
FROM [Sales].[SalesOrderDetail] SOD
JOIN [Sales].[SalesOrderHeader] SOH ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE SOH.CustomerID = '30052'
ORDER BY SOD.SalesOrderID, SOD.SalesOrderDetailID


-- Named window definition:

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*)       OVER(PARTITION BY SalesOrderID) As OrderLines,
  SUM(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderTotal,
  MIN(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderMin,
  AVG(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderAvg,
  MAX(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderMax
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER Win As OrderLines,
  SUM(LineTotal) OVER Win AS OrderTotal,
  MIN(LineTotal) OVER Win AS OrderMin,
  AVG(LineTotal) OVER Win AS OrderAvg,
  MAX(LineTotal) OVER Win AS OrderMax
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
WINDOW Win AS (PARTITION BY SalesOrderID)
ORDER BY SalesOrderID, SalesOrderDetailID


---- Window frames:

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER Win As OrderLines,
  SUM(LineTotal) OVER Win AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
WINDOW Win AS (PARTITION BY SalesOrderID)
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER Win As OrderLines,
  SUM(LineTotal) OVER Win AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
WINDOW Win AS (PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID)
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER Win As OrderLines,
  SUM(LineTotal) OVER Win AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
WINDOW Win AS (PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY SalesOrderID, SalesOrderDetailID

SELECT SalesOrderID, SalesOrderDetailID, ProductID, LineTotal,
  COUNT(*) OVER Win AS OrderLines,
  SUM(LineTotal) OVER Win AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID = '43666'
WINDOW Win AS (PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY SalesOrderID, SalesOrderDetailID


-- Running total

SELECT CustomerID, SalesOrderID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
  SUM(TotalDue) OVER Win AS TotalToDate
FROM [Sales].[SalesOrderHeader]
WHERE CustomerID = '30052'
WINDOW Win AS (PARTITION BY CustomerID ORDER BY OrderDate, SalesOrderID)
ORDER BY CustomerID, OrderDate, SalesOrderID

SELECT CustomerID, SalesOrderID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
  SUM(TotalDue) OVER Win AS TotalToDate
FROM [Sales].[SalesOrderHeader]
WHERE CustomerID = '30052'
WINDOW Win AS (PARTITION BY CustomerID ORDER BY OrderDate, SalesOrderID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY CustomerID, OrderDate, SalesOrderID

-- Moving average

SELECT CustomerID, SalesOrderID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
  AVG(TotalDue) OVER Win AS AverageOf3
FROM [Sales].[SalesOrderHeader]
WHERE CustomerID = '30052'
WINDOW Win AS (PARTITION BY CustomerID ORDER BY OrderDate, SalesOrderID ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
ORDER BY CustomerID, OrderDate, SalesOrderID


---- Ranking functions:

-- ROW_NUMBER()

SELECT SalesOrderID, SalesOrderDetailID, 
  ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY SalesOrderDetailID) AS RowNumber,
  ProductID, LineTotal,
  SUM(LineTotal) OVER(PARTITION BY SalesOrderID) AS OrderTotal
FROM [Sales].[SalesOrderDetail]
WHERE SalesOrderID IN ('43666', '43667', '43668')
ORDER BY SalesOrderID, SalesOrderDetailID

-- Filtered DELETE FROM

DROP TABLE IF EXISTS [Sales].[SomeOrders] 

SELECT SalesOrderNumber, OrderDate, [Status], [TerritoryID], TotalDue
INTO [Sales].[SomeOrders]
FROM [Sales].[SalesOrderHeader]
WHERE SalesOrderID % 20 = 0

INSERT INTO [Sales].[SomeOrders]
SELECT SalesOrderNumber, OrderDate, [Status], [TerritoryID], TotalDue
FROM [Sales].[SalesOrderHeader]
WHERE (SalesOrderID % 40 = 0)

INSERT INTO [Sales].[SomeOrders]
SELECT SalesOrderNumber, OrderDate, [Status], [TerritoryID], TotalDue
FROM [Sales].[SalesOrderHeader]
WHERE (SalesOrderID % 80 = 0)

SELECT * FROM [Sales].[SomeOrders]
ORDER BY SalesOrderNumber

SELECT ROW_NUMBER() OVER(PARTITION BY SalesOrderNumber ORDER BY SalesOrderNumber) AS Row_Num, * 
FROM [Sales].[SomeOrders]
ORDER BY SalesOrderNumber

DELETE T
FROM (
  SELECT ROW_NUMBER() OVER(PARTITION BY SalesOrderNumber ORDER BY SalesOrderNumber) AS Row_Num
  FROM [Sales].[SomeOrders]) T
WHERE Row_Num > 1

SELECT * FROM [Sales].[SomeOrders]
ORDER BY SalesOrderNumber

DROP TABLE IF EXISTS [Sales].[SomeOrders] 

-- RANK(), DENSE_RANK()

SELECT SalesOrderID, SalesOrderDetailID, LineTotal,
  RANK() OVER(ORDER BY LineTotal DESC) AS Rank,
  DENSE_RANK() OVER(ORDER BY LineTotal DESC) AS DenseRank
FROM [Sales].[SalesOrderDetail]
ORDER BY LineTotal DESC

-- NTILE()

SELECT [FirstName], [LastName], SalesYTD,
    NTILE(4) 
    OVER(ORDER BY SalesYTD DESC) AS Quartile
FROM [Sales].[vSalesPerson]
ORDER BY SalesYTD DESC


---- Statictical/analytical functions:

-- PERCENT_RANK(), CUME_DIST()

SELECT [FirstName], [LastName], SalesYTD,
  PERCENT_RANK() OVER (ORDER BY SalesYTD) * 100 AS PctRank,
  ROUND(CUME_DIST() OVER (ORDER BY SalesYTD) * 100, 2) AS CumeDist
FROM Sales.vSalesPerson
ORDER BY SalesYTD DESC

-- PERCENTILE_CONT(), PERCENTILE_DISC()

SELECT DISTINCT SP.[FirstName], SP.[LastName],
  COUNT(*) OVER(PARTITION BY SOH.SalesPersonID) AS OrderCount,
  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY SOH.TotalDue) OVER(PARTITION BY SOH.SalesPersonID) AS MedianCont,
  PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY SOH.TotalDue) OVER(PARTITION BY SOH.SalesPersonID) AS MedianDisc
FROM [Sales].[SalesOrderHeader] SOH
JOIN [Sales].[vSalesPerson] SP
  ON SP.BusinessEntityID = SOH.SalesPersonID
ORDER BY SP.[LastName], SP.[FirstName]

SELECT SP.[FirstName], SP.[LastName], TotalDue
FROM [Sales].[SalesOrderHeader] SOH
JOIN [Sales].[vSalesPerson] SP
  ON SP.BusinessEntityID = SOH.SalesPersonID
WHERE SP.LastName = 'Abbas'
ORDER BY TotalDue ASC


---- Offset functions:

-- LAG(), LEAD()

SELECT CustomerID, SalesOrderID,
  LAG(TotalDue) OVER Win AS LastOrder,
  TotalDue AS ThisOrder,
  LEAD(TotalDue) OVER Win AS NextOrder
FROM [Sales].[SalesOrderHeader]
WINDOW Win AS (PARTITION BY CustomerID ORDER BY CustomerID, SalesOrderID)
ORDER BY CustomerID, SalesOrderID

SELECT CustomerID, SalesOrderID,
  LAG(TotalDue, 1, 0) OVER Win AS LastOrder,
  TotalDue AS ThisOrder,
  LEAD(TotalDue, 1, 0) OVER Win AS NextOrder
FROM [Sales].[SalesOrderHeader]
WINDOW Win AS (PARTITION BY CustomerID ORDER BY CustomerID, SalesOrderID)
ORDER BY CustomerID, SalesOrderID

-- FIRST_VALUE(), LAST_VALUE()

SELECT DISTINCT CONVERT(varchar, OrderDate, 23) OrderDate,
  FIRST_VALUE(CustomerID) OVER Win AS FirstCustomer,
  LAST_VALUE(CustomerID) OVER Win AS LastCustomer
FROM [Sales].[SalesOrderHeader]
WINDOW Win AS (PARTITION BY OrderDate ORDER BY OrderDate, SalesOrderID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY OrderDate


---- Specials:

-- STRING_AGG()

SELECT STRING_AGG(FirstName, ', ') AS FirstNames
FROM Sales.vSalesPerson

SELECT STRING_AGG(FirstName, ', ') WITHIN GROUP (ORDER BY FirstName) AS FirstNames
FROM Sales.vSalesPerson

SELECT TOP 10 City,
  STRING_AGG(CONVERT (NVARCHAR (MAX), EmailAddress), ';') WITHIN GROUP (ORDER BY EmailAddress) AS Emails
FROM Person.BusinessEntityAddress AS BEA
INNER JOIN Person.Address AS A
  ON BEA.AddressID = A.AddressID
INNER JOIN Person.EmailAddress AS EA
  ON BEA.BusinessEntityID = EA.BusinessEntityID
GROUP BY City;

-- First and last record in a partition

SELECT SalesOrderID, CustomerID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
  LAG(0) OVER Win AS _first,
  LEAD(0) OVER Win AS _last
FROM [Sales].[SalesOrderHeader]
WINDOW Win AS (PARTITION BY CustomerID ORDER BY [CustomerID], OrderDate)

SELECT SalesOrderID, CustomerID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
  LAG(0, 1, 1) OVER Win AS _first,
  LEAD(0, 1, 1) OVER Win AS _last
FROM [Sales].[SalesOrderHeader]
WINDOW Win AS (PARTITION BY CustomerID ORDER BY [CustomerID], OrderDate)

SELECT T.*
FROM (
  SELECT SalesOrderID, CustomerID, CONVERT(varchar, OrderDate, 23) OrderDate, TotalDue,
    LAG(0, 1, 1) OVER Win AS _first,
    LEAD(0, 1, 1) OVER Win AS _last
  FROM [Sales].[SalesOrderHeader]
  WINDOW Win AS (PARTITION BY CustomerID ORDER BY [CustomerID], OrderDate)
  ) T
WHERE (_first = 1) OR (_last = 1)


--- Gaps and islands

DROP TABLE IF EXISTS [Sales].[SomeDates] 

CREATE TABLE [Sales].[SomeDates] (
  TheDate DATE NOT NULL CONSTRAINT PK_TheDate PRIMARY KEY
)

INSERT INTO [Sales].[SomeDates](TheDate) VALUES 
  ('2025-09-22'),
  ('2025-09-23'),
  ('2025-09-25'),
  ('2025-09-26'),
  ('2025-09-29'),
  ('2025-09-30'),
  ('2025-10-01'),
  ('2025-10-02'),
  ('2025-10-06'),
  ('2025-10-07'),
  ('2025-10-08')

SELECT TheDate FROM [Sales].[SomeDates];

-- Our expected output:

-- GapStart    GapEnd          IslandStart IslandEnd
-- ----------  ----------      ----------  ----------
-- 2025-09-24  2025-09-24      2025-09-22  2025-09-23
-- 2025-09-27  2025-09-28      2025-09-25  2025-09-26
-- 2025-10-03  2025-10-05      2025-09-29  2025-10-02
--                             2025-10-06  2025-10-08

SELECT TheDate AS currentDate, LEAD(TheDate) OVER(ORDER BY TheDate) AS nextDate
FROM [Sales].[SomeDates];

WITH CTE AS (
  SELECT TheDate AS currentDate, LEAD(TheDate) OVER(ORDER BY TheDate) AS nextDate
  FROM [Sales].[SomeDates]
)
SELECT DATEADD(DAY, 1, currentDate) AS GapStart, DATEADD(DAY, -1, nextDate) GapEnd
FROM CTE
WHERE DATEDIFF(DAY, currentDate, nextDate) > 1;


SELECT TheDate,
  DENSE_RANK() OVER(ORDER BY TheDate) AS Rank,
  DATEADD(day, - DENSE_RANK() OVER(ORDER BY TheDate), TheDate) AS Diff
FROM [Sales].[SomeDates];

WITH CTE AS (
  SELECT TheDate,
    DENSE_RANK() OVER(ORDER BY TheDate) AS Rank,
    DATEADD(day, - DENSE_RANK() OVER(ORDER BY TheDate), TheDate) AS Diff
  FROM [Sales].[SomeDates]
)
SELECT MIN(TheDate) AS IslandStart, MAX(TheDate) AS IslandEnd
FROM CTE
GROUP BY Diff;

DROP TABLE IF EXISTS [Sales].[SomeDates] 


SELECT OrderDate
FROM [Sales].[SalesOrderHeader];

WITH CTE AS (
  SELECT OrderDate AS currentDate, LEAD(OrderDate) OVER(ORDER BY OrderDate) AS nextDate
  FROM [Sales].[SalesOrderHeader]
)
SELECT CONVERT(varchar, DATEADD(day, 1, currentDate), 23) AS GapStart, CONVERT(varchar, DATEADD(day, -1, nextDate), 23) GapEnd
FROM CTE
WHERE DATEDIFF(day, currentDate, nextDate) > 1;

WITH CTE AS (
  SELECT OrderDate,
    DENSE_RANK() OVER(ORDER BY OrderDate) AS Rank,
    DATEADD(day, - DENSE_RANK() OVER(ORDER BY OrderDate), OrderDate) AS Diff
  FROM [Sales].[SalesOrderHeader]
)
SELECT CONVERT(varchar, MIN(OrderDate), 23) AS IslandStart, CONVERT(varchar, MAX(OrderDate), 23) AS IslandEnd
FROM CTE
GROUP BY Diff
ORDER BY Diff;
