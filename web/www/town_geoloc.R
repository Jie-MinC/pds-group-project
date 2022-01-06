

# Library and Init --------------------------------------------------------
library(jsonlite)
library(dplyr)
library(stringr)
library(leaflet)
load(file = "www/inputC.RData")

osmgeoapi<-c("https://nominatim.openstreetmap.org/search?",
             "&countrycodes=sg&format=json&limit=1&addressdetails=1")

osmrevgeoapi<- c("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=",
           "&lon=")

# Town --------------------------------------------------------------------

townvec<-inputC$town
numtown<- length(townvec)
TownData<-data.frame(townvec, rep(NA,numtown), rep(NA,numtown), rep(NA,numtown)) %>% 
  setNames(c("Town", "Lat", "Lng", "revGeoCode"))

for (i in 1:numtown){
  #print(paste("Now doing town ", TownData$Town[i], sep=""))
  if (i%%5 ==0){
    print( paste(toString(i)," towns done", sep=""))
  }
  
  adjtownname<- str_replace_all(TownData$Town[i], " ", "+")
  osmurl<- paste(osmgeoapi[1],"city=",adjtownname,osmgeoapi[2],sep="")
  osmjson<- fromJSON(readLines(osmurl))
  if (!!length(osmjson)) {
    fLat<- as.numeric(unlist(osmjson$lat))
    fLng<- as.numeric(unlist(osmjson$lon))
    TownData$Lat[i]<- fLat
    TownData$Lng[i]<- fLng
    
    #check address
    osmurl2<- paste(osmrevgeoapi[1],fLat,osmrevgeoapi[2],fLng, sep="")
    suppressWarnings(
      osmjson2<- fromJSON(readLines(osmurl2))
    )
    TownData$revGeoCode[i]<- osmjson2$display_name
  }
}

#manual input
indCA<- which(TownData$Town=="CENTRAL AREA")
TownData$Lat[indCA]<- 1.2789
TownData$Lng[indCA]<- 103.8536

indKW<- which(TownData$Town=="KALLANG/WHAMPOA")
TownData$Lat[indKW]<- 1.3245
TownData$Lng[indKW]<- 103.8572

# Street ------------------------------------------------------------------
strNvec<-inputC$street_name
numstr<- length(strNvec)
StrData<-data.frame(strNvec, rep(NA,numstr), rep(NA,numstr), rep(NA,numstr)) %>% 
  setNames(c("S_Name", "Lat", "Lng", "revGeoCode"))

for (i in 1:numstr){
  #print(paste("Now doing town ", TownData$Town[i], sep=""))
  if (i%%5 ==0){
    print( paste(toString(i)," streets done", sep=""))
  }
  
  adjstrname<- str_replace_all(StrData$S_Name[i], " ", "+")
  osmurl<- paste(osmgeoapi[1],"street=",adjstrname,osmgeoapi[2],sep="")
  osmjson<- fromJSON(readLines(osmurl))
  if (!!length(osmjson)) {
    fLat<- as.numeric(unlist(osmjson$lat))
    fLng<- as.numeric(unlist(osmjson$lon))
    StrData$Lat[i]<- fLat
    StrData$Lng[i]<- fLng
    
    #check address
    osmurl2<- paste(osmrevgeoapi[1],fLat,osmrevgeoapi[2],fLng, sep="")
    suppressWarnings(
      osmjson2<- fromJSON(readLines(osmurl2))
    )
    StrData$revGeoCode[i]<- osmjson2$display_name
  }
}



#leaflet
mapI <- awesomeIcons(
  icon = 'map-marker',
  iconColor = 'blue',
  library = 'glyphicon',
)

SgTownMap<- leaflet( data=TownData, options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)) %>% 
  addProviderTiles(providers$OneMapSG.Original, 
                   options = providerTileOptions(
                     minZoom = 10.5, maxZoom = 15)) %>%
  addMarkers(~Lng, ~Lat, label= ~Town)


SgTownMap

SgStrMap<- leaflet( data=StrData, options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)) %>% 
  addProviderTiles(providers$OneMapSG.Original, 
                   options = providerTileOptions(
                     minZoom = 10.5, maxZoom = 15)) %>%
  addMarkers(~Lng, ~Lat, label= ~S_Name)


SgStrMap


save(TownData, file="www/TownData.RData")
save(StrData, file="www/StrData.RData")



