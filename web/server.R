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




# Inititation -------------------------------------------------------------
#load dataset etc
numobs<- 800

#normal dataframe
numvar<-rnorm(numobs, mean = 0, sd=1)
groupvar<- sample(
    c("A","B","C"), size=numobs, replace = TRUE
)
normdf<-data.frame(groupvar, numvar) %>% 
    setNames(c("group","value"))

normdistgg<- normdf %>% ggplot(aes(x=value, fill=group)) + theme_bw() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    geom_density(alpha=0.5)


#uniform dataframe
numvar<-runif(numobs, min = -10, max=10)
groupvar<- sample(
    c("A","B","C"), size=numobs, replace = TRUE
)
unifdf<-data.frame(groupvar, numvar) %>% 
    setNames(c("group","value"))

unifdistgg<- unifdf %>% ggplot(aes(x=value, fill=group)) + theme_bw() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    geom_density(alpha=0.5)

# Shiny Server ------------------------------------------------------------
shinyServer(function(input, output, session) {
    
    ################ shiny js
    
    ################ output in tab_vis
    output$o_vis_dist<-renderPlotly({
        baseplot<- switch(input$i_vis_dist_type,
            'n' = normdistgg,
            'u' = unifdistgg
        )
        
        ggplotly(baseplot)
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
    
}) #close shinyServer bracket
