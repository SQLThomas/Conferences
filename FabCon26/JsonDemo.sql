-- ©2026 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

USE APIDemo;
GO

-- Prepare Person table
DROP TABLE IF EXISTS dbo.Person;

SELECT BEA.BusinessEntityID
      ,PE.FirstName
      ,PE.LastName
      ,PA.AddressLine1
      ,PA.AddressLine2
      ,PA.City
      ,SP.Name AS State
      ,PA.PostalCode
      ,CR.Name AS Country
      ,PP.PhoneNumber
      ,PM.EmailAddress
      ,BEA.AddressTypeID
      ,BEA.AddressID
      ,COUNT(*) OVER(PARTITION BY BEA.BusinessEntityID) AS AddressCnt
INTO dbo.Person
FROM AdventureWorks2025.Person.Person PE
  JOIN AdventureWorks2025.Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = PE.BusinessEntityID
  JOIN AdventureWorks2025.Person.Address PA ON PA.AddressID = BEA.AddressID
  JOIN AdventureWorks2025.Person.StateProvince SP ON SP.StateProvinceID = PA.StateProvinceID
  JOIN AdventureWorks2025.Person.CountryRegion CR ON CR.CountryRegionCode = SP.CountryRegionCode
  LEFT JOIN AdventureWorks2025.Person.PersonPhone PP ON PP.BusinessEntityID = PE.BusinessEntityID
  LEFT JOIN AdventureWorks2025.Person.EmailAddress PM ON PM.BusinessEntityID = PE.BusinessEntityID;
  
ALTER TABLE dbo.Person ADD CONSTRAINT PK_Person_Names PRIMARY KEY CLUSTERED
  (LastName ASC, FirstName ASC, BusinessEntityID ASC, AddressTypeID ASC);

SELECT TOP 5 * FROM dbo.Person;


-- Constructing JSON from relational table data
SELECT TOP 5 * 
FROM dbo.Person
WHERE (Country = 'Germany');

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, PhoneNumber, EmailAddress
FROM dbo.Person
WHERE (Country = 'Germany')
FOR JSON AUTO;

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, PhoneNumber, EmailAddress
FROM dbo.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, INCLUDE_NULL_VALUES;

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, ISNULL(AddressLine2, '') AddressLine2, City, [State], PostalCode, Country, PhoneNumber, EmailAddress
FROM dbo.Person
WHERE (Country = 'Germany')
FOR JSON AUTO;

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, PhoneNumber, EmailAddress
FROM dbo.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER;

SELECT TOP 5 BusinessEntityID, FirstName, LastName, AddressLine1, AddressLine2, City, [State], PostalCode, Country, PhoneNumber, EmailAddress
FROM dbo.Person
WHERE (Country = 'Germany')
FOR JSON AUTO, ROOT('Persons');


-- Joined tables -> nested JSON objects
SELECT TOP 6 BusinessEntityID, FirstName, LastName, Addresses.AddressLine1, Addresses.AddressLine2, Addresses.City
FROM dbo.Person P
JOIN AdventureWorks2025.Person.Address Addresses ON Addresses.AddressID = P.AddressID
WHERE (p.AddressCnt > 1)
ORDER BY BusinessEntityID
FOR JSON AUTO;

SELECT TOP 6 BusinessEntityID, FirstName, LastName, Addresses.AddressLine1, Addresses.AddressLine2, Addresses.City
FROM dbo.Person P
JOIN AdventureWorks2025.Person.Address Addresses ON Addresses.AddressID = P.AddressID
WHERE (p.AddressCnt > 1)
ORDER BY BusinessEntityID
FOR JSON AUTO, INCLUDE_NULL_VALUES;


-- New in SQL Server 2022: JSON_OBJECT() (default NULL ON NULL), and JSON_ARRAY()
SELECT TOP 5 JSON_OBJECT('EntityID': BusinessEntityID, 'Given Name': FirstName, 'Family Name': LastName, 'Street 1': AddressLine1, 
    'Street 2': AddressLine2, 'City': City, 'State': [State], 'ZIP Code': PostalCode, 'Country': Country ABSENT ON NULL) AS jPerson
