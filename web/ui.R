# Read Me ------------------------------------------------------------------
# naming convention:
# id for sidebarMenu is "i_sidetabs"
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"


# Library -----------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyjs)
library(plotly)
library(leaflet)


# Initiation --------------------------------------------------------------
# one time code here


# Header ------------------------------------------------------------------
header <- dashboardHeader( 
    titleWidth = 300,
    
    title = "Singapore Flat Resale Price"
) #close DBheader bracket


# Sidebar -------------------------------------------------------------------
sidebar <- dashboardSidebar(
    width = 200,
    sidebarMenu( id="i_sidetabs",
        menuItem("Visualization", tabName = "tab_vis", 
                 icon = icon("tasks", lib="glyphicon")
        ),
        
        menuItem("Prediction", tabName = "tab_pred",
                 icon = icon("signal", lib="glyphicon")
        ),
        
        menuItem("Documentation", tabName="tab_doc",
                 icon = icon("list-alt", lib="glyphicon")
        ),
        
        menuItem("Todo", tabName="tab_todo"
        )
        
    ) #close sidebarMenu bracket
)# close DBsidebar bracket


# Body --------------------------------------------------------------------

body <- dashboardBody(
    
    ############################# preparation
    useShinyjs(),
    shinyDashboardThemes(theme="poor_mans_flatly"),
    
    tabItems(
        ######################### Visualisation tab        
        tabItem(
            "tab_vis",
            
            ########### Intro
            "Welcome! If your name is Amy or is planning to", 
            "buy a flat in Singapore, then you are at the correct place.",
            "In this section, you will see some interesting figures and trends ",
            "on the resale flat prices in Singapore.",
            br(),
            
            ########### Plottings
            tabBox(
                height = 450, width = 12,
                selected = "Region",
                
                tabPanel("Floor Area", 
                    fluidRow(
                        column(3,
                            selectInput("i_vis_area_y", label = "Year",
                                        choices = list("2018"= 2018,
                                                       "2019"= 2019,
                                                       "2020"= 2020)    
                            ),
                            "No plotting here yet."
                        ), #close control column
                        column(9,
                               #plotlyOutput("o_vis_area")
                        ) #close plot column
                    )# close fluidR bracket
                ), #close floor area bracket
                
                tabPanel("Region",
                    fluidRow(
                        column(3,
                            selectInput("i_vis_region_y", label = "Year",
                                choices = list("2018"= 2018,
                                               "2019"= 2019,
                                               "2020"= 2020)    
                            ),
                            br(),
                            "This is gg plot"
                        ), #close control column
                        column(9,
                            plotOutput("o_vis_region")
                        ) #close plot column
                    )# close fluidR bracket     
                ), #close region bracket
                
                tabPanel("New Flat Model",
                    fluidRow(
                        column(3,
                            selectInput("i_vis_nfm_y", label = "Year",
                                choices = list("2018"= 2018,
                                               "2019"= 2019,
                                               "2020"= 2020)    
                                ),
                            br(),
                            "This is plotly plot"
                        ), #close control column
                        column(9,
                            plotlyOutput("o_vis_nfm")
                        ) #close plot column
                    )# close fluidR bracket          
                ), # close nfm bracket
                
            ), #close plotting tabbox bracket
            br(),
            
            ########### direct to predict
            actionButton("i_vis_direct", label = "Click here"),
            "to find out the estimated price for your dream home!"
        ), #close vis tabItem bracket
        
        ######################### Prediction tab        
        tabItem(
            "tab_pred",
            
            ################ Intro
            "Let's do some prediction!", br(),
            "Simply select the flat feature and we will do the remaining job.",
            br(),
            
            ################ feature box
            box(title = "Flat Features", width = 12,
                collapsible = FALSE,
                
                ############### 1st row for town, flat model and type
                fluidRow(
                    column(4, selectInput(
                        "i_pred_town", label = "Town",
                        choices = list("A"="a","B"="b"),
                        selected = "a"
                    ) #close town input bracket
                    ), # close town input column bracket
                    
                    
                    column(4,selectInput(
                        "i_pred_FType", label = "Flat Type",
                        choices = list("1 Room"="1r","2 Room"="2r"),
                        selected = "1r"
                    )#close flat type input bracket
                    ), #close flat type column bracket
                    
                    column(4,selectInput(
                        "i_pred_FModel", label = "Flat Model",
                        choices = list("Model A"="Ma","Model B"="Mb"),
                        selected = "Mb"
                    )#close flat model input bracket
                    )#close flat model column bracket
                    
                ), #close 2nd row bracket
                
                ############### 2nd row for area   
                
                fluidRow(
                    column(4, sliderInput(
                        "i_pred_area", 
                                label = HTML(paste0("Floor Area (m", tags$sup("2"), ")")),
                                width = "300px",
                                min = 100, max = 200, 
                                value = 150
                    ) #close flat type input bracket 
                    ), #close flat type column bracket
                    
                ),# close 2nd row bracket
                
                ############### last row for button
                fluidRow(
                    column(12, align="right",
                        actionButton("i_pred_resetbut",
                            label = "Reset",
                            width = "100px", color = "blue"
                        ), #close reset button input bracket
                        
                        actionButton("i_pred_predbut",
                            label = "Predict!",
                            width = "100px"
                        ) #close predict button input bracket
                        
                       
                    ) #close predict button column bracket
                    
                ),# close 2nd row bracket
                
                
            ),#close flat feature box bracket
            
            
            #################### results box
            box(title="Results", width = 12,
                collapsible = FALSE,
                textOutput("o_pred_res")
            ) #close results box bracket
            
        ), #close pred tabItem bracket
        
        ######################### Documentation tab
        tabItem(
            "tab_doc",
            box(title = "Dataset", width = 12,
                collapsible = FALSE,
                "The prediction model is trained using the", 
                tags$a(href="https://data.gov.sg/dataset/resale-flat-prices",
                       "open dataset", target = "_blank"), 
                "provided by Singapore Housing and Development Board."
                
            ),# close dataset box bracket
            
            box(title = "Data Attributes", width = 12,
                collapsible = FALSE,
                "Hello."
            ),# close data attr box bracket
            
            box(title = "Acknowledgement", width = 12,
                collapsible = FALSE,
                "Thank you all"
            ),# close ack box bracket
            
            box(title = "About Us", width = 12,
                collapsible = FALSE,
                "We are 5 smart PG students", br(),
                "Github repo here?"
            )# close ack box bracket
            
        ), #close doc tabItem bracket
        
        ######################### Todo tab
        tabItem(
            "tab_todo", fluidRow(
                
                box(title="Icon choices", width = 5,
                    collapsible = TRUE,
                    img(src = "icons.png", height = '250px', width = '400px',
                        alt = "icon choices")
                    
                ), #close icon box bracket
                
                box(title="Theme and colors", width = 5,
                    collapsible = TRUE,
                    "including change bg color for button like 'reset' ",
                    "in prediction tab"
                    
                )#close theme box bracket
                
            )# close fluidrow bracket
        )#close todo tabItem bracket

        
        
                
    ) #close tabItems bracket
) #close DBbody bracket







# Shiny UI ----------------------------------------------------------------


shinyUI(
    dashboardPage(header, sidebar, body)
)
