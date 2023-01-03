#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(flowmapblue)
library(dplyr)
mapboxAccessToken <- 'pk.eyJ1IjoiY29tZWV0aWUiLCJhIjoiY2xiNmE3dTJrMGI0ZTNub2E3c3RhNWdsbCJ9.eaHsSZnu_0vZD40IUq0DNA'
rpc=readRDS("../rpc.RDS")

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$head(
    # Note the wrapping of the string in HTML()
    tags$style(HTML("
      h2 {
        color: white;
      }"
    ))),
    # Application title
    titlePanel("Registre de preuve de covoiturage 2022"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
            selectInput("hours",
                        "Heures :",
                        0:23,
                        0:23,
                        multiple = TRUE),
            selectInput(
              "days",
              "Types de jour :",
              c("lun.","mar.","mer.","jeu.","ven.","sam.","dim."),
              selected =  c("lun.","mar.","mer.","jeu.","ven.","sam.","dim."),
              multiple = TRUE
            )
        ),

        # flowmap
        mainPanel(
          flowmapblueOutput("flowMap",height = "800px",width="1000px")
        )
    )
)

# Define server logic 
server <- function(input, output) {

    output$flowMap <- renderFlowmapblue({
      flows =rpc$flows |> filter(hour %in% input$hours,day %in% input$days) 
      flowmapblue(rpc$locations, flows, mapboxAccessToken, clustering=TRUE, darkMode=FALSE, animation=FALSE)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
