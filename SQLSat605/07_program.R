# 07_program.R
# Demo script: programming the Tidyverse way
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!
# Parts of this demo: © 2017 Wickham/Grolemund: „R for Data Science“

# Load packages -----------------------------------------------------------
library(magrittr)
library(purrr)
library(rvest)

# Introducing the pipe ----------------------------------------------------
f1.doc <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
f1.tab <- html_node(f1.doc, "table")
f1 <- html_table(f1.tab)
rm(f1.doc, f1.tab)

f1 <- html_table(html_node(read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung'), "table"))

f1 <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung') %>% 
  html_node("table") %>% 
  html_table()


# Functional programming --------------------------------------------------
df <- tibble(a = rnorm(10), b = rnorm(10), c = rnorm(10), d = rnorm(10))

median(df$a); median(df$b); median(df$c); median(df$d)

output <- vector("double", ncol(df))
for (i in seq_along(df)) {
  output[[i]] <- median(df[[i]])    
}
output

col_median <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- median(df[[i]])
  }
  output
}
col_median(df)

col_summary <- function(df, fun) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- fun(df[[i]])
  }
  output
}
col_summary(df, median)
col_summary(df, mean)
col_summary(df, sd)

map_dbl(df, median)
map_dbl(df, mean)
map_dbl(df, sd)
