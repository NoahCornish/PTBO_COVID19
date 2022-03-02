
##### 
# Built by Noah Cornish using data from the open government database for 
# the province of Ontario. 

#####
library(httr)
library(jsonlite)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(googlesheets4)
library(stringr)

Today <- Sys.Date() # date today for filtering

#access the API
PTBO_Case_API <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=d1bfe1ad-6575-4352-8302-09ca81f7ddfc&limit=50000000000")

#Filter only PTBO health unit
PTBO <- as.data.frame(PTBO_Case_API$result$records) %>% 
  filter(PHU_NAME == "PETERBOROUGH COUNTY-CITY") %>% 
  rename(`PUBLIC HEALTH UNIT` = PHU_NAME, DATE = FILE_DATE) %>% 
  select(DATE, `PUBLIC HEALTH UNIT`, ACTIVE_CASES, RESOLVED_CASES, DEATHS)

#remove unwanted text in the date column
PTBO$DATE <- gsub("T00:00:00","", as.character(PTBO$DATE))

#write to csv
write.csv(PTBO,
          file = "PTBO_Case_Outcomes.csv",
          row.names = FALSE)




