# Built by Noah Cornish using data from the open government database for 
# the province of Ontario. 

library(httr)
library(jsonlite)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(googlesheets4)
library(stringr)
library(scales)

## ONLY RUN THIS ON FRIDAY'S ##

Today = Sys.Date()

## ACCESS GOOGLE SHEET ##
ss_LTC <- gs4_get('https://docs.google.com/spreadsheets/d/17MlCgdoCt551VKWOTY6HqWZkKSzXkX3an9mPzfsBPdI/edit?usp=sharing')


ON_PHU_LTC_OUTBREAK_API <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=4b64488a-0523-4ebb-811a-fac2f07e6d59&limit=5000000000")

ON_LTC_OUTBREAKS <- as.data.frame(ON_PHU_LTC_OUTBREAK_API$result$records)

PTBO_LTC_OUTBREAKS <- as.data.frame(ON_PHU_LTC_OUTBREAK_API$result$records)

PTBO_LTC_OUTBREAKS <- data.frame(lapply(PTBO_LTC_OUTBREAKS, function(a){
  if (is.character(a)) return(toupper(a))
  else return(a)
}
))
  
PTBO_LTC_OUTBREAKS <- PTBO_LTC_OUTBREAKS %>% 
  
  filter(PHU == "PETERBOROUGH") %>% 
  rename(Date = Report_Data_Extracted) %>% 
  select(Date, PHU, LTC_Home, City, Beds, Total_LTC_Resident_Cases,
         Total_LTC_Resident_Deaths, Total_LTC_HCW_Cases)

PTBO_LTC_OUTBREAKS[is.na(PTBO_LTC_OUTBREAKS)] = 0
PTBO_LTC_OUTBREAKS$Date <- gsub("T00:00:00","", 
                                as.character(PTBO_LTC_OUTBREAKS$Date))


### WRITE TO GOOGLE SHEET ###
range_delete(ss_LTC, range = "2:244")
sheet_append(ss_LTC, data = PTBO_LTC_OUTBREAKS) 

  




