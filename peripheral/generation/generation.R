# -*- coding: utf-8-unix -*-
library(strafica)

background = load1(ancfile("primary/background.RData"))
trips = load1("trips.RData")
stat = fold(trips, .(model_type),
            n=length(pid),
            xfactor=sum(xfactor))
stat$xfactor_per_person = stat$xfactor / sum(background$xfactor)
write.csv2(stat, file="generation.csv", row.names=FALSE)
print(stat)
