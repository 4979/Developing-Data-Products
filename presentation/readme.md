# Documentation

## About
> D3 and Shiny App for Data Visualization.

This Shiny Web Application, is about temperature variation record analysis from last 10 years.
I have taken the data for every 31<sup>st</sup> January from 2006 to 2015 for my City. There is some variation recorded and i have used it to plot a histogram by using Shiny and D3 framework.

It's just to know, how is the temperature varies every year on same date. To do this, i have separated my code in some parts:

  1. data in simple ```".csv"``` format,
  2. ```server.R``` for some reactive output display as a result of server calculations,
  3. ```ui.R``` for the user-interface definitions,
  4. ```d3-shiny-app.html``` as a partial markup page, where i have written all the D3 logic to do data visualization.
  
## Working Principle

[A] This is the **server logic** for a Shiny Web Application:

  1. First, data is taken by ```server.R``` in ```"data.csv"``` format,
  2. Then, reactive expressions is used to get the data and translate relative paths to server-friendly paths,
  3. When, in-case of data changes, again it update the bar plot.
  
  ```{r}
  library(shiny)
  ```
  ```{r}
  shinyServer(function(input, output) {
  data <- reactive({
    
    if (input$dataSource == FALSE){
      path <- input$url
      if (substr(input$url, 0, 2) == "./"){
        path <- paste("./www/", substring(input$url, 3), sep="")
      }
    } else {
      df <- input$file
      path <- df$datapath
    }
    
    data <- read.csv(path, row.names=1)
    data.df <- cbind(rownames(data), data)
    colnames(data.df)[1] <- "Date"
    data.df
  })
    output$perfbarplot <- reactive({
      data()
    })
  })
  ```

[B] This is the **User-Interface Definition** for a Shiny Web Application:
  
  1. First, ```shinyUI``` method give header of the working app,
  2. sidebar panel to get data source from server as well as from local,
  3. If you choose from local, upload can be done in ```.csv``` format,
  4. simultaneously, main panel can take the HTML partial page through ```includeHTML``` method,
     where all logic written by using D3.js to draw csv format based data visualization.
  5. It have also feature to redraw the canvas, when you are uploading data from local.
  
  ```{r}
  library(shiny)
  ```
  ```{r}
  reactiveBar <- function (outputId) {
    HTML(paste("<div id=\"", outputId, "\" class=\"shiny-network-output\"><svg /></div>", sep=""))
  }

  shinyUI(pageWithSidebar(
  
  headerPanel(HTML("D3 and Shiny App for Data Visualization.")),
  
  sidebarPanel(
    checkboxInput(inputId= "dataSource", label="Use a file stored on my local machine.", value=FALSE),
    conditionalPanel(
      condition = "input.dataSource == false",
      textInput(inputId="url", label="Data File URL:", value="./data.csv"),
      helpText(HTML("<div style=\"text-indent:2px\">Download the sample dataset <a href=\"data.csv\">here!</a></div>"))
    ),
    conditionalPanel(
      condition = "input.dataSource == true",            
      fileInput(inputId = "file", label="Data in 'CSV' to plot:"),
      helpText(HTML("<div style=\"color: red; font-weight: bold\">Warning:</div> Local file uploads in 
                    Shiny are <strong>very</strong> experimental.<br/>
                    I have made this just to do some experiment.
                    <p>If you have any trouble using this feature,<br/>
                    Please ignore it."))
    ),
    HTML("<hr />"),
    helpText(
      HTML("All source available on <a href = \"https://github.com/4979/Developing-Data-Products\">GitHub</a>.<br/>by Prabhat Kumar.<br/>Date: 22-July-2015.")
    ),
    HTML("<hr />")
  ),
  # Show a plot through D3.js
  # Reactive output displayed as a result of server calculations.
    mainPanel(
      includeHTML("d3-shiny-app.html"),
      reactiveBar(outputId = "perfbarplot")
    )
  ))
  ```

## Technology

1. R
2. Shiny
3. D3
4. SVG
5. CSS
6. Markdown

## Editor
   
1. RStudio
2. Sublime Text

## Data Set
```
Date,Morning,Evening
01/31/2006,02.1,6.8
01/31/2007,-01.89,4.44
01/31/2008,04.10,9.50
01/31/2009,05.68,8.10
01/31/2010,04.34,6.88
01/31/2011,-01.10,05.61
01/31/2012,01.89,5.44
01/31/2013,04.10,10.22
01/31/2014,08.68,4.10
01/31/2015,02.88,09.34
```
- Data Source: from The Hindu News Paper.
- Note: Since I didn't use the API to collect data, the current data might not be 100% accurate.
- Date updated: 24-July-2015

**Copyright**: © 2015 Prabhat Kumar, All Rights reserved.

