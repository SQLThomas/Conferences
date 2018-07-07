# Benford2.R
# Demo of Benford's law
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

library(DBI)
library(ggplot2)

# Prepare Benford basics
dig <- seq(1:9)
even <- rep(round(1/9, 4), 9)
benf <- round(log10(1 + 1/dig), 4)
dat <- cbind.data.frame(dig, even, benf)

# Connect to SQL Server using RODBC
conn <- dbConnect(odbc::odbc(), dsn = 'dockersql', uid = 'gast', pwd = 'Gast2000!')

# Get totals from SalesOrderHeader in Adventureworks
salesdata <- dbGetQuery(conn, "SELECT SalesOrderID, OrderDate, CustomerID, SalesPersonID, SubTotal
         FROM AdventureWorks2014.Sales.SalesOrderHeader")
head(salesdata)

sales <- as.integer(substring(salesdata$SubTotal, 1, 1))
sales.t <- as.data.frame(table(sales))
dat.s <- cbind(dat, sales = sales.t$Freq/sum(sales.t$Freq))
ggplot(dat.s, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Adventureworks sales 2014") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

# Extract some sales data from TankData
salesdataNav <- dbGetQuery(conn, 
  "SELECT CLE.[Customer No_], CLE.[Posting Date], CLE.[Sales (LCY)]
  FROM NavDemo.dbo.[NorthTank$Cust_ Ledger Entry] CLE
  WHERE (CLE.[Sales (LCY)] > 0)
  AND (CLE.[Posting Date] BETWEEN '20150101' AND '20151231')")

salesNav <- as.integer(substring(salesdataNav$`Sales (LCY)`, 1, 1))
salesNav.t <- as.data.frame(table(salesNav))
dat.Nav <- cbind(dat, sales = salesNav.t$Freq/sum(salesNav.t$Freq))
ggplot(dat.Nav, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Navdemo sales 2014") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

# Finally some real-world data, first sales
load('data/_bensales.Rdata')
ggplot(ben.sales, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Some real-world sales") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

# Now purchase
load('data/_benpurch.Rdata')
ggplot(ben.purch, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = purch, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Some real-world purchase") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Purch' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

dbDisconnect(conn)
# rm(list = ls())
