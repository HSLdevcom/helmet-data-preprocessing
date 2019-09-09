# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
stat = fold(trips, .(ttype_peripheral, return, inverted),
            n=length(pid),
            xfactor=sum(xfactor))
write.csv2(stat, file="trips_per_person.csv", row.names=FALSE)
