-- Dynamic1.sql
-- Demo of static vs dynamic SQL statements
-- ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

-- Show SQL Server Version, nothing special
SELECT @@VERSION;

-- Select database to use
-- !! We need Adventureworks2014 here !!
USE AdventureWorks2014;

-- Show some records in SalesOrderHeader
SELECT TOP 5 *
FROM [Sales].[SalesOrderHeader];

-- Show top 10 biggest orders
SELECT TOP 10 SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM [Sales].[SalesOrderHeader]
ORDER BY SubTotal DESC;

-- Different approach
DECLARE @Statem nvarchar(1000)
SET @Statem = 
'SELECT TOP 10 SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM [Sales].[SalesOrderHeader]
ORDER BY SubTotal DESC'
EXECUTE(@Statem);

-- Now dynamic
DECLARE @Statem nvarchar(1000), @Num nvarchar(10), @Col nvarchar(100)
SET @Num = '7'
SET @Col = 'Freight'
SET @Statem = 
'SELECT TOP ' + @Num + ' SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM [Sales].[SalesOrderHeader]
ORDER BY ' + @Col + ' DESC'
EXECUTE(@Statem);

-- Now for some SQL injection, FOR EDUCATION ONLY, don't try this at work! ;-)
-- Drop the Curry table if it is left over from last demo
IF OBJECT_ID('Sales.Curry', 'U') IS NOT NULL 
  DROP TABLE Sales.Curry; 

-- Create a table Curry by copying the records of Currency
SELECT *
INTO Sales.Curry
FROM Sales.Currency;

SELECT *
FROM Sales.Curry;

-- Execute dynamic script, almost as before
DECLARE @Statem nvarchar(1000), @Num nvarchar(10), @Col nvarchar(100)
SET @Num = '10'
SET @Col = 'SubTotal DESC; TRUNCATE TABLE Sales.Curry; --'
SET @Statem = 
'SELECT TOP ' + @Num + ' SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM [Sales].[SalesOrderHeader]
ORDER BY ' + @Col + ' DESC'
--SELECT @Statem
EXECUTE(@Statem)

-- Hmm, the Curry table got emptied...
SELECT *
FROM Sales.Curry;
