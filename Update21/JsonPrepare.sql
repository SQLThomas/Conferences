USE [JsonDemo]
DROP TABLE IF EXISTS Sales.Person;

SELECT BEA.BusinessEntityID
      ,PE.[FirstName]
      ,PE.[LastName]
      ,PA.[AddressLine1]
      ,PA.[AddressLine2]
      ,PA.[City]
      ,SP.Name AS State
      ,PA.[PostalCode]
      ,CR.Name AS Country
      ,PE.[PhoneNumbers]
      ,PE.[EmailAddresses]
INTO Sales.Person
FROM [AdventureWorks2017].[Person].[Person] PE
  JOIN [AdventureWorks2017].[Person].[BusinessEntityAddress] BEA ON BEA.BusinessEntityID = PE.BusinessEntityID
  JOIN [AdventureWorks2017].[Person].[Address] PA ON PA.AddressID = BEA.AddressID
  JOIN [AdventureWorks2017].[Person].[StateProvince] SP ON SP.StateProvinceID = PA.StateProvinceID
  JOIN [AdventureWorks2017].[Person].[CountryRegion] CR ON CR.CountryRegionCode = SP.CountryRegionCode
  WHERE BEA.AddressTypeID = 2;
  
ALTER TABLE [Sales].[Person] ADD CONSTRAINT [PK_Person_Names] PRIMARY KEY CLUSTERED 
(
	[LastName] ASC, [FirstName] ASC, [BusinessEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


DROP TABLE IF EXISTS [Sales].[JsonOrders];
CREATE TABLE [Sales].[JsonOrders](
	[_ID] [int] NOT NULL,
	[jorder] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
ALTER TABLE [Sales].[JsonOrders] ADD  CONSTRAINT [PK_JsonOrders_ID] PRIMARY KEY CLUSTERED 
(	[_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];

DECLARE @jsontext NVARCHAR(Max)
SELECT @jsontext = (
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
ORDER BY SalesOrder.SalesOrderID
FOR JSON PATH
)
INSERT INTO Sales.JsonOrders
SELECT CAST(JSON_VALUE(value, '$.OrderID') As int) AS [_ID], value AS [jorder]
FROM OPENJSON(@jsontext)


DROP TABLE IF EXISTS [Sales].[JsonPerson];
CREATE TABLE [Sales].[JsonPerson](
	[_ID] [int] NOT NULL,
	[jperson] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
ALTER TABLE [Sales].[JsonPerson] ADD  CONSTRAINT [PK_JsonPerson_ID] PRIMARY KEY CLUSTERED 
(	[_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];

DECLARE @jsontext2 NVARCHAR(Max)
SELECT @jsontext2 = (
SELECT [BusinessEntityID]
      ,[FirstName]
      ,[LastName]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[City]
      ,[State]
      ,[PostalCode]
      ,[Country]
      ,JSON_QUERY(PhoneNumbers) AS Phones
      ,JSON_QUERY(EmailAddresses) AS EMails
  FROM [JsonDemo].[Sales].[Person]
  ORDER BY [BusinessEntityID]
  FOR JSON PATH
)
INSERT INTO Sales.JsonPerson
SELECT CAST(JSON_VALUE(value, '$.BusinessEntityID') As int) AS [_ID], value AS [jperson]
FROM OPENJSON(@jsontext2)
