# 06_communicate/app.R
# Demo script: communication from the Tidyverse
# ©2020 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

library(shiny)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Code block is executed once ---------------------------------------------
weo <- read_tsv('http://www.imf.org/external/pubs/ft/weo/2019/02/weodata/WEOOct2019alla.xls', na = c('n/a', '--'))
# weo <- read_tsv('data/WEOOct2019alla.xls', na = c('n/a', '--'))
weo <- head(weo, -1)
weo <- select(weo, 2:4, num_range('', 2000:2022))
weo$`Country Group Name` <- as.factor(weo$`Country Group Name`)
# weo$`Subject Descriptor` <- as.factor(weo$`Subject Descriptor`)
weo <- filter(weo, `WEO Subject Code` %in% c('NID_NGDP', 'LUR', 'TM_RPCH', 'TX_RPCH', 'PCPIPCH', 'NGDP_RPCH'))
weo <- weo[, -1]
measures <- as.list(unique(weo$`Subject Descriptor`))
weo <- gather(weo, Year, Value, num_range('', 2000:2022))

# Define UI for our application -------------------------------------------
ui <- fluidPage(
   
   # Application title
   titlePanel('World Economic Outlook'),
   
   # Sidebar with radio buttons, dynamically created from measures
   sidebarLayout(
      sidebarPanel(
         radioButtons(inputId = 'rb', label = 'Measure to show', 
                      choiceNames = measures, choiceValues = measures),
         width = 3
      ),
      
      # Show the resulting plot
      mainPanel(
         plotOutput('facetPlot', height = '750px'), width = 9
      )
   )
)

# Define server logic to plot our diagrams --------------------------------
server <- function(input, output) {
  
   output$facetPlot <- renderPlot({
     ggplot(filter(weo, `Subject Descriptor` == input$rb), aes(x=Year, y=Value, 
                group=`Country Group Name`, colour=`Country Group Name`)) + 
       geom_line(show.legend = FALSE) + facet_wrap(~ `Country Group Name`, ncol = 3) +
       scale_x_discrete(breaks=c('2000', '2005', '2010', '2015', '2020')) +
       theme(strip.text = element_text(size = rel(1.1)))
   })
}


# Single line necessary to run the application  ---------------------------
shinyApp(ui = ui, server = server)
