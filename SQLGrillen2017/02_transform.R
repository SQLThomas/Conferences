# 02_transform.R
# Demo script: transforming with the Tidyverse
# ©2017 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Load packages -----------------------------------------------------------
library(dplyr)
library(tibble)

# Transform F1 data -------------------------------------------------------
f1
colnames(f1) <- c('Pos', 'Team', 'Total', sprintf("R%02d", 1:21))
f1 <- as_tibble(f1)
f1.top9 <- filter(f1, as.integer(Pos) <= 9)
f1.top9$Team <- as.factor(f1.top9$Team)
f1.top9[, -2] <- apply(f1.top9[, -2], 2, function(x) as.integer(gsub('-', '0', as.character(x))))

# Transform IMF data for country groups -----------------------------------
colnames(weo.gr)
weo <- select(weo.gr, 2:4, num_range('', 2000:2022))

unique(weo.gr$`Country Group Name`)
weo$`Country Group Name` <- as.factor(weo$`Country Group Name`)

unique(weo.gr$`Subject Descriptor`)
weo$`Subject Descriptor` <- as.factor(weo$`Subject Descriptor`)
# weo <- filter(weo, `Subject Descriptor` %in% c('Investment', 'Unemployment rate', 
#       'Volume of imports of goods and services', 'Gross domestic product, constant prices'))
weo <- filter(weo, `WEO Subject Code` %in% c('NID_NGDP', 'LUR', 'TM_RPCH', 'TX_RPCH', 
                                             'PCPIPCH', 'NGDP_RPCH'))
weo <- weo[, -1]
rm(weo.all)
