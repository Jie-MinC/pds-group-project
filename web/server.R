# Read Me ------------------------------------------------------------------
# naming convention:
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"


# Library -----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(plotly)
library(jsonlite)
library(leaflet)

# Inititation -------------------------------------------------------------
#moved to global.R

# Shiny Server ------------------------------------------------------------
shinyServer(function(input, output, session) {
    
    ################ shiny js
    
    ################ output in tab_vis
    
    output$o_vis_area<-renderPlotly({
        areaplot
    })
    
    output$o_vis_region<-renderPlot({
        regplot
    })
    
    output$o_vis_nfm<-renderPlot({
       nfmplot
    })
    
    
    observeEvent(input$i_vis_direct, {
        updateTabItems(session,'i_sidetabs',"tab_pred")
    })
    
    
    ################ output in tab_pred
    observeEvent(input$i_pred_mapbut, {
        
        showModal(modalDialog(
            title = "Map",
            leafletOutput("o_pred_map"), 
            br(),
            "Estimated Region: ", textOutput("o_pred_map_reg", inline = TRUE),
            br(),
            "Estimated Town: ", textOutput("o_pred_map_town", inline = TRUE),
            size="m",
            footer = modalButton("Confirm")
            )
        )
        
    })
    
    output$o_pred_map<- renderLeaflet({
        SgMap
    }) #close render Leaflet
    
    observeEvent(input$o_pred_map_click, {
        regtext<- "North"
        towntext<- "BEDOK"
        
        output$o_pred_map_reg<- renderText({regtext})
        updateSelectInput(session, "i_pred_region", selected = regtext)
        
        output$o_pred_map_town<- renderText({towntext})
        updateSelectInput(session, "i_pred_town", selected = towntext)
        
    })
    
    
    observeEvent(input$i_pred_predbut, {
        output$o_pred_res<- renderText({
            outputtext<- isolate (
                { paste(input$i_pred_region,
                  input$i_pred_town,
                  input$i_pred_streetN,
                  input$i_pred_block,
                  input$i_pred_flatM,
                  input$i_pred_NoS,
                  input$i_pred_RLease,
                  input$i_pred_flatT,
                  input$i_pred_floorA, sep="; ")}
            )
            outputtext
        }) #close render result bracket
    }) #close observe predbut bracket
    
    observeEvent(input$i_pred_resetbut, {
        updateSelectInput(session, "i_pred_region",selected="Central")
        output$o_pred_res<- renderText({""
        }) #close render result bracket
    }) #close observe resetbut bracket
    
    ################ output in tab_doc

    ################ output in tab_todo
    
    observeEvent(input$o_todo_map_click, {
        fLat<-toString(input$o_todo_map_click[1])
        fLng<-toString(input$o_todo_map_click[2])
        
        output$o_todo_map_clickloc<- renderText({
            
            paste( "Latitude: ", fLat, '\n',
                   "Longitude: ", fLng, sep="")
        }) #print lat lng
        
        output$o_todo_map_add<- renderText({
            
            osmurl<- paste(osmapi[1],fLat,osmapi[2],fLng, sep="")
            suppressWarnings(
                osmjson<- fromJSON(readLines(osmurl))
            )
            osmjson$display_name
        }) # print address
    }
    )
    
    
}) #close shinyServer bracket