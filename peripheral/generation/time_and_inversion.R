# -*- coding: utf-8-unix -*-
library(strafica)

trips = load1("trips.RData")
stat = fold(trips, .(model_type, mode, trip_time, direction),
            n=length(pid),
            xfactor=sum(xfactor))
write.csv2(stat, file="time_and_inversion.csv", row.names=FALSE)
print(stat)
