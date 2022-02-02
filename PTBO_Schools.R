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

ss <- gs4_get('https://docs.google.com/spreadsheets/d/1Gcl6BSxJb0f3lK0Zbi4O9zd-_lLHoTIY7aUEFlH4sqo/edit?usp=sharing')

# read sheet from googlesheet (nb_shots shared in claircornish google drive)
df2 <- read_sheet("https://docs.google.com/spreadsheets/d/1Gcl6BSxJb0f3lK0Zbi4O9zd-_lLHoTIY7aUEFlH4sqo/edit?usp=sharing")

df2_previous <- df2 %>% 
  select(School) %>% 
  unique()


Abs_Peterborough <- fromJSON(
  "https://data.ontario.ca/api/3/action/datastore_search?resource_id=e3214f57-9c24-4297-be27-a1809f9044ba&limit=5000000000")

PTBO <- as.data.frame(Abs_Peterborough$result$records)

PTBO <- data.frame(lapply(PTBO, function(a){
  if (is.character(a)) return(toupper(a))
  else return(a)
}
))

PTBO <- filter(PTBO, school_board %in% c("PETERBOROUGH VICTORIA NORTHUM CLARINGTON CATHOLIC DISTRICT SCHOOL BOARD", 
                                         "KAWARTHA PINE RIDGE DISTRICT SCHOOL BOARD")) %>% 
  select(date, school_board, school, city_or_town, absence_percentage_staff_students)

PTBO$absence_percentage_staff_students <- as.numeric(PTBO$absence_percentage_staff_students)

PTBO_Schools <- PTBO %>% 
  mutate(`Absenteeism Percentage` = absence_percentage_staff_students) %>%
  #mutate(`Absenteeism Percentage` = label_percent(absence_percentage_staff_students)) %>% 
  select(date, school_board, school, city_or_town, `Absenteeism Percentage`) %>%
  filter(date == dfToday) %>% 
  select(date, school_board, school, `Absenteeism Percentage`) %>% 
  rename(Date = date, School = school, `School Board` = school_board)
PTBO_Schools$Date <- gsub("T00:00:00","", as.character(PTBO_Schools$Date))

Absenteeism1 <- scales::percent(PTBO_Schools$`Absenteeism Percentage`)


PTBO_Schools <- PTBO_Schools %>% 
  mutate(`Absenteeism Percentage` = Absenteeism1)

range_delete(ss, range = "2:10000")
sheet_append(ss, data = PTBO_Schools)

#############