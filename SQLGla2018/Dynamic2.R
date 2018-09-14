# Dynamic2.R
# Demo of static vs dynamic SQL statements
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!
  
# Connect to our SQL Server using DBI
# !! We need a Dynamics NAV/Navision database for this demo !!
library(DBI)
conn <- dbConnect(odbc::odbc(), dsn = 'dockersql', uid = 'gast', pwd = 'Gast2000!')

# Multiple companies in our ERP database
comp <- dbGetQuery(conn, 'select Name from NavDemo.dbo.Company')
comp

# (Almost) all tables exist once per company
tab <- dbGetQuery(conn, "select name from sys.tables where name like '%$Customer'")
tab

# Collect customer names from all companies
for (tname in tab$name) print(dbGetQuery(conn, 
    paste0("select Name from NavDemo.dbo.[", tname, ']')))

# Extract some sales data
sales <- dbGetQuery(conn, 
"SELECT TOP 20 CLE.[Customer No_], CLE.[Posting Date], CLE.[Sales (LCY)]
FROM NavDemo.dbo.[NorthTank$Cust_ Ledger Entry] CLE
WHERE (CLE.[Sales (LCY)] <> 0)
AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')")
sales

# Summarize sales per month per post code
sales <- dbGetQuery(conn, 
"SELECT CU.[Post Code] As Postcode, Datepart(Month, CLE.[Posting Date]) As Mon, SUM(CLE.[Sales (LCY)]) AS Amount
FROM NavDemo.dbo.[NorthTank$Customer] CU
LEFT OUTER JOIN NavDemo.dbo.[NorthTank$Cust_ Ledger Entry] CLE
  ON CLE.[Customer No_] = CU.No_
WHERE (CLE.[Sales (LCY)] <> 0)
  AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')
GROUP BY CU.[Post Code], CLE.[Posting Date]
ORDER BY CU.[Post Code], CLE.[Posting Date]")
head(sales, 20)

# Use a function to iterate through companies for summarizing sales data
funcSales <- function(compname) {dbGetQuery(conn, paste0(
  "SELECT '", compname, "' As Sub, CU.[County] As County, SUM(CLE.[Sales (LCY)]) AS Amount
  FROM NavDemo.dbo.[", compname, "$Customer] CU
  LEFT OUTER JOIN NavDemo.dbo.[", compname, "$Cust_ Ledger Entry] CLE
    ON CLE.[Customer No_] = CU.No_
  WHERE (CLE.[Sales (LCY)] <> 0)
    AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')
  GROUP BY CU.[County]"))
  }

# Show for one company
funcSales('NorthTank')
# Call for all companies
sales <- apply(comp, 1, FUN=funcSales)
str(sales)

sales.all <- do.call(rbind, sales)
sales.all$Sub <- factor(sales.all$Sub)
sales.all$County <- factor(sales.all$County)
sales.all
# Save our data, we'll need it later
# save(sales.all, file = "Data/_sales_all.Rdata")

# Cleanup
dbDisconnect(conn)
# rm(list = ls())
