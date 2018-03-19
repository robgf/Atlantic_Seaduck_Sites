#Non effort ID's

# putting efforts in order oby time (even when times don't make sense)
#

pre_track_frag_ord <- pre_track_frag %>%
  select(EffortId, SecondsFromMidnight,
         longitude_dd, latitude_dd, PointType,
         SpeciesId, Count) %>% distinct %>%
  group_by(EffortId) %>%
  arrange(EffortId, SecondsFromMidnight) %>%
  mutate(
    flag_W2E = if_else(lead(longitude_dd) > longitude_dd, 1, -1),
    flag_W2E = na.locf(flag_W2E, na.rm  =  FALSE),
    flag_rev_course = if_else(flag_W2E * lead(longitude_dd) >= flag_W2E * longitude_dd, FALSE, TRUE),
    flag_rev_course = na.locf(flag_rev_course, na.rm  =  FALSE)
  )

chck_off_effort_counts <- pre_track_frag_ord %>%
  filter(PointType %in% c("BEGCNT", "ENDCNT", "BEGTRAN", "ENDTRAN")) %>%
  group_by(EffortId) %>%
  mutate(Effort_bounds_n = n()) %>%
  filter((Effort_bounds_n %% 2) == 1)

chck_odd_bounds <- frnt_wntr_trck_pnts %>%
  filter(PointType %in% c("BEGCNT", "ENDCNT", "BEGTRAN", "ENDTRAN")) %>%
  group_by(EffortId) %>%
  mutate(Effort_bounds_n = n()) %>%
  filter((Effort_bounds_n %% 2) == 1)

