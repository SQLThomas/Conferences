# DemoTankData.R
# Demo using sales data of German petrol stations
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Using library DBI for SQL connection
library(DBI)

# Connect to our SQL Server
conn <- dbConnect(odbc::odbc(), dsn = "dockersql", uid = 'gast', pwd = 'Gast2000!')

# Show version information
ver <- dbGetQuery(conn,'SELECT @@VERSION')
cat(ver[[1]])

# Fetch list of companies
comp <- dbGetQuery(conn, "select Name from NavDemo.dbo.Company")
comp

# Fetch list of Customer tables
tab <- dbGetQuery(conn, "select name from sys.tables where name like '%$Customer'")
tab

# Use a function to iterate through companies for summarizing sales per post code
selSales <- function(compname) {dbGetQuery(conn, paste0(
  "SELECT '", compname, "' As Sub, CU.[Post Code] As Postcode, 
  Datepart(Month, CLE.[Posting Date]) As Mon, SUM(CLE.[Sales (LCY)]) AS Amount
  FROM NavDemo.dbo.[", compname, "$Customer] CU
  LEFT OUTER JOIN NavDemo.dbo.[", compname, "$Cust_ Ledger Entry] CLE
    ON CLE.[Customer No_] = CU.No_
  WHERE (CLE.[Sales (LCY)] <> 0)
    AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')
  GROUP BY CU.[Post Code], CLE.[Posting Date]
  ORDER BY CU.[Post Code], CLE.[Posting Date]"))}
sales <- apply(comp, 1, FUN=selSales)
sales.all <- do.call(rbind, sales)
sales.all$Sub <- factor(sales.all$Sub)
sales.all$Mon <- factor(sales.all$Mon)
head(sales.all, n = 20)

# alternatively: load("Data/sales_all.Rdata")

# Aggregates for 1-digit post zone
library(plyr)
library(ggplot2)
sales.all$PLZ1 <- factor(substr(sales.all$Postcode, 1, 1))
sales.y1 <- ddply(sales.all, c('PLZ1'), summarize, Sales=sum(Amount))
sales.y1
ggplot(sales.y1, aes(x=PLZ1, y=Sales/1000000, group=1)) + 
  geom_bar(stat='identity', fill='steelblue') + 
  ggtitle('Diesel sales in Germany 2015') + ylab('Sales in M€')

# Aggregates per month and post zone
sales.m1 <- ddply(sales.all, c('PLZ1', 'Mon'), summarize, Sales=sum(Amount))
ggplot(sales.m1, aes(x=Mon, y=Sales/1000000, colour=PLZ1, group=PLZ1)) + geom_line() + 
  ggtitle('Diesel sales in Germany 2015') + ylab('Sales in M€')

# Aggregates for 2-digit post zone
sales.all$PLZ2 <- factor(substr(sales.all$Postcode, 1, 2))
sales.y2 <- ddply(sales.all, c('PLZ2'), summarize, Sales=sum(Amount))
ggplot(sales.y2, aes(x=PLZ2, y=Sales/1000000, group=1)) + 
  geom_bar(stat='identity', fill='steelblue') + 
  ggtitle('Diesel sales in Germany 2015') + ylab('Sales in M€') 

# Map for 1-digit post zones
library(raster)
library(rgeos)
# split sales into 4 ranges, assign colours
salespal <- c('palegreen1','palegreen2','palegreen3','palegreen4')
sales.y1$col <- as.character(cut(sales.y1$Sales/max(sales.y1$Sales), c(0, 0.25, 0.5, 0.75, 1), salespal))
map1 <- shapefile('data/plz-1stellig.shp')
# merge sales data into the map object
map1@data <- merge(map1@data, sales.y1, by.x='plz', by.y='PLZ1', all.x=TRUE)
map1
plot(map1, col = map1$col)
# add text label in the center of each sector
centroids <- gCentroid(map1, byid=TRUE)
centroidLons <- coordinates(centroids)[,1]
centroidLats <- coordinates(centroids)[,2]
text(centroidLons, centroidLats, labels=map1$plz, col="black")
# add a legend
legend(title = 'Rel. sales', legend = c('<25%','<50%','<75%','>75%'), 
       fill = salespal, cex = 0.8, x = 17, y = 55, box.lty = 0)

# Map for 2-digit post zones
sales.y2$col <- as.character(cut(sales.y2$Sales/max(sales.y2$Sales), c(0, 0.25, 0.5, 0.75, 1), salespal))
map2 <- shapefile('data/plz-2stellig.shp')
map2@data <- merge(map2@data, sales.y2, by.x='plz', by.y='PLZ2', all.x=TRUE)
plot(map2, col = map2$col)

# add a legend
legend(title = 'Rel. sales', legend = c('<25%','<50%','<75%','>75%'), 
       fill = salespal, cex = 0.8, x = 17, y = 55, box.lty = 0)

# surprise
laender <- shapefile('data/vg2500_bld.shp')
Encoding(laender$GEN) <- 'latin1'
plot(laender[laender$GEN == 'Thüringen', ], col = 'red', add = TRUE)

# Close connection
dbDisconnect(conn)
