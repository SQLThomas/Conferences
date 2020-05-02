# 50 ways.R
# Demo script to my presentation "50 ways to show your data"
# ©2018 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Preload packages --------------------------------------------------------
# The stuff we'll need all or most of the time :-)
library(tidyverse)


# Facets ------------------------------------------------------------------
library(rvest)

# Formula 1 race results season 2016
browseURL('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
f1 <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung') %>% 
  html_node('table') %>% 
  html_table()
# load('data/f1.Rdata')
f1

colnames(f1) <- c('Pos', 'Driver', 'Total', sprintf('R%02d', 1:21))
f1 <- as_tibble(f1) %>% 
  filter(as.integer(Pos) <= 9)
f1$Driver <- as.factor(f1$Driver)
f1[, -2] <- apply(f1[, -2], 2, function(x) as.integer(gsub('-', '0', as.character(x))))
f1
f1long <- gather(f1, Race, Points, R01:R21)
f1long <- transform(f1long, Cumulated = ave(Points, Driver, FUN = cumsum))
f1long <- transform(f1long, Average = ave(Points, Driver, FUN = cummean))
f1long

ggplot(f1long)
ggplot(f1long, aes(x = Race, y = Points))
ggplot(f1long, aes(x = Race, y = Points)) + geom_point()
ggplot(f1long, aes(x = Race, y = Points)) + geom_line()

ggplot(f1long, aes(x = Race, y = Cumulated, group = Driver, colour = Driver)) + 
  geom_line() +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) +
  labs(title = 'F1 race results 2016, top 9 drivers',
       caption = 'source: www.formel1.de')

ggplot(f1long, aes(x = Race, y = Average, group = Driver, colour = Driver)) + 
  geom_line() +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) +
  labs(title = 'F1 race results 2016, top 9 drivers',
       caption = 'source: www.formel1.de')

ggplot(f1long, aes(x = Race, y = Points, group = Driver, colour = Driver)) + 
  geom_line() +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) +
  labs(title = 'F1 race results 2016, top 9 drivers',
       caption = 'source: www.formel1.de')

ggplot(f1long, aes(x = Race, y = Points, group = Driver, colour = Driver)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~ Driver) +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) +
  labs(title = 'F1 race results 2016, top 9 drivers',
       caption = 'source: www.formel1.de')


# Violins -----------------------------------------------------------------
ggplot(f1long, aes(x = reorder(Driver, Pos), y = Points, colour = Driver)) + 
  geom_boxplot(show.legend = FALSE) + 
  labs(x = 'Driver', title = 'F1 race statistics 2016, top 9 drivers',
       caption = 'source: www.formel1.de')

summary(f1long$Points[f1long$Driver == 'Nico Rosberg'])
summary(f1long$Points[f1long$Driver == 'Lewis Hamilton'])

ggplot(f1long, aes(x = reorder(Driver, Pos), y = Points, colour = Driver, fill = Driver)) + 
  geom_violin(show.legend = FALSE) + 
  labs(x = 'Driver', title = 'F1 race statistics 2016, top 9 drivers',
       caption = 'source: www.formel1.de')


# Lollipop charts ---------------------------------------------------------
# From the mpg dataset in ggplot2
library(ggalt)

mpg
cty_mpg <- aggregate(mpg$cty, by=list(mpg$manufacturer), FUN=mean)
colnames(cty_mpg) <- c('make', 'mileage')
cty_mpg <- cty_mpg[order(cty_mpg$mileage), ] 
cty_mpg$make <- factor(cty_mpg$make, levels = cty_mpg$make) 
cty_mpg

ggplot(cty_mpg, aes(x = make, y = mileage)) + 
  geom_col(show.legend = FALSE) + 
  labs(title = 'Simplest diagram', subtitle = 'Make Vs Avg. Mileage', 
       caption = 'source: mpg dataset')
  
