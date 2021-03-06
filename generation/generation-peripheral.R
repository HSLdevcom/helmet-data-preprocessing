# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("peripheral/primary/observations.RData"))

# Tour types
observations = subset(observations, ttype %in% c(1:7))
observations$model_type = NA
m = which(observations$ttype %in% 1)
observations$model_type[m] = "hwp"
m = which(observations$ttype %in% 2:5)
observations$model_type[m] = "hop"
m = which(observations$ttype %in% 6:7)
observations$model_type[m] = "oop"

tours = pick(observations,
             pid,
             mode,
             xfactor,
             model_type,
             closed)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor
check.na(tours)

background = load1(ancfile("peripheral/primary/background.RData"))
background = subset(background, rzone_peripheral_municipality %in% 1)
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
write.csv2(stat, file="generation-peripheral.csv", row.names=FALSE)
print(stat)
