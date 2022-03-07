# Benford.R
# Application of Benford's law
# ©2022 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load needed packages
library(ggplot2)
library(rvest)
library(XML)
library(DBI)

# Calculate probabilities for first digits
dig <- seq(1:9)
even <- rep(round(1/9, 4), 9)
benf <- round(log10(1 + 1/dig), 4)
dat <- cbind.data.frame(dig, even, benf)
View(dat)

# Visualize Benford distribution
ggplot(dat, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Benford's law visualized") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Distribution", values=c('Benford' = 'red', 'Homogeneous' = 'black')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), 
        legend.background = element_blank(), legend.title = element_blank())

# Examples: population and area of countries
popdata <- read_html('https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population') |>
  html_node("table") |> html_table()
# load("data/_popdata.Rdata")
popdata <- popdata[-1, c(2,4)]
names(popdata) <- c('country', 'population')
View(popdata)

pop <- as.integer(substring(popdata$population, 1, 1))
pop.t <- as.data.frame(table(pop))
dat.p <- cbind(dat, pop = pop.t$Freq/sum(pop.t$Freq))
View(dat.p)
ggplot(dat.p, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = pop, colour = 'Population data'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Population of world's countries") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'black', 'Population data' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), 
        legend.background = element_blank())

areadata <- read_html('https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_area') |>
  html_node("table:nth-of-type(2)") |> html_table()
# load("data/_areadata.Rdata")
areadata <- areadata[-1, c(2,3)]
names(areadata) <- c('country', 'area')
areadata[c(260, 261, 263), 2] <- c('5', '3', '4')
area <- as.integer(substring(areadata$area, 1, 1))
area.t <- as.data.frame(table(area))
dat.a <- cbind(dat, area = area.t$Freq/sum(area.t$Freq))
ggplot(dat.a, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = area, colour = 'Area data'), fill = 'turquoise3') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Area of world's countries") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'black', 'Area data' = 'turquoise3')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), 
        legend.background = element_blank())


# Connect to SQL Server using DBI
conn <- DBI::dbConnect(odbc::odbc(), dsn = 'dockersql', uid = 'gast', pwd = 'Gast2000!')

# Get totals from SalesOrderHeader in Adventureworks and WWI
salesdata14 <- 
  DBI::dbGetQuery(conn, "SELECT SalesOrderID, OrderDate, CustomerID, SalesPersonID, SubTotal
                  FROM AdventureWorks2014.Sales.SalesOrderHeader")
View(salesdata14)
sales <- as.integer(substring(salesdata14$SubTotal, 1, 1))
sales.t <- as.data.frame(table(sales))
dat.s <- cbind(dat, sales = sales.t$Freq/sum(sales.t$Freq))
ggplot(dat.s, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Adventureworks 2014 sales") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'black', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())


salesdata17 <- 
  DBI::dbGetQuery(conn, "SELECT SalesOrderID, OrderDate, CustomerID, SalesPersonID, SubTotal
                  FROM AdventureWorks2017.Sales.SalesOrderHeader")
View(salesdata17)
sales <- as.integer(substring(salesdata17$SubTotal, 1, 1))
sales.t <- as.data.frame(table(sales))
dat.s <- cbind(dat, sales = sales.t$Freq/sum(sales.t$Freq))
ggplot(dat.s, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Adventureworks 2017 sales") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'black', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())


salesdataWW <- 
  DBI::dbGetQuery(conn, "SELECT InvoiceLineID, InvoiceID, StockItemID, Description, ExtendedPrice
                  FROM WideWorldImporters.Sales.InvoiceLines")
View(salesdataWW)
sales <- as.integer(substring(salesdataWW$ExtendedPrice, 1, 1))
sales.t <- as.data.frame(table(sales))
dat.s <- cbind(dat, sales = sales.t$Freq/sum(sales.t$Freq))
ggplot(dat.s, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("WideWorldImporters sales") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'black', 'Sales' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

# Introducing a dedicated Benford package
library(benford.analysis)
ben <- benford(salesdataWW$ExtendedPrice, 1)
ben
plot(ben)

# Finally some real-world data, first sales
load('data/_bensales.Rdata')
ggplot(ben.sales, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = sales, colour = 'Sales'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Some real-world sales") + xlab('Digit') + ylab('Frequency') +
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Sales' = 'steelblue2')) + 
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
  scale_colour_manual(name = "Data sets", values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 'Purch' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

DBI::dbDisconnect(conn)

# Bonus code: Benford online bibliography
library(rvest)
bibdata <- read_html('https://www.benfordonline.net/list/chronological') |>
  html_node("table") |> html_table()
# load("data/_bibdata.Rdata")
bibdata <- bibdata[ ,c(1,2)]
names(bibdata) <- c('year', 'title')
bibdata$year <- substr(bibdata$year, 2, 5)
bibdata <- bibdata[(bibdata$year < format(Sys.Date(), "%Y")), ]
bibtable <- table(bibdata$year)
plot(bibtable, type = 'h', ylab = 'Number of publications / year', col = 'blue2',
     main = paste('Development of Benford bibliography ( years ', min(bibdata$year), ' - ', 
                  max(bibdata$year), ', n =', nrow(bibdata), ')'))
text(x = c(1881, 1938), y = c(15, 15), labels = c('Newcomb', 'Benford'), srt = 90, col = 'blue2')
