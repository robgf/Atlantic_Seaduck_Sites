# Import relavant Atlantic Seabird Database ----
# Looking for needed varibles and tables for effort, observation on filtered desigins
# Rob Fowler, robert_fowler@fws.gov
# 2018-03-08
#

# Call Libraries and connect----
library(tidyverse) # tidyverse functionality
require(DBI)       # for relational databases
library(odbc)
require(rlang)    # tidy programming extentsion
require(magrittr) # tidy programming extentsion
require(glue)     # alternative to paste()

require(datamodelr) # package to graphically desplay daabase structure

#Open Connection
con <- DBI::dbConnect(odbc::odbc(), "alantic_seabirds", database = "atlantic_seabirds")

#Create filters ----
#Creat Design Flown by Season list
Winter_Survey_id <- tbl(con, "SurveyMap") %>%
  filter(Season == "Winter") %>%
  select(SurveyId) %>%
  collect()
Winter_Design_id <- tbl(con, "DesignPlan") %>%
  filter(SurveyId %in% Winter_Survey_id$SurveyId) %>%
  select(DesignId) %>%
  collect()

#Create Seat FL FR list
front_FlightCreew_id <- tbl(con, "FlightCrew") %>%
  filter(Seat %in% c("LF", "RF")) %>%
  select(CrewMemberRoleId, Seat) %>%
  collect()

#Filter Effort Ids retain Seat info
fltr_DesignFlown <- tbl(con, "DesignFlown") %>%
  filter(DesignId %in% Winter_Design_id$DesignId) %>%
  filter(CrewMemberRoleId %in% front_FlightCreew_id$CrewMemberRoleId) %>%
  select(EffortId, DesignId, CrewMemberRoleId, dateFlown, ReplicateNumber) %>%
  collect()



# Relavent EffortId, DesignId, Seat Combination ----
front_winter_effort <- fltr_DesignFlown %>%
  left_join(front_FlightCreew_id, by = "CrewMemberRoleId") %>%
  select(EffortId, DesignId, Seat)

# Pull GpsTrack_point with above EffortId
frnt_wntr_trck_pnts <- tbl(con, "Gps_Track_point")
