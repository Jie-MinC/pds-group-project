##### this file will run once for each session
# Library -----------------------------------------------------------------
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)

# For UI use --------------------------------------------------------------

appdone<- FALSE

#load flat feature choices
load(file = "www/inputC.RData")


# For server use ----------------------------------------------------------

# load cleaned dataset from github
#ghurl<- 'https://media.githubusercontent.com/media/yongkokkhuen/pds-group-project/main/data/data_clean.csv'
#cleancsv<- data.frame(read_csv(ghurl))
cleancsv<- data.frame(read_csv("www/data_clean.csv"))

# open street map api
osmapi<- c("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=",
           "&lon=")

#leaflet map
SgMap<- leaflet(options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)) %>% 
  addProviderTiles(providers$OneMapSG.Original, 
                   options = providerTileOptions(
                     minZoom = 10.5, maxZoom = 15)) %>%
  setView(lat = 1.318, lng=103.84, zoom=10.5)

#Visualisation tab plotting
areaplot<- cleancsv %>% 
  ggplot(aes(x=floor_area_sqm, y=resale_price, color = region)) +
  geom_point() +
  scale_color_brewer(type = "qual", palette = 5)

regplot<- cleancsv %>% 
  ggplot(aes(x=region,y=resale_price, fill = region)) + theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  geom_violin() + geom_boxplot(width = 0.1) + theme(legend.position="none")+
  scale_color_brewer(type = "qual", palette = 5)

nfmplot<- cleancsv %>%
  ggplot(aes(x=resale_price, fill = new_flat_model)) + theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  geom_density(alpha=0.5)  

#nfmggplotly<-ggplotly(nfmplot)
#rm(nfmplot)
