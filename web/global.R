##### this file will run once for each session
# Library -----------------------------------------------------------------
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)
library(lubridate)

# For UI use --------------------------------------------------------------

appdone<- FALSE

#load flat feature choices
load(file = "www/inputC.RData")
load(file = "www/TownData.RData")


# For server use ----------------------------------------------------------

# load cleaned dataset from github
#ghurl<- 'https://media.githubusercontent.com/media/yongkokkhuen/pds-group-project/main/data/data_clean.csv'
#cleancsv<- data.frame(read_csv(ghurl))
cleancsv<- data.frame(read_csv("www/data_clean.csv"))
cleancsv<- cleancsv %>% mutate(RP_in_k= resale_price/1000)

# open street map api
osmapi<- c("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=",
           "&lon=")

# load prediction model
predmodel <- readRDS("www/rf_model.rds")
lvl_flat_model <- readRDS("www/lvl_flat_model.rds")
lvl_flat_type <- readRDS("www/lvl_flat_type.rds")
lvl_storey_range <- readRDS("www/lvl_storey_range.rds")
lvl_town <- readRDS("www/lvl_town.rds")

#leaflet map
SgMap<- leaflet(data=TownData, options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)) %>% 
  addProviderTiles(providers$OneMapSG.Original, 
                   options = providerTileOptions(
                     minZoom = 10.5, maxZoom = 15)) %>%
  addMarkers(~Lng, ~Lat, label= ~Town) %>%
  setView(lat = 1.318, lng=103.84, zoom=10.5)


# lat lng h formula
geodist<- function(lat1, lng1, lat2, lng2){
  Earthr<- 
  #convert into radiant
  lat1<- lat1*pi/180
  lng1<- lng1*pi/180
  lat2<- lat2*pi/180
  lng2<- lng2*pi/180
  
  latdiff<- lat1-lat2
  latsum<- lat1+lat2
  lngdiff<- lng1-lng2
  
  temp1<- 1 - sin(latdiff/2)^2 - sin(latsum/2)^2
  temp2<- sqrt( sin(latdiff/2)^2 +temp1*(sin(lngdiff/2)^2) )
  dist<- asin(temp2)
  
  return(dist)
}
