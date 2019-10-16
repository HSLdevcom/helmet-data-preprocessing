# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("secondary/observations.RData"))

# Tour types
observations = subset(observations, ttype %in% c(1:7))
observations$model_type = NA
m = which(observations$ttype %in% 1)
observations$model_type[m] = "hw-secondary"
m = which(observations$ttype %in% 2)
observations$model_type[m] = "hc-secondary"
m = which(observations$ttype %in% 3)
observations$model_type[m] = "hu-secondary"
m = which(observations$ttype %in% 4)
observations$model_type[m] = "hs-secondary"
m = which(observations$ttype %in% 5)
observations$model_type[m] = "ho-secondary"
m = which(observations$ttype %in% 6)
observations$model_type[m] = "wo-secondary"
m = which(observations$ttype %in% 7)
observations$model_type[m] = "oo-secondary"

trips = pick(observations,
             pid,
             mode,
             xfactor,
             model_type)

# Calculating generation for non-home-based trips
background = load1(ancfile("primary/background.RData"))
stat = fold(trips, .(model_type),
            n=length(pid),
            xfactor=sum(xfactor))
stat$xfactor_per_person = stat$xfactor / sum(background$xfactor)
write.csv2(stat, file="generation-secondary.csv", row.names=FALSE)
print(stat)
