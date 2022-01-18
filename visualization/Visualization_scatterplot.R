library(shiny)
library(ggplot2)
library(stringr)

data <- read.csv("../data/data_clean.csv", header = TRUE, sep = ",")
category <- c("Region", "Town", "Flat Type", "Flat Model")

df <- data.frame(year = "All")
df <- df %>% add_row(year = as.character(sort(unique(data$year))))

data$resale_price <- data$resale_price / 1000

ui<- pageWithSidebar(
  headerPanel("HDB Resale Price in Singapore"),
  sidebarPanel(
    selectInput("Category", "Select Category:", choices = sort(category), selected = head(category,1)),
    selectInput("Year", "Select Year:", choices = df$year, selected = head(df$year,1)),
    submitButton('Submit')
  ),
  mainPanel(
    plotOutput("plot")
  )
)

server<- function(input, output) {
  observe({
    
    title <- paste("HDB Resale Price in Singapore By Floor Area (sqm) By", input$Category)

    selectedCategory <- input$Category
    selectedCategory <- tolower(selectedCategory)
    selectedCategory <- str_replace(selectedCategory, " ",  "_")
    
    selectedYear <- input$Year
    
    dataplot <- data
    if (selectedYear != "All")
    {
      dataplot <- dataplot %>% 
        filter(year == selectedYear)
      
      title <- paste(title, "in", selectedYear)
    }
    
    output$plot <- renderPlot({
      ggplot(dataplot) +
        aes_string(x = "resale_price", y = "floor_area_sqm", colour = selectedCategory) +
        labs(title = title, x = "Resale Price (S$ in thousands)", y = "Floor Area (sqm)", color = input$Category) +
        geom_point() +
        scale_color_hue() + 
        theme(
          plot.title = element_text(size=14, face="bold")
        )
    })
  })
}

shinyApp(ui = ui, server = server)