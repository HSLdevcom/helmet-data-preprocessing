# -*- coding: windows-1252-dos -*-
library(strafica)

TYPE_HOME = 1

# New tours are constructed from those tours that do not visit home at any 
# point. New tours are open and go from person's home to the origin of
# non-home-based tour.
input = c("tours-peripheral.RData", "tours-metropolitan.RData")
output = c("constructed-peripheral.RData", "constructed-metropolitan.RData")
for (i in seq_along(input)) {
    
    tours = load1(input[i])
    tours = subset(tours, origin %nin% TYPE_HOME & destination %nin% TYPE_HOME)
    tour_columns = colnames(tours)
    
    constructed = data.frame(pid=tours$pid)
    constructed$xfactor = tours$xfactor
    constructed$rzone = tours$rzone
    constructed$tour_type = sprintf("%d - %d",
                                    TYPE_HOME,
                                    as.integer(sapply(strsplit(tours$tour_type, split=" - "), `[[`, 1)))
    constructed$no_of_trips = 1
    constructed$closed = TRUE
    constructed$source = TYPE_HOME
    constructed$starts_from = TYPE_HOME
    constructed$ends_to = tours$zone_origin
    constructed$itime = ""
    constructed$jtime = ""
    constructed$origin = TYPE_HOME
    constructed$destination = tours$zone_origin
    constructed$secondary_destination = -1
    constructed$itime_origin = ""
    constructed$itime_destination = ""
    constructed$itime_secondary_destination = ""
    constructed$zone_origin = tours$rzone
    constructed$zone_destination = tours$zone_origin
    constructed$zone_secondary_destination = -1
    constructed$mode = 4
    constructed$length = NA
    constructed$path = sprintf("1 - %d", tours$zone_origin)
    constructed$visits_t1 = 1
    constructed$visits_t2 = ifelse(constructed$destination == 2, 1, 0)
    constructed$visits_t3 = ifelse(constructed$destination == 3, 1, 0)
    constructed$visits_t4 = ifelse(constructed$destination == 4, 1, 0)
    constructed$visits_t5 = ifelse(constructed$destination == 5, 1, 0)
    constructed$visits_t6 = ifelse(constructed$destination == 6, 1, 0)
    constructed$visits_t7 = ifelse(constructed$destination == 7, 1, 0)
    constructed$visits_t8 = ifelse(constructed$destination == 8, 1, 0)
    constructed$visits_t9 = ifelse(constructed$destination == 9, 1, 0)
    constructed$visits_t10 = ifelse(constructed$destination == 10, 1, 0)
    constructed$visits_t11 = ifelse(constructed$destination == 11, 1, 0)
    constructed$visits_t12 = ifelse(constructed$destination == 12, 1, 0)
    constructed$model = tours$model
    constructed$year = tours$year
    constructed$constructed = TRUE
    
    stopifnot(all(colnames(constructed) == tour_columns))
    
    save(constructed, file=output[i])
}
