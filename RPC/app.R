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
library(ggplot2)
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
            ),
            p(textOutput("nbtrajs",inline = TRUE), " trajets réalisés."),
            plotOutput("hist")
        ),

        # flowmap
        mainPanel(
          flowmapblueOutput("flowMap",height = "800px",width = "auto")
        )
    )
)

# Define server logic 
server <- function(input, output) {
    flows =reactive({rpc$flows |> filter(hour %in% input$hours,day %in% input$days)})
    output$flowMap <- renderFlowmapblue({
      flowmapblue(rpc$locations, flows(), mapboxAccessToken, clustering=TRUE, darkMode=FALSE, animation=FALSE)
    })
    output$hist <- renderPlot({
      ggplot(flows())+geom_histogram(aes(x=hour),bins = 24)+theme_bw()+labs(x="heure",y="# trajets",title="Repartition horaire",subtitle="des trajets de covoiturages")
    })
    output$nbtrajs <- renderText(sum(flows()$count))
    
}

# Run the application 
shinyApp(ui = ui, server = server)
