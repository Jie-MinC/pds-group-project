library(readr)

cleancsv<- read.csv("www/data_clean.csv")

inputC <- list()
inputC$year<- unique(cleancsv$year)

for (catvar in c("town", "flat_type",
                 "storey_range", "flat_model", "region")){
  inputC[catvar]<- unique(cleancsv[catvar])
}

inputC$floor_area_sqm<- c(30,300)
inputC$remaining_lease<- c(1,99)
inputC$max_floor_lvl<- c(2,51)


inputC$attChoices<-list("Region" = "region",
                 "Town" = "town",
                 "Flat Type" = "flat_type",
                 "Flat Model" = "flat_model")

inputC$hmChoices<- list("Region & Flat Model" = "region & flat_model",
                        "Region & Flat Type" = "region & flat_type",
                        "Town & Flat Model" = "town & flat_model",
                        "Town & Flat Type" = "town & flat_type")
inputC$spChoices<- list("Region" = "region", "Flat Type" = "flat_type")

CentralT<- c("BUKIT MERAH","BUKIT TIMAH","GEYLANG","TOA PAYOH", "BISHAN",
             "KALLANG/WHAMPOA","MARINE PARADE", "CENTRAL AREA", "QUEENSTOWN")
EastT<- c("TAMPINES","BEDOK","PASIR RIS")
NorthT<- c("SEMBAWANG","WOODLANDS","YISHUN")
NorthEastT<- c("ANG MO KIO","HOUGANG","PUNGGOL","SENGKANG","SERANGOON")
WestT<- c("BUKIT BATOK","BUKIT PANJANG", "CHOA CHU KANG","CLEMENTI",
          "JURONG EAST","JURONG WEST")

inputC$RegTown<- list( "All" = sort(c(CentralT, EastT, NorthT, NorthEastT, WestT)),
                      "Central"= CentralT,
                      "East" = EastT,
                      "North" = NorthT,
                      "North-East" = NorthEastT,
                      "West" = WestT)

save(inputC, file="www/inputC.RData")

rm(inputC)
#load(file = "www/inputC.RData")
