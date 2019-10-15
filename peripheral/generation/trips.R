# -*- coding: utf-8-unix -*-
library(strafica)
source(ancfile("util.R"))

observations = load1(ancfile("primary/observations.RData"))

# Tour types in peripheral models
observations$model_type = NA
m = which(observations$ttype %in% 1)
observations$model_type[m] = 1
m = which(observations$ttype %in% 2:5)
observations$model_type[m] = 2
m = which(observations$ttype %in% 6:7)
observations$model_type[m] = 3

# Inverted tours visit destination before origin
observations$inverted = is_inverted(observations$order)

# All tours generate at least one trip
temp = observations
trips = pick(temp,
             pid,
             mode,
             xfactor,
             model_type,
             inverted,
             ipeak,
             jpeak)
trips$direction = ifelse(trips$inverted, "back", "there")
trips$trip_time = ifelse(trips$direction=="there", trips$ipeak, trips$jpeak)
trips = unpick(trips, ipeak, jpeak)

# Closed tours with several trips generate one trip more
temp = subset(observations, closed %in% 1 & no_of_trips>1)
trips2 = pick(temp,
              pid,
              mode,
              xfactor,
              model_type,
              inverted,
              ipeak,
              jpeak)
trips2$direction = ifelse(trips2$inverted, "there", "back")
trips2$trip_time = ifelse(trips2$direction=="there", trips2$ipeak, trips2$jpeak)

trips = rbind_list(trips, trips2)
trips = unpick(trips, ipeak, jpeak)

# Output
check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
