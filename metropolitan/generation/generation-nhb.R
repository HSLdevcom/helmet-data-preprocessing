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

# Calculating generation for non-home-based trips
background = load1(ancfile("primary/background.RData"))
stat = fold(trips, .(model_type),
            n=length(pid),
            xfactor=sum(xfactor))
stat$xfactor_per_person = stat$xfactor / sum(background$xfactor)
write.csv2(stat, file="generation-nhb.csv", row.names=FALSE)
print(stat)
