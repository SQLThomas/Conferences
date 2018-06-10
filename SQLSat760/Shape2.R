# Shape2.R
# Demo of using shapefiles in R
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!
 
# Load needed packages
library(GISTools)
library(plyr)
library(XML)

# Show RColorBrewer palettes
display.brewer.all()

# Load map data for Europe
p4str <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
europe <- readShapePoly('data/europe', proj4string=p4str)
plot(europe)

# Fetch GDP data
gdpdata <- readHTMLTable('http://statisticstimes.com/economy/countries-by-projected-gdp.php/', 
           which = 2, stringsAsFactors = FALSE)
# load('data/_gdpdata.Rdata')
gdpdata[3:12] <- NULL
names(gdpdata) <- c('country', 'gdp')
gdpdata$gdp <- as.numeric(gsub(',', '', gdpdata$gdp))
gdpdata$country[gdpdata$country == 'Slovak Republic'] <- 'Slovakia'
gdpdata$country[gdpdata$country == 'FYR Macedonia'] <- 'The former Yugoslav Republic of Macedonia'
gdpdata$country[gdpdata$country == 'Moldova'] <- 'Republic of Moldova'
europe@data <- merge(europe@data, gdpdata, by.x='NAME', by.y='country', all.x=TRUE, sort=FALSE)
europe@data <- europe@data[order(as.integer(as.character(europe@data$SP_ID))),]
europe$gdp[is.na(europe$gdp)] <- 0
shades.gdp <- auto.shading(europe$gdp, n = 10, cutter = quantileCuts, cols = brewer.pal(10, "RdYlBu"))
choropleth(europe, europe$gdp, shades.gdp)
choro.legend(45, 80, shades.gdp, fmt="%4.0f", title = "GDP (Billion US$)", 
             cex = 0.75, inset = 0.15)
title('GDP across Europe')

# Fetch population data
popdata <- readHTMLTable('http://statisticstimes.com/population/countries-by-population.php/', 
                     which = 2, stringsAsFactors = FALSE)
# load('data/_popdata.Rdata')
popdata <- popdata[c(2,4)]
names(popdata) <- c('country', 'population')
popdata$population <- as.numeric(gsub(',', '', popdata$population))
popdata$country[popdata$country == 'TFYR Macedonia'] <- 'The former Yugoslav Republic of Macedonia'
europe@data <- merge(europe@data, popdata, by.x='NAME', by.y='country', all.x=TRUE, sort=FALSE)
europe@data <- europe@data[order(as.integer(as.character(europe@data$SP_ID))),]
europe$population <- europe$population / 1000000
europe$population[is.na(europe$population)] <- 0
shades.pop <- auto.shading(europe$population, n = 8, cutter = rangeCuts, cols = brewer.pal(8, "RdYlBu"))
choropleth(europe, europe$population, shades.pop)
choro.legend(45, 80, shades.pop, fmt="%4.0f", title = "Population (Million)", 
             cex = 0.75, inset = 0.15)
title('Population across Europe')

# Load map for German federal states/counties from shapefile
counties <- readShapePoly('data/bld', proj4string=p4str)
counties$GEN <- as.character(counties$GEN)

# Load our sales data generated in Dynamic2.R :-)
load("data/_sales_all.Rdata")

# Aggregates for counties
sales.county <- ddply(sales.all, c('County'), summarize, Sales=sum(Amount)/1000000)
sales.county$County <- as.character(sales.county$County)
counties@data <- merge(counties@data, sales.county, by.x='GEN', by.y='County', all.x=TRUE, sort=FALSE)
shades <- auto.shading(counties$Sales, n = 5, cutter = rangeCuts, cols = brewer.pal(5, "Blues"))

choropleth(counties, counties$Sales, shades)
choro.legend(16, 55, shades, title = "Sales (Million €)")
title('Diesel sales Germany 2015')
north.arrow(6, 54, 0.2, lab='N')

# rm(list = ls())
