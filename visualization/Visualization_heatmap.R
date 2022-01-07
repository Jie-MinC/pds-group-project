library(shiny)
library(ggplot2)
library(stringr)

data <- read.csv("../data/data_clean.csv", header = TRUE, sep = ",")
category_x <- c("Region", "Town")
category_y <- c("Flat Type", "Flat Model")

df <- data.frame(year = "All")
df <- df %>% add_row(year = as.character(sort(unique(data$year))))

data$resale_price <- data$resale_price / 1000

ui<- pageWithSidebar(
  headerPanel("HDB Resale Price in Singapore"),
  sidebarPanel(
    selectInput("category_x", "Select X-axis:", choices = sort(category_x), selected = head(category_x,1)),
    selectInput("category_y", "Select Y-axis:", choices = sort(category_y), selected = head(category_y,1)),
    selectInput("Year", "Select Year:", choices = df$year, selected = head(df$year,1)),
    submitButton('Submit')
  ),
  mainPanel(
    plotOutput("plot")
  )
)

server<- function(input, output) {
  observe({
    
    title <- paste("HDB Resale Price in Singapore By", input$category_x, "By", input$category_y)

    selectedCategory_x <- input$category_x
    selectedCategory_x <- tolower(selectedCategory_x)
    selectedCategory_x <- str_replace(selectedCategory_x, " ",  "_")
    
    selectedCategory_y <- input$category_y
    selectedCategory_y <- tolower(selectedCategory_y)
    selectedCategory_y <- str_replace(selectedCategory_y, " ",  "_")
    
    selectedYear <- input$Year
    
    dataplot <- data
    if (selectedYear != "All")
    {
      dataplot <- dataplot %>% 
        filter(year == selectedYear)
      
      title <- paste(title, "in", selectedYear)
    }

    output$plot <- renderPlot({
      ggplot(data = dataplot, aes_string(x=selectedCategory_x, y=selectedCategory_y, fill="resale_price")) + 
        geom_tile() + 
        labs(title = title, x = input$category_x, y = input$category_y) +
        guides(fill=guide_legend("Resale Price (S$ in thousands)")) +
        scale_fill_gradient(low="red",high="black") +
        theme(
          plot.title = element_text(size=14, face="bold"),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        )
    })
  })
}

shinyApp(ui = ui, server = server)