FROM dbo.Person
WHERE (Country = 'Germany')

SELECT TOP 5 JSON_ARRAY(LastName, PhoneNumber) Phones
FROM dbo.Person
WHERE (Country = 'Germany')


-- Prepare more demo data (inspired by MS learn)
DROP TABLE IF EXISTS dbo.Families

CREATE TABLE dbo.Families (
    id INT identity CONSTRAINT PK_Families PRIMARY KEY,
    [data] NVARCHAR(MAX)
);
GO

INSERT INTO dbo.Families(data) VALUES
(  '{
    "id": "DesaiFamily",
    "parents": [
        { "familyName": "Desai", "givenName": "Prashanth" },
        { "familyName": "Miller", "givenName": "Helen" }
    ],
    "members": [
        { "familyName": "Desai", "givenName": "Jesse", "grade": 1 },
        { "familyName": "Desai", "givenName": "Lisa",  "grade": 8 }
    ],
    "address": { "state": "NY", "city": "New York City", "street": "Broadway", "phone": "212-555-1234", "fax": "212-555-4321" }
}'),
(  '{
    "id": "SQLFamily",
    "parents": [
        { "familyName": "Ward", "givenName": "Bob" },
        { "familyName": "Hoffmann", "givenName": "Anna" }
    ],
    "members": [
        { "familyName": "Geisler", "givenName": "Frank",  "grade": 22 },
        { "familyName": "Hütter", "givenName": "Thomas", "grade": 25 }        
    ],
    "address": { "state": "WA","city": "Redmond", "street": "Bill Gates Square", "phone": "425-000-000" }
}'),
( 'No Json data')

SELECT * FROM dbo.Families

-- JSON functions for retrieving, checking etc:
SELECT ID, ISJSON(data) IsItJson
FROM dbo.Families

SELECT JSON_VALUE(f.data, '$.address.city') AS City
FROM dbo.Families f
WHERE ISJSON(data) = 1

SELECT JSON_VALUE(f.data, '$.id') AS Family,  JSON_QUERY(f.data, '$.parents[0]') AS FirstParent
FROM dbo.Families f
WHERE ISJSON(data) = 1

SELECT JSON_VALUE(f.data, '$.id') AS Family,  JSON_PATH_EXISTS(f.data, '$.address.fax') AS HasFax
FROM dbo.Families f
WHERE ISJSON(data) = 1

UPDATE dbo.Families
SET data = JSON_MODIFY(data, 'lax $.address.phone', '425-555-9999')
WHERE id = 2

SELECT * FROM dbo.Families

-- Transform JSON to table data (example inspired by MS learn)
DECLARE @arraystring VARCHAR(MAX);
SET @arraystring = 
'[{"month":"Jan", "ordinal":1, "days":31},
  {"month":"Feb", "ordinal":2, "days":28},
  {"month":"Mar", "ordinal":3, "days":31},
  {"month":"Apr", "ordinal":4, "days":30},
  {"month":"May", "ordinal":5, "days":31},
  {"month":"Jun", "ordinal":6, "days":30}]';

SELECT * FROM OPENJSON(@arraystring)
WITH (month VARCHAR(3), ordinal int, days int) as months


-- New in SQL Server 2025: JSON data type
-- Prepare one old-fasioned table for comparison
DROP TABLE IF EXISTS dbo.SalesOrdersChar;
GO

CREATE TABLE dbo.SalesOrdersChar
(
    OrderNumber NVARCHAR(10) NOT NULL ,
    OrderLine INT NOT NULL,
    SOData NVARCHAR(MAX),
    CONSTRAINT PK_SalesOrdersChar PRIMARY KEY CLUSTERED(OrderNumber, OrderLine)
);
GO

