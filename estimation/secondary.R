# -*- coding: windows-1252-dos -*-
library(strafica)

tours = load1("tours-metropolitan.RData")
tour_columns = colnames(tours)
tours = subset(tours, secondary_destination != -1)
tours = subset(tours, zone_secondary_destination != 0)
stopifnot(all(tours$order %in% c("ABC", "ACB", "BAC", "BCA", "CAB", "CBA")))
tours$from = ifelse(tours$order %in% c("ACB", "BAC", "CBA"), "A", "B")

secondary = data.frame(pid=tours$pid)
secondary$xfactor = tours$xfactor
secondary$rzone = tours$rzone
secondary$tour_type = tours$tour_type
secondary$no_of_trips = tours$no_of_trips
secondary$closed = tours$closed
secondary$source = NA
secondary$starts_from = NA
secondary$ends_to = NA
secondary$itime = NA
secondary$jtime = NA
secondary$origin = ifelse(tours$from == "A", tours$origin, tours$destination)
secondary$destination = tours$secondary_destination
secondary$secondary_destination = ifelse(tours$from == "B", tours$origin, tours$destination)
secondary$itime_origin = ifelse(tours$from == "A", tours$itime_origin, tours$itime_destination)
secondary$itime_destination = tours$itime_secondary_destination
secondary$itime_secondary_destination = ifelse(tours$from == "B", tours$itime_origin, tours$itime_destination)
secondary$zone_origin = ifelse(tours$from == "A", tours$zone_origin, tours$zone_destination)
secondary$zone_destination = tours$zone_secondary_destination
secondary$zone_secondary_destination = ifelse(tours$from == "B", tours$zone_origin, tours$zone_destination)
secondary$order = tours$order
secondary$mode = tours$mode
secondary$length = tours$length
secondary$path = tours$path
secondary$visits_t1 = tours$visits_t1
secondary$visits_t2 = tours$visits_t2
secondary$visits_t3 = tours$visits_t3
secondary$visits_t4 = tours$visits_t4
secondary$visits_t5 = tours$visits_t5
secondary$visits_t6 = tours$visits_t6
secondary$visits_t7 = tours$visits_t7
secondary$visits_t8 = tours$visits_t8
secondary$visits_t9 = tours$visits_t9
secondary$visits_t10 = tours$visits_t10
secondary$visits_t11 = tours$visits_t11
secondary$visits_t12 = tours$visits_t12
secondary$model = tours$model
secondary$year = tours$year
secondary$constructed = FALSE

stopifnot(all(colnames(secondary) == tour_columns))

save(secondary, file="secondary-metropolitan.RData")
