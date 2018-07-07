-- Dynamic2.sql
-- Demo of static vs dynamic SQL statements
-- ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
-- without warranty of any kind for any other purposes, so run at your own risk!

-- Select different database to use
-- !! We need a Dynamics NAV/Navision database here !!
USE NavDemo;

-- Multiple companies in our ERP database
SELECT Name 
FROM NavDemo.dbo.Company;

-- (Almost) all tables exist once per company
SELECT name
FROM sys.tables
WHERE name LIKE '%$Customer';

-- Collect customer names from all companies
DECLARE @Tablename varchar(128);
DECLARE @Statement varchar(1000);
DECLARE curs SCROLL CURSOR FOR  
	SELECT name
	FROM sys.tables
	WHERE name LIKE '%$Customer';

OPEN curs
FETCH FIRST FROM curs INTO @Tablename
WHILE @@fetch_status = 0
BEGIN
    SET @Statement = 'SELECT Name FROM dbo.[' + @Tablename + '];'
    --PRINT @Statement
    EXEC (@Statement)
    FETCH NEXT FROM curs INTO @Tablename
END
CLOSE curs
DEALLOCATE curs

-- Extract some sales data
-- !! Replace NothTank with applicable company name !!
SELECT TOP 20 CLE.[Customer No_], CLE.[Posting Date], CLE.[Sales (LCY)]
FROM NavDemo.dbo.[NorthTank$Cust_ Ledger Entry] CLE
WHERE (CLE.[Sales (LCY)] <> 0)
  AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')

-- Summarize sales per month per post code
SELECT CU.[Post Code] As Postcode, Datepart(Month, CLE.[Posting Date]) As Mon, SUM(CLE.[Sales (LCY)]) AS Amount
FROM NavDemo.dbo.[NorthTank$Customer] CU
LEFT OUTER JOIN NavDemo.dbo.[NorthTank$Cust_ Ledger Entry] CLE
  ON CLE.[Customer No_] = CU.No_
WHERE (CLE.[Sales (LCY)] <> 0)
  AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')
GROUP BY CU.[Post Code], CLE.[Posting Date]
ORDER BY CU.[Post Code], CLE.[Posting Date]
