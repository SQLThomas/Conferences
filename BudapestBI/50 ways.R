# 50 ways.R
# Demo script to my presentation "50 ways to show your data"
# ©2023 Thomas Hütter, this script is provided as-is for demo and educational use only,
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
# f1long2 <- pivot_longer(f1.top9, c(R01:R21), names_to = 'Race', values_to = 'Points')
# f1long2
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


# Boxplots and violins -----------------------------------------------------------------
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

mt2 <- rownames_to_column(mtcars, var = 'model')
mt2

ggplot(mt2, aes(x = reorder(model, mpg), y = mpg)) +
  geom_col(show.legend = FALSE) +
  labs(title = 'Simplest diagram', subtitle = 'Model Vs Avg. Mileage',
       caption = 'source: mtcars dataset', x = 'model') + 
       theme(axis.text.x = element_text(angle = 90))

ggplot(mt2, aes(x = reorder(model, mpg), y = mpg, fill = model)) + 
  geom_col(show.legend = FALSE) + 
  labs(title = 'Simple coloured diagram', subtitle = 'Model Vs Avg. Mileage', 
       caption = 'source: mtcars dataset', x = 'model') + 
  theme(axis.text.x = element_text(angle = 90))

ggplot(mt2, aes(x = reorder(model, mpg), y = mpg)) + 
  geom_point(size = 3, colour = "steelblue") + 
  geom_segment(aes(x = reorder(model, mpg), xend = model, y = 0, yend = mpg)) + 
  labs(title = 'Lollipop Chart, hand-made', subtitle = 'Model Vs Avg. Mileage', 
       caption = 'source: mtcars dataset', x = 'model') + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

ggplot(mt2, aes(x = mpg, y = reorder(model, mpg))) + 
  geom_lollipop(point.colour = "steelblue", point.size = 3, horizontal = TRUE) +
  labs(title = 'Lollipop Chart', subtitle = 'Model Vs Avg. Mileage', 
     caption = 'source: mtcars dataset') + 
  theme_bw()

mt2$cyl <- as.factor(mt2$cyl)
ggplot(mt2, aes(x = mpg, y = reorder(model, mpg), colour = cyl)) + 
  geom_lollipop(point.size = 3, horizontal = TRUE) +
  scale_color_manual(breaks = c("4", "6", "8"), values=c("dodgerblue", "black", "red")) +
  labs(title = 'Lollipop Chart', subtitle = 'Model Vs Avg. Mileage', 
       caption = 'source: mtcars dataset', y = 'model') + 
  theme_bw()

# Encircling areas --------------------------------------------------------
library(ggalt)

mpg$cyl <- as.factor(mpg$cyl)
ggplot(mpg, aes(x = displ, y = cty)) + 
  geom_point(aes(col = cyl)) + 
  labs(title = 'Mileage over displacement, Cars of the 2000s', 
       subtitle = 'by number of cylinders',
       x = 'Displacement (l)', y = 'Mileage (city)', 
       caption = 'source: mpg dataset') +
  theme_classic()

ggplot(mpg, aes(x = displ, y = cty)) + 
  geom_point(aes(col = cyl)) + 
  geom_encircle(aes(col = cyl), size = 2) +
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

  
# Parliament diagrams ---------------------------------------------------------
library(ggpol)

de <- data.frame(
  parties = factor(c("AfD", "CDU/CSU", "FDP", "SSW", "Gruene", "SPD", "Linke"),
                   levels = c("AfD", "CDU/CSU", "FDP", "SSW", "Gruene", "SPD", "Linke")),
  seats   = c(83, 197, 92, 1, 118, 206, 39),
  colors  = c("lightblue", "black", "yellow", "blue", "green", "red", "purple"),
  stringsAsFactors = FALSE)
de

ggplot(de) + 
  geom_parliament(aes(seats = seats, fill = parties), color = "black") + 
  scale_fill_manual(values = de$colors, labels = de$parties) +
  coord_fixed() + labs(title = '20. Bundestag', caption = 'Source: Wikipedia') +
  theme_void() + theme(plot.title = element_text(hjust = 0.5))

ggplot(de) + 
  geom_arcbar(aes(shares = seats, fill = parties, r0 = 5, r1 = 10), sep = 0.05) + 
  scale_fill_manual(values = de$colors) +
  coord_fixed() + labs(title = '20. Bundestag', caption = 'Source: Wikipedia') +
  theme_void() + theme(plot.title = element_text(hjust = 0.5))


# Tree maps ---------------------------------------------------------------
# data from data.worldbank.org and Luke Duncalfe https://github.com/lukes
library(treemapify)

# Unzip and rename download from https://data.worldbank.org/indicator/IT.CEL.SETS
absdata <- read_csv('data/CEL.SETS_ABS.csv', skip = 4, show_col_types = FALSE)
absdata[61:63] <- NULL
absdata[3:59] <- NULL
absdata <- absdata[!is.na(absdata$`2015`), ]

countries <- read_csv('https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.csv', show_col_types = FALSE)
# countries <- read_csv('data/countries.csv')
countries <- countries[!is.na(countries$region), ]
europe <- countries[countries$region == 'Europe', ]
europe <- europe[, c(1,3,7)]

celldata2 <- inner_join(absdata, countries, by = c('Country Code' = 'alpha-3'))

