# DemoBasics1.R
# Demo script: data types and data structures in R
# ©2016 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

## Calculator mode :-)
17 + 4
sqrt(256)
32^4

## Data types
# numeric / integer / complex
n <- 4
4 -> n
n = 4
n

# character
c <- 'DataWeekender is a really cool event'
c

# Logical
l <- FALSE
l

# date-time
now <- date()
now

# factor
f <- factor(c('Jan', 'Feb', 'Mar', 'Apr', 'Feb', 'Jan'))
f

## Data structures
# vector
a_vector <- c(1, 2, 3, 4, 5, 6, 7, 8)
a_vector <- c(1:8)
a_vector

# matrix
a_matrix <- matrix(1:6, nrow=3, ncol=2)
a_matrix

# list
a_list <- list(8, "Nexus", TRUE, 1 + 2i)
a_list

# data frame
df <- data.frame(name = c("rob","jens","annette","thomas"), score = c(67,56,87,81))
df

# structure info
str(df)
