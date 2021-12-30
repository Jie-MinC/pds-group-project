# Read Me ------------------------------------------------------------------
# naming convention:
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"


# Library -----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)
library(jsonlite)

# Inititation -------------------------------------------------------------
# load cleaned dataset from github
ghurl<- 'https://media.githubusercontent.com/media/yongkokkhuen/pds-group-project/main/data/data_clean.csv'
#cleancsv<- data.frame(read_csv(ghurl))
cleancsv<- data.frame(read_csv("www/data_clean.csv"))

# open street map api
osmapi<- c("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=",
           "&lon=")

# Shiny Server ------------------------------------------------------------
shinyServer(function(input, output, session) {
    
    ################ shiny js
    
    ################ output in tab_vis
    
    output$o_vis_area<-renderPlotly({
        areaplot<- cleancsv %>% 
            filter(year %in% input$i_vis_area_y) %>%
            ggplot(aes(x=floor_area_sqm, y=resale_price, color = region)) +
            geom_point() +
            scale_color_brewer(type = "qual", palette = 5)
        
        #ggplotly(areaplot)
    })
    
    output$o_vis_region<-renderPlot({
        cleancsv %>% filter(year %in% input$i_vis_region_y) %>%
            ggplot(aes(x=region,y=resale_price, fill = region)) + theme_bw() +
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
            geom_violin() + geom_boxplot(width = 0.1) + theme(legend.position="none")+
            scale_color_brewer(type = "qual", palette = 5)
        
        #ggplotly(regplot)
    })
    
    output$o_vis_nfm<-renderPlotly({
        nfmplot<- cleancsv %>% filter(year %in% input$i_vis_nfm_y) %>%
            #group_by(new_flat_model)
            ggplot(aes(x=resale_price, fill = new_flat_model)) + theme_bw() +
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
            geom_density(alpha=0.5)  
        
        ggplotly(nfmplot)
    })
    
    
    observeEvent(input$i_vis_direct, {
        updateTabItems(session,'i_sidetabs',"tab_pred")
    })
    
    
    ################ output in tab_pred
    observeEvent(input$i_pred_predbut, {
        output$o_pred_res<- renderText({
            "No model predict what"
        }) #close render result bracket
    }) #close observe predbit bracket
    
    observeEvent(input$i_pred_resetbut, {
        output$o_pred_res<- renderText({""
        }) #close render result bracket
    }) #close observe resetbut bracket
    
    ################ output in tab_doc

    ################ output in tab_todo
    output$o_todo_map<- renderLeaflet({
        leaflet(options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)) %>% 
            addProviderTiles(providers$OneMapSG.Original, 
                             options = providerTileOptions(
                                 minZoom = 10.5, maxZoom = 15)) %>%
            setView(lat = 1.318, lng=103.84, zoom=10.5)
    }) #close render Leaflet
    
    output$o_todo_map_zlvl<- renderText({
        paste("Zoom Level: ", input$o_todo_map_zoom, sep="")
    }) #print zoom level
    
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