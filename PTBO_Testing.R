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

ON_PHU_Testing_API <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=07bc0e21-26b5-4152-b609-c1958cb7b227&limit=5000000000")

ON_PHU_Testing <- as.data.frame(ON_PHU_Testing_API$result$records) %>% 
  
  select(DATE, PHU_name, percent_positive_7d_avg, 
         test_volumes_7d_avg, tests_per_1000_7d_avg, 
         percent_complete_nextday_7d_avg, 
         percent_complete_2days_7d_avg) %>% 
  
  rename(Date = DATE, `Public Health Unit` = PHU_name, 
         `Percent Positive 7d Avg` = percent_positive_7d_avg, 
        `Testing Volume 7d Avg` = test_volumes_7d_avg,
        `Tests Per 1000 7d Avg` = tests_per_1000_7d_avg,
        `Percent Complete Next Day 7d Avg` = percent_complete_nextday_7d_avg,
        `Percent Complete Two Days 7d Avg` = percent_complete_2days_7d_avg)
  
PTBO_Testing <- ON_PHU_Testing %>% 
  
  filter(`Public Health Unit` == "Peterborough County-City Health Unit")


Percent1 <- scales::percent(PTBO_Testing$`Percent Positive 7d Avg`)
Percent2 <- scales::percent(PTBO_Testing$`Percent Complete Next Day 7d Avg`)
Percent3 <- scales::percent(PTBO_Testing$`Percent Complete Two Days 7d Avg`)

PTBO_Testing <- PTBO_Testing %>% 
  mutate(`Percent Positive 7d Avg` = Percent1)

PTBO_Testing <- PTBO_Testing %>% 
  mutate(`Percent Complete Next Day 7d Avg` = Percent2)

PTBO_Testing <- PTBO_Testing %>% 
  mutate(`Percent Complete Two Days 7d Avg` = Percent3)


PTBO_Testing <- PTBO_Testing[(order(as.Date(PTBO_Testing$Date, format="%Y/%m/%d"))),]


#write to csv
write.csv(PTBO_Testing,
          file = "PTBO_Testing_Data.csv",
          row.names = FALSE)

  


  

  
  
  