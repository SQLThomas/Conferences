# Shape1.R
# Demo of using shapefiles in R
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!
  
# Basics library needed
library(raster)
library(rgeos)
library(foreign)

# Load map for 1-digit post zones from shapefile
map1 <- shapefile('data/plz-1stellig')
map1
plot(map1)

# add text label for post code in the center of each sector
centroids <- gCentroid(map1, byid=TRUE)
centroidLons <- coordinates(centroids)[,1]
centroidLats <- coordinates(centroids)[,2]
text(centroidLons, centroidLats, labels=map1$plz, col="black")

# Load map for German federal states/counties from shapefile
counties <- shapefile('data/bld2011')
Encoding(counties$GEN) <- 'latin1'
counties
bld.dbf <- read.dbf('data/bld2011.dbf', as.is = TRUE)
Encoding(bld.dbf$GEN) <- 'latin1'
bld.dbf
bld.prj <- read.csv2('data/bld2011.prj', header = FALSE, as.is = TRUE)
bld.prj
plot(counties)

# Show PASS Germany regional groups
pass_de <- read.csv2('data/pass_de.csv')
pass_de
with(pass_de, points(Lon, Lat, pch = 21, bg = 'blue'))
title(main = 'PASS DE Regional Groups')
with(pass_de, text(Lon, Lat + 0.08, RG, pos = 4, cex = 0.8, col = 'darkblue'))

# Colour big (>= 10.000 km²) and small states
big.area <- 10000000000
plot(counties[counties$SHAPE_AREA >= big.area, ], col = 'orange')
plot(counties[counties$SHAPE_AREA < big.area, ], col = 'green', add = TRUE)
legend(title = 'Bundesländer', legend = c('>10.000 km²', '<10.000 km²'), 
       fill = c('orange', 'green'), cex = 0.8, x = 'topright', inset = 0.15)

# Leading parties in county parliaments
load('data/_govdata.RData')
gov

counties@data <- merge(counties@data, gov, by.x='GEN', by.y='county', all.x=TRUE, sort=FALSE)
plot(counties, col = counties$colo)
legend(title = 'Biggest party', legend = c('SPD', 'CDU', 'CSU', 'Grüne'), 
       fill = c('red', 'black', 'blue', 'green'), cex = 0.8, x = 'topright', inset = 0.12)
title('County parliaments Germany 2016')

# rm(list = ls())
