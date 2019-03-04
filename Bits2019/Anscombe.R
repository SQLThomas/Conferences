# Anscombe.R
# Demo using Anscombe's quartet
# ©2016 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load Anscombe data sets
ans <- read.csv2('data/Anscombe.csv', colClasses = c('factor', 'numeric', 'numeric'), dec='.')
ans

# statistics for all 4 data sets are the same
anstest <- ans[ans$set == 'A', ]
anstest
mean(anstest$x)
mean(anstest$y)
with(anstest, cor(x, y))
with(anstest, lm(y ~ x))

# Plot the 4 data sets
library(ggplot2)
ggplot(ans, aes(x=x, y=y, group=set)) + geom_point() + facet_wrap(~set)

# Plot adding regression line following linear model
ggplot(ans, aes(x=x, y=y, group=set)) + geom_point() + stat_smooth(method=lm, fullrange=TRUE, se=FALSE) + facet_wrap(~set)

