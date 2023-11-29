#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggplot2)

house <- read_csv("train.csv")
house2 <-  house %>% filter(Neighborhood == "NAmes" | Neighborhood == "BrkSide" | Neighborhood == "Edwards")
NAmes <- house2 %>% filter(Neighborhood == "NAmes")
Edwards <- house2 %>% filter(Neighborhood == "Edwards")
BrkSide <- house2 %>% filter(Neighborhood == "BrkSide")

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      
      # App title ----
      titlePanel("Scatterplot of Sale price by neighborhood"),
      
      # Copy the line below to make a set of radio buttons
      radioButtons("radio", label = h3("Neighborhood Selection"),
                   choices = list("NAmes" = 1, "Edwards" = 2, "BrkSide" = 3), 
                   selected = 1),
      
      hr(),
      fluidRow(column(3, verbatimTextOutput("value")))
      
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "distPlot")
    )
    
  )
)

# Define server logic required to draw a histogram

server <- function(input, output) {
  
  
  output$distPlot <- renderPlot({
    
    
    
    if(input$radio == 1)
    {
      
      plot(NAmes$GrLivArea, NAmes$SalePrice, col = 3, xlab = "Square Footage", ylab = "Salel Price", main = " NAmes Neighborhood square footage vs sale price", pch =20)
      
    }
    
    if(input$radio == 2)
    {
      
      plot(Edwards$GrLivArea, Edwards$SalePrice, col = 2,
           xlab = "Square Footage", ylab = "Sale Price", main = " Edwards Neighborhood square footage vs sale price", pch =20)
    }
    
    if(input$radio == 3)
    {
      
      plot(BrkSide$GrLivArea, BrkSide$SalePrice, col = 5,
           xlab = "Square Footage", ylab = "Sale Price", main = " BrkSide Neighborhood square footage vs sale price", pch =20)
    }
    
    
  }
  )
  
}

shinyApp(ui, server)