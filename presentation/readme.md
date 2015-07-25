# Documentation

## About
> D3 and Shiny App for Data Visualization.

On [shinyapps.io](https://prabhatkumar.shinyapps.io/Course-Project)

This Shiny Web Application, is about temperature variation record analysis from last 10 years.
I have taken the data for every 31<sup>st</sup> January from 2006 to 2015 for my City. There is some variation recorded and i have used it to plot a histogram by using Shiny and D3 framework.

It's just to know, how is the temperature varies every year on same date. To do this, i have separated my code in some parts:

  1. data in simple ```".csv"``` format,
  2. ```server.R``` for some reactive output display as a result of server calculations,
  3. ```ui.R``` for the user-interface definitions,
  4. ```d3-shiny-app.html``` as a partial markup page, where i have written all the D3 logic to do data visualization.
  
## Working Principle

**[A]** This is the **server logic** for a Shiny Web Application:

  1. First, data is taken by ```server.R``` in ```"data.csv"``` format,
  2. Then, reactive expressions is used to get the data and translate relative paths to server-friendly paths,
  3. When, in-case of data changes, again it updates the d3 plot.
  
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

**[B]** This is the **User-Interface Definition** for a Shiny Web Application:
  
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
  
**[C]** This is the **Data Visualization Definition** for a Shiny Web Application:
  
  1. ```Shiny.OutputBinding()``` is a custom output component, that is used for a need of output binding, it's an object created that tells Shiny how to identify instances of the component and how to interact with them.
  2. The default implementation in ```Shiny.OutputBinding``` reads the data-output-id attribute and falls back to the element's id if not present.
  3. Now, I have added ```D3.js``` from CDN and called ```renderValue(el, data)```,
  4. After that, I have set canvas dimension and written logic to remove the old graph, append a new one, worked with dates, develop functions to group the bars, labels, tooltip on mouseover-mouseout events, and finally added the text label, respectively.
  5. In Last, i have register "Output Binding" - created an output binding object, that needs to tell Shiny to use it.
  ```Shiny.outputBindings.register(networkOutputBinding, 'prabhatkumar.networkbinding');```
  
  ```{r}
  var networkOutputBinding = new Shiny.OutputBinding();
  ```
  ```{r}
  $.extend(networkOutputBinding, {
    find: function(scope) {
        return $(scope).find('.shiny-network-output');
    },
    renderValue: function(el, data) {
        // to set canvas dimension.
        var margin = {
                top: 80,
                right: 20,
                bottom: 80,
                left: 20
            },
            width = 800 - margin.right - margin.left,
            height = 800 - margin.top - margin.bottom;

        // remove the old graph.
        var svg = d3.select(el).select("svg");
        svg.remove();

        $(el).html("");

        // append a new one.
        svg = d3.select(el).append("svg")
            .attr("width", width + margin.right + margin.left)
            .attr("height", height + margin.top + margin.bottom);

        var perfdata = new Array();

        var parse = d3.time.format("%m/%d/%Y").parse,
            format = d3.time.format("%Y")

        for (var inc = 0; inc < data.Date.length; inc++) {
            perfdata[inc] = {
                date: parse(data.Date[inc]),
                perf: parseFloat(data.Morning[inc]),
                symbol: "Min°C"
            };
            perfdata[inc + data.Date.length] = {
                date: parse(data.Date[inc]),
                perf: parseFloat(data.Evening[inc]),
                symbol: "Max°C"
            };
        }

        // Nest stock values by symbol.
        symbols = d3.nest()
            .key(function(d) {
                return d.symbol;
            })
            .entries(perfdata);

        var x = d3.time.scale()
            .range([0, width - 60]);

        var y = d3.scale.linear()
            .range([height - 20, 0]);

        var duration = 1500,
            delay = 500;

        var color = d3.scale.category10();

        // do the minimum and maximum dates
        x.domain([
            parse(data.Date[0]),
            parse(data.Date[data.Date.length - 1])
        ]);

        var g = svg.selectAll("g")
            .data(symbols)
            .enter().append("g")
            .attr("class", "symbol");

        groupedBar();

        function groupedBar() {
            x = d3.scale.ordinal()
                .domain(symbols[0].values.map(function(d) {
                    return d.date;
                }))
                .rangeBands([0, width - 60], .1);

            var x1 = d3.scale.ordinal()
                .domain(symbols.map(function(d) {
                    return d.key;
                }))
                .rangeBands([0, x.rangeBand()]);

            var y0 = Math.max(Math.abs(d3.min(symbols.map(function(d) {
                return d3.min(d.values.map(function(d) {
                    return d.perf;
                }));
            }))), d3.max(symbols.map(function(d) {
                return d3.max(d.values.map(function(d) {
                    return d.perf;
                }));
            })));

            y.domain([-y0, y0])
                .range([height, 0])
                .nice();

            var yAxis = d3.svg.axis().scale(y).orient("left");
            // for labels.
            svg.selectAll(".labels")
                .data(symbols[0].values.map(function(d) {
                    return d.date;
                }))
                .enter().append("text")
                .attr("class", "labels")
                .attr("text-anchor", "middle")
                .attr("x", function(d, i) {
                    return x(i) + x.rangeBand() / 2;
                })
                .attr("y", height / 2 + 15)
                .text(function(d) {
                    return format(d);
                })
                .style("font-size", "12px")
                .style("fill-opacity", 0.8);

            var g = svg.selectAll(".symbol");

            var t = g.transition().duration(duration);

            g.each(function(p, j) {
                d3.select(this).selectAll("rect")
                    .data(function(d) {
                        return d.values;
                    })
                    .enter().append("rect")
                    .attr("x", function(d) {
                        return x(d.date) + x1(p.key);
                    })
                    .attr("y", function(d, i) {
                        return y(Math.max(0, d.perf));
                    })

                .attr("width", x1.rangeBand())
                    .attr("height", function(d, i) {
                        return Math.abs(y(d.perf) - y(0));
                    })

                .style("fill", color(p.key))
                    .style("fill-opacity", 1e-6)

                // for tooltip.
                .on('mouseover', function(d, i) {
                        d3.select(this)
                            .style('fill', 'gray')
                            .style("z-index", 9);
                        statusText
                            .text(p.key + " " + d.perf)
                            .attr('fill', color(p.key))
                            .attr("text-anchor", d.perf < 0 ? "begin" : "begin")
                            .attr("x", x(d.date) + x1(p.key) + x.rangeBand() / 2)
                            .attr("y", y(d.perf))
                            .attr("transform", d.perf < 0 ? "rotate(9 " + (x(d.date) + x1(p.key) + x.rangeBand() / 4) + "," + y(d.perf) + ")" : "rotate(-9 " + (x(d.date) + x1(p.key) + x.rangeBand() / 4) + "," + y(d.perf) + ")");
                    })
                    .on('mouseout', function(d, i) {
                        statusText
                            .text('');
                        d3.select(this).style('fill', color(p.key));
                    })
                    .transition()
                    .duration(duration)
                    .style("fill-opacity", 1);

                var statusText = svg.append('svg:text');

            });

            // Add the text label for the X axis
            svg.append("text")
                .attr("transform", "translate(" + (width / 2) + " ," + ((height / 2.2) + margin.bottom) + ")")
                .style("text-anchor", "middle")
                .text("Year");

            // Add the text label for the Y axis
            svg.append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 4)
                .attr("x", margin.top - (height / 2.4))
                .attr("dy", ".60em")
                .style("text-anchor", "end")
                .text("Temp in °C");

            // Add the title
            svg.append("text")
                .attr("x", (width / 2))
                .attr("y", 20)
                .attr("text-anchor", "middle")
                .style("font-size", "14px")
                .style("text-decoration", "none")
                .text("Temperature Vs. Year");
        };
      }
  });
  ```
  ```{r}
  # Register Output Binding.
  Shiny.outputBindings.register(networkOutputBinding, 'prabhatkumar.networkbinding');
  ```
  
  **Note**: ```d3.js``` given methods to work with drawing part of this App.

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
