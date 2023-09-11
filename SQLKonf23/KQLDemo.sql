-- ©2023 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

USE AdventureWorks2022;

SELECT @@VERSION;

SELECT *
FROM [Sales].[SalesOrderHeader]
LIMIT 10;

SELECT TOP 10 *
FROM [Sales].[SalesOrderHeader];

SELECT TOP 10 SalesOrderNumber, CustomerID, TerritoryID, TotalDue
FROM [Sales].[SalesOrderHeader];

SELECT TOP 10 Head.SalesOrderNumber, Cust.CustomerID, Pers.FirstName, COALESCE(Pers.MiddleName, '') AS MiddleName, Pers.LastName, Head.TotalDue
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID;

-- Won't work:
SELECT Head.SalesOrderNumber, Cust.CustomerID, Pers.FirstName, COALESCE(Pers.MiddleName, '') AS MiddleName, Pers.LastName, 
    Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Head.TotalDue
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
WHERE Country = 'DE'
ORDER BY Country;

SELECT Head.SalesOrderNumber, Cust.CustomerID, Pers.FirstName, COALESCE(Pers.MiddleName, '') AS MiddleName, Pers.LastName, 
    Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Head.TotalDue
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
WHERE Terr.CountryRegionCode = 'DE';

SELECT Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Ship.Name AS ShipBy, 
    COUNT(*) AS OrderCount, SUM(Head.TotalDue) AS TotalWorth
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
JOIN [Purchasing].[ShipMethod] Ship ON Ship.ShipMethodID = Head.ShipMethodID
GROUP BY Terr.CountryRegionCode, Terr.Name, Ship.Name;

SELECT Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Ship.Name AS ShipBy, 
    COUNT(*) AS OrderCount, SUM(Head.TotalDue) AS TotalWorth
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
JOIN [Purchasing].[ShipMethod] Ship ON Ship.ShipMethodID = Head.ShipMethodID
GROUP BY Terr.CountryRegionCode, Terr.Name, Ship.Name
HAVING COUNT(*) > 500;

SELECT Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Ship.Name AS ShipBy, 
    COUNT(*) AS OrderCount, SUM(Head.TotalDue) AS TotalWorth
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
JOIN [Purchasing].[ShipMethod] Ship ON Ship.ShipMethodID = Head.ShipMethodID
GROUP BY Terr.CountryRegionCode, Terr.Name, Ship.Name
HAVING COUNT(*) > 500
ORDER BY OrderCount DESC;

SELECT TOP 3 Terr.CountryRegionCode AS Country, Terr.Name AS Territory, Ship.Name AS ShipBy, 
    COUNT(*) AS OrderCount, SUM(Head.TotalDue) AS TotalWorth
FROM [Sales].[SalesOrderHeader] Head
JOIN [Sales].[Customer] Cust ON Cust.CustomerID = Head.CustomerID
JOIN [Person].[Person] Pers ON Pers.BusinessEntityID = Cust.PersonID
JOIN [Sales].[SalesTerritory] Terr ON Terr.TerritoryID = Head.TerritoryID
JOIN [Purchasing].[ShipMethod] Ship ON Ship.ShipMethodID = Head.ShipMethodID
GROUP BY Terr.CountryRegionCode, Terr.Name, Ship.Name
HAVING COUNT(*) > 500
ORDER BY OrderCount DESC;
