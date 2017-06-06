# 04_visualize.R
# Demo script: visualize your data using the Tidyverse
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load packages -----------------------------------------------------------
library(ggplot2)

# Formula 1 race results --------------------------------------------------
ggplot(f1long)

ggplot(f1long, aes(x=Race, y=Points))

ggplot(f1long, aes(x=Race, y=Points)) + geom_point()

ggplot(f1long, aes(x=Race, y=Points)) + geom_line()

ggplot(f1long, aes(x=Race, y=Points, group=Team, colour=Team, shape = Team)) + 
  geom_line() + geom_point() + scale_shape_manual(values=1:9)

ggplot(f1long, aes(x=Race, y=Points, group=Team, colour=Team)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~ Team) +
  scale_x_discrete(breaks=c('R01', 'R06', 'R11', 'R16', 'R21'))

ggplot(f1long, aes(x=reorder(Team, Pos), y=Points, colour=Team)) + 
  geom_boxplot(show.legend = FALSE) + xlab('Team')

summary(f1long$Points[f1long$Team == 'Nico Rosberg'])
summary(f1long$Points[f1long$Team == 'Lewis Hamilton'])

ggplot(f1long, aes(x=reorder(Team, Pos), y=Points, colour=Team)) + 
  geom_violin(show.legend = FALSE) + xlab('Team')

# WEO data ----------------------------------------------------------------
ggplot(weo, aes(x=Year, y=Investment, group=`Country Group Name`,
                colour=`Country Group Name`)) + geom_line()

ggplot(weo, aes(x=Year, y=Investment, group=`Country Group Name`, 
                colour=`Country Group Name`, shape = `Country Group Name`)) + 
  geom_line() + geom_point() + scale_shape_manual(values=1:15)

ggplot(weo, aes(x=Year, y=Investment, group=`Country Group Name`, colour=`Country Group Name`)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~ `Country Group Name`) +
  scale_x_discrete(breaks=c('2000', '2005', '2010', '2015', '2020'))