ggplot(cty_mpg, aes(x = make, y = mileage, fill = make)) + 
  geom_col(show.legend = FALSE) + 
  labs(title = 'Simple diagram', subtitle = 'Make Vs Avg. Mileage', 
       caption = 'source: mpg dataset')

ggplot(cty_mpg, aes(x = make, y = mileage)) + 
  geom_point(size = 3, colour = "steelblue") + 
  geom_segment(aes(x = make, xend = make, y = 0, yend = mileage)) + 
  labs(title = 'Lollipop Chart, hand-made', subtitle = 'Make Vs Avg. Mileage', 
       caption = 'source: mpg dataset') + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.6))

ggplot(cty_mpg, aes(x = make, y = mileage)) + 
  geom_lollipop(point.colour = "steelblue", point.size = 3, horizontal = FALSE) +
  labs(title = 'Lollipop Chart', subtitle = 'Make Vs Avg. Mileage', 
     caption = 'source: mpg dataset') + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 65, vjust = 0.6))


# Encircling areas --------------------------------------------------------
library(ggalt)

mpg$cyl <- as.factor(mpg$cyl)
ggplot(mpg, aes(x = displ, y = cty)) + 
  geom_point(aes(col = cyl)) + 
  # geom_encircle(aes(col = cyl), size = 2) +
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset') +
  theme_classic()

mtcars$cyl <- as.factor(mtcars$cyl)
ggplot(mtcars, aes(x = disp, y = mpg)) + 
  geom_point(aes(col = cyl)) + 
  geom_encircle(aes(color = cyl), size=2) +
  labs(title = 'Mileage over displacement, Cars of 1974', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (cu.in.)', y = 'Mileage', 
       caption = 'source: mtcars dataset') +
  theme_classic()


# Jitter plots / counts charts --------------------------------------------
ggplot(mpg, aes(cty, hwy)) + 
  geom_point() + xlim(7, 37) + ylim(5, 45) +
  labs(title = 'Scatterplot with overlapping points', 
       subtitle = 'mpg: city vs highway mileage', 
       x = 'cty', y = 'hwy',
       caption = 'this example from: Top 50 list, data: mpg')

nrow(mpg)

ggplot(mpg, aes(cty, hwy)) + xlim(7, 37) + ylim(5, 45) +
  geom_jitter(width = .5, size = 1) +
  labs(title = 'Jittered Points, no overplot',
       subtitle = 'mpg: city vs highway mileage', 
       x = 'cty', y = 'hwy',
       caption = 'this example from: Top 50 list, data: mpg')

ggplot(mpg, aes(cty, hwy)) + xlim(7, 37) + ylim(5, 45) +
  geom_count(col = 'navyblue', show.legend = F) +
  labs(title = 'Counts chart',
       subtitle = 'mpg: city vs highway mileage', 
       x = 'cty', y = 'hwy',
       caption = 'this example from: Top 50 list, data: mpg')


# Avoiding overlap of texts -----------------------------------------------
library(ggrepel)

ggplot(mtcars, aes(x = disp, y = mpg)) + 
  geom_point(col = 'blue') + 
  geom_text(aes(label = rownames(mtcars))) +
  theme_classic() +
  labs(title='Mileage over displacement, Cars of 1974', 
       subtitle = 'by brand and model',
       x = 'Displacement', y = 'Mileage', 
       caption = 'source: mtcars dataset')

ggplot(mtcars, aes(x = disp, y = mpg)) + 
  geom_point(col = 'blue') + 
  geom_text_repel(aes(label = rownames(mtcars))) +
  theme_classic() +
  labs(title='Mileage over displacement, Cars of 1974', 
       subtitle = 'by brand and model',
       x = 'Displacement', y = 'Mileage', 
       caption = 'source: mtcars dataset')

