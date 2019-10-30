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
tours = leftjoin(tours, model_types)
tours = leftjoin(tours, modes)
tours = unpick(tours, mode)

trips = tours
trips$from_origin = !(is_inverted(tours$order))
trips$itime = trips$itime

trips2 = subset(tours, closed %in% 1 & no_of_trips>1)
trips2$from_origin = (is_inverted(trips2$order))
trips2$itime = trips2$jtime

trips = rbind_list(trips, trips2)
trips = unpick(trips, jtime)

# Output
check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
