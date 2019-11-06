# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("metropolitan/secondary/observations.RData"))

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

tours = pick(observations,
             pid,
             mode,
             xfactor,
             model_type,
             closed)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor
check.na(tours)

background = load1(ancfile("metropolitan/primary/background.RData"))
stat = fold(tours, .(model_type),
            n=length(pid),
            weight=sum(weight))
stat$weight_per_person = stat$weight / sum(background$xfactor)
write.csv2(stat, file="generation-metropolitan-secondary.csv", row.names=FALSE)
print(stat)
