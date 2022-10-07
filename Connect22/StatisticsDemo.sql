--  Preparation
/*
USE [master]
ALTER DATABASE [AdventureWorks2019] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [AdventureWorks2019] 
  FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2019.bak' WITH  FILE = 1, 
  MOVE N'AdventureWorks2017' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2019.mdf',  
  MOVE N'AdventureWorks2017_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2019_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [AdventureWorks2019] SET MULTI_USER
GO
*/

USE [AdventureWorks2019] 
--  SET STATISTICS IO ON;
DBCC FREEPROCCACHE;


-- Intro

SELECT * FROM [Sales].[SalesOrderDetail]

SELECT * FROM [Person].[Address]

-- Exact hit

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 747);

DBCC SHOW_STATISTICS ([Sales.SalesOrderDetail], [IX_SalesOrderDetail_ProductID]);

EXEC sp_helpstats [Sales.SalesOrderDetail], 'ALL';

SELECT Cnt = COUNT(DISTINCT ProductID),
	Densi = 1.0 / COUNT(DISTINCT ProductID) FROM [Sales].[SalesOrderDetail];


-- Parameterized

DECLARE @Param1 int = 747;
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = @Param1);

SELECT Cnt = 1.0 / COUNT(DISTINCT ProductID) * COUNT(*) FROM [Sales].[SalesOrderDetail];


-- Inequality

DECLARE @Param2 int = 747;
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID > @Param2);

SELECT Cnt = 0.3 * COUNT(*) FROM [Sales].[SalesOrderDetail];


-- Average estimations

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 744);

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 745);

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 746);

DBCC SHOW_STATISTICS ([Sales.SalesOrderDetail], [IX_SalesOrderDetail_ProductID]);


-- Recompilation threshold / tipping point(s)

DBCC FREEPROCCACHE;
INSERT INTO [Sales].[SalesOrderDetail]
	([SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],[SpecialOfferID]
    ,[UnitPrice],[UnitPriceDiscount])
SELECT TOP 11000
	[SalesOrderID], '', [OrderQty], 747, 1, [UnitPrice], [UnitPriceDiscount]
FROM [Sales].[SalesOrderDetail];

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 747);

DBCC SHOW_STATISTICS ([Sales.SalesOrderDetail], [IX_SalesOrderDetail_ProductID]);

SELECT Cnt = 289.0 * (121317 + 11000) / 121317

SELECT Tipping1 = 500 + (0.20 * 121317), Tipping2 = SQRT(1000 * 121317)


INSERT INTO [Sales].[SalesOrderDetail]
	([SalesOrderID],[CarrierTrackingNumber],[OrderQty],[ProductID],[SpecialOfferID]
    ,[UnitPrice],[UnitPriceDiscount])
SELECT TOP 15
	[SalesOrderID], '', [OrderQty], 747, 1, [UnitPrice], [UnitPriceDiscount]
FROM [Sales].[SalesOrderDetail];

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 747);

DBCC SHOW_STATISTICS ([Sales.SalesOrderDetail], [IX_SalesOrderDetail_ProductID]);


-- Manual stats update / sample rate

DBCC FREEPROCCACHE;
UPDATE STATISTICS Sales.SalesOrderDetail [IX_SalesOrderDetail_ProductID] 
	WITH FULLSCAN, PERSIST_SAMPLE_PERCENT = ON;

SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty
FROM [Sales].[SalesOrderDetail]
WHERE (ProductID = 747);

DBCC SHOW_STATISTICS ([Sales.SalesOrderDetail], [IX_SalesOrderDetail_ProductID]);


-- Missing statistics

ALTER DATABASE [AdventureWorks2019] SET AUTO_CREATE_STATISTICS OFF;  

SELECT *
FROM [Person].[Address]
WHERE [City] = 'Paris'

SELECT SQRT(COUNT(*)) FROM [Person].[Address]

ALTER DATABASE [AdventureWorks2019] SET AUTO_CREATE_STATISTICS ON;  


-- Statistics on single columns

SELECT *
FROM [Person].[Address]
WHERE [City] = 'Paris'

DBCC SHOW_STATISTICS ([Person.Address], [_WA_Sys_00000004_3D5E1FD2]);

SELECT *
FROM [Person].[Address]
WHERE [PostalCode] = '75010'

DBCC SHOW_STATISTICS ([Person.Address], [_WA_Sys_00000006_3D5E1FD2]);


-- Correlated columns

SELECT *
FROM [Person].[Address]
WHERE ([City] = 'Paris') AND ([PostalCode] = '75010')

SELECT  19614.0 * (30.0 / 19614) * SQRT(398.0 / 19614)
