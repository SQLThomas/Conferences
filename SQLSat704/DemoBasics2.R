# DemoBasics2.R
# Demo script: packages in R
# ©2016 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Show packages currently installed and those loaded into memory
installed.packages()
search()

# Show available datasets
data()

# install an additional package
install.packages("plyr")
require(plyr)
library(plyr)
library(help=plyr)
