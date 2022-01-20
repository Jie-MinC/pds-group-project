# Read Me ------------------------------------------------------------------
# naming convention:
# tabName = "tab_{tabname}"
# id for inputs: "i_{tabname}_{id}"
# id for outputs: "o_{tabname}_{id}"


# Library -----------------------------------------------------------------
library(shiny)
library(shinyBS)
library(stringr)
library(jsonlite)
library(leaflet)
library(randomForest)

# Inititation -------------------------------------------------------------
#moved to global.R

# Shiny Server ------------------------------------------------------------
shinyServer(function(input, output, session) {
    
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
        
        xyvar<- unlist(str_split(input$i_vis_hm_xyvar, " & "))

        hmsum<- hmdf %>%
            group_by_at(vars(xyvar[1],
                             xyvar[2])) %>% 
            summarise(MRP_in_k = mean(RP_in_k), .groups = "drop")
        
        xaxlab<-names(inputC$attChoices)[which(inputC$attChoices==xyvar[1])]
        yaxlab<-names(inputC$attChoices)[which(inputC$attChoices==xyvar[2])]
        
        hmplot<- hmsum %>%
            ggplot(aes_string(x = xyvar[1], y= xyvar[2],
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
            geom_point(alpha=0.5) + theme_bw() +
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
            "Click on the map to get the nearest town.", br(),
            "Nearest Town: ", textOutput("o_pred_map_town", inline = TRUE),
            
            easyClose=TRUE, 
            footer = modalButton("Confirm")
        )
        )
        
        output$o_pred_map<- renderLeaflet({
            SgMap
        }) #close render Leaflet
    })
    
    observeEvent(input$i_pred_maxF, {
        maxindex<- ceiling(input$i_pred_maxF/3)
        newchoices<- as.list(sort(inputC$storey_range)[1:maxindex])
        
        tosel<- ifelse(input$i_pred_SRange %in% newchoices,
                       input$i_pred_SRange,
                       "01 TO 03")
        
        updateSelectInput(session, "i_pred_SRange",
                          choices = newchoices,
                          selected = tosel
        )
    }
    )
    
    observeEvent(input$o_pred_map_click, {
        
        fLat<-as.numeric(input$o_pred_map_click[1])
        fLng<-as.numeric(input$o_pred_map_click[2])
        
        distvec<- summarise(TownData,dist = geodist(fLat,fLng,Lat,Lng))
        towntext<- TownData$Town[which.min(unlist(distvec))]
        
        output$o_pred_map_town<- renderText({towntext})
        updateSelectInput(session, "i_pred_town", selected = towntext)
        
    })
    
    
    observeEvent(input$i_pred_predbut, {
        town <- input$i_pred_town
        flat_type <- input$i_pred_flatT
        storey_range <- input$i_pred_SRange
        floor_area_sqm <- input$i_pred_floorA
        flat_model <- input$i_pred_flatM
        remaining_lease <- input$i_pred_RLease *12
        max_floor_lvl <- input$i_pred_maxF
        commercial <- as.numeric(input$i_pred_com)
        market_hawker <- as.numeric(input$i_pred_mh)
        miscellaneous <- as.numeric(input$i_pred_misc)
        multistorey_carpark <- as.numeric(input$i_pred_carp)
        precinct_pavilion <- as.numeric(input$i_pred_ppav)
        
        df_input<-data.frame(town,
                             flat_type, storey_range, floor_area_sqm, 
                             flat_model, remaining_lease, max_floor_lvl, 
                             commercial, market_hawker, miscellaneous, 
                             multistorey_carpark, precinct_pavilion)
        
        df_input$town <- factor(df_input$town, levels = lvl_town)
        df_input$flat_type <- factor(df_input$flat_type, levels = lvl_flat_type)
        df_input$storey_range <- factor(df_input$storey_range, levels = lvl_storey_range)
        df_input$flat_model <- factor(df_input$flat_model, levels = lvl_flat_model)
        
        predprice<- round(predict(predmodel, newdata=df_input)/1000)
        
        output$o_pred_param_title<-renderText({
            "Flat Details:"
        })
        
        output$o_pred_param_loc<-renderText({
            "Location:"
        })
        
        output$o_pred_param_town<-renderText({
            paste("Town: ", town, ".", sep = "")
        })
        
        output$o_pred_param_ff0<-renderText({
            "Flat Feature:"
        })
        
        output$o_pred_param_ff1<-renderText({
            paste( "Flat Model: ", flat_model, ",   ",
                   "Highest Floor Level: ", max_floor_lvl, ",   ",
                   "Preferred Range for Storey Level: ", storey_range, ",",
                   sep = "")
        })
        
        output$o_pred_param_ff2<-renderText({
            paste( "Flat Type: ", flat_type, ",   ",
                   "Floor Area (sqm): ", floor_area_sqm, ",   ",
                   "Remaining Lease (year): ", remaining_lease/12, ".", 
                   sep = "")
        })
        
        output$o_pred_param_oth0<-renderText({
            "Others:"
        })
        
        output$o_pred_param_oth1<-renderText({
            paste( "Commercial: ", convertYN(commercial), ",   ",
                   "Market Hawker: ", convertYN(market_hawker), ",   ",
                   "Multi Storey Car Park: ", convertYN(multistorey_carpark), ",   ",
                   "Precinct Pavillion: ", convertYN(precinct_pavilion), ".",
                   "Miscellaneous: ", convertYN(miscellaneous), ",   ",
                   sep = "")
        })
        
        output$o_pred_res_price0<- renderText({
            'Predicted Current Price: '
        })
        output$o_pred_res_price1<- renderText({
            paste("S$ ", predprice, ",000",
                  sep="")
        })
        
    }) #close observe predbut bracket
    
    observeEvent(input$i_pred_resetbut, {
        updateSelectInput(session, "i_pred_town", selected=head(sort(inputC$town),1))
        
        updateSelectInput(session, "i_pred_flatM", selected=head(sort(inputC$flat_model),1))
        updateNumericInput(session, "i_pred_maxF", value = inputC$max_floor_lvl[2])
        updateSelectInput(session, "i_pred_SRange", 
                          choices = as.list(sort(inputC$storey_range)),
                          selected=head(sort(inputC$storey_range),1))
        
        updateSelectInput(session, "i_pred_flatT", selected=head(sort(inputC$flat_type),1))
        updateSliderInput(session, "i_pred_floorA", value = floor(mean(inputC$floor_area_sqm)))
        updateSliderInput(session, "i_pred_RLease", value = floor(mean(inputC$remaining_lease)))
        
        updateCheckboxInput(session, "i_pred_com", value = FALSE)
        updateCheckboxInput(session, "i_pred_mh", value = FALSE)
        updateCheckboxInput(session, "i_pred_misc", value = FALSE)
        updateCheckboxInput(session, "i_pred_carp", value = FALSE)
        updateCheckboxInput(session, "i_pred_ppav", value = FALSE)
        
        output$o_pred_param_title<- renderText({""
        }) 
        output$o_pred_param_loc<- renderText({""
        }) 
        output$o_pred_param_town<- renderText({""
        }) 
        output$o_pred_param_ff0<- renderText({""
        }) 
        output$o_pred_param_ff1<- renderText({""
        }) 
        output$o_pred_param_ff2<- renderText({""
        }) 
        output$o_pred_param_oth0<- renderText({""
        }) 
        output$o_pred_param_oth1<- renderText({""
        }) 
        output$o_pred_res_price0<- renderText({""
        }) 
        output$o_pred_res_price1<- renderText({""
        })
    }) #close observe resetbut bracket
    
    ################ output in tab_doc

    ################ output in tab_todo
    
    
}) #close shinyServer bracket