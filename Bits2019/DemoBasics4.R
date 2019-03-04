# DemoBasics4.R
# Demo script: continued data analysis and visualization in R
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Read data table from website (Formula 1 results 2016)
library(magrittr)
library(rvest)
browseURL('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
f1 <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung') %>%
  html_node('table') %>%
  html_table
f1
# add column names that make sense
colnames(f1) <- c('Pos', 'Driver', 'Total', sprintf('R%02d', 1:21))
# alternatively load('data/f1.Rdata')
f1[ ,3:24] <- apply(f1[ ,3:24], 2, function(x) as.integer(gsub('-', '0', as.character(x))))
f1

library(tidyr)
library(ggplot2)
f1long <- gather(f1, Race, Points, R01:R21)
f1long
ggplot(f1long[f1long$Pos <= 9, ], aes(x=Race, y=Points, group=Driver, colour=Driver)) + geom_line() +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) + facet_wrap(~ Driver) +
  labs(title = 'F1 race results 2016, top 9 drivers',
       caption = 'source: www.formel1.de')

# Handle geospatial data, e.g. shapefiles
library(raster)
# load German 1-digit post code zones
plz1 <- shapefile('data/plz-1stellig.shp')
plz1
# colouring different grey levels
col1 <- paste0('grey', seq(90, 00, -10))
plot(plz1, col = col1)