INSERT INTO dbo.SalesOrdersChar
SELECT 
  SOH.SalesOrderNumber AS SONumber, 
  ROW_NUMBER() OVER(PARTITION BY SOD.SalesOrderID ORDER BY SOD.SalesOrderDetailID) AS OrderLine,
  (
    SELECT 
      CONVERT(NVARCHAR(10), SOH.OrderDate, 23) AS OrderDate, 
      CAST(SOD.OrderQty AS INT) AS Qty,
      SOD.ProductID AS Product,
      Sp.CountryRegionCode AS [Address.Country], 
      Ad.PostalCode AS [Address.ZIP], 
      Ad.City AS [Address.City]
    FROM AdventureWorks2025.Person.Address Ad 
    LEFT JOIN AdventureWorks2025.Person.StateProvince Sp ON Sp.StateProvinceID = Ad.StateProvinceID
    WHERE Ad.AddressID = SOH.BillToAddressID
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  ) AS SOData
FROM AdventureWorks2025.Sales.SalesOrderHeader SOH
Left JOIN AdventureWorks2025.Sales.SalesOrderDetail SOD 
  ON SOD.SalesOrderID = SOH.SalesOrderID;

SELECT TOP 10 * FROM dbo.SalesOrdersChar;


SET STATISTICS TIME, IO ON;  -- Enable 'actual' plan
 
SELECT *
FROM dbo.SalesOrdersChar
WHERE JSON_VALUE(SOData, '$.Address.ZIP') = '30240';

ALTER TABLE dbo.SalesOrdersChar ADD CalcZip AS JSON_VALUE(SOData, '$.Address.ZIP');
GO

CREATE INDEX ixZip ON dbo.SalesOrdersChar(CalcZip);
GO

SELECT *
FROM dbo.SalesOrdersChar
WHERE JSON_VALUE(SOData, '$.Address.ZIP') = '30240';


-- Prepare a table with the new JSON data type
DROP TABLE IF EXISTS dbo.SalesOrdersJson;
GO

CREATE TABLE dbo.SalesOrdersJson
(
    OrderNumber NVARCHAR(10) NOT NULL ,
    OrderLine INT NOT NULL,
    SOData JSON,
    CONSTRAINT PK_SalesOrdersJson PRIMARY KEY CLUSTERED(OrderNumber, OrderLine)
);
GO

INSERT INTO dbo.SalesOrdersJson
SELECT 
  SOH.SalesOrderNumber AS SONumber, 
  ROW_NUMBER() OVER(PARTITION BY SOD.SalesOrderID ORDER BY SOD.SalesOrderDetailID) AS OrderLine,
  (
    SELECT 
      CONVERT(NVARCHAR(10), SOH.OrderDate, 23) AS OrderDate, 
      CAST(SOD.OrderQty AS INT) AS Qty,
      SOD.ProductID AS Product,
      Sp.CountryRegionCode AS [Address.Country], 
      Ad.PostalCode AS [Address.ZIP], 
      Ad.City AS [Address.City]
    FROM AdventureWorks2025.Person.Address Ad 
    LEFT JOIN AdventureWorks2025.Person.StateProvince Sp ON Sp.StateProvinceID = Ad.StateProvinceID
    WHERE Ad.AddressID = SOH.BillToAddressID
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  ) AS SOData
FROM AdventureWorks2025.Sales.SalesOrderHeader SOH
Left JOIN AdventureWorks2025.Sales.SalesOrderDetail SOD 
  ON SOD.SalesOrderID = SOH.SalesOrderID;

SELECT TOP 10 * FROM dbo.SalesOrdersJson


SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_VALUE(SOData, '$.Address.ZIP') = '30240';

SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_CONTAINS(SOData, '30240', '$.Address.ZIP') = 1;

CREATE JSON INDEX ixData ON dbo.SalesOrdersJson(SOData);
GO

SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_VALUE(SOData, '$.Address.ZIP') = '30240';

SELECT *
FROM dbo.SalesOrdersJson WITH(INDEX = ixData)
WHERE JSON_VALUE(SOData, '$.Address.ZIP') = '30240';

SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_CONTAINS(SOData, '30240', '$.Address.ZIP') = 1;

SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_CONTAINS(SOData, 'La Grange', '$.Address.City') = 1;

SELECT *
FROM dbo.SalesOrdersJson
WHERE JSON_CONTAINS(SOData, 'Miami', '$.Address.City') = 1;
