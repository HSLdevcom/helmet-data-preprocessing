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
             closed,
             inverted,
             ipeak,
             jpeak)
tours$weight = ifelse(tours$closed %in% 1, 1, 0.5) * tours$xfactor

# Output
check.na(tours)
tours = downclass(tours)
save(tours, file="tours.RData")
