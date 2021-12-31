library(readr)


cleancsv<- data.frame(read_csv("www/data_clean.csv"))
cleancsv["block"]<- as.numeric(unlist(cleancsv["block"]))

inputC <- list()

for (catvar in c("region","town", "street_name", 
                 "new_flat_model", "storey_range", "flat_type")){
  inputC[catvar]<- unique(cleancsv[catvar])
}

inputC$block<- c(min(cleancsv["block"]),max(cleancsv["block"]))
inputC$remaining_lease<- c(min(cleancsv["remaining_lease"]),max(cleancsv["remaining_lease"]))
inputC$floor_area_sqm<- c(min(cleancsv["floor_area_sqm"]),max(cleancsv["floor_area_sqm"]))

save(inputC, file="www/inputC.RData")

rm(inputC)
load(file = "www/inputC.RData")