ggplot(mtcars, aes(x = disp, y = mpg)) + 
  geom_point(col = 'blue') + 
  geom_label_repel(aes(label = rownames(mtcars), fill = cyl), color = 'white',
                  fontface = 'bold', segment.colour = 'blue') +
  theme_classic() +
  labs(title='Mileage over displacement, Cars of 1974', 
       subtitle = 'by brand, model and cylinders',
       x = 'Displacement', y = 'Mileage', 
       caption = 'source: mtcars dataset')

  
# Ridgeline plots ---------------------------------------------------------
library(ggridges)

f1four <- f1long[f1long$Pos <= 4, ]
legend_ord <- levels(with(f1four, reorder(Driver, Pos)))[1:4]

ggplot(f1four, aes(x = Race, y = -Pos, height = Average, group = Driver, fill = Driver)) + 
  geom_ridgeline(stat = "identity", scale = 1, alpha = 0.5, show.legend = TRUE) +
  # geom_density_ridges(stat = "identity", scale = 4, alpha = 0.5, show.legend = TRUE) +
  theme_ridges() +
  theme(axis.title.y = element_blank(), axis.text.y = element_blank()) +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21')) +
  scale_fill_discrete(breaks = legend_ord) +
  labs(y = '', title = 'F1 race average points 2016, top 4 drivers',
       caption = 'source: www.formel1.de')


# Tree maps ---------------------------------------------------------------
# data from data.worldbank.org and Luke Duncalfe https://github.com/lukes
library(treemap)

# Unzip and rename download from https://data.worldbank.org/indicator/IT.CEL.SETS
absdata <- read_csv('data/CEL.SETS_ABS.csv', skip = 4)
absdata[61:63] <- NULL
absdata[3:59] <- NULL

countries <- read_csv('https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.csv')
# countries <- read_csv('data/countries.csv')
countries <- countries[!is.na(countries$region), ]
europe <- countries[countries$region == 'Europe', ]
europe <- europe[, c(1,3,7)]

celldata2 <- inner_join(absdata, countries, by = c('Country Code' = 'alpha-3'))

treemap(celldata2, index = c('region', 'sub-region', 'Country Name'), vSize = '2015',
        type = "index", #Type sets the organization and color scheme of your treemap
        palette = "GnBu",  #Select your color palette from the RColorBrewer presets or make your own.
        title = "Cellphone subscriptions per region/country",
        fontsize.title = 14)

celldata3 <- inner_join(absdata, europe, by = c('Country Code' = 'alpha-3'))

treemap(celldata3, index = c('sub-region', 'Country Name'), vSize = '2015',
        type = "index", palette = "GnBu", 
        title = "Cellphone subscriptions per region/country, Europe",
        fontsize.title = 14)


# Waterfall diagrams ------------------------------------------------------
# Special thanks to Hugh Parsonage for fixing an error in waterfalls just in time ;-)
library(waterfalls)
library(waterfall)

stock <- data.frame(moves = c('Inv', 'Scrap', 'Purch1', 'Prod', 'Sales', 'Purch2'), 
                   value = c(100, -20, 150, 20, -150, 110))
stock

waterfall(stock, calc_total = TRUE, total_axis_text = 'Total') +
  theme_classic() +
  labs(title='Items in stock, waterfall style', 
       x = 'Points in time', y = 'Pieces', 
       caption = 'source: data entered manually')

stock2 <- data.frame(moves = c('1', '2', '3', '4', '5', '6'), 
                    value = c(100, -20, 150, 20, -150, 110))
waterfallchart(value ~ moves, stock2, xlab = 'Points in time', ylab = 'Pieces')


# Correlograms ------------------------------------------------------------
library(ggcorrplot)
library(corrplot)

rm(mtcars)
?mtcars
mtcars
corr <- round(cor(mtcars), digits = 2)
corr

ggcorrplot(corr)
corrplot(corr)
corrplot(corr, method = 'shade', shade.col = NA, tl.col = 'black', tl.srt = 45)

