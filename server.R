# Developing Data Products: Course Project
# D3 and Shiny App for Data Visualization
# @author : Prabhat Kumar
# @date   : 22-July-2015
# 40% of the final grade.
# ========================================


# This is the server logic for a Shiny Web Application.
# Some, reactive output displayed as a result of server calculations.
library(shiny)

shinyServer(function(input, output) {
  # Use reactive expressions.
  data <- reactive({
    
    if (input$dataSource == FALSE){
      path <- input$url
      # translate relative paths to server-friendly paths.
      if (substr(input$url, 0, 2) == "./"){
        path <- paste("./www/", substring(input$url, 3), sep="")
      }
    } else {
      df <- input$file
      path <- df$datapath
    }
    
    # to get the csv file data.
    data <- read.csv(path, row.names=1)
    
    data.df <- cbind(rownames(data), data)
    colnames(data.df)[1] <- "Date"
    data.df
  })
  
  # when data changes, update the bar plot.
  output$perfbarplot <- reactive({
    data()
  })
})
