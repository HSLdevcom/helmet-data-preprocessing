# -*- coding: utf-8-unix -*-
library(strafica)

background = load1(ancfile("primary/background.RData"))
tours = load1("tours.RData")
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
write.csv2(stat, file="generation.csv", row.names=FALSE)
print(stat)
