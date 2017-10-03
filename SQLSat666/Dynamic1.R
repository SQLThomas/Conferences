# Dynamic1.R
# Demo of static vs dynamic SQL statements
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!
  
# Using DBI and RSQLServer for our SQL connection
# !! We need the Adventurewoks2014 database !!
library(DBI)

# Open connection
# conn <- dbConnect(RSQLServer::SQLServer(), server = "localhost", database = 'NavDemo', 
#                   properties= list(user = 'gast', password = 'Gast2000!'))
conn <- dbConnect(RSQLServer::SQLServer(), server = "win10sql", database = 'NavDemo', 
                  properties= list(user = 'gast', password = 'Gast2000!'))

# Fetch SQL Server version
dbGetQuery(conn, "SELECT @@VERSION", stringsAsFactors = FALSE)
vers <- as.character(dbGetQuery(conn, "SELECT @@VERSION", stringsAsFactors = FALSE))
vers
cat(vers)

# Show some records in SalesOrderHeader
dbGetQuery(conn, "SELECT TOP 5 * FROM AdventureWorks2014.Sales.SalesOrderHeader", stringsAsFactors = FALSE)

# Show top 10 biggest orders
orders <- dbGetQuery(conn, "
SELECT TOP 10 SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM AdventureWorks2014.Sales.SalesOrderHeader
ORDER BY SubTotal DESC", stringsAsFactors = FALSE)
orders

# Now dynamic
num <- '10'
col <- 'SubTotal'
statem <- paste(
'SELECT TOP', num, 'SalesOrderID, OrderDate, CustomerID, SubTotal, Freight
FROM AdventureWorks2014.Sales.SalesOrderHeader
ORDER BY', col, 'DESC')
neworders <- dbGetQuery(conn, statem, stringsAsFactors = FALSE)
neworders

# Cleanup
dbDisconnect(conn)
# rm(list = ls())
