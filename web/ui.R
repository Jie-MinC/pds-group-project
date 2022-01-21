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
    #titleWidth = 250,
    
    title = "Flatly"
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
                height = 430, width = 12,
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
                ),# close scatter plot bracket
                
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
                width = 12, height= 610,
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
                    "* Other amenities such as ",
                    "admin office, childcare centre, education centre, ",
                    "Residents’ Committees centre, etc.",
                    br(),
                    "Note: refer to the documentation tab for more information",
                    "on each attributes.")
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
            
            box(title = "Data Attributes", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                tags$ol(
                    
                    tags$li("Region",
                        tags$ul(
                            tags$li("Refer to",
                                tags$a(href = "https://en.wikipedia.org/wiki/List_of_places_in_Singapore",
                                       "https://en.wikipedia.org/wiki/List_of_places_in_Singapore",
                                       target = "_blank"
                                ),
                                "for more information."
                            )
                        )
                    ),
                    br(),
                    
                    tags$li("Town",
                        tags$ul(
                            tags$li("Refer to",
                                tags$a(href = "https://en.wikipedia.org/wiki/List_of_places_in_Singapore",
                                        "https://en.wikipedia.org/wiki/List_of_places_in_Singapore",
                                       target = "_blank"
                                ),
                                "for more information."
                            )
                        )
                    ),
                    br(),
                    
                    tags$li("Flat Model",
                        tags$ul(
                            tags$li("Refer to",
                                tags$a(href = "https://sg.finance.yahoo.com/news/different-types-hdb-houses-call-020000642.html",
                                        "https://sg.finance.yahoo.com/news/different-types-hdb-houses-call-020000642.html",
                                       target = "_blank"
                                ),
                                "and",
                                tags$a(href = "https://www.teoalida.com/singapore/hdbfloorplans/",
                                       "https://www.teoalida.com/singapore/hdbfloorplans/",
                                       target = "_blank"
                                ),
                                "for more information."
                            )
                        )
                    ),
                    br(),
                    
                    tags$li("Flat Type",
                        tags$ul(
                            tags$li("Refer to",
                                tags$a(href = "https://www.hdb.gov.sg/residential/buying-a-flat/resale/getting-started/types-of-flats",
                                       "https://www.hdb.gov.sg/residential/buying-a-flat/resale/getting-started/types-of-flats",
                                       target = "_blank"
                                ),
                                "for more information."
                            )
                        )
                    ),
                    br(),
                    
                    tags$li("Highest Floor Level",
                        tags$ul(
                            tags$li("Highest floor level of the resale flat.")
                        )
                    ),
                    br(),
                    
                    tags$li("Preferred Range for Storey Level",
                        tags$ul(
                            tags$li("Preferred range for storey level of the resale flat.")
                        )
                    ),
                    br(),
                    
                    tags$li(
                        HTML(paste("Floor Area (m", tags$sup("2"), ")", sep = "")),
                        tags$ul(
                            tags$li("Floor area of the resale flat.")
                        )
                    ),
                    br(),
                    
                    tags$li("Remaining Lease (Year)",
                        tags$ul(
                            tags$li("Remaining lease of the resale flat."),
                            tags$li("Most of the HDB flats come with a 99-year lease.")
                        )
                    ),
                    br(),
                    
                    tags$li("Commercial",
                        tags$ul(
                            tags$li("Close to commercial property.")
                        )
                    ),
                    br(),
                    
                    tags$li("Market Hawker",
                        tags$ul(
                            tags$li("Close to market and hawker.")
                        )
                    ),
                    br(),
                    
                    tags$li("Multi Storey Car Park",
                        tags$ul(
                            tags$li("Close to multi-storey carpark.")
                        )
                    ),
                    br(),
                    
                    tags$li("Precinct Pavilion",
                        tags$ul(
                            tags$li("Close to precinct pavillion.")
                        )
                    ),
                    br(),
                    
                    tags$li("Miscellaneous",
                        tags$ul(
                            tags$li("Close to other amenities such as ",
                            "admin office, childcare centre, education centre, ",
                            "Residents’ Committees centre, etc.")
                        )
                    )
                
                )
            ),# close data attr box bracket
            
            box(title = "Dataset", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "The prediction model is trained using the open dataset",
                "provided by Singapore Housing and Development Board:",
                br(),
                br(),
                
                tags$ol(
                    tags$li("Resale Flat Price", 
                            tags$ul(
                                tags$li("Source: ",
                                        tags$a(href = "https://data.gov.sg/dataset/resale-flat-prices",
                                               "https://data.gov.sg/dataset/resale-flat-prices",
                                               target = "_blank"
                                        )
                                ),
                                tags$li("Resale flat transacted prices based on",
                                        "registration date from 2015-2021 are selected",
                                        "in this project.")
                            )
                    ),
                    br(),
                    
                    tags$li("HDB Property Information",
                            tags$ul(
                                tags$li("Source: ",
                                        tags$a(href = "https://data.gov.sg/dataset/hdb-property-information",
                                               "https://data.gov.sg/dataset/hdb-property-information",
                                               target = "_blank"
                                        )
                                ),
                                tags$li("The dataset contains the location of",
                                        "existing HDB blocks, highest floor level, ",
                                        "year of completion, type of building and ",
                                        "number of HDB flats (breakdown by flat type) ",
                                        "per block etc.")
                            )
                    )
                    
                ),
                
                "The data were last accessed on 17 Dec 2021, and is ",
                "used under the license",
                tags$a(href = "https://data.gov.sg/open-data-licence",
                       "https://data.gov.sg/open-data-licence",
                       target = "_blank"
                ),
                "."
                
            ),# close dataset box bracket
            
            box(title = "Acknowledgement", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "This project is conducted to fulfill the academic requirement",
                "of the course Principal of Data Science (WQD7001). ",
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
                "We are a group of 5 students in the Master of Data Science ", 
                "program in the University of Malaya.",
                br(), br(),
                "Members:", br(),
                tags$ol(
                    tags$li("Amy Lang (S2127213)"),
                    tags$li("Liaw Ching Peng (S2038321)"),
                    tags$li("Wong Wei Wen (S2121928)"),
                    tags$li("Yeoh Li Tian (S2120306)"),
                    tags$li("Yong Kok Khuen (17147279)")
                ),
                "The GitHub repository for this project can be found here:",
                tags$a(
                    href = "https://github.com/yongkokkhuen/pds-group-project",
                    "https://github.com/yongkokkhuen/pds-group-project",
                    target = "_blank"
                )
            ),# close about us box bracket
            
            box(title = "Lesson and Experience Learnt", width = 12,
                collapsible = FALSE, solidHeader = TRUE,
                status = "warning",
                "Throughout the whole project, we have all learnt precious experience:", 
                br(), br(),
                tags$p(
                    "Amy Lang: I have experienced many different functionalities of R ",
                    "in this project that I have yet to discover before. Utilizing GitHub ",
                    "to a certain extent also brings in a new perspective on ",
                    "the version control and teamwork experience."
                ),
                
                tags$p(
                    "Liaw Ching Peng: This project helped us to understand the full cycle ",
                    "of data science project thoroughly and improve our R programming skill ",
                    "as well with all the hands-on experience. The toughest part was ",
                    "the creation of random forest model which I have spent a couple of days ",
                    "to train the model with different features and number of trees, ",
                    "it was extremely time consuming. Nevertheless, the experience ",
                    "in this project is valuable and strengthened my skill set to ",
                    "deal with future data science project."    
                ),
                
                tags$p(
                    "Wong Wei Wen: This project helped to enhance R programming understanding ",
                    "and hands on practice. For reasonable feature selection purposes, ",
                    "doing due diligence statistical analysis on the dataset features ",
                    "are helpful and I have also learned tremendously on ",
                    "the side of modelling technique in terms of regressions."
                ),
                tags$p(
                    "Yeoh Li Tian: I now apprepriate more on the concept of 'less is more'. ",
                    "A simple UI with less fancy design and color reduces unnecessary distraction",
                    "and helps the users to focus more on the content itself."
                ),
                tags$p(
                    "Yong Kok Khuen: In order to represent the properties in a more meaningful ",
                    "way, we merged another dataset that contains the property information so ",
                    "that we can use these features in our modeling to produce better results, ",
                    "and deliver a more intuitive user experience."
                )
                
                
            ), #close declaration box
            
            tags$p(".", style = "color: #FFFFFF;")
        ) #close doc tabItem bracket

                
    ) #close tabItems bracket
) #close DBbody bracket


# Shiny UI ----------------------------------------------------------------


shinyUI(
    dashboardPage(header, sidebar, body)
)
