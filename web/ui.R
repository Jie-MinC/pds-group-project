# Read Me ------------------------------------------------------------------
# naming convention:
# id for sidebarMenu is "i_sidetabs"
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"
# change appdone<- TRUE in global.R to remove construction box


# Library -----------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(shinyBS)
library(leaflet)

# Initiation --------------------------------------------------------------
# most moved to global.R
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
    shinyDashboardThemes(theme="poor_mans_flatly"),
    
    tabItems(
        ######################### Visualisation tab        
        tabItem(
            "tab_vis",
            if (appdone==FALSE) {constructionbox},
            
            ########### title
            h1("Visualization for Singapore HDB Resale Flat Price", 
               style = "margin-left: 20px;"),
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
                            selectInput("i_vis_hm_xyvar", label = "Axis Attributes",
                                choices = inputC$hmChoices,
                                selected = "region & flat_type"
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
                
                tabPanel("Price Scatter Plot",
                    fluidRow(
                        column(3,
                            selectInput("i_vis_splot_z", label = "Color Attribute",
                                choices = inputC$spChoices,
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
            
            tags$p(".", style = "color: #FFFFFF;")

        ), #close vis tabItem bracket
        
        ######################### Prediction tab        
        tabItem(
            "tab_pred",
            if (appdone==FALSE) {constructionbox},
            
            ################ title
            h1("Prediction of Singapore HDB Resale Flat Price",
               style = "margin-left: 20px;"),
            br(),
            
            ################ feature box
            box(title = tags$p("Flat Details", 
                               style="font-size: 22px; margin-bottom: 0px;"),
                width = 12, height= 590,
                solidHeader = TRUE, collapsible = FALSE,
                status = "warning",
                
                ############### 1st row for town
                fluidRow(
                    column(12, tags$h4(tags$u("Location:"))),
                
                    column(4,
                        selectInput(
                            width = "100%",
                            "i_pred_town", label = "Town",
                            choices = as.list(sort(inputC$town))
                        ), #close town input bracket
                    ),
                    
                    column(2,
                           style = "margin-top: 25px;",
                           actionButton("i_pred_mapbut",
                                width = "100%",
                                label = "Use Map"
                           ) #close map button input bracket
                    )#close map col
                    
                ), #close town row bracket
                
                ############### 2nd row for flat features  
                
                fluidRow(
                    column(12, tags$h4(tags$u("Flat Features:"))),
                    
                    column(4, 
                           selectInput(
                               width = "100%",
                               "i_pred_flatM", label = "Flat Model",
                               choices = as.list(sort(inputC$flat_model))
                           ), #close flatM input bracket
                           
                           br(),
                           selectInput(
                               width = "100%",
                               "i_pred_flatT", label = "Flat Type",
                               choices = as.list(sort(inputC$flat_type))
                           ) #close flatT input bracket
                    ), #close 1st column bracket
                    
                    column(4, 
                           sliderInput(
                               width = "100%",
                               "i_pred_maxF", 
                               label = "Highest Floor Level",
                               min = inputC$max_floor_lvl[1],
                               max = inputC$max_floor_lvl[2], 
                               value = inputC$max_floor_lvl[2]
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
                            "i_pred_SRange", label = "Preferred Range for Storey Level",
                            choices = as.list(sort(inputC$storey_range))
                        ), #close SRange input bracket
                        br(),
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
                    
                    column(12, tags$h4(tags$u("Others:"))),
                    
                    column(2,
                        checkboxInput("i_pred_com", label = "Commercial", value = FALSE)
                    ),
                    
                    column(2,
                        checkboxInput("i_pred_mh", label = "Market Hawker", value = FALSE)
                    ),
                    column(8,
                        column(4,
                            checkboxInput("i_pred_carp", label = "Multi Storey Car Park", value = FALSE)
                        ),

                        column(4,
                            checkboxInput("i_pred_ppav", label = "Precinct Pavillion", value = FALSE)    
                        ),
                        
                        column(4,
                            checkboxInput("i_pred_misc", label = "Miscellaneous *", value = FALSE)
                        )
                    ),
                ),
                fluidRow(column(12, 
                    "* here")
                ),
                br(),
                
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
                    ) #close button column bracket
                    
                )# close button row bracket
            ),#close flat detail box bracket
            br(),
            
            #################### results box
            box(title=tags$p("Results", 
                             style="font-size: 22px; margin-bottom: 0px;"),
                width = 12, height = 380,
                solidHeader = TRUE, collapsible = FALSE,
                status = "warning",
                
                tags$h4(textOutput("o_pred_param_title")),
                tags$u(textOutput("o_pred_param_loc")),
                textOutput("o_pred_param_town"),
                br(),
                tags$u(textOutput("o_pred_param_ff0")),
                textOutput("o_pred_param_ff1"),
                textOutput("o_pred_param_ff2"),
                br(),
                tags$u(textOutput("o_pred_param_oth0")),
                textOutput("o_pred_param_oth1"),
                br(),
                tags$h4(textOutput("o_pred_res_price0")),
                tags$h3(textOutput("o_pred_res_price1"),
                        style="margin-top: 0px; margin-bottom: 0px;")
            ), #close results box bracket
            
            tags$p(".", style = "color: #FFFFFF;")
            
        ), #close pred tabItem bracket
        
        ######################### Documentation tab
        tabItem(
            "tab_doc",
            if (appdone==FALSE) {constructionbox},
            
            box(title = "Dataset", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "The prediction model is trained using the", 
                tags$a(href="https://data.gov.sg/dataset/resale-flat-prices",
                       "open dataset", target = "_blank"), 
                "provided by Singapore Housing and Development Board."
                
            ),# close dataset box bracket
            
            box(title = "Data Attributes", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "Hello."
            ),# close data attr box bracket
            
            box(title = "Declaration", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "This project is conducted to fulfill the academic requirement",
                "of the course Principal of Data Science (WQD7001). The data is",
                "used under the license https://data.gov.sg/open-data-licence",
                "(last accessed on (date))."
            ), #close declaration box
            
            box(title = "Acknowledgement", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "We would like to express our gratitude to our lecturer, ",
                "Dr Rohana binti Mahmud for allowing us to engage in this ",
                "project. We would also like to show our appreciation for ",
                "each and every member of the group as we manage to ",
                "push through the difficulties and to complete this project. ",
                "Lastly, we hope that the project will contribute to the users ",
                "through the visualization and prediction of ",
                "the current market price of the HDB flat in Singapore."
            ),# close ack box bracket
            
            box(title = "About Us", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "Master of Data Science", br(),
                "Amy Lang S2127213", br(),
                "Ching Peng Liaw S2038321", br(),
                "Li Tian Yeoh S2120306", br(),
                "Wei Wen Wong S2121928", br(),
                "Yong Kok Khuen 17147279", br(),
                "Github repo here?"
            ),# close ack box bracket
            
            tags$p(".", style = "color: #FFFFFF;")
        ), #close doc tabItem bracket
        
        ######################### Todo tab
        tabItem(
            "tab_todo", 
            if (appdone==FALSE) {constructionbox},
            
            fluidRow(
                
                column(6,
                    box(title = "Others", width=12,
                        
                        "General",
                        tags$ul(
                            tags$li("remove redundant data in inputC"),
                            tags$li("Colorrrrrrrrrr"),
                            tags$li("Englishhhhhhhh")
                        ),
                        
                        "Visualisation tab:",
                        tags$ul(
                            tags$li("nothing?")
                        ),
                        
                        "Prediction tab:",
                        tags$ul(
                            tags$li("binary input spacing"),
                            tags$li("yes/no or Yes/No?"),
                            tags$li("display param space formatting"),
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
