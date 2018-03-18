# DemoBasics3.R
# Demo script: basic data in-/output, analysis and visualization in R
# ©2016 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# Read comma/semicolon separated file, local or from the web
titanic <- read.csv('data/titanic.csv')
titanic.web <- read.csv('https://raw.githubusercontent.com/SQLThomas/demodata/master/train.csv')
identical(titanic, titanic.web)

# Structure, age statistics and summary of titanic dataset
str(titanic)
min(titanic$Age, na.rm=TRUE)
max(titanic$Age, na.rm=TRUE)
mean(titanic$Age, na.rm=TRUE)
median(titanic$Age, na.rm=TRUE)
summary(titanic)

# First and last rows of titanic data
head(titanic)
tail(titanic)

# histogram showing distribution of age
hist(titanic$Age)
# histogram, a little prettified
hist(titanic$Age, main = "Age distribution", xlab = "Age", col = "blue", breaks = 40, xlim = c(0,80))

# boxplot age over class
boxplot(titanic$Age ~ titanic$Pclass, main = 'Age distribution per class', xlab = "Class", ylab = "Age", col = c("blue"))

# survivors per class per sex
with(titanic, mosaicplot(~Pclass + Sex + Survived, main='Survivors of the Titanic', color=TRUE, off=2))
