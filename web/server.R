# Read Me ------------------------------------------------------------------
# naming convention:
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"


# Library -----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(shinyBS)
library(plotly)
library(jsonlite)
library(leaflet)

# Inititation -------------------------------------------------------------
#moved to global.R
# mapModal<-

# Shiny Server ------------------------------------------------------------
shinyServer(function(input, output, session) {
    
    ################ shiny js
    
    ################ output in tab_vis
    
    observeEvent(input$i_vis_trend_reg, {
        newchoices<- as.list(c("All", inputC$RegTown[[input$i_vis_trend_reg]]))
        tosel<- ifelse(input$i_vis_trend_town %in% newchoices,
                       input$i_vis_trend_town,
                       "All")
        
        updateSelectInput(session, "i_vis_trend_town",
                          choices = newchoices,
                          selected = tosel
        )
    }
    )
    
    observeEvent(input$i_vis_trend_subbut, {
        if (input$i_vis_trend_reg =="All"){
            selreg<- unlist(inputC$region)
        } else {
            selreg<- input$i_vis_trend_reg
        }
        
        if (input$i_vis_trend_town =="All"){
            seltown<- unlist(inputC$town)
        } else {
            seltown<- input$i_vis_trend_town
        }

        if (input$i_vis_trend_FType =="All"){
            selFType<- unlist(inputC$flat_type)
        } else {
            selFType<- input$i_vis_trend_FType
        }
        
        if (input$i_vis_trend_FModel =="All"){
            selFModel<- unlist(inputC$flat_model)
            #selFModel<- unlist(inputC$new_flat_model)
        } else {
            selFModel<- input$i_vis_trend_FModel
        }
        
        trenddf<- cleancsv %>% 
            filter(region %in% selreg, town %in% seltown,
                flat_type %in% selFType, flat_model %in% selFModel) %>%
            mutate(dateym = as.Date(paste(year, month, "01", sep="-"), format= "%Y-%m-%d")) 
        
    
        trendplotSubT<- paste(
            "Region: ", input$i_vis_trend_reg, " ;   ",
            "Town: ", input$i_vis_trend_town, " ;   ",
            "Flat Type: ", input$i_vis_trend_FType, " ;   ",
            "Flat Model: ", input$i_vis_trend_FModel, " ; \n",
            "Number of Data Found: ", nrow(trenddf), ".",
            sep = "")
        
        
        output$o_vis_trend_plot<-renderPlot({
            
            trendsum<- trenddf %>% group_by(dateym) %>% 
                summarise(mean_resale_price= mean(RP_in_k)) 
            
            
            
            trendplot<- trendsum %>%
                ggplot(aes(x=dateym, y = mean_resale_price)) + theme_bw() +
                #theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
                geom_line() + geom_point() +
                ggtitle("HDB Resale Price in Singapore from 2015 to 2021",
                        subtitle = trendplotSubT) +
                theme(axis.text.x = element_text(angle=45, hjust=1)) +
                xlab("Date") + ylab("Average Resale Price (S$ in thousands)")
            
            if (nrow(trenddf) !=0){
                xbreaks<- trendsum$dateym[seq(1,length(trendsum$dateym),6)]
                trendplot<- trendplot+ scale_x_continuous(breaks=xbreaks)
            }
            
            trendplot
            
            
            
        })
    }) ####### close trend plotting
    
    
    
    observeEvent(input$i_vis_hm_subbut, { 
        if (input$i_vis_hm_year == "All"){
            selyear<- unlist(inputC$year)
        } else {
            selyear<- input$i_vis_hm_year
        }
        
        hmdf<- cleancsv %>% filter(year %in% selyear)
        
        hmplotsubT<- paste("Year: ", input$i_vis_hm_year, " ;   ",
                           "Number of Data Found: ", nrow(hmdf), ".",
                           sep = "")
        
        hmsum<- hmdf %>%
            group_by_at(vars(input$i_vis_hm_xvar,
                             input$i_vis_hm_yvar)) %>% 
            summarise(MRP_in_k = mean(RP_in_k), .groups = "drop")
        
        xaxlab<-names(inputC$attChoices)[which(inputC$attChoices==input$i_vis_hm_xvar)]
        yaxlab<-names(inputC$attChoices)[which(inputC$attChoices==input$i_vis_hm_yvar)]
        
        hmplot<- hmsum %>%
            ggplot(aes_string(x = input$i_vis_hm_xvar,y= input$i_vis_hm_yvar,
                              fill="MRP_in_k"))+
            geom_tile() + theme_bw() +
            theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
            ggtitle("HDB Resale Price in Singapore",
                    subtitle = hmplotsubT) +
            xlab(xaxlab) + ylab(yaxlab) + 
            guides(fill=guide_legend("Average Resale Price (S$ in thousands)")) +
            scale_fill_gradient(low="red",high="black") +
            theme(axis.text.x = element_text(angle = 90, hjust=0.95, vjust=0.2))
        
        output$o_vis_hm<-renderPlot({ 
            hmplot
        })
    }) ##### close heatmap plotting
    
    
    
    observeEvent(input$i_vis_splot_subbut, {
        
        if (input$i_vis_splot_year == "All"){
            selyear<- unlist(inputC$year)
        } else {
            selyear<- input$i_vis_splot_year
        }
        
        splotdf<- cleancsv %>% filter(year %in% selyear)
        
        SPplotsubT<- paste("Year: ", input$i_vis_splot_year, " ;   ",
                           "Number of Data Found: ", nrow(splotdf), ".",
                           sep = "")
        
        legtitle<-names(inputC$attChoices)[which(inputC$attChoices==input$i_vis_splot_z)]
            
        SPplot<- splotdf %>%
            ggplot(aes_string(x = "RP_in_k", y = "floor_area_sqm", 
                              color = input$i_vis_splot_z)) + 
            geom_point() + theme_bw() +
            scale_color_hue() +
            ggtitle("HDB Resale Price in Singapore by Floor Area (sqm)",
                    subtitle = SPplotsubT) +
            xlab("Resale Price (S$ in thousands)") +
            ylab("Floor Area (sqm)") +
            guides(color=guide_legend(title=legtitle))
            
            
        
        
        output$o_vis_splot<-renderPlot({
            SPplot
        })
    })
    
    observeEvent(input$i_vis_direct, {
        updateTabItems(session,'i_sidetabs',"tab_pred")
    })
    
    
    ################ output in tab_pred
    observeEvent(input$i_pred_mapbut, {
        showModal(modalDialog( 
            title = "Map", id="o_pred_map_modal", 
            leafletOutput("o_pred_map"), 
            br(),
            textOutput("o_pred_map_loc"),
            "Estimated Region: ", textOutput("o_pred_map_reg", inline = TRUE),
            br(),
            "Estimated Town: ", textOutput("o_pred_map_town", inline = TRUE),
            br(),
            textOutput("o_pred_map_add"),
            easyClose=TRUE, 
            footer = modalButton("Confirm")
        )
        )
    })
    
    output$o_pred_map<- renderLeaflet({
        SgMap
    }) #close render Leaflet
    
    observeEvent(input$o_pred_map_click, {
        
        fLat<-as.numeric(input$o_pred_map_click[1])
        fLng<-as.numeric(input$o_pred_map_click[2])
        
        distvec<- summarise(TownData,dist = geodist(fLat,fLng,Lat,Lng))
        
        towntext<- TownData$Town[which.min(unlist(distvec))]
        regtext<- "Unknown"
        for (reg in inputC$region){
            if (towntext %in% unlist(inputC$RegTown[reg])) {
                regtext<- reg
                break
            }
        }
        
        
        #actual address
        fLat<-toString(fLat)
        fLng<-toString(fLng)
        
        output$o_pred_map_add<- renderText({
                
            osmurl<- paste(osmapi[1],fLat,osmapi[2],fLng, sep="")
            suppressWarnings(
                osmjson<- fromJSON(readLines(osmurl))
            )
            osmjson$display_name
        })
        
        output$o_pred_map_loc<- renderText(paste(fLat,fLng, sep = " , "))
        
        output$o_pred_map_reg<- renderText({regtext})
        updateSelectInput(session, "i_pred_region", selected = regtext)
        
        output$o_pred_map_town<- renderText({towntext})
        updateSelectInput(session, "i_pred_town", selected = towntext)
        
    })
    
    
    observeEvent(input$i_pred_predbut, {
        output$o_pred_res_para<- renderText({
            outputtext<- isolate (
                { paste(
                    "Location", " \n",
                    "Region: ", input$i_pred_region, ",   ",
                    "Town: ", input$i_pred_town, ",   ",
                    "Street Name: ", input$i_pred_streetN, ",   ",
                    "Block: ", toString(input$i_pred_block), ". \n",
                    "Flat Feature", " \n",
                    "Flat Model: ", input$i_pred_flatM, ",   ",
                    "Storey Level: ", input$i_pred_NoS, ",   ",
                    "Remaining Lease (year): ", input$i_pred_RLease, ",   ",
                    "Flat Type: ", input$i_pred_flatT, ",   ",
                    "Floor Area: ", input$i_pred_floorA,  ". \n",
                    sep = "")}
            )
            outputtext
        }) #close render result para bracket
        
        output$o_pred_res_price<- renderText({
            "66666666666666666"
        })
        
    }) #close observe predbut bracket
    
    observeEvent(input$i_pred_resetbut, {
        updateSelectInput(session, "i_pred_region",selected="Central")
        ########more updates here
        output$o_pred_res_para<- renderText({""
        }) 
        output$o_pred_res_price<- renderText({""
        }) 
    }) #close observe resetbut bracket
    
    ################ output in tab_doc

    ################ output in tab_todo
    
    
}) #close shinyServer bracket