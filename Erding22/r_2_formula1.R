# formula1.R
# Demo script to my presentation "Pimp your Power BI with R"
# ©2022 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Preload packages --------------------------------------------------------
library(tidyverse)
library(rvest)

# Formula 1 race results season 2016
browseURL('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
f1 <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung') %>% 
  html_node('table') %>% 
  html_table()
# load('f1.Rdata')
f1

colnames(f1) <- c('Pos', 'Driver', 'Total', sprintf('R%02d', 1:21))
f1 <- filter(f1, as.integer(Pos) <= 9)
f1$Driver <- as.factor(f1$Driver)
f1[, -2] <- apply(f1[, -2], 2, function(x) as.integer(gsub('-', '0', as.character(x))))
f1
# f1long <- gather(f1, Race, Points, R01:R21)
f1long <- pivot_longer(f1, c(R01:R21), names_to = 'Race', values_to = 'Points')
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
