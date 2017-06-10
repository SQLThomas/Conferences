# 03.tidy.R
# Demo script: the tidying part of the Tidyverse
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load packages -----------------------------------------------------------
library(tidyr)

# Gather and spread -------------------------------------------------------
f1.top9
f1long <- gather(f1.top9, Race, Points, R01:R21)
f1long

weo
weolong <- gather(weo, Year, Value, num_range('', 2000:2022))
weolong
weo <- spread(weolong, key = `Subject Descriptor`, value = Value)
weo

# Separate and unite ------------------------------------------------------
f1.top9
f1.sep <- f1.top9 %>% 
  separate(Team, into = c('Driver', 'Name'))
f1.sep

f1.new <- f1.sep %>% 
  unite(Standing, Pos, Name)
f1.new

rm(weolong, f1.sep, f1.new)
