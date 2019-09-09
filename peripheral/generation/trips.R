# -*- coding: utf-8-unix -*-
library(strafica)

observations = load1(ancfile("primary/observations.RData"))

# Tour types in peripheral model
observations$ttype_peripheral = NA
m = which(observations$ttype %in% 1)
observations$ttype_peripheral[m] = 1
m = which(observations$ttype %in% 2:5)
observations$ttype_peripheral[m] = 2
m = which(observations$ttype %in% 6:7)
observations$ttype_peripheral[m] = 3

# If destination is visited before origin, the tour is inverted
observations$inverted = ifelse(observations$order %in% c("BA","BAC","BCA","CBA"),
                               TRUE,
                               FALSE)

# If the tour is inverted, the first trip is a return trip (from destination
# back to origin)
observations$return = ifelse(observations$inverted,
                             TRUE,
                             FALSE)
observations$time = ifelse(observations$return,
                           observations$jpeak,
                           observations$ipeak)

# Closed trips are doubled: the return status is negated to account for a trip
# to other direction
trips_return = subset(observations, closed %in% 1)
trips_return$return = !(trips_return$return)
trips_return$time = ifelse(trips_return$return,
                           trips_return$jpeak,
                           trips_return$ipeak)
trips = rbind_list(observations,
                   trips_return)

check.na(trips)
trips = downclass(trips)
save(trips, file="trips.RData")
