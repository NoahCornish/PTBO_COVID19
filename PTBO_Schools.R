# Built by Noah Cornish using data from the open government database for 
# the province of Ontario. 

###### PTBO Schools #######

library(httr)
library(jsonlite)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(googlesheets4)
library(stringr)
library(scales)

dfToday <- Sys.Date() - 1  # date for Absenteeism 


#CONSEIL SCOLAIRE CATHOLIQUE MONAVENIR excluded
#KAWARTHA PINE RIDGE DISTRICT SCHOOL BOARD included
#PETERBOROUGH VICTORIA NORTHUM CLARINGTON CATHOLIC DISTRICT SCHOOL BOARD included

Abs_Peterborough <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=e3214f57-9c24-4297-be27-a1809f9044ba&limit=5000000000")

PTBO <- as.data.frame(Abs_Peterborough$result$records)

PTBO <- data.frame(lapply(PTBO, function(a){
  if (is.character(a)) return(toupper(a))
  else return(a)
}
))



PTBO <- filter(PTBO, school %in% c("ADAM SCOTT INTERMED S","APSLEY CENTRAL PS", "BUCKHORN PS",
                                   "CHEMONG PS", "CRESTWOOD INTERMEDIATE SCHOOL", "CRESTWOOD SS",
                                   "EDMISON HEIGHTS PS", "HAVELOCK-BELMONT PS", "HIGHLAND HEIGHTS PS",
                                   "KAAWAATE EAST CITY PUBLIC SCHOOL E PS", "KAWARTHA HEIGHTS PS",
                                   "KEITH WIGHTMAN PS", "KENNER C & VI", "KENNER INTERMEDIATE S",
                                   "LAKEFIELD DISTRICT PS", "MILLBROOK/SOUTH CAVAN PS", "NORTH CAVAN PS",
                                   "NORTH SHORE PS", "NORWOOD DISTRICT HS", "NORWOOD DISTRICT INTERMED S",
                                   "NORWOOD DISTRICT PS", "OTONABEE VALLEY PS", "PETERBOROUGH C & VS",
                                   "QUEEN ELIZABETH PS", "R F DOWNEY PS", "THOMAS A STEWART SS", "WARSAW PS",
                                   "HOLY CROSS CATHOLIC SS", "IMMACULATE CONCEPTION C ELEM S",
                                   "MONSIGNOR O'DONOGHUE C ELEM S", "ST. ALPHONSUS C ELEM S", "ST. ANNE C ELEM S",
                                   "ST. CATHERINE C ELEM S", "ST. JOHN C ELEM S", "ST. MARTIN C ELEM S",
                                   "ST. PATRICK C ELEM S", "ST. PAUL C ELEM S", "ST. PAUL C ELEM S", 
                                   "ST. PAUL C ELEM S", "ST. PETER CATHOLIC SS", "JAMES STRATH PS", 
                                   "PRINCE OF WALES PS", "ROGER NEILSON PS", "WESTMOUNT PS", 
                                   "ST. JOSEPH CES", "ST. TERESA CES"))

## SHOULD BE 44 schools in final dataset 

  PTBO <- filter(PTBO, school_board %in% c("KAWARTHA PINE RIDGE DISTRICT SCHOOL BOARD", 
                                   "PETERBOROUGH VICTORIA NORTHUM CLARINGTON CATHOLIC DISTRICT SCHOOL BOARD")) %>% 
  select(date, school_board, school, city_or_town, absence_percentage_staff_students)

PTBO$absence_percentage_staff_students <- as.numeric(PTBO$absence_percentage_staff_students)

PTBO_Schools_AllData <- PTBO%>% 
  mutate(`Absenteeism Percentage` = absence_percentage_staff_students) %>%
  #mutate(`Absenteeism Percentage` = label_percent(absence_percentage_staff_students)) %>% 
  select(date, school_board, school, city_or_town, `Absenteeism Percentage`) %>%
  select(date, school_board, school, city_or_town, `Absenteeism Percentage`) %>% 
  rename(Date = date, School = school, `School Board` = school_board, Location = city_or_town)
PTBO_Schools_AllData$Date <- gsub("T00:00:00","", as.character(PTBO_Schools_AllData$Date))

Absenteeism1 <- scales::percent(PTBO_Schools_AllData$`Absenteeism Percentage`)


PTBO_Schools_AllData <- PTBO_Schools_AllData %>% 
  mutate(`Absenteeism Percentage` = Absenteeism1)

#write to csv
write.csv(PTBO_Schools_AllData,
          file = "PTBO_School_AllData.csv",
          row.names = FALSE)


PTBO_Schools <- PTBO %>% 
  mutate(`Absenteeism Percentage` = absence_percentage_staff_students) %>%
  #mutate(`Absenteeism Percentage` = label_percent(absence_percentage_staff_students)) %>% 
  select(date, school_board, school, city_or_town, `Absenteeism Percentage`) %>%
  filter(date == dfToday) %>% 
  select(date, school_board, school, city_or_town, `Absenteeism Percentage`) %>% 
  rename(Date = date, School = school, `School Board` = school_board, Location = city_or_town)
PTBO_Schools$Date <- gsub("T00:00:00","", as.character(PTBO_Schools$Date))

Absenteeism1 <- scales::percent(PTBO_Schools$`Absenteeism Percentage`)


PTBO_Schools <- PTBO_Schools %>% 
  mutate(`Absenteeism Percentage` = Absenteeism1)

#write to csv
write.csv(PTBO_Schools,
          file = "PTBO_School_Data.csv",
          row.names = FALSE)

#############