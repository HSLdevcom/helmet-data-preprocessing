# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

model_types = read.delims("models.txt")
modes = read.delims("modes.txt")

observations1 = load1(ancfile("metropolitan/primary/observations.RData"))
observations2 = load1(ancfile("peripheral/primary/observations.RData"))
tours = rbind_list(observations1, observations2)
tours = pick(tours,
             pid,
             mode,
             ttype,
             survey,
             year,
             mtype,
             xfactor,
             itime,
             jtime,
             closed,
             order,
             no_of_trips)
tours$inverted = is_inverted(tours$order)
tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = unpick(tours, mode)

trips = tours
trips$direction = ifelse(trips$inverted, "back", "there")
trips$itime_trip = ifelse(trips$inverted, trips$jtime, trips$itime)

trips2 = subset(tours, closed %in% 1 & no_of_trips>1)
trips2$direction = ifelse(trips2$inverted, "there", "back")
trips2$itime_trip = ifelse(trips2$inverted, trips2$itime, trips2$jtime)

trips = rbind_list(trips, trips2)

# Output
check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
