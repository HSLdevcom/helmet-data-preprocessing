# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
stat = fold(trips, .(ttype_peripheral, return_trip, inverted, mode, trip_time),
            n=length(pid),
            xfactor=sum(xfactor))
write.csv2(stat, file="time_and_inversion.csv", row.names=FALSE)
