# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("primary/observations.RData"))

# Tour types in peripheral models
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

background = load1(ancfile("primary/background.RData"))
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
write.csv2(stat, file="generation.csv", row.names=FALSE)
print(stat)
