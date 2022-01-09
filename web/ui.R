# Read Me ------------------------------------------------------------------
# naming convention:
# id for sidebarMenu is "i_sidetabs"
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"
# change appdone<- TRUE in Initiation section to remove construction box


# Library -----------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyjs)
library(shinyBS)
library(plotly)
library(leaflet)

# Initiation --------------------------------------------------------------
# moved to global.R
constructionbox<-box(
    width=12, height=150, background = "red",
    h2("This app is still under construction."),
    h2("Contents shown are mostly placeholder which may not be real.")
)


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
                 icon = icon("file", lib="glyphicon")
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
    #shinyDashboardThemes(theme="grey_dark"),
    
    tabItems(
        ######################### Visualisation tab        
        tabItem(
            "tab_vis",
            if (appdone==FALSE) {constructionbox},
            
            ########### Intro
            "Welcome! If your name is Amy or is planning to", 
            "buy a flat in Singapore, then you are at the correct place.",
            "In this section, you will see some interesting figures and trends ",
            "on the resale flat prices in Singapore.",
            br(),
            
            ########### Plottings
            tabBox(
                height = 450, width = 12,
                selected = "Trend",
                
                tabPanel("Trend", 
                    #style= "background-color: #808080;",
                    fluidRow(
                        column(3, 
                            selectInput("i_vis_trend_reg", label = "Region",
                                choices = as.list(c("All",sort(inputC$region)))     
                            ),
                            selectInput("i_vis_trend_town", label = "Town",
                                choices = as.list(c("All",sort(inputC$town)))     
                            ),
                            selectInput("i_vis_trend_FType", label = "Flat Type",
                                choices = as.list(c("All",sort(inputC$flat_type)))    
                            ),
                            selectInput("i_vis_trend_FModel", label = "Flat Model",
                                #choices = as.list(c("All",sort(inputC$new_flat_model)))
                                choices = as.list(c("All",sort(inputC$flat_model)))
                            ),
                               
                            actionButton("i_vis_trend_subbut",
                                width = "100%",
                                label = "Plot!"
                            )
                        ), #close control column
                        
                        
                        column(9,
                               plotOutput("o_vis_trend_plot")
                        ) #close plot column
                    )# close fluidR bracket
                ), #close trend bracket
                
                tabPanel("Price Heat Map",
                    fluidRow(
                        column(3,
                            selectInput("i_vis_hm_xvar", label = "X-attribute",
                                #choices = inputC$attChoices,
                                choices = inputC$attChoices[c("Region","Town")],
                                selected = "region"
                            ),
                            selectInput("i_vis_hm_yvar", label = "Y-attribute",
                                #choices = inputC$attChoices,
                                choices = inputC$attChoices[c("Flat Type","Flat Model")],
                                selected = "flat_type"
                            ),
                            selectInput("i_vis_hm_year", label = "Year",
                                choices = as.list(c("All", sort(inputC$year))),
                                selected = "All"
                            ),
                            
                            actionButton("i_vis_hm_subbut",
                                         width = "100%",
                                         label = "Plot!"
                            )
                        ), #close control column
                        column(9,
                            plotOutput("o_vis_hm")
                        ) #close plot column
                    )# close fluidR bracket     
                ), #close hm bracket
                
                tabPanel("Floor Area Scatter Plot",
                    fluidRow(
                        column(3,
                            selectInput("i_vis_splot_z", label = "Color Attribute",
                                choices = inputC$attChoices,
                                selected = "region"
                            ),
                            selectInput("i_vis_splot_year", label = "Year",
                                choices = as.list(c("All", sort(inputC$year))),
                                selected = "All"
                            ),
                            actionButton("i_vis_splot_subbut",
                                         width = "100%",
                                         label = "Plot!"
                            )
                        ), #close control column
                        column(9,
                            plotOutput("o_vis_splot")
                        ) #close plot column
                    )# close fluidR bracket          
                )# close scatter plot bracket
                
            ), #close plotting tabbox bracket
            br(),
            
            ########### direct to predict
            actionButton("i_vis_direct", label = "Click here",
                         style= "background-color: #FFFFFF; color: #0645AD"),
            "to find out the estimated price for your dream home!"
        ), #close vis tabItem bracket
        
        ######################### Prediction tab        
        tabItem(
            "tab_pred",
            if (appdone==FALSE) {constructionbox},
            
            ################ Intro
            "Let's do some prediction!", br(),
            "Simply select the flat feature and we will do the remaining job.",
            br(),
            
            ################ feature box
            box(title = "Flat Details", width = 12, height= 550,
                solidHeader = TRUE, collapsible = FALSE,
                status = "warning",
                
                ############### 1st row for town
                fluidRow(
                    
                
                    column(5,
                        selectInput(
                            width = "100%",
                            "i_pred_town", label = "Town",
                            choices = as.list(sort(inputC$town))
                            #selected = "Bedok"
                        ), #close town input bracket

                    ),
                    
                    column(2,
                           actionButton("i_pred_mapbut",
                                width = "100%",
                                label = "Use Map"
                           ) #close map button input bracket
                    )#close map col
                    
                ), #close town row bracket
                
                ############### 2nd row for flat features  
                
                fluidRow(
                    column(12, h3("Flat Features:")),
                    
                    column(4, 
                           selectInput(
                               width = "100%",
                               "i_pred_flatM", label = "Flat Model",
                               #choices = as.list(sort(inputC$new_flat_model))
                               choices = as.list(sort(inputC$flat_model))
                           ), #close flatM input bracket
                           
                           selectInput(
                               width = "100%",
                               "i_pred_flatT", label = "Flat Type",
                               choices = as.list(sort(inputC$flat_type))
                               #selected = "1 Room"
                           ) #close flatT input bracket
                    ), #close 1st column bracket
                    
                    column(4, 
                           numericInput(
                               width = "100%",
                               "i_pred_maxF", 
                               label = "Max Floor Level",
                               min = inputC$max_floor_lvl[1],
                               max = inputC$max_floor_lvl[2], 
                               value = floor(mean(inputC$max_floor_lvl))
                           ), #close maxF bracket
                           
                           sliderInput(
                                width = "100%",
                                "i_pred_floorA", 
                                label = HTML(paste0("Floor Area (m", tags$sup("2"), ")")),
                                min = inputC$floor_area_sqm[1],
                                max = inputC$floor_area_sqm[2], 
                                value = floor(mean(inputC$floor_area_sqm))
                            ) #close floor area bracket 
                    ), #close 2nd column bracket
                    
                    column (4,
                        selectInput(
                            width = "100%",
                            "i_pred_SRange", label = "Storey Range",
                            choices = as.list(sort(inputC$storey_range))
                            #selected = "01 to 03"
                        ), #close SRange input bracket
                        sliderInput(
                            width = "100%",
                            "i_pred_RLease", label = "Remaining Lease (year)",
                            min = inputC$remaining_lease[1],
                            max = inputC$remaining_lease[2],
                            value = floor(mean(inputC$remaining_lease))
                        ) #close RLease bracket 
                    ) # close 3rd col
                    
                ),# close flat feature row bracket
                
                
                fluidRow(
                    
                    column(12, h3("Others:")),
                    
                    column(2,
                        checkboxInput("i_pred_com", label = "Commercial", value = TRUE),
                    ),
                    
                    column(2,
                        checkboxInput("i_pred_mh", label = "Market Hawker", value = TRUE),
                    ),
                    
                    column(2,
                        checkboxInput("i_pred_misc", label = "Miscellaneous", value = TRUE),
                    ),
                    
                    column(3,
                        checkboxInput("i_pred_carp", label = "Multi Storey Car Park", value = TRUE),
                    ),
                    
                    column(2,
                        checkboxInput("i_pred_ppav", label = "Precinct Pavillion", value = TRUE),
                    )
                ),
                
                ############### last row for button
                fluidRow(
                    column(12, align="right",
                        actionButton("i_pred_resetbut",
                            style= "background-color: #808080;",
                            label = "Reset",
                            width = "100px", color = "blue"
                        ), #close reset button input bracket
                        
                        actionButton("i_pred_predbut",
                            label = "Predict!",
                            width = "100px"
                        ) #close predict button input bracket
                        
                       
                    ) #close predict button column bracket
                    
                )# close flat feature row bracket
            ),#close flat detail box bracket
            br(),
            
            #################### results box
            box(title="Results", width = 12, height = 300,
                solidHeader = TRUE, collapsible = FALSE,
                status = "success",
                #dataTableOutput("o_pred_res_table"),
                verbatimTextOutput("o_pred_res_para"),
                h3('Predicted Current Price:'),
                verbatimTextOutput("o_pred_res_price")
            ), #close results box bracket
            #to fix background color
            br(),
            "need text to fix background?"
            
        ), #close pred tabItem bracket
        
        ######################### Documentation tab
        tabItem(
            "tab_doc",
            if (appdone==FALSE) {constructionbox},
            
            box(title = "Dataset", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "info",
                "The prediction model is trained using the", 
                tags$a(href="https://data.gov.sg/dataset/resale-flat-prices",
                       "open dataset", target = "_blank"), 
                "provided by Singapore Housing and Development Board."
                
            ),# close dataset box bracket
            
            box(title = "Data Attributes", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "info",
                "Hello."
            ),# close data attr box bracket
            
            box(title = "Acknowledgement", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "info",
                "Thank you all"
            ),# close ack box bracket
            
            box(title = "About Us", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "info",
                "We are 5 smart PG students", br(),
                "Github repo here?"
            )# close ack box bracket
            
        ), #close doc tabItem bracket
        
        ######################### Todo tab
        tabItem(
            "tab_todo", 
            if (appdone==FALSE) {constructionbox},
            
            fluidRow(
                
                column(6,
                    box(title="Icon choices", width=12,
                        collapsible = TRUE,
                        img(src = "icons.png", height = '250px', width = '400px',
                                 alt = "icon choices"), br(),
                        tags$a(href="https://getbootstrap.com/docs/3.4/components/#glyphicons",
                               "Link to full icon list")
                             
                    )#close icon box bracket
                
                ),
                
                column(6,
                    box(title = "Others", width=12,
                        
                        "General",
                        tags$ul(
                            tags$li("remove redundant data in inputC"),
                            tags$li("remove redundant data in global.R"),
                            tags$li("Colorrrrrrrrrr"),
                            tags$li("Englishhhhhhhh")
                        ),
                        
                        "Visualisation tab:",
                        tags$ul(
                            tags$li("Visualisation deco"),
                            tags$li("keep region in vis?")
                        ),
                        
                        "Prediction tab:",
                        tags$ul(
                            tags$li("reset button update inputs"),
                            tags$li("modal problem?"),
                            tags$li("remove est. reg. in map"),
                            tags$li("num var in pred, allowed range?"),
                            tags$li("explain pred feature?"),
                            tags$li("max floor level range?"),
                            tags$li("rem lease in year or month?"),
                            tags$li("rem lease in res para")
                        )
                        
                    )
                )
                
            
            )# close fluidrow bracket
            
        )#close todo tabItem bracket

        
        
                
    ) #close tabItems bracket
) #close DBbody bracket







# Shiny UI ----------------------------------------------------------------


shinyUI(
    dashboardPage(header, sidebar, body)
)
