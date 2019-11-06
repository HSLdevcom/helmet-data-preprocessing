# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("primary/observations.RData"))

# Tour types
observations = subset(observations, ttype %in% c(1:7))
observations$model_type = NA
m = which(observations$ttype %in% 1)
observations$model_type[m] = "hw"
m = which(observations$ttype %in% 2)
observations$model_type[m] = "hc"
m = which(observations$ttype %in% 3)
observations$model_type[m] = "hu"
m = which(observations$ttype %in% 4)
observations$model_type[m] = "hs"
m = which(observations$ttype %in% 5)
observations$model_type[m] = "ho"
m = which(observations$ttype %in% 6)
observations$model_type[m] = "wo"
m = which(observations$ttype %in% 7)
observations$model_type[m] = "oo"

tours = pick(observations,
             pid,
             mode,
             xfactor,
             model_type,
             closed,
             inverted,
             ipeak,
             jpeak)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor

# Calculating generation
background = load1(ancfile("primary/background.RData"))
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
write.csv2(stat, file="generation.csv", row.names=FALSE)
print(stat)

