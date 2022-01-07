library(readr)


cleancsv<- data.frame(read_csv("www/data_clean.csv"))

inputC <- list()
inputC$year<- unique(cleancsv$year)

for (catvar in c("town", "street_name",  "flat_type",
                 "storey_range", "flat_model", "region")){
  inputC[catvar]<- unique(cleancsv[catvar])
}

inputC$block<- c(min(cleancsv["block"]),max(cleancsv["block"]))
inputC$floor_area_sqm<- c(min(cleancsv["floor_area_sqm"]),max(cleancsv["floor_area_sqm"]))
inputC$remaining_lease<- c(floor(min(cleancsv["remaining_lease"])/12),
                           floor(max(cleancsv["remaining_lease"])/12))



inputC$attChoices<-list("Region" = "region",
                 "Town" = "town",
                 "Flat Type" = "flat_type",
                 "Flat Model" = "flat_model")

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
