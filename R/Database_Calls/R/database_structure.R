# Explore Atlantic Seabird Database ----
# Looking for needed varibles and tables for effort, observation on filtered desigins
# Rob Fowler, robert_fowler@fws.gov
# 2018-03-08
#

# Call Libraries ----
library(tidyverse) # tidyverse functionality
require(DBI)       # for relational databases
library(odbc)
require(rlang)    # tidy programming extentsion
require(magrittr) # tidy programming extentsion
require(glue)     # alternative to paste()

require(datamodelr) # package to graphically desplay daabase structure

# Query database structure ----
con <- DBI::dbConnect(odbc::odbc(), "alantic_seabirds", database = "atlantic_seabirds")
sQuery <- dm_re_query("sqlserver")
dm_atlantic_seabird <- dbGetQuery(con, sQuery)
DBI::dbDisconnect(con)

# create and plot connected portion of database ---
# # convert to a data model
dm_atlantic_seabird <- as.data_model(dm_atlantic_seabird)
focus <- list(tables = c(
  "Survey",
  "Transect",
  "SurveyMap",
  "DesignPlan",
  "DesignFlown",
  "GpsTrack_point",
  "Observation",
  "Aircraft",
  "FlightCrew",
  "ObservationCode",
  "nested_group",
  "CrewMember"


))

(focus_graph <- dm_create_graph(dm_atlantic_seabird, focus = focus) %>%
    dm_render_graph())

# Refine Plot further ----
# Season is in the SurveyMap table, SpeciesID is in Observation, Seat is in
# Flight crew table, and track points and point types are in GpsTrack. Need to
# include the connecting tables
focus <- list(tables = c(
  "SurveyMap",
  "DesignPlan",
  "DesignFlown",
  "GpsTrack_point",
  "Observation",
  "FlightCrew"
))
(relavent_graph <- dm_create_graph(dm_atlantic_seabird, focus = focus) %>%
    dm_render_graph())