col <- colorRampPalette(c('#BB4444', '#EE9988', '#FFFFFF', '#77AADD', '#4477AA'))
corrplot(corr, method = 'shade', shade.col = NA, tl.col = 'black', tl.srt = 45,
         col = col(200), addCoef.col = 'black', cl.pos = 'n', diag = FALSE, order = 'AOE')
corrplot(corr, method = 'ellipse', shade.col = NA, tl.col = 'black', tl.srt = 45,
         col = col(200), addCoef.col = 'black', cl.pos = 'n', order = 'AOE')


# Marginal plots ----------------------------------------------------------
library(ggExtra)

set.seed(30)
df <- data.frame(x = rnorm(500, 50, 10), y = runif(500, 0, 50))
p <- ggplot(df, aes(x, y)) + geom_point() + 
  labs(subtitle = 'Random data')
p
ggMarginal(p + labs(title = 'Marginal density curve'), type = 'density')
ggMarginal(p + labs(title = 'Marginal histogram'), type = 'histogram')
ggMarginal(p + labs(title = 'Marginal box plot'), type = 'boxplot')


# Radar charts ------------------------------------------------------------
#devtools::install_github("ricardo-bion/ggradar", dependencies=TRUE)
library(ggradar)
library(scales)

mtcars %>%
  rownames_to_column(var = "group") %>%
  tail(5) %>% mutate_at(vars(-group), list(rescale)) %>%
  select(1:8,12) -> mtcars_radar
mtcars_radar

ggradar(mtcars_radar, font.radar = 'Ayuthaya', 
        plot.title = 'Compare multiple properties',
        legend.text.size = 10)


# Maps --------------------------------------------------------------------
library(RCurl)
library(XML)
library(rlist)
library(ggmap)
# Load my Google-API key; sorry, you'll have to get your own
source(file = '~/RProjects/API/googleapi.R', echo = FALSE)

park.doc <- getURL('https://www.kleve.de/parkleitsystem/pls.xml')
park.xml <- xmlParse(park.doc)
p <- xmlToList(park.xml)
# load('Data/kleve.Rdata')
zeit <- as.POSIXct(p[[1]], format = '%d.%m.%Y %H:%M:%S')
p[1] <- NULL

pls <- data.frame()
pls <- list.stack(p)
pls$LON <- as.numeric(pls$LON)
pls$LAT <- as.numeric(pls$LAT)
pls$Gesamt <- as.numeric(pls$Gesamt)
pls$Aktuell <- as.numeric(pls$Aktuell)
pls$Trend <- as.numeric(pls$Trend)
pls$Status <- as.factor(pls$Status)
pls$Frei <- pls$Gesamt - pls$Aktuell
pls

map.kleve <- suppressMessages(qmap("Kleve", zoom=14, source = "google", maptype="roadmap"))
# load('Data/klevemap.Rdata')
# map.hull <- suppressMessages(qmap("Hull", zoom=13, source = "google", maptype="roadmap"))
map.kleve + 
  geom_point(data = pls, aes(x = LON, y = LAT, size = Frei, color = Status)) +
  scale_color_manual(name = "Status",
                     values = c('Geschlossen' = 'red', 'Offen' = 'green', 'Stoerung' = 'blue')) +
  labs(title = 'Parkhäuser in Kleve, freie Plätze',
       subtitle = paste('Stand:', zeit),
       caption = 'source: www.kleve.de')


# Animated plots ----------------------------------------------------------
# data from data.worldbank.org
# install gganimate using devtools, also needs imagemagick installed
# library(maptools)
library(rgdal)
library(gganimate)
library(RColorBrewer)

celldata <- read_csv('data/CEL.SETS.csv', skip = 4)
celldata[62:63] <- NULL
celldata[3:34] <- NULL
celldata <- gather(celldata, key = year, value = subscriptions, '1990':'2016')
celldata$subscriptions <- cut(celldata$subscriptions, c(0, 20, 40, 60, 80, 100, 150, 200, 350), right = FALSE)

europe <- readOGR('data/', 'eur', stringsAsFactors = FALSE) %>% 
  fortify(region = 'ISO3')
