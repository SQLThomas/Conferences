# Benford1.R
# Demo of Benford's law
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load needed packages
library(ggplot2)
library(XML)

# Calculate probabilities for first digits
dig <- seq(1:9)
even <- rep(round(1/9, 4), 9)
benf <- round(log10(1 + 1/dig), 4)
dat <- cbind.data.frame(dig, even, benf)
dat

# Visualize Benford distribution
ggplot(dat, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Benford's law visualized") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), legend.background = element_blank())

# Examples: population and area of countries
popdata <- readHTMLTable('http://statisticstimes.com/population/countries-by-population.php/', 
                         which = 2, stringsAsFactors = FALSE)
# load("Data/_popdata.Rdata")
popdata <- popdata[c(2,4)]
names(popdata) <- c('country', 'population')
head(popdata)

pop <- as.integer(substring(popdata$population, 1, 1))
pop.t <- as.data.frame(table(pop))
dat.p <- cbind(dat, pop = pop.t$Freq/sum(pop.t$Freq))
ggplot(dat.p, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = pop, colour = 'Real data'), fill = 'steelblue2') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Population of world's countries") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 
                              'Real data' = 'steelblue2')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), 
        legend.background = element_blank())

areadata <- readHTMLTable('http://statisticstimes.com/geography/countries-by-area.php/', 
                         which = 2, stringsAsFactors = FALSE)
# load("Data/_areadata.Rdata")
areadata <- areadata[c(2,3)]
names(areadata) <- c('country', 'area')
areadata$area[252] <- '44'
area <- as.integer(substring(areadata$area, 1, 1))
area.t <- as.data.frame(table(area))
dat.a <- cbind(dat, area = area.t$Freq/sum(area.t$Freq))
ggplot(dat.a, aes(x = dig, y = benf)) + scale_x_continuous(breaks = dig) + 
  geom_col(aes(x = dig, y = area, colour = 'Real data'), fill = 'turquoise3') +
  geom_line(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_point(aes(x = dig, y = benf, colour = 'Benford')) + 
  geom_line(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  geom_point(aes(x = dig, y = even, colour = 'Homogeneous')) + 
  ggtitle("Area of world's countries") + xlab('Digit') + ylab('Frequency') +
  scale_color_manual(values=c('Benford' = 'red', 'Homogeneous' = 'darkgreen', 
                              'Real data' = 'turquoise3')) + 
  theme(legend.position = c(1,1), legend.justification = c(1,1), 
        legend.background = element_blank())

# rm(list = ls())
