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
vw_winter_front_DesignFlown <- tbl(con, "DesignFlown") %>%
  filter(DesignId %in% Winter_Design_id$DesignId) %>%
  filter(CrewMemberRoleId %in% front_FlightCreew_id$CrewMemberRoleId) %>%
  select(EffortId, DesignId, CrewMemberRoleId, dateFlown, ReplicateNumber) %>%
  collect()



# Relavent EffortId, DesignId, Seat Combination ----
front_winter_effort <- vw_winter_front_DesignFlown %>%
  left_join(front_FlightCreew_id, by = "CrewMemberRoleId") %>%
  select(EffortId, DesignId, Seat)

# Pull GpsTrack_point with above EffortId
frnt_wntr_trck_pnts <- tbl(con, "GpsTrack_point") %>%
  filter(EffortId %in% front_winter_effort$EffortId) %>%
  select(EffortId, SecondsFromMidnight, longitude_dd, latitude_dd,
         GpsError, PointType, ConditionCode) %>%
  collect()

# Pull from Observation table
frnt_wntr_obs <- tbl(con, "Observation") %>%
  filter(EffortId %in% front_winter_effort$EffortId) %>%
  filter(SpeciesId %in% c("BLSC", "LTDU", "BUFF", "MERG",
                          "RBME", "COGO", "SUSC", "SCOT",
                          "DUCK", "WWSC", "COEI", "COME",
                          "HOME", "BAGO", "GOLD", "DWSC",
                          "GOME", "HARD", "UNDD", "EIDE")) %>%
  select(ObservationId, EffortId, SpeciesId,
         longitude_dd, latitude_dd, Count) %>%
  collect()

DBI::dbDisconnect(con)


# Simplify to an observation and track view with Design and Effort ids
vw_trk <- left_join(frnt_wntr_trck_pnts, front_winter_effort, by = "EffortId")
vw_obs <- left_join(frnt_wntr_obs,       front_winter_effort, by = "EffortId")

# I have determined that observations were not included as track points.
# So... we need to join these views to get all our useful points in one place to be ordered.

pre_track_frag <- full_join(vw_trk, vw_obs,
                            by = c("EffortId", "longitude_dd",
                                   "latitude_dd", "DesignId", "Seat"))