eu_map <- left_join(europe, celldata, by = c('id' = 'Country Code'))
eu_map$year <- as.integer(eu_map$year)
eu_map <- eu_map[!is.na(eu_map$year), ]

# display.brewer.all()
# for old version of gganimate:
# p <- ggplot(data = eu_map, aes(x = long, y = lat, group = group, fill=subscriptions, frame = year)) +
#   geom_polygon(color = 'gray80') + coord_map() + 
#   scale_fill_brewer(type = "seq", palette = 'YlGn') +
#   labs(title = "Cell phone subscriptions ", subtitle = 'per 100 inhabitants', 
#        caption = "map: thematicmapping.org, data: data.worldbank.org") +
#   theme_void()
# gganimate(p, ani.width = 1280, ani.height = 800, interval = .5)

p <- ggplot(data = eu_map, aes(x = long, y = lat, group = group, fill=subscriptions)) +
  geom_polygon(color = 'gray80') + coord_map() + 
  scale_fill_brewer(type = 'seq', palette = 'YlGn') +
  labs(title = 'Cell phone subscriptions {current_frame}', subtitle = 'per 100 inhabitants', 
       caption = 'map: thematicmapping.org, data: data.worldbank.org') +
  theme_void() +
  transition_manual(year)

p

# Chernoff faces ----------------------------------------------------------
library(ggChernoff)

mtcars$cyl <- as.factor(mtcars$cyl)

ggplot(mtcars, aes(x = disp, y = mpg, colour = cyl)) + 
  geom_point() + 
  geom_chernoff(aes(col = cyl, smile = mpg), size = 8) + 
  scale_color_manual(name = 'cyl', values = c('4' = 'darkgreen', '6' = 'blue', '8' = 'red')) +
  labs(title='Mileage over displacement, Cars of 1974', 
       subtitle = 'by number of cylinders, funny version',
       x = 'Displacement cu.in.', y = 'Mileage', 
       caption = 'source: mtcars dataset') +
  theme_classic()


# More extras -------------------------------------------------------------
# facet zoom
library(ggforce)
mpg$cyl <- as.factor(mpg$cyl)
ggplot(mpg, aes(x = displ, y = cty, colour = cyl)) + 
  geom_point() +
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset')

ggplot(mpg, aes(x = displ, y = cty, colour = cyl)) + 
  geom_point() +
  facet_zoom(x = cyl == 6) + 
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders, zoom on 6 cyl',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset')

# diverse themes
library(ggthemes)
mpg$cyl <- as.factor(mpg$cyl)
pl <- ggplot(mpg, aes(x = displ, y = cty, colour = cyl)) + 
  geom_point() + 
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset')
pl + theme_calc() + scale_colour_calc() + scale_shape_calc() + labs(subtitle = 'Theme: LibreOffice Calc')
pl + theme_economist() + scale_colour_economist() + labs(subtitle = 'Theme: The Economist')
pl + theme_few() + scale_colour_few() + labs(subtitle = 'Theme: Stephen Few')
pl + theme_gdocs() + scale_colour_gdocs() + labs(subtitle = 'Theme: Google Docs')
pl + theme_solarized_2() + scale_colour_solarized() + labs(subtitle = 'Theme: Solarized 2')
pl + theme_stata() + scale_colour_stata() + labs(subtitle = 'Theme: Stata')
pl + theme_wsj() + labs(subtitle = 'Theme: Wall Street Journal')

library(ggtech)
pl + theme_tech(theme = "google") + scale_fill_tech(theme = "google") + labs(subtitle = 'Theme: Google')
# Needs to install all sorts of fonts

# interactive: tooltips
library(ggiraph)
iplot <- ggplot(mpg, aes(x = displ, y = cty, colour = cyl)) + 
  geom_point_interactive(aes(tooltip = paste(manufacturer, model, displ)), size = 2) +
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset')
ggiraph(code = print(iplot))

