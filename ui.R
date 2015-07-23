# Developing Data Products: Course Project
# D3 and Shiny App for Data Visualization
# @author : Prabhat Kumar
# @date   : 22-July-2015
# 40% of the final grade
# ========================================


# This is the user-interface definition of a Shiny Web Application.

library(shiny)

reactiveBar <- function (outputId) {
  HTML(paste("<div id=\"", outputId, "\" class=\"shiny-network-output\"><svg /></div>", sep=""))
}

shinyUI(pageWithSidebar(
  # Application title
  headerPanel(HTML("D3 and Shiny App for Data Visualization.")),
  # Sidebar for data input.
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
