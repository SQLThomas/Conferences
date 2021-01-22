# 01_import.R
# Demo script: the import part of the Tidyverse
# ©2020 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load packages -----------------------------------------------------------
library(readr)
library(rvest)

# Load csv files with base R, then with readr functions -------------------
titanic.base <- read.csv('data/titanic.csv')
titanic.tidy <- read_csv('data/titanic.csv')
str(titanic.base)
str(titanic.tidy)
titanic.base
titanic.tidy
titanic.web <- read_csv('https://raw.githubusercontent.com/SQLThomas/demodata/master/train.csv')

system.time(sales.base <- read.csv('data/sales.csv'))
system.time(sales.tidy <- read_csv('data/sales.csv'))

# Load data from internet sites -------------------------------------------
browseURL('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
# browseURL('~/Downloads/Formel1.html')
f1.doc <- read_html('http://www.formel1.de/saison/wm-stand/2016/fahrer-wertung')
# f1.doc <- read_html('~/Downloads/Formel1.html')
f1.tab <- html_node(f1.doc, "table")
f1 <- html_table(f1.tab)
f1

browseURL('http://www.imf.org/en/publications/weo')
browseURL('http://www.imf.org/external/pubs/ft/weo/2019/02/weodata/groups.htm')
weo <- read_tsv('http://www.imf.org/external/pubs/ft/weo/2019/02/weodata/WEOOct2019all.xls', na = c('n/a', '--'))
weo.all <- head(weo, -1)
weo <- read_tsv('http://www.imf.org/external/pubs/ft/weo/2019/02/weodata/WEOOct2019alla.xls', na = c('n/a', '--'))
weo.gr <- head(weo, -1)
weo.gr

rm(weo, f1.doc, f1.tab, titanic.base, titanic.tidy, titanic.web, sales.base, sales.tidy)

