# DemoShiny/app.R
# Demo using sales data of German petrol stations
# ©2016 Thomas Hütter, this script is provided as-is for demo and educational use only,
# without warranty of any kind for any other purposes, so run at your own risk!

# !! Needs the data from DemoTankData.R to be in memory !!

# Using the shiny library, obviously
library(shiny)
library(raster)

# Define UI for application
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("Diesel sales in Germany"),
   
   # Sidebar with a selector for post code structure
   sidebarLayout(sidebarPanel(
      radioButtons('pz', 'Diagrams:', c('Line plot'='line', '1-digit post zones'='one', 
                                        '2-digit post zones'='two', '2-digit + surprise'='sup')),
      width = 2),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("mapPlot", height = "720px"), width = 10
      )
   )
))

# Define logic required to draw the plot
server <- shinyServer(function(input, output) {
   
   output$mapPlot <- renderPlot({
     switch(input$pz, 
            'line' = ggplot(sales.m1, aes(x=Mon, y=Sales/1000000, colour=PLZ1, group=PLZ1)) + geom_line() + 
              ggtitle('Diesel sales in Germany 2015') + ylab('Sales in M€'),
            'one' = plot(map1, col = map1$col),
            'two' = plot(map2, col = map2$col),
            'sup' = {plot(map2, col = map2$col); 
              plot(laender[laender$GEN == 'Thüringen', ], col = 'red', add = TRUE)}
            )
   })
})

# Run the application 
shinyApp(ui = ui, server = server)

