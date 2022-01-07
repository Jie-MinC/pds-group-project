library(shiny)
library(ggplot2)
library(stringr)
library(dplyr)

data <- read.csv("../data/data_clean.csv", header = TRUE, sep = ",")

df <- data.frame(x = "All")
dfRegion <- df %>% add_row(x = as.character(sort(unique(data$region))))
dfTown <- df %>% add_row(x = as.character(sort(unique(data$town))))
dfFlatType <- df %>% add_row(x = as.character(sort(unique(data$flat_type))))
dfFlatModel <- df %>% add_row(x = as.character(sort(unique(data$flat_model))))

data$resale_price <- data$resale_price / 1000

ui<- pageWithSidebar(
  headerPanel("HDB Resale Price in Singapore"),
  sidebarPanel(
    selectInput("Region", "Select Region:", choices = dfRegion$x, selected = head(dfRegion$x,1)),
    selectInput("Town", "Select Town:", choices = dfTown$x, selected = head(dfTown$x,1)),
    selectInput("FlatType", "Select Flat Type:", choices = dfFlatType$x, selected = head(dfFlatType$x,1)),
    selectInput("FlatModel", "Select Flat Model:", choices = dfFlatModel$x, selected = head(dfFlatModel$x,1)),
    submitButton('Submit')
  ),
  mainPanel(
    verbatimTextOutput("returnMsg"),
    plotOutput("plot")
  )
)

server<- function(input, output) {
  observe({

    
    title <- "HDB Resale Price in Singapore from 2015 to 2021"
    
    selectedRegion <- input$Region
    selectedTown <- input$Town
    selectedFlatType <- input$FlatType
    selectedFlatModel <- input$FlatModel

    dataplot <- data
    if (selectedRegion != "All")
    {
      dataplot <- dataplot %>%
        filter(region == selectedRegion)

      title <- paste(title, "\n", "Region:", selectedRegion)
    }
    if (selectedTown != "All")
    {
      dataplot <- dataplot %>%
        filter(region == selectedTown)
      
      title <- paste(title, "\n", "Town:", selectedTown)
    }
    if (selectedFlatType != "All")
    {
      dataplot <- dataplot %>%
        filter(flat_type == selectedFlatType)
      
      title <- paste(title, "\n", "Flat Type:", selectedFlatType)
    }
    if (selectedFlatModel != "All")
    {
      dataplot <- dataplot %>%
        filter(flat_model == selectedFlatModel)
      
      title <- paste(title, "\n", "Flat Model:", selectedFlatModel)
    }

    if (nrow(dataplot)  > 0)
    {
      dataplot <- dataplot %>%
        group_by(year) %>%
        summarise(total = mean(resale_price))
      
      output$plot <- renderPlot({
        ggplot(data=dataplot, aes_string(x="year", y="total", group=1)) +
          labs(title = title, x = "Year", y = "Resale Price (S$ in thousands)") +
          geom_line() +
          geom_point() +
          scale_x_continuous(labels = dataplot$year, breaks=dataplot$year) +
          theme(
            plot.title = element_text(size=14, face="bold")
          )
      })
      
      output$returnMsg <- renderPrint("")
    }
    else
    {
      output$returnMsg <- renderPrint("Not found.")
    }
  })
}

shinyApp(ui = ui, server = server)