ggplot(celldata2, aes(area = `2015`, label = `Country Name`, subgroup = region,
                      fill = (`2015`)/ave(`2015`, region, FUN = max))) +
  geom_treemap() + geom_treemap_subgroup_border() +
  geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 0.5, colour =
                               "lightgrey", fontface = "italic", min.size = 0) +
  geom_treemap_text(colour = "white", place = "center", reflow = T) +
  theme(legend.position = "none") + labs(title = "Cellphone subscriptions per region/country")

celldata3 <- inner_join(absdata, europe, by = c('Country Code' = 'alpha-3'))

ggplot(celldata3, aes(area = `2015`, label = `Country Name`, subgroup = `sub-region`,
                      fill = (`2015`)/ave(`2015`, `sub-region`, FUN = max))) +
  geom_treemap() + geom_treemap_subgroup_border() +
  geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 0.5, colour =
                               "lightgrey", fontface = "italic", min.size = 0) +
  geom_treemap_text(colour = "white", place = "center", reflow = T, angle = 45) +
  theme(legend.position = "none") + labs(title = "Cellphone subscriptions, European countries")


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
library(corrmorant)

rm(mtcars)
?mtcars
mtcars
mt4 <- mtcars[ , 1:4]
mt4
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

corrmorant(mt4, style = 'blue_red') + labs(title = 'Some more fancy correlations')

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
library(jsonlite)
library(ggmap)

# Load my Google-API key; sorry, you'll have to get your own
source(file = '~/Projects/RProjects/API/googleapi.R', echo = FALSE)

park.doc <- getURL('https://services.gis.konstanz.digital/geoportal/rest/services/Fachdaten/Parkplaetze_Parkleitsystem/MapServer/0/query?where=1%3D1&outFields=%2A&outSR=4326&f=json')
park.doc <- str_replace_all(park.doc, '\n', ', ')
park.doc <- str_replace_all(park.doc, '\r', '')
pls <- fromJSON(park.doc)
fnames <- pls$fields$name
pls <- flatten(pls$features)
colnames(pls) <- fnames

# load('Data/konstanz.Rdata')
pls
zeit <- as.POSIXct(pls[1, ]$Stand_von / 1000, origin="1970-01-01")

map.kn <- suppressMessages(qmap("Konstanz-Altstadt", zoom=13, source = "google", maptype="roadmap"))
# load('Data/konstanzmap.Rdata')
map.kn + 
  geom_point(data = pls, aes(x = lon, y = lat, size = real_fcap, color = has_light)) +
  scale_size(name = 'Free capacity') +
  scale_color_manual(name = "Has light", labels = c(' ' = 'No', 'ja' = 'Yes'),
                     values = c(' ' = 'red', 'ja' = 'green')) +
  labs(title = 'Parkhäuser in Konstanz, freie Plätze',
       subtitle = paste('Stand:', zeit),
       caption = '© Stadt Konstanz, Amt für Liegenschaften und Geoinformation ')


# Animated plots ----------------------------------------------------------
# data from International Monetary Fund www.imf.org
library(gganimate)
library(ggflags)
library(MazamaSpatialUtils)

imf <- read_tsv('https://www.imf.org/imf/weodatabase/downloadreport?c=122,124,423,939,172,132,134,174,178,136,941,946,137,181,138,182,936,961,184,&s=NGDPDPC,PCPIPCH,LUR,GGR_NGDP,&sy=1980&ey=2027&ssm=0&scsm=0&scc=0&ssd=1&ssc=0&sic=1&sort=country&ds=.&br=1&wsid=cd56ebc4-3c2e-46e6-bc47-53cfbc29bad1', locale=locale(encoding="UTF-16LE"), na = c('n/a', '--'))
imf$ISO <- tolower(iso3ToIso2(imf$ISO))
colnames(imf)[3] <- "Subject"
imf <- imf[-c(4,5,54,55)]
imf
imf <- pivot_longer(imf, '1980':'2027', names_to = 'Year', values_to = 'Value')

ggplot(imf, aes(x = Year, y = Value, group = Country)) +
  geom_line(colour = 'steelblue', linewidth = 1) +
  facet_grid(Subject ~ Country, scales = "free_y")

imf <- pivot_wider(imf, names_from = 'Subject', values_from = 'Value')
imf$ISO <- as.factor(imf$ISO)
imf$Country <- as.factor(imf$Country)
imf$Year <- as.integer(imf$Year)
colnames(imf)[4:7] <- c('GDP', 'Inflation', 'Unemployment', 'GenGovRevenue')
imf

ggplot(imf, aes(x = GenGovRevenue, y = Unemployment, size = Unemployment, colour = Country)) +
  geom_point(alpha = 0.7) +
  scale_size(range = c(2, 12)) + guides(size = 'none') +
  labs(title = 'Year: {frame_time}', x = 'GenGovRevenue', y = 'Unemployment') +
  transition_time(Year) + ease_aes('linear')

ggplot(imf, aes(x = GenGovRevenue, y = Unemployment, size = Unemployment, country = ISO)) +
  geom_flag() +
  scale_country() +
  scale_size(range = c(2, 12)) + guides(size = 'none') +
  labs(title = 'Year: {closest_state}', x = 'GenGovRevenue', y = 'Unemployment') +
  transition_states(Year, transition_length = 3, state_length = 1, wrap = FALSE) +
  ease_aes('linear')

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
girafe(code = print(iplot))

